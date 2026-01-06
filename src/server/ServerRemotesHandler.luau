local ServerScriptService = game:GetService("ServerScriptService")
local ChairRemote = require(ServerScriptService.Server.ServerRemotesLogic.ChairRemote)
local ServerRemotesHandler = {}

function ServerRemotesHandler.HandleRemotes()
	ChairRemote.Handle()
end

return ServerRemotesHandler
