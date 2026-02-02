local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local BombInputScreenGUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.BombInputUI.BombInputScreenGUI)
local CardsUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.CardsUI.CardsUI)
local DailyRewardUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.DailyRewardUI.DailyRewardUI)
local GeneralScreenGUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.GeneralUI.GeneralScreenGUI)
local ToolTipUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.GeneralUI.HoverDisplay.ToolTipUI)
local MessageBarUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.GlobalMessageBar.MessageBarUI)
local JumpscareScreenGUI = require(script.Parent.JumpscareGUI.JumpscareScreenGUI)

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages["ReactRoblox"])

local function CreateScreenGUI(name: string, uiRoot)
	local player = Players.LocalPlayer
	local playerGUI = player:WaitForChild("PlayerGui")
	local container = Instance.new("ScreenGui")
	container.Name = name
	container.IgnoreGuiInset = true
	container.ResetOnSpawn = false
	container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	container.ClipToDeviceSafeArea = false
	container.Parent = playerGUI
	local root = ReactRoblox.createRoot(container)
	local app = React.createElement(uiRoot)
	root:render(app)
end

return function()
	CreateScreenGUI("JumpscareGUI", JumpscareScreenGUI)
	CreateScreenGUI("BombInputGUI", BombInputScreenGUI)
	CreateScreenGUI("GeneralGUI", GeneralScreenGUI)
	CreateScreenGUI("GlobalMessageBar", MessageBarUI)
	CreateScreenGUI("ToolTipGUI", ToolTipUI)
	CreateScreenGUI("DailyRewards", DailyRewardUI)
	CreateScreenGUI("CardsGUI", CardsUI)
end
