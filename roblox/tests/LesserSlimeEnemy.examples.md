# Lesser Slime Enemy Examples

Milestone 4.4 adds one server-controlled enemy: `LesserSlime`.

## Runtime Tree Checks

In Studio Play mode, verify:

```lua
local enemy = workspace.AscensionGrounds.EnemyArea:WaitForChild("LesserSlime")
assert(enemy:GetAttribute("EnemyId") == "LesserSlime")
assert(enemy:FindFirstChild("Body"))
assert(enemy:FindFirstChild("Health"))
assert(enemy:FindFirstChild("MaxHealth"))
assert(enemy:FindFirstChild("State"))
assert(enemy:FindFirstChild("AttackTelegraph"))
assert(enemy.Health.Value == enemy.MaxHealth.Value)
```

## Reward Mutation Check

From a server command context after a player has loaded:

```lua
local player = game:GetService("Players"):GetPlayers()[1]
local services = game:GetService("ServerScriptService").ZeroToHeroServer.Services
local combat = require(services.CombatService)
local enemy = workspace.AscensionGrounds.EnemyArea:WaitForChild("LesserSlime")
local body = enemy:WaitForChild("Body")
local root = player.Character:WaitForChild("HumanoidRootPart")

local beforeHeroXP = player.Profile.HeroXP.Value
local beforeGold = player.Profile.Gold.Value

root.CFrame = CFrame.lookAt(body.Position + Vector3.new(0, 0, -4), body.Position)
task.wait(0.2)
enemy.Health.Value = 1
local result = combat.TryBasicAttack(player, enemy)
assert(result.Success == true)
assert(result.Defeated == true)
task.wait(0.35)

assert(enemy.Health.Value == 0)
assert(enemy.State.Value == "Dead")
assert(player.Profile.HeroXP.Value == beforeHeroXP + 12)
assert(player.Profile.Gold.Value >= beforeGold)
```

## Duplicate Reward Check

In a server command context after a successful kill:

```lua
local afterHeroXP = player.Profile.HeroXP.Value
local afterGold = player.Profile.Gold.Value

local immediateDuplicate = combat.TryBasicAttack(player, enemy)
assert(immediateDuplicate.Success == false)
task.wait(0.2)
assert(player.Profile.HeroXP.Value == afterHeroXP)
assert(player.Profile.Gold.Value == afterGold)

task.wait(2.3)
local deadTargetDuplicate = combat.TryBasicAttack(player, enemy)
assert(deadTargetDuplicate.Success == false)
assert(deadTargetDuplicate.Error == "TargetDefeated")
assert(player.Profile.HeroXP.Value == afterHeroXP)
assert(player.Profile.Gold.Value == afterGold)
```

The immediate duplicate can fail on cooldown before target validation. The important requirement is that neither the immediate duplicate nor the post-cooldown dead-target duplicate grants another reward.

## Respawn Check

```lua
root.CFrame = CFrame.new(0, 10, 0)
task.wait(8)
assert(enemy.Health.Value == enemy.MaxHealth.Value)
assert(enemy:GetAttribute("RewardClaimed") == false)
assert(enemy.State.Value == "Idle")
```

## Hands-On Checks

- Move into Lesser Slime detect range and confirm it changes from Idle/Detect to Chase.
- Confirm the red attack telegraph appears before damage.
- Confirm guard and dodge reduce/avoid incoming damage through the existing combat controller.
- Defeat the enemy and confirm the reward popup shows Hero XP and optional Gold.
- Confirm the enemy stops attacking while Dead.
- Wait for respawn and confirm Health returns to MaxHealth.
