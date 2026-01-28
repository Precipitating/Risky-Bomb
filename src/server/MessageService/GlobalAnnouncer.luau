local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local ServerScriptService = game:GetService("ServerScriptService")
local GUIRemotes = require(ServerScriptService.Server.ServerRemotesLogic.GUIRemotes)
local GlobalAnnouncerDataStore = DataStoreService:GetDataStore("CurrentDonationStore")
local GlobalAnnouncer = {}

function GlobalAnnouncer.Initialize()
	--GlobalAnnouncerDataStore:RemoveAsync("Message")
	MessagingService:SubscribeAsync("GlobalMessage", function(message)
		GUIRemotes.networker:fireAll("UpdateDonationText", message)
	end)
end

function GlobalAnnouncer.FireGlobalMessage(text: string)
	local success, _ = pcall(function()
		GlobalAnnouncerDataStore:UpdateAsync("Message", function(_)
			return text
		end)
	end)

	-- not a big deal if failed, but used for new joiners to get the latest donation message
	if not success then
		warn("Can't set the last donation message to data store")
	end

	MessagingService:PublishAsync("GlobalMessage", {
		Message = text,
	})
end

return GlobalAnnouncer
