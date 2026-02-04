local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Shared.Packages.Networker).server
local CardData = require(script.Parent.CardData)

local CardHandler = {}

type CardData = CardData.CardData

function CardHandler:SetRandomCardForPlayer(player: Player)
	local cardChosen = CardData[CardData.GetRandomCard()]
	self.networker:fire(player, "ReceiveRandomCardFromServer", cardChosen)
end
function CardHandler:UseCard(player: Player, cardKeyName: string, bombInput: number)
	if not cardKeyName then
		error("cardOwned is nil!")
	end
	print(cardKeyName)
	CardData[cardKeyName].Use(player, bombInput)
end
CardHandler.networker = Networker.new("CardsNetwork", CardHandler, { CardHandler.UseCard })
return CardHandler
