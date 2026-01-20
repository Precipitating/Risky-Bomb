local DataStoreService = game:GetService("DataStoreService")
return {
	DonationStore = DataStoreService:GetOrderedDataStore("DonationBoard"),
	WinStore = DataStoreService:GetOrderedDataStore("WinsBoard"),
	InGameMoneyBoard = DataStoreService:GetOrderedDataStore("IngameMoneyBoard"),
}
