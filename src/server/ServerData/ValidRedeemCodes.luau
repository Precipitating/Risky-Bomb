local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local DataService = require(ReplicatedStorage.Packages.DataService).server

return {
	WILSON = function(player: Player)
		DataService:update(player, { "currency" }, function(currCash)
			return currCash + 1000
		end)
	end,
}
