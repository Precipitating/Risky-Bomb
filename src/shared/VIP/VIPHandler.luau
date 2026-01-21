local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Rarity = require(ReplicatedStorage.Config.Rarity)
local UtilityModule = require(ReplicatedStorage.Utility.UtilityModule)
local DataService
if RunService:IsServer() then
	DataService = require(ReplicatedStorage.Packages.DataService).server
else
	DataService = require(ReplicatedStorage.Packages.DataService).client
end
local VIPGUILocation = ReplicatedStorage.UITemplates.VIPGui
local VIPHandler = {}

function VIPHandler.OwnsVIPGamePass(player: Player)
	local ownsGamepass = false
	local success, errorMsg = pcall(function()
		ownsGamepass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, 1680854313)
	end)

	if not success then
		error(errorMsg)
	end
	return ownsGamepass
end

function VIPHandler.IsVIP(player: Player)
	local isVIP = false
	if RunService:IsServer() then
		isVIP = DataService:get(player, "VIP")
	else
		isVIP = DataService:get("VIP")
	end

	return isVIP
end

function VIPHandler.SetVIPGUI(player: Player)
	warn("Setting VIP GUI...")
	if not VIPHandler.IsVIP(player) then
		return
	end
	if not player then
		return
	end

	local character: Model? = player.Character
	local head = UtilityModule.Get(character, "Head")
	local gui = VIPGUILocation:Clone()
	gui.Parent = head
end

function VIPHandler.AwardVIPRewards(player: Player)
	warn("Awarding VIP Items...")
	local alreadyBought = DataService:get(player, "VIP")
	local VIPItemsAwarded = DataService:get(player, "VIPItemsAwarded")

	if alreadyBought and VIPItemsAwarded then
		return
	end
	DataService:arrayInsert(
		player,
		{ "chairsOwned" },
		{ Name = "VIPChair", RarityChance = Rarity.Legendary, Material = "Metal", Color = "Forest green" }
	)
	DataService:arrayInsert(
		player,
		{ "bombsOwned" },
		{ Name = "VIPBomb", RarityChance = Rarity.Legendary, Material = "Metal", Color = "Black" }
	)
	DataService:set(player, "VIP", true)
	DataService:set(player, "VIPItemsAwarded", true)
end

function VIPHandler.DoubleRewardsIfVIP(player: Player, input: number)
	local finalReward = input
	if VIPHandler.IsVIP(player) then
		finalReward *= 2
	end

	return finalReward
end
return VIPHandler
