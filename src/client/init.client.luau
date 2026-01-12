local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local SoundManager = require(ReplicatedStorage.Shared.Sound.SoundManager)
local ClientRemotesHandler = require(script.ClientRemotes.ClientRemotesHandler)
local MountUI = require(script.ClientUI.MountUI)
local ProximityPromptHandler = require(script.Prompts.ProximityPromptHandler)

local function DisableRespawn()
	repeat
		local disabled = pcall(function()
			StarterGui:SetCore("ResetButtonCallback", false)
		end)
		task.wait(1)
	until disabled
end

local function ClientInit()
	DisableRespawn()
	ProximityPromptHandler.ClientProximityPrompts()
	ClientRemotesHandler.Handle()
	SoundManager.Initialize()

	MountUI()
end

ClientInit()
