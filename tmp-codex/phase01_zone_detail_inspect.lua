local HttpService = game:GetService("HttpService")

local grounds = workspace:FindFirstChild("AscensionGrounds")
local recreation = grounds and grounds:FindFirstChild("Phase0TrainingZoneRecreation")

local function summarizePart(part)
	return {
		name = part.Name,
		className = part.ClassName,
		position = { x = part.Position.X, y = part.Position.Y, z = part.Position.Z },
		size = { x = part.Size.X, y = part.Size.Y, z = part.Size.Z },
		material = tostring(part.Material),
		color = { r = math.floor(part.Color.R * 255 + 0.5), g = math.floor(part.Color.G * 255 + 0.5), b = math.floor(part.Color.B * 255 + 0.5) },
		canCollide = part.CanCollide,
	}
end

local function zoneDetail(name)
	local zone = recreation and recreation:FindFirstChild(name)
	if not zone then
		return { name = name, exists = false }
	end

	local children = {}
	for _, child in ipairs(zone:GetChildren()) do
		table.insert(children, { name = child.Name, className = child.ClassName })
	end

	local tallest = {}
	for _, descendant in ipairs(zone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local top = descendant.Position.Y + descendant.Size.Y / 2
			table.insert(tallest, {
				name = descendant.Name,
				top = top,
				position = { x = descendant.Position.X, y = descendant.Position.Y, z = descendant.Position.Z },
				size = { x = descendant.Size.X, y = descendant.Size.Y, z = descendant.Size.Z },
				material = tostring(descendant.Material),
			})
		end
	end
	table.sort(tallest, function(a, b)
		return a.top > b.top
	end)
	while #tallest > 12 do
		table.remove(tallest)
	end

	local named = {}
	for _, queryName in ipairs({
		"ForgeFacade",
		"FurnaceMouth",
		"GuardianLifeTree",
		"GuardianTreeTrunk",
		"SkywardTowerCore",
		"SkywardTowerFinishRing",
		"HeroesTrackTimerGate",
		"HeroesTrackOuterSegment01",
		"ArcaneArmillaryOrb",
		"ArcaneRingHorizontal",
		"ArcaneRunePad",
	}) do
		local found = zone:FindFirstChild(queryName, true)
		if found and found:IsA("BasePart") then
			named[queryName] = summarizePart(found)
		elseif found then
			named[queryName] = { name = found.Name, className = found.ClassName }
		end
	end

	return {
		name = name,
		exists = true,
		children = children,
		tallest = tallest,
		named = named,
	}
end

local result = {
	zones = {
		zoneDetail("Power_StrengthForge"),
		zoneDetail("Vitality_GuardianGrove"),
		zoneDetail("Agility_SkywardTower"),
		zoneDetail("Endurance_HeroesTrack"),
		zoneDetail("Control_ArcaneShrine"),
	},
}

return HttpService:JSONEncode(result)
