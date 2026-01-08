local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundManager = require(ReplicatedStorage.Shared.Sound.SoundManager)
local ClientRemotesHandler = require(script.ClientRemotesHandler)
local ProximityPromptHandler = require(script.ProximityPromptHandler)

local function ClientInit()
	ProximityPromptHandler.ClientProximityPrompts()
	ClientRemotesHandler.Handle()
	SoundManager.PlayTheme(SoundManager.GetRandomMainSound())
end

ClientInit()
