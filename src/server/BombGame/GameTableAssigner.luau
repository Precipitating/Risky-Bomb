local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService").Server
local Table = require(ServerScriptService.BombGame.Table)
local TableDictionary = {}
local GameTableAssigner = {}

function GameTableAssigner.GetTableFromID(id: string)
	if not TableDictionary[id] then
		error("Cannot get game table class from id specified")
	end

	return TableDictionary[id]
end

local function AssignConnections()
	-- for existing tables on studio
	for _, tableModel in pairs(workspace:FindFirstChild("Tables"):GetChildren()) do
		local tableData = Table.new(tableModel)
		tableModel:SetAttribute("ID", tableData.ID)
		TableDictionary[tableData.ID] = tableData
	end
	-- for newly spawned tables
	CollectionService:GetInstanceAddedSignal("GameTable"):Connect(function(tableModel)
		local tableData = Table.new(tableModel)
		tableModel:SetAttribute("ID", tableData.ID)
		TableDictionary[tableData.ID] = tableData
	end)

	CollectionService:GetInstanceRemovedSignal("GameTable"):Connect(function(destroyedTable)
		local destroyedTableID = destroyedTable:GetAttribute("ID")
		TableDictionary[destroyedTableID]:Cleanup()
		TableDictionary[destroyedTableID] = nil
	end)
end

function GameTableAssigner:Initialize()
	AssignConnections()
end

return GameTableAssigner
