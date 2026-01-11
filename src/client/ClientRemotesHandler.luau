local StarterPlayer = game:GetService("StarterPlayer")
local GUIRemotes = require(StarterPlayer.StarterPlayerScripts.Client.ClientRemotesLogic.GUIRemotes)
local InputRemotes = require(StarterPlayer.StarterPlayerScripts.Client.ClientRemotesLogic.InputRemotes)
local SoundRemotes = require(StarterPlayer.StarterPlayerScripts.Client.ClientRemotesLogic.SoundRemotes)

local ClientRemotesHandler = {}

function ClientRemotesHandler.Handle()
	InputRemotes.Handle()
	GUIRemotes.Handle()
	SoundRemotes.Handle()
end

return ClientRemotesHandler
