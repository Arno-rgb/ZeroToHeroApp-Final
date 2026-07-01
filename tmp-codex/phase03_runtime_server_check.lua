local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local player
local deadline = os.clock() + 18
repeat
	player = Players:GetPlayers()[1]
	if not player then
		task.wait(0.2)
	end
until player or os.clock() > deadline
assert(player, "No player in Play mode")

local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart", 10)
assert(rootPart, "No HumanoidRootPart")

local services = ServerScriptService:WaitForChild("ZeroToHeroServer"):WaitForChild("Services")
local TrainingStationService = require(services:WaitForChild("TrainingStationService"))
local CombatService = require(services:WaitForChild("CombatService"))

local grounds = workspace:WaitForChild("AscensionGrounds")
local phase03 = grounds:WaitForChild("Phase03EnvironmentalFeedback")

local animationTags = {
	"ZTH_AmbientPulse",
	"ZTH_AmbientFloat",
	"ZTH_AmbientRotate",
	"ZTH_AmbientFlicker",
	"ZTH_AmbientParticle",
	"ZTH_PromptFeedback",
	"ZTH_ChallengeFeedback",
}

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
		lights = 0,
		particleEmitters = 0,
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
		elseif descendant:IsA("Light") then
			counts.lights += 1
		elseif descendant:IsA("ParticleEmitter") then
			counts.particleEmitters += 1
		end
	end
	return counts
end

local function tagCounts()
	local result = {}
	for _, tagName in ipairs(animationTags) do
		local count = 0
		for _, instance in ipairs(CollectionService:GetTagged(tagName)) do
			if instance:IsDescendantOf(phase03) then
				count += 1
			end
		end
		result[tagName] = count
	end
	return result
end

local navigationSamples = {}
for _, sample in ipairs({
	{ name = "spawn road", position = Vector3.new(0, 8, 110) },
	{ name = "central plaza", position = Vector3.new(0, 8, 0) },
	{ name = "power prompt yard", position = Vector3.new(-78, 10, -24) },
	{ name = "power forge district", position = Vector3.new(-150, 10, -86) },
	{ name = "vitality grove", position = Vector3.new(0, 10, 248) },
	{ name = "agility tower", position = Vector3.new(260, 10, -72) },
	{ name = "endurance track", position = Vector3.new(-260, 10, 174) },
	{ name = "control shrine", position = Vector3.new(260, 10, 184) },
	{ name = "enemy route", position = Vector3.new(0, 8, -112) },
}) do
	rootPart.CFrame = CFrame.new(sample.position)
	task.wait(0.1)
	table.insert(navigationSamples, {
		name = sample.name,
		position = {
			x = math.round(rootPart.Position.X * 100) / 100,
			y = math.round(rootPart.Position.Y * 100) / 100,
			z = math.round(rootPart.Position.Z * 100) / 100,
		},
	})
end

local forgeCore = grounds:WaitForChild("StrengthForge"):WaitForChild("ForgeCore")
rootPart.CFrame = forgeCore.CFrame + Vector3.new(0, 4, 0)
task.wait(0.2)
local forgeStart = TrainingStationService.StartStationMinigame(player, "StrengthForge")
local challengeSnapshot = TrainingStationService.GetActiveChallengeSnapshot(player)
local forgeCancel
if challengeSnapshot then
	forgeCancel = TrainingStationService.CancelStationMinigame(player, challengeSnapshot.ChallengeId, "Phase03VisualRuntimeCheck")
end

local enemy = grounds:WaitForChild("EnemyArea"):WaitForChild("LesserSlime", 12)
assert(enemy, "LesserSlime missing")
local body = enemy:WaitForChild("Body", 10)
local health = enemy:WaitForChild("Health", 10)
local attackPosition = body.Position + Vector3.new(0, 0, 7)
rootPart.CFrame = CFrame.lookAt(attackPosition, body.Position)
task.wait(0.2)
local beforeHealth = health.Value
local attackResult = CombatService.TryBasicAttack(player, enemy)
local afterHealth = health.Value

return HttpService:JSONEncode({
	player = player.Name,
	phase03Counts = countDescendants(phase03),
	tagCounts = tagCounts(),
	navigationSamples = navigationSamples,
	forgeStart = forgeStart,
	challengeSnapshot = challengeSnapshot and {
		challengeId = challengeSnapshot.ChallengeId,
		requiredSuccesses = challengeSnapshot.RequiredSuccesses,
		maxAttempts = challengeSnapshot.MaxAttempts,
		successCount = challengeSnapshot.SuccessCount,
	} or nil,
	forgeCancel = forgeCancel,
	enemy = {
		name = enemy.Name,
		enemyId = enemy:GetAttribute("EnemyId"),
		state = enemy:FindFirstChild("State") and enemy.State.Value or nil,
		beforeHealth = beforeHealth,
		afterHealth = afterHealth,
		attackResult = attackResult,
	},
})
