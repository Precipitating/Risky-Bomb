local ServerScriptService = game:GetService("ServerScriptService").Server
local BombTypes = require(ServerScriptService.ServerTypes.BombTypes)

local originalScale: Vector3 = Vector3.new(0.827, 1.062, 0.827)
local scaledUp: Vector3 = Vector3.new(originalScale.X * 2, originalScale.Y * 2, originalScale.Z * 2)
type BombConstants = BombTypes.BombConstants
local constants: BombConstants = {
	MAX_BOMB_TIME = 600,
	MIN_BOMB_TIME = 30,
	MINIMUM_TWEEN_DURATION = 0.05, -- below this, and we won't hear the tick sound anymore
	MAX_TWEEN_DURATION = 1,
	ORIGINAL_BOMB_SCALE = Vector3.new(0.827, 1.062, 0.827),
	BOMB_SCALED_UP = scaledUp,
}
return constants
