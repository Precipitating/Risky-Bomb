local CollectionService = game:GetService("CollectionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerDataHandler = require(ServerScriptService.Server.ServerData.ServerDataHandler)
local SoundToClient = require(ServerScriptService.Server.ServerRemotesLogic.SoundToClient)
local ProximityPromptHandler = {}

local function LikeRewardPrompt(prompt: ProximityPrompt, player: Player)
	if not CollectionService:HasTag(prompt, "LikeReward") then
		return
	end

	local redeemedData = ServerDataHandler.GetData(player, { "rewardsRedeemed" })
	if redeemedData and redeemedData["LIKEREWARD"] == true then
		print(`{player.DisplayName} already redeemed likes reward!`)
		SoundToClient.networker:fire(player, "PlayExistingSound", "UISounds", "Error")
		return
	end

	local success, response = pcall(function()
		return player:IsInGroupAsync(368525793)
	end)

	if success and response then
		ServerDataHandler.UpdateData(player, { "currency" }, function(currMoney: number)
			return currMoney + 3600
		end)
		ServerDataHandler.UpdateData(player, { "rewardsRedeemed" }, function(currTable: {})
			currTable["LIKEREWARD"] = true
			return currTable
		end)
	end
end

ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
	LikeRewardPrompt(prompt, player)
end)

return ProximityPromptHandler
