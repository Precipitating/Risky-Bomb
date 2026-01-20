local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type JumpscareButtonUIProps = {
	BackgroundColor: Color3,
	Text: string,
	Font: Font,
	StrokeColor: Color3,
	OnToggle: () -> (),
}
local function JumpscareButtonUI(props: JumpscareButtonUIProps)
	return e("TextButton", {
		Position = UDim2.fromScale(0.985, 0.04),
		Size = UDim2.fromScale(0.15, 0.03),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = props.BackgroundColor,
		Text = props.Text,
		TextScaled = true,
		Font = props.Font,
		TextYAlignment = Enum.TextYAlignment.Bottom,
		[React.Event.Activated] = props.OnToggle,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.5, 0),
		}),
		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0.1, 0),
			PaddingRight = UDim.new(0.1, 0),
			PaddingTop = UDim.new(0.1, 0),
		}),
		Stroke = e("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = props.StrokeColor,
			Thickness = 0.08,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			BorderStrokePosition = Enum.BorderStrokePosition.Outer,
		}),
		AspectRatio = e("UIAspectRatioConstraint", {
			AspectRatio = 10,
		}),
	})
end

return JumpscareButtonUI
