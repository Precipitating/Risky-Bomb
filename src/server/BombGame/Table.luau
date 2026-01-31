local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService").Server
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local InventoryEvents = require(ServerScriptService.Inventory.InventoryEvents)
local Signals = require(ServerScriptService.ServerSignals.Signals)
local GUIRemotes = require(ServerScriptService.ServerRemotesLogic.GUIRemotes)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Table = {}
local COUNTDOWN_TIME = 5
Table.__index = Table

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

	self.PlayersAssigned = {
		[1] = nil,
		[2] = nil,
	}

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

function Table:Cleanup()
	self.Janitor:Destroy()
	self.BombTimeLeft = nil
	self.BombActive = nil
	self.CountdownActive = nil
	self.PlayerCount = nil
	self.CurrentTurn = nil
	self.GameActive = nil
	self.ID = nil
	table.clear(self.PlayersAssigned)
	table.clear(self.TableRefs)
	self.PlayersAssigned = nil
	self.TableRefs = nil
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

function Table:PlayerSatOrLeft(seat: Seat, seatNumber: number)
	local humanoid = seat.Occupant
	-- means player stood up
	if not humanoid then
		print(`Player stood up`)
		local player = self.PlayersAssigned[seatNumber]
		local unsatPlayer = player.Character
		unsatPlayer:SetAttribute("ID", nil)
		GUIRemotes.networker:fire(player, "BombGUIDisconnect")
		player = nil
		self.PlayerCount = math.clamp(self.PlayerCount - 1, 0, 2)
		self.TableRefs.PlayersJoinedText.Text = `<b>Players Joined: {tostring(self.PlayerCount)}/2</b>`
		InventoryEvents.ResetSkin("Chairs", self.TableRefs[`Chair{tostring(seatNumber)}`])

		if self.CountdownActive then
			self.CountdownActive = false
		end
		return
	end

	-- player sat down
	local character = humanoid.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		error("Failed to get player reference sitting down")
	end

	self.PlayersAssigned[seatNumber] = player
	character:SetAttribute("ID", self.ID)
	self.PlayerCount = math.clamp(self.PlayerCount + 1, 0, 2)

	InventoryEvents.SetEquippedSkin(
		"chairEquipped",
		"Chairs",
		self.PlayersAssigned[seatNumber],
		self.TableRefs[`Chair{tostring(seatNumber)}`]
	)

	self.TableRefs.PlayersJoinedText.Text = `<b>Players Joined: {tostring(self.PlayerCount)}/2</b>`
	print(self.TableRefs.PlayersJoinedText.Text)
	if self.PlayerCount == 2 then
		self:StartCountdown()
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

function Table:ConnectSeats()
	local seat1 = self.TableRefs.Seat1
	local seat2 = self.TableRefs.Seat2
	self.Janitor:Add(seat1:GetPropertyChangedSignal("Occupant"):Connect(function()
		self:PlayerSatOrLeft(seat1, 1)
	end))

	self.Janitor:Add(seat2:GetPropertyChangedSignal("Occupant"):Connect(function()
		self:PlayerSatOrLeft(seat2, 2)
	end))
end

function Table:Initialize()
	self:AddReferencesToJanitor()
	self:ConnectSeats()
end

return Table
