local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local UICharms = require(ReplicatedStorage.Charms.UICharms)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local SinglePlayerUIFunctions = {}
SinglePlayerUIFunctions.networker = Networker.new("SingleplayerNetwork", SinglePlayerUIFunctions)

function SinglePlayerUIFunctions:ToggleButtonVisibility(enable: boolean)
	UICharms.SingleplayerButtonVisible(enable)
	print(`Singleplayer button visibility should be {enable}`)
end

function SinglePlayerUIFunctions:TrySinglePlayer()
	local success = self.networker:fetch("CanSinglePlayer", PlayerContext.Character:GetAttribute("ID"))

	if not success then
		SoundManager.PlayExistingSound(SoundManager.UISounds.Error)
		return
	end

	UICharms.SingleplayerButtonVisible(false)
	self.networker:fire("StartSinglePlayer", PlayerContext.Character:GetAttribute("ID"))
end

return SinglePlayerUIFunctions
