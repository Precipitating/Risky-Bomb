local ServerScriptService = game:GetService("ServerScriptService").Server
local TweenService = game:GetService("TweenService")
local BindableEvents = ServerScriptService.BindableEvents
local MAX_BOMB_TIME: number = 600
local MIN_BOMB_TIME: number = 30
local ORIGINAL_BOMB_SCALE: vector = vector.create(0.827, 1.062, 0.827)
local BOMB_SCALED_UP: vector =
	vector.create(ORIGINAL_BOMB_SCALE.x * 2, ORIGINAL_BOMB_SCALE.y * 2, ORIGINAL_BOMB_SCALE.z * 2)

local BombHandler = {}
local function BombTween(bombRef: MeshPart, startTime: number)
	while bombRef:GetAttribute("Active") do
		local currTime = bombRef:GetAttribute("Time")
		local duration = currTime / startTime

		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, true)

		local tween = TweenService:Create(bombRef, tweenInfo, {
			Size = BOMB_SCALED_UP,
		})

		tween:Play()
		tween.Completed:Wait()
	end
end

local function StopBomb(bombRef: MeshPart)
	bombRef:SetAttribute("Active", false)
end
local function SpawnExplosionEffect(bombRef: MeshPart)
	local explosion = Instance.new("Explosion")
	explosion.Position = bombRef.Position
	explosion.BlastRadius = 15 -- Set how far the explosion's effect will reach
	explosion.BlastPressure = 0 -- Set how powerful the explosion's effect is
	explosion.DestroyJointRadiusPercent = 0 -- Set how much destruction radius will affect joints (0 means no destruction)
	explosion.Parent = game.Workspace -- Add the explosion to the workspace to trigger it
end

local function DetonateBomb(bombRef: MeshPart, gameTable: Model)
	StopBomb(bombRef)
	SpawnExplosionEffect(bombRef)
	bombRef.Transparency = 1
	BindableEvents.GameFinished:Fire(gameTable)
end

local function StartTicking(bombRef: MeshPart, gameTable: Model)
	-- count down
	task.spawn(function()
		while bombRef:GetAttribute("Active") do
			local timeLeft = bombRef:GetAttribute("Time")

			if timeLeft <= 0 then
				DetonateBomb(bombRef, gameTable)
				return
			end

			bombRef:SetAttribute("Time", timeLeft - 1)
			task.wait(1)
		end
	end)
end

local function StartScaleLerping(bombRef: MeshPart, startTime: number)
	task.spawn(function()
		BombTween(bombRef, startTime)
	end)
end

-- returns true if bomb time is <= 0
function BombHandler.ReduceBombTime(bombRef: MeshPart, reductionTime: number)
	if not bombRef:GetAttribute("Active") then
		return
	end
	local currentTime = bombRef:GetAttribute("Time")
	local result = currentTime - reductionTime
	bombRef:SetAttribute("Time", result)

	return result
end

local function StartBomb(bombRef: MeshPart, startTime: number, gameTable: Model)
	bombRef:SetAttribute("Active", true)
	StartTicking(bombRef, gameTable)
	StartScaleLerping(bombRef, startTime)
end

function BombHandler.InitializeBomb(bombRef: MeshPart, gameTable: Model)
	local startTime = math.random(MIN_BOMB_TIME, MAX_BOMB_TIME)
	bombRef:SetAttribute("Time", startTime)
	StartBomb(bombRef, startTime, gameTable)
end

return BombHandler
