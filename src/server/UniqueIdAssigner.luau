local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local GameModule = require(ServerScriptService.Server.BombGame.GameModule)
local UniqueIdAssigner = {}
function UniqueIdAssigner.AssignAll()
	local instanceList = CollectionService:GetTagged("AssignId")

	for _, instance in ipairs(instanceList) do
		if not instance:IsDescendantOf(workspace) then
			continue
		end
		local id = HttpService:GenerateGUID(false)
		instance:SetAttribute("ID", id)
		if CollectionService:HasTag(instance, "GameTable") then
			GameModule.AddGameTableToList(id, instance)
		end
	end
end

return UniqueIdAssigner
