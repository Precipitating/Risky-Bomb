local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Signal = require(ReplicatedStorage.Packages.Signal)

return {
	GameFinished = Signal.new(),
	BeginGame = Signal.new(),
	AbruptEnd = Signal.new(),
	SinglePlayerNetworkFire = Signal.new(),
	AITurn = Signal.new(),
	SetCardForPlayer = Signal.new(),
	SetCardForAI = Signal.new(),
}
