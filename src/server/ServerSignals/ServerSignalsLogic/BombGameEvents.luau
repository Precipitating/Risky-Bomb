local ServerScriptService = game:GetService("ServerScriptService").Server
local GameModule = require(ServerScriptService.BombGame.GameModule)
local SinglePlayerAI = require(ServerScriptService.Singleplayer.SinglePlayerAI)
local SinglePlayerHandler = require(ServerScriptService.Singleplayer.SinglePlayerHandler)
local ServerSignals = require(ServerScriptService.ServerSignals.Signals)
local BombGameEvents = {}

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

	ServerSignals.AITurn:Connect(function(tableClass, difficultyConfig)
		SinglePlayerAI.ThinkAndChoose(tableClass, difficultyConfig)
	end)
end

return BombGameEvents
