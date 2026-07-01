# StatConfig Manual Examples

Run these examples in Roblox Studio after `ReplicatedStorage.ZeroToHeroShared.Config.StatConfig` exists.

```luau
local StatConfig = require(game:GetService("ReplicatedStorage").ZeroToHeroShared.Config.StatConfig)

assert(#StatConfig.GetStatIds() == 5)
assert(StatConfig.IsValidStatId("Power") == true)
assert(StatConfig.IsValidStatId("Vitality") == true)
assert(StatConfig.IsValidStatId("Agility") == true)
assert(StatConfig.IsValidStatId("Endurance") == true)
assert(StatConfig.IsValidStatId("Control") == true)
assert(StatConfig.IsValidStatId("Strength") == false)

assert(StatConfig.GetRequiredXPForLevel("Power", 1) == 100)
assert(StatConfig.GetRequiredXPForLevel("Power", 2) == 255)
assert(StatConfig.GetRequiredXPForLevel("Power", 3) == 441)
assert(StatConfig.GetTotalXPRequiredForLevel("Power", 0) == 0)
assert(StatConfig.GetTotalXPRequiredForLevel("Power", 3) == 796)

assert(StatConfig.GetRequiredXPForLevel("Strength", 1) == nil)
assert(StatConfig.GetRequiredXPForLevel("Power", 0) == nil)
assert(StatConfig.GetTotalXPRequiredForLevel("Power", -1) == nil)
```
