local ServerScriptService = game:GetService("ServerScriptService")
local JumpscareHandler = require(ServerScriptService.Server.HandlePurchases.JumpscareHandler)
local DevProductRemotes = {}

function DevProductRemotes:Initialize()
	JumpscareHandler:Initialize()
end

return DevProductRemotes
