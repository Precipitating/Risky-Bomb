local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService").Server
local ServerStorage = game:GetService("ServerStorage")
local InventoryEvents = require(ServerScriptService.Inventory.InventoryEvents)
local LeaderboardHandler = require(ServerScriptService.Leaderboards.LeaderboardHandler)
local Signals = require(ServerScriptService.ServerSignals.Signals)
local GUIRemotes = require(ServerScriptService.ServerRemotesLogic.GUIRemotes)
local OrderedDataStores = require(ServerScriptService.ServerData.OrderedDataStores)
local SoundToClient = require(ServerScriptService.ServerRemotesLogic.SoundToClient)
local BombConfig = require(ReplicatedStorage.Config.BombSharedConfig)
local RandomModule = require(ReplicatedStorage.RandomModule)
local VIPHandler = require(ReplicatedStorage.VIP.VIPHandler)
local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker).server
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local BombHandler = require(script.Parent.BombHandler)
local BombServerConfig = require(script.Parent.BombServerConfig)
local GameTableManager = require(script.Parent.GameTableManager)
local Remotes = ReplicatedStorage.Remotes
local GUINetwork = GUIRemotes.networker

local WIN_REWARD = 300
local AI_REWARD = 100
local LOSE_REWARD = 50
local ABRUPT_REWARD = 10

local GameModule = {}

function GameModule:DisablePlayerControlsOnTable(playersList, cameraPart: Part)
	print("disable controls called")
	for _, player in pairs(playersList) do
		if not player then
			continue
		end
		GUIRemotes.networker:fire(player, "UpdateGameActive", true)
		self.inputNetworker:fire(player, "DisableControls", true)
		self.inputNetworker:fire(player, "SetGameCamera", true, cameraPart)
	end
end

function GameModule:PlayAudioForTablePlayers(playersList, audioID: string, oneShot: boolean)
	for _, player in pairs(playersList) do
		if not player then
			warn("One player ref missing setting audio for players, ignore if AI mode")
			continue
		end
		if oneShot then
			SoundToClient:PlaySoundOnClient(player, audioID, nil, false, nil)
		else
			SoundToClient:PlaySoundOnClient(player, audioID, nil, true, nil)
		end
	end
end
local function SetInitialTurn(tableClass)
	local playerList = tableClass.PlayersAssigned
	-- AI
	if tableClass.AIConfig.AIMode then
		local playerID = tableClass.AIConfig.PlayerID
		print(tableClass.AIConfig.PlayerID)
		local random = RandomModule.GetRandomDecimalBetween(0, 1)
		if random >= 0.5 then
			tableClass.AIConfig.AITurn = true
			Signals.AITurn:Fire(tableClass)
		else
			GUINetwork:fire(playerList[playerID], "SyncTurn", true)
			GameModule.StartCountdown(tableClass, playerID)
		end
		return
	end

	-- normal 1v1

	if not tableClass.PlayersAssigned[1] or not tableClass.PlayersAssigned[2] then
		error("PlayersAssigned not populated correctly")
	end

	print(tableClass)
	local randomPlayerID = RandomModule.GetRandomNumberBetween(1, 2)
	tableClass.CurrentTurn = randomPlayerID

	print(`current {randomPlayerID} `)

	-- show bomb gui for this person as it's their turn
	GUINetwork:fire(playerList[randomPlayerID], "SyncTurn", true)

	-- start
	GameModule.StartCountdown(tableClass, randomPlayerID)
end

function GameModule.RespawnTable(tableClass)
	local oldTable = tableClass.TableRefs.Parent
	local oldTablePos = oldTable:GetPivot()
	oldTable:Destroy()

	local newTable = ServerStorage.Models.GameTable:Clone()

	newTable.Parent = workspace
	newTable:PivotTo(oldTablePos)
	print("Table respawned!")
end

local function HandleLoser(loser, isAI: boolean)
	if not loser then
		print("Loser player ref is nil!")
	end

	DataService:update(loser, { "currency" }, function(currentCash)
		return currentCash + VIPHandler.DoubleRewardsIfVIP(loser, LOSE_REWARD)
	end)

	local humanoid = loser.Character.Humanoid
	humanoid.Health = 0

	if not isAI then
		SoundToClient.networker:fire(loser, "PlayExistingSound", "UISounds", "Lose")
	else
		SoundToClient.networker:fire(loser, "PlayExistingSound", "UISounds", "AIWin")
	end
end

