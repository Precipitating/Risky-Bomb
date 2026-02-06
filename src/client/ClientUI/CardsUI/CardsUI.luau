local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local CardsFunctions = require(script.Parent.CardsFunctions)
local ModularImageLabelUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularImageLabelUI)
local ModularTextLabelUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextLabelUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRipple = require(ReplicatedStorage.Packages.ReactRipple)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local BombGameCharms = require(ReplicatedStorage.Charms.BombGameCharms)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)

local e = React.createElement

type CardsUIProps = {
	StrokeColor: Color3?,
	AnchorPoint: Vector2?,
	IsOpen: boolean,
	SetIsOpen: (boolean) -> (),
}

local function IsYourTurn()
	return ReactCharm.useAtom(BombGameCharms.BombInputVisible)
end
local function CardData()
	return ReactCharm.useAtom(BombGameCharms.CurrentCard)
end
local function CardActivated()
	return ReactCharm.useAtom(BombGameCharms.CardUsed)
end

local function CardsUI(props: CardsUIProps)
	local isYourTurn = IsYourTurn()
	local cardUsed = CardActivated()
	local cardData = CardData()
	local binding, spring = ReactRipple.useSpring(1, ReactRipple.config.figmaQuick)
	local debounce = false

	if not isYourTurn or cardUsed then
		return nil
	end

	return e("ImageButton", {
		Position = UDim2.fromScale(0.99, 0.5),
		Size = binding:map(function(s)
			return UDim2.fromScale(0.5 * s, 0.6 * s)
		end),
		Visible = isYourTurn or not cardUsed,
		AnchorPoint = Vector2.new(1, 0.5),

		[React.Change.GuiState] = function(rbx: ImageButton)
			if rbx.GuiState == Enum.GuiState.Hover then
				spring:setGoal(1.1)
			elseif rbx.GuiState == Enum.GuiState.Press then
				SoundManager.PlayExistingSound(SoundManager.UISounds.CardUse)
				spring:setGoal(0.50, { impulse = -10 })
				task.delay(0.1, function()
					if debounce then
						return
					end
					debounce = true
					CardsFunctions.CardActivated = true
					CardsFunctions:UseCard()
					BombGameCharms.CardUsed(true)
					spring:setGoal(1)
					debounce = false
				end)
			else
				spring:setGoal(1)
			end
		end,
	}, {
		AspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 0.6,
		}),
		Stroke = e("UIStroke", {
			Thickness = 3,
			Color = props.StrokeColor,
		}),
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.1, 0),
		}),

		Gradient = e("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("FF8F8F")),
				ColorSequenceKeypoint.new(0.25, Color3.fromHex("FF6B6B")),
				ColorSequenceKeypoint.new(0.5, Color3.fromHex("FF3B3B")),
				ColorSequenceKeypoint.new(0.7, Color3.fromHex("C02626")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("8A1010")),
			}),
			Rotation = -90,
		}),

		Title = ModularTextLabelUI({
			Position = UDim2.fromScale(0.5, 0.05),
			BackgroundTransparency = 1,
			TextColor = Color3.fromHex("FFF1F2"),
			Font = Enum.Font.Fantasy,
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.fromScale(0.9, 0.1),
			Text = cardData.Name or "???",
		}),

		ImageFrame = e("Frame", {
			Position = UDim2.fromScale(0.5, 0.16),
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.fromScale(0.9, 0.53),
			BackgroundTransparency = 1,
		}, {
			Image = ModularImageLabelUI(
				{
					Position = UDim2.fromScale(0.5, 0.05),
					AnchorPoint = Vector2.new(0.5, 0),
					Size = UDim2.fromScale(0.9, 0.9),

					BackgroundTransparency = 1,
					AspectRatio = 1,
					ScaleType = Enum.ScaleType.Crop,
					ImageID = cardData.ImageID or "",
					CornerRadius = 0.5,
				},
				e("UIStroke", {
					Thickness = 2,
					Color = Color3.fromRGB(255, 255, 255),
					Transparency = 0.5,
				})
			),
		}),

		TitleLine = e("Frame", {
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.15),
			Size = UDim2.fromScale(0.9, 0.01),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("7F1D1D"),
			BackgroundTransparency = 0.3,
		}),

		ImageLine = e("Frame", {
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.7),
			Size = UDim2.fromScale(0.9, 0.01),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromHex("7F1D1D"),
			BackgroundTransparency = 0.3,
		}),

		Description = ModularTextLabelUI({
			Position = UDim2.fromScale(0.05, 0.8),
			BackgroundTransparency = 1,
			TextColor = Color3.fromHex("FFF1F2"),
			Font = Enum.Font.Fantasy,
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromScale(0.9, 0.2),
			Text = cardData.Description or "???",
		}),
	})
end

return CardsUI
