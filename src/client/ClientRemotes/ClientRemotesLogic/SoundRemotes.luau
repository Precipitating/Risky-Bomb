local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Networker = require(ReplicatedStorage.Packages.Networker).client
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local SoundRemotes = {}

SoundRemotes.networker = Networker.new("SoundRemotes", SoundRemotes)

function SoundRemotes:PlaySoundOnClient(audioID: string, parent: Instance | nil, isTheme: boolean, config)
	print(`audio id that should be on client {audioID}`)
	if isTheme then
		SoundManager.PlayTheme(audioID, config)
	else
		SoundManager.PlayAt(audioID, parent, config)
	end
end

-- the client already converted the sound ids to sound instances whilst the server hasnt
-- so we have to reference it via pathing
function SoundRemotes:PlayExistingSound(folderName: string, soundName: string)
	local sound = SoundManager[folderName][soundName]
	SoundManager.PlayExistingSound(sound)
end

function SoundRemotes:PlayBombTickSound(bombRef: MeshPart)
	local tickSound: Sound = bombRef:WaitForChild("Tick") :: Sound
	if not tickSound.IsPlaying then
		tickSound:Play()
	else
		tickSound.TimePosition = 0
	end
end

return SoundRemotes
