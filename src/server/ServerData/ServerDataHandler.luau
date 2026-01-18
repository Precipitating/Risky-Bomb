local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Rarity = require(ReplicatedStorage.Config.Rarity)
local DataTemplate = require(script.Parent.DataTemplate)
local DataService = require(ReplicatedStorage.Packages.DataService).server
local ServerDataHandler = {}

local Options = {
	template = DataTemplate,
	profileStoreIndex = "Testing",
	useMock = true,
	resetData = true,
}

function DataService:onPlayerInit(player: Player, data): ()
	print(player.Name .. " has initialized with data:", data)
	if data.firstJoin == true then
		data.firstJoin = false
		data.currency = 999999
		data.chairEquipped = { Name = "Default", Material = "SmoothPlastic", Color = "White" }
		data.bombEquipped = { Name = "Default", Material = "SmoothPlastic", Color = "White" }
		data.chairsOwned = {
			[1] = {
				Name = "Default",
				RarityChance = Rarity.Common,
				Material = "SmoothPlastic",
				Color = "White",
			},
		}
		data.bombsOwned = {
			[1] = {
				Name = "Default",
				RarityChance = Rarity.Common,
				Material = "SmoothPlastic",
				Color = "White",
			},
		}

		data.sessionJoinTime = os.time()
	end
end

function ServerDataHandler.Initialize()
	DataService:init(Options)
end

return ServerDataHandler
