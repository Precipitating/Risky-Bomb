local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService").Server
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerStorage = game:GetService("ServerStorage")
local GlobalAnnouncer = require(ServerScriptService.MessageService.GlobalAnnouncer)
local SoundToClient = require(ServerScriptService.ServerRemotesLogic.SoundToClient)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local UtilityModule = require(ReplicatedStorage.Utility.UtilityModule)
local LeaderboardTemplate = ServerStorage.Templates.LeaderboardElement
local LeaderboardHandler = {}
LeaderboardHandler.janitor = Janitor.new()

function LeaderboardHandler.AddValueToDataStore(store: OrderedDataStore, player: Player, value: number)
	local success, result = pcall(function()
		store:UpdateAsync(tostring(player.UserId), function(oldValue)
			oldValue = oldValue or 0
			return oldValue + value
		end)
	end)

	if not success then
		warn(result)
	end

	-- donation board special sound on buy + shows msg globally on banner
	if store.Name == "DonationBoard" then
		SoundToClient:PlaySoundOnClient(player, SoundManager.UISounds.Thanks, nil, false, nil)
		GlobalAnnouncer.FireGlobalMessage(`{player.Name} donated {tostring(value)} ROBUX! `)
	end

	return success
end

function LeaderboardHandler:PopulateLeaderboard(leaderboardKey: string, ascending: boolean, playersPerPage: number)
	local leaderboardFolder = workspace:FindFirstChild("Leaderboards")
	local leaderboard = DataStoreService:GetOrderedDataStore(leaderboardKey)
	local leaderboardObject = UtilityModule.Get(leaderboardFolder, leaderboardKey)
	local placeToInsert = UtilityModule.Get(leaderboardObject, "SurfaceGui", "BGFrame")

	task.spawn(function()
		while true do
			self.janitor:Cleanup()
			local success, pages = pcall(function()
				return leaderboard:GetSortedAsync(ascending, playersPerPage)
			end)
			if success then
				local entries = pages:GetCurrentPage()
				for rank, entry in pairs(entries) do
					--leaderboard:RemoveAsync(entry.key)
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
			task.wait(60)
		end
	end)
end

function LeaderboardHandler:Initialize()
	-- leaderboardKey must match the leaderboard mesh part name

	self:PopulateLeaderboard("DonationBoard", false, 10)
	self:PopulateLeaderboard("WinsBoard", false, 10)
	self:PopulateLeaderboard("IngameMoneyBoard", false, 10)
end

return LeaderboardHandler
