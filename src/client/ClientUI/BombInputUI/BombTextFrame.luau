local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type BombTextFrameProps = {
	Text: string,
	Position: UDim2,
	Size: UDim2,
	Visible: boolean,
	BackgroundColor: Color3,
	StrokeColor: Color3,
	Font: Font,
	FontColor: Color3,
	AspectRatio: number,
	AnchorPoint: Vector2,
}
local function BombTextFrame(props: BombTextFrameProps)
	return e("Frame", {
		Position = props.Position,
		Size = props.Size,
		BackgroundColor3 = props.BackgroundColor,
		Visible = props.Visible,
		Active = false,
		Interactable = false,
		AnchorPoint = props.AnchorPoint,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
		}),
		Stroke = e("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = props.StrokeColor,
			Thickness = 0.03,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			BorderStrokePosition = Enum.BorderStrokePosition.Outer,
		}),
		Text = e("TextLabel", {
			Text = props.Text,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Font = props.Font,
			TextScaled = true,
			TextColor3 = props.FontColor,
			Active = false,
			Interactable = false,
		}),
		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0.03, 0),
			PaddingRight = UDim.new(0.03, 0),
		}),
		AspectRatio = e("UIAspectRatioConstraint", {
			AspectType = Enum.AspectType.FitWithinMaxSize,
			AspectRatio = props.AspectRatio,
		}),
	})
end

return BombTextFrame
