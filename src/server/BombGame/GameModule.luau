local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService").Server
local ServerStorage = game:GetService("ServerStorage")
local InventoryEvents = require(ServerScriptService.Inventory.InventoryEvents)
local LeaderboardHandler = require(ServerScriptService.Leaderboards.LeaderboardHandler)
local GUIRemotes = require(ServerScriptService.ServerRemotesLogic.GUIRemotes)
local OrderedDataStores = require(ServerScriptService.ServerData.OrderedDataStores)
local SoundToClient = require(ServerScriptService.ServerRemotesLogic.SoundToClient)
local BombConfig = require(ReplicatedStorage.Config.BombSharedConfig)
local VIPHandler = require(ReplicatedStorage.VIP.VIPHandler)
local DataService = require(ReplicatedStorage.Packages.DataService).server
local UtilityModule = require(ReplicatedStorage.Utility.UtilityModule)
local Networker = require(ReplicatedStorage.Packages.Networker).server
local BombGameStorage = require(script.Parent.BombGameStorage)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local BombHandler = require(script.Parent.BombHandler)
local BombServerConfig = require(script.Parent.BombServerConfig)
local Remotes = ReplicatedStorage.Remotes
local GameTablesList = BombGameStorage.GetGameTablesList()
local PlayersPlayingList = BombGameStorage.GetPlayerList()
local GUINetwork = GUIRemotes.networker

local WIN_REWARD = 100
local LOSE_REWARD = 50

local GameModule = {}

function GameModule:DisablePlayerControlsOnTable(tableID)
	print("disable controls called")
	print(PlayersPlayingList[tableID])
	for player, _ in pairs(PlayersPlayingList[tableID]) do
		self.inputNetworker:fire(player, "DisableControls", true)
		self.inputNetworker:fire(player, "EnableFirstPerson", true)
	end
end

function GameModule:PlayAudioForTablePlayers(tableID: string, audioID: string, oneShot: boolean)
	for player, _ in pairs(PlayersPlayingList[tableID]) do
		if oneShot then
			SoundToClient:PlaySoundOnClient(player, audioID, nil, false, nil)
		else
			SoundToClient:PlaySoundOnClient(player, audioID, nil, true, nil)
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
			GUINetwork:fire(player, "SyncTurn", randTurn)
		else
			PlayersPlayingList[tableID][player].YourTurn = not firstPlayerTurn
			GUINetwork:fire(player, "SyncTurn", not firstPlayerTurn)
			print(`Second player turn set to {not firstPlayerTurn}`)
		end
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

	DataService:update(loser, { "currency" }, function(currentCash)
		return currentCash + VIPHandler.DoubleRewardsIfVIP(loser, LOSE_REWARD)
	end)

	local humanoid = loser.Character.Humanoid
	humanoid.Health = 0
	SoundToClient:PlaySoundOnClient(loser, SoundManager.GameSounds.Lose, nil, false, nil)
end

local function HandleWinner(winner: Player)
	if not winner then
		print("Winner player ref is nil!")
	end

	-- update to store
	DataService:update(winner, { "currency" }, function(currentCash)
		return currentCash + VIPHandler.DoubleRewardsIfVIP(winner, WIN_REWARD)
	end)
	LeaderboardHandler.AddValueToDataStore(OrderedDataStores.WinStore, winner, 1)

	SoundToClient:PlaySoundOnClient(winner, SoundManager.GameSounds.Win, nil, false, nil)
	print(`Winner: {winner.DisplayName}`)
end

function GameModule:FinishGame(tableID: string)
	local loser: Player = nil
	local winner: Player = nil
	BombGameStorage.GetGameTable(tableID):SetAttribute("GameActive", false)
	GameModule:PlayAudioForTablePlayers(tableID, SoundManager.GetRandomMainSound(), false)
	for player in pairs(PlayersPlayingList[tableID]) do
		local playerInTable = PlayersPlayingList[tableID][player]

		self.inputNetworker:fire(player, "DisableControls", false)
		self.inputNetworker:fire(player, "EnableFirstPerson", false)

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
	-- clamp for anti input exploitation
	playerInputOnExceed = math.clamp(playerInputOnExceed, 1, 600)
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

			GUINetwork:fire(player, "UpdateCountdownBar", timeLeft)
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
			GUINetwork:fire(player, "SyncTurn", false)
			print("GUI should disable.")
		else
			playerInTable.YourTurn = true
			GUINetwork:fire(player, "SyncTurn", true)
			GameModule.StartCountdown(tableID, playerInTable, player)
			print("GUI should enable.")
		end
	end
end

function GameModule:SubmitBombTime(_: Player, tableID: string, timeToReduce: number)
	local tableRef = BombGameStorage.GetGameTable(tableID)
	local bombRef = UtilityModule.Get(tableRef, "Bomb")
	timeToReduce = math.clamp(timeToReduce, 1, BombServerConfig.MAX_BOMB_TIME)
	local newTime = BombHandler.ReduceBombTime(bombRef, timeToReduce)

	if newTime > 0 then
		GameModule.NextTurn(tableID)
	end
end

function GameModule.SetBombSkin(gameTable: Model, tableID: string)
	-- pick random bomb skin
	local playerList = BombGameStorage.GetPlayerList()
	local playersInTable = playerList[tableID]
	local bomb = gameTable:FindFirstChild("Bomb")
	local equippedBombs = {}
	for playerRef, _ in pairs(playersInTable) do
		local objectEquipped = DataService:get(playerRef, { "bombEquipped" })
		table.insert(equippedBombs, objectEquipped)
	end

	local chosenBombName = equippedBombs[math.random(#equippedBombs)]
	InventoryEvents.SetEquippedSkin("bombEquipped", "Bombs", chosenBombName, bomb)
end

function GameModule.BeginGame(gameTable: Model)
	local bomb = gameTable:FindFirstChild("Bomb")
	local tableID = gameTable:GetAttribute("ID")

	GameModule.SetBombSkin(gameTable, tableID)
	gameTable:SetAttribute("GameActive", true)

	GameModule:PlayAudioForTablePlayers(tableID, SoundManager.GetRandomBombThemeSound(), false)
	GameModule:DisablePlayerControlsOnTable(tableID)

	BombHandler.InitializeBomb(bomb, gameTable)
	SetInitialTurn(tableID)

	GameModule.NextTurn(tableID)
end

GameModule.inputNetworker = Networker.new("InputRemotes", GameModule, { GameModule.SubmitBombTime })

return GameModule
