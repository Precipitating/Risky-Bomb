local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local CommonUIFunctions =
	require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.GeneralUI.CommonUIFunctions.CommonUIFunctions)
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local RarityColor = require(ReplicatedStorage.Config.RarityColor)
local Rarity = require(ReplicatedStorage.Config.Rarity)
local UICharms = require(ReplicatedStorage.Charms.UICharms)
local UtilityModule = require(ReplicatedStorage.Utility.UtilityModule)
local PackType = require(ReplicatedStorage.Types.PackType)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local ShopUIFunctions = {}

ShopUIFunctions.networker = Networker.new("InGamePurchaseRemotes", ShopUIFunctions)
ShopUIFunctions.janitor = Janitor.new()

-- tweens
local spinTweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1)
local rollTweenInfo = TweenInfo.new(10, Enum.EasingStyle.Quart)
local skipTweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quart)

-- how many random spin items we should populate the scroll frame
local PoolCount = 45
-- the layout order of where the actual reward will appear
local WonItemLayoutOrder = 40

function ShopUIFunctions.AttemptPurchase(packType: number, packName: string)
	local isDuplicate, itemWon = ShopUIFunctions.networker:fetch("AttemptBuy", packType, packName)
	if not isDuplicate and not itemWon then
		SoundManager.PlayExistingSound(SoundManager.UISounds.Error)
		return nil
	end
	return isDuplicate, itemWon
end

local function SetViewportRarityColor(
	viewportFrame: ViewportFrame,
	packTable: { ItemList: {}, Cost: number },
	itemName: string
)
	local rarityOfItem = packTable.ItemList[itemName]

	viewportFrame.BackgroundColor3 = RarityColor[rarityOfItem]
end

local function CreateViewportUI(): ViewportFrame
	local viewportFrame = Instance.new("ViewportFrame")
	local corner = Instance.new("UICorner")
	local aspectRatio = Instance.new("UIAspectRatioConstraint")

	aspectRatio.Parent = viewportFrame
	aspectRatio.AspectType = Enum.AspectType.ScaleWithParentSize
	aspectRatio.DominantAxis = Enum.DominantAxis.Height

	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = viewportFrame

	viewportFrame.Size = UDim2.fromScale(1, 0.9)
	viewportFrame.AnchorPoint = Vector2.new(0.5, 0)

	return viewportFrame
end

local function PrepareViewportMesh(mesh: MeshPart): MeshPart
	local obj = mesh:Clone()
	obj.Parent = nil -- parent later
	local surfaceAppearance = obj:FindFirstChildOfClass("SurfaceAppearance")
	return obj, surfaceAppearance
end

local function SetupViewportCamera(viewport: ViewportFrame, mesh: MeshPart)
	local cam = Instance.new("Camera")
	cam.Parent = viewport
	viewport.CurrentCamera = cam
	CommonUIFunctions.CameraLookAtObject(cam, mesh)
end

local function StartSpinning(obj: MeshPart)
	TweenService:Create(obj, spinTweenInfo, { Orientation = obj.Orientation + Vector3.new(0, 360, 0) }):Play()
end

local function RandomSkinSwitching(obj: MeshPart, surfaceAppearance: SurfaceAppearance)
	local alive = true

	-- random color/material loop
	task.spawn(function()
		while alive do
			task.wait(1)
			if surfaceAppearance then
				surfaceAppearance.Color = UtilityModule.GetRandomColor().Color
			else
				obj.BrickColor = UtilityModule.GetRandomColor()
				obj.Material = UtilityModule.GetRandomMaterial()
			end
		end
	end)

	return function()
		alive = false
	end
end

local function OrderAscending(
	viewport: ViewportFrame,
	mesh: MeshPart,
	packTable: { ItemList: {}, Cost: number },
	ordered: boolean
)
	local itemRarity = -packTable.ItemList[mesh.Name]

	if ordered then
		viewport.LayoutOrder = itemRarity
	end
end

local function CreateViewportFrame(
	packTable: { ItemList: {}, Cost: number },
	mesh: MeshPart,
	skinSwitch: boolean,
	shouldOrder: boolean
)
	local viewport = CreateViewportUI()
	local obj, surfaceAppearance = PrepareViewportMesh(mesh)
	obj.Parent = viewport

	SetupViewportCamera(viewport, obj)
	StartSpinning(obj)
	SetViewportRarityColor(viewport, packTable, mesh.Name)
	viewport.Name = mesh.Name

	if skinSwitch then
		local stopSkinSwapping = RandomSkinSwitching(obj, surfaceAppearance)
		viewport.Destroying:Connect(function()
			stopSkinSwapping()
		end)
	else
		obj.BrickColor = UtilityModule.GetRandomColor()
		local materialRolled = UtilityModule.RollMaterial(obj.Name)
		if materialRolled == "None" then
			if surfaceAppearance then
				surfaceAppearance.Color = UtilityModule.GetRandomColor().Color
			end
		else
			obj.Material = materialRolled
		end
	end

	if shouldOrder then
		OrderAscending(viewport, obj, packTable, true)
	end

	ShopUIFunctions.janitor:Add(viewport)
	return viewport
