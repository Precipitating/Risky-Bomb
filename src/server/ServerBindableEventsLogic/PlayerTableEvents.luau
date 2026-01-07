local ServerScriptService = game:GetService("ServerScriptService").Server
local GameModule = require(ServerScriptService.BombGame.GameModule)
local BindableEvents = ServerScriptService.BindableEvents
local PlayerTableEvents = {}

local function OnListIncreased()
	BindableEvents.PlayerAddedToTable.Event:Connect(function(tableID, playerRef) end)
end

local function OnListDecreased()
	BindableEvents.PlayerRemovedFromTable.Event:Connect(function(tableID, _)
		print("List decreased!")
	end)
end
function PlayerTableEvents.Handle()
	OnListIncreased()
	OnListDecreased()
end

return PlayerTableEvents
