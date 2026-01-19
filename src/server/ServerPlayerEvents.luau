local ServerScriptService = game:GetService("ServerScriptService").Server
local BombGameStorage = require(ServerScriptService.BombGame.BombGameStorage)
local LeaderboardHandler = require(ServerScriptService.Leaderboards.LeaderboardHandler)
local PlayerEvents = {}

function PlayerEvents.Handle()
	game.Players.PlayerAdded:Connect(function(player)
		LeaderboardHandler:Initialize()
		player.CharacterAdded:Connect(function(character)
			character.Humanoid.Died:Connect(function()
				-- if died on table, unassign
				local tableID = character:GetAttribute("AssignedTable")
				if tableID then
					print("Unassigned dead player from")
					BombGameStorage.UnAssignSinglePlayerFromTable(tableID, player)
				end
			end)
		end)
	end)
end

return PlayerEvents
