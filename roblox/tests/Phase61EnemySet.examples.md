# Phase 6.1 Enemy Set Examples

Phase 6.1 adds the remaining prototype enemies through the existing server-owned enemy framework:

- `GateHound`
- `StoneShell`
- `GateSentinel`

Do not use these checks to start Break, Brakk, or the full vertical-slice flow.

## Config Checks

From a Studio server command context:

```lua
local shared = game:GetService("ReplicatedStorage").ZeroToHeroShared
local enemyConfig = require(shared.Config.EnemyConfig)
local lootConfig = require(shared.Config.LootTableConfig)

for _, enemyId in ipairs({ "GateHound", "StoneShell", "GateSentinel" }) do
	local enemy = enemyConfig.GetEnemy(enemyId)
	assert(enemy ~= nil, enemyId .. " missing")
	assert(enemy.LootTableId == enemyId, enemyId .. " loot table mismatch")
	assert(lootConfig.GetLootTable(enemy.LootTableId) ~= nil, enemyId .. " loot table missing")
end

local validation = lootConfig.ValidateAllLootTables()
assert(validation.IsValid == true)
assert(validation.TableCount >= 4)

assert(enemyConfig.GetEnemy("GateHound").MoveSpeed > enemyConfig.GetEnemy("LesserSlime").MoveSpeed)
assert(enemyConfig.GetEnemy("GateHound").MaxHealth < enemyConfig.GetEnemy("LesserSlime").MaxHealth)
assert(enemyConfig.GetEnemy("StoneShell").MoveSpeed < enemyConfig.GetEnemy("LesserSlime").MoveSpeed)
assert(enemyConfig.GetEnemy("StoneShell").DamageTakenMultiplier < 1)
assert(enemyConfig.GetEnemy("GateSentinel").DefensivePattern ~= nil)
```

## Runtime Tree Checks

In Studio Play mode:

```lua
local enemyArea = workspace.AscensionGrounds.EnemyArea

for _, enemyId in ipairs({ "GateHound", "StoneShell", "GateSentinel" }) do
	local enemy = enemyArea:WaitForChild(enemyId)
	assert(enemy:GetAttribute("EnemyId") == enemyId)
	assert(enemy:FindFirstChild("Body"))
	assert(enemy:FindFirstChild("Health"))
	assert(enemy:FindFirstChild("MaxHealth"))
	assert(enemy:FindFirstChild("State"))
	assert(enemy:FindFirstChild("AttackTelegraph"))
	assert(enemy:GetAttribute("RewardClaimed") == false)
	assert(enemy.Health.Value == enemy.MaxHealth.Value)
end

assert(enemyArea.GateSentinel:FindFirstChild("GuardTelegraph"))
```

## Damage And Guard Checks

From a server command context after one player has loaded:

```lua
local player = game:GetService("Players"):GetPlayers()[1]
local services = game:GetService("ServerScriptService").ZeroToHeroServer.Services
local combat = require(services.CombatService)
local enemyArea = workspace.AscensionGrounds.EnemyArea
local root = player.Character:WaitForChild("HumanoidRootPart")

local hound = enemyArea:WaitForChild("GateHound")
root.CFrame = CFrame.lookAt(hound.Body.Position + Vector3.new(0, 0, -4), hound.Body.Position)
task.wait(0.2)
local houndHit = combat.TryBasicAttack(player, hound)
assert(houndHit.Success == true)
assert(houndHit.TargetDamageMultiplier == 1)

task.wait(0.7)
local shell = enemyArea:WaitForChild("StoneShell")
root.CFrame = CFrame.lookAt(shell.Body.Position + Vector3.new(0, 0, -4), shell.Body.Position)
task.wait(0.2)
local shellHit = combat.TryBasicAttack(player, shell)
assert(shellHit.Success == true)
assert(shellHit.TargetDamageMultiplier < 1)
assert(shellHit.Damage < shellHit.RawDamage)

task.wait(0.7)
local sentinel = enemyArea:WaitForChild("GateSentinel")
sentinel:SetAttribute("DamageTakenMultiplier", 0.45)
root.CFrame = CFrame.lookAt(sentinel.Body.Position + Vector3.new(0, 0, -4), sentinel.Body.Position)
task.wait(0.2)
local sentinelGuardHit = combat.TryBasicAttack(player, sentinel)
assert(sentinelGuardHit.Success == true)
assert(sentinelGuardHit.TargetDamageMultiplier == 0.45)
assert(sentinelGuardHit.Damage < sentinelGuardHit.RawDamage)
```

The final attribute set is a direct server test of the combat multiplier path. In normal play, `EnemyService` owns that attribute during the Sentinel guard state.

## Reward Once Check

```lua
local player = game:GetService("Players"):GetPlayers()[1]
local services = game:GetService("ServerScriptService").ZeroToHeroServer.Services
local combat = require(services.CombatService)
local enemy = workspace.AscensionGrounds.EnemyArea:WaitForChild("GateHound")
local root = player.Character:WaitForChild("HumanoidRootPart")

root.CFrame = CFrame.lookAt(enemy.Body.Position + Vector3.new(0, 0, -4), enemy.Body.Position)
task.wait(0.2)
enemy.Health.Value = 1
local beforeHeroLevel = player.Profile.HeroLevel.Value
local beforeHeroXP = player.Profile.HeroXP.Value
local result = combat.TryBasicAttack(player, enemy)
assert(result.Success == true)
assert(result.Defeated == true)
task.wait(0.35)
assert(enemy.State.Value == "Dead")
assert(enemy:GetAttribute("RewardClaimed") == true)
assert(player.Profile.HeroLevel.Value > beforeHeroLevel or player.Profile.HeroXP.Value > beforeHeroXP)

local afterHeroXP = player.Profile.HeroXP.Value
task.wait(0.75)
local duplicate = combat.TryBasicAttack(player, enemy)
assert(duplicate.Success == false)
assert(player.Profile.HeroXP.Value == afterHeroXP)
```

## Hands-On Checks

- Confirm Gate Hound feels fast and fragile.
- Confirm Stone Shell feels slow and armoured.
- Confirm Gate Sentinel shows a clear guard/defensive pattern before it resumes attacking.
- Confirm every enemy uses a visible red attack telegraph before damage.
- Defeat each enemy and confirm reward popups are server-approved and readable.
- Confirm rewards grant once per death and respawn resets `RewardClaimed`.
- Confirm combat HUD, reward popup, and enemy billboards remain readable on phone and desktop viewports.
