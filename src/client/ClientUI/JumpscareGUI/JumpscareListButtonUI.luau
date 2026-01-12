local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local StarterPlayer = game:GetService("StarterPlayer")
local JumpscareUIFunctions = require(script.Parent.JumpscareUIFunctions)
local React = require(ReplicatedStorage.Packages.React)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local e = React.createElement

type JumpscareListButtonProp = {
	Text: string,
	UserID: string,
}

local function JumpscareListButtonUI(props: JumpscareListButtonProp)
	return e("TextButton", {
		Position = UDim2.fromScale(0.985, 0.03),
		Size = UDim2.fromScale(0.95, 0.03),
		BackgroundColor3 = Color3.fromRGB(121, 0, 2),
		Text = props.Text,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		[React.Event.Activated] = function()
			if not Players:GetPlayerByUserId(props.UserID) then
				warn("Player left the game, cannot jumpscare")
				SoundManager.PlayAt(SoundManager.UISounds.Error)
				return
			end
			SoundManager.PlayExistingSound(SoundManager.UISounds.ButtonClick)
			JumpscareUIFunctions.networker:fire("AddPendingJumpscare", props.UserID)
			MarketplaceService:PromptProductPurchase(PlayerContext.Player, 3507139396)
		end,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.3, 0),
		}),
	})
end

return JumpscareListButtonUI
