local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ConfirmationUI = require(script.Parent.ConfirmationUI)
local ShopPackDisplayerUI = require(script.Parent.ShopPackDisplayerUI)
local ShopRobux = require(script.Parent.ShopRobux)
local ModularImageLabel = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularImageLabelUI)
local ModularTextButtonUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextButtonUI)
local ModularTextLabel = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextLabelUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRipple = require(ReplicatedStorage.Packages.ReactRipple)
local PackType = require(ReplicatedStorage.Types.PackType)
local e = React.createElement

type ShopFrameUIProps = {
	Position: UDim2,
	Size: UDim2,
	AspectRatio: number?,
	StrokeColor: Color3?,
	AnchorPoint: Vector2?,
	IsOpen: boolean,
	SetIsOpen: (boolean) -> (),
	LootTableOpen: boolean,
	SetLootTableOpen: (boolean) -> (),
}

local function ShopFrameUI(props: ShopFrameUIProps)
	local robuxPageOpened, setRobuxPageOpened = React.useState(false)
	local chairPageOpened, setChairPageOpened = React.useState(false)
	local bombPageOpened, setBombPageOpened = React.useState(false)

	local confirmationOpened, setConfirmationOpened = React.useState(false)
	local currentPackType, setCurrentPackType = React.useState(-1)
	local packName, setPackName = React.useState("nil")
	local packPrice, setPackPrice = React.useState("unset")

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
			isOpen = props.IsOpen,
			OnClick = function()
				props.SetIsOpen(false)
				setRobuxPageOpened(false)
				setBombPageOpened(false)
				setConfirmationOpened(false)
				setCurrentPackType(-1)
				setPackName("nil")
				setPackPrice("unset")
				props.SetLootTableOpen(false)
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
			isOpen = props.IsOpen,
			CornerRadius = UDim.new(0.1, 0),
			Font = Enum.Font.FredokaOne,
			OnClick = function()
				if bombPageOpened then
					setBombPageOpened(false)
				end
				if robuxPageOpened then
					setRobuxPageOpened(false)
				end

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
			isOpen = props.IsOpen,
			OnClick = function()
				if chairPageOpened then
					setChairPageOpened(false)
				end
				if robuxPageOpened then
					setRobuxPageOpened(false)
				end

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
			isOpen = props.IsOpen,
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
		ChairPage = ShopPackDisplayerUI({
			Position = UDim2.fromScale(0.21, 0.25),
			Size = UDim2.fromScale(0.7, 0.4),
			IsOpen = chairPageOpened,
			ConfirmationSetOpen = setConfirmationOpened,
			PackType = PackType.ChairPack,
			PackSetName = setPackName,
			PackSetType = setCurrentPackType,
			PackSetPrice = setPackPrice,
		}),
		BombPage = ShopPackDisplayerUI({
			Position = UDim2.fromScale(0.21, 0.25),
			Size = UDim2.fromScale(0.7, 0.4),
			IsOpen = bombPageOpened,
			PackType = PackType.BombPack,
			ConfirmationSetOpen = setConfirmationOpened,
			PackSetName = setPackName,
			PackSetType = setCurrentPackType,
			PackSetPrice = setPackPrice,
		}),
		ConfirmationPrompt = ConfirmationUI({
			Position = UDim2.fromScale(0.55, 0.3),
			StrokeColor = Color3.fromRGB(255, 255, 255),
			AnchorPoint = Vector2.new(0.5),
			Size = UDim2.fromScale(0.6, 0.6),
			AspectRatio = 2,
			IsOpen = confirmationOpened,
			SetIsOpen = setConfirmationOpened,
			CostText = tostring(packPrice),
			PackType = currentPackType,
			PackName = packName,
			LootTableOpen = props.LootTableOpen,
			SetLootTableOpen = props.SetLootTableOpen,
		}),

		BlockingFrame = e("TextButton", {
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 4,
			Visible = confirmationOpened,
			BackgroundColor3 = Color3.fromRGB(1, 1, 1),
			BackgroundTransparency = 0.5,
			Size = UDim2.fromOffset(9999, 9999),
			AutoButtonColor = false,
		}),
	})
end

return ShopFrameUI
