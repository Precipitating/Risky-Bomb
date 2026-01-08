local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local CountdownBarXSize = nil
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

	Remotes.UpdateCountdownBar.OnClientEvent:Connect(function(bombGUI: ScreenGui, timeLeft: number | nil)
		-- ref checks
		if not bombGUI then
			warn("BombGUI ref missing on updating countdownbar")
			return
		end

		local connection = Connections[bombGUI]
		if not connection then
			warn("BombGUI connection missing")
			return
		end

		local countDownBar = bombGUI:WaitForChild("Countdown", 5)
		if not countDownBar then
			warn("Countdown bar missing or destroyed, game may be finished.")
			return
		end

		if not CountdownBarXSize then
			CountdownBarXSize = countDownBar.Size.X.Scale
		end
		-- means reset the bar
		if timeLeft == nil then
			countDownBar.Size = UDim2.fromScale(CountdownBarXSize, countDownBar.Size.Y.Scale)
			return
		end

		local newXSize = timeLeft * CountdownBarXSize
		local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local goal = { Size = UDim2.fromScale(newXSize, countDownBar.Size.Y.Scale) }
		local tween = TweenService:Create(countDownBar, tweenInfo, goal)
		tween:Play()
	end)
end

local function GetBombGUIInput()
	Remotes.GetBombInput.OnClientInvoke = function()
		local bombGUI = PlayerContext.Player.PlayerGui:FindFirstChild("BombGUI")
		if not bombGUI or not Connections[bombGUI] then
			print("Player missing BombGUI instance or connection!")
			return
		end
		local numberText = bombGUI:FindFirstChild("InputFrame"):FindFirstChild("Number")
		local number = tonumber(numberText.Text)
		numberText.Text = "1"

		return number
	end
end

function GUIRemotes.Handle()
	BombGUIConnect()
	BombGUIDisconnect()
	GetBombGUIInput()
end

return GUIRemotes
