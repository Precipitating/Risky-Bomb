local ServerScriptService = game:GetService("ServerScriptService").Server
local GameModule = require(ServerScriptService.BombGame.GameModule)
local BombGameStorage = require(ServerScriptService.BombGame.BombGameStorage)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local CountdownTime: number = 3

local ChairRemote = {}

local function StopCountDown(countdownText: TextLabel)
	countdownText.Visible = false
	countdownText.Text = tostring(CountdownTime)
end

local function StartCountDown(playerCountText: TextLabel, countdownText: TextLabel, gameTable: Model)
	if countdownText:GetAttribute("Active") then
		return
	end

	countdownText.Visible = true
	countdownText:SetAttribute("Active", true)

	task.spawn(function()
		for i = CountdownTime, 0, -1 do
			if not countdownText:GetAttribute("Active") then
				StopCountDown(countdownText)
				return
			end
			countdownText.Text = tostring(math.clamp(i, 0, CountdownTime))
			task.wait(1)
		end

		-- one last check
		if not countdownText:GetAttribute("Active") then
			StopCountDown(countdownText)
			return
		end

		-- succesfully counted down without players leaving
		countdownText.Visible = false
		playerCountText.Visible = false

		print("Start game!")
		GameModule.BeginGame(gameTable)
	end)
end

function ChairRemote:Handle()
	Remotes.ChairSat.OnServerEvent:Connect(function(player: Player, gameTable, sat: boolean)
		local playerCountText: TextLabel = gameTable
			:FindFirstChild("Bomb")
			:FindFirstChild("PlayersJoinedBillboard")
			:FindFirstChildOfClass("TextLabel", true)

		local countdownText: TextLabel = gameTable
			:FindFirstChild("Bomb")
			:FindFirstChild("CountdownBillboard")
			:FindFirstChildOfClass("TextLabel", true)

		-- get players joined count
		local currentJoined = playerCountText:GetAttribute("JoinedCount")
		print(currentJoined)
		local newCurrentJoined = sat and math.clamp(currentJoined + 1, 0, 2) or math.clamp(currentJoined - 1, 0, 2)
		playerCountText:SetAttribute("JoinedCount", newCurrentJoined)
		playerCountText.Text = `<b>Players Joined: {newCurrentJoined}/2</b>`

		-- add player reference to table's ID dictionary (on server)
		if sat then
			BombGameStorage.AssignPlayerToTable(gameTable:GetAttribute("ID"), player)
		else
			BombGameStorage.UnAssignSinglePlayerFromTable(gameTable:GetAttribute("ID"), player)
		end

		print(playerCountText:GetAttribute("JoinedCount"))

		-- start countdown if 2 players sat down
		if newCurrentJoined == 2 then
			StartCountDown(playerCountText, countdownText, gameTable)
		end

		-- stop countdown if 1 player
		if not sat and countdownText:GetAttribute("Active") then
			countdownText:SetAttribute("Active", false)
			gameTable:SetAttribute("GameActive", false)
		end
	end)
end

return ChairRemote
