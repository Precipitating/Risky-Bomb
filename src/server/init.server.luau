local ServerPlayerEvents = require(script.ServerPlayerEvents)
local ServerBindableEventsHandler = require(script.ServerBindableEventsHandler)
local ServerRemotesHandler = require(script.ServerRemotesHandler)
local UniqueIdAssigner = require(script.UniqueIdAssigner)

local function ServerInit()
	ServerPlayerEvents.Handle()
	ServerRemotesHandler.HandleRemotes()
	ServerBindableEventsHandler.HandleEvents()
	UniqueIdAssigner.AssignAll()
end

ServerInit()
