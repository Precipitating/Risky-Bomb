local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local Remotes = ReplicatedStorage.Remotes
local SoundRemotes = {}

function SoundRemotes.Handle()
	Remotes.PlaySoundOnClient.OnClientEvent:Connect(
		function(audioID: string, parent: Instance, isTheme: boolean, config)
			print(`audio id that should be on client {audioID}`)
			if isTheme then
				SoundManager.PlayTheme(audioID, config)
			else
				SoundManager.PlayAt(audioID, parent, config)
			end
		end
	)

	Remotes.PlayTickSound.OnClientEvent:Connect(function(bombRef: MeshPart)
		local tickSound: Sound = bombRef:WaitForChild("Tick") :: Sound
		if not tickSound.IsPlaying then
			tickSound:Play()
		else
			tickSound.TimePosition = 0
		end
	end)
end

return SoundRemotes
