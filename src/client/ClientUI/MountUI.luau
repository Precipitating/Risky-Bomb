local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared

local RootUI = require(script.Parent.RootUI)
local React = require(ReplicatedStorage.Packages.react)
local ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])

return function()
	local player = Players.LocalPlayer
	local playerGUI = player:WaitForChild("PlayerGui")
	local container = Instance.new("ScreenGui")
	container.Name = "React"
	container.IgnoreGuiInset = true
	container.ResetOnSpawn = false
	container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	container.ClipToDeviceSafeArea = false
	container.Parent = playerGUI
	local root = ReactRoblox.createRoot(container)
	local app = React.createElement(RootUI)
	root:render(app)
end
