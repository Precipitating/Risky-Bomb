local StarterPlayer = game:GetService("StarterPlayer")
local GUIRemotes = require(StarterPlayer.StarterPlayerScripts.Client.ClientRemotesLogic.GUIRemotes)
local InputRemotes = require(StarterPlayer.StarterPlayerScripts.Client.ClientRemotesLogic.InputRemotes)
local ClientRemotesHandler = {}

function ClientRemotesHandler.Handle()
	InputRemotes.Handle()
	GUIRemotes.Handle()
end

return ClientRemotesHandler
