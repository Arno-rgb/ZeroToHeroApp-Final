local HttpService = game:GetService("HttpService")

local function pathOf(instance)
	local parts = {}
	local current = instance
	while current and current ~= game do
		table.insert(parts, 1, current.Name)
		current = current.Parent
	end
	return table.concat(parts, ".")
end

local function countDescendants(root)
	local counts = {
		total = 0,
		baseParts = 0,
		collidableParts = 0,
		unanchoredParts = 0,
		scripts = 0,
		localScripts = 0,
		moduleScripts = 0,
		remoteEvents = 0,
		remoteFunctions = 0,
		bindables = 0,
		particleEmitters = 0,
		beams = 0,
		trails = 0,
		lights = 0,
	}
	for _, descendant in ipairs(root:GetDescendants()) do
		counts.total += 1
		if descendant:IsA("BasePart") then
			counts.baseParts += 1
			if descendant.CanCollide then
				counts.collidableParts += 1
			end
			if not descendant.Anchored then
				counts.unanchoredParts += 1
			end
		elseif descendant:IsA("Script") then
			counts.scripts += 1
		elseif descendant:IsA("LocalScript") then
			counts.localScripts += 1
		elseif descendant:IsA("ModuleScript") then
			counts.moduleScripts += 1
		elseif descendant:IsA("RemoteEvent") then
			counts.remoteEvents += 1
		elseif descendant:IsA("RemoteFunction") then
			counts.remoteFunctions += 1
		elseif descendant:IsA("BindableEvent") or descendant:IsA("BindableFunction") then
			counts.bindables += 1
		elseif descendant:IsA("ParticleEmitter") then
			counts.particleEmitters += 1
		elseif descendant:IsA("Beam") then
			counts.beams += 1
		elseif descendant:IsA("Trail") then
			counts.trails += 1
		elseif descendant:IsA("PointLight") or descendant:IsA("SpotLight") or descendant:IsA("SurfaceLight") then
			counts.lights += 1
		end
	end
	return counts
end

local function partSummary(part)
	if not part then
		return nil
	end
	return {
		name = part.Name,
		path = pathOf(part),
		position = { x = part.Position.X, y = part.Position.Y, z = part.Position.Z },
		size = { x = part.Size.X, y = part.Size.Y, z = part.Size.Z },
		anchored = part.Anchored,
		canCollide = part.CanCollide,
		material = tostring(part.Material),
		color = { r = math.floor(part.Color.R * 255 + 0.5), g = math.floor(part.Color.G * 255 + 0.5), b = math.floor(part.Color.B * 255 + 0.5) },
	}
end

local function findFirstBasePart(root, name)
	local found = root and root:FindFirstChild(name, true)
	if found and found:IsA("BasePart") then
		return found
	end
	return nil
end

local function zoneSummary(root, name)
	local zone = root and root:FindFirstChild(name)
	if not zone then
		return { name = name, exists = false }
	end

	local floorPart
	for _, descendant in ipairs(zone:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name:find("Floor") then
			floorPart = descendant
			break
		end
	end

	local landmark = findFirstBasePart(zone, "Phase01LandmarkMarker")
	local result = {
		name = name,
		exists = true,
		pivot = { x = zone:GetPivot().Position.X, y = zone:GetPivot().Position.Y, z = zone:GetPivot().Position.Z },
		counts = countDescendants(zone),
		floor = partSummary(floorPart),
		landmarkMarker = partSummary(landmark),
		signCount = 0,
		lightCount = 0,
		neonCount = 0,
	}

	for _, descendant in ipairs(zone:GetDescendants()) do
		if descendant.Name:find("Sign") then
			result.signCount += 1
		end
		if descendant:IsA("PointLight") or descendant:IsA("SpotLight") or descendant:IsA("SurfaceLight") then
			result.lightCount += 1
		end
		if descendant:IsA("BasePart") and descendant.Material == Enum.Material.Neon then
			result.neonCount += 1
		end
	end

	return result
end

local grounds = workspace:FindFirstChild("AscensionGrounds")
local recreation = grounds and grounds:FindFirstChild("Phase0TrainingZoneRecreation")
local prompt = grounds
	and grounds:FindFirstChild("StrengthForge")
	and grounds.StrengthForge:FindFirstChild("ForgeCore")
	and grounds.StrengthForge.ForgeCore:FindFirstChild("TrainStrengthPrompt")

local promptInfo
if prompt then
	promptInfo = {
		path = pathOf(prompt),
		enabled = prompt.Enabled,
		actionText = prompt.ActionText,
		objectText = prompt.ObjectText,
		maxActivationDistance = prompt.MaxActivationDistance,
		parent = partSummary(prompt.Parent),
	}
end

local quarantine = game:GetService("ReplicatedStorage"):FindFirstChild("ZeroToHeroAssets")
local assetInfo = {}
if quarantine then
	local creator = quarantine:FindFirstChild("CreatorStoreQuarantine")
	local approved = quarantine:FindFirstChild("ApprovedVisualAssets")
	for _, container in ipairs({ creator, approved }) do
		if container then
			for _, child in ipairs(container:GetChildren()) do
				table.insert(assetInfo, {
					name = child.Name,
					path = pathOf(child),
					counts = countDescendants(child),
				})
			end
		end
	end
end

local result = {
	groundsExists = grounds ~= nil,
	recreationExists = recreation ~= nil,
	recreationCounts = recreation and countDescendants(recreation) or nil,
	prompt = promptInfo,
	zones = {
		zoneSummary(recreation, "Power_StrengthForge"),
		zoneSummary(recreation, "Vitality_GuardianGrove"),
		zoneSummary(recreation, "Agility_SkywardTower"),
		zoneSummary(recreation, "Endurance_HeroesTrack"),
		zoneSummary(recreation, "Control_ArcaneShrine"),
	},
	assets = assetInfo,
}

return HttpService:JSONEncode(result)
