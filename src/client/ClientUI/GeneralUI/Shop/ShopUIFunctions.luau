local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local RarityColor = require(ReplicatedStorage.Config.RarityColor)
local ChairPacksData = require(ReplicatedStorage.Config.ChairPacksData)
local UtilityModule = require(ReplicatedStorage.Utility.UtilityModule)
local PackType = require(ReplicatedStorage.Types.PackType)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local ShopUIFunctions = {}
ShopUIFunctions.networker = Networker.new("InGamePurchaseRemotes", ShopUIFunctions)
ShopUIFunctions.janitor = Janitor.new()

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
		viewportFrame.BackgroundColor3 = RarityColor[rarityOfItem]
	elseif packType == "Bombs" then
		--TODO
	end
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

	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = viewportFrame
	cam.Parent = viewportFrame
	local obj = mesh:Clone()
	obj.Parent = viewportFrame
	viewportFrame.CurrentCamera = cam

	obj.CFrame = CFrame.new(0, 0, -5)
	cam.CFrame = CFrame.new(Vector3.zero)
	viewportFrame.Size = UDim2.fromScale(1, 0.9)

	local packTable = ChairPacksData[packName].ItemList
	local itemRarity = packTable[obj.Name]
	print(obj.Name)
	print(itemRarity)

	viewportFrame.Name = `{itemRarity - 100}`

	SetViewportRarityColor(viewportFrame, packType, packName, mesh.Name)

	-- spin
	local conn = RunService.RenderStepped:Connect(function()
		obj.CFrame *= CFrame.Angles(0, math.rad(1), 0)
	end)

	-- random color/material display
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
		conn:Disconnect()
	end)

	ShopUIFunctions.janitor:Add(viewportFrame)

	return viewportFrame
end

function ShopUIFunctions:RemoveOldViewports()
	self.janitor:Cleanup()
	print("should cleanup")
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
