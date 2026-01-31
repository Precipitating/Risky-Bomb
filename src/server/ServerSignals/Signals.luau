local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Signal = require(ReplicatedStorage.Packages.Signal)

return {
	GameFinished = Signal.new(),
	BeginGame = Signal.new(),
}