end

function ShopUIFunctions:RemoveOldViewports()
	self.janitor:Cleanup()
	print("should cleanup viewport connections")
end

-- the server should return result before spin occurs
local function CreateActualRewardViewport(
	packTable: { ItemList: {}, Cost: number },
	mesh: MeshPart,
	itemWon: {
		Name: string,
		RarityChance: number,
		Material: string,
		Color: string,
	}?
)
	if not itemWon then
		warn("Missing item won table")
		return
	end

	local viewport = CreateViewportUI()
	local obj, surfaceAppearance = PrepareViewportMesh(mesh)
	obj.Parent = viewport
	SetupViewportCamera(viewport, obj)

	-- apply skin color
	if surfaceAppearance then
		surfaceAppearance.Color = BrickColor.new(itemWon.Color :: any).Color
	else
		obj.BrickColor = BrickColor.new(itemWon.Color :: any)
	end

	SetViewportRarityColor(viewport, packTable, mesh.Name)
	StartSpinning(obj)
	viewport.Name = mesh.Name

	return viewport
end
local function GetScrollFrameRef(isSpinMode: boolean)
	local lootTableFolder = nil
	if not isSpinMode then
		lootTableFolder =
			UtilityModule.Get(PlayerContext.PlayerGui, "GeneralGUI", "Shop", "ConfirmationPrompt", "LootTable")
	else
		lootTableFolder = UtilityModule.Get(PlayerContext.PlayerGui, "GeneralGUI", "Shop", "SpinTable")
	end

	return lootTableFolder
end

-- get the position to where the marker lands perfectly in the middle of an item
local function MarkerToItemPosition(
	wonItemViewport: ViewportFrame,
	scrollFrameRef: ScrollingFrame,
	scrollMarkerRef: Frame
)
	if wonItemViewport then
		local itemCenter = (
			(wonItemViewport.AbsolutePosition.X - scrollFrameRef.AbsolutePosition.X)
			+ scrollFrameRef.CanvasPosition.X
			+ (wonItemViewport.AbsoluteSize.X * 0.5)

		)
		local markerCenter = scrollMarkerRef.AbsolutePosition.X
			- scrollFrameRef.AbsolutePosition.X
			+ scrollFrameRef.CanvasPosition.X

		local target = itemCenter - markerCenter

		return target
	end

	return nil
end

local function PlayRewardSound(rarity: number)
	if rarity == Rarity.Common then
		SoundManager.PlayExistingSound(SoundManager.UISounds.Common)
	elseif rarity == Rarity.Rare then
		SoundManager.PlayExistingSound(SoundManager.UISounds.Rare)
	elseif rarity == Rarity.Epic then
		SoundManager.PlayExistingSound(SoundManager.UISounds.Epic)
	elseif rarity == Rarity.Legendary then
		SoundManager.PlayExistingSound(SoundManager.UISounds.Legendary)
	end
end

local function GetPackFolder(packType: number)
	local packTypeString = ""
	if packType == PackType.ChairPack then
		packTypeString = "Chairs"
	elseif packType == PackType.BombPack then
		packTypeString = "Bombs"
	end

	return packTypeString
end
--
local function DisplayPackLoot(folder, packTable, scrollFrameRef)
	print("Show loot pool mode")
	-- spawn each viewport frame into the scrolling frame
	for _, mesh in ipairs(folder) do
		local viewport = CreateViewportFrame(packTable, mesh, true, true)
		viewport.Parent = scrollFrameRef
	end
end

local function CreateWonItemViewport(itemWon, folder, packTable, scrollFrameRef)
	local viewport: ViewportFrame? = nil

	UtilityModule.GetItemMeshCalled(itemWon.Name, folder, function(mesh)
		viewport = CreateActualRewardViewport(packTable, mesh, itemWon)

		if not viewport then
			error("Won item viewport reference nil")
		end

		viewport.LayoutOrder = WonItemLayoutOrder
		viewport.Parent = scrollFrameRef
	end)

	if not viewport then
		error("Won item viewport missing")
	end

	return viewport
