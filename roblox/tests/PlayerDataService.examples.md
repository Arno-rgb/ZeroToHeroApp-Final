# PlayerDataService Manual Examples

Run these checks in Roblox Studio Play mode after `ServerScriptService.ZeroToHeroServer.Services.PlayerDataService` exists.

```luau
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.ZeroToHeroServer.Services.PlayerDataService)
local player = Players:GetPlayers()[1]
assert(player, "Start Play mode with one local player")

local session = PlayerDataService.GetSession(player) or PlayerDataService.LoadPlayer(player)
assert(session ~= nil)
assert(session.Profile.Version == 1)
assert(session.Profile.HeroLevel == 1)
assert(session.Profile.HeroXP == 0)
assert(session.Profile.Gold == 0)
assert(session.Profile.TrainingStats.Power.Level == 0)
assert(session.Profile.TrainingStats.Power.XP == 0)
assert(session.Profile.TrainingStats.Power.EffectiveValue == 0)

local snapshot = PlayerDataService.GetProfile(player)
snapshot.Gold = 999999
assert(PlayerDataService.GetProfile(player).Gold == 0, "GetProfile must return a copy")

local result = PlayerDataService.AddTrainingStatValue(player, "Power", 1, "Manual example")
assert(result.Success == true)
assert(result.Value == 1)
assert(PlayerDataService.GetProfile(player).TrainingStats.Power.EffectiveValue == 1)
assert(player.Stats.Power.Value == 1)

local badResult = PlayerDataService.AddTrainingStatValue(player, "Strength", 1, "Manual example")
assert(badResult.Success == false)
assert(PlayerDataService.GetProfile(player).TrainingStats.Strength == nil)
```

Join/rejoin persistence check when Studio DataStores are enabled:

1. Publish the place and enable Studio API/DataStore access.
2. Start Play mode with one player.
3. Run `PlayerDataService.AddTrainingStatValue(player, "Power", 1, "Persistence test")`.
4. Stop Play mode and start it again with the same test account.
5. Confirm `PlayerDataService.GetProfile(player).TrainingStats.Power.EffectiveValue` kept the saved value.
