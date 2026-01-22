local Rarity = require(script.Parent.Rarity)
return {
	NineToFivePack = {
		Cost = 1700,
		ItemList = {
			FoldingChair = Rarity.Common,
			PlasticStool = Rarity.Common,
			Operator = Rarity.Rare,
			BarStool = Rarity.Rare,
			Executive = Rarity.Epic,
			GardenChair = Rarity.Epic,
			EvilChair = Rarity.Legendary,
			Beanbag = Rarity.Legendary,
		},
		AlreadyOwnedPayment = 500,
	},
	BrainrotPack = {
		Cost = 2500,
		ItemList = {

			GiraffeChair = Rarity.Common,
			ClippyChair = Rarity.Common,
			CappucinoChairSA = Rarity.Rare,
			BrainChairSA = Rarity.Rare,
			CreepyChair = Rarity.Epic,
			RacoonChairSA = Rarity.Legendary,
			OwlChair = Rarity.Legendary,
			TungChairSA = Rarity.Legendary,
		},
		AlreadyOwnedPayment = 500,
	},
}
