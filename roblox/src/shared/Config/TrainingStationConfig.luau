local StatConfig = require(script.Parent.StatConfig)

local TrainingStationConfig = {}

local DEFAULT_INTERACTION_RANGE = 12
local DEFAULT_COOLDOWN_SECONDS = 8
local DEFAULT_DURATION_SECONDS = 18
local DEFAULT_BASE_XP = 100

local STATIONS = {
	table.freeze({
		Id = "StrengthForge",
		DisplayName = "Strength Forge",
		Description = "Power station with a server-validated three-repetition timing challenge.",
		StatId = "Power",
		InteractionRange = DEFAULT_INTERACTION_RANGE,
		CooldownSeconds = DEFAULT_COOLDOWN_SECONDS,
		DurationSeconds = DEFAULT_DURATION_SECONDS,
		BaseXP = DEFAULT_BASE_XP,
		PromptPath = table.freeze({
			"Workspace",
			"AscensionGrounds",
			"StrengthForge",
			"ForgeCore",
			"TrainStrengthPrompt",
		}),
		AnchorPath = table.freeze({
			"Workspace",
			"AscensionGrounds",
			"StrengthForge",
			"ForgeCore",
		}),
		PromptActionText = "Train",
		PromptObjectText = "Strength Forge",
		PromptHoldDuration = 0.25,
		MinigameResult = table.freeze({
			Enabled = true,
			MinimumMultiplier = 0.85,
			MaximumMultiplier = 1.5,
		}),
		Minigame = table.freeze({
			Enabled = true,
			RequiredSuccesses = 3,
			MaxAttempts = 6,
			MarkerPeriodSeconds = 1.35,
			ChallengeTimeoutSeconds = 28,
			ServerInputTolerance = 0.045,
			TargetZones = table.freeze({
				table.freeze({
					Center = 0.50,
					Width = 0.24,
					PerfectWidth = 0.08,
				}),
				table.freeze({
					Center = 0.62,
					Width = 0.22,
					PerfectWidth = 0.07,
				}),
				table.freeze({
					Center = 0.38,
					Width = 0.22,
					PerfectWidth = 0.07,
				}),
			}),
		}),
	}),
}

local STATIONS_BY_ID = {}

for _, station in ipairs(STATIONS) do
	STATIONS_BY_ID[station.Id] = station
end

local function cloneArray(values)
	local copy = {}

	for index, value in ipairs(values) do
		copy[index] = value
	end

	return copy
end

local function deepCopy(value)
	if typeof(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, childValue in pairs(value) do
		copy[key] = deepCopy(childValue)
	end

	return copy
end

local function cloneStation(station)
	local copy = {}

	for key, value in pairs(station) do
		if key == "PromptPath" or key == "AnchorPath" then
			copy[key] = cloneArray(value)
		elseif key == "MinigameResult" or key == "Minigame" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end

	return copy
end

function TrainingStationConfig.GetStationIds()
	local ids = {}

	for index, station in ipairs(STATIONS) do
		ids[index] = station.Id
	end

	return ids
end

function TrainingStationConfig.GetStation(stationId)
	if typeof(stationId) ~= "string" then
		return nil
	end

	local station = STATIONS_BY_ID[stationId]
	if station == nil then
		return nil
	end

	return station
end

function TrainingStationConfig.GetStations()
	local stations = {}

	for index, station in ipairs(STATIONS) do
		stations[index] = cloneStation(station)
	end

	return stations
end

function TrainingStationConfig.IsValidStationId(stationId)
	return TrainingStationConfig.GetStation(stationId) ~= nil
end

function TrainingStationConfig.ValidateStation(station)
	if typeof(station) ~= "table" then
		return false, "Station must be a table"
	end

	if typeof(station.Id) ~= "string" or station.Id == "" then
		return false, "Station Id is required"
	end

	if not StatConfig.IsValidStatId(station.StatId) then
		return false, "Station StatId is invalid"
	end

	if tonumber(station.InteractionRange) == nil or station.InteractionRange <= 0 then
		return false, "Station InteractionRange must be positive"
	end

	if tonumber(station.CooldownSeconds) == nil or station.CooldownSeconds < 0 then
		return false, "Station CooldownSeconds must be non-negative"
	end

	if tonumber(station.DurationSeconds) == nil or station.DurationSeconds <= 0 then
		return false, "Station DurationSeconds must be positive"
	end

	if tonumber(station.BaseXP) == nil or station.BaseXP <= 0 then
		return false, "Station BaseXP must be positive"
	end

	if typeof(station.PromptPath) ~= "table" or #station.PromptPath == 0 then
		return false, "Station PromptPath is required"
	end

	if typeof(station.AnchorPath) ~= "table" or #station.AnchorPath == 0 then
		return false, "Station AnchorPath is required"
	end

	if typeof(station.MinigameResult) == "table" and station.MinigameResult.Enabled == true then
		if typeof(station.Minigame) ~= "table" or station.Minigame.Enabled ~= true then
			return false, "Station Minigame config is required when MinigameResult is enabled"
		end

		if tonumber(station.Minigame.RequiredSuccesses) == nil or station.Minigame.RequiredSuccesses <= 0 then
			return false, "Station Minigame.RequiredSuccesses must be positive"
		end

		if tonumber(station.Minigame.MaxAttempts) == nil or station.Minigame.MaxAttempts < station.Minigame.RequiredSuccesses then
			return false, "Station Minigame.MaxAttempts must be at least RequiredSuccesses"
		end

		if tonumber(station.Minigame.MarkerPeriodSeconds) == nil or station.Minigame.MarkerPeriodSeconds <= 0 then
			return false, "Station Minigame.MarkerPeriodSeconds must be positive"
		end

		if typeof(station.Minigame.TargetZones) ~= "table" or #station.Minigame.TargetZones == 0 then
			return false, "Station Minigame.TargetZones must contain at least one zone"
		end
	end

	return true, nil
end

return table.freeze(TrainingStationConfig)
