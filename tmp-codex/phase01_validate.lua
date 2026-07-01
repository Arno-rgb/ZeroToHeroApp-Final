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
		neonParts = 0,
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
			if descendant.Material == Enum.Material.Neon then
				counts.neonParts += 1
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

local function tallestPart(root)
	local winner
	local top = -math.huge
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local partTop = descendant.Position.Y + descendant.Size.Y / 2
			if partTop > top then
				top = partTop
				winner = descendant
			end
		end
	end
	if not winner then
		return nil
	end
	return {
		name = winner.Name,
		path = pathOf(winner),
		top = top,
		position = { x = winner.Position.X, y = winner.Position.Y, z = winner.Position.Z },
		size = { x = winner.Size.X, y = winner.Size.Y, z = winner.Size.Z },
	}
end

local grounds = workspace:FindFirstChild("AscensionGrounds")
local recreation = grounds and grounds:FindFirstChild("Phase0TrainingZoneRecreation")
local pass = recreation and recreation:FindFirstChild("Phase01VisualDeltaPass")
local prompt = grounds
	and grounds:FindFirstChild("StrengthForge")
	and grounds.StrengthForge:FindFirstChild("ForgeCore")
	and grounds.StrengthForge.ForgeCore:FindFirstChild("TrainStrengthPrompt")

local zones = {}
if pass then
	for _, name in ipairs({
		"Power_StrengthForge_Delta",
		"Vitality_GuardianGrove_Delta",
		"Agility_SkywardTower_Delta",
		"Endurance_HeroesTrack_Delta",
		"Control_ArcaneShrine_Delta",
	}) do
		local zone = pass:FindFirstChild(name)
		table.insert(zones, {
			name = name,
			exists = zone ~= nil,
			counts = zone and countDescendants(zone) or nil,
			tallest = zone and tallestPart(zone) or nil,
		})
	end
end

local blockedWorkspaceAssets = {}
if workspace:FindFirstChild("Sword of Darkness", true) then
	table.insert(blockedWorkspaceAssets, "Sword of Darkness")
end
if workspace:FindFirstChild("Free VFX Pack 1 By DogmathPan", true) then
	table.insert(blockedWorkspaceAssets, "Free VFX Pack 1 By DogmathPan")
end
if workspace:FindFirstChild("Beam Texture Pack", true) then
	table.insert(blockedWorkspaceAssets, "Beam Texture Pack")
end

local result = {
	passExists = pass ~= nil,
	passPath = pass and pathOf(pass) or nil,
	passCounts = pass and countDescendants(pass) or nil,
	zones = zones,
	prompt = prompt and {
		path = pathOf(prompt),
		enabled = prompt.Enabled,
		actionText = prompt.ActionText,
		objectText = prompt.ObjectText,
		maxActivationDistance = prompt.MaxActivationDistance,
		parentPosition = { x = prompt.Parent.Position.X, y = prompt.Parent.Position.Y, z = prompt.Parent.Position.Z },
	} or nil,
	blockedWorkspaceAssets = blockedWorkspaceAssets,
}

return HttpService:JSONEncode(result)
