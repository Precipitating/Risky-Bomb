local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local CommonUIFunctions =
	require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.GeneralUI.CommonUIFunctions.CommonUIFunctions)
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local RarityColor = require(ReplicatedStorage.Config.RarityColor)
local ChairPacksData = require(ReplicatedStorage.Config.ChairPacksData)
local BombPacksData = require(ReplicatedStorage.Config.BombPacksData)
local UtilityModule = require(ReplicatedStorage.Utility.UtilityModule)
local PackType = require(ReplicatedStorage.Types.PackType)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local ShopUIFunctions = {}

ShopUIFunctions.networker = Networker.new("InGamePurchaseRemotes", ShopUIFunctions)
ShopUIFunctions.janitor = Janitor.new()
local spinTweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1)

function ShopUIFunctions.AttemptPurchase(packType: number, packName: string)
	local result = ShopUIFunctions.networker:fetch("AttemptBuy", packType, packName)
	if not result then
		SoundManager.PlayExistingSound(SoundManager.UISounds.Error)
		return false
	end
	return true
end

local function SetViewportRarityColor(viewportFrame: ViewportFrame, packType: string, packName: string, name: string)
	local rarityOfItem = nil

	if packType == "Chairs" then
		rarityOfItem = ChairPacksData[packName].ItemList[name]
	elseif packType == "Bombs" then
		rarityOfItem = BombPacksData[packName].ItemList[name]
	end
	viewportFrame.BackgroundColor3 = RarityColor[rarityOfItem]
end

local function GetItemListOf(packType: string, packName: string)
	if packType == "Chairs" then
		return ChairPacksData[packName].ItemList
	elseif packType == "Bombs" then
		return BombPacksData[packName].ItemList
	end

	error(`Pack type of {packType} doesn't exist!`)
end

local function CreateViewportFrame(packType: string, packName: string, mesh: MeshPart)
	local viewportFrame = Instance.new("ViewportFrame")
	local cam = Instance.new("Camera")
	local corner = Instance.new("UICorner")
	local aspectRatio = Instance.new("UIAspectRatioConstraint")
	local alive = true
	aspectRatio.Parent = viewportFrame
	aspectRatio.AspectType = Enum.AspectType.ScaleWithParentSize
	aspectRatio.DominantAxis = Enum.DominantAxis.Height

	-- setup the viewport to have camera and object
	-- and position camera to look at object at a suitable distance
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = viewportFrame
	cam.Parent = viewportFrame
	local obj = mesh:Clone()
	obj.Parent = viewportFrame
	viewportFrame.CurrentCamera = cam
	CommonUIFunctions.CameraLookAtObject(cam, mesh)
	viewportFrame.Size = UDim2.fromScale(1, 0.9)

	local packTable = GetItemListOf(packType, packName)
	local itemRarity = packTable[obj.Name]

	-- order from common -> rare
	viewportFrame.LayoutOrder = -itemRarity
	viewportFrame.Name = obj.Name

	SetViewportRarityColor(viewportFrame, packType, packName, mesh.Name)

	-- spin
	TweenService:Create(obj, spinTweenInfo, { Orientation = obj.Orientation + Vector3.new(0, 360, 0) }):Play()

	-- random color/material display for chairs only
	task.spawn(function()
		while alive do
			task.wait(1)
			obj.BrickColor = BrickColor.random()
			obj.Material = UtilityModule.GetRandomMaterial()
		end
	end)

	viewportFrame.Destroying:Connect(function()
		print("destroyed!")
		alive = false
	end)

	ShopUIFunctions.janitor:Add(viewportFrame)

	return viewportFrame
end

function ShopUIFunctions:RemoveOldViewports()
	self.janitor:Cleanup()
	print("should cleanup viewport connections")
end

function ShopUIFunctions.SpawnLootTable(packType: number, packName: string)
	local packTypeString = ""
	if packType == PackType.ChairPack then
		packTypeString = "Chairs"
	elseif packType == PackType.BombPack then
		packTypeString = "Bombs"
	end
	-- ensure packName matches the table name
	local folder = UtilityModule.Get(ReplicatedStorage, packTypeString, packName):GetChildren()

	local lootTableFolder =
		UtilityModule.Get(PlayerContext.PlayerGui, "GeneralGUI", "Shop", "ConfirmationPrompt", "LootTable")

	if folder then
		for _, mesh in pairs(folder) do
			print(mesh)
			local viewport = CreateViewportFrame(packTypeString, packName, mesh)
			viewport.Parent = lootTableFolder
		end
	else
		error("Can't find pack name. Double check the name is correct.")
	end
end

return ShopUIFunctions
