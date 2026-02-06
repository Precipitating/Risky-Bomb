local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local UnreliableTickRemote = ReplicatedStorage.Remotes.PlayBombTick
local Networker = require(ReplicatedStorage.Packages.Networker).server
local SoundToClient = {}
SoundToClient.networker = Networker.new("SoundRemotes", {})

function SoundToClient:PlaySoundOnClient(
	player: Player,
	audioID: string,
	parent: Instance | nil,
	isTheme: boolean,
	config
)
	self.networker:fire(player, "PlaySoundOnClient", audioID, parent, isTheme, config)
end

function SoundToClient:PlayBombTickOnClient(player: Player)
	UnreliableTickRemote:FireClient(player)
end

return SoundToClient
