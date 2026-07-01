local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

local function pathOf(instance)
	local names = {}
	local current = instance
	while current and current ~= game do
		table.insert(names, 1, current.Name)
		current = current.Parent
	end
	return table.concat(names, ".")
end

local function round(value)
	return math.round(value * 100) / 100
end

local function vec3(value)
	return { x = round(value.X), y = round(value.Y), z = round(value.Z) }
end

local function countDescendants(root)
	local counts = {
		total = 0,
		baseParts = 0,
		meshParts = 0,
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
		thinNeonParts = 0,
	}
	if root == nil then
		return counts
	end

	for _, descendant in ipairs(root:GetDescendants()) do
		counts.total += 1
		if descendant:IsA("BasePart") then
			counts.baseParts += 1
			if descendant:IsA("MeshPart") then
				counts.meshParts += 1
			end
			if descendant.CanCollide then
				counts.collidableParts += 1
			end
			if not descendant.Anchored then
				counts.unanchoredParts += 1
			end
			if descendant.Material == Enum.Material.Neon then
				counts.neonParts += 1
				local size = descendant.Size
				if math.min(size.X, size.Y, size.Z) <= 0.75 then
					counts.thinNeonParts += 1
				end
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

local function boundsFor(root)
	local minX, minY, minZ = math.huge, math.huge, math.huge
	local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
	local partCount = 0
	if root == nil then
		return nil
	end

	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Transparency < 1 then
			partCount += 1
			local cf = descendant.CFrame
			local half = descendant.Size / 2
			local corners = {
				Vector3.new(-half.X, -half.Y, -half.Z),
				Vector3.new(-half.X, -half.Y, half.Z),
				Vector3.new(-half.X, half.Y, -half.Z),
				Vector3.new(-half.X, half.Y, half.Z),
				Vector3.new(half.X, -half.Y, -half.Z),
				Vector3.new(half.X, -half.Y, half.Z),
				Vector3.new(half.X, half.Y, -half.Z),
				Vector3.new(half.X, half.Y, half.Z),
			}
			for _, corner in ipairs(corners) do
				local world = cf:PointToWorldSpace(corner)
				minX = math.min(minX, world.X)
				minY = math.min(minY, world.Y)
				minZ = math.min(minZ, world.Z)
				maxX = math.max(maxX, world.X)
				maxY = math.max(maxY, world.Y)
				maxZ = math.max(maxZ, world.Z)
			end
		end
	end

	if partCount == 0 then
		return nil
	end
	return {
		partCount = partCount,
		min = { x = round(minX), y = round(minY), z = round(minZ) },
		max = { x = round(maxX), y = round(maxY), z = round(maxZ) },
		size = { x = round(maxX - minX), y = round(maxY - minY), z = round(maxZ - minZ) },
	}
end

local function partInfo(part)
	if part == nil or not part:IsA("BasePart") then
		return nil
	end
	return {
		path = pathOf(part),
		position = vec3(part.Position),
		orientation = vec3(part.Orientation),
		size = vec3(part.Size),
		anchored = part.Anchored,
		canCollide = part.CanCollide,
		transparency = round(part.Transparency),
		material = tostring(part.Material),
		color = {
			r = math.round(part.Color.R * 255),
			g = math.round(part.Color.G * 255),
			b = math.round(part.Color.B * 255),
		},
	}
end

local function summarizeChild(root, name)
	local child = root and root:FindFirstChild(name)
	return {
		path = child and pathOf(child) or nil,
		exists = child ~= nil,
		className = child and child.ClassName or nil,
		counts = child and countDescendants(child) or nil,
		bounds = child and boundsFor(child) or nil,
	}
end

local function summarizePrompt(prompt)
	if prompt == nil then
		return nil
	end
	return {
		path = pathOf(prompt),
		enabled = prompt.Enabled,
		actionText = prompt.ActionText,
		objectText = prompt.ObjectText,
		maxActivationDistance = prompt.MaxActivationDistance,
		holdDuration = prompt.HoldDuration,
		parent = partInfo(prompt.Parent),
	}
end

local function promptList()
	local result = {}
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("ProximityPrompt") then
			table.insert(result, summarizePrompt(descendant))
		end
	end
	table.sort(result, function(a, b)
		return a.path < b.path
	end)
	return result
end

local function assetSummary()
	local result = {}
	local assetsRoot = ReplicatedStorage:FindFirstChild("ZeroToHeroAssets")
	if assetsRoot == nil then
		return result
	end
	for _, folderName in ipairs({ "CreatorStoreQuarantine", "ApprovedVisualAssets" }) do
		local folder = assetsRoot:FindFirstChild(folderName)
		if folder then
			for _, child in ipairs(folder:GetChildren()) do
				table.insert(result, {
					path = pathOf(child),
					className = child.ClassName,
					counts = countDescendants(child),
				})
			end
		end
	end
	table.sort(result, function(a, b)
		return a.path < b.path
	end)
	return result
end

local function sourceSummary(root)
	local result = {}
	if root == nil then
		return result
	end
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("LuaSourceContainer") then
			table.insert(result, {
				path = pathOf(descendant),
				className = descendant.ClassName,
				enabled = descendant:IsA("BaseScript") and descendant.Enabled or nil,
			})
		end
	end
	table.sort(result, function(a, b)
		return a.path < b.path
	end)
	return result
end

local grounds = workspace:FindFirstChild("AscensionGrounds")
local recreation = grounds and grounds:FindFirstChild("Phase0TrainingZoneRecreation")
local phase01 = recreation and recreation:FindFirstChild("Phase01VisualDeltaPass")
local forgeCore = grounds and grounds:FindFirstChild("StrengthForge") and grounds.StrengthForge:FindFirstChild("ForgeCore")
local prompt = forgeCore and forgeCore:FindFirstChild("TrainStrengthPrompt")

local worldGroups = {}
if grounds then
	for _, child in ipairs(grounds:GetChildren()) do
		table.insert(worldGroups, {
			name = child.Name,
			className = child.ClassName,
			counts = countDescendants(child),
			bounds = boundsFor(child),
		})
	end
	table.sort(worldGroups, function(a, b)
		return a.name < b.name
	end)
end

local report = {
	groundsExists = grounds ~= nil,
	worldGroups = worldGroups,
	recreation = summarizeChild(grounds, "Phase0TrainingZoneRecreation"),
	phase01 = phase01 and {
		path = pathOf(phase01),
		counts = countDescendants(phase01),
		bounds = boundsFor(phase01),
	} or nil,
	phase0VisualScalePolish = summarizeChild(grounds, "Phase0VisualScalePolish"),
	referenceSpacingBlockout = summarizeChild(grounds, "ReferenceSpacingBlockout"),
	strengthForgePrompt = summarizePrompt(prompt),
	allPrompts = promptList(),
	assets = assetSummary(),
	serverScripts = sourceSummary(ServerScriptService),
	clientScripts = sourceSummary(StarterPlayer:FindFirstChild("StarterPlayerScripts")),
}

return HttpService:JSONEncode(report)
