local StarterPlayer = game:GetService("StarterPlayer")
local GUIRemotes = require(StarterPlayer.StarterPlayerScripts.Client.ClientRemotes.ClientRemotesLogic.GUIRemotes)
local InputRemotes = require(StarterPlayer.StarterPlayerScripts.Client.ClientRemotes.ClientRemotesLogic.InputRemotes)
require(StarterPlayer.StarterPlayerScripts.Client.ClientRemotes.ClientRemotesLogic.SoundRemotes)

local ClientRemotesHandler = {}

function ClientRemotesHandler.Handle()
	InputRemotes:Initialize()
	GUIRemotes.Handle()
end

return ClientRemotesHandler
