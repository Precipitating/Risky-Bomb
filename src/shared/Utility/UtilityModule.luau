local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local RunService = game:GetService("RunService")
local BombPacksData = require(ReplicatedStorage.Config.BombPacksData)
local ChairPacksData = require(ReplicatedStorage.Config.ChairPacksData)
local PackType = require(ReplicatedStorage.Types.PackType)
local UtilityModule = {}

local RandomColors = {
	"Really red",
	"Bright orange",
	"New Yeller",
	"Gold",
	"Bright green",
	"Dark green",
	"Sea green",
	"Cyan",
	"Bright blue",
	"Navy blue",
	"Royal purple",
	"Lavender",
	"Eggplant",
	"Reddish brown",
	"Cork",
	"White",
	"Light stone grey",
	"Really black",
}
function UtilityModule.GetRandomColor()
	return BrickColor.new(RandomColors[math.random(1, #RandomColors)])
end
function UtilityModule.Get(parent, ...)
	local current = parent

	for _, name in ipairs({ ... }) do
		if RunService:IsServer() then
			current = current:FindFirstChild(name)
		else
			current = current:WaitForChild(name)
		end

		if not current then
			error(("Can't get reference to %s"):format(name))
		end
	end

	return current
end

function UtilityModule.GetRandomMaterial()
	local materialList = Enum.Material:GetEnumItems()
	local material = nil
	repeat
		material = materialList[math.random(#materialList)]
	until material ~= Enum.Material.Air and material ~= Enum.Material.Water and material ~= Enum.Material.ForceField

	return material
end

-- "SA" means it has a surface appearance, so no material will change the look which makes it redundant
function UtilityModule.RollMaterial(itemName: string)
	local material = nil
	if string.find(itemName, "SA", 1, true) then
		material = "None"
	else
		material = UtilityModule.GetRandomMaterial()
	end
	return material
end

function UtilityModule.GetPackList(packType: number, packName: string)
	local packTable = nil
	if packType == PackType.ChairPack then
		packTable = ChairPacksData[packName]
	elseif packType == PackType.BombPack then
		packTable = BombPacksData[packName]
	else
		error(`Failed to get {packType} table!`)
	end

	return packTable
end

function UtilityModule.GetMeshFolderListOf(packTypeString: string, packName: string)
	local folder = UtilityModule.Get(ReplicatedStorage, packTypeString, packName)
	if not folder then
		error("Getting mesh of item failed, folder path is wrong!")
		return nil
	end

	return folder:GetChildren()
end

function UtilityModule.RGBToHex(color: Color3)
	local r = math.clamp(math.floor(color.R * 255), 0, 255)
	local g = math.clamp(math.floor(color.G * 255), 0, 255)
	local b = math.clamp(math.floor(color.B * 255), 0, 255)
	return string.format("#%02X%02X%02X", r, g, b)
end
function UtilityModule.GetItemMeshCalled(itemName: string, folderToSearch: any, ifFoundFunc: any)
	local meshRef = nil

	for _, mesh in ipairs(folderToSearch) do
		if mesh.Name == itemName then
			if ifFoundFunc then
				ifFoundFunc(mesh)
			end
			meshRef = mesh
			break
		end
	end

	return meshRef
end

-- returns a table of
-- Name = name,
-- RarityChance = itemChance,
-- Material = material.Name,
-- Color = color.Name

function UtilityModule.GetRandomPackItem(packTable, packType: number?, packName: string?)
	if not packTable and packType and packName then
		packTable = UtilityModule.GetPackList(packType, packName)
	end
	if not packTable then
		error("Failed to get random pack item, check args")
		return
	end

	-- sum up rarity weights
	local totalWeight = 0
	for _, itemChance in pairs(packTable.ItemList) do
		totalWeight += itemChance
	end

	-- roll a random item based on these weights
	local rng = Random.new()
	local roll = rng:NextNumber(0, totalWeight)
	local cumulative = 0
	for name, itemChance in pairs(packTable.ItemList) do
		cumulative += itemChance
		if roll <= cumulative then
			local material = UtilityModule.RollMaterial(name)
			local color = UtilityModule.GetRandomColor()
			return {
				Name = name,
				RarityChance = itemChance,
				Material = material.Name or "None",
				Color = color.Name,
			}
		end
	end

	return nil
end

return UtilityModule