end

local function FillPoolWithRandomItems(packTable, folder, scrollFrameRef, scrollMarkerRef)
	local markerPassPositions = {}

	for i = 1, PoolCount do
		local randomItem = UtilityModule.GetRandomPackItem(packTable)
		local mesh = UtilityModule.GetItemMeshCalled(randomItem.Name, folder)
		local viewport = CreateViewportFrame(packTable, mesh, false, false)

		if viewport.LayoutOrder ~= WonItemLayoutOrder then
			viewport.LayoutOrder = i
		end

		viewport.Parent = scrollFrameRef

		table.insert(markerPassPositions, MarkerToItemPosition(viewport, scrollFrameRef, scrollMarkerRef))
	end

	return markerPassPositions
end

local function SetupTickSound(scrollFrameRef, markerPassPositions)
	local currIdx = 1

	return RunService.RenderStepped:Connect(function()
		if scrollFrameRef.CanvasPosition.X > markerPassPositions[currIdx] then
			currIdx += 1
			SoundManager.PlayExistingSound(SoundManager.UISounds.Tick)
		end
	end)
end

local function CreateSpinTween(scrollFrameRef, target)
	return TweenService:Create(scrollFrameRef, rollTweenInfo, { CanvasPosition = Vector2.new(target, 0) })
end

local function LootSpin(itemWon, folder, packTable, scrollFrameRef)
	local scrollMarkerRef: Frame = UtilityModule.Get(PlayerContext.PlayerGui, "GeneralGUI", "Shop", "SpinTableMarker")

	print("Spinning pool mode")

	if not itemWon then
		warn("Can't get item won")
		return
	end

	-- 1. create won item viewport
	local wonItemViewport = CreateWonItemViewport(itemWon, folder, packTable, scrollFrameRef)

	-- 2. fill pool and collect marker positions
	local markerPassPositions = FillPoolWithRandomItems(packTable, folder, scrollFrameRef, scrollMarkerRef)

	-- 3. compute tween target
	local target = MarkerToItemPosition(wonItemViewport, scrollFrameRef, scrollMarkerRef)

	local tween = CreateSpinTween(scrollFrameRef, target)

	-- 4. tick sound listener
	ShopUIFunctions.janitor:Add(SetupTickSound(scrollFrameRef, markerPassPositions))

	-- 5. completion logic
	local completeConn = tween.Completed:Connect(function()
		PlayRewardSound(itemWon.RarityChance)
		UICharms.PackBought(false)
		ShopUIFunctions:RemoveOldViewports()
	end)

	UICharms.SpinTweenHandle({
		Tween = tween,
		CompleteConn = completeConn,
		Target = target,
		ItemWonRarityChance = itemWon.RarityChance,
	})

	tween:Play()
end

function ShopUIFunctions.SpawnLootTable(
	packType: number,
	packName: string,
	isSpinMode: boolean,
	itemWon: {
		Name: string,
		RarityChance: number,
		Material: string,
		Color: string,
	}?
)
	local packTypeString = GetPackFolder(packType)

	local folder = UtilityModule.GetMeshFolderListOf(packTypeString, packName)
	local packTable = UtilityModule.GetPackList(packType, packName)
	local scrollFrameRef: ScrollingFrame = nil

	-- determine parent
	scrollFrameRef = GetScrollFrameRef(isSpinMode)

	if isSpinMode then
		LootSpin(itemWon, folder, packTable, scrollFrameRef)
		return
	end

	-- view loot table
	DisplayPackLoot(folder, packTable, scrollFrameRef)
end

function ShopUIFunctions.SkipSpin()
	local currentSpinInfo = UICharms.SpinTweenHandle()
	local itemRarity = currentSpinInfo.ItemWonRarityChance

	-- cancel current tween and connections
	currentSpinInfo.Tween:Cancel()
	currentSpinInfo.CompleteConn:Disconnect()

	-- create new tween with a shortened duration time
	local scrollFrameRef = GetScrollFrameRef(true)
	local tween =
		TweenService:Create(scrollFrameRef, skipTweenInfo, { CanvasPosition = Vector2.new(currentSpinInfo.Target, 0) })

	tween:Play()
	tween.Completed:Connect(function()
		PlayRewardSound(itemRarity)
		UICharms.PackBought(false)
		ShopUIFunctions:RemoveOldViewports()
	end)

	-- shouldn't need the previous tween info anymore.
	currentSpinInfo = {}
end

return ShopUIFunctions
