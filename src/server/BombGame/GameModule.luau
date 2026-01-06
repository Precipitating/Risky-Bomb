local ServerScriptService = game:GetService("ServerScriptService").Server
local BombHandler = require(script.Parent.BombHandler)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local BindableEvents = ServerScriptService.BindableEvents
local PlayersPlayingList = {}
local GameTablesList = {}
local GameModule = {}

function GameModule.AddGameTableToList(tableID: string, tableRef: Model?)
	GameTablesList[tableID] = tableRef
	print(GameTablesList)
end

function GameModule.GetGameTable(tableID: string)
	return GameTablesList[tableID]
end

function GameModule.AssignPlayerToTable(tableID: string, playerRef: Player)
	local playerModel = playerRef.Character
	playerModel:SetAttribute("AssignedTable", tableID)
	PlayersPlayingList[tableID] = PlayersPlayingList[tableID] or {}
	PlayersPlayingList[tableID][playerRef] = true
	BindableEvents.PlayerAddedToTable:Fire(tableID, playerRef)
end

function GameModule.UnAssignPlayerToTable(tableID: string, playerRef: Player)
	local playerModel = playerRef.Character
	playerModel:SetAttribute("AssignedTable", nil)
	PlayersPlayingList[tableID][playerRef] = nil
	BindableEvents.PlayerRemovedFromTable:Fire(tableID, playerRef)
end

local function DisablePlayerControlsOnTable(tableID)
	print("disable controls called")
	print(PlayersPlayingList[tableID])
	for player, _ in pairs(PlayersPlayingList[tableID]) do
		Remotes.DisableControls:FireClient(player, true)
		Remotes.EnableFirstPerson:FireClient(player, true)
	end
end

-- should only be ONE player here, as the loser should be dead.
function GameModule.FinishGame(tableID: string)
	for player in pairs(PlayersPlayingList[tableID]) do
		print(`Winner: {player.DisplayName}`)
		Remotes.EnableFirstPerson:FireClient(player, false)
		Remotes.DisableControls:FireClient(player, false)
		break
	end
	GameTablesList[tableID]:SetAttribute("GameActive", false)
end

function GameModule.BeginGame(gameTable: Model)
	gameTable:SetAttribute("GameActive", true)
	local bomb = gameTable:FindFirstChild("Bomb")
	DisablePlayerControlsOnTable(gameTable:GetAttribute("ID"))
	BombHandler.InitializeBomb(bomb)
end

return GameModule
