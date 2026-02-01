local Rarity = require(script.Parent.Rarity)
return {
	NineToFivePack = {
		Cost = 1200,
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
		AlreadyOwnedPayment = 360,
	},
	BrainrotPack = {
		Cost = 1800,
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
		AlreadyOwnedPayment = 720,
	},
	RetroPack = {
		Cost = 1800,
		ItemList = {
			RetroHalloweenChair = Rarity.Common,
			RetroSofa = Rarity.Common,
			RetroTree = Rarity.Rare,
			RetroCircle = Rarity.Rare,
			RetroTrampoline = Rarity.Epic,
			RetroCar = Rarity.Epic,
			RetroNoobHead = Rarity.Legendary,
			RetroTeapotTurret = Rarity.Legendary,
		},
		AlreadyOwnedPayment = 720,
	},
}
