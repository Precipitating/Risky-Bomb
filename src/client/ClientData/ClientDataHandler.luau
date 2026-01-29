local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local BombGameCharms = require(ReplicatedStorage.Charms.BombGameCharms)
local UICharms = require(ReplicatedStorage.Charms.UICharms)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local DataService = require(ReplicatedStorage.Packages.DataService).client

local ClientDataHandler = {}

local function SyncData()
	local fetchedCurrency = DataService:fetch({ "currency" })
	local canAwardDaily = DataService:fetch({ "canAwardDaily" })
	BombGameCharms.CurrentCashValue(fetchedCurrency)
	UICharms.CanAwardDaily(canAwardDaily)

	DataService:getChangedSignal({ "currency" }):Connect(function(newValue)
		print("cash updated on client!")
		SoundManager.PlayExistingSound(SoundManager.UISounds.Cash)
		BombGameCharms.CurrentCashValue(newValue)
	end)
end

function ClientDataHandler.Initialize()
	DataService:init()
	DataService:waitForData()
	SyncData()
end

return ClientDataHandler
