local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
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
		return
	end
end

local function CreateViewportFrame(mesh: MeshPart)
	local viewportFrame = Instance.new("ViewportFrame")
	local cam = Instance.new("Camera")
	cam.Parent = viewportFrame
	local obj = mesh:Clone()

	obj.Parent = viewportFrame
	viewportFrame.CurrentCamera = cam
	obj.CFrame = CFrame.new(0, 0, -5)
	cam.CFrame = CFrame.new(Vector3.zero)
	local conn = RunService.RenderStepped:Connect(function()
		obj.CFrame *= CFrame.Angles(0, math.rad(1), 0)
	end)
	viewportFrame.Size = UDim2.fromScale(0.1, 0.1)
	ShopUIFunctions.janitor:Add(viewportFrame, "Destroy")
	ShopUIFunctions.janitor:Add(conn, "Disconnect")

	return viewportFrame
end

function ShopUIFunctions:RemoveOldViewports()
	self.janitor:Cleanup()
end

function ShopUIFunctions.SpawnLootTable(packType: number, packName: string)
	local packTypeString = ""
	if packType == PackType.ChairPack then
		packTypeString = "Chairs"
	elseif packType == PackType.BombPack then
		packTypeString = "Bombs"
	end
	local folder = ReplicatedStorage:FindFirstChild(packTypeString):FindFirstChild(packName)
	if folder then
		for _, mesh in ipairs(folder:GetChildren()) do
			local viewport = CreateViewportFrame(mesh)
			viewport.Parent = PlayerContext.PlayerGui:FindFirstChild("Shop", true)
		end
	end
end

return ShopUIFunctions
