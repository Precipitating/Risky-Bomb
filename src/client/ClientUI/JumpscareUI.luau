local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local UtilityModule = require(ReplicatedStorage.UtilityModule)
local PlayerList = {}
local PlayerContext = require(StarterPlayer.StarterPlayerScripts.Client.PlayerContext)
local Remotes = ReplicatedStorage.Remotes

local JumpscareIDs = {
	"rbxassetid://124338845724473",
	"rbxassetid://6182991646",
	"rbxassetid://3425028682",
	"rbxassetid://12351005336",
}

local JumpscareSounds = {
	"rbxassetid://5710016194",
	"rbxassetid://6754147732",
	"rbxassetid://7076365030",
	"rbxassetid://130285917830946",
}
local JumpscareUI = {}

function JumpscareUI.GetRandomJumpscareImage()
	return JumpscareIDs[math.random(1, #JumpscareIDs)]
end

function JumpscareUI.GetRandomJumpscareSound()
	return JumpscareSounds[math.random(1, #JumpscareSounds)]
end
local function GetPlayers()
	table.clear(PlayerList)
	for _, player in ipairs(Players:GetPlayers()) do
		table.insert(PlayerList, { Name = player.Name, PlayerRef = player })
	end
end

local function PopulatePlayerList(playerListFrame: ScrollingFrame)
	local playerListButton: TextButton = UtilityModule.Get(ReplicatedStorage.UITemplates, "PlayerButton")
	GetPlayers()

	for _, target in pairs(PlayerList) do
		local newButton: TextButton = playerListButton:Clone()
		newButton.Text = target.Name
		newButton.Activated:Connect(function()
			Remotes.PendingJumpscarePlayer:FireServer(target.PlayerRef.UserId)
			MarketplaceService:PromptProductPurchase(PlayerContext.Player, 3507139396)
		end)
		newButton.Parent = playerListFrame
	end
end

function JumpscareUI.Initialize()
	local jumpscareUI: SurfaceGui = UtilityModule.Get(PlayerContext.PlayerGui, "JumpscareUI")
	local jumpscareButton: TextButton = UtilityModule.Get(jumpscareUI, "InteractButton")
	local playerListFrame: ScrollingFrame = UtilityModule.Get(jumpscareUI, "PlayerListFrame")

	jumpscareButton.Activated:Connect(function()
		if jumpscareButton:GetAttribute("Opened") then
			jumpscareButton:SetAttribute("Opened", false)
			playerListFrame.Active = false
			playerListFrame.Visible = false
			playerListFrame.Interactable = false

			for _, child in ipairs(playerListFrame:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
		else
			jumpscareButton:SetAttribute("Opened", true)
			PopulatePlayerList(playerListFrame)

			playerListFrame.Active = true
			playerListFrame.Visible = true
			playerListFrame.Interactable = true
		end
	end)
end

return JumpscareUI
