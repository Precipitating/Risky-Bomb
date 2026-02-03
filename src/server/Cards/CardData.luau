local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local BombHandler = require(ServerScriptService.Server.BombGame.BombHandler)
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
	[2] = "HoldUpCard",
	[3] = "LeTrolleCard",
}

local function GetTableFromPlayer(player: Player)
	local character = player.Character
	if not character then
		warn("Attempt to use card but player's model isn't valid")
	end

	local tableID = character:GetAttribute("ID")
	-- get table
	local tableClass = GameTableManager.GetTableFromID(tableID)

	if not tableClass then
		error("Table not found when activating SafeCard")
	end

	return tableClass, tableID
end

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
			local tableClass, tableID = GetTableFromPlayer(player)
			local safeBombTime = RandomModule.GetRandomNumberBetween(1, tableClass.BombTimeLeft - 1)

			GameModule:SubmitBombTime(player, tableID, safeBombTime)
		end,
	} :: CardData,

	HoldUpCard = {
		KeyName = "HoldUpCard",
		Name = "Hold up!",
		Description = "Add a random number between 50-200 to the current time!",
		ImageID = "rbxassetid://109484338496545",
		UseType = CardUseType.Enum.InstantActivation,
		Use = function(player: Player)
			local tableClass, _ = GetTableFromPlayer(player)
			local numToAdd = RandomModule.GetRandomNumberBetween(50, 200)
			BombHandler.AddBombTime(tableClass, numToAdd)
		end,
	} :: CardData,

	LeTrolleCard = {
		KeyName = "LeTrolleCard",
		Name = "Le Trolle",
		Description = "Make the bomb falsely tick slower for 3 turns, REMEMBER THAT TIME WILL NOT CHANGE!",
		ImageID = "rbxassetid://97593773796651",
		UseType = CardUseType.Enum.InstantActivation,
		Use = function(player: Player)
			local tableClass, _ = GetTableFromPlayer(player)
			if not tableClass.BombEffectsActive["LeTrolleCard"] then
				tableClass.BombEffectsActive["LeTrolleCard"] = { TurnsLeft = 3 }
			else
				tableClass.BombEffectsActive["LeTrolleCard"].TurnsLeft += 3
			end
			print(`turns added to le troll = {tableClass.BombEffectsActive["LeTrolleCard"].TurnsLeft}`)
		end,
	} :: CardData,
}
