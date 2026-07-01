# Phase 6.2 Break System Examples

Phase 6.2 adds the first Break-focused enemy behavior through the existing server-owned combat and enemy framework.

Scope:

- Stone Shell is the only Break-enabled enemy in this milestone.
- Break damage is distinct from health damage.
- The server owns the Break meter, Broken state, temporary vulnerability, and recovery.
- Do not use these checks to start Gatekeeper Brakk, boss rewards, or the full vertical-slice flow.

## Config Checks

From a Studio command context:

```lua
local shared = game:GetService("ReplicatedStorage").ZeroToHeroShared
local enemyConfig = require(shared.Config.EnemyConfig)
local actionConfig = require(shared.Config.CombatActionConfig)

local shell = enemyConfig.GetEnemy("StoneShell")
assert(shell ~= nil)
assert(shell.DamageTakenMultiplier == 0.65)
assert(typeof(shell.Break) == "table")
assert(shell.Break.MaxBreak == 16)
assert(shell.Break.BrokenDurationSeconds == 2)
assert(shell.Break.VulnerableDamageTakenMultiplier == 1.35)

assert(enemyConfig.GetEnemy("GateHound").Break == nil)
assert(enemyConfig.GetEnemy("GateSentinel").Break == nil)

local attack = actionConfig.GetAction("BasicAttack")
assert(attack.BreakDamageMultiplier == 1)
```

## Runtime Tree Checks

In Studio Play mode:

```lua
local shell = workspace.AscensionGrounds.EnemyArea:WaitForChild("StoneShell")

assert(shell:GetAttribute("BreakEnabled") == true)
assert(shell:GetAttribute("Broken") == false)
assert(shell:GetAttribute("Vulnerable") == false)
assert(shell:GetAttribute("DamageTakenMultiplier") == 0.65)
assert(shell:FindFirstChild("Break"))
assert(shell:FindFirstChild("MaxBreak"))
assert(shell:FindFirstChild("BreakState"))
assert(shell.MaxBreak.Value == 16)
assert(shell.Break.Value == 0)
assert(shell.BreakState.Value == "Stable")

local panel = shell.Body.EnemyBillboard.Panel
assert(panel:FindFirstChild("BreakLabel"))
assert(panel:FindFirstChild("BreakBar"))
```

## Break Combat Checks

From a server command context after one player has loaded:

```lua
local player = game:GetService("Players"):GetPlayers()[1]
local services = game:GetService("ServerScriptService").ZeroToHeroServer.Services
local combat = require(services.CombatService)
local enemyService = require(services.EnemyService)
local shell = workspace.AscensionGrounds.EnemyArea:WaitForChild("StoneShell")
local state = enemyService.GetEnemyState("StoneShell")
local root = player.Character:WaitForChild("HumanoidRootPart")

state.Health.Value = 10000
state.MaxHealth.Value = 10000
state.Break.Value = 0
state.IsBroken = false
state.BreakTriggeredForCurrentMeter = false
state.Model:SetAttribute("Broken", false)
state.Model:SetAttribute("Vulnerable", false)
state.Model:SetAttribute("DamageTakenMultiplier", 0.65)

root.CFrame = CFrame.lookAt(shell.Body.Position + Vector3.new(0, 0, 6), shell.Body.Position)
task.wait(0.2)

local firstHit = combat.TryBasicAttack(player, shell)
assert(firstHit.Success == true)
assert(firstHit.Damage > 0)
assert(firstHit.RawDamage > 0)
assert(firstHit.BreakDamage > 0)
assert(firstHit.RawBreakDamage == firstHit.BreakDamage)
assert(firstHit.TargetDamageMultiplier == 0.65)
assert(shell.Break.Value == math.min(shell.MaxBreak.Value, firstHit.BreakDamage))

while shell:GetAttribute("Broken") ~= true do
	task.wait(0.75)
	local hit = combat.TryBasicAttack(player, shell)
	assert(hit.Success == true)
end

assert(shell.State.Value == "Broken")
assert(shell.BreakState.Value == "Broken")
assert(shell:GetAttribute("Broken") == true)
assert(shell:GetAttribute("Vulnerable") == true)
assert(shell:GetAttribute("DamageTakenMultiplier") == 1.35)

task.wait(0.75)
local vulnerableHit = combat.TryBasicAttack(player, shell)
assert(vulnerableHit.Success == true)
assert(vulnerableHit.TargetDamageMultiplier == 1.35)
assert(shell.Break.Value == shell.MaxBreak.Value)

task.wait(2.35)
assert(shell:GetAttribute("Broken") == false)
assert(shell:GetAttribute("Vulnerable") == false)
assert(shell.BreakState.Value == "Stable")
assert(shell.Break.Value == 0)
assert(shell:GetAttribute("DamageTakenMultiplier") == 0.65)
```

## Hands-On Checks

- Fight Stone Shell with mouse/keyboard and confirm the Break meter is readable during movement.
- Confirm Broken state is visually and mechanically understandable.
- Confirm the vulnerability window feels noticeable.
- Confirm recovery timing is readable before Stone Shell resumes normal behavior.
- Repeat on a touch/mobile viewport and confirm combat HUD, reward popup, and enemy billboard do not overlap badly.
- Save the Roblox place in Studio after successful MCP changes.
