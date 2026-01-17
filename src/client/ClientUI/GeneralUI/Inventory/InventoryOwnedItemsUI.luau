local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

type InventoryOwnedItemsUIProps = {
	Position: UDim2,
	Size: UDim2,
	AnchorPoint: Vector2?,
	IsOpen: boolean,
	SetIsOpen: (boolean) -> (),
}
local function InventoryOwnedItemsUI(props: InventoryOwnedItemsUIProps)
	if not props.IsOpen then
		return nil
	end
	return e("ScrollingFrame", {
		Position = props.Position,
		Size = props.Size,
		Visible = props.IsOpen,
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(0, 81, 255),
		BorderSizePixel = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		AnchorPoint = props.AnchorPoint,
		ScrollBarImageColor3 = Color3.fromRGB(255, 1, 1),
		ZIndex = 2,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = UDim2.fromScale(0, 1),
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.05, 0),
		}),
		Stroke = e("UIStroke", {
			Thickness = 2,
			Color = Color3.fromRGB(255, 255, 255),
		}),

		UIGrid = e("UIGridLayout", {
			SortOrder = Enum.SortOrder.Name,
			CellPadding = UDim2.fromScale(0.1, 0.1),
			CellSize = UDim2.fromScale(0.4, 0.4),
		}),
		UIPad = e("UIPadding", {
			PaddingLeft = UDim.new(0.05, 0),
		}),
	})
end

return InventoryOwnedItemsUI
