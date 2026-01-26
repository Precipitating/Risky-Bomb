local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

type LootTableUIProps = {
	Position: UDim2,
	Size: UDim2,
	AnchorPoint: Vector2?,
	IsOpen: boolean,
	ZIndex: number?,
	SetIsOpen: (boolean) -> ()?,
	ScrollBarImageTransparency: number?,
}
local function LootTableUI(props: LootTableUIProps)
	if not props.IsOpen then
		return nil
	end
	return e("ScrollingFrame", {
		Position = props.Position,
		Size = props.Size,
		Visible = props.IsOpen,
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(1, 1, 1),
		ScrollBarImageTransparency = props.ScrollBarImageTransparency or 0,
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		AnchorPoint = props.AnchorPoint,
		ScrollBarImageColor3 = Color3.fromRGB(255, 1, 1),
		ZIndex = props.ZIndex or 2,
		ScrollingDirection = Enum.ScrollingDirection.X,
		CanvasSize = UDim2.fromScale(2, 0),
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
		}),
		Stroke = e("UIStroke", {
			Thickness = 3,
			Color = Color3.fromRGB(255, 255, 255),
		}),

		UIList = e("UIListLayout", {
			Padding = UDim.new(0.02, 0),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			ItemLineAlignment = Enum.ItemLineAlignment.Center,
		}),
	})
end

return LootTableUI
