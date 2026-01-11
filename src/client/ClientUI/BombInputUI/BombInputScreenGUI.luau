local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local BombCountdownFrame = require(script.Parent.BombCountdownFrame)
local BombTextButton = require(script.Parent.BombTextButton)
local BombTextFrame = require(script.Parent.BombTextFrame)
local React = require(ReplicatedStorage.Packages.React)
local Remotes = ReplicatedStorage.Remotes
local BombGameCharms = require(ReplicatedStorage.Charms.BombGameCharms)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local BombConfig = require(ReplicatedStorage.Config.BombConfig)

local e = React.createElement

local BombInputUITheme = {
	BackgroundColor = Color3.fromRGB(0, 0, 0),
	StrokeColor = Color3.fromRGB(255, 255, 255),
}
local function IsYourTurn()
	return ReactCharm.useAtom(BombGameCharms.BombInputVisible)
end

local function CountdownValue()
	return ReactCharm.useAtom(BombGameCharms.BombInputTimeLeft)
end

local function CurrentInput()
	return ReactCharm.useAtom(BombGameCharms.CurrentBombInput)
end

local function SetCurrentInput(val: number)
	BombGameCharms.CurrentBombInput(math.max(1, val))
end
local function BombInputScreenGUI()
	local isVisible = IsYourTurn()
	local currentInput = CurrentInput()
	local countdownValue = CountdownValue()

	if not isVisible then
		return nil
	end

	return e(React.Fragment, nil, {
		Title = e(BombTextFrame, {
			Position = UDim2.fromScale(0.5, 0.7),
			Size = UDim2.fromScale(0.3, 0.076),
			BackgroundColor = BombInputUITheme.BackgroundColor,
			StrokeColor = BombInputUITheme.StrokeColor,
			Visible = isVisible,
			Text = "SHAVE OFF BOMB TIME (s)",
			Font = Enum.Font.AmaticSC,
			FontColor = Color3.new(1, 1, 1),
			AspectRatio = 5,
			AnchorPoint = Vector2.new(0.5, 0.5),
		}),
		InputFrame = e(BombTextFrame, {
			Position = UDim2.fromScale(0.5, 0.76),
			Size = UDim2.fromScale(0.1, 0.144),
			BackgroundColor = BombInputUITheme.BackgroundColor,
			StrokeColor = BombInputUITheme.StrokeColor,
			Visible = isVisible,
			Text = tostring(currentInput),
			Font = Enum.Font.SourceSansBold,
			FontColor = Color3.new(1, 0, 0),
			AspectRatio = 1,
			AnchorPoint = Vector2.new(0.5, 0),
		}),

		DecrementOneFrame = e(BombTextButton, {
			Position = UDim2.fromScale(0.43, 0.83),
			Size = UDim2.fromScale(0.065, 0.144),
			BackgroundColor = BombInputUITheme.BackgroundColor,
			StrokeColor = BombInputUITheme.StrokeColor,
			Visible = isVisible,
			Text = "-1",
			Font = Enum.Font.SourceSansBold,
			FontColor = Color3.new(1, 1, 1),
			AspectRatio = 1.5,
			AnchorPoint = Vector2.new(1, 0.5),
			ButtonClickedFunc = function()
				SetCurrentInput(currentInput - 1)
			end,
		}),
		DecrementFiveFrame = e(BombTextButton, {
			Position = UDim2.fromScale(0.35, 0.83),
			Size = UDim2.fromScale(0.065, 0.144),
			BackgroundColor = BombInputUITheme.BackgroundColor,
			StrokeColor = BombInputUITheme.StrokeColor,
			Visible = isVisible,
			Text = "-5",
			Font = Enum.Font.SourceSansBold,
			FontColor = Color3.new(1, 1, 1),
			AspectRatio = 1.5,
			AnchorPoint = Vector2.new(1, 0.5),
			ButtonClickedFunc = function()
				SetCurrentInput(currentInput - 5)
			end,
		}),
		IncrementOneFrame = e(BombTextButton, {
			Position = UDim2.fromScale(0.57, 0.83),
			Size = UDim2.fromScale(0.065, 0.144),
			BackgroundColor = BombInputUITheme.BackgroundColor,
			StrokeColor = BombInputUITheme.StrokeColor,
			Visible = isVisible,
			Text = "+1",
			Font = Enum.Font.SourceSansBold,
			FontColor = Color3.new(1, 1, 1),
			AspectRatio = 1.5,
			AnchorPoint = Vector2.new(0, 0.5),
			ButtonClickedFunc = function()
				SetCurrentInput(currentInput + 1)
			end,
		}),
		IncrementFiveFrame = e(BombTextButton, {
			Position = UDim2.fromScale(0.65, 0.83),
			Size = UDim2.fromScale(0.065, 0.144),
			BackgroundColor = BombInputUITheme.BackgroundColor,
			StrokeColor = BombInputUITheme.StrokeColor,
			Visible = isVisible,
			Text = "+5",
			Font = Enum.Font.SourceSansBold,
			FontColor = Color3.new(1, 1, 1),
			AspectRatio = 1.5,
			AnchorPoint = Vector2.new(0, 0.5),
			ButtonClickedFunc = function()
				SetCurrentInput(currentInput + 5)
			end,
		}),
		CountdownBar = e(BombCountdownFrame, {
			Position = UDim2.fromScale(0.4, 0.645),
			Size = UDim2.fromScale((0.2 * countdownValue) / BombConfig.MAX_TURN_TIME, 0.005),
			StrokeColor = Color3.fromRGB(255, 255, 255),
			BackgroundColor = Color3.fromRGB(255, 0, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			CurrentCountdownTime = countdownValue,
			Visible = isVisible and countdownValue > 0,
		}),

		SubmitButton = e(BombTextButton, {
			Position = UDim2.fromScale(0.5, 0.955),
			Size = UDim2.fromScale(0.1, 0.144),
			BackgroundColor = BombInputUITheme.BackgroundColor,
			StrokeColor = BombInputUITheme.StrokeColor,
			Visible = isVisible,
			Text = "SUBMIT",
			Font = Enum.Font.SourceSansBold,
			FontColor = Color3.new(1, 1, 1),
			AspectRatio = 3,
			AnchorPoint = Vector2.new(0.5, 0.5),
			ButtonClickedFunc = function()
				Remotes.SubmitBombReduction:FireServer(
					PlayerContext.Character:GetAttribute("AssignedTable"),
					currentInput
				)
				SetCurrentInput(1)
			end,
		}),
	})
end

return BombInputScreenGUI
