local ServerScriptService = game:GetService("ServerScriptService").Server
local BombHandler = require(script.Parent.BombHandler)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local BindableEvents = ServerScriptService.BindableEvents
local BombGUI = ReplicatedStorage.BombGUI
local PlayersPlayingList = {}
local GameTablesList = {}
local GameModule = {}

function GameModule.AddGameTableToList(tableID: string, tableRef: Model?)
	GameTablesList[tableID] = tableRef
	print(GameTablesList)
end

function GameModule.RemoveGameTableFromList(tableID: string)
	GameTablesList[tableID] = nil
	print(GameTablesList)
end
function GameModule.GetGameTable(tableID: string)
	return GameTablesList[tableID]
end

function GameModule.AssignPlayerToTable(tableID: string, playerRef: Player)
	local playerModel = playerRef.Character
	playerModel:SetAttribute("AssignedTable", tableID)
	PlayersPlayingList[tableID] = PlayersPlayingList[tableID] or {}
	PlayersPlayingList[tableID][playerRef] = {}
	PlayersPlayingList[tableID][playerRef].YourTurn = false
	BindableEvents.PlayerAddedToTable:Fire(tableID, playerRef)
end

function GameModule.UnAssignPlayerFromTable(tableID: string, playerRef: Player)
	local playerModel = playerRef.Character
	local playerInTable = PlayersPlayingList[tableID][playerRef]

	playerModel:SetAttribute("AssignedTable", nil)
	if playerInTable.BombGUI then
		Remotes.DisconnectGUI:FireClient(playerRef, playerInTable.BombGUI)
	end
	playerInTable = nil
	BindableEvents.PlayerRemovedFromTable:Fire(tableID, playerRef)
	print(`Unassigned player from table {tableID}, {PlayersPlayingList[tableID]} `)
end

local function DisablePlayerControlsOnTable(tableID)
	print("disable controls called")
	print(PlayersPlayingList[tableID])
	for player, _ in pairs(PlayersPlayingList[tableID]) do
		Remotes.DisableControls:FireClient(player, true)
		Remotes.EnableFirstPerson:FireClient(player, true)
	end
end

local function AddBombGUI(gameTable: Model, tableID: string)
	local firstPlayerTurn = nil
	for player, _ in pairs(PlayersPlayingList[tableID]) do
		local gui = BombGUI.BombGUI:Clone()
		gui.Parent = player:FindFirstChild("PlayerGui")

		-- initialize turn, one should be true and one should be false
		if firstPlayerTurn == nil then
			local randTurn = math.random() < 0.5
			PlayersPlayingList[tableID][player].YourTurn = randTurn
			firstPlayerTurn = randTurn
			print(`First player turn set to {firstPlayerTurn}`)
			gui.Enabled = randTurn
		else
			PlayersPlayingList[tableID][player].YourTurn = not firstPlayerTurn
			gui.Enabled = not firstPlayerTurn
			print(`Second player turn set to {not firstPlayerTurn}`)
		end

		PlayersPlayingList[tableID][player].BombGUI = gui
		Remotes.ConnectGUI:FireClient(player, gameTable, gui)
	end
end

function GameModule.RespawnTable(tableID: string)
	local oldTable = GameTablesList[tableID]
	local oldTablePos = oldTable:GetPivot()
	oldTable:Destroy()

	local newTable = ReplicatedStorage.Models.GameTable:Clone()
	GameModule.AddGameTableToList(tableID, newTable)
	newTable:SetAttribute("ID", tableID)
	newTable.Parent = workspace
	newTable:PivotTo(oldTablePos)
end

function GameModule.FinishGame(tableID: string)
	for player in pairs(PlayersPlayingList[tableID]) do
		local playerInTable = PlayersPlayingList[tableID][player]

		if playerInTable.YourTurn then
			-- death event should disconnect the GUI, and remove from list
			player.Character.Humanoid.Health = 0
			continue
		end

		print(`Winner: {player.DisplayName}`)
		Remotes.EnableFirstPerson:FireClient(player, false)
		Remotes.DisableControls:FireClient(player, false)
		GameModule.UnAssignPlayerFromTable(tableID, player)
	end
	GameModule.RespawnTable(tableID)
end

function GameModule.NextTurn(tableID: string)
	for player in pairs(PlayersPlayingList[tableID]) do
		local playerInTable = PlayersPlayingList[tableID][player]
		print("Next turn should occur.")
		if playerInTable.YourTurn then
			playerInTable.YourTurn = false
			playerInTable.BombGUI.Enabled = false
			print("GUI should disable.")
		else
			playerInTable.YourTurn = true
			playerInTable.BombGUI.Enabled = true
			print("GUI should enable.")
		end
	end
end

function GameModule.BeginGame(gameTable: Model)
	local bomb = gameTable:FindFirstChild("Bomb")
	local tableID = gameTable:GetAttribute("ID")
	gameTable:SetAttribute("GameActive", true)
	DisablePlayerControlsOnTable(tableID)
	BombHandler.InitializeBomb(bomb, gameTable)
	AddBombGUI(gameTable, tableID)
	GameModule.NextTurn(tableID)
end

return GameModule
