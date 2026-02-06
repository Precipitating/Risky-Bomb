local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local React = require(ReplicatedStorage.Packages.React)
local ReactRipple = require(ReplicatedStorage.Packages.ReactRipple)

local e = React.createElement

type BombTextButtonProps = {
	Text: string,
	Position: UDim2,
	Size: UDim2,
	Visible: boolean,
	BackgroundColor: Color3,
	StrokeColor: Color3,
	Font: Font,
	FontColor: Color3,
	AnchorPoint: Vector2,
	AspectRatio: number,
	ButtonClickedFunc: () -> (),
}

local function BombTextButton(props: BombTextButtonProps)
	local binding, spring = ReactRipple.useSpring(1, ReactRipple.config.stiff)
	return e("Frame", {
		Position = props.Position,
		Size = props.Size,
		BackgroundColor3 = props.BackgroundColor,
		Active = props.Visible,
		Visible = props.Visible,
		Interactable = props.Visible,
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
		TextButton = e("TextButton", {
			Text = props.Text,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = binding:map(function(s)
				return UDim2.fromScale(s, s)
			end),
			BackgroundTransparency = 1,
			Font = props.Font,
			TextScaled = true,
			TextColor3 = props.FontColor,
			Active = props.Visible,
			Interactable = props.Visible,
			[React.Change.GuiState] = function(rbx: TextButton)
				if rbx.GuiState == Enum.GuiState.Hover then
					spring:setGoal(1.1)
				elseif rbx.GuiState == Enum.GuiState.Press then
					spring:setGoal(0.5, { impulse = -10 })
					props.ButtonClickedFunc()
				else
					spring:setGoal(1)
				end
			end,
		}),
		AspectRatio = e("UIAspectRatioConstraint", {
			AspectType = Enum.AspectType.FitWithinMaxSize,
			AspectRatio = props.AspectRatio,
		}),
	})
end

return BombTextButton
