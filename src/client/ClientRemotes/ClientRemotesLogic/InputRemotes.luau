local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local StarterPlayer = game:GetService("StarterPlayer")
local Networker = require(ReplicatedStorage.Packages.Networker).client
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local PlayerModule = PlayerContext.Player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")

local InputRemotes = {}

function InputRemotes:SetGameCamera(enable: boolean, tableRef: Model)
	if enable then
		if not tableRef then
			error("Table reference not found when setting camera to game table!")
			return
		end
		local pos: Part = tableRef:FindFirstChild("CameraPos") :: Part
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		workspace.CurrentCamera:PivotTo(pos.CFrame)
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
	self.networking:fire("SubmitBombTime", PlayerContext.Character:GetAttribute("AssignedTable"), currentInput)
end

function InputRemotes:Initialize()
	self.networking = Networker.new("InputRemotes", self)
end

return InputRemotes
