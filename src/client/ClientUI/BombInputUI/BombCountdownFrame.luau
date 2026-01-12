local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local React = require(ReplicatedStorage.Packages.React)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local e = React.createElement

type BombCountdownFrameProps = {
	Position: UDim2,
	Size: UDim2,
	Visible: boolean,
	BackgroundColor: Color3,
	StrokeColor: Color3,
	FontColor: Color3,
	AspectRatio: number,
}
local function BombCountdownFrame(props: BombCountdownFrameProps)
	return e("Frame", {
		Position = props.Position,
		Size = props.Size,
		BackgroundColor3 = props.BackgroundColor,
		Visible = props.Visible,
		Active = false,
		Interactable = false,
		[React.Change.Size] = function(_)
			SoundManager.PlayExistingSound(SoundManager.UISounds.Tick)
		end,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0.5, 0),
		}),
		Stroke = e("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = props.StrokeColor,
			Thickness = 0.3,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			BorderStrokePosition = Enum.BorderStrokePosition.Outer,
		}),
	})
end

return BombCountdownFrame
