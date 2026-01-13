local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local React = require(ReplicatedStorage.Packages.React)
local ReactRipple = require(ReplicatedStorage.Packages.ReactRipple)
local BombGameCharms = require(ReplicatedStorage.Charms.BombGameCharms)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local e = React.createElement
type GeneralCashUIProps = {
	Position: UDim2,
	Size: UDim2,
	ImageID: string,
	AspectRatio: number,
	AnchorPoint: Vector2,
}

local function CurrentCash()
	return ReactCharm.useAtom(BombGameCharms.CurrentCashValue)
end

local function GeneralCashUI(props: GeneralCashUIProps)
	return e("ImageLabel", {
		Position = props.Position,
		Size = props.Size,
		Image = props.ImageID,
		BackgroundTransparency = 1,
		AnchorPoint = props.AnchorPoint,
	}, {
		AspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = props.AspectRatio,
		}),
		CashLabel = e("TextLabel", {
			Position = UDim2.fromScale(1, 0.6),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromScale(2, 0.7),
			Font = Enum.Font.Bangers,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			BackgroundTransparency = 1,
			Text = tostring(CurrentCash()),
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(0, 0, 0),
				Thickness = 3,
			}),
		}),
	})
end

return GeneralCashUI
