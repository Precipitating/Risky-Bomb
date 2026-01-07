local ServerScriptService = game:GetService("ServerScriptService").Server
local GameModule = require(ServerScriptService.BombGame.GameModule)
local BindableEvents = ServerScriptService.BindableEvents
local BombGameEvents = {}

function BombGameEvents.Handle()
	BindableEvents.GameFinished.Event:Connect(function(gameTable: Model)
		local id = gameTable:GetAttribute("ID")
		GameModule.FinishGame(id)
	end)
end

return BombGameEvents
