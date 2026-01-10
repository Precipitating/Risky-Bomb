local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local React = require(ReplicatedStorage.Packages.react)
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
				return
			end
			Remotes.PendingJumpscarePlayer:FireServer(props.UserID)
			MarketplaceService:PromptProductPurchase(PlayerContext.Player, 3507139396)
		end,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.3, 0),
		}),
	})
end

return JumpscareListButtonUI
