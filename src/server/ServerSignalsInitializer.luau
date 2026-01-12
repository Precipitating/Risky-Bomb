local ServerScriptService = game:GetService("ServerScriptService").Server
local BombGameEvents = require(ServerScriptService.ServerSignals.ServerSignalsLogic.BombGameEvents)
local PlayerTableEvents = require(ServerScriptService.ServerSignals.ServerSignalsLogic.PlayerTableEvents)
local ServerSignalsInitializer = {}

function ServerSignalsInitializer.HandleEvents()
	PlayerTableEvents.Handle()
	BombGameEvents.Handle()
end

return ServerSignalsInitializer
