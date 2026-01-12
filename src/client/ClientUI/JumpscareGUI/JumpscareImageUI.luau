local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local JumpscareUIFunctions = require(script.Parent.JumpscareUIFunctions)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local BombGameCharms = require(ReplicatedStorage.Charms.BombGameCharms)
local e = React.createElement

local function isJumpscareActive()
	return ReactCharm.useAtom(BombGameCharms.JumpscareActivated)
end

local function JumpscareImage()
	return ReactCharm.useAtom(BombGameCharms.JumpscareImage)
end

local function JumpscareImageUI()
	local jumpscareImage = JumpscareImage()
	local jumpscareActive = isJumpscareActive()
	return e("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		Active = false,
		Visible = jumpscareActive,
		Image = jumpscareImage,
		ZIndex = 2,
	})
end

return JumpscareImageUI
