local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local CommonUIFunctions =
	require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.GeneralUI.CommonUIFunctions.CommonUIFunctions)
local InventoryFrameUI =
	require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.GeneralUI.Inventory.InventoryFrameUI)
local ModularTextButtonUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextButtonUI)
local GeneralCashUI = require(script.Parent.GeneralCashUI)
local GeneralImageButtonUI = require(script.Parent.GeneralImageButtonUI)
local ShopFrameUI = require(script.Parent.Shop.ShopFrameUI)
local SinglePlayerUIFunctions = require(script.Parent.SinglePlayerUIFunctions)
local React = require(ReplicatedStorage.Packages.React)
local ReactCharm = require(ReplicatedStorage.Packages.ReactCharm)
local UICharms = require(ReplicatedStorage.Charms.UICharms)

local e = React.createElement

local function SingleplayerButtonVisible()
	return ReactCharm.useAtom(UICharms.SingleplayerButtonVisible)
end

local function GeneralScreenGUI()
	local shopOpen, setShopOpen = React.useState(false)
	local inventoryOpen, setInventoryOpen = React.useState(false)
	local lootTableOpen, setLootTableOpen = React.useState(false)
	local singlePlayerButtonVisible = SingleplayerButtonVisible()

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
				if lootTableOpen then
					setLootTableOpen(false)
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
				if lootTableOpen then
					setLootTableOpen(false)
				end
				setInventoryOpen(not inventoryOpen)
			end,
		}),
		InviteFriendsButton = GeneralImageButtonUI({
			Position = UDim2.fromScale(0.01, 0.3),
			Size = UDim2.fromScale(0.2, 0.2),
			AspectRatio = 0.8,
			ImageID = "rbxassetid://116545774107407",
			AnchorPoint = Vector2.new(0, 0.5),
			OnClick = function()
				CommonUIFunctions.InviteFriends()
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
			LootTableOpen = lootTableOpen,
			SetLootTableOpen = setLootTableOpen,
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

		SinglePlayerButton = ModularTextButtonUI({
			Text = "SINGLEPLAYER MODE",
			Font = Enum.Font.FredokaOne,
			TextColor = Color3.fromRGB(255, 255, 255),
			BackgroundColor = Color3.fromRGB(255, 0, 0),
			Position = UDim2.fromScale(0.98, 0.8),
			Size = UDim2.fromScale(0.2, 0.2),
			StrokeThickness = 0.1,
			AnchorPoint = Vector2.new(1, 1),
			StrokeColor = Color3.fromRGB(0, 0, 0),
			AspectRatio = 3,
			isOpen = singlePlayerButtonVisible,

			OnClick = function()
				SinglePlayerUIFunctions:TrySinglePlayer()
			end,
		}),
	})
end

return GeneralScreenGUI
