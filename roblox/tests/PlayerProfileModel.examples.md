# PlayerProfileModel Manual Examples

Run these examples in Roblox Studio after both shared modules exist:

```luau
local shared = game:GetService("ReplicatedStorage").ZeroToHeroShared
local PlayerProfileModel = require(shared.Types.PlayerProfileModel)

local profile = PlayerProfileModel.CreateDefaultProfile()

assert(profile.Version == PlayerProfileModel.GetCurrentVersion())
assert(profile.HeroLevel == 1)
assert(profile.HeroXP == 0)
assert(profile.Gold == 0)
assert(type(profile.TrainingStats) == "table")
assert(type(profile.Equipment) == "table")
assert(type(profile.Inventory) == "table")
assert(type(profile.Campaign) == "table")
assert(type(profile.MobileLink) == "table")
assert(type(profile.RewardClaims) == "table")
assert(type(profile.TrainingDaily) == "table")
assert(profile.TrainingDaily.TotalSeconds == 0)

for _, statId in ipairs({ "Power", "Vitality", "Agility", "Endurance", "Control" }) do
	local stat = profile.TrainingStats[statId]
	assert(stat.Level == 0)
	assert(stat.XP == 0)
	assert(stat.EffectiveValue == 0)
end

local otherProfile = PlayerProfileModel.CreateDefaultProfile()
profile.TrainingStats.Power.Level = 7
profile.Inventory.Items.example = { ItemId = "ExampleSword" }
assert(otherProfile.TrainingStats.Power.Level == 0)
assert(otherProfile.Inventory.Items.example == nil)

local validation = PlayerProfileModel.ValidateProfile(profile)
assert(validation.IsValid == true)

local repaired = PlayerProfileModel.RepairProfile({
	HeroLevel = -4,
	Gold = "bad",
	TrainingStats = {
		Power = { Level = 2, XP = 50, EffectiveValue = 2 },
	},
}).Profile

assert(repaired.Version == PlayerProfileModel.GetCurrentVersion())
assert(repaired.HeroLevel == 1)
assert(repaired.Gold == 0)
assert(repaired.TrainingStats.Power.Level == 2)
assert(repaired.TrainingStats.Power.XP == 50)
assert(repaired.TrainingStats.Power.EffectiveValue == 2)
assert(repaired.TrainingStats.Vitality.Level == 0)
```
