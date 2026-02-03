local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local BombConfig = require(ReplicatedStorage.Config.BombSharedConfig)
local Charm = require(ReplicatedStorage.Packages.Charm)

return {
	BombInputTimeLeft = Charm.atom(BombConfig.MAX_TURN_TIME),
	BombInputVisible = Charm.atom(false),
	CardUsed = Charm.atom(false),
	CurrentBombInput = Charm.atom(1),
	JumpscareActivated = Charm.atom(false),
	JumpscareImage = Charm.atom(""),
	CurrentCashValue = Charm.atom(0),
	CurrentCard = Charm.atom({}),
	GameActive = Charm.atom(false),
	IsSat = Charm.atom(false),
}
