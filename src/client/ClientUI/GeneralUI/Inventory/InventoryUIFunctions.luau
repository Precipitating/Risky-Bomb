local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local CommonUIFunctions =
	require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.GeneralUI.CommonUIFunctions.CommonUIFunctions)
local RarityColor = require(ReplicatedStorage.Config.RarityColor)
local UICharms = require(ReplicatedStorage.Charms.UICharms)
local ItemToDisplayName = require(ReplicatedStorage.Config.ItemToDisplayName)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local UtilityModule = require(ReplicatedStorage.Utility.UtilityModule)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local DataService = require(ReplicatedStorage.Packages.DataService).client
local InventoryUIFunctions = {}

InventoryUIFunctions.networker = Networker.new("InventoryRemotes", InventoryUIFunctions)
InventoryUIFunctions.janitor = Janitor.new()
local spinTweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1)
local FullItemList = {}

local function GetScrollFrameOfCategory(category: string)
	local parentPath = UtilityModule.Get(PlayerContext.PlayerGui, "GeneralGUI", "Inventory", `{category}`)
	if not parentPath then
		error(`UI Reference to {category} not found`)
	end
	return parentPath
end

local function EquipItem(imageButton: ImageButton, category: string, item)
	-- equip item
	imageButton.Activated:Connect(function()
		local result = InventoryUIFunctions.networker:fetch("EquipItem", category, item.Name, item.Material, item.Color)
		if not result then
			warn("Failed to set inventory item")
			SoundManager.PlayExistingSound(SoundManager.UISounds.Error)
			return false
		end
		SoundManager.PlayExistingSound(SoundManager.UISounds.Success)
		return true
	end)
end

local function SetItemLayoutOrder(imageButton: ImageButton, item)
	if item.Name == "Default" then
		imageButton.LayoutOrder = -999
	else
		imageButton.LayoutOrder = -item.RarityChance
	end
end

local function SetItemColorAndMaterial(objectClone, surfaceAppearance: SurfaceAppearance?, item)
	if surfaceAppearance then
		if not surfaceAppearance then
			warn("VIEWPORT OBJECT HAS NO SURFACE APPERANCE?")
			return
		end
		surfaceAppearance.Color = BrickColor.new(item.Color).Color
	else
		objectClone.Material = Enum.Material[item.Material]
		objectClone.BrickColor = BrickColor.new(item.Color)
	end
end

-- interaction connections
local function ImageButtonConnections(imageButton: ImageButton, category: string, objectClone, item)
	-- spin
	TweenService:Create(objectClone, spinTweenInfo, { Orientation = objectClone.Orientation + Vector3.new(0, 360, 0) })
		:Play()

	-- tooltip visibility events
	imageButton.MouseEnter:Connect(function()
		UICharms.CurrentToolTipInfo({
			ItemName = `<font color="{UtilityModule.RGBToHex(RarityColor[item.RarityChance])}">Name: {ItemToDisplayName[item.Name] or item.Name}</font>`,
			ItemColor = `<font color="{UtilityModule.RGBToHex(BrickColor.new(item.Color).Color)}">Color: {item.Color}</font>`,
			ItemMaterial = `<font color="#4D7C0F">Material: {item.Material}</font>`,
		})
		UICharms.ToolTipOpen(true)
	end)

	-- reset info for tooltip when unhovered
	imageButton.MouseLeave:Connect(function()
		UICharms.CurrentToolTipInfo({
			ItemName = "???",
			ItemColor = "???",
			ItemMaterial = "???",
			Position = { X = 0.5, Y = 0.5 },
		})
		UICharms.ToolTipOpen(false)
	end)

	EquipItem(imageButton, category, item)
end

local function SpawnViewportButton(category: string, object, item)
	local parentPath = GetScrollFrameOfCategory(category)
	local imageButton: ImageButton = Instance.new("ImageButton")
	local viewPort: ViewportFrame = Instance.new("ViewportFrame")
	local objectClone = object:Clone()
	local camera: Camera = Instance.new("Camera")
	local corner: UICorner = Instance.new("UICorner")
	local surfaceAppearance: SurfaceAppearance? = objectClone:FindFirstChildOfClass("SurfaceAppearance")

	-- set properties for required objects
	corner.CornerRadius = UDim.new(0.1, 0)
	corner.Parent = viewPort

	imageButton.BackgroundTransparency = 1
	imageButton.ImageTransparency = 1
	imageButton.Name = item.Name
	imageButton.AnchorPoint = Vector2.new(0.5, 0.5)

	viewPort.BackgroundColor3 = RarityColor[item.RarityChance]
	viewPort.Parent = imageButton
	viewPort.CurrentCamera = camera
	viewPort.Size = UDim2.fromScale(1, 1)

	-- common -> legendary rarity ascending
	SetItemLayoutOrder(imageButton, item)

	-- make camera face the object, via its max dimensions, default skin will be first no matter what
	CommonUIFunctions.CameraLookAtObject(camera, objectClone)

	SetItemColorAndMaterial(objectClone, surfaceAppearance, item)
	ImageButtonConnections(imageButton, category, objectClone, item)

	objectClone.Parent = viewPort
	camera.Parent = viewPort
	imageButton.Parent = parentPath

	InventoryUIFunctions.janitor:Add(imageButton)
end

-- -1 rarity filter means ALL
-- this function similar to OpenInventoryOf, but uses FullItemList to stop having to repopulate itself again for efficiency.
function InventoryUIFunctions:FilterRarity(category: string, rarityFilter: number)
	if #FullItemList <= 0 then
		error("Empty item list")
	end
	self.janitor:Cleanup()
	local searchPath, _ = InventoryUIFunctions.GetCategoryData(category)
	local scrollFrame = GetScrollFrameOfCategory(category)
	for _, item in ipairs(FullItemList) do
		if rarityFilter and rarityFilter ~= -1 and item.RarityChance ~= rarityFilter then
			continue
		end
		local ownedObject = searchPath:FindFirstChild(item.Name, true)
		if not ownedObject then
			warn(`Can't find {item.Name} in ReplicatedStorage `)
			continue
		end
		SpawnViewportButton(category, ownedObject, item)
	end
	scrollFrame.CanvasPosition = Vector2.new(0, 0)
end

-- gets the inventory data store key depending on category input
function InventoryUIFunctions.GetCategoryData(category: string)
	local inventoryList = nil
	local searchPath = nil
	if category == "ChairPage" then
		inventoryList = DataService:get({ "chairsOwned" })
		searchPath = ReplicatedStorage.Chairs
	elseif category == "BombPage" then
		inventoryList = DataService:get({ "bombsOwned" })
		searchPath = ReplicatedStorage.Bombs
	else
		error(`Error, failed to get inventory of {category}`)
	end

	return searchPath, inventoryList
end

-- goes through inventory datastore and spawn every item in the specified category
-- also stores all the items in a table
function InventoryUIFunctions.OpenInventoryOf(category: string)
	table.clear(FullItemList)
	InventoryUIFunctions.janitor:Cleanup()

	local searchPath, inventoryList = InventoryUIFunctions.GetCategoryData(category)
	for _, item in ipairs(inventoryList) do
		local ownedObject = searchPath:FindFirstChild(item.Name, true)

		if not ownedObject then
			warn(`Can't find {item.Name} in ReplicatedStorage `)
			continue
		end

		SpawnViewportButton(category, ownedObject, item)
		table.insert(FullItemList, item)
	end
end

return InventoryUIFunctions
