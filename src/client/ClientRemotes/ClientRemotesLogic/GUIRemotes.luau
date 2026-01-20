local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local BombGameCharms = require(ReplicatedStorage.Charms.BombGameCharms)
local BombConfig = require(ReplicatedStorage.Config.BombSharedConfig)
local UICharms = require(ReplicatedStorage.Charms.UICharms)
local Networker = require(ReplicatedStorage.Packages.Networker).client

local Remotes = ReplicatedStorage.Remotes

local Connections = {}
local GUIRemotes = {}
GUIRemotes.networker = Networker.new("GUIRemotes", GUIRemotes)

function GUIRemotes.DisconnectAll(key)
	if not Connections[key] then
		warn("Disconnect failed, key doesn't exist")
		return
	end
	for _, conn in pairs(Connections[key]) do
		if typeof(conn) == "RBXScriptConnection" then
			conn:Disconnect()
		end
	end

	table.clear(Connections[key])

	print(`Disconnected {key}!`)
end

function GUIRemotes.StoreConnection(key, signal, callback)
	-- initialize table for this key
	if not Connections[key] then
		Connections[key] = {}
	end

	local conn = signal:Connect(callback)
	table.insert(Connections[key], conn)
	return conn
end

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
