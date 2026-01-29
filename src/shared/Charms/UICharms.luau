local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Charm = require(ReplicatedStorage.Packages.Charm)

return {
	CurrentDonationText = Charm.atom(""),
	ToolTipOpen = Charm.atom(false),
	CurrentToolTipInfo = Charm.atom({
		ItemName = "???",
		ItemMaterial = "???",
		ItemColor = "???",
	}),
	SpinTweenHandle = Charm.atom({}),
	PackBought = Charm.atom(false),
	CanAwardDaily = Charm.atom(true),
}
