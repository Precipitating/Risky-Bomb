local ProximityPromptService = game:GetService("ProximityPromptService")
local StarterPlayer = game:GetService("StarterPlayer")
local ChairPrompt = require(StarterPlayer.StarterPlayerScripts.Client.Prompts.ChairPrompt)

local ProximityPromptHandler = {}

function ProximityPromptHandler.ClientProximityPrompts()
	ProximityPromptService.PromptTriggered:Connect(function(prompt, _)
		ChairPrompt.Handle(prompt)
	end)
end

return ProximityPromptHandler
