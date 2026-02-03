local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService").Server
local RandomModule = require(ReplicatedStorage.RandomModule)
local AIDifficultyConfig = require(script.Parent.AIDifficultyConfig)
local GameTableManager = require(ServerScriptService.BombGame.GameTableManager)
local GameModule = require(ServerScriptService.BombGame.GameModule)
local Networker = require(ReplicatedStorage.Packages.Networker).server
local AIFolder = ServerStorage.Models.AI:GetChildren()

local SinglePlayerHandler = {}

function SinglePlayerHandler:CanSinglePlayer(_: Player, tableID: string)
	local tableClass = GameTableManager.GetTableFromID(tableID)
	local bothSeatsOccupied = (tableClass.TableRefs.Seat1 and tableClass.TableRefs.Seat1.Occupant)
		and (tableClass.TableRefs.Seat2 and tableClass.TableRefs.Seat2.Occupant)

	local bothPlayerRefsSet = tableClass.PlayersAssigned[1] and tableClass.PlayersAssigned[2]

	if tableClass.PlayerCount ~= 1 or bothSeatsOccupied or bothPlayerRefsSet then
		warn("Can't initialize singleplayer, two people are sitting down!")
		return false
	end

	return true
end

function SinglePlayerHandler:StartSinglePlayer(_: Player, tableID: string)
	local tableClass = GameTableManager.GetTableFromID(tableID)
	tableClass.AIConfig.AIMode = true
	local aiModel = AIFolder[RandomModule.GetRandomNumberBetween(1, #AIFolder)]:Clone()

	-- destroy the empty chair & put a random AI model in place of it
	if tableClass.TableRefs.Seat1.Occupant == nil then
		aiModel:PivotTo(tableClass.TableRefs.Chair1:GetPivot())
		aiModel.Parent = tableClass.TableRefs.Parent
		tableClass:RemoveChair(1)
	else
		aiModel:PivotTo(tableClass.TableRefs.Chair2:GetPivot())
		aiModel.Parent = tableClass.TableRefs.Parent
		tableClass:RemoveChair(2)
	end
	tableClass.AIConfig.AIModel = aiModel
	tableClass.TableRefs.CountdownText.Visible = false
	tableClass.TableRefs.PlayersJoinedText.Visible = false
	tableClass.AIConfig.AIDifficultyConfig = AIDifficultyConfig[AIDifficultyConfig.GetRandomDifficulty()]

	-- start it
	GameModule.BeginGame(tableClass)
end

SinglePlayerHandler.networker = Networker.new(
	"SingleplayerNetwork",
	SinglePlayerHandler,
	{ SinglePlayerHandler.CanSinglePlayer, SinglePlayerHandler.StartSinglePlayer }
)
return SinglePlayerHandler
