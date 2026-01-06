local StarterPlayer = game:GetService("StarterPlayer")
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local PlayerModule = PlayerContext.Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
local Remotes = ReplicatedStorage.Remotes

local InputRemotes = {}

local function EnableFirstPerson(enable: boolean)
	if enable then
		PlayerContext.Player.CameraMode = Enum.CameraMode.LockFirstPerson
	else
		PlayerContext.Player.CameraMode = Enum.CameraMode.Classic
	end
end

local function DisableControls(enable: boolean)
	local controls = require(PlayerModule):GetControls()
	if enable then
		controls:Disable()
	else
		controls:Enable()
	end
end

function InputRemotes.Handle()
	Remotes.DisableControls.OnClientEvent:Connect(function(enable: boolean)
		print("Disable controls")
		DisableControls(enable)
	end)

	Remotes.EnableFirstPerson.OnClientEvent:Connect(function(enable: boolean)
		EnableFirstPerson(enable)
	end)
end

return InputRemotes
