local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local JumpscareHandler = require(script.Parent.JumpscareHandler)
local PurchaseHistory = DataStoreService:GetDataStore("PurchaseHistory")
local ProductFunctions = {}

local PurchaseHandler = {}

-- jumpscare
ProductFunctions[3507139396] = function(receipt, player)
	return JumpscareHandler:JumpscarePurchased(player)
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
		error(`Purchase failed! {errorMsg}`)
	end

	local success, isPurchaseRecorded = pcall(function()
		return PurchaseHistory:UpdateAsync(playerProductKey, function(alreadyPurchased)
			if alreadyPurchased then
				return true
			end

			if player then
				local handler = ProductFunctions[productId]
				local success, result = pcall(handler, receiptInfo, player)
				if not success or not result then
					warn(`Purchased unsuccessful {receiptInfo.ProductId}`)
					JumpscareHandler:RemovePendingJumpscare(player)
				end
			end
			return true
		end)
	end)
	if not success then
		warn(`Purchase datastore unsuccessful`)
		JumpscareHandler:RemovePendingJumpscare(player)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	elseif isPurchaseRecorded == nil then
		JumpscareHandler:RemovePendingJumpscare(player)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

MarketplaceService.ProcessReceipt = ProcessReceipt
return PurchaseHandler
