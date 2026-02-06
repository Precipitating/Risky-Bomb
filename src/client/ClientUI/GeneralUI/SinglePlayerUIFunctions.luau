local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local UICharms = require(ReplicatedStorage.Charms.UICharms)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local SinglePlayerButtonDebounce = false
local SinglePlayerUIFunctions = {}
SinglePlayerUIFunctions.networker = Networker.new("SingleplayerNetwork", SinglePlayerUIFunctions)

function SinglePlayerUIFunctions:ToggleButtonVisibility(enable: boolean)
	UICharms.SingleplayerButtonVisible(enable)
	print(`Singleplayer button visibility should be {enable}`)
end

function SinglePlayerUIFunctions:TrySinglePlayer()
	if SinglePlayerButtonDebounce then
		return
	end
	SinglePlayerButtonDebounce = true

	local id: string? = PlayerContext.Character:GetAttribute("ID")

	task.delay(1, function()
		SinglePlayerButtonDebounce = false
	end)

	if not id then
		return
	end
	if not PlayerContext.Humanoid.SeatPart then
		return
	end

	local success = self.networker:fetch("CanSinglePlayer", id)

	if not success then
		SoundManager.PlayExistingSound(SoundManager.UISounds.Error)
		return
	end

	UICharms.SingleplayerButtonVisible(false)
	print(id)

	self.networker:fire("StartSinglePlayer", id)
end

return SinglePlayerUIFunctions
