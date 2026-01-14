local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local React = require(ReplicatedStorage.Packages.React)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local e = React.createElement

type ModularTextButtonProps = {
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
	StrokeThickness: number?,
	AspectRatio: number?,
	RichText: boolean?,
	OnHover: () -> ()?,
	OnClick: () -> ()?,
}
local function ModularTextButton(props: ModularTextButtonProps)
	return e("TextButton", {
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
		[React.Change.GuiState] = function(rbx: TextButton)
			if rbx.GuiState == Enum.GuiState.Hover then
				if props.OnHover then
					props.OnHover()
				end
			elseif rbx.GuiState == Enum.GuiState.Press then
				SoundManager.PlayExistingSound(SoundManager.UISounds.ButtonClick)
				if props.OnClick then
					props.OnClick()
				end
			end
		end,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = props.CornerRadius,
		}),
		Stroke = e("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
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

return ModularTextButton
