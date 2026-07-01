local CombatStatConfig = require(script.Parent.Parent.Config.CombatStatConfig)

local DerivedCombatStats = {}

local function toFiniteNumber(value, defaultValue)
	local numericValue = tonumber(value)
	if numericValue == nil or numericValue ~= numericValue or numericValue == math.huge or numericValue == -math.huge then
		return defaultValue
	end

	return numericValue
end

local function readNonNegativeNumber(value)
	return math.max(0, toFiniteNumber(value, 0))
end

local function readPositiveInteger(value, defaultValue)
	local numericValue = toFiniteNumber(value, defaultValue)
	return math.max(1, math.floor(numericValue))
end

local function roundToPrecision(value, precision)
	if precision <= 0 then
		return math.floor(value + 0.5)
	end

	local multiplier = 10 ^ precision
	return math.floor(value * multiplier + 0.5) / multiplier
end

local function createStatMap(defaultValue)
	local statMap = {}
	for _, statKey in ipairs(CombatStatConfig.GetCombatStatKeys()) do
		statMap[statKey] = defaultValue or 0
	end

	return statMap
end

local function copyKnownStatMap(source)
	local statMap = createStatMap(0)
	if typeof(source) ~= "table" then
		return statMap
	end

	for _, statKey in ipairs(CombatStatConfig.GetCombatStatKeys()) do
		statMap[statKey] = readNonNegativeNumber(source[statKey])
	end

	return statMap
end

local function addStatMap(target, source)
	for _, statKey in ipairs(CombatStatConfig.GetCombatStatKeys()) do
		target[statKey] += source[statKey] or 0
	end
end

local function readTrainingValue(trainingStats, statId)
	if typeof(trainingStats) ~= "table" then
		return 0
	end

	local statValue = trainingStats[statId]
	if typeof(statValue) == "table" then
		return readNonNegativeNumber(statValue.EffectiveValue or statValue.Value or statValue.Level)
	end

	return readNonNegativeNumber(statValue)
end

local function calculateTrainingContributions(trainingStats)
	local aggregate = createStatMap(0)
	local byTrainingStat = {}
	local effectiveTrainingValues = {}
	local trainingWeights = CombatStatConfig.GetTrainingWeights()

	for _, trainingStatId in ipairs(CombatStatConfig.GetTrainingStatIds()) do
		local weights = trainingWeights[trainingStatId] or {}
		local effectiveValue = readTrainingValue(trainingStats, trainingStatId)
		local contribution = createStatMap(0)
		effectiveTrainingValues[trainingStatId] = effectiveValue

		for statKey, weight in pairs(weights) do
			if CombatStatConfig.IsCombatStatKey(statKey) then
				contribution[statKey] = effectiveValue * readNonNegativeNumber(weight)
				aggregate[statKey] += contribution[statKey]
			end
		end

		byTrainingStat[trainingStatId] = contribution
	end

	return aggregate, byTrainingStat, effectiveTrainingValues
end

local function calculateHeroLevelContributions(heroLevel)
	local contribution = createStatMap(0)
	local heroLevelScaling = CombatStatConfig.GetHeroLevelScaling()
	local levelsAfterFirst = math.max(0, heroLevel - 1)

	for statKey, amountPerLevel in pairs(heroLevelScaling) do
		if CombatStatConfig.IsCombatStatKey(statKey) then
			contribution[statKey] = levelsAfterFirst * readNonNegativeNumber(amountPerLevel)
		end
	end

	return contribution
end

local function mergeClassModifier(baseModifier, overrideModifier)
	local merged = {
		Id = baseModifier.Id,
		Additive = table.clone(baseModifier.Additive),
		Multipliers = table.clone(baseModifier.Multipliers),
	}

	if typeof(overrideModifier) ~= "table" then
		return merged
	end

	if typeof(overrideModifier.Id) == "string" and overrideModifier.Id ~= "" then
		merged.Id = overrideModifier.Id
	end

	if typeof(overrideModifier.Additive) == "table" then
		for statKey, value in pairs(overrideModifier.Additive) do
			if CombatStatConfig.IsCombatStatKey(statKey) then
				merged.Additive[statKey] = readNonNegativeNumber(value)
			end
		end
	end

	if typeof(overrideModifier.Multipliers) == "table" then
		for statKey, value in pairs(overrideModifier.Multipliers) do
			if CombatStatConfig.IsCombatStatKey(statKey) then
				merged.Multipliers[statKey] = toFiniteNumber(value, 1)
			end
		end
	end

	return merged
