local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local ModularImageButtonUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularImageButtonUI)
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local React = require(ReplicatedStorage.Packages.React)
local BombPacksData = require(ReplicatedStorage.Config.BombPacksData)
local ChairPacksData = require(ReplicatedStorage.Config.ChairPacksData)
local VIPHandler = require(ReplicatedStorage.VIP.VIPHandler)
local PackType = require(ReplicatedStorage.Types.PackType)
local e = React.createElement

type ShopPackDisplayerUIProps = {
	Position: UDim2,
	Size: UDim2,
	AspectRatio: number?,
	StrokeColor: Color3?,
	BackgroundColor: Color3?,
	BackgroundTransparency: boolean?,
	AnchorPoint: Vector2?,
	IsOpen: boolean,
	ConfirmationSetOpen: (boolean) -> (),
	PackType: number,
	PackSetType: (number) -> (),
	PackSetName: (string) -> (),
	PackSetPrice: (string) -> (),
}

local function GetImageId(bombID: string, chairID: string, props: ShopPackDisplayerUIProps)
	if props.PackType == PackType.BombPack then
		return bombID
	else
		return chairID
	end
end

local function GetPriceOfPack(packType: number, packName: string)
	local isVIP = VIPHandler.IsVIP(PlayerContext.Player)
	local result = "???"
	if packType == PackType.BombPack then
		if isVIP then
			result = tostring(BombPacksData[packName].Cost - (BombPacksData[packName].Cost * 0.2))
		else
			result = tostring(BombPacksData[packName].Cost)
		end
	elseif packType == PackType.ChairPack then
		if isVIP then
			result = tostring(ChairPacksData[packName].Cost - (ChairPacksData[packName].Cost * 0.2))
		else
			result = tostring(ChairPacksData[packName].Cost)
		end
	end

	return result
end

local function ShopPackDisplayerUI(props: ShopPackDisplayerUIProps)
	if not props.IsOpen then
		return nil
	end
	return e("ScrollingFrame", {
		Position = props.Position,
		Size = props.Size,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 1),
		BackgroundTransparency = 1,
		Visible = props.IsOpen,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarImageColor3 = Color3.fromRGB(255, 1, 1),
		AnchorPoint = props.AnchorPoint,
	}, {

		UIList = e("UIListLayout", {
			Padding = UDim.new(0.02, 0),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		}),
		_95Pack = ModularImageButtonUI({
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.11),
			BackgroundTransparency = 1,
			ImageID = GetImageId("rbxassetid://71026580288153", "rbxassetid://110643834598127", props),
			OnClick = function()
				local packName = "NineToFivePack"
				props.PackSetName(packName)
				props.PackSetType(props.PackType)
				props.PackSetPrice(GetPriceOfPack(props.PackType, packName))
				props.ConfirmationSetOpen(true)
			end,
			IsOpen = props.IsOpen,
		}),
		BrainrotPack = ModularImageButtonUI({
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.11),
			BackgroundTransparency = 1,
			ImageID = GetImageId("rbxassetid://136780506331527", "rbxassetid://126547977248693", props),
			OnClick = function()
				local packName = "BrainrotPack"
				props.PackSetName(packName)
				props.PackSetType(props.PackType)
				props.PackSetPrice(GetPriceOfPack(props.PackType, packName))
				props.ConfirmationSetOpen(true)
			end,
			IsOpen = props.IsOpen,
		}),
		RetroPack = ModularImageButtonUI({
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0.11),
			BackgroundTransparency = 1,
			ImageID = GetImageId("rbxassetid://80834896765015", "rbxassetid://135308861179903", props),
			OnClick = function()
				local packName = "RetroPack"
				props.PackSetName(packName)
				props.PackSetType(props.PackType)
				props.PackSetPrice(GetPriceOfPack(props.PackType, packName))
				props.ConfirmationSetOpen(true)
			end,
			IsOpen = props.IsOpen,
		}),
	})
end

return ShopPackDisplayerUI
