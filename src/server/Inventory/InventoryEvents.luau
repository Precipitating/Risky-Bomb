local AssetService = game:GetService("AssetService")
local ServerScriptService = game:GetService("ServerScriptService")

local ValidRedeemCodes = require(ServerScriptService.Server.ServerData.ValidRedeemCodes)
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local DataService = require(ReplicatedStorage.Packages.DataService).server
local Networker = require(ReplicatedStorage.Packages.Networker).server

local InventoryEvents = {}

function InventoryEvents.ResetSkin(type: string, object: MeshPart)
	local skinModel: MeshPart = ReplicatedStorage:FindFirstChild(type):FindFirstChild("Default", true)
	local hasSurfaceAppearance = object:FindFirstChildOfClass("SurfaceAppearance")
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
	local hasParticle = object:FindFirstChildOfClass("ParticleEmitter")
	if hasParticle then
		hasParticle:Destroy()
	end
	if hasSurfaceAppearance then
		hasSurfaceAppearance:Destroy()
	end
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

local function GetObjectEquipped(playerOrTable, equipKey: string)
	local objectEquipped = nil
	if typeof(playerOrTable) == "table" then
		objectEquipped = playerOrTable
	elseif playerOrTable:IsA("Player") then
		objectEquipped = GetEquippedObjectName(playerOrTable, equipKey)
	else
		error("Wrong input data submitted for objectEquipped")
	end
	return objectEquipped
end

local function ApplyParticleIfExists(skinMesh: MeshPart, object)
	local hasParticle = skinMesh:FindFirstChildOfClass("ParticleEmitter")
	if hasParticle then
		hasParticle.Parent = object
	end
end

-- match the pivot offsets to the chair sat, will be reverted on unsit
local function ApplyEquippedSkinOffsets(skinMesh: MeshPart, object)
	object.PivotOffset = skinMesh.PivotOffset
	skinMesh:PivotTo(object:GetPivot())
	object.CFrame *= skinMesh.PivotOffset
end
-- match equipped skin's color on chair sat
local function ApplyMaterialsAndColors(object, skinMesh: MeshPart, objectEquipped)
	object.Size = skinMesh.Size

	local hasSurfaceAppearance: SurfaceAppearance | nil = skinMesh:FindFirstChildOfClass("SurfaceAppearance")
	if not skinMesh then
		warn(`Can't find MeshPart {objectEquipped.Name}`)
		return
	end

	if hasSurfaceAppearance then
		local surfaceAppearanceClone = hasSurfaceAppearance:Clone()
		surfaceAppearanceClone.Color = BrickColor.new(objectEquipped.Color).Color
		surfaceAppearanceClone.Parent = object
	else
		object.BrickColor = BrickColor.new(objectEquipped.Color)
		object.Material = Enum.Material[objectEquipped.Material] :: Enum.Material
	end
end

local function ReplaceChairMeshWithEquipped(skinMesh: MeshPart, object, objectEquipped)
	local newMesh = AssetService:CreateMeshPartAsync(skinMesh.MeshId)
	object:ApplyMesh(newMesh)
	if objectEquipped.Name == "Default" then
		object.TextureID = skinMesh.TextureID
	end

	newMesh:Destroy()
end

local function MatchEquippedSkinSeatPosition(equipKey: string, skinMesh: MeshPart, object)
	-- set the new skin's seat position - it may be different
	if equipKey == "chairEquipped" then
		local chairSeat = object:FindFirstChildOfClass("Seat")
		local skinMeshSeat = skinMesh:FindFirstChildOfClass("Seat")
		chairSeat:PivotTo(skinMeshSeat:GetPivot())
	end
end
-- playerOrTable = if player then get the equipped object manually, if string then its already done, so skip ahead
function InventoryEvents.SetEquippedSkin(equipKey: string, objectType: string, playerOrTable, object: MeshPart)
	local objectEquipped = GetObjectEquipped(playerOrTable, equipKey)

	-- hide so we dont see the mesh resize when setting a new ID
	object.Transparency = 1

	local skinMesh: MeshPart =
		ReplicatedStorage:FindFirstChild(objectType):FindFirstChild(objectEquipped.Name, true):Clone()

	ApplyParticleIfExists(skinMesh, object)
	ApplyEquippedSkinOffsets(skinMesh, object)
	ReplaceChairMeshWithEquipped(skinMesh, object, objectEquipped)

	-- update mesh's info to match equipped object
	ApplyMaterialsAndColors(object, skinMesh, objectEquipped)
	MatchEquippedSkinSeatPosition(equipKey, skinMesh, object)

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
local function Trim(s)
	return s:match("^%s*(.-)%s*$")
end

function InventoryEvents:RedeemCode(player: Player, codeInputted: string)
	codeInputted = Trim(string.upper(codeInputted))
	print(codeInputted)
	if ValidRedeemCodes[codeInputted] ~= nil then
		local codesRedeemed = DataService:get(player, { "codesRedeemed" })
		if codesRedeemed[codeInputted] == nil then
			ValidRedeemCodes[codeInputted](player)
			codesRedeemed[codeInputted] = true
			return true
		end
	end
	return false
end

InventoryEvents.networker =
	Networker.new("InventoryRemotes", InventoryEvents, { InventoryEvents.EquipItem, InventoryEvents.RedeemCode })
return InventoryEvents
