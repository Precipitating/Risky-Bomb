local StarterPlayer = game:GetService("StarterPlayer")
local InputRemotes = require(StarterPlayer.StarterPlayerScripts.Client.ClientRemotesLogic.InputRemotes)
local ClientRemotesHandler = {}

function ClientRemotesHandler.Handle()
	InputRemotes.Handle()
end

return ClientRemotesHandler
