local ClientRemotesHandler = require(script.ClientRemotesHandler)
local ProximityPromptHandler = require(script.ProximityPromptHandler)

local function ClientInit()
	ProximityPromptHandler.ClientProximityPrompts()
	ClientRemotesHandler.Handle()
end

ClientInit()
