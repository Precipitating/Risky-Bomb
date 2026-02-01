local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local VIPHandler = require(ReplicatedStorage.VIP.VIPHandler)
local UtilityModule = require(ReplicatedStorage.Utility.UtilityModule)
local PackType = require(ReplicatedStorage.Types.PackType)
local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker).server
local DISCOUNT_MULTIPLIER: number = 0.2
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

local function IsAlreadyOwned(itemWon, player: Player, dataKey: string)
	local inventory = DataService:get(player, { dataKey })

	for _, ownedItemName in ipairs(inventory) do
		print(
			`{itemWon.Name} -> {ownedItemName.Name}, {itemWon.Material} -> {ownedItemName.Material}, {itemWon.Color} -> {ownedItemName.Color}`
		)
		if
			itemWon.Name == ownedItemName.Name
			and itemWon.Material == ownedItemName.Material
			and itemWon.Color == ownedItemName.Color
		then
			return true
		end
	end
	return false
end

function Roll(player: Player, dataKey: string, packData)
	if not packData then
		error("Crate data is wrong. Cannot roll")
		return
	end

	local isDuplicate = false

	local randomItemFromPack = UtilityModule.GetRandomPackItem(packData)

	print(
		`Item Chosen: {randomItemFromPack.Name} with material {randomItemFromPack.Material} and color {randomItemFromPack.Color}`
	)

	if not IsAlreadyOwned(randomItemFromPack, player, dataKey) then
		print(
			`{player.Name} won... {randomItemFromPack.Name} with material {randomItemFromPack.Material} and color {randomItemFromPack.Color}`
		)
		DataService:arrayInsert(player, { dataKey }, randomItemFromPack)
	else
		-- duplicate, cashback
		warn(`{player.Name} already owns this, refunding {packData.AlreadyOwnedPayment}`)
		DataService:update(player, { "currency" }, function(currentCash)
			return currentCash + packData.AlreadyOwnedPayment
		end)
		isDuplicate = true
	end

	return isDuplicate, randomItemFromPack
end

function InGamePurchases.AttemptToApplyDiscount(player: Player, packTable: { ItemsList: {}, Cost: number })
	local inputPrice = packTable.Cost
	if VIPHandler.IsVIP(player) then
		inputPrice -= (packTable.Cost * DISCOUNT_MULTIPLIER)
	end

	return inputPrice
end

local function BuyAndRoll(packTable, objectOwnedKey: string, player: Player, playerCash: number)
	if not packTable then
		warn(`pack list is nil, check AttemptBuy args`)
		return false
	end

	local packCost = InGamePurchases.AttemptToApplyDiscount(player, packTable)

	if packCost > playerCash then
		warn(`{player.Name} can't afford pack!`)
		return false
	end
	-- can afford
	DataService:update(player, { "currency" }, function(currentCash)
		return currentCash - packCost
	end)
	return Roll(player, objectOwnedKey, packTable)
end

local function GetItemsOwnedDatastoreKey(packType: number)
	if packType == PackType.ChairPack then
		return "chairsOwned"
	elseif packType == PackType.BombPack then
		return "bombsOwned"
	else
		error(`Failed to get {packType} key1`)
	end
end

function InGamePurchases:AttemptBuy(player: Player, packType: number, packName: string)
	-- if false, not allowed to buy due to country restrictions OR pcall failed.
	if not CanPlayerBuyCrates(player) then
		return false
	end
	print(`Attempting to buy a {packType} of name {packName}...`)

	local playerCash = DataService:get(player, { "currency" })

	local objectOwnedKey = GetItemsOwnedDatastoreKey(packType)

	local packTable = UtilityModule.GetPackList(packType, packName)

	return BuyAndRoll(packTable, objectOwnedKey, player, playerCash)
end

InGamePurchases.networker = Networker.new("InGamePurchaseRemotes", InGamePurchases, {
	InGamePurchases.AttemptBuy,
})

return InGamePurchases
