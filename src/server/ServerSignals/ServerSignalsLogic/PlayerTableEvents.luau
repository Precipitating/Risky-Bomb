local ServerScriptService = game:GetService("ServerScriptService").Server
local ServerSignals = require(ServerScriptService.ServerSignals.Signals)
local PlayerTableEvents = {}

local function OnListIncreased()
	ServerSignals.PlayerAddedToTable:Connect(function(tableID, playerRef) end)
end

local function OnListDecreased()
	ServerSignals.PlayerRemovedFromTable:Connect(function(tableID, _)
		print("List decreased!")
	end)
end
function PlayerTableEvents.Handle()
	OnListIncreased()
	OnListDecreased()
end

return PlayerTableEvents
