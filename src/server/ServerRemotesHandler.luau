local ServerScriptService = game:GetService("ServerScriptService")
local ChairRemote = require(ServerScriptService.Server.ServerRemotesLogic.ChairRemote)
local GameRemotes = require(ServerScriptService.Server.ServerRemotesLogic.GameRemotes)
local ServerRemotesHandler = {}

function ServerRemotesHandler.HandleRemotes()
	ChairRemote.Handle()
	GameRemotes.Handle()
end

return ServerRemotesHandler
