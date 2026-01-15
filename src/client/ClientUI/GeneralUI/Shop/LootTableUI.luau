local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

type LootTableUIProps = {
	Position: UDim2,
	Size: UDim2,
	AspectRatio: number?,
	StrokeColor: Color3?,
	AnchorPoint: Vector2?,
	IsOpen: boolean,
	SetIsOpen: (boolean) -> (),
}
local function LootTableUI(props: LootTableUIProps)
	if not props.IsOpen then
		return nil
	end
	return e("Frame", {
		Position = props.Position,
		Size = props.Size,
		Visible = props.IsOpen,
		AnchorPoint = props.AnchorPoint,
		ZIndex = 2,
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
	})
end

return LootTableUI
