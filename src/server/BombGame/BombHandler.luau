local TweenService = game:GetService("TweenService")

local BombHandler = {}
local MAX_BOMB_TIME: number = 600
local MIN_BOMB_TIME: number = 30
local ORIGINAL_BOMB_SCALE: vector = vector.create(0.827, 1.062, 0.827)
local BOMB_SCALED_UP: vector =
	vector.create(ORIGINAL_BOMB_SCALE.x * 2, ORIGINAL_BOMB_SCALE.y * 2, ORIGINAL_BOMB_SCALE.z * 2)

local function BombTween(bombRef: MeshPart, tweenDuration: number)
	local tweenInfo = TweenInfo.new(tweenDuration, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, -1, true)
	local tweenScaleUp = TweenService:Create(bombRef, tweenInfo, { Size = BOMB_SCALED_UP })
	tweenScaleUp:Play()

	tweenScaleUp.Completed:Once(function()
		print("Tween Done")
	end)
end

local function SpawnExplosionEffect(bombRef: MeshPart)
	local explosion = Instance.new("Explosion")
	explosion.Position = bombRef.Position
	explosion.BlastRadius = 15 -- Set how far the explosion's effect will reach
	explosion.BlastPressure = 0 -- Set how powerful the explosion's effect is
	explosion.DestroyJointRadiusPercent = 0 -- Set how much destruction radius will affect joints (0 means no destruction)
	explosion.Parent = game.Workspace -- Add the explosion to the workspace to trigger it
end

local function DetonateBomb(bombRef: MeshPart)
	SpawnExplosionEffect(bombRef)
	bombRef.Transparency = 1
end

local function StartTicking(bombRef: MeshPart, startTime: number)
	-- count down
	task.spawn(function()
		for i = startTime, 0, -1 do
			if not bombRef:GetAttribute("Active") then
				return
			end
			task.wait(1)
			bombRef:SetAttribute("Time", i)
		end

		if bombRef:GetAttribute("Time") == 0 then
			-- timer hit 0, so detonation occurs here
			bombRef:SetAttribute("Active", false)
			DetonateBomb(bombRef)
		end
	end)
end

local function StartScaleLerping(bombRef: MeshPart, startTime: number)
	-- scale lerp
	task.spawn(function()
		if not bombRef:GetAttribute("Active") then
			return
		end
		local currentTime = bombRef:GetAttribute("Time")
		local tweenTickTime: number = currentTime / startTime
		BombTween(bombRef, tweenTickTime)
	end)
end
local function StartBomb(bombRef: MeshPart, startTime: number)
	bombRef:SetAttribute("Active", true)
	StartTicking(bombRef, startTime)
	StartScaleLerping(bombRef, startTime)
end

function BombHandler.InitializeBomb(bombRef: MeshPart)
	local startTime = math.random(MIN_BOMB_TIME, MAX_BOMB_TIME)
	bombRef:SetAttribute("Time", startTime)
	StartBomb(bombRef, startTime)
end

return BombHandler
