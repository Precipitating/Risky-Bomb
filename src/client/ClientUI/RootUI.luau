local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local JumpscareListUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.Jumpscare.JumpscareListUI)
local JumpscareButtonUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.Jumpscare.JumpscareButtonUI)
local JumpscareScreenUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.Jumpscare.JumpscareScreenUI)
local React = require(ReplicatedStorage.Packages.react)
local e = React.createElement

local JumpscareUITheme = {
	BackgroundColor = Color3.fromRGB(255, 1, 1),
	StrokeColor = Color3.fromRGB(121, 0, 2),
}

local function RootUI()
	local isJumpscareOpen, setisJumpscareOpen = React.useState(false)
	return e(React.Fragment, nil, {
		JumpscareButton = e(JumpscareButtonUI, {
			BackgroundColor = JumpscareUITheme.BackgroundColor,
			Font = Enum.Font.SpecialElite,
			Text = "JUMPSCARE PLAYER",
			StrokeColor = JumpscareUITheme.StrokeColor,
			OnToggle = function()
				setisJumpscareOpen(not isJumpscareOpen)
			end,
		}),

		JumpscareList = e(JumpscareListUI, {
			BackgroundColor = JumpscareUITheme.BackgroundColor,
			StrokeColor = JumpscareUITheme.StrokeColor,
			IsVisible = isJumpscareOpen,
		}),

		JumpscareImage = e(JumpscareScreenUI),
	})
end

return RootUI
