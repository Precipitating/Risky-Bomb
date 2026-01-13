local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Networker = require(ReplicatedStorage.Packages.Networker).server
local JumpscareHandler = { PendingJumpscares = {} }

function JumpscareHandler:AddPendingJumpscare(player: Player, targetUserID: string)
	self.PendingJumpscares[player.UserId] = {}
	self.PendingJumpscares[player.UserId].Target = targetUserID
end

function JumpscareHandler:Initialize() end

function JumpscareHandler:RemovePendingJumpscare(player: Player)
	self.PendingJumpscares[player.UserId].Target = nil
end

function JumpscareHandler:JumpscarePurchased(player: Player)
	print(`{player} bought jumpscare!`)
	local targetPlayer = Players:GetPlayerByUserId(self.PendingJumpscares[player.UserId].Target)
	self.networker:fire(targetPlayer, "ActivateJumpscare")
	self.PendingJumpscares[player.UserId].Target = nil

	return true
end

JumpscareHandler.networker = Networker.new("JumpscareRemotes", JumpscareHandler, {
	JumpscareHandler.AddPendingJumpscare,
})

return JumpscareHandler
