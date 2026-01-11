local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local BombGameCharms = require(ReplicatedStorage.Charms.BombGameCharms)
local BombConfig = require(ReplicatedStorage.Config.BombConfig)

local Remotes = ReplicatedStorage.Remotes

local Connections = {}
local GUIRemotes = {}

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

local function BombGUIDisconnect()
	Remotes.DisconnectGUI.OnClientEvent:Connect(function()
		BombGameCharms.BombInputVisible(false)
		BombGameCharms.BombInputTimeLeft(BombConfig.MAX_TURN_TIME)
		BombGameCharms.CurrentBombInput(1)
	end)
end

local function BombGUIConnect()
	Remotes.SyncTurn.OnClientEvent:Connect(function(visible: boolean)
		BombGameCharms.BombInputVisible(visible)
		if not visible then
			BombGameCharms.CurrentBombInput(1)
			BombGameCharms.BombInputTimeLeft(BombConfig.MAX_TURN_TIME)
		end
	end)

	Remotes.UpdateCountdownBar.OnClientEvent:Connect(function(timeLeft: number)
		BombGameCharms.BombInputTimeLeft(timeLeft)
	end)
end

local function GetBombGUIInput()
	Remotes.GetBombInput.OnClientInvoke = function()
		local currentInput = BombGameCharms.CurrentBombInput()
		return currentInput
	end
end

function GUIRemotes.Handle()
	BombGUIConnect()
	BombGUIDisconnect()
	GetBombGUIInput()
end

return GUIRemotes
