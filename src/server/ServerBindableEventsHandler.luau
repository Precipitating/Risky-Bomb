local ServerScriptService = game:GetService("ServerScriptService").Server
local BombGameEvents = require(ServerScriptService.ServerBindableEventsLogic.BombGameEvents)
local PlayerTableEvents = require(ServerScriptService.ServerBindableEventsLogic.PlayerTableEvents)
local ServerBindableEventsHandler = {}

function ServerBindableEventsHandler.HandleEvents()
	PlayerTableEvents.Handle()
	BombGameEvents.Handle()
end

return ServerBindableEventsHandler
