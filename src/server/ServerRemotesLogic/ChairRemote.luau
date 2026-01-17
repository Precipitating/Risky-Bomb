local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService").Server
local Networker = require(ReplicatedStorage.Packages.Networker).server
local DataService = require(ReplicatedStorage.Packages.DataService).server
local UtilityModule = require(ReplicatedStorage.Utility.UtilityModule)
local GameModule = require(ServerScriptService.BombGame.GameModule)
local BombGameStorage = require(ServerScriptService.BombGame.BombGameStorage)
local CountdownTime: number = 3
local ChairRemote = {}

local function StopCountDown(countdownText: TextLabel)
	countdownText.Visible = false
	countdownText.Text = tostring(CountdownTime)
end

local function StartCountDown(playerCountText: TextLabel, countdownText: TextLabel, gameTable: Model)
	if countdownText:GetAttribute("Active") then
		return
	end

	countdownText.Visible = true
	countdownText:SetAttribute("Active", true)

	task.spawn(function()
		for i = CountdownTime, 0, -1 do
			if not countdownText:GetAttribute("Active") then
				StopCountDown(countdownText)
				return
			end
			countdownText.Text = tostring(math.clamp(i, 0, CountdownTime))
			task.wait(1)
		end

		-- one last check
		if not countdownText:GetAttribute("Active") then
			StopCountDown(countdownText)
			return
		end

		-- succesfully counted down without players leaving
		countdownText.Visible = false
		playerCountText.Visible = false

		print("Start game!")
		GameModule.BeginGame(gameTable)
	end)
end

local function ResetChair(chair: MeshPart)
	local skinModel: MeshPart = ReplicatedStorage.Chairs:FindFirstChild("Default", true)
	if not skinModel then
		warn(`Can't find default chair mesh`)
		return
	end
	local newMesh = AssetService:CreateMeshPartAsync(skinModel.MeshId)
	chair:ApplyMesh(newMesh)
	chair.TextureID = skinModel.TextureID
	chair.Size = skinModel.Size
	chair.CFrame *= chair.PivotOffset:Inverse()
	chair.PivotOffset = CFrame.identity
	newMesh:Destroy()
end

local function SetChairSkinToEquipped(player: Player, chair: MeshPart)
	local chairEquipped = DataService:get(player, { "chairEquipped" })
	if not chairEquipped then
		warn("Cannot get chairEquipped, check key is accessed properly.")
		return
	end
	print(chairEquipped)

	-- get skin chair mesh
	local skinMesh: MeshPart = ReplicatedStorage.Chairs:FindFirstChild(chairEquipped.Name, true)
	if not skinMesh then
		warn(`Can't find chair model {chairEquipped.Name}`)
		return
	end
	chair.PivotOffset = skinMesh.PivotOffset
	skinMesh:PivotTo(chair:GetPivot())

	chair.CFrame *= skinMesh.PivotOffset

	local newMesh = AssetService:CreateMeshPartAsync(skinMesh.MeshId)
	chair:ApplyMesh(newMesh)
	if chairEquipped.Name == "Default" then
		chair.TextureID = skinMesh.TextureID
	end

	-- update mesh's info to match equipped chair
	chair.BrickColor = chairEquipped.Color
	chair.Size = skinMesh.Size
	chair.Material = chairEquipped.Material

	-- set the new skin's seat position - it may be different
	local chairSeat = chair:FindFirstChildOfClass("Seat")
	local skinMeshSeat = skinMesh:FindFirstChildOfClass("Seat")
	chairSeat:PivotTo(skinMeshSeat:GetPivot())
	newMesh:Destroy()
end

function ChairRemote:ChairSat(player: Player, gameTable, chair: MeshPart, sat: boolean)
	local playerCountText: TextLabel = gameTable
		:FindFirstChild("Bomb")
		:FindFirstChild("PlayersJoinedBillboard")
		:FindFirstChildOfClass("TextLabel", true)

	local countdownText: TextLabel =
		gameTable:FindFirstChild("Bomb"):FindFirstChild("CountdownBillboard"):FindFirstChildOfClass("TextLabel", true)

	-- set chair skin if applicable
	if sat then
		SetChairSkinToEquipped(player, chair)
	else
		ResetChair(chair)
	end
	-- modify players joined count
	local currentJoined = playerCountText:GetAttribute("JoinedCount")
	print(currentJoined)
	local newCurrentJoined = sat and math.clamp(currentJoined + 1, 0, 2) or math.clamp(currentJoined - 1, 0, 2)
	playerCountText:SetAttribute("JoinedCount", newCurrentJoined)
	playerCountText.Text = `<b>Players Joined: {newCurrentJoined}/2</b>`

	-- add player reference to table's ID dictionary (on server)
	if sat then
		BombGameStorage.AssignPlayerToTable(gameTable:GetAttribute("ID"), player)
	else
		BombGameStorage.UnAssignSinglePlayerFromTable(gameTable:GetAttribute("ID"), player)
	end

	print(playerCountText:GetAttribute("JoinedCount"))

	-- start countdown if 2 players sat down
	if newCurrentJoined == 2 then
		StartCountDown(playerCountText, countdownText, gameTable)
	end

	-- stop countdown if 1 player
	if not sat and countdownText:GetAttribute("Active") then
		countdownText:SetAttribute("Active", false)
		gameTable:SetAttribute("GameActive", false)
	end
end

ChairRemote.networker = Networker.new("ChairRemotes", ChairRemote, {
	ChairRemote.ChairSat,
})

return ChairRemote
