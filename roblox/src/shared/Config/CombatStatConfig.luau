local CombatStatConfig = {}

local COMBAT_STAT_KEYS = {
	"MaxHP",
	"PhysicalDamage",
	"BreakDamage",
	"MaxStamina",
	"StaminaRecovery",
	"MoveSpeedBonus",
	"CriticalChance",
	"GuardEffectiveness",
	"SkillEffectiveness",
}

local COMBAT_STAT_KEY_SET = {}
for _, statKey in ipairs(COMBAT_STAT_KEYS) do
	COMBAT_STAT_KEY_SET[statKey] = true
end

local TRAINING_STAT_IDS = {
	"Power",
	"Vitality",
	"Agility",
	"Endurance",
	"Control",
}

local function freezeMap(values)
	return table.freeze(table.clone(values))
end

local function freezeNestedMap(values)
	local copy = {}
	for key, value in pairs(values) do
		if typeof(value) == "table" then
			copy[key] = freezeMap(value)
		else
			copy[key] = value
		end
	end

	return table.freeze(copy)
end

local BASE_STATS = table.freeze({
	MaxHP = 100,
	PhysicalDamage = 12,
	BreakDamage = 8,
	MaxStamina = 100,
	StaminaRecovery = 8,
	MoveSpeedBonus = 0,
	CriticalChance = 0.05,
	GuardEffectiveness = 0.1,
	SkillEffectiveness = 1,
})

local HERO_LEVEL_SCALING = table.freeze({
	MaxHP = 5,
	PhysicalDamage = 0.4,
	BreakDamage = 0.25,
	MaxStamina = 2,
	StaminaRecovery = 0.05,
	MoveSpeedBonus = 0,
	CriticalChance = 0,
	GuardEffectiveness = 0,
	SkillEffectiveness = 0,
})

local TRAINING_WEIGHTS = freezeNestedMap({
	Power = {
		PhysicalDamage = 1.15,
		BreakDamage = 0.8,
	},
	Vitality = {
		MaxHP = 10,
		GuardEffectiveness = 0.003,
	},
	Agility = {
		MoveSpeedBonus = 0.003,
		CriticalChance = 0.002,
	},
	Endurance = {
		MaxStamina = 8,
		StaminaRecovery = 0.12,
		GuardEffectiveness = 0.001,
	},
	Control = {
		CriticalChance = 0.0005,
		GuardEffectiveness = 0.003,
		SkillEffectiveness = 0.015,
	},
})

local STAT_CAPS = table.freeze({
	MaxHP = 5000,
	PhysicalDamage = 1000,
	BreakDamage = 800,
	MaxStamina = 1000,
	StaminaRecovery = 60,
	MoveSpeedBonus = 0.25,
	CriticalChance = 0.35,
	GuardEffectiveness = 0.75,
	SkillEffectiveness = 2.5,
})

local STAT_PRECISION = table.freeze({
	MaxHP = 0,
	PhysicalDamage = 2,
	BreakDamage = 2,
	MaxStamina = 0,
	StaminaRecovery = 2,
	MoveSpeedBonus = 4,
	CriticalChance = 4,
	GuardEffectiveness = 4,
	SkillEffectiveness = 4,
})

local DEFAULT_CLASS_ID = "Adventurer"

local CLASS_MULTIPLIER_LIMITS = table.freeze({
	Minimum = 0.75,
	Maximum = 1.25,
})

local CLASS_MODIFIERS = freezeNestedMap({
	Adventurer = {
		Additive = {},
		Multipliers = {},
	},
	Vanguard = {
		Additive = {
			GuardEffectiveness = 0.03,
		},
		Multipliers = {
			MaxHP = 1.06,
			BreakDamage = 1.04,
		},
	},
	Ranger = {
		Additive = {
			CriticalChance = 0.02,
		},
		Multipliers = {
			MoveSpeedBonus = 1.08,
			PhysicalDamage = 1.03,
		},
	},
	Monk = {
		Additive = {
			SkillEffectiveness = 0.04,
		},
		Multipliers = {
			StaminaRecovery = 1.08,
			GuardEffectiveness = 1.05,
		},
	},
})

function CombatStatConfig.GetCombatStatKeys()
	return table.clone(COMBAT_STAT_KEYS)
end

function CombatStatConfig.GetTrainingStatIds()
	return table.clone(TRAINING_STAT_IDS)
end

function CombatStatConfig.IsCombatStatKey(statKey)
	return typeof(statKey) == "string" and COMBAT_STAT_KEY_SET[statKey] == true
end

function CombatStatConfig.GetBaseStats()
	return table.clone(BASE_STATS)
end

function CombatStatConfig.GetHeroLevelScaling()
	return table.clone(HERO_LEVEL_SCALING)
end

function CombatStatConfig.GetTrainingWeights()
	local copy = {}
	for statId, weights in pairs(TRAINING_WEIGHTS) do
		copy[statId] = table.clone(weights)
	end

	return copy
end

function CombatStatConfig.GetStatCaps()
	return table.clone(STAT_CAPS)
end

function CombatStatConfig.GetStatPrecision()
	return table.clone(STAT_PRECISION)
end

function CombatStatConfig.GetDefaultClassId()
	return DEFAULT_CLASS_ID
end

function CombatStatConfig.GetClassMultiplierLimits()
	return table.clone(CLASS_MULTIPLIER_LIMITS)
end

function CombatStatConfig.GetClassModifier(classId)
	if typeof(classId) ~= "string" or CLASS_MODIFIERS[classId] == nil then
		classId = DEFAULT_CLASS_ID
	end

	local modifier = CLASS_MODIFIERS[classId]
	return {
		Id = classId,
		Additive = table.clone(modifier.Additive),
		Multipliers = table.clone(modifier.Multipliers),
	}
end

return table.freeze(CombatStatConfig)
