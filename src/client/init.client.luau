local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local StarterGui = game:GetService("StarterGui")
local ClientDataHandler = require(script.ClientData.ClientDataHandler)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local ClientRemotesHandler = require(script.ClientRemotes.ClientRemotesHandler)
local GUIRemotes = require(script.ClientRemotes.ClientRemotesLogic.GUIRemotes)
require(script.ClientRemotes.ClientRemotesLogic.SoundRemotes)
local MountUI = require(script.ClientUI.MountUI)
local ProximityPromptHandler = require(script.Prompts.ProximityPromptHandler)
local SurfaceGUIHandler = require(script.SurfaceGUIs.SurfaceGUIHandler)

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
	SurfaceGUIHandler:Initialize()
	MountUI()
	GUIRemotes:SetLastDonationMessage()
end

ClientInit()
