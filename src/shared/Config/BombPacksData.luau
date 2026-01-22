local Rarity = require(script.Parent.Rarity)
return {
	NineToFivePack = {
		Cost = 1250,
		ItemList = {
			Bag = Rarity.Common,
			Can = Rarity.Common,
			Backpack = Rarity.Rare,
			Printer = Rarity.Rare,
			Briefcase = Rarity.Epic,
			Nokia = Rarity.Epic,
			Car = Rarity.Legendary,
			Monitor = Rarity.Legendary,
		},
		AlreadyOwnedPayment = 500,
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
	},
}
