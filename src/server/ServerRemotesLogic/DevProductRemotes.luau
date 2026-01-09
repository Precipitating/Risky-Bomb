local ServerScriptService = game:GetService("ServerScriptService").Server
local PurchaseHandler = require(ServerScriptService.HandlePurchases.PurchaseHandler)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local DevProductRemotes = {}

local function JumpscareRemotes()
	Remotes.PendingJumpscarePlayer.OnServerEvent:Connect(function(player, targetID)
		PurchaseHandler.AddPendingJumpscare(player, targetID)
	end)
end
function DevProductRemotes.Handle()
	JumpscareRemotes()
end

return DevProductRemotes
