local MarketplaceService = game:GetService("MarketplaceService")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ModularImageButtonUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularImageButtonUI)
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local React = require(ReplicatedStorage.Packages.React)
local ReactRipple = require(ReplicatedStorage.Packages.ReactRipple)
local e = React.createElement

type ShopRobuxUIProps = {
	Position: UDim2,
	Size: UDim2,
	AspectRatio: number?,
	StrokeColor: Color3?,
	BackgroundColor: Color3?,
	BackgroundTransparency: boolean?,
	AnchorPoint: Vector2?,
	IsOpen: boolean,
}
local function ShopRobuxUI(props: ShopRobuxUIProps)
	if not props.IsOpen then
		return nil
	end
	return e("Frame", {
		Position = props.Position,
		Size = props.Size,
		BackgroundTransparency = 1,
		Visible = props.IsOpen,
		AnchorPoint = props.AnchorPoint,
	}, {

		UIList = e("UIListLayout", {
			Padding = UDim.new(0.02, 0),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		}),
		_1000Button = ModularImageButtonUI({
			Position = UDim2.fromScale(0, 0),
			IsOpen = props.IsOpen,
			Size = UDim2.fromScale(1, 0.3),
			BackgroundTransparency = 1,
			ImageID = "rbxassetid://129002561266142",
			OnClick = function()
				MarketplaceService:PromptProductPurchase(PlayerContext.Player, 3512408744)
			end,
		}),
		_2500Button = ModularImageButtonUI({
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.3),
			IsOpen = props.IsOpen,
			BackgroundTransparency = 1,
			ImageID = "rbxassetid://123110515723057",
			OnClick = function()
				MarketplaceService:PromptProductPurchase(PlayerContext.Player, 3512408743)
			end,
		}),
		_5250Button = ModularImageButtonUI({
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.3),
			IsOpen = props.IsOpen,
			BackgroundTransparency = 1,
			ImageID = "rbxassetid://72380522066348",
			OnClick = function()
				MarketplaceService:PromptProductPurchase(PlayerContext.Player, 3512408742)
			end,
		}),
		_5Button = ModularImageButtonUI({
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.3),
			IsOpen = props.IsOpen,
			BackgroundTransparency = 1,
			ImageID = "rbxassetid://102258412586491",
			OnClick = function()
				MarketplaceService:PromptProductPurchase(PlayerContext.Player, 3512408741)
			end,
		}),
	})
end

return ShopRobuxUI
