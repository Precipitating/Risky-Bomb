local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local StarterPlayer = game:GetService("StarterPlayer")
local Networker = require(ReplicatedStorage.Packages.Networker).client
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local PlayerModule = PlayerContext.Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")

local InputRemotes = {}

function InputRemotes:EnableFirstPerson(enable: boolean)
	if enable then
		print("Enable first person")
		local hrp: BasePart = PlayerContext.Player.Character.HumanoidRootPart
		local firstPersonPosition = hrp:GetPivot() + (hrp.CFrame.lookVector * 1.5) + Vector3.new(0, 1, 0)
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		workspace.CurrentCamera:PivotTo(firstPersonPosition)
	else
		print("Disable first person")
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end
end

function InputRemotes:DisableControls(enable: boolean)
	print("Disable controls")
	local controls = require(PlayerModule):GetControls()
	if enable then
		controls:Disable()
	else
		controls:Enable()
	end
end

function InputRemotes:SubmitBombTime(currentInput: number)
	SoundManager.PlayExistingSound(SoundManager.UISounds.Submit)
	self.networking:fire("SubmitBombTime", PlayerContext.Character:GetAttribute("AssignedTable"), currentInput)
	--Remotes.SubmitBombReduction:FireServer(PlayerContext.Character:GetAttribute("AssignedTable"), currentInput)
end

function InputRemotes:Initialize()
	self.networking = Networker.new("InputRemotes", self)
end

return InputRemotes
