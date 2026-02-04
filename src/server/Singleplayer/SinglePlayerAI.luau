local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService").Server
local RandomModule = require(ReplicatedStorage.Shared.RandomModule)
local GameModule = require(ServerScriptService.BombGame.GameModule)
local BombHandler = require(ServerScriptService.BombGame.BombHandler)
local AIDifficultyConfig = require(script.Parent.AIDifficultyConfig)
type AIDifficulty = AIDifficultyConfig.AIDifficulty

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
	if not tableClass.AIConfig.AITurn then
		warn("Not AI's turn?")
		return
	end
	local deductionTime = TimeDeductCalculate(difficultyConfig, tableClass.BombTimeLeft)

	task.delay(RandomModule.GetRandomNumberBetween(1, difficultyConfig.decisionDelay), function()
		if not tableClass.GameActive then
			return
		end
		print(`ai currently reducing {deductionTime}`)
		local resultingTime = BombHandler.ReduceBombTime(tableClass, deductionTime)

		if resultingTime > 0 then
			GameModule.NextTurn(tableClass)
		end
	end)
end

return SinglePlayerAI