local function HandleWinner(winner: Player, abruptEnd: boolean?, isAI: boolean?)
	if not winner then
		print("Winner player ref is nil!")
	end

	-- update to store
	if not abruptEnd then
		if isAI then
			DataService:update(winner, { "currency" }, function(currentCash)
				return currentCash + VIPHandler.DoubleRewardsIfVIP(winner, AI_REWARD)
			end)
		else
			DataService:update(winner, { "currency" }, function(currentCash)
				return currentCash + VIPHandler.DoubleRewardsIfVIP(winner, WIN_REWARD)
			end)
		end
	else
		DataService:update(winner, { "currency" }, function(currentCash)
			return currentCash + VIPHandler.DoubleRewardsIfVIP(winner, ABRUPT_REWARD)
		end)
	end

	LeaderboardHandler.AddValueToDataStore(OrderedDataStores.WinStore, winner, 1)
	-- sound
	if not isAI then
		SoundToClient.networker:fire(winner, "PlayExistingSound", "UISounds", "Win")
	else
		SoundToClient.networker:fire(winner, "PlayExistingSound", "UISounds", "AILose")
	end

	print(`Winner: {winner.DisplayName}`)
end

-- if player leaves or somehow dies unnaturally we should call this instead of FinishGame
function GameModule:AbruptEnd(tableClass, winner: Player)
	tableClass.GameActive = false
	tableClass.BombActive = false
	if not winner then
		GameModule.RespawnTable(tableClass)
		return
	end
	GameModule:PlayAudioForTablePlayers(tableClass.PlayersAssigned, SoundManager.GetRandomMainSound(), false)
	self.inputNetworker:fire(winner, "DisableControls", false)
	self.inputNetworker:fire(winner, "SetGameCamera", false, nil)
	GUIRemotes.networker:fire(winner, "BombGUIDisconnect")

	HandleWinner(winner, true)
	GameModule.RespawnTable(tableClass)
end

function GameModule:FinishGame(tableClass)
	local loser: Player = nil
	local winner: Player = nil
	local playerList = tableClass.PlayersAssigned
	tableClass.GameActive = false
	GameModule:PlayAudioForTablePlayers(playerList, SoundManager.GetRandomMainSound(), false)
	for _, player in pairs(playerList) do
		if not player then
			continue
		end
		player.Character:SetAttribute("ID", nil)
		GUIRemotes.networker:fire(player, "UpdateGameActive", false)
		self.inputNetworker:fire(player, "DisableControls", false)
		self.inputNetworker:fire(player, "SetGameCamera", false, nil)
		GUIRemotes.networker:fire(player, "BombGUIDisconnect")
	end

	-- AI mode
	if tableClass.AIConfig.AIMode then
		local playerID = tableClass.AIConfig.PlayerID
		if tableClass.AIConfig.AITurn then
			HandleWinner(tableClass.PlayersAssigned[playerID], true)
		else
			HandleLoser(tableClass.PlayersAssigned[playerID], true)
		end
		GameModule.RespawnTable(tableClass)
		return
	end

	-- normal mode
	local currentTurnID = tableClass.CurrentTurn
	local currentTurnPlayer = playerList[currentTurnID]
	loser = currentTurnPlayer
	winner = playerList[3 - currentTurnID]

	HandleLoser(loser, false)
	HandleWinner(winner)
	GameModule.RespawnTable(tableClass)
end

function ExceededCountdown(tableClass, targetPlayer: Player)
	if not targetPlayer then
		error("Exceeded countdown but player ref is nil")
	end
	-- countdown finished
	local playerInputOnExceed = Remotes.GetBombInput:InvokeClient(targetPlayer)

	-- clamp for anti input exploitation
	playerInputOnExceed = math.clamp(playerInputOnExceed, 1, 600)
	local resultingTime = BombHandler.ReduceBombTime(tableClass, playerInputOnExceed)

	if resultingTime and resultingTime > 0 then
		GameModule.NextTurn(tableClass)
	end
end

local function CanStillCountdownBar(tableClass, targetPlayerID: number)
	local aiConfig = tableClass.AIConfig
	if not aiConfig or not aiConfig.AIMode then
		if tableClass.CurrentTurn ~= targetPlayerID then
			print("Stop counting down for this client, turn switched")
			return false
		end
	else
		if tableClass.AIConfig.AITurn then
			return false
		end
	end
	return true
end

-- moves the countdown bar when called
function GameModule.StartCountdown(tableClass, targetPlayerID: number)
	local targetPlayer = tableClass.PlayersAssigned[targetPlayerID]
	print("start countdown called")
	task.spawn(function()
		for timeLeft = BombConfig.MAX_TURN_TIME, 0, -1 do
			if not tableClass.GameActive then
				print("Game not active, don't count down any more")
				return
			end

			if not CanStillCountdownBar(tableClass, targetPlayerID) then
				return
			end

			GUINetwork:fire(targetPlayer, "UpdateCountdownBar", timeLeft)
			task.wait(1)
		end
		-- one more check (if they input at 0, it still assumes its your turn)
		if not CanStillCountdownBar(tableClass, targetPlayerID) then
			return
		end

		ExceededCountdown(tableClass, targetPlayer)
	end)
