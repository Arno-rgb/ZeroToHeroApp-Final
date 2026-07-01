# R3 Combat Presentation Polish Manual Examples

Run these checks in Roblox Studio after the R3 `CombatController` source is synced.

## Edit-Mode Source Check

```luau
local HttpService = game:GetService("HttpService")
local StarterPlayer = game:GetService("StarterPlayer")

local scriptObject = StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Controllers.CombatController
local source = scriptObject.Source

assert(source:sub(1, 2) ~= "do", "CombatController should not contain the stale wrapper body")
assert(source:find("R3CombatPresentationPolish", 1, true), "Missing R3 marker")
assert(source:find("TargetPanel", 1, true), "Missing target panel")
assert(source:find("DamageFloat", 1, true), "Missing damage float")
assert(source:find("RunService.Heartbeat:Connect(runUpdateHud)", 1, true), "Missing guarded Heartbeat HUD loop")
assert(not source:find("SoundId", 1, true), "Do not add unapproved audio assets")

print(HttpService:JSONEncode({
	HasR3Marker = true,
	HasTargetPanel = true,
	HasDamageFloat = true,
	HasHeartbeat = true,
}))
```

## Server Check In Play Mode

Run from a server command context with one player in Play mode.

```luau
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local CombatService = require(ServerScriptService.ZeroToHeroServer.Services.CombatService)
local player = Players:GetPlayers()[1]
local enemy = Workspace.AscensionGrounds.EnemyArea.StoneShell
local body = enemy.Body
local health = enemy.Health
local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

assert(player and root, "Expected player character")
root.CFrame = CFrame.lookAt(body.Position + Vector3.new(0, 0, -7), body.Position)
task.wait(0.25)

CombatService.SyncCombatState(player)
local before = health.Value
local result = CombatService.TryBasicAttack(player, enemy)
local after = health.Value
local spam = CombatService.TryBasicAttack(player, enemy)

assert(result.Success == true)
assert(after == before - result.Damage)
assert(result.BreakDamage == 0 and result.RawBreakDamage == 0)
assert(spam.Success == false and spam.Error == "Cooldown")

print(string.format(
	"R3_SERVER_OK Target=%s Before=%d After=%d Damage=%d Break=%d CooldownReject=%s",
	tostring(result.TargetName),
	before,
	after,
	result.Damage,
	result.BreakDamage,
	tostring(spam.Error)
))
```

## Client Check In Play Mode

Run from a client command context after the server hit. If navigation is unreliable in Studio MCP, position the already-damaged Stone Shell near the player in Play mode before running this client check.

```luau
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("CombatControllerGui")

local deadline = os.clock() + 4
while os.clock() < deadline do
	if gui:GetAttribute("CombatHudVisible") == true
		and gui.TargetPanel.Visible == true
		and tostring(gui:GetAttribute("CurrentTargetName") or "") == "Stone Shell" then
		break
	end
	task.wait(0.05)
end

local targetPanel = gui:FindFirstChild("TargetPanel")
local combatResources = gui:FindFirstChild("ResourcePanel")
local controls = gui:FindFirstChild("Controls")
local statsGui = playerGui:FindFirstChild("TrainingStatsHudGui")
local enemy = Workspace.AscensionGrounds.EnemyArea.StoneShell

assert(gui:GetAttribute("R3CombatPresentationPolish") == true)
assert(gui:GetAttribute("LastHudError") == nil, tostring(gui:GetAttribute("LastHudError")))
assert(combatResources and combatResources.Visible == true)
assert(controls and controls.Visible == true)
assert(targetPanel and targetPanel.Visible == true)
assert(gui:GetAttribute("CurrentTargetName") == "Stone Shell")
assert(gui:GetAttribute("CurrentTargetHP") == enemy.Health.Value)
assert(gui:GetAttribute("CurrentTargetMaxHP") == enemy.MaxHealth.Value)
assert((tonumber(gui:GetAttribute("DamageFloatCount")) or 0) >= 1)
assert((tonumber(gui:GetAttribute("ImpactEffectCount")) or 0) >= 1)
assert((tonumber(gui:GetAttribute("SwingTrailCount")) or 0) >= 1)
assert(gui:GetAttribute("LastDamageTarget") == "Stone Shell")
assert(gui:GetAttribute("LastDamageAmount") == 8)
assert(statsGui and statsGui.Enabled == false)
assert(playerGui:FindFirstChild("AscensionCombatFeedbackGui") == nil)
assert(playerGui:FindFirstChild("AscensionTrainingFeedbackGui") == nil)

print(string.format(
	"R3_CLIENT_OK Target=%s HP=%d/%d Damage=%d Floats=%d Impacts=%d Trails=%d StatsHudEnabled=%s",
	tostring(gui:GetAttribute("CurrentTargetName")),
	tonumber(gui:GetAttribute("CurrentTargetHP")) or -1,
	tonumber(gui:GetAttribute("CurrentTargetMaxHP")) or -1,
	tonumber(gui:GetAttribute("LastDamageAmount")) or -1,
	tonumber(gui:GetAttribute("DamageFloatCount")) or 0,
	tonumber(gui:GetAttribute("ImpactEffectCount")) or 0,
	tonumber(gui:GetAttribute("SwingTrailCount")) or 0,
	tostring(statsGui.Enabled)
))
```

## Hands-On Checks

1. Save the place after MCP changes.
2. Fight Lesser Slime and Stone Shell with mouse/keyboard.
3. Repeat with a touch/mobile viewport.
4. Confirm target panel, damage float, swing trail, impact burst, and hit recoil are readable but restrained.
5. Confirm `ATK`, `GUARD`, and `DODGE` controls remain readable and unchanged.
6. Confirm reward popup, inventory gear button, combat HUD, and stats-HUD suppression do not overlap in a confusing way.
7. After owner-approved animations/audio are added, verify equip/unequip state, animation cancellation, no stuck loops, and bounded combat volume.
