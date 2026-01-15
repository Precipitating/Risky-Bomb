local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ModularImageButtonUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularImageButtonUI)
local React = require(ReplicatedStorage.Packages.React)
local PackType = require(ReplicatedStorage.Types.PackType)
local e = React.createElement

type ShopChairsUIProps = {
	Position: UDim2,
	Size: UDim2,
	AspectRatio: number?,
	StrokeColor: Color3?,
	BackgroundColor: Color3?,
	BackgroundTransparency: boolean?,
	AnchorPoint: Vector2?,
	IsOpen: boolean,
	ConfirmationSetOpen: (boolean) -> (),
	PackSetType: (number) -> (),
	PackSetName: (string) -> (),
	PackSetPrice: (string) -> (),
}
local function ShopChairsUI(props: ShopChairsUIProps)
	if not props.IsOpen then
		return nil
	end
	return e("ScrollingFrame", {
		Position = props.Position,
		Size = props.Size,
		CanvasSize = UDim2.fromScale(0, 1),
		BackgroundTransparency = 1,
		Visible = props.IsOpen,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarImageColor3 = Color3.fromRGB(255, 1, 1),
		AnchorPoint = props.AnchorPoint,
	}, {

		UIList = e("UIListLayout", {
			Padding = UDim.new(0.02, 0),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		}),
		_95Pack = ModularImageButtonUI({
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.11),
			BackgroundTransparency = 1,
			ImageID = "rbxassetid://110643834598127",
			OnClick = function()
				props.PackSetName("NineToFivePack")
				props.PackSetType(PackType.ChairPack)
				props.PackSetPrice("1000")
				props.ConfirmationSetOpen(true)
			end,
		}),
	})
end

return ShopChairsUI
