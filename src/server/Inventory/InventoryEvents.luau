local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker).server

local InventoryEvents = {}

function InventoryEvents:EquipItem(
	player: Player,
	itemType: string,
	itemName: string,
	itemMaterial: Enum.Material,
	itemColor: BrickColor
)
	if itemType:lower():find("chair") then
		itemType = "chairEquipped"
	elseif itemType:lower():find("bomb") then
		itemType = "bombEquipped"
	else
		return false
	end

	DataService:update(player, { itemType }, function(currentType)
		return { Name = itemName, Material = itemMaterial, Color = itemColor }
	end)

	print(`Inventory updated for {player} to {itemName}, with material of {itemMaterial} and color {itemColor}`)
	print(DataService:get(player, itemType))
	return true
end

InventoryEvents.networker = Networker.new("InventoryRemotes", InventoryEvents, { InventoryEvents.EquipItem })
return InventoryEvents
