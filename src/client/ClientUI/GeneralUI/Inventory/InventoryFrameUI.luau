local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local InventoryCodePageUI = require(script.Parent.InventoryCodePageUI)
local InventoryItemFiltersUI = require(script.Parent.InventoryItemFiltersUI)
local InventoryOwnedItemsUI = require(script.Parent.InventoryOwnedItemsUI)
local InventoryUIFunctions = require(script.Parent.InventoryUIFunctions)
local ModularImageLabel = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularImageLabelUI)
local ModularTextButtonUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextButtonUI)
local ModularTextLabel = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextLabelUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRipple = require(ReplicatedStorage.Packages.ReactRipple)

local e = React.createElement

type InventoryFrameUIProps = {
	Position: UDim2,
	Size: UDim2,
	AspectRatio: number?,
	StrokeColor: Color3?,
	AnchorPoint: Vector2?,
	IsOpen: boolean,
	SetIsOpen: (boolean) -> (),
}
local function InventoryFrameUI(props: InventoryFrameUIProps)
	local chairPageOpened, setChairPageOpened = React.useState(false)
	local bombPageOpened, setBombPageOpened = React.useState(false)
	local codePageOpened, setCodePageOpened = React.useState(false)

	React.useEffect(function()
		if props.IsOpen then
			setChairPageOpened(false)
			setBombPageOpened(false)
			setCodePageOpened(false)
		end
	end, { props.IsOpen })

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
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 195, 255)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 195, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 103, 134)),
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
			isOpen = props.IsOpen,
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
			Text = "Inventory",
			Position = UDim2.fromScale(0.36, -0.14),
			Size = UDim2.fromScale(0.3, 0.3),
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
			isOpen = props.IsOpen,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			StrokeThickness = 0,
			CornerRadius = UDim.new(0.1, 0),
			Font = Enum.Font.FredokaOne,
			OnClick = function()
				if chairPageOpened then
					return
				end
				setBombPageOpened(false)
				setCodePageOpened(false)
				setChairPageOpened(true)
				InventoryUIFunctions.OpenInventoryOf("ChairPage")
			end,
		}),
		BombCategory = ModularTextButtonUI({
			Text = "Bombs",
			Position = UDim2.fromScale(0.05, 0.4),
			Size = UDim2.fromScale(0.15, 0.15),
			TextColor = Color3.fromRGB(255, 255, 255),
			AspectRatio = 3,
			isOpen = props.IsOpen,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			StrokeThickness = 0,
			CornerRadius = UDim.new(0.1, 0),
			Font = Enum.Font.FredokaOne,
			OnClick = function()
				if bombPageOpened then
					return
				end
				setChairPageOpened(false)
				setCodePageOpened(false)
				setBombPageOpened(true)
				InventoryUIFunctions.OpenInventoryOf("BombPage")
			end,
		}),
		CodeCategory = ModularTextButtonUI({
			Text = "Codes",
			Position = UDim2.fromScale(0.05, 0.5),
			Size = UDim2.fromScale(0.15, 0.15),
			TextColor = Color3.fromRGB(255, 255, 255),
			AspectRatio = 3,
			isOpen = props.IsOpen,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			StrokeThickness = 0,
			CornerRadius = UDim.new(0.1, 0),
			Font = Enum.Font.FredokaOne,
			OnClick = function()
				if codePageOpened then
					return
				end
				setChairPageOpened(false)
				setBombPageOpened(false)
				setCodePageOpened(true)
			end,
		}),

		ItemFilters = InventoryItemFiltersUI({
			IsOpen = bombPageOpened or chairPageOpened,
			Position = UDim2.fromScale(0.25, 0.23),
			Size = UDim2.fromScale(1, 0.05),
			AspectRatio = 12,
			InventoryType = (function()
				if chairPageOpened then
					return "ChairPage"
				elseif bombPageOpened then
					return "BombPage"
				end
				return ""
			end)(),
		}),

		-- pages
		ChairPage = InventoryOwnedItemsUI({
			Position = UDim2.fromScale(0.23, 0.3),
			Size = UDim2.fromScale(0.65, 0.5),
			IsOpen = chairPageOpened,
			SetIsOpen = setChairPageOpened,
		}),

		BombPage = InventoryOwnedItemsUI({
			Position = UDim2.fromScale(0.23, 0.3),
			Size = UDim2.fromScale(0.65, 0.5),
			IsOpen = bombPageOpened,
			SetIsOpen = setChairPageOpened,
		}),
		CodePage = InventoryCodePageUI({
			Position = UDim2.fromScale(0.23, 0.3),
			Size = UDim2.fromScale(0.65, 0.5),
			IsOpen = codePageOpened,
		}),
	})
end

return InventoryFrameUI
