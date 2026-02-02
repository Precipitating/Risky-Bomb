local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RandomModule = require(ReplicatedStorage.Shared.RandomModule)
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

local SoundManager = {
	UISounds = {
		ButtonClick = "rbxassetid://452267918",
		Error = "rbxassetid://3779045779",
		Submit = "rbxassetid://9118819937",
		Tick = "rbxassetid://4621722813",
		Cash = "rbxassetid://14621507602",
		Success = "rbxassetid://12221990",
		Thanks = "rbxassetid://101848247153533",
		Arigato = "rbxassetid://88955287410162",

		Common = "rbxassetid://4612386679",
		Rare = "rbxassetid://4612386064",
		Epic = "rbxassetid://4612386227",
		Legendary = "rbxassetid://4612383790",

		AIWin = "rbxassetid://17620645740",
		AILose = "rbxassetid://128504700405137",

		CardUse = "rbxassetid://128706455708345",
	},
	PromptSounds = {
		ChairSit = "rbxassetid://12222152",
		ChairLeave = "rbxassetid://12221967",
	},
	GameSounds = {
		Win = "rbxassetid://125552754635730",
		Lose = "rbxassetid://91020679481479",
	},
}

local function LoadSoundsFromTable(parent: Instance, folderName: string, tableToModify: {})
	local folder = Instance.new("Folder")
	folder.Parent = parent
	folder.Name = folderName
	for key, uiSoundID in pairs(tableToModify) do
		local sound = Instance.new("Sound")
		sound.Parent = folder
		sound.Name = key
		sound.SoundId = uiSoundID
		sound.Volume = 3
		-- this turns the sound IDs in the table to actual sound instances
		tableToModify[key] = sound
	end
end

function SoundManager.PlayExistingSound(sound: Sound | string)
	if typeof(sound) == "string" then
		warn("Sound is a string, ignore if using UI Labs")
		return
	end
	if sound.IsPlaying then
		sound.TimePosition = 0
		return
	end
	sound:Play()
end

function SoundManager.Initialize()
	-- spawn sound instances that will be used heavily
	local soundService = game.SoundService
	LoadSoundsFromTable(soundService, "UISounds", SoundManager.UISounds)
	LoadSoundsFromTable(soundService, "PromptSounds", SoundManager.PromptSounds)

	SoundManager.PlayTheme(SoundManager.GetRandomMainSound())
end

function SoundManager.GetRandomMainSound()
	return MainSounds[RandomModule.GetRandomNumberBetween(1, #MainSounds)]
end

function SoundManager.GetRandomBombThemeSound()
	return BombGameThemes[RandomModule.GetRandomNumberBetween(1, #BombGameThemes)]
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

-- one shots
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
	Debris:AddItem(sound, sound.TimeLength + 0.5)
end

return SoundManager
