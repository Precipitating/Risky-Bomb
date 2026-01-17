local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarity = require(ReplicatedStorage.Shared.Config.Rarity)
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
		Name = "Default",
		RarityChance = Rarity.Common,
		Material = Enum.Material.Plastic,
		Color = BrickColor.Black(),
	},
	chairEquipped = {
		Name = "Default",
		RarityChance = Rarity.Common,
		Material = Enum.Material.Plastic,
		Color = BrickColor.White(),
	},
	bombEquipped = { Name = "Default", Material = Enum.Material.Plastic, Color = BrickColor.White() },
}
