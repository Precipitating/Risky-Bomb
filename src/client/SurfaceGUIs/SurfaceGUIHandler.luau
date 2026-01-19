local MarketplaceService = game:GetService("MarketplaceService")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local UtilityModule = require(ReplicatedStorage.Utility.UtilityModule)
local SurfaceGUIHandler = {}

local DonationDevProducts = {
	["100"] = 3516890199,
	["250"] = 3516890198,
	["500"] = 3516890200,
	["750"] = 3516890201,
	["1000"] = 3516890202,
	["10000"] = 3516891247,
	["25000"] = 3516902698,
}

function SurfaceGUIHandler.ConnectDonationButtons()
	local location =
		UtilityModule.Get(workspace, "Leaderboards", "DonateGui", "SurfaceGui", "MainFrame", "ScrollingFrame")

	for _, object: TextButton in ipairs(location:GetChildren()) do
		if not object:IsA("TextButton") then
			continue
		end

		object.Activated:Connect(function()
			MarketplaceService:PromptProductPurchase(PlayerContext.Player, DonationDevProducts[object.Name])
		end)
	end
end

function SurfaceGUIHandler:Initialize()
	SurfaceGUIHandler.ConnectDonationButtons()
end

return SurfaceGUIHandler
