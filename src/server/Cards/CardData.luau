local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService").Server
local BombHandler = require(ServerScriptService.BombGame.BombHandler)
local CardUseType = require(ReplicatedStorage.Config.CardUseType)
local RandomModule = require(ReplicatedStorage.RandomModule)
local GameModule = require(ServerScriptService.BombGame.GameModule)
local GameTableManager = require(ServerScriptService.BombGame.GameTableManager)
local SoundToClient = require(ServerScriptService.ServerRemotesLogic.SoundToClient)
local CardTypes = require(ServerScriptService.ServerTypes.CardTypes)

type CardData = CardTypes.CardData

local CardsList = {
	[1] = "SafeCard",
	[2] = "HoldUpCard",
	[3] = "LeTrolleCard",
	[4] = "DoubleTroubleCard",
	[5] = "DoubleCheckCard",
	[6] = "SkipTurnCard",
}

local AICompatibleCards = {
	[1] = "SafeCard",
	[2] = "HoldUpCard",
	[3] = "LeTrolleCard",
	[4] = "DoubleTroubleCard",
	[5] = "SkipTurnCard",
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
	GetRandomCardAI = function()
		return AICompatibleCards[RandomModule.GetRandomNumberBetween(1, #AICompatibleCards)]
	end,

	SafeCard = {
		KeyName = "SafeCard",
		Name = "Safety Net",
		Description = "Use this card to apply a random 1 time 'safe' input (unless the timer is 1)",
		ImageID = "rbxassetid://76671018220570",
		UseType = CardUseType.Enum.InstantActivation,
		Use = function(player: Player, _: number)
			local tableClass, tableID = GetTableFromPlayer(player)
			local safeBombTime = RandomModule.GetRandomNumberBetween(1, tableClass.BombTimeLeft - 1)
			warn(`Safety card number chosen is {safeBombTime} `)
			GameModule:SubmitBombTime(player, tableID, safeBombTime)
		end,
	} :: CardData,

	HoldUpCard = {
		KeyName = "HoldUpCard",
		Name = "Hold up!",
		Description = "Add a random number between 50-200 to the current time!",
		ImageID = "rbxassetid://109484338496545",
		UseType = CardUseType.Enum.CanInputAfterActivation,
		Use = function(player: Player, _: number)
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
		UseType = CardUseType.Enum.CanInputAfterActivation,
		Use = function(player: Player, _: number)
			local tableClass, _ = GetTableFromPlayer(player)
			tableClass.BombEffectsActive["LeTrolleCard"] = { TurnsLeft = 3 }
		end,
	} :: CardData,

	DoubleTroubleCard = {
		KeyName = "DoubleTroubleCard",
		Name = "Double Trouble",
		Description = "Force the opponent's input to be DOUBLED unknowingly to them",
		ImageID = "rbxassetid://138957508838982",
		UseType = CardUseType.Enum.CanInputAfterActivation,
		Use = function(player: Player, _: number)
			local tableClass, _ = GetTableFromPlayer(player)
			local oppositePlayer = tableClass:GetOppositePlayer()

			if not oppositePlayer and not tableClass.AIConfig.AIMode then
				error("Opposite player not set properly!")
			end
			tableClass.BombEffectsActive["DoubleTroubleCard"] = tableClass.BombEffectsActive["DoubleTroubleCard"] or {}

			if tableClass.AIConfig.AIMode then
				if not tableClass.AIConfig.AITurn then
					tableClass.BombEffectsActive["DoubleTroubleCard"]["AIMode"] = true
				else
					tableClass.BombEffectsActive["DoubleTroubleCard"][player] = true
					print(`Double trouble applied to {player}`)
				end
			else
				tableClass.BombEffectsActive["DoubleTroubleCard"][oppositePlayer] = true
				print(`Double trouble applied to {oppositePlayer.DisplayName}`)
			end
		end,
	} :: CardData,

	DoubleCheckCard = {
		KeyName = "DoubleCheckCard",
		Name = "Double Check",
		Description = "Use to check if the current input is safe by over 10 seconds via audio cues",
		ImageID = "rbxassetid://71353406346530",
		UseType = CardUseType.Enum.CanInputAfterActivation,
		Use = function(player: Player, bombInput: number)
			local tableClass, _ = GetTableFromPlayer(player)
			local bombTime = tableClass.BombTimeLeft

			if (bombTime - bombInput) > 10 then
				SoundToClient.networker:fire(player, "PlayExistingSound", "UISounds", "Yes")
			else
				SoundToClient.networker:fire(player, "PlayExistingSound", "UISounds", "Dont")
			end
		end,
	} :: CardData,

	SkipTurnCard = {
		KeyName = "SkipTurnCard",
		Name = "Skip",
		Description = "Skip a turn",
		ImageID = "rbxassetid://135885419597915",
		UseType = CardUseType.Enum.InstantActivation,
		Use = function(player: Player, _: number)
			local tableClass, _ = GetTableFromPlayer(player)
			GameModule.NextTurn(tableClass)
			print("Turn skipped!")
		end,
	} :: CardData,
}
