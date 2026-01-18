local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ChairPacksData = require(ReplicatedStorage.Config.ChairPacksData)
local BombPacksData = require(ReplicatedStorage.Config.BombPacksData)
local UtilityModule = require(ReplicatedStorage.Utility.UtilityModule)
local PackType = require(ReplicatedStorage.Types.PackType)
local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker).server
local InGamePurchases = {}

local function CanPlayerBuyCrates(player: Player)
	local success, result = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(player)
	end)
	if not success then
		return false
	end

	if result.ArePaidRandomItemsRestricted then
		return false
	end

	return true
end

local function IsAlreadyOwned(
	itemWon: string,
	materialRolled: Enum.Material,
	colorRolled: BrickColor,
	player: Player,
	dataKey: string
)
	local inventory = DataService:get(player, { dataKey })
	for _, ownedItemName in ipairs(inventory) do
		if
			ownedItemName.Name == itemWon
			and ownedItemName.Material == materialRolled
			and ownedItemName.Color == colorRolled
		then
			return true
		end
	end
	return false
end
function Roll(player: Player, dataKey: string, crateData)
	if not crateData then
		error("Crate data is wrong. Cannot roll")
		return
	end

	local totalWeight = 0
	for _, itemChance in pairs(crateData.ItemList) do
		totalWeight += itemChance
	end

	local roll = math.random() * totalWeight

	local cumulative = 0
	for name, itemChance in pairs(crateData.ItemList) do
		cumulative += itemChance
		if roll <= cumulative then
			local material = UtilityModule.GetRandomMaterial()
			local color = BrickColor.random()

			if not IsAlreadyOwned(name, material, color, player, dataKey) then
				print(`{player.Name} won... {name}`)
				DataService:arrayInsert(player, { dataKey }, {
					Name = name,
					RarityChance = itemChance,
					Material = material,
					Color = color,
				})
			else
				warn(`{player.Name} already owns this, refunding {crateData.AlreadyOwnedPayment}`)
				DataService:update(player, { "currency" }, function(currentCash)
					return currentCash + crateData.AlreadyOwnedPayment
				end)
			end

			return
		end
	end
end

local function BuyAndRoll(dataTable, objectOwnedKey: string, player: Player, playerCash: number, packName: string)
	if not dataTable[packName] then
		warn(`{packName} doesn't exist in table`)
		return false
	end
	local packCost = dataTable[packName].Cost

	if packCost > playerCash then
		warn(`{player.Name} can't afford pack!`)
		return false
	end
	-- can afford
	DataService:update(player, { "currency" }, function(currentCash)
		return currentCash - packCost
	end)
	Roll(player, objectOwnedKey, dataTable[packName])
	return true
end

function InGamePurchases:AttemptBuy(player: Player, packType: number, packName: string)
	-- if false, not allowed to buy due to country restrictions OR pcall failed.
	if not CanPlayerBuyCrates(player) then
		return false
	end
	print(packType)
	print(packName)
	local playerCash = DataService:get(player, { "currency" })
	local objectOwnedKey = nil

	local packTable = nil
	if packType == PackType.ChairPack then
		packTable = ChairPacksData
		objectOwnedKey = "chairsOwned"
	elseif packType == PackType.BombPack then
		packTable = BombPacksData
		objectOwnedKey = "bombsOwned"
	else
		error(`Failed to get {packType} table!`)
	end
	return BuyAndRoll(packTable, objectOwnedKey, player, playerCash, packName)
end

InGamePurchases.networker = Networker.new("InGamePurchaseRemotes", InGamePurchases, {
	InGamePurchases.AttemptBuy,
})

return InGamePurchases
