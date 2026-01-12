local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local BombGameCharms = require(ReplicatedStorage.Charms.BombGameCharms)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local Networker = require(ReplicatedStorage.Packages.Networker).client

local JumpscareIDs = {
	"rbxassetid://124338845724473",
	"rbxassetid://6182991646",
	"rbxassetid://3425028682",
	"rbxassetid://12351005336",
}

local JumpscareSounds = {
	"rbxassetid://5710016194",
	"rbxassetid://6754147732",
	"rbxassetid://7076365030",
	"rbxassetid://130285917830946",
}
local JumpscareUIFunctions = {}
JumpscareUIFunctions.networker = Networker.new("JumpscareRemotes", JumpscareUIFunctions)

function JumpscareUIFunctions.GetRandomJumpscareImage()
	return JumpscareIDs[math.random(1, #JumpscareIDs)]
end

function JumpscareUIFunctions.GetRandomJumpscareSound()
	return JumpscareSounds[math.random(1, #JumpscareSounds)]
end

function JumpscareUIFunctions:ActivateJumpscare()
	BombGameCharms.JumpscareImage(self.GetRandomJumpscareImage())
	local sound: Sound = SoundManager.PlayGlobal(self.GetRandomJumpscareSound())
	sound.Loaded:Wait()

	BombGameCharms.JumpscareActivated(true)
	sound.Ended:Wait()
	sound:Destroy()
	BombGameCharms.JumpscareActivated(false)
end
function JumpscareUIFunctions.GetPlayers()
	local playerList = {}
	for _, player in ipairs(Players:GetPlayers()) do
		table.insert(playerList, { Name = player.Name, UserID = player.UserId })
	end
	return playerList
end

return JumpscareUIFunctions
