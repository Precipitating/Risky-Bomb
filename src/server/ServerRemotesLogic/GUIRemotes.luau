local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local Networker = require(ReplicatedStorage.Packages.Networker).server
local DonationStore = DataStoreService:GetDataStore("CurrentDonationStore")
local GUIRemotes = {}

function GUIRemotes.GetLastDonationMessage()
	print("OI")
	local msg = ""
	local success, err = pcall(function()
		msg = DonationStore:GetAsync("Message")
	end)

	if err then
		warn("Server can't get last donation message from store!")
	end

	return msg or "Donate to see your name here!"
end

GUIRemotes.networker = Networker.new("GUIRemotes", GUIRemotes, { GUIRemotes.GetLastDonationMessage })
return GUIRemotes
