local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local CardsUI = require(script.Parent.CardsUI)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages["ReactRoblox"])
local e = React.createElement

return function(parent)
	local root = ReactRoblox.createRoot(parent)
	local app = e(CardsUI)
	root:render(app)

	return function()
		root:unmount()
	end
end
