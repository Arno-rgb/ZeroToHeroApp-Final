local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local player
local deadline = os.clock() + 15
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

local services = ServerScriptService.ZeroToHeroServer.Services
local TrainingStationService = require(services.TrainingStationService)
local CombatService = require(services.CombatService)

local grounds = workspace:WaitForChild("AscensionGrounds")
local overlay = grounds:WaitForChild("Phase0TrainingZoneRecreation")

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
rayParams.FilterDescendantsInstances = { overlay }

local function rayHitAt(name, x, z)
	local origin = Vector3.new(x, 80, z)
	local hit = workspace:Raycast(origin, Vector3.new(0, -140, 0), rayParams)
	return {
		name = name,
		hit = hit ~= nil,
		instance = hit and hit.Instance and hit.Instance:GetFullName() or nil,
		position = hit and { x = hit.Position.X, y = hit.Position.Y, z = hit.Position.Z } or nil,
	}
end

local routeChecks = {
	rayHitAt("central plaza", 0, 0),
	rayHitAt("north road", 0, -120),
	rayHitAt("south guardian road", 0, 145),
	rayHitAt("power road", -92, -48),
	rayHitAt("agility road", 105, -44),
	rayHitAt("endurance road", -105, 82),
	rayHitAt("control road", 105, 82),
	rayHitAt("power floor", -135, -65),
	rayHitAt("guardian grove floor", 0, 185),
	rayHitAt("skyward tower floor", 150, -65),
	rayHitAt("heroes track floor", -150, 115),
	rayHitAt("arcane shrine floor", 150, 115),
}

local navigationSamples = {}
for _, sample in ipairs({
	{ name = "spawn", position = Vector3.new(0, 6, 82) },
	{ name = "central", position = Vector3.new(0, 6, 0) },
	{ name = "power", position = Vector3.new(-95, 6, -34) },
	{ name = "guardian", position = Vector3.new(0, 6, 160) },
	{ name = "agility", position = Vector3.new(128, 6, -45) },
	{ name = "endurance", position = Vector3.new(-140, 6, 105) },
	{ name = "control", position = Vector3.new(140, 6, 105) },
}) do
	rootPart.CFrame = CFrame.new(sample.position)
	task.wait(0.1)
	table.insert(navigationSamples, {
		name = sample.name,
		position = { x = rootPart.Position.X, y = rootPart.Position.Y, z = rootPart.Position.Z },
	})
end

local forgeCore = grounds.StrengthForge.ForgeCore
rootPart.CFrame = forgeCore.CFrame + Vector3.new(0, 4, 0)
task.wait(0.2)
local forgeStart = TrainingStationService.StartStationMinigame(player, "StrengthForge")
local challengeSnapshot = TrainingStationService.GetActiveChallengeSnapshot(player)
local forgeCancel
if challengeSnapshot then
	forgeCancel = TrainingStationService.CancelStationMinigame(player, challengeSnapshot.ChallengeId, "Phase0VisualRuntimeCheck")
end

local enemy = grounds.EnemyArea:WaitForChild("LesserSlime", 10)
assert(enemy, "LesserSlime missing")
local body = enemy:WaitForChild("Body", 10)
local health = enemy:WaitForChild("Health", 10)
rootPart.CFrame = body.CFrame + Vector3.new(0, 0, 7)
task.wait(0.2)
local beforeHealth = health.Value
local attackResult = CombatService.TryBasicAttack(player, enemy)
local afterHealth = health.Value

return HttpService:JSONEncode({
	player = player.Name,
	routeChecks = routeChecks,
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
