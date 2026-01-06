local ServerScriptService = game:GetService("ServerScriptService").Server
local PlayerTableEvents = require(ServerScriptService.ServerBindableEventsLogic.PlayerTableEvents)
local ServerBindableEventsHandler = {}

function ServerBindableEventsHandler.HandleEvents()
	PlayerTableEvents.Handle()
end

return ServerBindableEventsHandler
