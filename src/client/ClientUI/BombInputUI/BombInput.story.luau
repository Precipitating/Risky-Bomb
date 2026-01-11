local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local BombInputScreenGUI = require(script.Parent.BombInputScreenGUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages["ReactRoblox"])
local e = React.createElement

return function(parent)
	local root = ReactRoblox.createRoot(parent)
	local app = e(BombInputScreenGUI)
	root:render(app)

	return function()
		root:unmount()
	end
end
