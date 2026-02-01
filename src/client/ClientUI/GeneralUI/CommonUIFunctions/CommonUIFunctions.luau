local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local StarterPlayer = game:GetService("StarterPlayer")
local SoundManager = require(ReplicatedStorage.Shared.Sound.SoundManager)
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local CommonUIFunctions = {}

-- used to dynamically calculate how far/close object should be, so the viewport object is in frame.
-- this is used to prevent manual position offsetting
function CommonUIFunctions.CameraLookAtObject(camera: Camera, object: MeshPart)
	local size = object.Size
	local maxDimension = math.max(size.X, size.Y, size.Z)
	camera.CFrame = CFrame.new(0, 0, maxDimension * 1.3)
end

function CommonUIFunctions.InviteFriends()
	local success, canSend = pcall(function()
		return SocialService:CanSendCallInviteAsync(PlayerContext.Player)
	end)

	if success then
		SocialService:PromptGameInvite(PlayerContext.Player)
	else
		SoundManager.PlayExistingSound(SoundManager.UISounds.Error)
	end
end

return CommonUIFunctions
