local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService").Server
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local InventoryEvents = require(ServerScriptService.Inventory.InventoryEvents)
local CardTypes = require(ServerScriptService.ServerTypes.CardTypes)
local AITypes = require(ServerScriptService.ServerTypes.AITypes)
local Signals = require(ServerScriptService.ServerSignals.Signals)
local GUIRemotes = require(ServerScriptService.ServerRemotesLogic.GUIRemotes)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Table = {}
local COUNTDOWN_TIME = 5
Table.__index = Table

type AIDifficulty = AITypes.AIDifficulty
export type TableReferences = {
	Parent: Model?,
	Chair1: MeshPart?,
	Seat1: Seat?,
	Chair2: MeshPart?,
	Seat2: Seat?,
	Table: Model?,
	Bomb: MeshPart?,
	CameraPos: Part?,
	PlayersJoinedBillboard: BillboardGui?,
	CountdownBillboard: BillboardGui?,
}

type AIType = {
	AIMode: boolean,
	AITurn: boolean,
	AIDifficultyChosen: AIDifficulty?,
	AIModel: Model | MeshPart | Part | nil,
	PlayerID: number?,
	AICard: CardTypes.CardData,
}

function Table.new(table: Model)
	local self = setmetatable({}, Table)
	self.ID = HttpService:GenerateGUID(false)
	self.GameActive = false
	self.Janitor = Janitor.new()
	self.BombTimeLeft = -1
	self.BombActive = false
	self.CountdownActive = false
	self.PlayerCount = 0
	self.CurrentTurn = -1
	self.TurnCounter = 1
	self.BombEffectsActive = {}

	self.PlayersAssigned = {
		[1] = nil,
		[2] = nil,
	}

	self.AIConfig = (
		{
			AIMode = false,
			AITurn = false,
			AIDifficultyConfig = nil,
			AIModel = nil,
			PlayerID = nil,
			AICard = nil,
		}
	) :: AIType

	self.TableRefs = {
		Parent = table,

		Chair1 = table:WaitForChild("Default"),
		Seat1 = table:WaitForChild("Default"):WaitForChild("Seat"),
		Chair2 = table:WaitForChild("Default1"),
		Seat2 = table:WaitForChild("Default1"):WaitForChild("Seat"),

		Table = table:WaitForChild("table"),
		Bomb = table:WaitForChild("Bomb"),
		CameraPos = table:WaitForChild("CameraPos"),

		CountdownText = table
			:WaitForChild("Bomb")
			:WaitForChild("CountdownBillboard")
			:WaitForChild("CountdownTextLabel"),
		PlayersJoinedText = table
			:WaitForChild("Bomb")
			:WaitForChild("PlayersJoinedBillboard")
			:WaitForChild("PlayersJoinedText"),
	} :: TableReferences

	self:Initialize()

	return self
end

local function TableClear(table)
	for key in pairs(table) do
		table[key] = nil
	end
end

function Table:ReduceBombEffectTurns()
	for key, data in pairs(self.BombEffectsActive) do
		if data.TurnsLeft ~= nil then
			if data.TurnsLeft <= 0 then
				self.BombEffectsActive[key] = nil
				warn(`{key} removed from bomb effects`)
			else
				data.TurnsLeft -= 1
			end
		end
	end
end

function Table:Cleanup()
	-- ensure the singleplayer buttons are disabled before deletion
	if self.PlayersAssigned[1] then
		Signals.SinglePlayerNetworkFire:Fire(self.PlayersAssigned[1], "ToggleButtonVisibility", false)
	end
	if self.PlayersAssigned[2] then
		Signals.SinglePlayerNetworkFire:Fire(self.PlayersAssigned[2], "ToggleButtonVisibility", false)
	end

	self.Janitor:Destroy()
	self.BombTimeLeft = nil
	self.BombActive = nil
	self.CountdownActive = nil
	self.PlayerCount = nil
	self.CurrentTurn = nil
	self.GameActive = nil
	self.ID = nil
	self.TurnCounter = nil

	TableClear(self.AIConfig)
	TableClear(self.PlayersAssigned)
	TableClear(self.TableRefs)
	TableClear(self.BombEffectsActive)
	self.PlayersAssigned = nil
	self.BombEffectsActive = nil
	self.TableRefs = nil
	self.AIConfig = nil

	print("Table cleaned up!")
end

function Table:AddReferencesToJanitor()
	for key, ref in pairs(self.TableRefs) do
		if not ref then
			error(`Table Refs: Cannot get {key} reference`)
		end

		if ref then
			self.Janitor:Add(ref)
		end
	end
end

function Table:GetOppositePlayer()
	if self.CurrentTurn ~= 1 and self.CurrentTurn ~= 2 then
		return nil
	end

	return self.PlayersAssigned[3 - self.CurrentTurn]
end

function Table:GetCurrentTurnPlayer()
	if self.AIConfig.AIMode and not self.AIConfig.AITurn then
		return self.PlayersAssigned[self.AIConfig.PlayerID]
	end

	if self.CurrentTurn ~= 1 and self.CurrentTurn ~= 2 then
		return nil
	end

	return self.PlayersAssigned[self.CurrentTurn]
end

