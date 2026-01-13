local DataTemplate = require(script.Parent.DataTemplate)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local DataService = require(ReplicatedStorage.Packages.DataService).server
local ServerDataHandler = {}

local Options = {
	template = DataTemplate,
	profileStoreIndex = "Testing",
	useMock = true,
}

function DataService:onPlayerInit(player: Player, data): ()
	print(player.Name .. " has initialized with data:", data)
	if data.firstJoin == true then
		data.firstJoin = false
		data.currency = 0
	end
	data.sessionJoinTime = os.time()
end

function ServerDataHandler.Initialize()
	DataService:init(Options)
end

return ServerDataHandler
