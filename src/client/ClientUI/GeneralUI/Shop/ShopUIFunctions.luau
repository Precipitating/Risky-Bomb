local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local CommonUIFunctions =
	require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.GeneralUI.CommonUIFunctions.CommonUIFunctions)
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local RarityColor = require(ReplicatedStorage.Config.RarityColor)
local UtilityModule = require(ReplicatedStorage.Utility.UtilityModule)
local PackType = require(ReplicatedStorage.Types.PackType)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local ShopUIFunctions = {}

ShopUIFunctions.networker = Networker.new("InGamePurchaseRemotes", ShopUIFunctions)
ShopUIFunctions.janitor = Janitor.new()
local spinTweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1)
local rollTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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
				surfaceAppearance.Color = BrickColor.random().Color
			else
				obj.BrickColor = BrickColor.random()
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
		viewport.LayoutOrder = -itemRarity
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
		obj.BrickColor = BrickColor.random()
		local materialRolled = UtilityModule.RollMaterial(obj.Name)
		if materialRolled == "None" then
			if surfaceAppearance then
				surfaceAppearance.Color = BrickColor.random().Color
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
		warn("Misisng item won table")
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
	local packTypeString = ""
	if packType == PackType.ChairPack then
		packTypeString = "Chairs"
	elseif packType == PackType.BombPack then
		packTypeString = "Bombs"
	end
	-- ensure packName matches the table name
	local folder = UtilityModule.GetMeshFolderListOf(packTypeString, packName)
	local packTable = UtilityModule.GetPackList(packType, packName)
	local lootTableFolder = nil

	-- determine parent
	if not isSpinMode then
		lootTableFolder =
			UtilityModule.Get(PlayerContext.PlayerGui, "GeneralGUI", "Shop", "ConfirmationPrompt", "LootTable")
	else
		lootTableFolder = UtilityModule.Get(PlayerContext.PlayerGui, "GeneralGUI", "Shop", "SpinTable")
	end

	-- view pack items
	if not isSpinMode then
		print("Normal loot pool mode")
		-- spawn each viewport frame into the scrolling frame
		for _, mesh in ipairs(folder) do
			local viewport = CreateViewportFrame(packTable, mesh, true, true)
			viewport.Parent = lootTableFolder
		end
	else
		-- bought pack, show spinning pack mode
		print("Spinning pool mode")
		if not itemWon then
			warn("Can't get item won")
			return
		end

		local poolCount = (#folder * 2) - 1
		local wonItemViewport: ViewportFrame | nil = nil
		-- add actual reward in pool with its properties
		UtilityModule.GetItemMeshCalled(itemWon.Name, folder, function(mesh)
			wonItemViewport = CreateActualRewardViewport(packTable, mesh, itemWon)
			if wonItemViewport then
				wonItemViewport.LayoutOrder = math.random(1, poolCount)
				wonItemViewport.Parent = lootTableFolder
			else
				error("Won item viewport reference nil")
				return
			end
		end)

		-- fill rest with random items
		for _ = 1, poolCount do
			local randomItem = UtilityModule.GetRandomPackItem(packTable)
			local mesh = UtilityModule.GetItemMeshCalled(randomItem.Name, folder)
			local viewport = CreateViewportFrame(packTable, mesh, false, false)
			viewport.LayoutOrder = math.random(1, poolCount)
			viewport.Parent = lootTableFolder
		end

		-- tween scroll

		if wonItemViewport then
			local targetXPos = 100
			local tween = TweenService
				:Create(lootTableFolder, rollTweenInfo, { CanvasPosition = Vector2.new(targetXPos, 0) })
				:Play()
		end
	end
end

return ShopUIFunctions
