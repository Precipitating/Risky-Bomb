local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ShopRobux = require(script.Parent.ShopRobux)
local ModularImageLabel = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularImageLabelUI)
local ModularTextButtonUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextButtonUI)
local ModularTextLabel = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextLabelUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRipple = require(ReplicatedStorage.Packages.ReactRipple)
local e = React.createElement

type ShopFrameUIProps = {
	Position: UDim2,
	Size: UDim2,
	AspectRatio: number?,
	StrokeColor: Color3?,
	AnchorPoint: Vector2?,
	IsOpen: boolean,
	SetIsOpen: (boolean) -> (),
}
local function ShopFrameUI(props: ShopFrameUIProps)
	local robuxPageOpened, setRobuxPageOpened = React.useState(false)
	local chairPageOpened, setChairPageOpened = React.useState(false)
	local bombPageOpened, setBombPageOpened = React.useState(false)
	if not props.IsOpen then
		return nil
	end

	return e("Frame", {
		Position = props.Position,
		Size = props.Size,
		Visible = props.IsOpen,
		AnchorPoint = props.AnchorPoint,
	}, {
		AspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = props.AspectRatio,
		}),
		Stroke = e("UIStroke", {
			Thickness = 3,
			Color = props.StrokeColor,
		}),
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.5, 0),
		}),
		Gradient = e("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 26, 26)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(26, 26, 26)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
			}),
			Rotation = 90,
		}),
		FuseImage = ModularImageLabel({
			ImageID = "rbxassetid://73108730808069",
			Position = UDim2.fromScale(0.465, -0.19),
			ZIndex = 0,
			Size = UDim2.fromScale(0.2, 0.2),
			BackgroundTransparency = 1,
			Rotation = 10,
		}),
		CloseButton = ModularTextButtonUI({
			Position = UDim2.fromScale(0.75, 0.05),
			Size = UDim2.fromScale(0.08, 0.08),
			BackgroundColor = Color3.fromRGB(255, 1, 1),
			Text = "X",
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Font = Enum.Font.FredokaOne,
			TextColor = Color3.fromRGB(255, 255, 255),
			OnClick = function()
				props.SetIsOpen(false)
			end,
			StrokeThickness = 0.08,
			AspectRatio = 1,
		}),
		ShopLabel = ModularTextLabel({
			Text = "Store",
			Position = UDim2.fromScale(0.406, -0.1),
			Size = UDim2.fromScale(0.2, 0.2),
			TextColor = Color3.fromRGB(252, 255, 255),
			BackgroundTransparency = 1,
			Font = Enum.Font.FredokaOne,
			StrokeThickness = 0.05,
		}),
		Seperator = e("Frame", {
			Position = UDim2.fromScale(0.2, 0.3),
			Size = UDim2.fromScale(0.001, 0.26),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			ZIndex = 0,
		}, {
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 1,
			}),
		}),
		-- categories
		ChairCategory = ModularTextButtonUI({
			Text = "Chairs",
			Position = UDim2.fromScale(0.05, 0.3),
			Size = UDim2.fromScale(0.15, 0.15),
			TextColor = Color3.fromRGB(255, 255, 255),
			AspectRatio = 3,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			StrokeThickness = 0,
			CornerRadius = UDim.new(0.1, 0),
			Font = Enum.Font.FredokaOne,
			OnClick = function()
				setBombPageOpened(false)
				setRobuxPageOpened(false)
				setChairPageOpened(true)
			end,
		}),
		BombCategory = ModularTextButtonUI({
			Text = "Bombs",
			Position = UDim2.fromScale(0.05, 0.4),
			Size = UDim2.fromScale(0.15, 0.15),
			TextColor = Color3.fromRGB(255, 255, 255),
			AspectRatio = 3,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			StrokeThickness = 0,
			CornerRadius = UDim.new(0.1, 0),
			Font = Enum.Font.FredokaOne,
			OnClick = function()
				setChairPageOpened(false)
				setRobuxPageOpened(false)
				setBombPageOpened(true)
			end,
		}),
		BuyCurrencyCategory = ModularTextButtonUI({
			Text = "Cash",
			Position = UDim2.fromScale(0.05, 0.5),
			Size = UDim2.fromScale(0.15, 0.15),
			TextColor = Color3.fromRGB(255, 255, 255),
			AspectRatio = 3,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			StrokeThickness = 0,
			CornerRadius = UDim.new(0.1, 0),
			Font = Enum.Font.FredokaOne,
			OnClick = function()
				if bombPageOpened then
					setBombPageOpened(false)
				end

				if chairPageOpened then
					setChairPageOpened(false)
				end

				setRobuxPageOpened(true)
			end,
		}),

		-- category pages
		RobuxPage = ShopRobux({
			Position = UDim2.fromScale(0.22, 0.25),
			Size = UDim2.fromScale(0.7, 0.4),
			IsOpen = robuxPageOpened,
		}),
	})
end

return ShopFrameUI
