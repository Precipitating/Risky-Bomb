local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Rarity = require(ReplicatedStorage.Config.Rarity)
local DailyRewardsData = require(ReplicatedStorage.Config.DailyRewardsData)
local DataTemplate = require(script.Parent.DataTemplate)
local OrderedDataStores = require(script.Parent.OrderedDataStores)
local DataService = require(ReplicatedStorage.Packages.DataService).server
local ServerDataHandler = {}

local Options = {
	template = DataTemplate,
	profileStoreIndex = "Testing",
	useMock = true,
	resetData = true,
}

local function SetAwardDailyIf24Hours(data, firstJoin: boolean)
	local currentTime = os.time()
	local secDiff = currentTime - data.sessionJoinTime

	data.canAwardDaily = (firstJoin and true) or false

	if secDiff >= DailyRewardsData.OneDayInSeconds then
		if secDiff >= DailyRewardsData.OneDayInSeconds * 2 then
			data.consecutiveDay = 1
		else
			data.consecutiveDay += 1
		end

		data.canAwardDaily = true
	end

	if data.canAwardDaily then
		ServerDataHandler:AwardDaily(data)
	end
end

function ServerDataHandler:AwardDaily(data)
	local consecutiveDay = data.consecutiveDay
	data.currency += consecutiveDay * DailyRewardsData.AwardPerDay
	data.sessionJoinTime = os.time()
end

function DataService:onPlayerInit(player: Player, data): ()
	print(player.Name .. " has initialized with data:", data)
	local firstJoin = data.firstJoin

	if firstJoin == true then
		data.firstJoin = false
		data.currency = 999999999
		data.chairEquipped = { Name = "Default", Material = "SmoothPlastic", Color = "White" }
		data.bombEquipped = { Name = "Default", Material = "SmoothPlastic", Color = "White" }
		data.chairsOwned = {
			[1] = {
				Name = "Default",
				RarityChance = Rarity.Common,
				Material = "SmoothPlastic",
				Color = "White",
			},
		}
		data.bombsOwned = {
			[1] = {
				Name = "Default",
				RarityChance = Rarity.Common,
				Material = "SmoothPlastic",
				Color = "White",
			},
		}

		data.sessionJoinTime = os.time()
		data.consecutiveDay = 1
		data.canAwardDaily = false
	end

	-- update cash store to update leaderboard
	DataService:getChangedSignal(player, { "currency" }):Connect(function(newValue)
		print("cash updated on server!")
		OrderedDataStores.InGameMoneyBoard:SetAsync(player.UserId, newValue)
	end)

	SetAwardDailyIf24Hours(data, firstJoin)
end

function ServerDataHandler.Initialize()
	DataService:init(Options)
end
return ServerDataHandler