end

function GameModule.NextTurn(tableClass)
	if tableClass.BombTimeLeft <= 0 then
		warn("Not switching turn, bomb time is 0")
		return
	end

	local playerList = tableClass.PlayersAssigned

	tableClass.TurnCounter += 1
	tableClass:ReduceBombEffectTurns()

	-- AI Mode
	if tableClass.AIConfig.AIMode then
		local config = tableClass.AIConfig
		local playerID = tableClass.AIConfig.PlayerID
		local player = playerList[playerID]
		if config.AITurn then
			config.AITurn = false
			GUINetwork:fire(player, "SyncTurn", true)
			GameModule.StartCountdown(tableClass, playerID)
		else
			config.AITurn = true
			GUINetwork:fire(player, "SyncTurn", false)
			Signals.AITurn:Fire(tableClass)
		end
		return
	end

	-- normal mode
	local whosTurnCurrently = tableClass.CurrentTurn
	print(`current {whosTurnCurrently} `)
	local nextTurn = 3 - whosTurnCurrently
	print(`next turn {nextTurn}`)

	GUINetwork:fire(playerList[whosTurnCurrently], "SyncTurn", false)
	GUINetwork:fire(playerList[nextTurn], "SyncTurn", true)
	tableClass.CurrentTurn = nextTurn
	GameModule.StartCountdown(tableClass, nextTurn)
end

function GameModule:SubmitBombTime(_: Player?, tableID: string, timeToReduce: number)
	local tableClass = GameTableManager.GetTableFromID(tableID)
	if not tableClass then
		error("tableClass invalid when submitting bomb!")
	end
	if tableClass.BombTimeLeft <= 0 or not tableClass.BombActive then
		warn("Cannot reduce time, bomb time is 0")
		return
	end

	timeToReduce = BombHandler.DoubleTrouble(tableClass, timeToReduce)
	timeToReduce = math.clamp(timeToReduce, 0, BombServerConfig.MAX_BOMB_TIME)

	BombHandler.ReduceBombTime(tableClass, timeToReduce)

	GameModule.NextTurn(tableClass)
end

function GameModule.SetBombSkin(tableClass)
	-- AI
	if tableClass.AIConfig.AIMode then
		tableClass.AIConfig.PlayerID = (tableClass.PlayersAssigned[1] and 1) or (tableClass.PlayersAssigned[2] and 2)
		local player = tableClass.PlayersAssigned[tableClass.AIConfig.PlayerID]
		local objectEquipped = DataService:get(player, { "bombEquipped" })
		InventoryEvents.SetEquippedSkin("bombEquipped", "Bombs", objectEquipped, tableClass.TableRefs.Bomb)
		return
	end

	-- pick random bomb skin from plr1 or plr2
	-- normal
	local equippedBombs = {}
	for _, playerRef in ipairs(tableClass.PlayersAssigned) do
		if not playerRef then
			warn("One player ref missing setting bomb skin, ignore if AI mode")
			continue
		end
		local objectEquipped = DataService:get(playerRef, { "bombEquipped" })
		table.insert(equippedBombs, objectEquipped)
	end

	local chosenBombName = equippedBombs[RandomModule.GetRandomNumberBetween(1, #equippedBombs)]
	InventoryEvents.SetEquippedSkin("bombEquipped", "Bombs", chosenBombName, tableClass.TableRefs.Bomb)
end
function GameModule.SetRandomCardPerPlayer(tableClass)
	print(tableClass.PlayersAssigned)
	for _, playerRef in pairs(tableClass.PlayersAssigned) do
		if not playerRef then
			warn("One player ref missing setting card, ignore if AI mode")
			continue
		end

		Signals.SetCardForPlayer:Fire(playerRef)
	end

	-- set AI's card if AI mode
	if tableClass.AIConfig.AIMode then
		Signals.SetCardForAI:Fire(tableClass)
	end
end

function GameModule.BeginGame(tableClass)
	GameModule:DisablePlayerControlsOnTable(tableClass.PlayersAssigned, tableClass.TableRefs.CameraPos)
	GameModule.SetBombSkin(tableClass)
	GameModule.SetRandomCardPerPlayer(tableClass)
	tableClass.GameActive = true
	GameModule:PlayAudioForTablePlayers(tableClass.PlayersAssigned, SoundManager.GetRandomBombThemeSound(), false)

	BombHandler.InitializeBomb(tableClass)
	SetInitialTurn(tableClass)
end

GameModule.inputNetworker = Networker.new("InputRemotes", GameModule, { GameModule.SubmitBombTime })

return GameModule
