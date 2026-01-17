local RunService = game:GetService("RunService")
local UtilityModule = {}

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
	until material ~= Enum.Material.Air and material ~= Enum.Material.Water

	return material
end

return UtilityModule
