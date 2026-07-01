local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ZeroToHeroShared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local StatConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("StatConfig"))
local PlayerDataService = require(ServerScriptService:WaitForChild("ZeroToHeroServer"):WaitForChild("Services"):WaitForChild("PlayerDataService"))

local TrainingService = {}

local DEFAULT_TRAINING_SECONDS = 60
local MAX_SINGLE_AWARD_SECONDS = 15 * 60
local MAX_SINGLE_BASE_XP = 100000

local DIMINISHING_RETURN_TIERS = table.freeze({
	table.freeze({
		UntilSeconds = 20 * 60,
		Multiplier = 1,
	}),
	table.freeze({
		UntilSeconds = 40 * 60,
		Multiplier = 0.7,
	}),
	table.freeze({
		UntilSeconds = 70 * 60,
		Multiplier = 0.4,
	}),
	table.freeze({
		UntilSeconds = math.huge,
		Multiplier = 0.15,
	}),
})

local function cleanNonNegativeInteger(value, defaultValue)
	local numericValue = tonumber(value)
	if numericValue == nil then
		return defaultValue
	end

	return math.max(0, math.floor(numericValue))
end

local function cleanPositiveInteger(value, defaultValue)
	local numericValue = tonumber(value)
	if numericValue == nil then
		return defaultValue
	end

	return math.max(1, math.floor(numericValue))
end

local function getDateKey(nowUnix)
	local dateParts = os.date("!*t", nowUnix or os.time())
	return string.format("%04d-%02d-%02d", dateParts.year, dateParts.month, dateParts.day)
end

local function createEmptyDailyTotals(dateKey)
	local stats = {}

	for _, statId in ipairs(StatConfig.GetStatIds()) do
		stats[statId] = {
			Seconds = 0,
			BaseXP = 0,
			AwardedXP = 0,
		}
	end

	return {
		DateKey = dateKey,
		TotalSeconds = 0,
		TotalBaseXP = 0,
		TotalAwardedXP = 0,
		Stats = stats,
	}
end

local function ensureDailyTotals(profile, dateKey)
	if typeof(profile.TrainingDaily) ~= "table" or profile.TrainingDaily.DateKey ~= dateKey then
		profile.TrainingDaily = createEmptyDailyTotals(dateKey)
	end

	if typeof(profile.TrainingDaily.Stats) ~= "table" then
		profile.TrainingDaily.Stats = createEmptyDailyTotals(dateKey).Stats
	end

	for _, statId in ipairs(StatConfig.GetStatIds()) do
		if typeof(profile.TrainingDaily.Stats[statId]) ~= "table" then
			profile.TrainingDaily.Stats[statId] = {
				Seconds = 0,
				BaseXP = 0,
				AwardedXP = 0,
			}
		end
	end

	return profile.TrainingDaily
end

