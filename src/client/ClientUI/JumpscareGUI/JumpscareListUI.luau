local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local JumpscareListButton = require(script.Parent.JumpscareListButtonUI)
local JumpscareUIFunctions = require(script.Parent.JumpscareUIFunctions)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

type JumpscareListUIProps = {
	BackgroundColor: Color3,
	StrokeColor: Color3,
	IsVisible: boolean,
}
local function JumpscareListUI(props: JumpscareListUIProps)
	if not props.IsVisible then
		return nil
	end
	local players, setPlayers = React.useState({})

	React.useEffect(function()
		if props.IsVisible then
			setPlayers(JumpscareUIFunctions.GetPlayers())
		end
	end, { props.IsVisible })

	local playerList = {}
	for _, player in pairs(players) do
		playerList[player.UserID] = JumpscareListButton({
			Text = player.Name,
			UserID = player.UserID,
		})
	end
	local fragmentList = e(React.Fragment, nil, playerList)

	return e("ScrollingFrame", {
		Position = UDim2.fromScale(0.98, 0.06),
		Size = UDim2.fromScale(0.14, 0.3),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = props.BackgroundColor,
		ScrollBarThickness = 3,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		CanvasSize = UDim2.fromScale(0, 1),
		Visible = props.IsVisible,
		Active = props.IsVisible,
		Interactable = props.IsVisible,
		ScrollBarImageColor3 = Color3.fromRGB(0, 0, 255),
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 0.8),
		}),
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0.005, 0),
		}),

		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0.01, 0),
			PaddingTop = UDim.new(0.002, 0),
		}),
		Stroke = e("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = props.StrokeColor,
			Thickness = 0.02,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			BorderStrokePosition = Enum.BorderStrokePosition.Outer,
		}),
		AspectRatio = e("UIAspectRatioConstraint", {
			AspectRatio = 1,
		}),
		PlayerList = fragmentList,
	})
end

return JumpscareListUI
