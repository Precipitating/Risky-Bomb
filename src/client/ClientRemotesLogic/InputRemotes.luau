local StarterPlayer = game:GetService("StarterPlayer")
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local PlayerModule = PlayerContext.Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
local Remotes = ReplicatedStorage.Remotes

local InputRemotes = {}

local function EnableFirstPerson(enable: boolean)
	if enable then
		local hrp: BasePart = PlayerContext.Player.Character.HumanoidRootPart
		local firstPersonPosition = hrp:GetPivot() + (hrp.CFrame.lookVector * 1.5) + Vector3.new(0, 1, 0)
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		workspace.CurrentCamera:PivotTo(firstPersonPosition)
	else
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
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
