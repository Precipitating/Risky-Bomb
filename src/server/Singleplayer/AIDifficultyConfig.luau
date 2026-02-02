local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RandomModule = require(ReplicatedStorage.Shared.RandomModule)
export type AIDifficulty = {
	minReduction: number,
	maxReduction: number,
	dangerThreshold: number,
	panicModeThreshold: number,
	riskTolerance: number,
	timePercentageMin: number,
	timePercentageMax: number,
	decisionDelay: number,
	panicReduction: number,
}
local difficultyList = {
	[1] = "Easy",
	[2] = "Normal",
	[3] = "Hard",
}

return {
	GetRandomDifficulty = function()
		local randomDiff = RandomModule.GetRandomNumberBetween(1, #difficultyList)
		print(`AI difficulty ={randomDiff}`)
		return difficultyList[randomDiff]
	end,
	Easy = {
		minReduction = 10,
		maxReduction = 550,
		dangerThreshold = 2,
		panicModeThreshold = 5,
		riskTolerance = 0.2,
		timePercentageMin = 0.05,
		timePercentageMax = 0.10,
		decisionDelay = 3.5,
		panicReduction = 1,
	} :: AIDifficulty,

	Normal = {
		minReduction = 7,
		maxReduction = 450,
		dangerThreshold = 5,
		panicModeThreshold = 4,
		riskTolerance = 0.45,
		timePercentageMin = 0.10,
		timePercentageMax = 0.20,
		decisionDelay = 2.0,
		panicReduction = 1,
	} :: AIDifficulty,

	Hard = {
		minReduction = 1,
		maxReduction = 200,
		dangerThreshold = 20,
		panicModeThreshold = 3,
		riskTolerance = 0.65,
		timePercentageMin = 0.15,
		timePercentageMax = 0.30,
		decisionDelay = 1,
		panicReduction = 2,
	} :: AIDifficulty,
}
