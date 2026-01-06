local OnPlayerSpawned = require(script.PlayerEvents)
local ServerBindableEventsHandler = require(script.ServerBindableEventsHandler)
local ServerRemotesHandler = require(script.ServerRemotesHandler)
local UniqueIdAssigner = require(script.UniqueIdAssigner)

local function ServerInit()
	OnPlayerSpawned.Handle()
	ServerRemotesHandler.HandleRemotes()
	ServerBindableEventsHandler.HandleEvents()
	UniqueIdAssigner.AssignAll()
end

ServerInit()
