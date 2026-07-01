# DerivedCombatStats Manual Examples

Run these checks in Roblox Studio Edit mode after `ReplicatedStorage.ZeroToHeroShared.Config.CombatStatConfig` and `ReplicatedStorage.ZeroToHeroShared.Utility.DerivedCombatStats` exist.

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DerivedCombatStats = require(ReplicatedStorage.ZeroToHeroShared.Utility.DerivedCombatStats)

local function expectNear(actual, expected)
	assert(math.abs(actual - expected) < 0.0001, ("Expected %s, got %s"):format(expected, actual))
end

local lowInput = {
	HeroLevel = 1,
	TrainingStats = {
		Power = { EffectiveValue = 0 },
		Vitality = { EffectiveValue = 0 },
		Agility = { EffectiveValue = 0 },
		Endurance = { EffectiveValue = 0 },
		Control = { EffectiveValue = 0 },
	},
	EquipmentBonuses = {},
	ClassId = "Adventurer",
}

local lowA = DerivedCombatStats.Calculate(lowInput)
local lowB = DerivedCombatStats.Calculate(lowInput)
for statKey, value in pairs(lowA.Stats) do
	assert(lowB.Stats[statKey] == value, "Same input must produce the same output")
end

assert(lowA.Stats.MaxHP == 100)
assert(lowA.Stats.PhysicalDamage == 12)
assert(lowA.Stats.BreakDamage == 8)
assert(lowA.Stats.MaxStamina == 100)
assert(lowA.Stats.StaminaRecovery == 8)
assert(lowA.Stats.MoveSpeedBonus == 0)
assert(lowA.Stats.CriticalChance == 0.05)
assert(lowA.Stats.GuardEffectiveness == 0.1)
assert(lowA.Stats.SkillEffectiveness == 1)

local normal = DerivedCombatStats.Calculate({
	HeroLevel = 10,
	TrainingStats = {
		Power = { EffectiveValue = 12 },
		Vitality = { EffectiveValue = 8 },
		Agility = { EffectiveValue = 6 },
		Endurance = { EffectiveValue = 7 },
		Control = { EffectiveValue = 5 },
	},
	EquipmentBonuses = {
		MaxHP = 15,
		PhysicalDamage = 3,
		MaxStamina = 10,
		CriticalChance = 0.02,
	},
	ClassId = "Vanguard",
})

assert(normal.Stats.MaxHP == 254)
assert(normal.Stats.PhysicalDamage == 32.4)
assert(normal.Stats.BreakDamage == 20.64)
assert(normal.Stats.MaxStamina == 184)
assert(normal.Stats.StaminaRecovery == 9.29)
assert(normal.Stats.MoveSpeedBonus == 0.018)
assert(normal.Stats.CriticalChance == 0.0845)
assert(normal.Stats.GuardEffectiveness == 0.176)
assert(normal.Stats.SkillEffectiveness == 1.075)
expectNear(normal.Contributions.Training.PhysicalDamage, 13.8)
assert(normal.Contributions.Equipment.PhysicalDamage == 3)
assert(normal.Contributions.Equipment.CriticalChance == 0.02)

local high = DerivedCombatStats.Calculate({
	HeroLevel = 250,
	TrainingStats = {
		Power = { EffectiveValue = 10000 },
		Vitality = { EffectiveValue = 10000 },
		Agility = { EffectiveValue = 10000 },
		Endurance = { EffectiveValue = 10000 },
		Control = { EffectiveValue = 10000 },
	},
	EquipmentBonuses = {
		MoveSpeedBonus = 5,
		CriticalChance = 5,
		MaxHP = 100000,
		PhysicalDamage = 100000,
	},
	ClassId = "Ranger",
	ClassModifiers = {
		Id = "UnsafeTestClass",
		Multipliers = {
			PhysicalDamage = 100,
			MoveSpeedBonus = 100,
			CriticalChance = 100,
		},
	},
})

assert(high.Stats.MoveSpeedBonus == 0.25)
assert(high.Stats.CriticalChance == 0.35)
assert(high.Stats.PhysicalDamage == 1000)
assert(high.Metadata.Caps.MoveSpeedBonus.Applied == true)
assert(high.Metadata.Caps.CriticalChance.Applied == true)
assert(high.Metadata.Caps.PhysicalDamage.Applied == true)
assert(high.Metadata.UncappedStats.PhysicalDamage < math.huge)
```

Expected normal-case output summary:

- `MaxHP = 254`
- `PhysicalDamage = 32.4`
- `BreakDamage = 20.64`
- `MaxStamina = 184`
- `StaminaRecovery = 9.29`
- `MoveSpeedBonus = 0.018`
- `CriticalChance = 0.0845`
- `GuardEffectiveness = 0.176`
- `SkillEffectiveness = 1.075`
