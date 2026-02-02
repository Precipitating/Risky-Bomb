local ServerScriptService = game:GetService("ServerScriptService").Server
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RandomModule = require(ReplicatedStorage.Shared.RandomModule)
local SoundToClient = require(ServerScriptService.ServerRemotesLogic.SoundToClient)
local ServerSignals = require(ServerScriptService.ServerSignals.Signals)
local BombServerConfig = require(script.Parent.BombServerConfig)

local BombHandler = {}

local function PlayTickSound(playersList, bomb: MeshPart)
	for _, player in pairs(playersList) do
		SoundToClient:PlayBombTickOnClient(player, bomb)
	end
end

local function BombTween(tableClass, startTime: number)
	local bomb = tableClass.TableRefs.Bomb
	if not bomb then
		error("Missing bomb reference when tweening bomb!")
	end
	while tableClass.BombActive do
		local currTime = tableClass.BombTimeLeft
		local duration = math.max(BombServerConfig.MINIMUM_TWEEN_DURATION, currTime / startTime)
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, true)

		local tween = TweenService:Create(bomb, tweenInfo, {
			Size = BombServerConfig.BOMB_SCALED_UP,
		})

		tween:Play()
		PlayTickSound(tableClass.PlayersAssigned, bomb)
		tween.Completed:Wait()
	end
end

local function SpawnExplosionEffect(bombRef: MeshPart)
	local explosion = Instance.new("Explosion")
	explosion.Position = bombRef.Position
	explosion.BlastRadius = 15 -- Set how far the explosion's effect will reach
	explosion.BlastPressure = 0 -- Set how powerful the explosion's effect is
	explosion.DestroyJointRadiusPercent = 0 -- Set how much destruction radius will affect joints (0 means no destruction)
	explosion.Parent = game.Workspace -- Add the explosion to the workspace to trigger it
end

local function DetonateBomb(tableClass, bombRef: MeshPart)
	tableClass.BombActive = false
	SpawnExplosionEffect(bombRef)
	bombRef.Transparency = 1
	ServerSignals.GameFinished:Fire(tableClass)
end

local function StartTicking(tableClass)
	local bomb = tableClass.TableRefs.Bomb
	-- count down
	task.spawn(function()
		while tableClass.BombActive do
			print(tableClass.BombTimeLeft) -- debugging, delete later
			local timeLeft = tableClass.BombTimeLeft

			if timeLeft <= 0 then
				DetonateBomb(tableClass, bomb)
				return
			end

			tableClass.BombTimeLeft -= 1
			task.wait(1)
		end
	end)
end

local function StartScaleLerping(tableClass, startTime: number)
	task.spawn(function()
		BombTween(tableClass, startTime)
	end)
end

-- returns true if bomb time is <= 0
function BombHandler.ReduceBombTime(tableClass, reductionTime: number)
	if not tableClass.BombActive then
		return nil
	end
	local currentTime = tableClass.BombTimeLeft
	local result = currentTime - reductionTime
	tableClass.BombTimeLeft = result

	return result
end

local function StartBomb(tableClass, startTime: number)
	tableClass.BombActive = true
	StartTicking(tableClass)
	StartScaleLerping(tableClass, startTime)
end

function BombHandler.InitializeBomb(tableClass)
	local startTime =
		RandomModule.GetRandomNumberBetween(BombServerConfig.MIN_BOMB_TIME, BombServerConfig.MAX_BOMB_TIME)
	tableClass.BombTimeLeft = startTime

	StartBomb(tableClass, startTime)
end

return BombHandler
