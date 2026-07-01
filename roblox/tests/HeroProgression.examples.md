# Hero Progression Examples

Milestone 5.1 adds configurable Hero XP, Hero Level, and Gold rewards.

## Config Checks

In Studio Edit mode:

```lua
local config = require(game.ReplicatedStorage.ZeroToHeroShared.Config.HeroProgressionConfig)
assert(config.GetRequiredXPForLevel(1) == 0)
assert(config.GetRequiredXPForLevel(2) == 24)
assert(config.GetRequiredXPForLevel(3) == 46)
assert(config.GetProgress(1, 12).XPRequired == 24)
```

## Server Award Check

In Studio Play mode from a server command context:

```lua
local player = game:GetService("Players"):GetPlayers()[1]
local service = require(game.ServerScriptService.ZeroToHeroServer.Services.HeroProgressionService)

local beforeLevel = player.Profile.HeroLevel.Value
local beforeGold = player.Profile.Gold.Value
local result = service.AwardRewards(player, {
	HeroXP = 80,
	Gold = 5,
}, {
	Reason = "HeroProgressionExample",
	Source = "Test",
	Display = false,
})

assert(result.Success == true)
assert(result.HeroXPGained == 80)
assert(result.GoldGained == 5)
assert(result.NewHeroLevel > beforeLevel)
assert(result.LevelUps >= 1)
assert(player.Profile.HeroLevel.Value == result.NewHeroLevel)
assert(player.Profile.HeroXP.Value == result.NewHeroXP)
assert(player.Profile.Gold.Value == beforeGold + 5)
```

## Empty Reward Check

In Studio Play mode from a server command context:

```lua
local player = game:GetService("Players"):GetPlayers()[1]
local service = require(game.ServerScriptService.ZeroToHeroServer.Services.HeroProgressionService)

local beforeLevel = player.Profile.HeroLevel.Value
local beforeXP = player.Profile.HeroXP.Value
local beforeGold = player.Profile.Gold.Value
local result = service.AwardRewards(player, {
	HeroXP = 0,
	Gold = 0,
}, {
	Reason = "HeroProgressionNoRewardExample",
	Source = "Test",
	Display = false,
})

assert(result.Success == false)
assert((result.Reason or result.Error) == "NoRewards")
assert(player.Profile.HeroLevel.Value == beforeLevel)
assert(player.Profile.HeroXP.Value == beforeXP)
assert(player.Profile.Gold.Value == beforeGold)
```

## Slime Reward Check

In Studio Play mode from a server command context:

```lua
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local player = Players:GetPlayers()[1]
local services = ServerScriptService.ZeroToHeroServer.Services
local playerData = require(services.PlayerDataService)
local combat = require(services.CombatService)
local enemy = require(services.EnemyService)

local slime = Workspace.AscensionGrounds.EnemyArea.LesserSlime
local health = slime.Health
while health.Value <= 0 or slime:GetAttribute("RewardClaimed") == true do
	task.wait(0.25)
end

local state = enemy.GetEnemyState("LesserSlime")
if state then
	state.TargetPlayer = nil
end

local before = playerData.GetHeroProgressSnapshot(player)
health.Value = 1
local body = slime.Body
local root = player.Character.HumanoidRootPart
root.CFrame = CFrame.lookAt(body.Position + Vector3.new(0, 0, 4), body.Position)

local attack = combat.TryBasicAttack(player, slime)
task.wait(0.25)
local after = playerData.GetHeroProgressSnapshot(player)

assert(attack.Success == true)
assert(attack.Defeated == true)
assert(after.Level > before.Level or after.XP > before.XP)
assert(slime:GetAttribute("RewardClaimed") == true)
```

## Reward Popup Check

Set `Display = true` or omit it in the same server call and confirm the client popup receives:

- `Hero XP`
- `Gold`
- `LEVEL UP` badge when `LevelUps > 0`
- `Lv old -> new` subtitle when a level-up happens

## Persistence Check

Published-place rejoin test:

1. Publish the place.
2. Enable Studio API/DataStore access.
3. Start Play mode and award Hero XP plus Gold through `HeroProgressionService.AwardRewards`.
4. Confirm `player.Profile.HeroLevel`, `HeroXP`, and `Gold` changed.
5. Stop Play mode.
6. Start Play mode again with the same account.
7. Confirm the changed `HeroLevel`, `HeroXP`, and `Gold` values were loaded.

Local unpublished Studio may report session-only persistence through `PlayerDataService`; that does not verify rejoin persistence.
