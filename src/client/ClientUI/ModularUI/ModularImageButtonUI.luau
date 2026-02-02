local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local React = require(ReplicatedStorage.Packages.React)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local e = React.createElement

type ModularImageButtonProps = {
	Position: UDim2,
	Size: UDim2,
	AnchorPoint: Vector2?,
	BackgroundColor: Color3?,
	ImageID: string,
	BackgroundTransparency: number?,
	ZIndex: number?,
	IsOpen: boolean,
	LayoutOrder: number?,
	CornerRadius: number?,
	AspectRatio: number?,
	Rotation: number?,
	OnClick: () -> ()?,
	OnHover: () -> ()?,
}
local function ModularImageButton(props: ModularImageButtonProps)
	return e("ImageButton", {
		Position = props.Position,
		Size = props.Size,
		Visible = props.IsOpen,
		AnchorPoint = props.AnchorPoint,
		ScaleType = Enum.ScaleType.Fit,
		LayoutOrder = props.LayoutOrder or 0,
		Rotation = props.Rotation,
		Image = props.ImageID,
		ZIndex = props.ZIndex,
		BackgroundColor3 = props.BackgroundColor,
		BackgroundTransparency = props.BackgroundTransparency,
		[React.Change.GuiState] = function(rbx: ImageButton)
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
		Corner = e("UICorner", {
			CornerRadius = UDim.new(props.CornerRadius or 0, 0),
		}),
	})
end

return ModularImageButton
