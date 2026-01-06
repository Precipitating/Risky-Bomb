local CollectionService = game:GetService("CollectionService")
local StarterPlayer = game:GetService("StarterPlayer")
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes

local ChairPrompt = {}

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

local function PromptVisibilityConnection(prompt: ProximityPrompt, seat: Seat, gameTable: Model?)
	if not gameTable then
		print("GameTable ref not found")
		return
	end

	if not CollectionService:HasTag(prompt, "Set") then
		print("Seat connected!")
		seat:GetPropertyChangedSignal("Occupant"):Connect(function()
			local seatHumanoid = seat.Occupant
			if seatHumanoid then
				prompt.Enabled = false
				Remotes.ChairSat:FireServer(gameTable, true)
			else
				prompt.Enabled = true
				Remotes.ChairSat:FireServer(gameTable, false)
			end
		end)
		prompt:AddTag("Set")
	end
end

function ChairPrompt.Handle(prompt: ProximityPrompt)
	if not CollectionService:HasTag(prompt, "Chair") then
		return
	end
	-- get seat & return if unsittable
	local seat = GetSeat(prompt)
	local chairModel = prompt:FindFirstAncestorOfClass("Model")
	local gameTable = chairModel:FindFirstAncestorOfClass("Model")
	-- enable/disable prompt visibility if sat/unsat
	PromptVisibilityConnection(prompt, seat, gameTable)

	-- handle edge cases
	if not CanSitOn(seat) then
		return
	end

	-- success
	seat:Sit(PlayerContext.Humanoid)
end

return ChairPrompt
