local HttpService = game:GetService("HttpService")

local function vec3(v)
	return { x = math.round(v.X * 100) / 100, y = math.round(v.Y * 100) / 100, z = math.round(v.Z * 100) / 100 }
end

local function pathOf(instance)
	local names = {}
	local current = instance
	while current and current ~= game do
		table.insert(names, 1, current.Name)
		current = current.Parent
	end
	return table.concat(names, ".")
end

local targets = {
	"Workspace.AscensionGrounds.StarterSpawn",
	"Workspace.AscensionGrounds.StrengthForge.ForgeCore",
	"Workspace.AscensionGrounds.EnemyArea.EnemyAreaFloor",
	"Workspace.AscensionGrounds.ReferenceSpacingBlockout.CentralPlaza.CentralCrystal",
	"Workspace.AscensionGrounds.ReferenceSpacingBlockout.SpacingRefinementLayer.DistrictFootprints.PowerFootprint",
	"Workspace.AscensionGrounds.ReferenceSpacingBlockout.SpacingRefinementLayer.DistrictFootprints.VitalityFootprint",
	"Workspace.AscensionGrounds.ReferenceSpacingBlockout.SpacingRefinementLayer.DistrictFootprints.AgilityFootprint",
	"Workspace.AscensionGrounds.ReferenceSpacingBlockout.SpacingRefinementLayer.DistrictFootprints.EnduranceFootprint",
	"Workspace.AscensionGrounds.ReferenceSpacingBlockout.SpacingRefinementLayer.DistrictFootprints.ControlFootprint",
	"Workspace.AscensionGrounds.ReferenceSpacingBlockout.BrokenGateBlockout.GateRoad",
}

local function findByPath(path)
	local current = game
	for segment in string.gmatch(path, "[^%.]+") do
		if segment == "game" then
			current = game
		else
			current = current:FindFirstChild(segment)
			if not current then
				return nil
			end
		end
	end
	return current
end

local result = {}
for _, path in ipairs(targets) do
	local obj = findByPath(path)
	if obj then
		local entry = { path = pathOf(obj), className = obj.ClassName }
		if obj:IsA("BasePart") then
			entry.position = vec3(obj.Position)
			entry.size = vec3(obj.Size)
			entry.orientation = vec3(obj.Orientation)
		elseif obj:IsA("Model") then
			entry.position = vec3(obj:GetPivot().Position)
		end
		table.insert(result, entry)
	end
end

return HttpService:JSONEncode(result)
