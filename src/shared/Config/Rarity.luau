local RarityTable = {
	Common = 60,
	Rare = 25,
	Epic = 10,
	Legendary = 5,
}

local function ToArray()
	local array = {}
	for key, value in pairs(RarityTable) do
		array[#array + 1] = { key = key, value = value }
	end

	table.sort(array, function(a, b)
		return a.value > b.value
	end)

	return array
end

return {
	Common = 60,
	Rare = 25,
	Epic = 10,
	Legendary = 5,

	SortedArray = ToArray,
}
