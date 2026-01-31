local ServerScriptService = game:GetService("ServerScriptService").Server
local BombGameEvents = require(ServerScriptService.ServerSignals.ServerSignalsLogic.BombGameEvents)
local ServerSignalsInitializer = {}

function ServerSignalsInitializer.HandleEvents()
	BombGameEvents.Handle()
end

return ServerSignalsInitializer
