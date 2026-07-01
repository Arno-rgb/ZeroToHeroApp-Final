local StatConfig = {}

local DEFAULT_BASE_XP = 100
local DEFAULT_XP_EXPONENT = 1.35
local DEFAULT_MAXIMUM_TEST_LEVEL = 25

local function freezeArray(values)
	return table.freeze(table.clone(values))
end

local STAT_DEFINITIONS = {
	table.freeze({
		Id = "Power",
		DisplayName = "Power",
		Description = "Raw force for physical damage, Break pressure, and charged attacks.",
		ColourToken = "stat.power.orange",
		Colour = Color3.fromRGB(255, 142, 42),
		IconPlaceholder = "icon-placeholder-power",
		BaseXP = DEFAULT_BASE_XP,
		XPExponent = DEFAULT_XP_EXPONENT,
		MaximumTestLevel = DEFAULT_MAXIMUM_TEST_LEVEL,
		DerivedStatResponsibilities = freezeArray({
			"PhysicalDamage",
			"BreakDamage",
			"ChargedAttackScaling",
		}),
	}),
	table.freeze({
		Id = "Vitality",
		DisplayName = "Vitality",
		Description = "Durability for maximum HP, recovery, and minor resistance.",
		ColourToken = "stat.vitality.green",
		Colour = Color3.fromRGB(95, 215, 95),
		IconPlaceholder = "icon-placeholder-vitality",
		BaseXP = DEFAULT_BASE_XP,
		XPExponent = DEFAULT_XP_EXPONENT,
		MaximumTestLevel = DEFAULT_MAXIMUM_TEST_LEVEL,
		DerivedStatResponsibilities = freezeArray({
			"MaxHP",
			"Recovery",
			"MinorResistance",
		}),
	}),
	table.freeze({
		Id = "Agility",
		DisplayName = "Agility",
		Description = "Mobility and precision for movement speed, critical chance, and dodge quality.",
		ColourToken = "stat.agility.blue",
		Colour = Color3.fromRGB(80, 183, 255),
		IconPlaceholder = "icon-placeholder-agility",
		BaseXP = DEFAULT_BASE_XP,
		XPExponent = DEFAULT_XP_EXPONENT,
		MaximumTestLevel = DEFAULT_MAXIMUM_TEST_LEVEL,
		DerivedStatResponsibilities = freezeArray({
			"MoveSpeedBonus",
			"CriticalChance",
			"DodgeQuality",
		}),
	}),
	table.freeze({
		Id = "Endurance",
		DisplayName = "Endurance",
		Description = "Staying power for stamina, Focus recovery, and sustained pressure resistance.",
		ColourToken = "stat.endurance.gold",
		Colour = Color3.fromRGB(255, 204, 74),
		IconPlaceholder = "icon-placeholder-endurance",
		BaseXP = DEFAULT_BASE_XP,
		XPExponent = DEFAULT_XP_EXPONENT,
		MaximumTestLevel = DEFAULT_MAXIMUM_TEST_LEVEL,
		DerivedStatResponsibilities = freezeArray({
			"MaxStamina",
			"FocusRecovery",
			"SustainedPressureResistance",
		}),
	}),
	table.freeze({
		Id = "Control",
		DisplayName = "Control",
		Description = "Technical mastery for skill effectiveness, guard, parry accuracy, and combo quality.",
		ColourToken = "stat.control.purple",
		Colour = Color3.fromRGB(181, 111, 255),
		IconPlaceholder = "icon-placeholder-control",
		BaseXP = DEFAULT_BASE_XP,
		XPExponent = DEFAULT_XP_EXPONENT,
		MaximumTestLevel = DEFAULT_MAXIMUM_TEST_LEVEL,
		DerivedStatResponsibilities = freezeArray({
			"SkillEffectiveness",
			"GuardEffectiveness",
			"ParryAccuracy",
			"ComboQuality",
		}),
	}),
}

local STATS_BY_ID = {}
local STAT_IDS = {}

for index, statDefinition in ipairs(STAT_DEFINITIONS) do
	STATS_BY_ID[statDefinition.Id] = statDefinition
	STAT_IDS[index] = statDefinition.Id
end

StatConfig.Stats = table.freeze(STAT_DEFINITIONS)

function StatConfig.GetStatIds()
	return table.clone(STAT_IDS)
end

function StatConfig.GetStat(statId)
	if typeof(statId) ~= "string" then
		return nil
	end

	return STATS_BY_ID[statId]
end

function StatConfig.IsValidStatId(statId)
	return StatConfig.GetStat(statId) ~= nil
end

local function normalizePositiveLevel(level)
	local numericLevel = tonumber(level)
	if numericLevel == nil then
		return nil
	end

	local flooredLevel = math.floor(numericLevel)
	if flooredLevel < 1 then
		return nil
	end

	return flooredLevel
end

function StatConfig.GetRequiredXPForLevel(statId, level)
	local statDefinition = StatConfig.GetStat(statId)
	local positiveLevel = normalizePositiveLevel(level)

	if statDefinition == nil or positiveLevel == nil then
		return nil
	end

	local requiredXP = statDefinition.BaseXP * (positiveLevel ^ statDefinition.XPExponent)
	return math.floor(requiredXP + 0.5)
end

function StatConfig.GetTotalXPRequiredForLevel(statId, targetLevel)
	if not StatConfig.IsValidStatId(statId) then
		return nil
	end

	local numericLevel = tonumber(targetLevel)
	if numericLevel == nil then
		return nil
	end

	local flooredLevel = math.floor(numericLevel)
	if flooredLevel < 0 then
		return nil
	end

	local totalXP = 0
	for level = 1, flooredLevel do
		totalXP += StatConfig.GetRequiredXPForLevel(statId, level)
	end

	return totalXP
end

return table.freeze(StatConfig)
