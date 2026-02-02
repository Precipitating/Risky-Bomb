local RNG = Random.new()

local RandomModule = {}

function RandomModule.GetRandomNumberBetween(min: number, max: number)
	return RNG:NextInteger(min, max)
end

function RandomModule.GetRandomDecimalBetween(min: number, max: number)
	return RNG:NextNumber(min, max)
end

return RandomModule
