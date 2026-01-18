local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Shared.Config.Rarity)

export type ItemData = {
	Name: string,
	RarityChance: number,
	Material: Enum.Material,
	Color: BrickColor,
}

return {
	firstJoin = true,
	currency = 0,
	sessionJoinTime = 0,

	chairsOwned = {
		[1] = {
			Name = "Default",
			RarityChance = Rarity.Common,
			Material = "SmoothPlastic", -- Enum.Material -> string
			Color = "White", -- BrickColor -> string
		},
	},

	bombsOwned = {
		[1] = {
			Name = "Default",
			RarityChance = Rarity.Common,
			Material = "SmoothPlastic",
			Color = "Black",
		},
	},

	chairEquipped = {
		Name = "Default",
		RarityChance = Rarity.Common,
		Material = "SmoothPlastic",
		Color = "White",
	},

	bombEquipped = {
		Name = "Default",
		RarityChance = Rarity.Common,
		Material = "SmoothPlastic",
		Color = "Black",
	},
}
