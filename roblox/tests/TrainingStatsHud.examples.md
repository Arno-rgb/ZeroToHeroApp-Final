# TrainingStatsHud Manual Examples

Run these checks in Roblox Studio Play mode after `PlayerDataService` and `TrainingStatsHud` exist.

## Server Replication Check

Run from the server command context with one local player in Play mode.

```luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local StatConfig = require(ReplicatedStorage.ZeroToHeroShared.Config.StatConfig)
local PlayerDataService = require(ServerScriptService.ZeroToHeroServer.Services.PlayerDataService)

local player = Players:GetPlayers()[1]
assert(player, "Start Play mode with one local player")
PlayerDataService.LoadPlayer(player)

local trainingStats = player:WaitForChild("TrainingStats", 5)
assert(trainingStats, "TrainingStats folder missing")

for _, statId in ipairs(StatConfig.GetStatIds()) do
	local statFolder = trainingStats:FindFirstChild(statId)
	assert(statFolder, statId .. " folder missing")
	assert(statFolder.Level.Value == 0)
	assert(statFolder.XP.Value == 0)
	assert(statFolder.XPRequired.Value == StatConfig.GetRequiredXPForLevel(statId, 1))
	assert(statFolder.EffectiveValue.Value == 0)
end

assert(player.Profile.TrainingRank.Value == 0)
```

## Strength Forge Update Check

After completing one Strength Forge set, confirm from the server command context:

```luau
local player = game:GetService("Players"):GetPlayers()[1]
local power = player.TrainingStats.Power

assert(power.Level.Value >= 1)
assert(power.XP.Value >= 0)
assert(power.XPRequired.Value > 0)
assert(power.EffectiveValue.Value == power.Level.Value)
```

## Client HUD Check

Run from the client command context after one Strength Forge set:

```luau
local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
local gui = playerGui:WaitForChild("TrainingStatsHudGui", 5)
assert(gui, "TrainingStatsHudGui missing")

local panel = gui.Panel
assert(panel.Visible == true)
assert(panel.Rows.PowerRow.Level.Text == "Lv 1")
assert(panel.Rows.PowerRow.XP.Text == "48 / 255 XP")
assert(panel.Header.Rank.Text == "Rank 0")

for _, statId in ipairs({ "Power", "Vitality", "Agility", "Endurance", "Control" }) do
	assert(panel.Rows:FindFirstChild(statId .. "Row"), statId .. " row missing")
end
```

## Hands-On Visual Checks

1. Start Play mode with one local player.
2. Confirm a compact `Training Stats` HUD appears near the top-left and contains five rows.
3. Confirm text remains readable on a phone-sized viewport.
4. Complete Strength Forge.
5. Confirm the Power row level/XP bar updates and flashes.
6. Confirm the old `AscensionTrainingFeedbackGui.StatsPanel` is hidden, while reward toast behavior remains available until the dedicated reward-popup milestone.
