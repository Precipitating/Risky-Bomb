require(script.BombGame.GameModule)
require(script.HandlePurchases.PurchaseHandler)
require(script.ServerRemotesLogic.ChairRemote)
require(script.HandlePurchases.InGamePurchases)
require(script.Inventory.InventoryEvents)
local ServerDataHandler = require(script.ServerData.ServerDataHandler)
local ServerPlayerEvents = require(script.ServerPlayerEvents)
local ServerSignalsInitializer = require(script.ServerSignalsInitializer)

local UniqueIdAssigner = require(script.UniqueIdAssigner)

local function ServerInit()
	ServerDataHandler.Initialize()
	ServerPlayerEvents.Handle()
	ServerSignalsInitializer.HandleEvents()
	UniqueIdAssigner.AssignAll()
end

ServerInit()
