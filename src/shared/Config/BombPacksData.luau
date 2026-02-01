local Rarity = require(script.Parent.Rarity)
return {
	NineToFivePack = {
		Cost = 1200,
		ItemList = {
			Bag = Rarity.Common,
			Can = Rarity.Common,
			Backpack = Rarity.Rare,
			Printer = Rarity.Rare,
			Briefcase = Rarity.Epic,
			NokiaSA = Rarity.Epic,
			Car = Rarity.Legendary,
			Monitor = Rarity.Legendary,
		},
		AlreadyOwnedPayment = 360,
	},
	BrainrotPack = {
		Cost = 1500,
		ItemList = {
			TabletSA = Rarity.Common,
			ElephantSA = Rarity.Common,
			PotSA = Rarity.Rare,
			HoundSA = Rarity.Rare,
			BuffSA = Rarity.Epic,
			FeetBroSA = Rarity.Epic,
			PlaneSA = Rarity.Legendary,
			TungBombSA = Rarity.Legendary,
		},
		AlreadyOwnedPayment = 450,
	},
	RetroPack = {
		Cost = 1500,
		ItemList = {
			UglyEggSA = Rarity.Common,
			TixSA = Rarity.Common,
			DuckSA = Rarity.Rare,
			RetroBomb = Rarity.Rare,
			NoobSA = Rarity.Epic,
			RetroTeapotBombSA = Rarity.Epic,
			NecroBookSA = Rarity.Legendary,
			PumpkinSA = Rarity.Legendary,
		},
		AlreadyOwnedPayment = 450,
	},
}
