local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataService = require(ReplicatedStorage.Shared.Packages.DataService).client
local DailyRewardUIFunctions = {}

function DailyRewardUIFunctions.GetConsecutiveDays()
	return DataService:get({ "consecutiveDay" })
end
return DailyRewardUIFunctions