end

local function clampClassMultiplier(multiplier)
	local limits = CombatStatConfig.GetClassMultiplierLimits()
	return math.clamp(toFiniteNumber(multiplier, 1), limits.Minimum, limits.Maximum)
end

local function applyClassModifier(subtotal, classModifier)
	local classContribution = createStatMap(0)
	local classBeforeCap = createStatMap(0)

	for _, statKey in ipairs(CombatStatConfig.GetCombatStatKeys()) do
		local beforeClass = subtotal[statKey]
		local additive = readNonNegativeNumber(classModifier.Additive[statKey])
		local multiplier = clampClassMultiplier(classModifier.Multipliers[statKey] or 1)
		local afterClass = (beforeClass + additive) * multiplier

		classContribution[statKey] = afterClass - beforeClass
		classBeforeCap[statKey] = afterClass
	end

	return classContribution, classBeforeCap
end

local function applyCaps(statMap)
	local caps = CombatStatConfig.GetStatCaps()
	local precision = CombatStatConfig.GetStatPrecision()
	local finalStats = createStatMap(0)
	local capReport = {}

	for _, statKey in ipairs(CombatStatConfig.GetCombatStatKeys()) do
		local beforeCap = readNonNegativeNumber(statMap[statKey])
		local cap = caps[statKey]
		local afterCap = beforeCap

		if cap ~= nil then
			afterCap = math.min(beforeCap, cap)
		end

		finalStats[statKey] = roundToPrecision(afterCap, precision[statKey] or 2)
		capReport[statKey] = {
			Applied = cap ~= nil and beforeCap > cap,
			Cap = cap,
			BeforeCap = roundToPrecision(beforeCap, precision[statKey] or 2),
			AfterCap = finalStats[statKey],
		}
	end

	return finalStats, capReport
end

function DerivedCombatStats.Calculate(input)
	if typeof(input) ~= "table" then
		input = {}
	end

	local heroLevel = readPositiveInteger(input.HeroLevel, 1)
	local base = CombatStatConfig.GetBaseStats()
	local heroLevelContribution = calculateHeroLevelContributions(heroLevel)
	local trainingContribution, trainingByStat, effectiveTrainingValues = calculateTrainingContributions(input.TrainingStats)
	local equipmentContribution = copyKnownStatMap(input.EquipmentBonuses)

	local subtotalBeforeClass = table.clone(base)
	addStatMap(subtotalBeforeClass, heroLevelContribution)
	addStatMap(subtotalBeforeClass, trainingContribution)
	addStatMap(subtotalBeforeClass, equipmentContribution)

	local classId = input.ClassId
	if typeof(classId) ~= "string" or classId == "" then
		classId = CombatStatConfig.GetDefaultClassId()
	end

	local baseClassModifier = CombatStatConfig.GetClassModifier(classId)
	local classModifier = mergeClassModifier(baseClassModifier, input.ClassModifiers)
	local classContribution, uncappedStats = applyClassModifier(subtotalBeforeClass, classModifier)
	local finalStats, capReport = applyCaps(uncappedStats)

	return {
		Stats = finalStats,
		Contributions = {
			Base = table.clone(base),
			HeroLevel = heroLevelContribution,
			Training = trainingContribution,
			TrainingByStat = trainingByStat,
			Equipment = equipmentContribution,
			Class = classContribution,
		},
		Metadata = {
			HeroLevel = heroLevel,
			EffectiveTrainingValues = effectiveTrainingValues,
			ClassId = classModifier.Id,
			UncappedStats = uncappedStats,
			Caps = capReport,
		},
	}
end

function DerivedCombatStats.CalculateForProfile(profile, options)
	if typeof(options) ~= "table" then
		options = {}
	end

	if typeof(profile) ~= "table" then
		profile = {}
	end

	return DerivedCombatStats.Calculate({
		HeroLevel = profile.HeroLevel,
		TrainingStats = profile.TrainingStats,
		EquipmentBonuses = options.EquipmentBonuses,
		ClassId = options.ClassId or profile.ClassId,
		ClassModifiers = options.ClassModifiers,
	})
end

return table.freeze(DerivedCombatStats)
