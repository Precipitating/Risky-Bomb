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
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		_1000Button = ModularImageButtonUI({
			Position = UDim2.fromScale(0, 0.1),
			IsOpen = props.IsOpen,
			Size = UDim2.fromScale(1, 0.25),
			LayoutOrder = 1,
			BackgroundTransparency = 1,
			ImageID = "rbxassetid://93126331373791",
			OnClick = function()
				MarketplaceService:PromptProductPurchase(PlayerContext.Player, 3512408744)
			end,
		}),
		_2700Button = ModularImageButtonUI({
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.25),
			IsOpen = props.IsOpen,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			ImageID = "rbxassetid://92919378138222",
			OnClick = function()
				MarketplaceService:PromptProductPurchase(PlayerContext.Player, 3512408743)
			end,
		}),
		_6200Button = ModularImageButtonUI({
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.25),
			IsOpen = props.IsOpen,
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			ImageID = "rbxassetid://71293299227927",
			OnClick = function()
				MarketplaceService:PromptProductPurchase(PlayerContext.Player, 3512408742)
			end,
		}),
		_14000Button = ModularImageButtonUI({
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.25),
			IsOpen = props.IsOpen,
			BackgroundTransparency = 1,
			LayoutOrder = 4,
			ImageID = "rbxassetid://80512945610152",
			OnClick = function()
				MarketplaceService:PromptProductPurchase(PlayerContext.Player, 3512408741)
			end,
		}),
		_32000Button = ModularImageButtonUI({
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.25),
			IsOpen = props.IsOpen,
			BackgroundTransparency = 1,
			LayoutOrder = 5,
			ImageID = "rbxassetid://90286951028944",
			OnClick = function()
				MarketplaceService:PromptProductPurchase(PlayerContext.Player, 3526966512)
			end,
		}),
	})
end

return ShopRobuxUI
