local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local InventoryFrameUI =
	require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.GeneralUI.Inventory.InventoryFrameUI)
local GeneralCashUI = require(script.Parent.GeneralCashUI)
local GeneralImageButtonUI = require(script.Parent.GeneralImageButtonUI)
local ShopFrameUI = require(script.Parent.Shop.ShopFrameUI)
local React = require(ReplicatedStorage.Packages.React)
local BombGameCharms = require(ReplicatedStorage.Charms.BombGameCharms)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)

local e = React.createElement

local function BombInputScreenGUI()
	local shopOpen, setShopOpen = React.useState(true)
	local inventoryOpen, setInventoryOpen = React.useState(false)
	return e(React.Fragment, nil, {
		ShopButton = GeneralImageButtonUI({
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(0.2, 0.2),
			AspectRatio = 1,
			ImageID = "rbxassetid://124449779482452",
			AnchorPoint = Vector2.new(0, 0.5),
			OnClick = function()
				if inventoryOpen then
					setInventoryOpen(false)
				end
				setShopOpen(not shopOpen)
			end,
		}),
		InventoryButton = GeneralImageButtonUI({
			Position = UDim2.fromScale(0, 0.7),
			Size = UDim2.fromScale(0.2, 0.2),
			AspectRatio = 1,
			ImageID = "rbxassetid://93355381110569",
			AnchorPoint = Vector2.new(0, 0.5),
			OnClick = function()
				if shopOpen then
					setShopOpen(false)
				end
				setInventoryOpen(not inventoryOpen)
			end,
		}),
		Cash = GeneralCashUI({
			Position = UDim2.fromScale(0.005, 0.9),
			Size = UDim2.fromScale(0.1, 0.1),
			AnchorPoint = Vector2.new(0, 0.5),
			ImageID = "rbxassetid://129785989512283",
			AspectRatio = 1,
		}),
		Shop = ShopFrameUI({
			Position = UDim2.fromScale(0.3, 0.55),
			Size = UDim2.fromScale(0.8, 0.8),
			AnchorPoint = Vector2.new(0, 0.5),
			StrokeColor = Color3.fromRGB(0, 0, 0),
			AspectRatio = 1,
			IsOpen = shopOpen,
			SetIsOpen = setShopOpen,
		}),
		Inventory = InventoryFrameUI({
			Position = UDim2.fromScale(0.3, 0.55),
			Size = UDim2.fromScale(0.8, 0.8),
			AnchorPoint = Vector2.new(0, 0.5),
			StrokeColor = Color3.fromRGB(0, 0, 0),
			AspectRatio = 1,
			IsOpen = inventoryOpen,
			SetIsOpen = setInventoryOpen,
		}),
	})
end

return BombInputScreenGUI
