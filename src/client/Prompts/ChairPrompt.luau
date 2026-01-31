local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local StarterPlayer = game:GetService("StarterPlayer")
local Networker = require(ReplicatedStorage.Packages.Networker).client
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)

local ChairPrompt = {}
-- ChairPrompt.networker = Networker.new("ChairRemotes", ChairPrompt)

local function GetSeat(prompt)
	local seat: Seat? = prompt:FindFirstAncestorOfClass("Seat")
	if not seat then
		return nil
	end

	return seat
end

local function CanSitOn(seat: Seat)
	if not seat then
		print("Seat not found!")
		return false
	end
	if seat.Occupant then
		print("Already occupied!")
		return false
	end

	return true
end

local function PromptVisibilityConnection(prompt: ProximityPrompt, seat: Seat)
	if not CollectionService:HasTag(prompt, "Set") then
		print("Seat connected!")
		seat:GetPropertyChangedSignal("Occupant"):Connect(function()
			local seatHumanoid = seat.Occupant
			if seatHumanoid then
				prompt.Enabled = false
				SoundManager.PlayExistingSound(SoundManager.PromptSounds.ChairSit)
			else
				prompt.Enabled = true
				SoundManager.PlayExistingSound(SoundManager.PromptSounds.ChairLeave)
			end
		end)
		prompt:AddTag("Set")
	end
end

function ChairPrompt.Handle(prompt: ProximityPrompt)
	if not CollectionService:HasTag(prompt, "Chair") then
		return
	end
	if PlayerContext.Character.Humanoid.Health <= 0 then
		print(`Can't sit, player's dead!`)
		return
	end
	-- get seat & return if unsittable
	local seat = GetSeat(prompt)

	-- enable/disable prompt visibility if sat/unsat
	PromptVisibilityConnection(prompt, seat)

	-- handle edge cases
	if not CanSitOn(seat) then
		return
	end

	-- success
	seat:Sit(PlayerContext.Humanoid)
end

return ChairPrompt
