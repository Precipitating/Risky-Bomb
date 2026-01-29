local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local DailyRewardUIFunctions = require(script.Parent.DailyRewardUIFunctions)
local ModularImageLabel = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularImageLabelUI)
local ModularTextButtonUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextButtonUI)
local ModularTextLabelUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextLabelUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRipple = require(ReplicatedStorage.Packages.ReactRipple)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local UICharms = require(ReplicatedStorage.Charms.UICharms)
local DailyRewardsData = require(ReplicatedStorage.Config.DailyRewardsData)

local e = React.createElement

type DailyRewardUIProps = {
	Position: UDim2,
	Size: UDim2,
	AspectRatio: number?,
	StrokeColor: Color3?,
	AnchorPoint: Vector2?,
	SetIsOpen: (boolean) -> (),
}

local function CanAwardDaily()
	return ReactCharm.useAtom(UICharms.CanAwardDaily)
end

local function DailyRewardUI(props: DailyRewardUIProps)
	local canShow = CanAwardDaily()
	local days, setDays = React.useState(0)

	React.useEffect(function()
		setDays(DailyRewardUIFunctions.GetConsecutiveDays())
	end, {})
	local frameRef = React.useRef(nil)

	if not canShow then
		return nil
	end

	return e("Frame", {
		ref = frameRef,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.5, 0.5),
		Visible = canShow,
		AnchorPoint = Vector2.new(0.5, 0.5),
	}, {
		AspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = props.AspectRatio,
		}),
		Stroke = e("UIStroke", {
			Thickness = 3,
			Color = props.StrokeColor,
		}),
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.5, 0),
		}),
		Gradient = e("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.4, Color3.fromRGB(123, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
			}),
			Rotation = 90,
		}),
		FuseImage = ModularImageLabel({
			ImageID = "rbxassetid://73108730808069",
			Position = UDim2.fromScale(0.465, -0.19),
			ZIndex = 0,
			Size = UDim2.fromScale(0.2, 0.2),
			BackgroundTransparency = 1,
			Rotation = 10,
		}),
		Title = ModularTextLabelUI({
			Position = UDim2.fromScale(0.5, 0.2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			TextColor = Color3.fromRGB(255, 255, 255),
			Size = UDim2.fromScale(0.3, 0.3),
			Text = "Daily Reward",
			Font = Enum.Font.FredokaOne,
		}),
		Desc = ModularTextLabelUI({
			Position = UDim2.fromScale(0.5, 0.35),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			TextColor = Color3.fromRGB(255, 255, 255),
			Size = UDim2.fromScale(1, 0.05),
			Text = "Rewards stack on consecutive days!",
			Font = Enum.Font.FredokaOne,
		}),
		ConsecutiveDays = ModularTextLabelUI({
			Position = UDim2.fromScale(0.5, 0.42),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			TextColor = Color3.fromRGB(255, 255, 255),
			Size = UDim2.fromScale(1, 0.06),
			Text = `{tostring(days)} days played`,
			Font = Enum.Font.FredokaOne,
		}),
		Award = ModularTextLabelUI({
			Position = UDim2.fromScale(0.5, 0.58),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			TextColor = Color3.fromRGB(255, 1, 255),
			Size = UDim2.fromScale(1, 0.2),
			Text = `{days * DailyRewardsData.AwardPerDay} BOMBA$ AWARDED!`,
			Font = Enum.Font.FredokaOne,
		}),
		ClaimButton = ModularTextButtonUI({
			Position = UDim2.fromScale(0.5, 0.8),
			Size = UDim2.fromScale(1, 0.1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			isOpen = true,
			CornerRadius = UDim.new(0.1),
			StrokeThickness = 0.1,
			BackgroundColor = Color3.fromRGB(255, 0, 0),
			TextColor = Color3.fromRGB(255, 255, 255),
			Font = Enum.Font.FredokaOne,
			AspectRatio = 3,
			Text = "Close",
			OnClick = function()
				UICharms.CanAwardDaily(false)
			end,
		}),
	})
end

return DailyRewardUI
