local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService").Server
local DataService = require(ReplicatedStorage.Packages.DataService).server
local VIPHandler = require(ReplicatedStorage.VIP.VIPHandler)
local LeaderboardHandler = require(ServerScriptService.Leaderboards.LeaderboardHandler)
local PlayerEvents = {}

function PlayerEvents.Handle()
	game.Players.PlayerAdded:Connect(function(player)
		LeaderboardHandler:Initialize()
		DataService:waitForData(player)

		-- check if player bought gamepass on the website and award
		if VIPHandler.OwnsVIPGamePass(player) then
			VIPHandler.AwardVIPRewards(player)
		end

		player.CharacterAdded:Connect(function(character)
			local ownsVIP = VIPHandler.IsVIP(player)
			if ownsVIP then
				VIPHandler.SetVIPGUI(player)
			end

			character.Humanoid.Died:Connect(function()
				-- if died on table, unassign
				-- local tableID = character:GetAttribute("AssignedTable")
				-- if tableID then
				--print("Unassigned dead player from")
				--GameTableManager.UnassignPlayerFromTable(tableID)
				--BombGameStorage.UnAssignSinglePlayerFromTable(tableID, player)
				--end
			end)
		end)
	end)
end

return PlayerEvents
