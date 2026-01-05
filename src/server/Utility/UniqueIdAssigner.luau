local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local UniqueIdAssigner = {}

function UniqueIdAssigner.AssignAll()
	local instanceList = CollectionService:GetTagged("AssignId")

	for _, instance in ipairs(instanceList) do
		instance:SetAttribute("ID", HttpService:GenerateGUID(false))
	end
end

return UniqueIdAssigner
