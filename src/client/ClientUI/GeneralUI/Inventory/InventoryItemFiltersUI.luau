local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local InventoryUIFunctions = require(script.Parent.InventoryUIFunctions)
local ModularTextButtonUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextButtonUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRipple = require(ReplicatedStorage.Packages.ReactRipple)
local RarityColor = require(ReplicatedStorage.Config.RarityColor)
local Rarity = require(ReplicatedStorage.Config.Rarity)

local e = React.createElement

type InventoryItemFiltersUIProps = {
	Position: UDim2,
	Size: UDim2,
	AspectRatio: number?,
	StrokeColor: Color3?,
	AnchorPoint: Vector2?,
	IsOpen: boolean,
	SetIsOpen: (boolean) -> ()?,
	InventoryType: string,
}
local function InventoryItemFiltersUI(props: InventoryItemFiltersUIProps)
	if not props.IsOpen then
		return nil
	end

	return e("Frame", {
		Position = props.Position,
		Size = props.Size,
		Visible = props.IsOpen,
		AnchorPoint = props.AnchorPoint,
		ZIndex = 0,
	}, {
		AspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = props.AspectRatio,
		}),
		Stroke = e("UIStroke", {
			Thickness = 3,
			Color = props.StrokeColor or Color3.fromRGB(255, 255, 255),
		}),
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
		}),
		Gradient = e("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 195, 255)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 195, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 103, 134)),
			}),
			Rotation = 90,
		}),
		AllItemsButton = ModularTextButtonUI({
			Position = UDim2.fromScale(0.02, 0.25),
			Size = UDim2.fromScale(0.5, 0.5),
			AspectRatio = 4,
			StrokeThickness = 0.1,
			TextColor = Color3.fromRGB(1, 1, 1),
			BackgroundColor = Color3.fromRGB(255, 255, 255),
			CornerRadius = UDim.new(0.1),
			Font = Enum.Font.ArimoBold,
			Text = "ALL",
			isOpen = props.IsOpen,
			OnClick = function()
				InventoryUIFunctions:FilterRarity(props.InventoryType, -1)
			end,
		}),
		CommonButton = ModularTextButtonUI({
			Position = UDim2.fromScale(0.22, 0.25),
			Size = UDim2.fromScale(0.5, 0.5),
			AspectRatio = 4,
			StrokeThickness = 0.1,
			TextColor = Color3.fromRGB(1, 1, 1),
			BackgroundColor = RarityColor[Rarity.Common],
			CornerRadius = UDim.new(0.1),
			Font = Enum.Font.ArimoBold,
			Text = "COMMON",
			isOpen = props.IsOpen,
			OnClick = function()
				InventoryUIFunctions:FilterRarity(props.InventoryType, Rarity.Common)
			end,
		}),
		RareButton = ModularTextButtonUI({
			Position = UDim2.fromScale(0.42, 0.25),
			Size = UDim2.fromScale(0.5, 0.5),
			AspectRatio = 4,
			TextColor = Color3.fromRGB(1, 1, 1),
			StrokeThickness = 0.1,
			BackgroundColor = RarityColor[Rarity.Rare],
			CornerRadius = UDim.new(0.1),
			Font = Enum.Font.ArimoBold,
			Text = "RARE",
			isOpen = props.IsOpen,
			OnClick = function()
				InventoryUIFunctions:FilterRarity(props.InventoryType, Rarity.Rare)
			end,
		}),
		EpicButton = ModularTextButtonUI({
			Position = UDim2.fromScale(0.62, 0.25),
			Size = UDim2.fromScale(0.5, 0.5),
			AspectRatio = 4,
			StrokeThickness = 0.1,
			TextColor = Color3.fromRGB(1, 1, 1),
			BackgroundColor = RarityColor[Rarity.Epic],
			CornerRadius = UDim.new(0.1),
			Font = Enum.Font.ArimoBold,
			Text = "EPIC",
			isOpen = props.IsOpen,
			OnClick = function()
				InventoryUIFunctions:FilterRarity(props.InventoryType, Rarity.Epic)
			end,
		}),

		LegendaryButton = ModularTextButtonUI({
			Position = UDim2.fromScale(0.82, 0.25),
			Size = UDim2.fromScale(0.5, 0.5),
			AspectRatio = 4,
			StrokeThickness = 0.1,
			TextColor = Color3.fromRGB(1, 1, 1),
			BackgroundColor = RarityColor[Rarity.Legendary],
			CornerRadius = UDim.new(0.1),
			Font = Enum.Font.ArimoBold,
			Text = "LEGENDARY",
			isOpen = props.IsOpen,
			OnClick = function()
				InventoryUIFunctions:FilterRarity(props.InventoryType, Rarity.Legendary)
			end,
		}),
	})
end

return InventoryItemFiltersUI
