local HeroProgressionConfig = {}

local MAX_HERO_LEVEL = 50

local LEVEL_CURVE = {
	BaseXP = 24,
	LinearXP = 16,
	QuadraticXP = 6,
}

local REWARD_REMOTE_NAME = "TrainingStationReward"

local function toPositiveInteger(value, defaultValue)
	local numericValue = tonumber(value)
	if numericValue == nil then
		return defaultValue
	end

	return math.max(1, math.floor(numericValue))
end

function HeroProgressionConfig.GetMaxHeroLevel()
	return MAX_HERO_LEVEL
end

function HeroProgressionConfig.GetRewardRemoteName()
	return REWARD_REMOTE_NAME
end

function HeroProgressionConfig.GetLevelCurve()
	return table.clone(LEVEL_CURVE)
end

function HeroProgressionConfig.GetRequiredXPForLevel(targetLevel)
	local cleanTargetLevel = toPositiveInteger(targetLevel, 1)
	if cleanTargetLevel <= 1 then
		return 0
	end

	if cleanTargetLevel > MAX_HERO_LEVEL then
		return nil
	end

	local levelIndex = cleanTargetLevel - 2
	return LEVEL_CURVE.BaseXP
		+ (LEVEL_CURVE.LinearXP * levelIndex)
		+ (LEVEL_CURVE.QuadraticXP * levelIndex * levelIndex)
end

function HeroProgressionConfig.GetProgress(heroLevel, heroXP)
	local cleanLevel = math.clamp(toPositiveInteger(heroLevel, 1), 1, MAX_HERO_LEVEL)
	local cleanXP = math.max(0, math.floor(tonumber(heroXP) or 0))
	local nextRequired = HeroProgressionConfig.GetRequiredXPForLevel(cleanLevel + 1) or 0

	return {
		Level = cleanLevel,
		XP = cleanXP,
		XPRequired = nextRequired,
		AtMaxLevel = cleanLevel >= MAX_HERO_LEVEL,
	}
end

return table.freeze(HeroProgressionConfig)
