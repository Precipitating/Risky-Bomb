local AITypes = {}

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

return AITypes
