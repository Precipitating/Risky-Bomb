local Constants = {
	WIN_REWARD = 300,
	AI_REWARD = 100,
	LOSE_REWARD = 50,
	ABRUPT_REWARD = 10,
	DISCOUNT_MULTIPLIER = 0.2,
}
table.freeze(Constants)

return Constants
