local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService").Server
local RandomModule = require(ReplicatedStorage.RandomModule)
local AIDifficultyConfig = require(script.Parent.AIDifficultyConfig)
local GameTableAssigner = require(ServerScriptService.BombGame.GameTableAssigner)
local GameModule = require(ServerScriptService.BombGame.GameModule)
local GUIRemotes = require(ServerScriptService.ServerRemotesLogic.GUIRemotes)
local Networker = require(ReplicatedStorage.Packages.Networker).server
local AIFolder = ServerStorage.Models.AI:GetChildren()
local GUINetwork = GUIRemotes.networker
local SinglePlayerHandler = {}

function SinglePlayerHandler:CanSinglePlayer(_: Player, tableID: string)
	local tableClass = GameTableAssigner.GetTableFromID(tableID)
	if not tableClass then
		return false
	end

	-- check for seats validity
	local seat1 = tableClass.TableRefs and tableClass.TableRefs.Seat1
	local seat2 = tableClass.TableRefs and tableClass.TableRefs.Seat2

	if not seat1 or not seat2 then
		return false
	end

	-- check for seat occupants
	local seat1Occupied = seat1.Occupant ~= nil
	local seat2Occupied = seat2.Occupant ~= nil

	local oneSeatOccupied = seat1Occupied or seat2Occupied
	local bothPlayersAssigned = tableClass.PlayersAssigned[1] ~= nil and tableClass.PlayersAssigned[2] ~= nil

	if tableClass.PlayerCount ~= 1 then
		return false
	end

	if not oneSeatOccupied then
		return false
	end

	if bothPlayersAssigned then
		return false
	end

	return true
end

function SinglePlayerHandler:StartSinglePlayer(player: Player, tableID: string)
	if not tableID or tableID == "" then
		return
	end
	if not self:CanSinglePlayer(player, tableID) then
		warn("Can't start game, player's missing from seat or two players on the seat")
		return
	end

	local tableClass = GameTableAssigner.GetTableFromID(tableID)
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
