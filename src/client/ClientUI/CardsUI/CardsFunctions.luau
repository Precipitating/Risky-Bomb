local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BombGameCharms = require(ReplicatedStorage.Shared.Charms.BombGameCharms)
local Networker = require(ReplicatedStorage.Shared.Packages.Networker).client

local CardsFunctions = {}
CardsFunctions.CardActivated = false
CardsFunctions.networker = Networker.new("CardsNetwork", CardsFunctions)

function CardsFunctions:ReceiveRandomCardFromServer(cardFromServer)
	BombGameCharms.CardUsed(false)
	BombGameCharms.CurrentCard(cardFromServer)
	print(cardFromServer)

	if not BombGameCharms.CurrentCard() then
		warn("Server sent an invalid card to assign to player")
	end
end

function CardsFunctions:UseCard()
	if not self.CardActivated then
		warn("Attempting to use card when card hasn't activated?")
		return
	end
	local card = BombGameCharms.CurrentCard()
	if not card then
		warn("Can't use card from client, AssignCard is nil")
	end

	self.networker:fire("UseCard", card.KeyName, BombGameCharms.CurrentBombInput())
	print("Card used!")

	BombGameCharms.CurrentCard({})
	self.CardActivated = false
end

return CardsFunctions
