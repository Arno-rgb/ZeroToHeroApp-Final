# StrengthForgeMinigame Manual Examples

Run these checks in Roblox Studio Play mode after `TrainingStationService` and the `StrengthForgeMinigame` LocalScript exist.

## Server-Side Validation Case

Run from the server command context with one local player in Play mode.

```luau
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local TrainingStationService = require(ServerScriptService.ZeroToHeroServer.Services.TrainingStationService)
local PlayerDataService = require(ServerScriptService.ZeroToHeroServer.Services.PlayerDataService)

local player = Players:GetPlayers()[1]
assert(player, "Start Play mode with one local player")

local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
assert(root, "Player character must be loaded")
root.CFrame = workspace.AscensionGrounds.StrengthForge.ForgeCore.CFrame + Vector3.new(0, 4, 0)

local direct = TrainingStationService.TryActivateStation(player, "StrengthForge")
assert(direct.Success == false)
assert(direct.Error == "MinigameRequired")

local before = PlayerDataService.GetProfile(player)
local started = TrainingStationService.StartStationMinigame(player, "StrengthForge")
assert(started.Success == true)

local function markerPosition(startTime, period)
	local elapsed = math.max(0, Workspace:GetServerTimeNow() - startTime)
	local phase = (elapsed / period) % 1
	return phase <= 0.5 and phase * 2 or (1 - phase) * 2
end

for _ = 1, 3 do
	local snapshot = TrainingStationService.GetActiveChallengeSnapshot(player)
	assert(snapshot ~= nil, "Challenge should still be active")
	local target = snapshot.TargetZones[snapshot.SuccessCount + 1]

	while math.abs(markerPosition(snapshot.ServerStartTime, snapshot.MarkerPeriodSeconds) - target.Center) > 0.015 do
		task.wait(0.01)
	end

	local result = TrainingStationService.SubmitStationMinigame(player, snapshot.ChallengeId)
	assert(result.Success == true)
end

local after = PlayerDataService.GetProfile(player)
assert(after.TrainingStats.Power.Level >= before.TrainingStats.Power.Level)
assert(
	after.TrainingStats.Power.XP > before.TrainingStats.Power.XP
		or after.TrainingStats.Power.Level > before.TrainingStats.Power.Level
)

local cooldown = TrainingStationService.StartStationMinigame(player, "StrengthForge")
assert(cooldown.Success == false)
assert(cooldown.Error == "Cooldown")
```

## Manual Interaction Case

1. Start Play mode with one local player.
2. Move to `Workspace.AscensionGrounds.StrengthForge.ForgeCore`.
3. Trigger the `TrainStrengthPrompt`.
4. Confirm the Strength Forge timing panel appears.
5. Press `Strike`, click the button, or tap the button when the marker is inside the orange target zone.
6. Confirm three successful hits complete the set.
7. Confirm the reward popup appears through the existing training feedback UI.
8. Confirm leaving the forge during an active challenge hides the panel and does not award XP.
9. Confirm a second prompt activation immediately after completion shows cooldown instead of awarding again.
