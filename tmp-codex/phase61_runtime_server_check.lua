local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local shared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local EnemyConfig = require(shared.Config:WaitForChild("EnemyConfig"))
local LootTableConfig = require(shared.Config:WaitForChild("LootTableConfig"))
local services = ServerScriptService:WaitForChild("ZeroToHeroServer"):WaitForChild("Services")
local CombatService = require(services:WaitForChild("CombatService"))

local player = Players:GetPlayers()[1]
assert(player ~= nil, "expected one Studio test player")
local profile = player:WaitForChild("Profile", 12)
assert(profile ~= nil, "profile did not replicate")
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart", 12)
assert(root ~= nil, "player root missing")

local enemyArea = Workspace:WaitForChild("AscensionGrounds"):WaitForChild("EnemyArea")
local expectedEnemyIds = {
	"GateHound",
	"StoneShell",
	"GateSentinel",
}

local validation = LootTableConfig.ValidateAllLootTables()
assert(validation.IsValid == true, "loot table validation failed in Play mode")
assert(validation.TableCount >= 4, "expected at least four loot tables in Play mode")

for _, enemyId in ipairs(expectedEnemyIds) do
	local enemy = enemyArea:WaitForChild(enemyId, 12)
	assert(enemy ~= nil, enemyId .. " did not spawn")
	assert(enemy:GetAttribute("EnemyId") == enemyId, enemyId .. " missing EnemyId attribute")
	assert(enemy:GetAttribute("RewardClaimed") == false, enemyId .. " should start unclaimed")
	assert(enemy:FindFirstChild("Body") ~= nil, enemyId .. " missing Body")
	assert(enemy:FindFirstChild("Health") ~= nil, enemyId .. " missing Health")
	assert(enemy:FindFirstChild("MaxHealth") ~= nil, enemyId .. " missing MaxHealth")
	assert(enemy:FindFirstChild("State") ~= nil, enemyId .. " missing State")
	assert(enemy:FindFirstChild("AttackTelegraph") ~= nil, enemyId .. " missing AttackTelegraph")
	assert(enemy.Health.Value == enemy.MaxHealth.Value, enemyId .. " should spawn at full health")
	assert(LootTableConfig.GetLootTable(EnemyConfig.GetEnemy(enemyId).LootTableId) ~= nil, enemyId .. " missing loot table")
end

local hound = enemyArea:WaitForChild("GateHound")
local shell = enemyArea:WaitForChild("StoneShell")
local sentinel = enemyArea:WaitForChild("GateSentinel")
assert(sentinel:FindFirstChild("GuardTelegraph") ~= nil, "GateSentinel missing GuardTelegraph")

root.CFrame = CFrame.lookAt(hound.Body.Position + Vector3.new(0, 0, -4), hound.Body.Position)
task.wait(0.25)
local houndHit = CombatService.TryBasicAttack(player, hound)
assert(houndHit.Success == true, "GateHound hit failed: " .. tostring(houndHit.Error))
assert(houndHit.TargetDamageMultiplier == 1, "GateHound should take normal damage")

task.wait(0.75)
root.CFrame = CFrame.lookAt(shell.Body.Position + Vector3.new(0, 0, -4), shell.Body.Position)
task.wait(0.25)
local shellHit = CombatService.TryBasicAttack(player, shell)
assert(shellHit.Success == true, "StoneShell hit failed: " .. tostring(shellHit.Error))
assert(shellHit.TargetDamageMultiplier < 1, "StoneShell should reduce incoming player damage")
assert(shellHit.Damage < shellHit.RawDamage, "StoneShell damage should be lower than raw damage")

task.wait(0.75)
root.CFrame = CFrame.lookAt(sentinel.Body.Position + Vector3.new(0, 0, -4), sentinel.Body.Position)
local guardWaitStartedAt = os.clock()
while sentinel:GetAttribute("Guarded") ~= true and os.clock() - guardWaitStartedAt < 7 do
	root.CFrame = CFrame.lookAt(sentinel.Body.Position + Vector3.new(0, 0, -4), sentinel.Body.Position)
	task.wait(0.2)
end
assert(sentinel:GetAttribute("Guarded") == true, "GateSentinel did not enter guard")
assert(sentinel.State.Value == "Guard", "GateSentinel state should be Guard")
local sentinelGuardHit = CombatService.TryBasicAttack(player, sentinel)
assert(sentinelGuardHit.Success == true, "GateSentinel guarded hit failed: " .. tostring(sentinelGuardHit.Error))
assert(sentinelGuardHit.TargetDamageMultiplier < 1, "GateSentinel guard should reduce incoming damage")
assert(sentinelGuardHit.Damage < sentinelGuardHit.RawDamage, "GateSentinel guarded damage should be lower than raw damage")

task.wait(0.75)
root.CFrame = CFrame.lookAt(hound.Body.Position + Vector3.new(0, 0, -4), hound.Body.Position)
task.wait(0.2)
local beforeLevel = profile.HeroLevel.Value
local beforeXP = profile.HeroXP.Value
local beforeGold = profile.Gold.Value
hound.Health.Value = 1
local killResult = CombatService.TryBasicAttack(player, hound)
assert(killResult.Success == true, "GateHound kill hit failed: " .. tostring(killResult.Error))
assert(killResult.Defeated == true, "GateHound should be defeated")
task.wait(0.45)
assert(hound.State.Value == "Dead", "GateHound should be Dead after defeat")
assert(hound:GetAttribute("RewardClaimed") == true, "GateHound reward should be claimed")
assert(profile.HeroLevel.Value > beforeLevel or profile.HeroXP.Value > beforeXP, "GateHound defeat should advance Hero XP or level")
assert(profile.Gold.Value >= beforeGold, "Gold should not decrease")

local afterLevel = profile.HeroLevel.Value
local afterXP = profile.HeroXP.Value
local afterGold = profile.Gold.Value
task.wait(0.8)
local duplicate = CombatService.TryBasicAttack(player, hound)
assert(duplicate.Success == false, "dead GateHound should reject duplicate attack")
assert(profile.HeroLevel.Value == afterLevel, "duplicate should not grant level")
assert(profile.HeroXP.Value == afterXP, "duplicate should not grant Hero XP")
assert(profile.Gold.Value == afterGold, "duplicate should not grant Gold")

print(("PHASE61_RUNTIME_SERVER ok houndDamage=%d shellDamage=%d raw=%d sentinelDamage=%d raw=%d"):format(
	houndHit.Damage,
	shellHit.Damage,
	shellHit.RawDamage,
	sentinelGuardHit.Damage,
	sentinelGuardHit.RawDamage
))
