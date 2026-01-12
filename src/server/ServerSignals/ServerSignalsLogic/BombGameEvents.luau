local ServerScriptService = game:GetService("ServerScriptService").Server
local GameModule = require(ServerScriptService.BombGame.GameModule)
local ServerSignals = require(ServerScriptService.ServerSignals.Signals)
local BombGameEvents = {}

function BombGameEvents.Handle()
	ServerSignals.GameFinished:Connect(function(gameTable: Model)
		local id = gameTable:GetAttribute("ID")
		GameModule:FinishGame(id)
	end)
end

return BombGameEvents
