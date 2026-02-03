local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type ModularImageLabelProps = {
	Position: UDim2,
	Size: UDim2,
	AnchorPoint: Vector2?,
	BackgroundColor: Color3?,
	ImageID: string?,
	BackgroundTransparency: number?,
	ZIndex: number?,
	CornerRadius: number?,
	AspectRatio: number?,
	Rotation: number?,
}
local function ModularImageLabel(props: ModularImageLabelProps, children)
	return e("ImageLabel", {
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		ScaleType = Enum.ScaleType.Fit,
		Rotation = props.Rotation,
		Image = props.ImageID or "",
		ZIndex = props.ZIndex,
		BackgroundColor3 = props.BackgroundColor,
		BackgroundTransparency = props.BackgroundTransparency,
	}, {
		AspectRatio = e("UIAspectRatioConstraint", {
			AspectRatio = props.AspectRatio,
		}),
		Corner = e("UICorner", {
			CornerRadius = UDim.new(props.CornerRadius or 0, 0),
		}),
		OptionalChildren = children,
	})
end

return ModularImageLabel
