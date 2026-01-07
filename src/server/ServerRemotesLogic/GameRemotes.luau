local ServerScriptService = game:GetService("ServerScriptService")
local BombHandler = require(ServerScriptService.Server.BombGame.BombHandler)
local GameModule = require(ServerScriptService.Server.BombGame.GameModule)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Remotes = ReplicatedStorage.Remotes
local GameRemotes = {}

local function SubmitBombTimeRemote()
	Remotes.SubmitBombReduction.OnServerEvent:Connect(function(_: Player, tableRef: Model, timeToReduce: number)
		local bombRef = tableRef:FindFirstChild("Bomb")
		local newTime = BombHandler.ReduceBombTime(bombRef, timeToReduce)

		if newTime > 0 then
			local id = tableRef:GetAttribute("ID")
			GameModule.NextTurn(id)
		end
	end)
end

function GameRemotes.Handle()
	SubmitBombTimeRemote()
end

return GameRemotes
