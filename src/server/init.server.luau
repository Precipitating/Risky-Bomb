require(script.BombGame.GameModule)
require(script.HandlePurchases.PurchaseHandler)
require(script.HandlePurchases.InGamePurchases)
require(script.Inventory.InventoryEvents)
local GameTableManager = require(script.BombGame.GameTableManager)
local GlobalAnnouncer = require(script.MessageService.GlobalAnnouncer)
local ServerDataHandler = require(script.ServerData.ServerDataHandler)
local ServerPlayerEvents = require(script.ServerPlayerEvents)
local ServerSignalsInitializer = require(script.ServerSignalsInitializer)

local function ServerInit()
	ServerDataHandler.Initialize()
	ServerPlayerEvents.Handle()
	ServerSignalsInitializer.HandleEvents()
	GameTableManager:Initialize()

	GlobalAnnouncer.Initialize()
end

ServerInit()
