local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local JumpscareScreenGUI = require(script.Parent.JumpscareScreenGUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages["ReactRoblox"])
local e = React.createElement

return function(parent)
	local root = ReactRoblox.createRoot(parent)
	local app = e(JumpscareScreenGUI)
	root:render(app)

	return function()
		root:unmount()
	end
end
