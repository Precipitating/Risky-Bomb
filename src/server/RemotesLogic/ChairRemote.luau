local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local CountdownTime: number = 3

local ChairRemote = {}

local function StopCountDown(countdownText: TextLabel)
	countdownText.Visible = false
	countdownText.Text = tostring(CountdownTime)
end

local function StartCountDown(countdownText: TextLabel)
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

		print("Start game!")
	end)
end

function ChairRemote:Handle()
	Remotes.ChairSat.OnServerEvent:Connect(function(_, gameTable, sat: boolean)
		local playerCountText: TextLabel = gameTable
			:FindFirstChild("Bomb")
			:FindFirstChild("PlayersJoinedBillboard")
			:FindFirstChildOfClass("TextLabel", true)

		local countdownText: TextLabel = gameTable
			:FindFirstChild("Bomb")
			:FindFirstChild("CountdownBillboard")
			:FindFirstChildOfClass("TextLabel", true)

		local currentJoined = playerCountText:GetAttribute("JoinedCount")
		local newCurrentJoined = sat and math.clamp(currentJoined + 1, 0, 2) or math.clamp(currentJoined - 1, 0, 2)

		playerCountText:SetAttribute("JoinedCount", newCurrentJoined)
		playerCountText.Text = `<b>Players Joined: {newCurrentJoined}/2</b>`

		if newCurrentJoined == 2 then
			StartCountDown(countdownText)
		end

		-- stop countdown if left
		if not sat and countdownText:GetAttribute("Active") then
			countdownText:SetAttribute("Active", false)
		end
	end)
end

return ChairRemote
