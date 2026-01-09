local RunService = game:GetService("RunService")
local UtilityModule = {}

function UtilityModule.Get(parent, name)
	local exists = nil
	if RunService:IsServer() then
		exists = parent:FindFirstChild(name)
	else
		exists = parent:WaitForChild(name)
	end

	if not exists then
		error(`Can't get reference to {name}`)
		return nil
	end
	return exists
end

return UtilityModule
