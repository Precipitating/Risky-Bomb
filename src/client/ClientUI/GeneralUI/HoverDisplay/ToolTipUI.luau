local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ModularTextLabelUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextLabelUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRipple = require(ReplicatedStorage.Packages.ReactRipple)
local UICharms = require(ReplicatedStorage.Charms.UICharms)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)

local e = React.createElement

local function IsOpenAtom()
	return ReactCharm.useAtom(UICharms.ToolTipOpen)
end

local function GetToolTipInfo()
	return ReactCharm.useAtom(UICharms.CurrentToolTipInfo)
end

local function ToolTipUI()
	local isOpen = IsOpenAtom()
	local toolTipInfo = GetToolTipInfo()
	if not isOpen then
		return nil
	end

	return e("Frame", {
		Position = UDim2.fromScale(0.53, 0.3),
		Size = UDim2.fromScale(1, 0.14),
		Visible = isOpen,
		Transparency = 0.5,
		AnchorPoint = Vector2.new(0.5, 0.5),
	}, {
		AspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 2,
		}),
		Stroke = e("UIStroke", {
			Thickness = 3,
			Color = Color3.fromRGB(255, 255, 255),
		}),
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.2, 0),
		}),
		Gradient = e("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 195, 255)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 195, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 103, 134)),
			}),
			Rotation = 90,
		}),
		Name = ModularTextLabelUI({
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0, 0.5),
			StrokeThickness = 0.05,
			RichText = true,
			StrokeColor = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.FredokaOne,
			BackgroundTransparency = 1,
			Text = toolTipInfo.ItemName,
			LayoutOrder = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextScaled = false,
		}),
		Material = ModularTextLabelUI({
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0, 0.5),
			StrokeThickness = 0.05,
			RichText = true,
			StrokeColor = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.FredokaOne,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = toolTipInfo.ItemMaterial,
			LayoutOrder = 3,
			TextScaled = false,
		}),
		Color = ModularTextLabelUI({
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0, 0.5),
			StrokeThickness = 0.05,
			RichText = true,
			StrokeColor = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.FredokaOne,
			BackgroundTransparency = 1,
			Text = toolTipInfo.ItemColor,
			LayoutOrder = 2,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextScaled = false,
		}),
		UIPad = e("UIPadding", {
			PaddingLeft = UDim.new(0.05, 0),
			PaddingRight = UDim.new(0.05, 0),
			PaddingTop = UDim.new(0.05, 0),
			PaddingBottom = UDim.new(0.05, 0),
		}),
		List = e("UIListLayout", {
			Padding = UDim.new(0, 0.1),
			VerticalFlex = Enum.UIFlexAlignment.Fill,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
end

return ToolTipUI
