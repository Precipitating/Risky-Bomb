local ServerScriptService = game:GetService("ServerScriptService")
local GameModule = require(ServerScriptService.Server.BombGame.GameModule)
local PlayerEvents = {}

function PlayerEvents.Handle()
	game.Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			character.Humanoid.Died:Connect(function()
				-- if died on table, unassign
				local tableID = character:GetAttribute("AssignedTable")
				if tableID then
					print("Unassign!")
					GameModule.UnAssignPlayerToTable(tableID, player)
				end
			end)
		end)
	end)
end

return PlayerEvents
