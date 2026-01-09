local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local Players = game:GetService("Players")
local JumpscarePending = {}
local PurchaseHistory = DataStoreService:GetDataStore("PurchaseHistory")
local ProductFunctions = {}

local PurchaseHandler = {}

function PurchaseHandler.AddPendingJumpscare(player: Player, targetUserID)
	JumpscarePending[player.UserId] = {}
	JumpscarePending[player.UserId].Target = targetUserID
end

local function RemovePendingJumpscare(player: Player)
	JumpscarePending[player.UserId].Target = nil
end

-- jumpscare
ProductFunctions[3507139396] = function(receipt, player)
	print(`{player} bought jumpscare!`)
	Remotes.JumpscarePlayer:FireClient(Players:GetPlayerByUserId(JumpscarePending[player.UserId].Target))
	JumpscarePending[player.UserId].Target = nil
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
					RemovePendingJumpscare(player)
				end
			end
			return true
		end)
	end)
	if not success then
		warn(`Purchase datastore unsuccessful`)
		RemovePendingJumpscare(player)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	elseif isPurchaseRecorded == nil then
		RemovePendingJumpscare(player)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

function PurchaseHandler.Initialize()
	MarketplaceService.ProcessReceipt = ProcessReceipt
end

return PurchaseHandler
