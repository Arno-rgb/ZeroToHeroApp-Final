# TrainingService Manual Examples

Run these checks in Roblox Studio Play mode after `ServerScriptService.ZeroToHeroServer.Services.TrainingService` exists.

```luau
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local services = ServerScriptService.ZeroToHeroServer.Services
local PlayerDataService = require(services.PlayerDataService)
local TrainingService = require(services.TrainingService)

local player = Players:GetPlayers()[1]
assert(player, "Start Play mode with one local player")

local session = PlayerDataService.GetSession(player) or PlayerDataService.LoadPlayer(player)
assert(session ~= nil)

local invalidStat = TrainingService.AwardTrainingXP(player, "Strength", 100, {
	DurationSeconds = 60,
	Source = "Manual invalid stat check",
	DateKey = "2099-01-01",
})
assert(invalidStat.Success == false)
assert(invalidStat.Error == "InvalidStat")

local invalidXP = TrainingService.AwardTrainingXP(player, "Power", 0, {
	DurationSeconds = 60,
	Source = "Manual invalid XP check",
	DateKey = "2099-01-01",
})
assert(invalidXP.Success == false)
assert(invalidXP.Error == "InvalidXP")

local levelOne = TrainingService.AwardTrainingXP(player, "Power", 100, {
	DurationSeconds = 60,
	Source = "Manual level one check",
	DateKey = "2099-01-01",
})
assert(levelOne.Success == true)
assert(levelOne.OldLevel == 0)
assert(levelOne.NewLevel == 1)
assert(levelOne.XPGained == 100)
assert(levelOne.LevelUps == 1)

local multiLevel = TrainingService.AwardTrainingXP(player, "Power", 796, {
	DurationSeconds = 60,
	Source = "Manual multi-level check",
	DateKey = "2099-01-02",
})
assert(multiLevel.Success == true)
assert(multiLevel.LevelUps >= 2)
assert(multiLevel.NewLevel >= 3)

local firstTier = TrainingService.CalculateDiminishedXP(100, 60, 0)
assert(firstTier.AwardedXP == 100)
assert(firstTier.Multiplier == 1)

local secondTier = TrainingService.CalculateDiminishedXP(100, 60, 20 * 60)
assert(secondTier.AwardedXP == 70)
assert(secondTier.Multiplier == 0.7)

local fourthTier = TrainingService.CalculateDiminishedXP(100, 60, 70 * 60)
assert(fourthTier.AwardedXP == 15)
assert(fourthTier.Multiplier == 0.15)

local profile = PlayerDataService.GetProfile(player)
assert(profile.TrainingDaily ~= nil)
assert(profile.TrainingDaily.TotalSeconds > 0)
assert(profile.TrainingStats.Power.Level == multiLevel.NewLevel)
```
