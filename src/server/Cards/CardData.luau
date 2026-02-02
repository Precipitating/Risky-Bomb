local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CardUseType = require(ReplicatedStorage.Shared.Config.CardUseType)
local RandomModule = require(ReplicatedStorage.Shared.RandomModule)
local GameModule = require(ServerScriptService.Server.BombGame.GameModule)
local GameTableManager = require(ServerScriptService.Server.BombGame.GameTableManager)

export type CardData = {
	KeyName: string,
	Name: string,
	Description: string,
	ImageID: string,
	UseType: number,
	Use: (Player) -> (),
}

local CardsList = {
	[1] = "SafeCard",
}

return {

	GetRandomCard = function()
		return CardsList[RandomModule.GetRandomNumberBetween(1, #CardsList)]
	end,

	SafeCard = {
		KeyName = "SafeCard",
		Name = "Safety Net",
		Description = "Use this card to apply a random 1 time 'safe' input (unless the timer is 1)",
		ImageID = "rbxassetid://76671018220570",
		UseType = CardUseType.Enum.InstantActivation,
		Use = function(player: Player)
			local character = player.Character
			if not character then
				warn("Attempt to use card but player's model isn't valid")
			end

			local tableID = character:GetAttribute("ID")
			-- get table
			local table = GameTableManager.GetTableFromID(tableID)

			if not table then
				error("Table not found when activating SafeCard")
			end
			local safeBombTime = RandomModule.GetRandomNumberBetween(1, table.BombTimeLeft - 1)

			GameModule:SubmitBombTime(player, tableID, safeBombTime)
		end,
	} :: CardData,
}
