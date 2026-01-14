local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type ModularTextLabelProps = {
	Position: UDim2,
	Size: UDim2,
	AnchorPoint: Vector2?,
	BackgroundColor: Color3?,
	BackgroundTransparency: number?,
	Text: string,
	TextColor: Color3?,
	TextYAlignment: Enum.TextYAlignment?,
	TextXAlignment: Enum.TextXAlignment?,
	CornerRadius: UDim?,
	Font: Font?,
	StrokeColor: Color3?,
	RichText: boolean?,
	StrokeThickness: number?,
	AspectRatio: number?,
}
local function ModularTextLabel(props: ModularTextLabelProps)
	return e("TextLabel", {
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		BackgroundColor3 = props.BackgroundColor,
		BackgroundTransparency = props.BackgroundTransparency,
		Text = props.Text,
		TextColor3 = props.TextColor,
		TextScaled = true,
		Font = props.Font,
		TextYAlignment = props.TextYAlignment,
		TextXAlignment = props.TextXAlignment,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = props.CornerRadius,
		}),
		Stroke = e("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			Color = props.StrokeColor,
			Thickness = props.StrokeThickness,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			BorderStrokePosition = Enum.BorderStrokePosition.Outer,
		}),
		AspectRatio = e("UIAspectRatioConstraint", {
			AspectRatio = props.AspectRatio,
		}),
	})
end

return ModularTextLabel
