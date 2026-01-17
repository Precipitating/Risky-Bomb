local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local RarityColor = require(ReplicatedStorage.Config.RarityColor)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local Networker = require(ReplicatedStorage.Packages.Networker).client
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local DataService = require(ReplicatedStorage.Packages.DataService).client
local InventoryUIFunctions = {}
InventoryUIFunctions.networker = Networker.new("InventoryRemotes", InventoryUIFunctions)

local function SpawnViewportButton(category: string, object, item)
	local parentPath =
		PlayerContext.PlayerGui:FindFirstChild("GeneralGUI"):FindFirstChild("Inventory"):WaitForChild(category)
	if not parentPath then
		error(`UI Reference to {category} not found`)
	end

	local imageButton: ImageButton = Instance.new("ImageButton")
	local viewPort: ViewportFrame = Instance.new("ViewportFrame")
	local objectClone = object:Clone()
	local camera: Camera = Instance.new("Camera")
	local corner: UICorner = Instance.new("UICorner")

	corner.CornerRadius = UDim.new(0.1, 0)
	corner.Parent = viewPort

	imageButton.BackgroundTransparency = 1
	imageButton.ImageTransparency = 1
	imageButton.Name = tostring(item.RarityChance)

	objectClone.CFrame = CFrame.new(0, 0, -5)
	objectClone.Parent = viewPort
	objectClone.Material = item.Material
	objectClone.BrickColor = item.Color

	camera.CFrame = CFrame.new(Vector3.zero)
	camera.Parent = viewPort

	viewPort.BackgroundColor3 = RarityColor[item.RarityChance]
	viewPort.Parent = imageButton
	viewPort.CurrentCamera = camera
	viewPort.Size = UDim2.fromScale(1, 1)

	imageButton.Parent = parentPath

	-- spin
	local conn = RunService.RenderStepped:Connect(function()
		objectClone.CFrame *= CFrame.Angles(0, math.rad(1), 0)
	end)

	imageButton.Destroying:Connect(function()
		print("destroyed!")
		conn:Disconnect()
	end)

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

function InventoryUIFunctions.OpenInventoryOf(category: string)
	local inventoryList = nil
	local searchPath = nil
	if category == "chairs" then
		inventoryList = DataService:get({ "chairsOwned" })
		print(inventoryList)
		searchPath = ReplicatedStorage.Chairs
		category = "ChairPage"
	elseif category == "bombs" then
		inventoryList = DataService:get({ "bombsOwned" })
		searchPath = ReplicatedStorage.Bombs
		category = "BombPage"
	else
		error(`Error, failed to get inventory of {category}`)
	end

	for _, item in ipairs(inventoryList) do
		local ownedObject = searchPath:FindFirstChild(item.Name, true)
		if not ownedObject then
			warn(`Can't find {item.Name} in ReplicatedStorage `)
			continue
		end
		SpawnViewportButton(category, ownedObject, item)
	end
end

return InventoryUIFunctions
