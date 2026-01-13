local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local StarterGui = game:GetService("StarterGui")
local ClientDataHandler = require(script.ClientData.ClientDataHandler)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
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
	ClientDataHandler.Initialize()
	DisableRespawn()
	ProximityPromptHandler.ClientProximityPrompts()
	ClientRemotesHandler.Handle()
	SoundManager.Initialize()

	MountUI()
end

ClientInit()
