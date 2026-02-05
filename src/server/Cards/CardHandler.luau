local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CardTypes = require(ServerScriptService.Server.ServerTypes.CardTypes)
local CardData = require(script.Parent.CardData)
local Networker = require(ReplicatedStorage.Shared.Packages.Networker).server
local CardHandler = {}

type CardData = CardTypes.CardData

function CardHandler:SetRandomCardForPlayer(player: Player)
	local cardChosen = CardData[CardData.GetRandomCard()]
	self.networker:fire(player, "ReceiveRandomCardFromServer", cardChosen)
end
-- should be used via client -> server remote call
function CardHandler:UseCard(player: Player, cardKeyName: string, bombInput: number)
	if not cardKeyName then
		error("cardOwned is nil!")
	end
	warn(`{cardKeyName} used!`)
	CardData[cardKeyName].Use(player, bombInput)
end

CardHandler.networker = Networker.new("CardsNetwork", CardHandler, { CardHandler.UseCard })
return CardHandler
