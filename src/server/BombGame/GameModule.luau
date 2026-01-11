local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local BombConfig = require(ReplicatedStorage.Config.BombConfig)
local BombGameStorage = require(script.Parent.BombGameStorage)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local BombHandler = require(script.Parent.BombHandler)
local Remotes = ReplicatedStorage.Remotes
local GameTablesList = BombGameStorage.GetGameTablesList()
local PlayersPlayingList = BombGameStorage.GetPlayerList()
local GameModule = {}

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
local function SetInitialTurn(tableID: string)
	local firstPlayerTurn = nil
	print(PlayersPlayingList)
	for player in pairs(PlayersPlayingList[tableID]) do
		-- initialize turn, one should be true and one should be false
		if firstPlayerTurn == nil then
			local randTurn = math.random() < 0.5
			PlayersPlayingList[tableID][player].YourTurn = randTurn
			firstPlayerTurn = randTurn

			print(`First player turn set to {firstPlayerTurn}`)
			Remotes.SyncTurn:FireClient(player, randTurn)
		else
			PlayersPlayingList[tableID][player].YourTurn = not firstPlayerTurn
			Remotes.SyncTurn:FireClient(player, not firstPlayerTurn)
			print(`Second player turn set to {not firstPlayerTurn}`)
		end

		--PlayersPlayingList[tableID][player].BombGUI = gui
		--Remotes.ConnectGUI:FireClient(player, gameTable, gui)
	end
end

function GameModule.RespawnTable(tableID: string)
	local oldTable = GameTablesList[tableID]
	local oldTablePos = oldTable:GetPivot()
	oldTable:Destroy()

	local newTable = ServerStorage.Models.GameTable:Clone()
	BombGameStorage.AddGameTableToList(tableID, newTable)

	newTable:SetAttribute("ID", tableID)
	newTable.Parent = workspace
	newTable:PivotTo(oldTablePos)
	print("Table respawned!")
end

local function HandleLoser(loser)
	if not loser then
		print("Loser player ref is nil!")
	end
	local humanoid = loser.Character.Humanoid
	humanoid.Health = 0
end

local function HandleWinner(winner: Player)
	if not winner then
		print("Winner player ref is nil!")
	end
	print(`Winner: {winner.DisplayName}`)
end

function GameModule.FinishGame(tableID: string)
	local loser: Player = nil
	local winner: Player = nil
	BombGameStorage.GetGameTable(tableID):SetAttribute("GameActive", false)
	PlayAudioForTablePlayers(tableID, SoundManager.GetRandomMainSound(), false)
	for player in pairs(PlayersPlayingList[tableID]) do
		local playerInTable = PlayersPlayingList[tableID][player]

		Remotes.EnableFirstPerson:FireClient(player, false)
		Remotes.DisableControls:FireClient(player, false)

		if playerInTable.YourTurn then
			loser = player
			continue
		end
		winner = player
	end
	BombGameStorage.ClearTable(tableID)
	HandleLoser(loser)
	HandleWinner(winner)
	GameModule.RespawnTable(tableID)
end

function ExceededCountdown(tableID: string, player: Player)
	-- countdown finished
	local bombRef = BombGameStorage.GetGameTable(tableID):FindFirstChild("Bomb")
	local playerInputOnExceed = Remotes.GetBombInput:InvokeClient(player)
	local resultingTime = BombHandler.ReduceBombTime(bombRef, playerInputOnExceed)

	-- if newTime is nil, it means bomb isn't active anymore.
	if resultingTime and resultingTime > 0 then
		GameModule.NextTurn(tableID)
	end
end

function GameModule.StartCountdown(tableID: string, playerInTable, player: Player)
	task.spawn(function()
		for timeLeft = BombConfig.MAX_TURN_TIME, 0, -1 do
			if not GameTablesList[tableID]:GetAttribute("GameActive") then
				print("Game not active, don't count down any more")
				return
			end

			if not playerInTable.YourTurn then
				return
			end

			Remotes.UpdateCountdownBar:FireClient(player, timeLeft)
			task.wait(1)
		end

		-- one more check (if they input at 0, it still assumes its your turn)
		if not playerInTable.YourTurn then
			return
		end
		ExceededCountdown(tableID, player)
	end)
end
function GameModule.NextTurn(tableID: string)
	for player in pairs(PlayersPlayingList[tableID]) do
		local playerInTable = PlayersPlayingList[tableID][player]
		print("Next turn should occur.")
		if playerInTable.YourTurn then
			playerInTable.YourTurn = false
			Remotes.SyncTurn:FireClient(player, false)
			print("GUI should disable.")
		else
			playerInTable.YourTurn = true
			Remotes.SyncTurn:FireClient(player, true)
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
	SetInitialTurn(tableID)

	GameModule.NextTurn(tableID)
end

return GameModule
