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
	currency = 999999,
	sessionJoinTime = 0,
	chairsOwned = {
		[1] = {
			Name = "Default",
			RarityChance = Rarity.Common,
			Material = Enum.Material.SmoothPlastic,
			Color = BrickColor.White(),
		},
	},
	bombsOwned = {
		[1] = {
			Name = "Default",
			RarityChance = Rarity.Common,
			Material = Enum.Material.SmoothPlastic,
			Color = BrickColor.Black(),
		},
	},
	chairEquipped = {
		Name = "Default",
		RarityChance = Rarity.Common,
		Material = Enum.Material.SmoothPlastic,
		Color = BrickColor.White(),
	},
	bombEquipped = {
		Name = "Default",
		RarityChance = Rarity.Common,
		Material = Enum.Material.SmoothPlastic,
		Color = BrickColor.Black(),
	},
}