local function getMultiplierForElapsedSeconds(elapsedSeconds)
	local cleanElapsed = cleanNonNegativeInteger(elapsedSeconds, 0)

	for _, tier in ipairs(DIMINISHING_RETURN_TIERS) do
		if cleanElapsed < tier.UntilSeconds then
			return tier.Multiplier
		end
	end

	return DIMINISHING_RETURN_TIERS[#DIMINISHING_RETURN_TIERS].Multiplier
end

local function calculateDiminishingReturn(baseXP, durationSeconds, priorDailySeconds)
	local cleanBaseXP = cleanNonNegativeInteger(baseXP, 0)
	local cleanDurationSeconds = cleanPositiveInteger(durationSeconds, DEFAULT_TRAINING_SECONDS)
	local cleanPriorSeconds = cleanNonNegativeInteger(priorDailySeconds, 0)

	if cleanBaseXP <= 0 then
		return {
			BaseXP = cleanBaseXP,
			DurationSeconds = cleanDurationSeconds,
			PriorDailySeconds = cleanPriorSeconds,
			Multiplier = 0,
			AwardedXP = 0,
		}
	end

	local remainingSeconds = cleanDurationSeconds
	local cursorSeconds = cleanPriorSeconds
	local weightedSeconds = 0

	for _, tier in ipairs(DIMINISHING_RETURN_TIERS) do
		if remainingSeconds <= 0 then
			break
		end

		if cursorSeconds < tier.UntilSeconds then
			local secondsInTier = math.min(remainingSeconds, tier.UntilSeconds - cursorSeconds)
			weightedSeconds += secondsInTier * tier.Multiplier
			cursorSeconds += secondsInTier
			remainingSeconds -= secondsInTier
		end
	end

	local averageMultiplier = weightedSeconds / cleanDurationSeconds
	local awardedXP = math.floor((cleanBaseXP * averageMultiplier) + 0.5)

	return {
		BaseXP = cleanBaseXP,
		DurationSeconds = cleanDurationSeconds,
		PriorDailySeconds = cleanPriorSeconds,
		Multiplier = averageMultiplier,
		AwardedXP = awardedXP,
	}
end

local function applyXPToTrainingStat(profile, statId, xpAmount)
	local statDefinition = StatConfig.GetStat(statId)
	local stat = profile.TrainingStats[statId]
	local oldLevel = stat.Level
	local oldXP = stat.XP
	local cleanXP = cleanNonNegativeInteger(xpAmount, 0)
	local levelUps = 0

	stat.XP += cleanXP

	while stat.Level < statDefinition.MaximumTestLevel do
		local nextLevel = stat.Level + 1
		local requiredXP = StatConfig.GetRequiredXPForLevel(statId, nextLevel)
		if requiredXP == nil or stat.XP < requiredXP then
			break
		end

		stat.XP -= requiredXP
		stat.Level += 1
		levelUps += 1
	end

	stat.EffectiveValue = stat.Level

	return {
		OldLevel = oldLevel,
		NewLevel = stat.Level,
		OldXP = oldXP,
		NewXP = stat.XP,
		LevelUps = levelUps,
		NewEffectiveValue = stat.EffectiveValue,
	}
end

local function calculateTrainingRankFromStats(trainingStats)
	local count = 0
	local total = 0
	local lowest = math.huge

	for _, statId in ipairs(StatConfig.GetStatIds()) do
		local stat = trainingStats[statId]
		local value = 0
		if stat then
			value = cleanNonNegativeInteger(stat.EffectiveValue or stat.Level, 0)
		end

		count += 1
		total += value
		lowest = math.min(lowest, value)
	end

	if count == 0 then
		return 0
	end

	local average = total / count
	return math.floor((average + lowest) / 2)
end

function TrainingService.GetDiminishingReturnTiers()
	return DIMINISHING_RETURN_TIERS
end

function TrainingService.GetDateKey(nowUnix)
	return getDateKey(nowUnix)
end

function TrainingService.GetDiminishingReturnMultiplier(priorDailySeconds)
	return getMultiplierForElapsedSeconds(priorDailySeconds)
end

function TrainingService.CalculateDiminishedXP(baseXP, durationSeconds, priorDailySeconds)
	return calculateDiminishingReturn(baseXP, durationSeconds, priorDailySeconds)
end

function TrainingService.CalculateTrainingRank(profile)
	if typeof(profile) ~= "table" or typeof(profile.TrainingStats) ~= "table" then
		return 0
	end

	return calculateTrainingRankFromStats(profile.TrainingStats)
end

function TrainingService.AwardTrainingXP(player, statId, baseXP, options)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return {
			Success = false,
			Error = "InvalidPlayer",
		}
	end

	if not StatConfig.IsValidStatId(statId) then
		return {
			Success = false,
			Error = "InvalidStat",
		}
	end

	local cleanBaseXP = cleanNonNegativeInteger(baseXP, 0)
	if cleanBaseXP <= 0 or cleanBaseXP > MAX_SINGLE_BASE_XP then
		return {
			Success = false,
			Error = "InvalidXP",
		}
	end

	local cleanOptions = options or {}
	if typeof(cleanOptions) ~= "table" then
		cleanOptions = {}
	end

	local durationSeconds = cleanPositiveInteger(cleanOptions.DurationSeconds, DEFAULT_TRAINING_SECONDS)
	if durationSeconds > MAX_SINGLE_AWARD_SECONDS then
		return {
			Success = false,
			Error = "InvalidDuration",
		}
	end

	local source = tostring(cleanOptions.Source or "Training")
	local dateKey = cleanOptions.DateKey
	if typeof(dateKey) ~= "string" or dateKey == "" then
		dateKey = getDateKey(cleanOptions.NowUnix)
	end

	local mutationResult = nil
	local success, err = PlayerDataService.MutateProfile(player, source, function(profile)
		local dailyTotals = ensureDailyTotals(profile, dateKey)
		local priorDailySeconds = cleanNonNegativeInteger(dailyTotals.TotalSeconds, 0)
		local diminished = calculateDiminishingReturn(cleanBaseXP, durationSeconds, priorDailySeconds)
		local applied = applyXPToTrainingStat(profile, statId, diminished.AwardedXP)
		local statDaily = dailyTotals.Stats[statId]

		dailyTotals.TotalSeconds += durationSeconds
		dailyTotals.TotalBaseXP += cleanBaseXP
		dailyTotals.TotalAwardedXP += diminished.AwardedXP
		statDaily.Seconds += durationSeconds
		statDaily.BaseXP += cleanBaseXP
		statDaily.AwardedXP += diminished.AwardedXP

		mutationResult = {
			Success = true,
			Stat = statId,
			Source = source,
			DateKey = dateKey,
			BaseXP = cleanBaseXP,
			XPGained = diminished.AwardedXP,
			DurationSeconds = durationSeconds,
			DiminishingMultiplier = diminished.Multiplier,
			PriorDailySeconds = priorDailySeconds,
			NewDailySeconds = dailyTotals.TotalSeconds,
			OldLevel = applied.OldLevel,
			NewLevel = applied.NewLevel,
			OldXP = applied.OldXP,
			NewXP = applied.NewXP,
			LevelUps = applied.LevelUps,
			NewEffectiveValue = applied.NewEffectiveValue,
			TrainingRank = calculateTrainingRankFromStats(profile.TrainingStats),
		}
	end)

	if not success then
		return {
			Success = false,
			Error = tostring(err),
		}
	end

	return mutationResult
end

return table.freeze(TrainingService)
