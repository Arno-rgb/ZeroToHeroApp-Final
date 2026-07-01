local HttpService = game:GetService("HttpService")

local function pathOf(instance)
	local names = {}
	local current = instance
	while current and current ~= game do
		table.insert(names, 1, current.Name)
		current = current.Parent
	end
	return table.concat(names, ".")
end

local function vec3(v)
	return { x = math.round(v.X * 100) / 100, y = math.round(v.Y * 100) / 100, z = math.round(v.Z * 100) / 100 }
end

local function cframeInfo(part)
	return {
		position = vec3(part.Position),
		orientation = vec3(part.Orientation),
		size = vec3(part.Size),
		anchored = part.Anchored,
		canCollide = part.CanCollide,
	}
end

local function countDescendants(root)
	local counts = {
		total = 0,
		baseParts = 0,
		meshParts = 0,
		scripts = 0,
		localScripts = 0,
		moduleScripts = 0,
		remoteEvents = 0,
		remoteFunctions = 0,
		bindableEvents = 0,
		bindableFunctions = 0,
		particleEmitters = 0,
		beams = 0,
		trails = 0,
		lights = 0,
		unanchoredParts = 0,
		collidableParts = 0,
	}
	if not root then
		return counts
	end
	for _, obj in ipairs(root:GetDescendants()) do
		counts.total += 1
		if obj:IsA("BasePart") then
			counts.baseParts += 1
			if obj:IsA("MeshPart") then
				counts.meshParts += 1
			end
			if not obj.Anchored then
				counts.unanchoredParts += 1
			end
			if obj.CanCollide then
				counts.collidableParts += 1
			end
		elseif obj:IsA("Script") then
			counts.scripts += 1
		elseif obj:IsA("LocalScript") then
			counts.localScripts += 1
		elseif obj:IsA("ModuleScript") then
			counts.moduleScripts += 1
		elseif obj:IsA("RemoteEvent") then
			counts.remoteEvents += 1
		elseif obj:IsA("RemoteFunction") then
			counts.remoteFunctions += 1
		elseif obj:IsA("BindableEvent") then
			counts.bindableEvents += 1
		elseif obj:IsA("BindableFunction") then
			counts.bindableFunctions += 1
		elseif obj:IsA("ParticleEmitter") then
			counts.particleEmitters += 1
		elseif obj:IsA("Beam") then
			counts.beams += 1
		elseif obj:IsA("Trail") then
			counts.trails += 1
		elseif obj:IsA("Light") then
			counts.lights += 1
		end
	end
	return counts
end

local report = {
	prompts = {},
	spawnsAndAnchors = {},
	remotes = {},
	serverScripts = {},
	clientScripts = {},
	assets = {},
	worldGroups = {},
}

for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("ProximityPrompt") then
		local parent = obj.Parent
		table.insert(report.prompts, {
			path = pathOf(obj),
			parentPath = parent and pathOf(parent) or nil,
			parentCFrame = parent and parent:IsA("BasePart") and cframeInfo(parent) or nil,
			enabled = obj.Enabled,
			actionText = obj.ActionText,
			objectText = obj.ObjectText,
			maxActivationDistance = obj.MaxActivationDistance,
			holdDuration = obj.HoldDuration,
		})
	end
	if obj:IsA("SpawnLocation") or obj.Name:find("Anchor") or obj.Name:find("Spawn") or obj.Name:find("ForgeCore") or obj.Name == "EnemyAreaFloor" or obj.Name == "TrainingDummy" then
		local item = { path = pathOf(obj), className = obj.ClassName }
		if obj:IsA("BasePart") then
			item.cframe = cframeInfo(obj)
		elseif obj:IsA("Model") then
			local pivot = obj:GetPivot()
			item.pivot = { position = vec3(pivot.Position) }
		end
		table.insert(report.spawnsAndAnchors, item)
	end
end

local replicatedStorage = game:GetService("ReplicatedStorage")
local remotesRoot = replicatedStorage:FindFirstChild("ZeroToHeroShared") and replicatedStorage.ZeroToHeroShared:FindFirstChild("Remotes")
if remotesRoot then
	for _, obj in ipairs(remotesRoot:GetChildren()) do
		table.insert(report.remotes, { path = pathOf(obj), className = obj.ClassName })
	end
end
local legacyRemotes = replicatedStorage:FindFirstChild("AscensionRemotes")
if legacyRemotes then
	for _, obj in ipairs(legacyRemotes:GetChildren()) do
		table.insert(report.remotes, { path = pathOf(obj), className = obj.ClassName, legacy = true })
	end
end

local serverRoot = game:GetService("ServerScriptService")
for _, obj in ipairs(serverRoot:GetDescendants()) do
	if obj:IsA("LuaSourceContainer") then
		table.insert(report.serverScripts, { path = pathOf(obj), className = obj.ClassName, enabled = obj:IsA("BaseScript") and obj.Enabled or nil })
	end
end

local starterScripts = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
if starterScripts then
	for _, obj in ipairs(starterScripts:GetDescendants()) do
		if obj:IsA("LuaSourceContainer") then
			table.insert(report.clientScripts, { path = pathOf(obj), className = obj.ClassName, enabled = obj:IsA("BaseScript") and obj.Enabled or nil })
		end
	end
end

local assetsRoot = replicatedStorage:FindFirstChild("ZeroToHeroAssets")
if assetsRoot then
	for _, folderName in ipairs({ "CreatorStoreQuarantine", "ApprovedVisualAssets" }) do
		local folder = assetsRoot:FindFirstChild(folderName)
		if folder then
			for _, child in ipairs(folder:GetChildren()) do
				table.insert(report.assets, {
					path = pathOf(child),
					className = child.ClassName,
					counts = countDescendants(child),
				})
			end
		end
	end
end

local grounds = workspace:FindFirstChild("AscensionGrounds")
if grounds then
	for _, name in ipairs({ "StrengthForge", "EnemyArea", "ReferenceSpacingBlockout", "Phase0VisualScalePolish" }) do
		local child = grounds:FindFirstChild(name)
		table.insert(report.worldGroups, {
			path = child and pathOf(child) or ("Workspace.AscensionGrounds." .. name),
			exists = child ~= nil,
			counts = countDescendants(child),
		})
	end
end

return HttpService:JSONEncode(report)
