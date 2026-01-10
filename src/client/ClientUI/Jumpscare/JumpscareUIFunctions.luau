local Players = game:GetService("Players")

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

function JumpscareUIFunctions.GetRandomJumpscareImage()
	return JumpscareIDs[math.random(1, #JumpscareIDs)]
end

function JumpscareUIFunctions.GetRandomJumpscareSound()
	return JumpscareSounds[math.random(1, #JumpscareSounds)]
end
function JumpscareUIFunctions.GetPlayers()
	local playerList = {}
	for _, player in ipairs(Players:GetPlayers()) do
		table.insert(playerList, { Name = player.Name, UserID = player.UserId })
	end
	return playerList
end

return JumpscareUIFunctions
