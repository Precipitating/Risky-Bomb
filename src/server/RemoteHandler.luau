local ServerScriptService = game:GetService("ServerScriptService")
local ChairRemote = require(ServerScriptService.Server.RemotesLogic.ChairRemote)
local RemoteHandler = {}

local function Handle(target)
	target:Handle()
end

function RemoteHandler.HandleRemotes()
	Handle(ChairRemote)
end

return RemoteHandler
