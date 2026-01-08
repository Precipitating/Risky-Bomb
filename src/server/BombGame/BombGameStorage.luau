local ServerScriptService = game:GetService("ServerScriptService").Server
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local BindableEvents = ServerScriptService.BindableEvents

local BombGameStorage = {}

local PlayersPlayingList = {}
local GameTablesList = {}

function BombGameStorage.GetPlayerList()
	return PlayersPlayingList
end

function BombGameStorage.GetGameTablesList()
	return GameTablesList
end

function BombGameStorage.AddGameTableToList(tableID: string, tableRef: Model?)
	GameTablesList[tableID] = tableRef
	print(GameTablesList)
end

function BombGameStorage.RemoveGameTableFromList(tableID: string)
	GameTablesList[tableID] = nil
	print(`{tableID} removed from game table list!`)
end
function BombGameStorage.GetGameTable(tableID: string)
	return GameTablesList[tableID]
end

function BombGameStorage.AssignPlayerToTable(tableID: string, playerRef: Player)
	local playerModel = playerRef.Character
	playerModel:SetAttribute("AssignedTable", tableID)
	PlayersPlayingList[tableID] = PlayersPlayingList[tableID] or {}
	PlayersPlayingList[tableID][playerRef] = {}
	PlayersPlayingList[tableID][playerRef].YourTurn = false
	BindableEvents.PlayerAddedToTable:Fire(tableID, playerRef)

	print(`{playerRef.DisplayName} added to player's table!`)
end

function BombGameStorage.ClearTable(tableID: string)
	BombGameStorage.GetGameTable(tableID):SetAttribute("GameActive", false)
	for player in pairs(PlayersPlayingList[tableID]) do
		local playerInTable = PlayersPlayingList[tableID][player]
		local playerModel = player.Character
		if playerInTable then
			playerModel:SetAttribute("AssignedTable", nil)
			if playerInTable.BombGUI then
				Remotes.DisconnectGUI:FireClient(player, playerInTable.BombGUI)
			end
			playerInTable = nil
			BindableEvents.PlayerRemovedFromTable:Fire(tableID, player)
			print(`(ClearTable) Unassigned player from table {tableID}, {PlayersPlayingList[tableID]} `)
		end
	end

	-- make sure its clear.
	table.clear(PlayersPlayingList[tableID])
end

function BombGameStorage.GetPlayerCountInTable(tableID: string)
	local count = 0
	for _ in pairs(PlayersPlayingList[tableID]) do
		count += 1
	end

	return count
end

function BombGameStorage.UnAssignSinglePlayerFromTable(tableID: string, player: Player)
	local playerInTable = PlayersPlayingList[tableID][player]
	local playerModel = player.Character
	if playerInTable then
		playerModel:SetAttribute("AssignedTable", nil)
		if playerInTable.BombGUI then
			Remotes.DisconnectGUI:FireClient(player, playerInTable.BombGUI)
		end
		playerInTable = nil
		BindableEvents.PlayerRemovedFromTable:Fire(tableID, player)
		print(`(Unassigned player from table {tableID}, {PlayersPlayingList} `)
	end
end

return BombGameStorage
