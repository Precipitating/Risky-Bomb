local BombGameStorage = {}
local PlayersPlayingList = {}
local GameTablesList = {}
function BombGameStorage.GetPlayerList()
	return PlayersPlayingList
end

function BombGameStorage.GetGameTablesList()
	return GameTablesList
end

return BombGameStorage
