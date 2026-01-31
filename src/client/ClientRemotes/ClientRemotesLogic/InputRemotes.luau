local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local StarterPlayer = game:GetService("StarterPlayer")
local Networker = require(ReplicatedStorage.Packages.Networker).client
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local PlayerModule = PlayerContext.Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")

local InputRemotes = {}

function InputRemotes:SetGameCamera(enable: boolean, cameraPos: Part)
	if enable then
		if not cameraPos then
			error("Camera part not found on SetGameCamera")
			return
		end
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		workspace.CurrentCamera:PivotTo(cameraPos.CFrame)
	else
		print("Reset game camera pos")
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
	self.networking:fire("SubmitBombTime", PlayerContext.Character:GetAttribute("ID"), currentInput)
end

function InputRemotes:Initialize()
	self.networking = Networker.new("InputRemotes", self)
end

return InputRemotes
