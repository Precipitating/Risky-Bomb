local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerStorage = game:GetService("ServerStorage")
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local UtilityModule = require(ReplicatedStorage.Utility.UtilityModule)
local LeaderboardTemplate = ServerStorage.Templates.LeaderboardElement
local LeaderboardHandler = {}
LeaderboardHandler.janitor = Janitor.new()

function LeaderboardHandler:PopulateLeaderboard(leaderboardKey: string, ascending: boolean, playersPerPage: number)
	local leaderboardFolder = workspace:FindFirstChild("Leaderboards")
	local leaderboard = DataStoreService:GetOrderedDataStore(leaderboardKey)
	local leaderboardObject = UtilityModule.Get(leaderboardFolder, leaderboardKey)
	local placeToInsert = UtilityModule.Get(leaderboardObject, "SurfaceGui", "BGFrame")

	task.spawn(function()
		while true do
			task.wait(60)
			self.janitor:Cleanup()
			local success, pages = pcall(function()
				return leaderboard:GetSortedAsync(ascending, playersPerPage)
			end)
			print(pages:GetCurrentPage())
			if success then
				local entries = pages:GetCurrentPage()

				for rank, entry in pairs(entries) do
					local leaderboardElement = LeaderboardTemplate:Clone()
					local playerName = Players:GetNameFromUserIdAsync(tonumber(entry.key))
					local playerValue = entry.value

					local nameLabel = leaderboardElement:FindFirstChild("Name", true)
					local rankLabel = leaderboardElement:FindFirstChild("Rank", true)
					local valueLabel = leaderboardElement:FindFirstChild("Value", true)

					rankLabel.Text = rank
					nameLabel.Text = playerName
					valueLabel.Text = tostring(playerValue)
					leaderboardElement.Parent = placeToInsert

					self.janitor:Add(leaderboardElement)
				end
			end
		end
	end)
end

function LeaderboardHandler:Initialize()
	-- leaderboardKey must match the leaderboard mesh part name
	self:PopulateLeaderboard("DonationBoard", false, 5)
end

return LeaderboardHandler
