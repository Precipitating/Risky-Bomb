local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker).server

local InventoryEvents = {}

function InventoryEvents:EquipItem(player: Player, itemType: string, itemName: string)
	if itemType:lower():find("chair") then
		itemType = "chairEquipped"
	elseif itemType:lower():find("bomb") then
		itemType = "bombEquipped"
	else
		return false
	end

	DataService:update(player, { itemType }, function(currentType)
		if currentType ~= itemName then
			return itemName
		end
		print(`{player.Name} Already equipped {itemName} ignoring.`)
		return currentType
	end)

	print(`Inventory updated for {player} to {itemName}`)
	return true
end

InventoryEvents.networker = Networker.new("InventoryRemotes", InventoryEvents, { InventoryEvents.EquipItem })
return InventoryEvents
