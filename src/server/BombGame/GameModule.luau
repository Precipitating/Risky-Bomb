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
local Networker = require(ReplicatedStorage.Packages.Networker).server
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local BombHandler = require(script.Parent.BombHandler)
local BombServerConfig = require(script.Parent.BombServerConfig)
local GameTableManager = require(script.Parent.GameTableManager)
local Remotes = ReplicatedStorage.Remotes
local GUINetwork = GUIRemotes.networker

local WIN_REWARD = 100
local LOSE_REWARD = 50

local GameModule = {}

function GameModule:DisablePlayerControlsOnTable(playersList, cameraPart: Part)
	print("disable controls called")
	for _, player in pairs(playersList) do
		print(player)
		print(cameraPart)
		self.inputNetworker:fire(player, "DisableControls", true)
		self.inputNetworker:fire(player, "SetGameCamera", true, cameraPart)
	end
end

function GameModule:PlayAudioForTablePlayers(playersList, audioID: string, oneShot: boolean)
	for _, player in pairs(playersList) do
		if oneShot then
			SoundToClient:PlaySoundOnClient(player, audioID, nil, false, nil)
		else
			SoundToClient:PlaySoundOnClient(player, audioID, nil, true, nil)
		end
	end
end
local function SetInitialTurn(tableClass)
	if not tableClass.PlayersAssigned[1] or not tableClass.PlayersAssigned[2] then
		error("PlayersAssigned not populated correctly")
	end

	local playerList = tableClass.PlayersAssigned
	print(tableClass)
	local randomPlayerID = math.random(1, 2)
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

function GameModule:FinishGame(tableClass)
	local loser: Player = nil
	local winner: Player = nil
	local playerList = tableClass.PlayersAssigned
	tableClass.GameActive = false
	GameModule:PlayAudioForTablePlayers(playerList, SoundManager.GetRandomMainSound(), false)
	for _, player in pairs(playerList) do
		self.inputNetworker:fire(player, "DisableControls", false)
		self.inputNetworker:fire(player, "SetGameCamera", false, nil)
		GUIRemotes.networker:fire(player, "BombGUIDisconnect")
	end

	local currentTurnID = tableClass.CurrentTurn
	local currentTurnPlayer = playerList[currentTurnID]
	loser = currentTurnPlayer
	winner = playerList[3 - currentTurnID]

	HandleLoser(loser)
	HandleWinner(winner)
	GameModule.RespawnTable(tableClass)
end

function ExceededCountdown(tableClass, targetPlayer: Player)
	-- countdown finished
	local playerInputOnExceed = Remotes.GetBombInput:InvokeClient(targetPlayer)

	-- clamp for anti input exploitation
	playerInputOnExceed = math.clamp(playerInputOnExceed, 1, 600)
	local resultingTime = BombHandler.ReduceBombTime(tableClass, playerInputOnExceed)

	if resultingTime and resultingTime > 0 then
		GameModule.NextTurn(tableClass)
	end
end

-- moves the countdown bar when called
function GameModule.StartCountdown(tableClass, targetPlayerID: number)
	local targetPlayer = tableClass.PlayersAssigned[targetPlayerID]
	print(targetPlayer)
	print("start countdown called")
	task.spawn(function()
		for timeLeft = BombConfig.MAX_TURN_TIME, 0, -1 do
			if not tableClass.GameActive then
				print("Game not active, don't count down any more")
				return
			end

			if tableClass.CurrentTurn ~= targetPlayerID then
				warn("id doesn't match, not countin down")
				return
			end

			GUINetwork:fire(targetPlayer, "UpdateCountdownBar", timeLeft)
			task.wait(1)
		end

		-- one more check (if they input at 0, it still assumes its your turn)
		if tableClass.CurrentTurn ~= targetPlayerID then
			return
		end
		ExceededCountdown(tableClass, targetPlayer)
	end)
end
function GameModule.NextTurn(tableClass)
	local playerList = tableClass.PlayersAssigned
	local whosTurnCurrently = tableClass.CurrentTurn
	print(`current {whosTurnCurrently} `)
	local nextTurn = 3 - whosTurnCurrently
	print(`next turn {nextTurn}`)

	GUINetwork:fire(playerList[whosTurnCurrently], "SyncTurn", false)
	GUINetwork:fire(playerList[nextTurn], "SyncTurn", true)
	tableClass.CurrentTurn = nextTurn
	GameModule.StartCountdown(tableClass, nextTurn)
end

function GameModule:SubmitBombTime(_: Player, tableID: string, timeToReduce: number)
	local tableRef = GameTableManager.GetTableFromID(tableID)
	timeToReduce = math.clamp(timeToReduce, 1, BombServerConfig.MAX_BOMB_TIME)
	local newTime = BombHandler.ReduceBombTime(tableRef, timeToReduce)

	if newTime > 0 then
		GameModule.NextTurn(tableRef)
	end
end

function GameModule.SetBombSkin(tableClass)
	-- pick random bomb skin

	local equippedBombs = {}
	for _, playerRef in ipairs(tableClass.PlayersAssigned) do
		local objectEquipped = DataService:get(playerRef, { "bombEquipped" })
		table.insert(equippedBombs, objectEquipped)
	end

	local chosenBombName = equippedBombs[math.random(#equippedBombs)]
	InventoryEvents.SetEquippedSkin("bombEquipped", "Bombs", chosenBombName, tableClass.TableRefs.Bomb)
end

function GameModule.BeginGame(tableClass)
	print(tableClass)
	GameModule.SetBombSkin(tableClass)
	tableClass.GameActive = true

	GameModule:PlayAudioForTablePlayers(tableClass.PlayersAssigned, SoundManager.GetRandomBombThemeSound(), false)
	GameModule:DisablePlayerControlsOnTable(tableClass.PlayersAssigned, tableClass.TableRefs.CameraPos)
	BombHandler.InitializeBomb(tableClass)
	SetInitialTurn(tableClass)
end

GameModule.inputNetworker = Networker.new("InputRemotes", GameModule, { GameModule.SubmitBombTime })

return GameModule
