local AssetService = game:GetService("AssetService")
local ContentProvider = game:GetService("ContentProvider")
local ServerScriptService = game:GetService("ServerScriptService")
local DataTemplate = require(ServerScriptService.Server.ServerData.DataTemplate)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker).server

local InventoryEvents = {}

function InventoryEvents.ResetSkin(type: string, object: MeshPart)
	local skinModel: MeshPart = ReplicatedStorage:FindFirstChild(type):FindFirstChild("Default", true)
	if not skinModel then
		warn(`Can't find default {type} mesh`)
		return
	end
	local newMesh = AssetService:CreateMeshPartAsync(skinModel.MeshId)
	object:ApplyMesh(newMesh)
	object.TextureID = skinModel.TextureID
	object.Material = skinModel.Material
	object.Size = skinModel.Size
	object.CFrame *= object.PivotOffset:Inverse()
	object.PivotOffset = CFrame.identity
	newMesh:Destroy()
end

local function GetEquippedObjectName(player: Player, equipKey: string)
	local objectEquipped = DataService:get(player, { equipKey })
	if not objectEquipped then
		warn(`Cannot get {equipKey}, check key is accessed properly.`)
		return nil
	end

	return objectEquipped
end

-- playerOrEquippedName = if player then get the equipped object manually, if string then its already done, so skip ahead
function InventoryEvents.SetEquippedSkin(equipKey: string, objectType: string, playerOrTable, object: MeshPart)
	local objectEquipped = nil
	if typeof(playerOrTable) == "table" then
		objectEquipped = playerOrTable
	elseif playerOrTable:IsA("Player") then
		objectEquipped = GetEquippedObjectName(playerOrTable, equipKey)
	else
		error("Wrong input data submitted for objectEquipped")
	end

	object.Transparency = 1
	local skinMesh: MeshPart =
		ReplicatedStorage:FindFirstChild(objectType):FindFirstChild(objectEquipped.Name, true):Clone()
	if not skinMesh then
		warn(`Can't find MeshPart {objectEquipped.Name}`)
		return
	end
	object.PivotOffset = skinMesh.PivotOffset
	skinMesh:PivotTo(object:GetPivot())
	object.CFrame *= skinMesh.PivotOffset

	local newMesh = AssetService:CreateMeshPartAsync(skinMesh.MeshId)
	object:ApplyMesh(newMesh)
	if objectEquipped.Name == "Default" then
		object.TextureID = skinMesh.TextureID
	end

	-- update mesh's info to match equipped chair
	object.BrickColor = objectEquipped.Color
	object.Size = skinMesh.Size
	object.Material = objectEquipped.Material

	-- set the new skin's seat position - it may be different
	if equipKey == "chairEquipped" then
		local chairSeat = object:FindFirstChildOfClass("Seat")
		local skinMeshSeat = skinMesh:FindFirstChildOfClass("Seat")
		chairSeat:PivotTo(skinMeshSeat:GetPivot())
	end

	newMesh:Destroy()
	skinMesh:Destroy()
	object.Transparency = 0
end

function InventoryEvents:EquipItem(
	player: Player,
	itemType: string,
	itemName: string,
	itemMaterial: Enum.Material,
	itemColor: BrickColor
)
	if itemType:lower():find("chair") then
		itemType = "chairEquipped"
	elseif itemType:lower():find("bomb") then
		itemType = "bombEquipped"
	else
		return false
	end

	DataService:update(player, { itemType }, function(_)
		return { Name = itemName, Material = itemMaterial, Color = itemColor }
	end)

	print(`Equipping a {itemType} for {player} to {itemName}, with material of {itemMaterial} and color {itemColor}`)
	print(DataService:get(player, itemType))
	return true
end

InventoryEvents.networker = Networker.new("InventoryRemotes", InventoryEvents, { InventoryEvents.EquipItem })
return InventoryEvents
