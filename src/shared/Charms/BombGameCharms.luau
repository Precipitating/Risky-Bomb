local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local BombConfig = require(ReplicatedStorage.Config.BombConfig)
local Charm = require(ReplicatedStorage.Packages.Charm)

return {
	BombInputTimeLeft = Charm.atom(BombConfig.MAX_TURN_TIME),
	BombInputVisible = Charm.atom(false),
	CurrentBombInput = Charm.atom(1),
	JumpscareActivated = Charm.atom(false),
	JumpscareImage = Charm.atom(""),
}
