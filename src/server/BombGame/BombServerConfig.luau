export type BombConstants = {
	MAX_BOMB_TIME: number,
	MIN_BOMB_TIME: number,
	MINIMUM_TWEEN_DURATION: number,
	ORIGINAL_BOMB_SCALE: Vector3,
	BOMB_SCALED_UP: Vector3,
}

local originalScale: Vector3 = Vector3.new(0.827, 1.062, 0.827)
local scaledUp: Vector3 = Vector3.new(originalScale.X * 2, originalScale.Y * 2, originalScale.Z * 2)

local constants: BombConstants = {
	MAX_BOMB_TIME = 600,
	MIN_BOMB_TIME = 30,
	MINIMUM_TWEEN_DURATION = 0.05, -- below this, and we won't hear the tick sound anymore
	ORIGINAL_BOMB_SCALE = Vector3.new(0.827, 1.062, 0.827),
	BOMB_SCALED_UP = scaledUp,
}
return constants
