local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local BombGameCharms = require(ReplicatedStorage.Charms.BombGameCharms)
local BombConfig = require(ReplicatedStorage.Config.BombSharedConfig)
local UICharms = require(ReplicatedStorage.Charms.UICharms)
local Networker = require(ReplicatedStorage.Packages.Networker).client

local Remotes = ReplicatedStorage.Remotes

local GUIRemotes = {}
GUIRemotes.networker = Networker.new("GUIRemotes", GUIRemotes)

function GUIRemotes:BombGUIDisconnect()
	BombGameCharms.BombInputVisible(false)
	BombGameCharms.BombInputTimeLeft(BombConfig.MAX_TURN_TIME)
	BombGameCharms.CurrentBombInput(1)
end

function GUIRemotes:SyncTurn(visible: boolean)
	BombGameCharms.BombInputVisible(visible)
	if not visible then
		BombGameCharms.CurrentBombInput(1)
		BombGameCharms.BombInputTimeLeft(BombConfig.MAX_TURN_TIME)
	end
end

function GUIRemotes:UpdateCountdownBar(timeLeft: number)
	BombGameCharms.BombInputTimeLeft(timeLeft)
end

-- content accessible via Data.Message due to global messaging
function GUIRemotes:UpdateDonationText(receiveTable)
	UICharms.CurrentDonationText(receiveTable.Data.Message)
end

function GUIRemotes:UpdateGameActive(state: boolean)
	print(`Game active = {state}`)
	BombGameCharms.GameActive(state)
end

function GUIRemotes:SetLastDonationMessage()
	local msg = self.networker:fetch("GetLastDonationMessage")
	print(msg)
	UICharms.CurrentDonationText(msg)
end

local function GetBombGUIInput()
	Remotes.GetBombInput.OnClientInvoke = function()
		local currentInput = BombGameCharms.CurrentBombInput()
		return currentInput
	end
end

function GUIRemotes.Handle()
	GetBombGUIInput()
end

return GUIRemotes
