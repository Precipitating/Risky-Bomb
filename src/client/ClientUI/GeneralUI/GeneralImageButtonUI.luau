local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local React = require(ReplicatedStorage.Packages.React)
local ReactRipple = require(ReplicatedStorage.Packages.ReactRipple)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local e = React.createElement

type GeneralImageButtonUIProps = {
	Position: UDim2,
	Size: UDim2,
	ImageID: string,
	AspectRatio: number?,
	BackgroundTransparency: number?,
	AnchorPoint: Vector2?,
	Visible: boolean?,
	OnClick: () -> (),
}
local function GeneralImageButtonUI(props: GeneralImageButtonUIProps)
	local binding, spring = ReactRipple.useSpring(1, ReactRipple.config.stiff)
	return e("ImageButton", {
		Position = props.Position,
		Size = binding:map(function(s)
			return UDim2.fromScale(props.Size.X.Scale * s, props.Size.Y.Scale * s)
		end),
		Image = props.ImageID,
		Visible = props.Visible or true,
		BackgroundTransparency = props.BackgroundTransparency or 1,
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
		[React.Change.GuiState] = function(rbx: ImageButton)
			if rbx.GuiState == Enum.GuiState.Hover then
				spring:setGoal(1.1)
			elseif rbx.GuiState == Enum.GuiState.Press then
				SoundManager.PlayExistingSound(SoundManager.UISounds.ButtonClick)
				spring:setGoal(0.5, { impulse = -10 })
				props.OnClick()
			else
				spring:setGoal(1)
			end
		end,
	}, {
		AspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = props.AspectRatio or 1,
		}),
	})
end

return GeneralImageButtonUI
