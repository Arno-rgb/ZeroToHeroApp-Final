# RewardPopup Manual Examples

Run these checks in Roblox Studio Play mode after `RewardPopup` exists under `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI`.

## Strength Forge Reward Check

Complete one server-validated Strength Forge set, then confirm from the client command context:

```luau
local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
local gui = playerGui:WaitForChild("RewardPopupGui", 5)
assert(gui, "RewardPopupGui missing")

local popup = gui:WaitForChild("Popup", 5)
assert(popup, "Popup missing")
assert(gui:GetAttribute("LastRewardPrimary") == "Power XP", "Expected Power XP reward state")
assert(string.find(tostring(gui:GetAttribute("LastRewardAmount")), "+") ~= nil, "Expected positive recorded reward amount")

local rows = popup:WaitForChild("RewardRows", 5)
local firstRow = rows:WaitForChild("RewardRow1", 5)
assert(firstRow.Label.Text == "Power XP", "Expected Power XP reward row")
assert(string.find(firstRow.Amount.Text, "+") ~= nil, "Expected positive reward amount")

if popup.Visible then
	assert(firstRow.Visible == true, "First reward row should be visible while popup is active")
end
```

## Queue Check

Run from the server command context with one local player in Play mode.

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players:GetPlayers()[1]
local rewardEvent = ReplicatedStorage.ZeroToHeroShared.Remotes.TrainingStationReward

rewardEvent:FireClient(player, {
	Title = "Training Complete",
	Subtitle = "Queue test one",
	DisplaySeconds = 4,
	Rewards = {
		{ Kind = "Gold", Amount = 25 },
	},
})

rewardEvent:FireClient(player, {
	Title = "Loot Found",
	Subtitle = "Queue test two",
	DisplaySeconds = 4,
	Rewards = {
		{ Kind = "Item", Name = "Training Blade", Rarity = "Rare", Amount = 1 },
	},
})
```

Then confirm the first reward from the client command context:

```luau
local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
local popup = playerGui.RewardPopupGui.Popup
assert(popup.Visible == true, "Queued popup should be visible")
assert(playerGui.RewardPopupGui:GetAttribute("QueueDepth") == 1, "Second reward should be queued")
assert(popup.Header.Title.Text == "Training Complete")
assert(popup.RewardRows.RewardRow1.Label.Text == "Gold")
```

Let the client advance without blocking client-side scheduling by waiting from the server command context:

```luau
task.wait(4.7)
```

Then confirm the second reward from the client command context:

```luau
local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
local popup = playerGui.RewardPopupGui.Popup
assert(popup.Visible == true, "Second queued popup should become visible")
assert(popup.Header.Title.Text == "Loot Found", "Second reward should show after the first")
assert(popup.RewardRows.RewardRow1.Label.Text == "Training Blade")
```

Let the second reward finish from the server command context:

```luau
task.wait(4.7)
```

Then confirm the queue cleared from the client command context:

```luau
local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
assert(playerGui.RewardPopupGui:GetAttribute("QueueDepth") == 0)
assert(playerGui.RewardPopupGui:GetAttribute("IsShowing") == false)
```

## Level-Up Emphasis Check

Run from the server command context:

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players:GetPlayers()[1]
ReplicatedStorage.ZeroToHeroShared.Remotes.TrainingStationReward:FireClient(player, {
	StationName = "Strength Forge",
	Stat = "Power",
	XPGained = 148,
	OldLevel = 0,
	NewLevel = 1,
	LevelUps = 1,
	DisplaySeconds = 6,
})
```

Then confirm from the client command context:

```luau
local popup = game:GetService("Players").LocalPlayer.PlayerGui.RewardPopupGui.Popup
assert(popup.Header.LevelUpBadge.Visible == true, "Level-up badge should be visible")
assert(popup.Header.Subtitle.Text == "Lv 0 -> 1", "Level-up subtitle should show level change")
```

## Hands-On Visual Checks

1. Start Play mode with one local player.
2. Complete Strength Forge.
3. Confirm a lower-center popup appears with `Power XP` and the approved XP amount.
4. Confirm level-up rewards show a visible `LEVEL UP` badge.
5. Fire two reward payloads quickly and confirm they queue instead of overlapping.
6. Confirm rare item test rewards use a stronger colored row/stroke.
7. Confirm the old `AscensionTrainingFeedbackGui.RewardToast` does not appear over the new popup.
