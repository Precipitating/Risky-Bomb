local ServerScriptService = game:GetService("ServerScriptService").Server
local GameModule = require(ServerScriptService.BombGame.GameModule)
local ServerSignals = require(ServerScriptService.ServerSignals.Signals)
local BombGameEvents = {}

function BombGameEvents.Handle()
	ServerSignals.GameFinished:Connect(function(tableClass)
		GameModule:FinishGame(tableClass)
	end)

	ServerSignals.BeginGame:Connect(function(tableClass)
		GameModule.BeginGame(tableClass)
	end)
end

return BombGameEvents
