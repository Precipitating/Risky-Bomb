local ServerScriptService = game:GetService("ServerScriptService")
local ChairRemote = require(ServerScriptService.Server.ServerRemotesLogic.ChairRemote)
local DevProductRemotes = require(ServerScriptService.Server.ServerRemotesLogic.DevProductRemotes)
local GameRemotes = require(ServerScriptService.Server.ServerRemotesLogic.GameRemotes)
local ServerRemotesHandler = {}

function ServerRemotesHandler.HandleRemotes()
	ChairRemote:Initialize()
	GameRemotes.Handle()
	DevProductRemotes:Initialize()
end

return ServerRemotesHandler
