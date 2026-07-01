local HttpService = game:GetService("HttpService")

local grounds = workspace:FindFirstChild("AscensionGrounds")
local root = grounds and grounds:FindFirstChild("Phase0TrainingZoneRecreation")

local function pathOf(instance)
	local names = {}
	local current = instance
	while current and current ~= game do
		table.insert(names, 1, current.Name)
		current = current.Parent
	end
	return table.concat(names, ".")
end

local result = {
	exists = root ~= nil,
	zones = {},
	wideRoads = {},
	counts = {
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
	},
	blockedWorkspaceAssets = {},
	prompt = nil,
}

if root then
	for _, obj in ipairs(root:GetDescendants()) do
		result.counts.total += 1
		if obj:IsA("BasePart") then
			result.counts.baseParts += 1
			if obj.CanCollide then result.counts.collidableParts += 1 end
			if not obj.Anchored then result.counts.unanchoredParts += 1 end
		elseif obj:IsA("Script") then
			result.counts.scripts += 1
		elseif obj:IsA("LocalScript") then
			result.counts.localScripts += 1
		elseif obj:IsA("ModuleScript") then
			result.counts.moduleScripts += 1
		elseif obj:IsA("RemoteEvent") then
			result.counts.remoteEvents += 1
		elseif obj:IsA("RemoteFunction") then
			result.counts.remoteFunctions += 1
		elseif obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
			result.counts.bindables += 1
		elseif obj:IsA("ParticleEmitter") then
			result.counts.particleEmitters += 1
		elseif obj:IsA("Beam") then
			result.counts.beams += 1
		elseif obj:IsA("Trail") then
			result.counts.trails += 1
		elseif obj:IsA("Light") then
			result.counts.lights += 1
		end
	end

	for _, zoneName in ipairs({
		"Power_StrengthForge",
		"Vitality_GuardianGrove",
		"Agility_SkywardTower",
		"Endurance_HeroesTrack",
		"Control_ArcaneShrine",
	}) do
		local zone = root:FindFirstChild(zoneName)
		local zoneInfo = { name = zoneName, exists = zone ~= nil, floor = nil, landmarkFound = false, activitySigns = 0 }
		if zone then
			for _, child in ipairs(zone:GetDescendants()) do
				if child:IsA("BasePart") and child.Name:find("DistrictFloor") then
					zoneInfo.floor = { name = child.Name, x = child.Size.X, z = child.Size.Z }
				end
				if child.Name:find("ForgeFacade") or child.Name:find("GuardianTree") or child.Name:find("SkywardTower") or child.Name:find("HeroesTrackOval") or child.Name:find("Armillary") then
					zoneInfo.landmarkFound = true
				end
				if child.Name:find("Sign_Backing") then
					zoneInfo.activitySigns += 1
				end
			end
		end
		table.insert(result.zones, zoneInfo)
	end

	local roads = root:FindFirstChild("SharedHubAndRoads")
	if roads then
		for _, child in ipairs(roads:GetChildren()) do
			if child:IsA("BasePart") and child.Name:find("Road") then
				table.insert(result.wideRoads, { name = child.Name, width = math.min(child.Size.X, child.Size.Z), length = math.max(child.Size.X, child.Size.Z), collidable = child.CanCollide })
			end
		end
	end
end

for _, obj in ipairs(workspace:GetDescendants()) do
	if obj.Name:find("SwordOfDarkness") or obj.Name:find("Sword of Darkness") then
		table.insert(result.blockedWorkspaceAssets, pathOf(obj))
	end
end

local prompt = grounds and grounds:FindFirstChild("StrengthForge") and grounds.StrengthForge:FindFirstChild("ForgeCore") and grounds.StrengthForge.ForgeCore:FindFirstChild("TrainStrengthPrompt")
if prompt then
	result.prompt = {
		path = pathOf(prompt),
		enabled = prompt.Enabled,
		maxActivationDistance = prompt.MaxActivationDistance,
		actionText = prompt.ActionText,
		parentPosition = {
			x = grounds.StrengthForge.ForgeCore.Position.X,
			y = grounds.StrengthForge.ForgeCore.Position.Y,
			z = grounds.StrengthForge.ForgeCore.Position.Z,
		},
	}
end

return HttpService:JSONEncode(result)