function Table:PlayerStoodUp(seatNumber: number)
	print(`Player stood up`)
	local player = self.PlayersAssigned[seatNumber]
	local unsatPlayer = player.Character

	if unsatPlayer then
		unsatPlayer:SetAttribute("ID", nil)
		Signals.SinglePlayerNetworkFire:Fire(player, "ToggleButtonVisibility", false)
		-- if another player exists on other chair, renenable singleplayer button
		local otherPlayerExists = self.PlayersAssigned[3 - seatNumber]
		if otherPlayerExists and not self.GameActive then
			Signals.SinglePlayerNetworkFire:Fire(otherPlayerExists, "ToggleButtonVisibility", true)
		end
	else
		-- someone left midgame, abrupt end
		if self.GameActive then
			Signals.AbruptEnd:Fire(self, self.PlayersAssigned[3 - seatNumber])
			return
		end
	end

	GUIRemotes.networker:fire(player, "BombGUIDisconnect")

	-- reset values
	self.PlayersAssigned[seatNumber] = nil
	self.PlayerCount = math.clamp(self.PlayerCount - 1, 0, 2)

	self.TableRefs.PlayersJoinedText.Text = `<b>Players Joined: {tostring(self.PlayerCount)}/2</b>`
	InventoryEvents.ResetSkin("Chairs", self.TableRefs[`Chair{tostring(seatNumber)}`])

	if self.CountdownActive then
		self.CountdownActive = false
	end
end

function Table:PlayerSatDown(humanoid: Humanoid, seatNumber: number)
	local character = humanoid.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		error("Failed to get player reference sitting down")
	end

	-- set table's ID to player's model
	self.PlayersAssigned[seatNumber] = player
	print(self.PlayersAssigned[seatNumber])
	character:SetAttribute("ID", self.ID)
	self.PlayerCount = math.clamp(self.PlayerCount + 1, 0, 2)

	-- equip the chair skin
	InventoryEvents.SetEquippedSkin(
		"chairEquipped",
		"Chairs",
		self.PlayersAssigned[seatNumber],
		self.TableRefs[`Chair{tostring(seatNumber)}`]
	)

	-- make singleplayer button available if we're alone
	if self.PlayerCount == 1 then
		Signals.SinglePlayerNetworkFire:Fire(player, "ToggleButtonVisibility", true)
	end

	-- update the bomb billboard text
	self.TableRefs.PlayersJoinedText.Text = `<b>Players Joined: {tostring(self.PlayerCount)}/2</b>`
	print(self.TableRefs.PlayersJoinedText.Text)

	-- start countdown if 2 players
	if self.PlayerCount == 2 then
		self:StartCountdown()
		Signals.SinglePlayerNetworkFire:Fire(self.PlayersAssigned[3 - seatNumber], "ToggleButtonVisibility", false)
	end
end

function Table:PlayerSatOrLeft(seat: Seat, seatNumber: number)
	local humanoid = seat.Occupant
	-- means player stood up
	if not humanoid then
		self:PlayerStoodUp(seatNumber)
	else
		-- else sat down
		self:PlayerSatDown(humanoid, seatNumber)
	end
end

function Table:StartCountdown()
	if self.PlayersAssigned[1] == nil or self.PlayersAssigned[2] == nil then
		warn("Missing player references for table")
		return
	end

	local function ShouldStopTimer()
		if self.PlayerCount < 2 or self.CountdownActive == false then
			warn("Timer interruption")
			self.TableRefs.CountdownText.Visible = false

			return true
		end
		return false
	end

	-- countdown thread
	task.spawn(function()
		self.CountdownActive = true
		self.TableRefs.CountdownText.Visible = true

		for i = COUNTDOWN_TIME, 0, -1 do
			if ShouldStopTimer() then
				return
			end
			self.TableRefs.CountdownText.Text = tostring(math.max(0, i))
			task.wait(1)
		end

		if ShouldStopTimer() then
			return
		end

		-- should start playing here
		self.TableRefs.CountdownText.Visible = false
		self.TableRefs.PlayersJoinedText.Visible = false
		self.CountdownActive = false

		Signals.BeginGame:Fire(self)
	end)
end

function Table:RemoveChair(chairID: number)
	if chairID == 1 then
		if self.TableRefs.Chair1 then
			self.TableRefs.Chair1:Destroy()
			self.TableRefs.Seat1 = nil
			self.Janitor:Remove("Seat1Connection")
		end
	elseif chairID == 2 then
		if self.TableRefs.Chair2 then
			self.TableRefs.Chair2:Destroy()
			self.TableRefs.Seat2 = nil
			self.Janitor:Remove("Seat2Connection")
		end
	end
end

function Table:ConnectSeats()
	local seat1 = self.TableRefs.Seat1
	local seat2 = self.TableRefs.Seat2
	self.Janitor:Add(
		seat1:GetPropertyChangedSignal("Occupant"):Connect(function()
			self:PlayerSatOrLeft(seat1, 1)
		end),
		"Disconnect",
		"Seat1Connection"
	)

	self.Janitor:Add(
		seat2:GetPropertyChangedSignal("Occupant"):Connect(function()
			self:PlayerSatOrLeft(seat2, 2)
		end),
		"Disconnect",
		"Seat2Connection"
	)
end

function Table:Initialize()
	self:AddReferencesToJanitor()
	self:ConnectSeats()
end

return Table
