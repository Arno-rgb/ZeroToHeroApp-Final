local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

local ANIMATION_TAGS = {
	"ZTH_AmbientPulse",
	"ZTH_AmbientFloat",
	"ZTH_AmbientRotate",
	"ZTH_AmbientFlicker",
	"ZTH_AmbientParticle",
	"ZTH_PromptFeedback",
	"ZTH_ChallengeFeedback",
}

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
	if root == nil then
		return counts
	end
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

local function promptInfo(prompt)
	if prompt == nil then
		return nil
	end
	local parent = prompt.Parent
	return {
		path = pathOf(prompt),
		enabled = prompt.Enabled,
		actionText = prompt.ActionText,
		objectText = prompt.ObjectText,
		maxActivationDistance = prompt.MaxActivationDistance,
		holdDuration = prompt.HoldDuration,
		parentPath = parent and pathOf(parent) or nil,
		parentPosition = parent and parent:IsA("BasePart") and vec3(parent.Position) or nil,
	}
end

local function tagCounts()
	local result = {}
	for _, tag in ipairs(ANIMATION_TAGS) do
		result[tag] = #CollectionService:GetTagged(tag)
	end
	return result
end

local function listClientScripts()
	local result = {}
	local starterScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
	if starterScripts then
		for _, descendant in ipairs(starterScripts:GetDescendants()) do
			if descendant:IsA("LuaSourceContainer") then
				table.insert(result, {
					path = pathOf(descendant),
					className = descendant.ClassName,
					enabled = descendant:IsA("BaseScript") and descendant.Enabled or nil,
				})
			end
		end
	end
	table.sort(result, function(a, b)
		return a.path < b.path
	end)
	return result
end

local grounds = workspace:FindFirstChild("AscensionGrounds")
local salvage = grounds and grounds:FindFirstChild("Phase02VisualSalvagePass")
local phase03 = grounds and grounds:FindFirstChild("Phase03EnvironmentalFeedback")
local forgePrompt = grounds
	and grounds:FindFirstChild("StrengthForge")
	and grounds.StrengthForge:FindFirstChild("ForgeCore")
	and grounds.StrengthForge.ForgeCore:FindFirstChild("TrainStrengthPrompt")
local dummyPrompt = grounds
	and grounds:FindFirstChild("EnemyArea")
	and grounds.EnemyArea:FindFirstChild("TrainingDummy")
	and grounds.EnemyArea.TrainingDummy:FindFirstChild("Body")
	and grounds.EnemyArea.TrainingDummy.Body:FindFirstChild("HitEnemyPrompt")

local assetsRoot = ReplicatedStorage:FindFirstChild("ZeroToHeroAssets")
local quarantine = assetsRoot and assetsRoot:FindFirstChild("CreatorStoreQuarantine")
local approved = assetsRoot and assetsRoot:FindFirstChild("ApprovedVisualAssets")

return HttpService:JSONEncode({
	groundsExists = grounds ~= nil,
	phase02 = salvage and {
		path = pathOf(salvage),
		counts = countDescendants(salvage),
	} or nil,
	phase03 = phase03 and {
		path = pathOf(phase03),
		counts = countDescendants(phase03),
	} or nil,
	tagCounts = tagCounts(),
	prompts = {
		strengthForge = promptInfo(forgePrompt),
		trainingDummy = promptInfo(dummyPrompt),
	},
	clientScripts = listClientScripts(),
	assetFolders = {
		quarantine = quarantine and countDescendants(quarantine) or nil,
		approved = approved and countDescendants(approved) or nil,
	},
	serverScriptRoot = ServerScriptService:FindFirstChild("ZeroToHeroServer") ~= nil,
})
