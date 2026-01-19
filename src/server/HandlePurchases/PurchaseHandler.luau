local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataService = require(ReplicatedStorage.Shared.Packages.DataService).server
local JumpscareHandler = require(script.Parent.JumpscareHandler)
local PurchaseHistory = DataStoreService:GetDataStore("PurchaseHistory")
local PlayerDonations = DataStoreService:GetOrderedDataStore("DonationBoard")

local ProductFunctions = {}
local PurchaseHandler = {}

local function AddDonationToDataStore(player: Player, value: number)
	local success, result = pcall(function()
		PlayerDonations:UpdateAsync(player.UserId, function(oldValue)
			oldValue = oldValue or 0
			return oldValue + value
		end)
	end)

	if not success then
		warn(result)
	end

	return success
end
-- jumpscare
ProductFunctions[3507139396] = function(_, player)
	return JumpscareHandler:JumpscarePurchased(player)
end

-- currency
ProductFunctions[3512408744] = function(_, player)
	DataService:update(player, { "currency" }, function(currentCash)
		return currentCash + 1000
	end)
	return true
end
ProductFunctions[3512408743] = function(_, player)
	DataService:update(player, { "currency" }, function(currentCash)
		return currentCash + 2500
	end)
	return true
end
ProductFunctions[3512408742] = function(_, player)
	DataService:update(player, { "currency" }, function(currentCash)
		return currentCash + 5250
	end)
	return true
end
ProductFunctions[3512408741] = function(_, player)
	DataService:update(player, { "currency" }, function(currentCash)
		return currentCash + 11500
	end)

	return true
end

-- donations
ProductFunctions[3516890199] = function(_, player)
	return AddDonationToDataStore(player, 100)
end
ProductFunctions[3516890198] = function(_, player)
	return AddDonationToDataStore(player, 250)
end
ProductFunctions[3516890200] = function(_, player)
	return AddDonationToDataStore(player, 500)
end
ProductFunctions[3516890201] = function(_, player)
	return AddDonationToDataStore(player, 750)
end
ProductFunctions[3516890202] = function(_, player)
	return AddDonationToDataStore(player, 1000)
end
ProductFunctions[3516891247] = function(_, player)
	return AddDonationToDataStore(player, 10000)
end
ProductFunctions[3516902698] = function(_, player)
	return AddDonationToDataStore(player, 25000)
end

local function ProcessReceipt(receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId
	local key = `{userId}_{receiptInfo.PurchaseId}`
	local player = Players:GetPlayerByUserId(userId)

	local wasFirstPurchase = false

	local success, errMsg = pcall(function()
		PurchaseHistory:UpdateAsync(key, function(alreadyPurchased)
			if alreadyPurchased then
				return true
			end

			wasFirstPurchase = true
			return true
		end)
	end)

	if not success then
		error(errMsg)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- grant ONLY once
	if wasFirstPurchase and player then
		local handler = ProductFunctions[productId]
		local ok, errorMsg = pcall(handler, receiptInfo, player)
		if not ok or not errorMsg then
			error(errorMsg)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.ProcessReceipt = ProcessReceipt

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, wasPurchased)
	if not wasPurchased then
		JumpscareHandler.JumpscarePurchaseFailed(Players:GetPlayerByUserId(userId), productId)
	end
end)
return PurchaseHandler
