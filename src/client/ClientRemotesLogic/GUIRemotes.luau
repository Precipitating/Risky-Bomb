local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local Connections = {}
local GUIRemotes = {}

function GUIRemotes.DisconnectAll(name)
	if not Connections[name] then
		warn("Disconnect failed, key doesn't exist")
		return
	end
	for _, conn in pairs(Connections[name]) do
		if typeof(conn) == "RBXScriptConnection" then
			conn:Disconnect()
		end
	end

	table.clear(Connections[name])

	print(`Disconnected {name}!`)
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
	Remotes.DisconnectGUI.OnClientEvent:Connect(function(bombGUI: ScreenGui)
		GUIRemotes.DisconnectAll(bombGUI)
		bombGUI:Destroy()
	end)
end

local function BombGUIConnect()
	local function Process(input: TextLabel, val: number)
		local currentNum = tonumber(input.Text) or 0
		local newNum = currentNum + val

		if newNum < 1 then
			newNum = 1
		end

		input.Text = tostring(newNum)
	end
	Remotes.ConnectGUI.OnClientEvent:Connect(function(tableRef: Model, bombGUI: ScreenGui)
		local addFiveInput = bombGUI:WaitForChild("AddFiveInput"):WaitForChild("TextButton")
		local negateFiveInput = bombGUI:WaitForChild("NegateFiveInput"):WaitForChild("TextButton")
		local incrementInput = bombGUI:WaitForChild("IncrementInput"):WaitForChild("TextButton")
		local decrementInput = bombGUI:WaitForChild("DecrementInput"):WaitForChild("TextButton")
		local submitInput = bombGUI:WaitForChild("SubmitFrame"):WaitForChild("TextButton")
		local input = bombGUI:WaitForChild("InputFrame"):WaitForChild("Number")

		GUIRemotes.StoreConnection(bombGUI, addFiveInput.Activated, function()
			Process(input, 5)
		end)
		GUIRemotes.StoreConnection(bombGUI, negateFiveInput.Activated, function()
			Process(input, -5)
		end)
		GUIRemotes.StoreConnection(bombGUI, incrementInput.Activated, function()
			Process(input, 1)
		end)
		GUIRemotes.StoreConnection(bombGUI, decrementInput.Activated, function()
			Process(input, -1)
		end)
		GUIRemotes.StoreConnection(bombGUI, submitInput.Activated, function()
			Remotes.SubmitBombReduction:FireServer(tableRef, tonumber(input.Text))
			input.Text = "1"
		end)
	end)
end

function GUIRemotes.Handle()
	BombGUIConnect()
	BombGUIDisconnect()
end

return GUIRemotes
