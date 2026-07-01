# PlayerCombatController Manual Examples

Run these checks in Roblox Studio after `CombatActionConfig`, `CombatService`, `CombatBootstrap`, and `CombatController` exist.

## Studio Tree Checks

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

assert(ReplicatedStorage.ZeroToHeroShared.Config.CombatActionConfig)
assert(ServerScriptService.ZeroToHeroServer.Services.CombatService)
assert(ServerScriptService.ZeroToHeroServer.CombatBootstrap)
assert(StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Controllers.CombatController)
```

## Server Checks In Play Mode

Run from a server command context with one player in Play mode.

```luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local CombatService = require(ServerScriptService.ZeroToHeroServer.Services.CombatService)
local remotes = ReplicatedStorage.ZeroToHeroShared.Remotes
local player = Players:GetPlayers()[1]
local dummy = Workspace.AscensionGrounds.EnemyArea.TrainingDummy

assert(remotes.CombatAction:IsA("RemoteEvent"))
assert(remotes.CombatFeedback:IsA("RemoteEvent"))
assert(player.PlayerGui.CombatControllerGui.Controls.AttackButton)
assert(player.PlayerGui.CombatControllerGui.Controls.GuardButton)
assert(player.PlayerGui.CombatControllerGui.Controls.DodgeButton)

local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
assert(root, "Player character root must exist")
root.CFrame = CFrame.lookAt(dummy.Body.Position + Vector3.new(0, 0, -7), dummy.Body.Position)

local startHealth = dummy.Health.Value
local attack = CombatService.TryBasicAttack(player, dummy)
assert(attack.Success == true)
assert(attack.Damage > 0)
assert(dummy.Health.Value == startHealth - attack.Damage)

local spam = CombatService.TryBasicAttack(player, dummy)
assert(spam.Success == false and spam.Error == "Cooldown")

local beforeGuard = CombatService.ApplyIncomingDamage(player, 50, {
	Source = "ManualTest",
	ApplyToHumanoid = false,
})

CombatService.SetGuarding(player, true)
local afterGuard = CombatService.ApplyIncomingDamage(player, 50, {
	Source = "ManualTest",
	ApplyToHumanoid = false,
})
assert(afterGuard.FinalDamage < beforeGuard.FinalDamage)

local beforeDodge = CombatService.GetPlayerCombatSnapshot(player)
local dodge = CombatService.TryDodge(player, root.CFrame.LookVector)
local afterDodge = CombatService.GetPlayerCombatSnapshot(player)
assert(dodge.Success == true)
assert(afterDodge.Stamina < beforeDodge.Stamina)

local dodgedHit = CombatService.ApplyIncomingDamage(player, 50, {
	Source = "ManualTest",
	ApplyToHumanoid = false,
})
assert(dodgedHit.Dodged == true)
assert(dodgedHit.FinalDamage == 0)
```

## Hands-On Input Checks

1. Start Play mode and walk to `Workspace.AscensionGrounds.EnemyArea.TrainingDummy`.
2. Face the dummy and press left mouse button or tap `ATK`; the dummy should flash and the status label should show damage.
3. Rapidly press attack; cooldown feedback should appear and dummy health should not drop every press.
4. Hold `F` on keyboard; `GUARD` should turn active and the status label should show guard feedback.
5. Press `Q` or tap `DODGE`; the character should move a short distance, stamina feedback should appear, and guard should drop.
6. On a touch-capable viewport, tap `ATK`, `GUARD`, and `DODGE`; all three touch buttons should be readable and activate the same server-approved actions.

Expected result: the client can request combat actions, but server validation owns damage, cooldowns, stamina, guard state, and dodge invulnerability.
