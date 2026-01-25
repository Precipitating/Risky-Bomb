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
}
