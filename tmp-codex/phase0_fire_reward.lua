local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players:GetPlayers()[1]
assert(player, "No player")

local remotes = ReplicatedStorage:WaitForChild("ZeroToHeroShared"):WaitForChild("Remotes")
local rewardEvent = remotes:WaitForChild("TrainingStationReward", 10)
assert(rewardEvent, "TrainingStationReward missing")

rewardEvent:FireClient(player, {
	Title = "Visual Check",
	Subtitle = "Phase 0 route test",
	DisplaySeconds = 30,
	Rewards = {
		{ Kind = "TrainingXP", Stat = "Power", Amount = 1 },
		{ Kind = "Gold", Amount = 1 },
	},
})

return "reward fired"
