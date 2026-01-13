local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local GeneralCashUI = require(script.Parent.GeneralCashUI)
local GeneralImageButtonUI = require(script.Parent.GeneralImageButtonUI)
local React = require(ReplicatedStorage.Packages.React)
local BombGameCharms = require(ReplicatedStorage.Charms.BombGameCharms)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)

local e = React.createElement

local function BombInputScreenGUI()
	return e(React.Fragment, nil, {
		ShopButton = GeneralImageButtonUI({
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.2, 0.2),
			AspectRatio = 1,
			ImageID = "rbxassetid://124449779482452",
			AnchorPoint = Vector2.new(0, 0.5),
			OnClick = function() end,
		}),
		Inventory = GeneralImageButtonUI({
			Position = UDim2.fromScale(0, 0.7),
			Size = UDim2.fromScale(0.2, 0.2),
			AspectRatio = 1,
			ImageID = "rbxassetid://93355381110569",
			AnchorPoint = Vector2.new(0, 0.5),
			OnClick = function() end,
		}),
		Cash = GeneralCashUI({
			Position = UDim2.fromScale(0.005, 0.9),
			Size = UDim2.fromScale(0.1, 0.1),
			AnchorPoint = Vector2.new(0, 0.5),
			ImageID = "rbxassetid://129785989512283",
			AspectRatio = 1,
		}),
	})
end

return BombInputScreenGUI
