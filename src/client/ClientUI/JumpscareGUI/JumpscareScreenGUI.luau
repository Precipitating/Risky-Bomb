local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local JumpscareListUI = require(script.Parent.JumpscareListUI)
local JumpscareButtonUI = require(script.Parent.JumpscareButtonUI)
local JumpscareImageUI = require(script.Parent.JumpscareImageUI)
local React = require(ReplicatedStorage.Packages.React)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local e = React.createElement

local JumpscareUITheme = {
	BackgroundColor = Color3.fromRGB(255, 1, 1),
	StrokeColor = Color3.fromRGB(121, 0, 2),
}

local function JumpscareScreenGUI()
	local isJumpscareOpen, setisJumpscareOpen = React.useState(false)
	return e(React.Fragment, nil, {
		JumpscareButton = e(JumpscareButtonUI, {
			BackgroundColor = JumpscareUITheme.BackgroundColor,
			Font = Enum.Font.SpecialElite,
			Text = "JUMPSCARE PLAYER",
			StrokeColor = JumpscareUITheme.StrokeColor,
			OnToggle = function()
				SoundManager.PlayExistingSound(SoundManager.UISounds.ButtonClick)
				setisJumpscareOpen(not isJumpscareOpen)
			end,
		}),

		JumpscareList = e(JumpscareListUI, {
			BackgroundColor = JumpscareUITheme.BackgroundColor,
			StrokeColor = JumpscareUITheme.StrokeColor,
			IsVisible = isJumpscareOpen,
		}),

		JumpscareImage = e(JumpscareImageUI),
	})
end

return JumpscareScreenGUI
