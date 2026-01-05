local RemoteHandler = require(script.RemoteHandler)
local UniqueIdAssigner = require(script.Utility.UniqueIdAssigner)

local function ServerInit()
	RemoteHandler.HandleRemotes()
	UniqueIdAssigner.AssignAll()
end

ServerInit()
