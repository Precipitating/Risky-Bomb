local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Networker = require(ReplicatedStorage.Packages.Networker).client
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local SoundRemotes = {}

SoundRemotes.networker = Networker.new("SoundRemotes", SoundRemotes)

function SoundRemotes:PlaySoundOnClient(audioID: string, parent: Instance, isTheme: boolean, config)
	print(`audio id that should be on client {audioID}`)
	if isTheme then
		SoundManager.PlayTheme(audioID, config)
	else
		SoundManager.PlayAt(audioID, parent, config)
	end
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
