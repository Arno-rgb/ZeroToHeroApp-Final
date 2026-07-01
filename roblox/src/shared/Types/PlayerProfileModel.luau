local StatConfig = require(script.Parent.Parent.Config.StatConfig)

local PlayerProfileModel = {}

local CURRENT_VERSION = 1
local EQUIPMENT_SLOTS = { "Weapon", "Armour", "Charm" }

local function deepCopy(value)
	if typeof(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, childValue in pairs(value) do
		copy[deepCopy(key)] = deepCopy(childValue)
	end

	return copy
end

local function appendIssue(issues, path, message)
	table.insert(issues, {
		Path = path,
		Message = message,
	})
end

local function toInteger(value)
	local numericValue = tonumber(value)
	if numericValue == nil then
		return nil
	end

	return math.floor(numericValue)
end

local function readNonNegativeInteger(source, key, defaultValue, issues, path)
	if typeof(source) ~= "table" then
		appendIssue(issues, path, "Parent table is missing")
		return defaultValue
	end

	local integerValue = toInteger(source[key])
	if integerValue == nil or integerValue < 0 then
		appendIssue(issues, path, "Expected a non-negative integer")
		return defaultValue
	end

	return integerValue
end

local function readPositiveInteger(source, key, defaultValue, issues, path)
	if typeof(source) ~= "table" then
		appendIssue(issues, path, "Parent table is missing")
		return defaultValue
	end

	local integerValue = toInteger(source[key])
	if integerValue == nil or integerValue < 1 then
		appendIssue(issues, path, "Expected a positive integer")
		return defaultValue
	end

	return integerValue
end

local function createDefaultTrainingStats()
	local trainingStats = {}

	for _, statId in ipairs(StatConfig.GetStatIds()) do
		trainingStats[statId] = {
			Level = 0,
			XP = 0,
			EffectiveValue = 0,
		}
	end

	return trainingStats
end

local function createDefaultEquipment()
	local equipment = {}

	for _, slotName in ipairs(EQUIPMENT_SLOTS) do
		equipment[slotName] = false
	end

	return equipment
end

local function createDefaultTrainingDaily()
	local stats = {}

	for _, statId in ipairs(StatConfig.GetStatIds()) do
		stats[statId] = {
			Seconds = 0,
			BaseXP = 0,
			AwardedXP = 0,
		}
	end

	return {
		DateKey = "",
		TotalSeconds = 0,
		TotalBaseXP = 0,
		TotalAwardedXP = 0,
		Stats = stats,
	}
end

function PlayerProfileModel.GetCurrentVersion()
	return CURRENT_VERSION
end

function PlayerProfileModel.GetEquipmentSlots()
	return table.clone(EQUIPMENT_SLOTS)
end

function PlayerProfileModel.DeepCopy(value)
	return deepCopy(value)
end

function PlayerProfileModel.CreateDefaultTrainingStats()
	return createDefaultTrainingStats()
end

function PlayerProfileModel.CreateDefaultTrainingDaily()
	return createDefaultTrainingDaily()
end

function PlayerProfileModel.CreateDefaultProfile()
	return {
		Version = CURRENT_VERSION,
		HeroLevel = 1,
		HeroXP = 0,
		Gold = 0,
		TrainingStats = createDefaultTrainingStats(),
		Equipment = createDefaultEquipment(),
		Inventory = {
			Items = {},
			NextItemInstanceId = 1,
		},
		Materials = {},
		Campaign = {
			ChapterId = "BrokenGate",
			HighestUnlockedNodeId = "Start",
			CompletedNodes = {},
			BossVictories = {},
		},
		MobileLink = {
			Linked = false,
			Provider = "None",
			ExternalUserId = "",
			LinkedAt = 0,
		},
		RewardClaims = {},
		TrainingDaily = createDefaultTrainingDaily(),
	}
end

local function repairMaterials(rawMaterials, issues)
	local materials = {}

	if rawMaterials == nil then
		return materials
	end

	if typeof(rawMaterials) ~= "table" then
		appendIssue(issues, "Materials", "Expected table")
		return materials
	end

	for materialId, amount in pairs(rawMaterials) do
		if typeof(materialId) == "string" and materialId ~= "" then
			local cleanAmount = math.max(0, toInteger(amount) or 0)
			if cleanAmount > 0 then
				materials[materialId] = cleanAmount
			end
		else
			appendIssue(issues, "Materials", "Expected string material ids")
		end
	end

	return materials
end

local function repairTrainingStats(rawTrainingStats, issues)
	local trainingStats = createDefaultTrainingStats()

	if typeof(rawTrainingStats) ~= "table" then
		appendIssue(issues, "TrainingStats", "Expected table")
		return trainingStats
	end

	for _, statId in ipairs(StatConfig.GetStatIds()) do
		local rawStat = rawTrainingStats[statId]
		if typeof(rawStat) ~= "table" then
			appendIssue(issues, "TrainingStats." .. statId, "Expected stat table")
		else
			trainingStats[statId] = {
				Level = readNonNegativeInteger(rawStat, "Level", 0, issues, "TrainingStats." .. statId .. ".Level"),
				XP = readNonNegativeInteger(rawStat, "XP", 0, issues, "TrainingStats." .. statId .. ".XP"),
				EffectiveValue = readNonNegativeInteger(rawStat, "EffectiveValue", 0, issues, "TrainingStats." .. statId .. ".EffectiveValue"),
			}
		end
	end

	return trainingStats
end

local function repairEquipment(rawEquipment, issues)
	local equipment = createDefaultEquipment()

	if typeof(rawEquipment) ~= "table" then
		appendIssue(issues, "Equipment", "Expected table")
		return equipment
	end

	for _, slotName in ipairs(EQUIPMENT_SLOTS) do
		local slotValue = rawEquipment[slotName]
		if slotValue == false or typeof(slotValue) == "string" then
			equipment[slotName] = slotValue
		else
			appendIssue(issues, "Equipment." .. slotName, "Expected false or owned item instance id")
		end
	end

	return equipment
end

local function repairInventory(rawInventory, issues)
	if typeof(rawInventory) ~= "table" then
		appendIssue(issues, "Inventory", "Expected table")
		return {
			Items = {},
			NextItemInstanceId = 1,
		}
	end

	local items = {}
	if typeof(rawInventory.Items) == "table" then
		items = deepCopy(rawInventory.Items)
	else
		appendIssue(issues, "Inventory.Items", "Expected table")
	end

	return {
		Items = items,
		NextItemInstanceId = readPositiveInteger(rawInventory, "NextItemInstanceId", 1, issues, "Inventory.NextItemInstanceId"),
	}
end

local function repairCampaign(rawCampaign, issues)
	local campaign = {
		ChapterId = "BrokenGate",
		HighestUnlockedNodeId = "Start",
		CompletedNodes = {},
		BossVictories = {},
	}

	if typeof(rawCampaign) ~= "table" then
		appendIssue(issues, "Campaign", "Expected table")
		return campaign
	end

	if typeof(rawCampaign.ChapterId) == "string" and rawCampaign.ChapterId ~= "" then
		campaign.ChapterId = rawCampaign.ChapterId
	else
		appendIssue(issues, "Campaign.ChapterId", "Expected non-empty string")
	end

	if typeof(rawCampaign.HighestUnlockedNodeId) == "string" and rawCampaign.HighestUnlockedNodeId ~= "" then
		campaign.HighestUnlockedNodeId = rawCampaign.HighestUnlockedNodeId
	else
		appendIssue(issues, "Campaign.HighestUnlockedNodeId", "Expected non-empty string")
	end

	if typeof(rawCampaign.CompletedNodes) == "table" then
		campaign.CompletedNodes = deepCopy(rawCampaign.CompletedNodes)
	else
		appendIssue(issues, "Campaign.CompletedNodes", "Expected table")
	end

	if typeof(rawCampaign.BossVictories) == "table" then
		campaign.BossVictories = deepCopy(rawCampaign.BossVictories)
	else
		appendIssue(issues, "Campaign.BossVictories", "Expected table")
	end

	return campaign
end

local function repairMobileLink(rawMobileLink, issues)
	local mobileLink = {
		Linked = false,
		Provider = "None",
		ExternalUserId = "",
		LinkedAt = 0,
	}

	if typeof(rawMobileLink) ~= "table" then
		appendIssue(issues, "MobileLink", "Expected table")
		return mobileLink
	end

	if typeof(rawMobileLink.Linked) == "boolean" then
		mobileLink.Linked = rawMobileLink.Linked
	else
		appendIssue(issues, "MobileLink.Linked", "Expected boolean")
	end

	if typeof(rawMobileLink.Provider) == "string" and rawMobileLink.Provider ~= "" then
		mobileLink.Provider = rawMobileLink.Provider
	else
		appendIssue(issues, "MobileLink.Provider", "Expected non-empty string")
	end

	if typeof(rawMobileLink.ExternalUserId) == "string" then
		mobileLink.ExternalUserId = rawMobileLink.ExternalUserId
	else
		appendIssue(issues, "MobileLink.ExternalUserId", "Expected string")
	end

	mobileLink.LinkedAt = readNonNegativeInteger(rawMobileLink, "LinkedAt", 0, issues, "MobileLink.LinkedAt")

	return mobileLink
end

local function repairTrainingDaily(rawTrainingDaily, issues)
	local trainingDaily = createDefaultTrainingDaily()

	if typeof(rawTrainingDaily) ~= "table" then
		appendIssue(issues, "TrainingDaily", "Expected table")
		return trainingDaily
	end

	if typeof(rawTrainingDaily.DateKey) == "string" then
		trainingDaily.DateKey = rawTrainingDaily.DateKey
	else
		appendIssue(issues, "TrainingDaily.DateKey", "Expected string")
	end

	trainingDaily.TotalSeconds = readNonNegativeInteger(rawTrainingDaily, "TotalSeconds", 0, issues, "TrainingDaily.TotalSeconds")
	trainingDaily.TotalBaseXP = readNonNegativeInteger(rawTrainingDaily, "TotalBaseXP", 0, issues, "TrainingDaily.TotalBaseXP")
	trainingDaily.TotalAwardedXP = readNonNegativeInteger(rawTrainingDaily, "TotalAwardedXP", 0, issues, "TrainingDaily.TotalAwardedXP")

	if typeof(rawTrainingDaily.Stats) ~= "table" then
		appendIssue(issues, "TrainingDaily.Stats", "Expected table")
		return trainingDaily
	end

	for _, statId in ipairs(StatConfig.GetStatIds()) do
		local rawStat = rawTrainingDaily.Stats[statId]
		if typeof(rawStat) ~= "table" then
			appendIssue(issues, "TrainingDaily.Stats." .. statId, "Expected stat daily table")
		else
			trainingDaily.Stats[statId] = {
				Seconds = readNonNegativeInteger(rawStat, "Seconds", 0, issues, "TrainingDaily.Stats." .. statId .. ".Seconds"),
				BaseXP = readNonNegativeInteger(rawStat, "BaseXP", 0, issues, "TrainingDaily.Stats." .. statId .. ".BaseXP"),
				AwardedXP = readNonNegativeInteger(rawStat, "AwardedXP", 0, issues, "TrainingDaily.Stats." .. statId .. ".AwardedXP"),
			}
		end
	end

	return trainingDaily
end

function PlayerProfileModel.RepairProfile(rawProfile)
	local issues = {}
	local profile = PlayerProfileModel.CreateDefaultProfile()

	if typeof(rawProfile) ~= "table" then
		appendIssue(issues, "Profile", "Expected table")
		return {
			Profile = profile,
			WasRepaired = true,
			Issues = issues,
		}
	end

	profile.Version = readPositiveInteger(rawProfile, "Version", CURRENT_VERSION, issues, "Version")
	if profile.Version ~= CURRENT_VERSION then
		appendIssue(issues, "Version", "Profile version differs from current model version")
		profile.Version = CURRENT_VERSION
	end

	profile.HeroLevel = readPositiveInteger(rawProfile, "HeroLevel", 1, issues, "HeroLevel")
	profile.HeroXP = readNonNegativeInteger(rawProfile, "HeroXP", 0, issues, "HeroXP")
	profile.Gold = readNonNegativeInteger(rawProfile, "Gold", 0, issues, "Gold")
	profile.TrainingStats = repairTrainingStats(rawProfile.TrainingStats, issues)
	profile.Equipment = repairEquipment(rawProfile.Equipment, issues)
	profile.Inventory = repairInventory(rawProfile.Inventory, issues)
	profile.Materials = repairMaterials(rawProfile.Materials, issues)
	profile.Campaign = repairCampaign(rawProfile.Campaign, issues)
	profile.MobileLink = repairMobileLink(rawProfile.MobileLink, issues)

	if typeof(rawProfile.RewardClaims) == "table" then
		profile.RewardClaims = deepCopy(rawProfile.RewardClaims)
	else
		appendIssue(issues, "RewardClaims", "Expected table")
	end

	profile.TrainingDaily = repairTrainingDaily(rawProfile.TrainingDaily, issues)

	return {
		Profile = profile,
		WasRepaired = #issues > 0,
		Issues = issues,
	}
end

function PlayerProfileModel.ValidateProfile(profile)
	local repaired = PlayerProfileModel.RepairProfile(profile)

	return {
		IsValid = #repaired.Issues == 0,
		Issues = repaired.Issues,
	}
end

function PlayerProfileModel.MigrateProfile(rawProfile)
	-- Placeholder for future versioned migrations. For v1, migration is validation plus safe repair.
	return PlayerProfileModel.RepairProfile(rawProfile)
end

return table.freeze(PlayerProfileModel)
