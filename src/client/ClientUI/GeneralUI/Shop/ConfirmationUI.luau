local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local LootTableUI = require(script.Parent.LootTableUI)
local ShopUIFunctions = require(script.Parent.ShopUIFunctions)
local ModularTextButtonUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextButtonUI)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type ConfirmationUIProps = {
	Position: UDim2,
	Size: UDim2,
	AspectRatio: number?,
	StrokeColor: Color3?,
	AnchorPoint: Vector2?,
	IsOpen: boolean,
	CostText: string,
	PackType: number,
	PackName: string,
	SetIsOpen: (boolean) -> (),
	LootTableOpen: boolean,
	SetLootTableOpen: (boolean) -> (),
	PackBought: boolean,
	SetPackBought: (boolean) -> (),
}
local function ConfirmationUI(props: ConfirmationUIProps)
	if not props.IsOpen then
		return nil
	end

	return e("Frame", {
		Position = props.Position,
		Size = props.Size,
		Visible = props.IsOpen,
		AnchorPoint = props.AnchorPoint,
		ZIndex = 5,
	}, {
		AspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = props.AspectRatio,
		}),
		Stroke = e("UIStroke", {
			Thickness = 3,
			Color = props.StrokeColor,
		}),
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.2, 0),
		}),

		Gradient = e("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(26, 26, 26)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(26, 26, 26)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
			}),
			Rotation = 90,
		}),

		PriceTextLabel = e("TextLabel", {
			Position = UDim2.fromScale(0.5, 0.1),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Text = `This costs {props.CostText} BOMBA$`,
			Size = UDim2.fromScale(0.9, 0.13),
			Font = Enum.Font.FredokaOne,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 1, 255),
		}),
		ConfirmTextLabel = e("TextLabel", {
			Position = UDim2.fromScale(0, 0.45),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Text = "Are you sure you want to buy this?",
			Size = UDim2.fromScale(1, 0.2),
			Font = Enum.Font.FredokaOne,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
		}),
		YesButton = ModularTextButtonUI({
			Position = UDim2.fromScale(0.2, 0.8),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor = Color3.fromRGB(1, 255, 1),
			Text = "Yes",
			isOpen = props.IsOpen,
			TextColor = Color3.fromRGB(255, 255, 255),
			StrokeThickness = 0.1,
			AspectRatio = 2,
			Size = UDim2.fromScale(0.2, 0.3),
			Font = Enum.Font.FredokaOne,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			OnClick = function()
				-- if nil, can't afford
				local isDuplicateOrInvalid, itemWon = ShopUIFunctions.AttemptPurchase(props.PackType, props.PackName)
				props.SetIsOpen(false)
				props.SetLootTableOpen(false)
				props.SetPackBought(true)
				if isDuplicateOrInvalid == nil then
					return
				end
				ShopUIFunctions:RemoveOldViewports()
				ShopUIFunctions.SpawnLootTable(props.PackType, props.PackName, true, itemWon)
			end,
		}),
		NoButton = ModularTextButtonUI({
			Position = UDim2.fromScale(0.55, 0.8),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor = Color3.fromRGB(255, 1, 1),
			Text = "No",
			TextColor = Color3.fromRGB(255, 255, 255),
			StrokeThickness = 0.1,
			AspectRatio = 2,
			Size = UDim2.fromScale(0.2, 0.3),
			Font = Enum.Font.FredokaOne,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			isOpen = props.IsOpen,
			OnClick = function()
				props.SetIsOpen(false)
				props.SetLootTableOpen(false)
				ShopUIFunctions:RemoveOldViewports()
			end,
		}),
		ShowLootTable = ModularTextButtonUI({
			Position = UDim2.fromScale(0.38, 1.05),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor = Color3.fromRGB(17, 0, 255),
			Text = "Show Loot Table",
			TextColor = Color3.fromRGB(255, 255, 255),
			StrokeColor = Color3.fromRGB(255, 255, 255),
			StrokeThickness = 0.05,
			AspectRatio = 2,
			Size = UDim2.fromScale(0.2, 0.3),
			Font = Enum.Font.FredokaOne,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			isOpen = props.IsOpen,
			OnClick = function()
				local newState = not props.LootTableOpen
				props.SetLootTableOpen(newState)
				if newState then
					ShopUIFunctions.SpawnLootTable(props.PackType, props.PackName, false)
				else
					ShopUIFunctions:RemoveOldViewports()
				end
			end,
		}),
		LootTable = LootTableUI({
			Position = UDim2.fromScale(0.5, 1.3),
			AnchorPoint = Vector2.new(0.5),
			Size = UDim2.fromScale(1, 1),
			IsOpen = props.LootTableOpen and props.IsOpen,
			SetIsOpen = props.SetLootTableOpen,
			PackName = props.PackName,
			PackType = props.PackType,
		}),
	})
end

return ConfirmationUI
