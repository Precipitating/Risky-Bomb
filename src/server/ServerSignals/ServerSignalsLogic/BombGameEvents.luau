local ServerScriptService = game:GetService("ServerScriptService").Server
local GameModule = require(ServerScriptService.BombGame.GameModule)
local CardHandler = require(ServerScriptService.Cards.CardHandler)
local CardData = require(ServerScriptService.Cards.CardData)
local SinglePlayerAI = require(ServerScriptService.Singleplayer.SinglePlayerAI)
local SinglePlayerHandler = require(ServerScriptService.Singleplayer.SinglePlayerHandler)
local ServerSignals = require(ServerScriptService.ServerSignals.Signals)
local BombGameEvents = {}

-- mostly used due to cyclic dependencies
function BombGameEvents.Handle()
	ServerSignals.GameFinished:Connect(function(tableClass)
		GameModule:FinishGame(tableClass)
	end)

	ServerSignals.BeginGame:Connect(function(tableClass)
		GameModule.BeginGame(tableClass)
	end)
	ServerSignals.AbruptEnd:Connect(function(tableClass, winner)
		GameModule:AbruptEnd(tableClass, winner)
	end)

	ServerSignals.SinglePlayerNetworkFire:Connect(function(player: Player, methodName: string, ...)
		return SinglePlayerHandler.networker:fire(player, methodName, ...)
	end)

	ServerSignals.AITurn:Connect(function(tableClass)
		SinglePlayerAI.ThinkAndChoose(tableClass)
	end)

	ServerSignals.SetCardForPlayer:Connect(function(player: Player)
		CardHandler:SetRandomCardForPlayer(player)
	end)
	ServerSignals.SetCardForAI:Connect(function(tableClass)
		local cardChosen = CardData[CardData.GetRandomCardAI()]
		tableClass.AIConfig.AICard = cardChosen
	end)

	ServerSignals.AIModeFinish:Connect(function(tableClass)
		SinglePlayerAI.AIGameFinish(tableClass)
	end)

	ServerSignals.AIModeNextTurn:Connect(function(playerList, tableClass)
		SinglePlayerAI.AIModeNextTurn(playerList, tableClass)
	end)
	ServerSignals.AISetInitialTurn:Connect(function(playerList, tableClass)
		SinglePlayerAI.AISetInitialTurn(playerList, tableClass)
	end)
end

return BombGameEvents
