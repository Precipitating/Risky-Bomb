local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService").Server
local BombGameStorage = require(script.Parent.BombGameStorage)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local BombHandler = require(script.Parent.BombHandler)
local Remotes = ReplicatedStorage.Remotes
local BindableEvents = ServerScriptService.BindableEvents
local BombGUI = ReplicatedStorage.BombGUI
local GameTablesList = BombGameStorage.GetGameTablesList()
local PlayersPlayingList = BombGameStorage.GetPlayerList()
local COUNTDOWN_TIME = 5
local GameModule = {}

function GameModule.AddGameTableToList(tableID: string, tableRef: Model?)
	GameTablesList[tableID] = tableRef
	print(GameTablesList)
end

function GameModule.RemoveGameTableFromList(tableID: string)
	GameTablesList[tableID] = nil
	print(`{tableID} removed from game table list!`)
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

	print(`{playerRef.DisplayName} added to player's table!`)
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

local function PlayAudioForTablePlayers(tableID: string, audioID: string, oneShot: boolean)
	for player, _ in pairs(PlayersPlayingList[tableID]) do
		if oneShot then
			Remotes.PlaySoundOnClient:FireClient(player, audioID, nil, false, nil)
		else
			Remotes.PlaySoundOnClient:FireClient(player, audioID, nil, true, nil)
		end
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

	local newTable = ServerStorage.Models.GameTable:Clone()
	GameModule.AddGameTableToList(tableID, newTable)
	newTable:SetAttribute("ID", tableID)
	newTable.Parent = workspace
	newTable:PivotTo(oldTablePos)
end

function GameModule.FinishGame(tableID: string)
	PlayAudioForTablePlayers(tableID, SoundManager.GetRandomMainSound(), false)
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

function ExceededCountdown(tableID: string)
	-- countdown finished
	local bombRef = BombGameStorage.GetGameTablesList()[tableID]:FindFirstChild("Bomb")
	local newTime = BombHandler.ReduceBombTime(bombRef, 10)
	if newTime > 0 then
		GameModule.NextTurn(tableID)
	end
end

function GameModule.StartCountdown(tableID: string, playerInTable, player: Player)
	task.spawn(function()
		for timeLeft = COUNTDOWN_TIME, 0, -1 do
			if not playerInTable.YourTurn then
				Remotes.UpdateCountdownBar:FireClient(player, playerInTable.BombGUI, nil)
				return
			end
			Remotes.UpdateCountdownBar:FireClient(player, playerInTable.BombGUI, timeLeft / COUNTDOWN_TIME)
			task.wait(1)
		end
		-- one more check (if they input at 0, it still assumes its your turn)
		if not playerInTable.YourTurn then
			Remotes.UpdateCountdownBar:FireClient(player, playerInTable.BombGUI, nil)
			return
		end
		ExceededCountdown(tableID)
	end)
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
			GameModule.StartCountdown(tableID, playerInTable, player)
			print("GUI should enable.")
		end
	end
end

function GameModule.BeginGame(gameTable: Model)
	local bomb = gameTable:FindFirstChild("Bomb")
	local tableID = gameTable:GetAttribute("ID")
	gameTable:SetAttribute("GameActive", true)

	PlayAudioForTablePlayers(tableID, SoundManager.GetRandomBombThemeSound(), false)
	DisablePlayerControlsOnTable(tableID)

	BombHandler.InitializeBomb(bomb, gameTable)
	AddBombGUI(gameTable, tableID)

	GameModule.NextTurn(tableID)
end

return GameModule
