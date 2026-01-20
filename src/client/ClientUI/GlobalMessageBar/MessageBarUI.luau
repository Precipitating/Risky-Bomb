local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ModularTextLabelUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextLabelUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local UICharms = require(ReplicatedStorage.Charms.UICharms)

local e = React.createElement

local function CurrentDonator()
	return ReactCharm.useAtom(UICharms.CurrentDonationText)
end
local function MessageBarUI()
	local currentText = CurrentDonator()
	return e(React.Fragment, nil, {
		GlobalMsgTextLabel = ModularTextLabelUI({
			Position = UDim2.fromScale(0.5, 0),
			Text = currentText,
			Font = Enum.Font.FredokaOne,
			BackgroundColor = Color3.fromRGB(0, 255, 21),
			StrokeThickness = 0,
			TextColor = Color3.fromRGB(0, 0, 0),
			Size = UDim2.fromScale(1, 0.05),
			AspectRatio = 90,
			AnchorPoint = Vector2.new(0.5, 0),
		}),
	})
end

return MessageBarUI
