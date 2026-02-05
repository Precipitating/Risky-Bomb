local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService").Server
local RandomModule = require(ReplicatedStorage.RandomModule)
local CardUseType = require(ReplicatedStorage.Config.CardUseType)
local GameModule = require(ServerScriptService.BombGame.GameModule)

local CardHandler = require(ServerScriptService.Cards.CardHandler)
local CardTypes = require(ServerScriptService.ServerTypes.CardTypes)
local AITypes = require(ServerScriptService.ServerTypes.AITypes)
type AIDifficulty = AITypes.AIDifficulty
type CardData = CardTypes.CardData

local SinglePlayerAI = {}

-- decide roughly where the AI should cut via the bomb's min & max detonation time
local function TimeDeductCalculate(config: AIDifficulty, timeLeft: number)
	if timeLeft < config.panicModeThreshold then
		return config.panicReduction
	end

	local reduction = 0
	-- in danger zone - be more conservative
	if timeLeft <= config.dangerThreshold then
		reduction = config.minReduction
	else
		-- normal

		local randomFactor = RandomModule.GetRandomNumberBetween(0, 1)

		local percentageReduction = math.lerp(config.timePercentageMin, config.timePercentageMax, randomFactor)
		reduction = timeLeft * percentageReduction
	end
	-- clamp to min/max bounds
	reduction = math.max(config.minReduction, math.min(config.maxReduction, reduction))

	-- must reduce at least minReduction
	reduction = math.max(config.minReduction, reduction)

	return math.floor(reduction)
end

-- returns the value to deduct from bomb after x seconds
function SinglePlayerAI.ThinkAndChoose(tableClass)
	local difficultyConfig = tableClass.AIConfig.AIDifficultyConfig
	local aiCard: CardData? = tableClass.AIConfig.AICard
	local shouldUseCard = RandomModule.GetRandomDecimalBetween(0, 1) <= 0.25
	local singlePlayerID = tableClass.AIConfig.PlayerID
	if not tableClass.AIConfig.AITurn then
		warn("Not AI's turn?")
		return
	end
	local deductionTime = TimeDeductCalculate(difficultyConfig, tableClass.BombTimeLeft)

	task.delay(RandomModule.GetRandomNumberBetween(1, difficultyConfig.decisionDelay), function()
		if not tableClass.GameActive then
			return
		end

		local usedInstantCard = false

		if aiCard and shouldUseCard then
			CardHandler:UseCard(tableClass.PlayersAssigned[singlePlayerID], aiCard.KeyName, deductionTime)

			usedInstantCard = (aiCard.UseType == CardUseType.Enum.InstantActivation)

			tableClass.AIConfig.AICard = nil
		end

		-- resolve turn
		if usedInstantCard then
			warn("AI used an instant activation card, so no reduction.")

			if tableClass.BombTimeLeft > 0 then
				GameModule.NextTurn(tableClass)
			end
		else
			warn(`AI chooses to reduce {deductionTime}`)
			GameModule:SubmitBombTime(nil, tableClass.ID, deductionTime)
		end
	end)
end

return SinglePlayerAI
