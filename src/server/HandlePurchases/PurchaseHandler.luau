local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataService = require(ReplicatedStorage.Shared.Packages.DataService).server
local JumpscareHandler = require(script.Parent.JumpscareHandler)
local PurchaseHistory = DataStoreService:GetDataStore("PurchaseHistory")

local ProductFunctions = {}

local PurchaseHandler = {}

-- jumpscare
ProductFunctions[3507139396] = function(receipt, player)
	return JumpscareHandler:JumpscarePurchased(player)
end

-- currency
ProductFunctions[3512408744] = function(receipt, player)
	DataService:update(player, { "currency" }, function(currentCash)
		return currentCash + 1000
	end)
	return true
end
ProductFunctions[3512408743] = function(receipt, player)
	DataService:update(player, { "currency" }, function(currentCash)
		return currentCash + 2500
	end)
	return true
end
ProductFunctions[3512408742] = function(receipt, player)
	DataService:update(player, { "currency" }, function(currentCash)
		return currentCash + 5250
	end)
	return true
end
ProductFunctions[3512408741] = function(receipt, player)
	DataService:update(player, { "currency" }, function(currentCash)
		return currentCash + 11500
	end)

	return true
end
local function ProcessReceipt(receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId
	local purchased = false
	local playerProductKey = `{userId}_{receiptInfo.PurchaseId}`
	local player = Players:GetPlayerByUserId(userId)
	local success, errorMsg = pcall(function()
		purchased = PurchaseHistory:GetAsync(playerProductKey)
	end)

	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		JumpscareHandler.JumpscarePurchaseFailed(player, productId)
		error(`Purchase failed {errorMsg}`)
	end

	-- check if already purchased
	local success, isPurchaseRecorded = pcall(function()
		return PurchaseHistory:UpdateAsync(playerProductKey, function(alreadyPurchased)
			if alreadyPurchased then
				return true
			end

			if player then
				local handler = ProductFunctions[productId]
				local success, result = pcall(handler, receiptInfo, player)
				if not success or not result then
					JumpscareHandler.JumpscarePurchaseFailed(player, productId)
					error(`Purchased failed {receiptInfo.ProductId}`)
				end
			end

			return true
		end)
	end)

	if not success then
		JumpscareHandler.JumpscarePurchaseFailed(player, productId)
		error(`Purchase datastore failed`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	elseif isPurchaseRecorded == nil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

MarketplaceService.ProcessReceipt = ProcessReceipt
return PurchaseHandler
