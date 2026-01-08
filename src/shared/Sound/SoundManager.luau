local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local ThemeSoundHandle = SoundService.Background
local MainSounds = {
	"rbxassetid://101468716959778",
	"rbxassetid://98394237109741",
	"rbxassetid://86335096116258",
	"rbxassetid://94378181487716",
	"rbxassetid://1841647093",
	"rbxassetid://1842000022",
}

local BombGameThemes = {
	"rbxassetid://72995265072887",
}

local SoundManager = {}

function SoundManager.GetRandomMainSound()
	return MainSounds[math.random(1, #MainSounds)]
end

function SoundManager.GetRandomBombThemeSound()
	return BombGameThemes[math.random(1, #BombGameThemes)]
end

function SoundManager.PlayTheme(id: string, config)
	ThemeSoundHandle:Stop()
	ThemeSoundHandle.SoundId = id

	if config then
		for prop, value in pairs(config) do
			ThemeSoundHandle[prop] = value
		end
	end

	ThemeSoundHandle:Play()
end

function SoundManager.PlayGlobal(soundId, config)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Parent = SoundService

	if config then
		for prop, value in pairs(config) do
			sound[prop] = value
		end
	end

	sound:Play()
	return sound
end

function SoundManager.PlayAt(soundId: string, parent, config)
	local existingSound = SoundService:FindFirstChild(soundId)
	if existingSound then
		print("oneshot exists! replayin")
		existingSound:Stop()
		existingSound:Play()
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = soundId
	sound.SoundId = soundId
	if parent then
		sound.Parent = parent
	else
		sound.Parent = SoundService
	end

	if config then
		for prop, value in pairs(config) do
			sound[prop] = value
		end
	end

	sound:Play()
	Debris:AddItem(sound, sound.TimeLength)
end

return SoundManager
