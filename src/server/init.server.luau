local GameModule = require(script.BombGame.GameModule)
local PurchaseHandler = require(script.HandlePurchases.PurchaseHandler)
local ServerPlayerEvents = require(script.ServerPlayerEvents)
local ServerSignalsInitializer = require(script.ServerSignalsInitializer)
local ServerRemotesHandler = require(script.ServerRemotesHandler)
local UniqueIdAssigner = require(script.UniqueIdAssigner)

local function ServerInit()
	ServerPlayerEvents.Handle()
	ServerRemotesHandler.HandleRemotes()
	ServerSignalsInitializer.HandleEvents()
	UniqueIdAssigner.AssignAll()
	PurchaseHandler.Initialize()
	GameModule:Initialize()
end

ServerInit()
