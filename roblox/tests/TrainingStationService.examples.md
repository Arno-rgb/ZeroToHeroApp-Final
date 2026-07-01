# TrainingStationService Manual Examples

Run these checks in Roblox Studio Play mode after `ServerScriptService.ZeroToHeroServer.Services.TrainingStationService` exists.

```luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local shared = ReplicatedStorage.ZeroToHeroShared
local TrainingStationConfig = require(shared.Config.TrainingStationConfig)
local TrainingStationService = require(ServerScriptService.ZeroToHeroServer.Services.TrainingStationService)
local PlayerDataService = require(ServerScriptService.ZeroToHeroServer.Services.PlayerDataService)

local player = Players:GetPlayers()[1]
assert(player, "Start Play mode with one local player")

local station = TrainingStationConfig.GetStation("StrengthForge")
assert(station ~= nil)
assert(station.StatId == "Power")
assert(station.InteractionRange > 0)
assert(station.CooldownSeconds >= 0)
assert(station.DurationSeconds > 0)
assert(station.BaseXP > 0)
assert(station.MinigameResult.Enabled == true)

local rewardEvent = shared.Remotes:FindFirstChild("TrainingStationReward")
assert(rewardEvent ~= nil)
assert(rewardEvent:IsA("RemoteEvent"))

local prompt = workspace.AscensionGrounds.StrengthForge.ForgeCore:FindFirstChild("TrainStrengthPrompt")
assert(prompt ~= nil)
assert(prompt:IsA("ProximityPrompt"))
assert(prompt.ActionText == "Train")
assert(prompt.ObjectText == "Strength Forge")

local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
assert(root, "Move the player to the Strength Forge before this check")
root.CFrame = workspace.AscensionGrounds.StrengthForge.ForgeCore.CFrame + Vector3.new(0, 4, 0)

local beforeProfile = PlayerDataService.GetProfile(player)
local direct = TrainingStationService.TryActivateStation(player, "StrengthForge")
assert(direct.Success == false)
assert(direct.Error == "MinigameRequired")

local afterProfile = PlayerDataService.GetProfile(player)
assert(afterProfile.TrainingStats.Power.XP == beforeProfile.TrainingStats.Power.XP)
assert(afterProfile.TrainingStats.Power.Level == beforeProfile.TrainingStats.Power.Level)

local challenge = TrainingStationService.StartStationMinigame(player, "StrengthForge")
assert(challenge.Success == true)
assert(challenge.ChallengeId ~= nil)

local duplicate = TrainingStationService.StartStationMinigame(player, "StrengthForge")
assert(duplicate.Success == false)
assert(duplicate.Error == "ActiveChallenge")

local cancelled = TrainingStationService.CancelStationMinigame(player, challenge.ChallengeId, "ManualExample")
assert(cancelled.Success == true)

local invalid = TrainingStationService.TryActivateStation(player, "MissingStation")
assert(invalid.Success == false)
assert(invalid.Error == "InvalidStation")
```
