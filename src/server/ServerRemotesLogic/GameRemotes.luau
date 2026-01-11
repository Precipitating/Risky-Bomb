local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerScriptService = game:GetService("ServerScriptService")
local UtilityModule = require(ReplicatedStorage.UtilityModule)
local BombGameStorage = require(ServerScriptService.Server.BombGame.BombGameStorage)
local BombHandler = require(ServerScriptService.Server.BombGame.BombHandler)
local GameModule = require(ServerScriptService.Server.BombGame.GameModule)
local Remotes = ReplicatedStorage.Remotes
local GameRemotes = {}

local function SubmitBombTimeRemote()
	Remotes.SubmitBombReduction.OnServerEvent:Connect(function(_: Player, tableID: string, timeToReduce: number)
		local tableRef = BombGameStorage.GetGameTable(tableID)
		local bombRef = UtilityModule.Get(tableRef, "Bomb")
		local newTime = BombHandler.ReduceBombTime(bombRef, timeToReduce)

		if newTime > 0 then
			GameModule.NextTurn(tableID)
		end
	end)
end

function GameRemotes.Handle()
	SubmitBombTimeRemote()
end

return GameRemotes
