local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ZeroToHeroShared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local TrainingStationConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("TrainingStationConfig"))
local TrainingService = require(script.Parent:WaitForChild("TrainingService"))

local TrainingStationService = {}

local REMOTES_FOLDER_NAME = "Remotes"
local REWARD_EVENT_NAME = "TrainingStationReward"
local CHALLENGE_EVENT_NAME = "TrainingStationChallenge"
local ACTION_EVENT_NAME = "TrainingStationAction"
local LEGACY_REMOTES_FOLDER_NAME = "AscensionRemotes"
local LEGACY_STAT_CHANGED_EVENT_NAME = "StatChanged"

local DEFAULT_REQUIRED_SUCCESSES = 3
local DEFAULT_MAX_ATTEMPTS = 6
local DEFAULT_MARKER_PERIOD_SECONDS = 1.35
local DEFAULT_CHALLENGE_TIMEOUT_SECONDS = 28
local DEFAULT_INPUT_TOLERANCE = 0.045

local hasStarted = false
local actionConnection = nil
local connectionsByStationId = {}
local cooldownsByPlayer = {}
local activeChallengesByPlayer = {}
local rewardCallbacks = {}

local function resolvePath(pathSegments)
	local current = game

	for index, segment in ipairs(pathSegments) do
		if index == 1 and segment == "game" then
			current = game
		elseif index == 1 and segment == "Workspace" then
			current = workspace
		else
			current = current:FindFirstChild(segment)
		end

		if current == nil then
			return nil
		end
	end

	return current
end

local function ensureFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if folder and not folder:IsA("Folder") then
		folder:Destroy()
		folder = nil
	end

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end

	return folder
end

local function ensureRemoteEvent(parent, name)
	local remoteEvent = parent:FindFirstChild(name)
	if remoteEvent and not remoteEvent:IsA("RemoteEvent") then
		remoteEvent:Destroy()
		remoteEvent = nil
	end

	if not remoteEvent then
		remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = name
		remoteEvent.Parent = parent
	end

	return remoteEvent
end

local function getRemotesFolder()
	return ensureFolder(ZeroToHeroShared, REMOTES_FOLDER_NAME)
end

local function getRewardEvent()
	return ensureRemoteEvent(getRemotesFolder(), REWARD_EVENT_NAME)
end

local function getChallengeEvent()
	return ensureRemoteEvent(getRemotesFolder(), CHALLENGE_EVENT_NAME)
end

local function getActionEvent()
	return ensureRemoteEvent(getRemotesFolder(), ACTION_EVENT_NAME)
end

local function getLegacyStatChangedEvent()
	local legacyFolder = ReplicatedStorage:FindFirstChild(LEGACY_REMOTES_FOLDER_NAME)
	if legacyFolder == nil or not legacyFolder:IsA("Folder") then
		return nil
	end

	local statChanged = legacyFolder:FindFirstChild(LEGACY_STAT_CHANGED_EVENT_NAME)
	if statChanged and statChanged:IsA("RemoteEvent") then
		return statChanged
	end

	return nil
end

local function getServerTime()
	local ok, serverTime = pcall(function()
		return Workspace:GetServerTimeNow()
	end)

	if ok and typeof(serverTime) == "number" then
		return serverTime
	end

	return os.clock()
end

local function cleanPositiveInteger(value, defaultValue)
	local numericValue = tonumber(value)
	if numericValue == nil then
		return defaultValue
	end

	return math.max(1, math.floor(numericValue))
end

local function cleanPositiveNumber(value, defaultValue)
	local numericValue = tonumber(value)
	if numericValue == nil or numericValue <= 0 then
		return defaultValue
	end

	return numericValue
end

local function cloneArray(values)
	local copy = {}

	for index, value in ipairs(values) do
		if typeof(value) == "table" then
			copy[index] = table.clone(value)
		else
			copy[index] = value
		end
	end

	return copy
end

local function getCharacterRoot(player)
	local character = player.Character
	if character == nil then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function getAnchorPosition(anchor)
	if anchor == nil then
		return nil
	end

	if anchor:IsA("BasePart") then
		return anchor.Position
	end

	if anchor:IsA("Model") then
		local pivot = anchor:GetPivot()
		return pivot.Position
	end

	return nil
end

local function isPlayerInRange(player, station)
	local root = getCharacterRoot(player)
	if root == nil then
		return false, "NoCharacterRoot"
	end

	local anchor = resolvePath(station.AnchorPath)
	local anchorPosition = getAnchorPosition(anchor)
	if anchorPosition == nil then
		return false, "MissingAnchor"
	end

	local range = tonumber(station.InteractionRange) or 0
	local distance = (root.Position - anchorPosition).Magnitude

	if distance > range then
		return false, "OutOfRange"
	end

	return true, nil
end

local function getCooldownBucket(player)
	local bucket = cooldownsByPlayer[player]
	if bucket == nil then
		bucket = {}
		cooldownsByPlayer[player] = bucket
	end

	return bucket
end

local function isOnCooldown(player, station)
	local bucket = getCooldownBucket(player)
	local now = os.clock()
	local nextAllowedAt = bucket[station.Id] or 0

	if now < nextAllowedAt then
		return true, nextAllowedAt - now
	end

	return false, 0
end

local function setCooldown(player, station)
	local bucket = getCooldownBucket(player)
	bucket[station.Id] = os.clock() + (tonumber(station.CooldownSeconds) or 0)
end

local function getMinigameConfig(station)
	if typeof(station.Minigame) ~= "table" or station.Minigame.Enabled ~= true then
		return nil
	end

	return station.Minigame
end

local function stationUsesMinigame(station)
	local minigameResult = station.MinigameResult
	return typeof(minigameResult) == "table" and minigameResult.Enabled == true and getMinigameConfig(station) ~= nil
end

local function normalizeTargetZone(zone)
	local center = math.clamp(tonumber(zone and zone.Center) or 0.5, 0.08, 0.92)
	local width = math.clamp(tonumber(zone and zone.Width) or 0.24, 0.05, 0.9)
	local perfectWidth = math.clamp(tonumber(zone and zone.PerfectWidth) or 0.08, 0.01, width)

	return {
		Center = center,
		Width = width,
		PerfectWidth = perfectWidth,
	}
end

local function getChallengeSettings(station)
	local minigame = getMinigameConfig(station) or {}
	local requiredSuccesses = cleanPositiveInteger(minigame.RequiredSuccesses, DEFAULT_REQUIRED_SUCCESSES)
	local maxAttempts = cleanPositiveInteger(minigame.MaxAttempts, DEFAULT_MAX_ATTEMPTS)
	maxAttempts = math.max(maxAttempts, requiredSuccesses)

	return {
		RequiredSuccesses = requiredSuccesses,
		MaxAttempts = maxAttempts,
		MarkerPeriodSeconds = cleanPositiveNumber(minigame.MarkerPeriodSeconds, DEFAULT_MARKER_PERIOD_SECONDS),
		ChallengeTimeoutSeconds = cleanPositiveNumber(minigame.ChallengeTimeoutSeconds, DEFAULT_CHALLENGE_TIMEOUT_SECONDS),
		ServerInputTolerance = math.clamp(tonumber(minigame.ServerInputTolerance) or DEFAULT_INPUT_TOLERANCE, 0, 0.2),
	}
end

local function getTargetZones(station, requiredSuccesses)
	local minigame = getMinigameConfig(station) or {}
	local configuredZones = minigame.TargetZones
	local zones = {}

	for index = 1, requiredSuccesses do
		local configuredZone = nil
		if typeof(configuredZones) == "table" then
			configuredZone = configuredZones[index] or configuredZones[#configuredZones]
		end

		zones[index] = normalizeTargetZone(configuredZone)
	end

	return zones
end

local function getMarkerPosition(startedAt, markerPeriodSeconds, now)
	local elapsed = math.max(0, now - startedAt)
	local phase = (elapsed / markerPeriodSeconds) % 1

	if phase <= 0.5 then
		return phase * 2
	end

	return (1 - phase) * 2
end

local function getCurrentTargetZone(challenge)
	return challenge.TargetZones[math.min(challenge.SuccessCount + 1, #challenge.TargetZones)]
end

local function evaluateChallengeHit(challenge, now)
	local markerPosition = getMarkerPosition(challenge.StartedAt, challenge.MarkerPeriodSeconds, now)
	local targetZone = getCurrentTargetZone(challenge)
	local distance = math.abs(markerPosition - targetZone.Center)
	local hitHalfWidth = (targetZone.Width / 2) + challenge.ServerInputTolerance
	local perfectHalfWidth = targetZone.PerfectWidth / 2

	if distance > hitHalfWidth then
		return {
			Success = false,
			Accuracy = 0,
			Rating = "Miss",
			MarkerPosition = markerPosition,
			TargetCenter = targetZone.Center,
			TargetWidth = targetZone.Width,
		}
	end

	local accuracy = math.clamp(1 - (distance / math.max(hitHalfWidth, 0.001)), 0, 1)
	local rating = "Hit"
	if distance <= perfectHalfWidth then
		accuracy = math.max(accuracy, 0.95)
		rating = "Perfect"
	elseif accuracy >= 0.65 then
		rating = "Good"
	end

	return {
		Success = true,
		Accuracy = accuracy,
		Rating = rating,
		MarkerPosition = markerPosition,
		TargetCenter = targetZone.Center,
		TargetWidth = targetZone.Width,
	}
end

local function calculateAverageAccuracy(challenge)
	if #challenge.AccuracySamples == 0 then
		return 0
	end

	local totalAccuracy = 0
	for _, accuracy in ipairs(challenge.AccuracySamples) do
		totalAccuracy += accuracy
	end

	return math.clamp(totalAccuracy / #challenge.AccuracySamples, 0, 1)
end

local function calculateChallengeMultiplier(station, averageAccuracy)
	local minigameResult = station.MinigameResult or {}
	local minimumMultiplier = tonumber(minigameResult.MinimumMultiplier) or 1
	local maximumMultiplier = tonumber(minigameResult.MaximumMultiplier) or 1
	local cleanAccuracy = math.clamp(averageAccuracy, 0, 1)

	return math.clamp(minimumMultiplier + ((maximumMultiplier - minimumMultiplier) * cleanAccuracy), minimumMultiplier, maximumMultiplier)
end

local function getMinigameMultiplier(station, minigameResult)
	local minigameConfig = station.MinigameResult
	if typeof(minigameConfig) ~= "table" or minigameConfig.Enabled ~= true then
		return 1
	end

	if typeof(minigameResult) ~= "table" then
		return 1
	end

	local rawMultiplier = tonumber(minigameResult.Multiplier)
	if rawMultiplier == nil then
		return 1
	end

	local minMultiplier = tonumber(minigameConfig.MinimumMultiplier) or 1
	local maxMultiplier = tonumber(minigameConfig.MaximumMultiplier) or 1

	return math.clamp(rawMultiplier, minMultiplier, maxMultiplier)
end

local function buildClientRewardPayload(station, result)
	return {
		StationId = station.Id,
		StationName = station.DisplayName,
		Stat = result.Stat,
		XPGained = result.XPGained,
		BaseXP = result.BaseXP,
		OldLevel = result.OldLevel,
		NewLevel = result.NewLevel,
		LevelUps = result.LevelUps,
		NewXP = result.NewXP,
		NewEffectiveValue = result.NewEffectiveValue,
		TrainingRank = result.TrainingRank,
		DurationSeconds = result.DurationSeconds,
		DiminishingMultiplier = result.DiminishingMultiplier,
		MinigameAccuracy = result.MinigameAccuracy,
		MinigameMultiplier = result.MinigameMultiplier,
	}
end

local function fireRewardCallbacks(player, station, result, payload)
	for _, callback in ipairs(rewardCallbacks) do
		local ok, err = pcall(callback, player, station, result, payload)
		if not ok then
			warn(("[TrainingStationService] Reward callback failed for %s: %s"):format(station.Id, tostring(err)))
		end
	end
end

local function fireClientReward(player, payload)
	getRewardEvent():FireClient(player, payload)

	local legacyStatChanged = getLegacyStatChangedEvent()
	if legacyStatChanged then
		legacyStatChanged:FireClient(player, {
			kind = "reward",
			stat = payload.Stat,
			amount = payload.XPGained,
			value = payload.NewEffectiveValue,
			xp = payload.XPGained,
			oldLevel = payload.OldLevel,
			newLevel = payload.NewLevel,
			levelUps = payload.LevelUps,
			source = payload.StationName,
		})
	end
end

local function fireChallengeClient(player, payload)
	getChallengeEvent():FireClient(player, payload)
end

local function buildChallengeStartedPayload(challenge)
	return {
		Type = "Started",
		ChallengeId = challenge.ChallengeId,
		StationId = challenge.StationId,
		StationName = challenge.StationName,
		Stat = challenge.StatId,
		ServerStartTime = challenge.StartedAt,
		MarkerPeriodSeconds = challenge.MarkerPeriodSeconds,
		RequiredSuccesses = challenge.RequiredSuccesses,
		MaxAttempts = challenge.MaxAttempts,
		ChallengeTimeoutSeconds = challenge.ChallengeTimeoutSeconds,
		InteractionRange = challenge.InteractionRange,
		AnchorPath = cloneArray(challenge.AnchorPath),
		TargetZones = cloneArray(challenge.TargetZones),
	}
end

local function clearChallenge(player, challenge)
	if activeChallengesByPlayer[player] == challenge then
		activeChallengesByPlayer[player] = nil
	end
end

local function failChallenge(player, challenge, errorName)
	clearChallenge(player, challenge)
	fireChallengeClient(player, {
		Type = "Failed",
		ChallengeId = challenge.ChallengeId,
		StationId = challenge.StationId,
		Error = errorName,
	})
end

local function completeChallenge(player, challenge)
	local station = TrainingStationConfig.GetStation(challenge.StationId)
	if station == nil then
		failChallenge(player, challenge, "MissingStation")
		return {
			Success = false,
			Error = "MissingStation",
		}
	end

	local averageAccuracy = calculateAverageAccuracy(challenge)
	local multiplier = calculateChallengeMultiplier(station, averageAccuracy)
	clearChallenge(player, challenge)

	local result = TrainingStationService.TryActivateStation(player, challenge.StationId, {
		ServerValidatedChallenge = true,
		ChallengeId = challenge.ChallengeId,
		AverageAccuracy = averageAccuracy,
		Multiplier = multiplier,
	})

	if not result.Success then
		fireChallengeClient(player, {
			Type = "Failed",
			ChallengeId = challenge.ChallengeId,
			StationId = challenge.StationId,
			Error = result.Error,
		})
		return result
	end

	fireChallengeClient(player, {
		Type = "Completed",
		ChallengeId = challenge.ChallengeId,
		StationId = challenge.StationId,
		AverageAccuracy = averageAccuracy,
		Multiplier = multiplier,
		XPGained = result.XPGained,
		NewLevel = result.NewLevel,
		NewXP = result.NewXP,
	})

	return result
end

function TrainingStationService.RegisterRewardCallback(callback)
	if typeof(callback) ~= "function" then
		return false, "Callback must be a function"
	end

	table.insert(rewardCallbacks, callback)
	return true
end

function TrainingStationService.GetRewardEvent()
	return getRewardEvent()
end

function TrainingStationService.GetChallengeEvent()
	return getChallengeEvent()
end

function TrainingStationService.GetActionEvent()
	return getActionEvent()
end

function TrainingStationService.GetStation(stationId)
	return TrainingStationConfig.GetStation(stationId)
end

function TrainingStationService.GetActiveChallengeSnapshot(player)
	local challenge = activeChallengesByPlayer[player]
	if challenge == nil then
		return nil
	end

	return {
		ChallengeId = challenge.ChallengeId,
		StationId = challenge.StationId,
		SuccessCount = challenge.SuccessCount,
		Attempts = challenge.Attempts,
		RequiredSuccesses = challenge.RequiredSuccesses,
		MaxAttempts = challenge.MaxAttempts,
		ServerStartTime = challenge.StartedAt,
		MarkerPeriodSeconds = challenge.MarkerPeriodSeconds,
		TargetZones = cloneArray(challenge.TargetZones),
		ExpiresAt = challenge.ExpiresAt,
	}
end

function TrainingStationService.TryActivateStation(player, stationId, minigameResult)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return {
			Success = false,
			Error = "InvalidPlayer",
		}
	end

	local station = TrainingStationConfig.GetStation(stationId)
	if station == nil then
		return {
			Success = false,
			Error = "InvalidStation",
		}
	end

	local stationOk, stationError = TrainingStationConfig.ValidateStation(station)
	if not stationOk then
		return {
			Success = false,
			Error = stationError,
		}
	end

	local inRange, rangeError = isPlayerInRange(player, station)
	if not inRange then
		return {
			Success = false,
			Error = rangeError,
		}
	end

	local onCooldown, remaining = isOnCooldown(player, station)
	if onCooldown then
		return {
			Success = false,
			Error = "Cooldown",
			CooldownRemaining = remaining,
		}
	end

	if stationUsesMinigame(station) then
		if typeof(minigameResult) ~= "table" or minigameResult.ServerValidatedChallenge ~= true then
			return {
				Success = false,
				Error = "MinigameRequired",
			}
		end
	end

	setCooldown(player, station)

	local minigameMultiplier = getMinigameMultiplier(station, minigameResult)
	local baseXP = math.max(1, math.floor((tonumber(station.BaseXP) or 0) * minigameMultiplier + 0.5))

	local result = TrainingService.AwardTrainingXP(player, station.StatId, baseXP, {
		Source = station.DisplayName,
		DurationSeconds = station.DurationSeconds,
	})

	if not result.Success then
		return result
	end

	if typeof(minigameResult) == "table" then
		result.ChallengeId = minigameResult.ChallengeId
		result.MinigameAccuracy = minigameResult.AverageAccuracy
		result.MinigameMultiplier = minigameMultiplier
	end

	local payload = buildClientRewardPayload(station, result)
	fireRewardCallbacks(player, station, result, payload)
	fireClientReward(player, payload)

	return result
end

function TrainingStationService.StartStationMinigame(player, stationId)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return {
			Success = false,
			Error = "InvalidPlayer",
		}
	end

	local station = TrainingStationConfig.GetStation(stationId)
	if station == nil then
		return {
			Success = false,
			Error = "InvalidStation",
		}
	end

	if not stationUsesMinigame(station) then
		return TrainingStationService.TryActivateStation(player, stationId)
	end

	local stationOk, stationError = TrainingStationConfig.ValidateStation(station)
	if not stationOk then
		return {
			Success = false,
			Error = stationError,
		}
	end

	local inRange, rangeError = isPlayerInRange(player, station)
	if not inRange then
		return {
			Success = false,
			Error = rangeError,
		}
	end

	local onCooldown, remaining = isOnCooldown(player, station)
	if onCooldown then
		fireChallengeClient(player, {
			Type = "Rejected",
			StationId = station.Id,
			Error = "Cooldown",
			CooldownRemaining = remaining,
		})
		return {
			Success = false,
			Error = "Cooldown",
			CooldownRemaining = remaining,
		}
	end

	local now = getServerTime()
	local existingChallenge = activeChallengesByPlayer[player]
	if existingChallenge and now <= existingChallenge.ExpiresAt then
		fireChallengeClient(player, buildChallengeStartedPayload(existingChallenge))
		return {
			Success = false,
			Error = "ActiveChallenge",
			ChallengeId = existingChallenge.ChallengeId,
		}
	end

	local settings = getChallengeSettings(station)
	local targetZones = getTargetZones(station, settings.RequiredSuccesses)
	local challenge = {
		ChallengeId = HttpService:GenerateGUID(false),
		Player = player,
		StationId = station.Id,
		StationName = station.DisplayName,
		StatId = station.StatId,
		AnchorPath = cloneArray(station.AnchorPath),
		InteractionRange = tonumber(station.InteractionRange) or 0,
		StartedAt = now,
		ExpiresAt = now + settings.ChallengeTimeoutSeconds,
		RequiredSuccesses = settings.RequiredSuccesses,
		MaxAttempts = settings.MaxAttempts,
		MarkerPeriodSeconds = settings.MarkerPeriodSeconds,
		ChallengeTimeoutSeconds = settings.ChallengeTimeoutSeconds,
		ServerInputTolerance = settings.ServerInputTolerance,
		TargetZones = targetZones,
		Attempts = 0,
		SuccessCount = 0,
		AccuracySamples = {},
	}

	activeChallengesByPlayer[player] = challenge
	fireChallengeClient(player, buildChallengeStartedPayload(challenge))

	task.delay(settings.ChallengeTimeoutSeconds + 0.5, function()
		if activeChallengesByPlayer[player] == challenge then
			failChallenge(player, challenge, "Timeout")
		end
	end)

	return {
		Success = true,
		ChallengeId = challenge.ChallengeId,
		RequiredSuccesses = challenge.RequiredSuccesses,
		MaxAttempts = challenge.MaxAttempts,
	}
end

function TrainingStationService.SubmitStationMinigame(player, challengeId)
	local challenge = activeChallengesByPlayer[player]
	if challenge == nil then
		return {
			Success = false,
			Error = "NoActiveChallenge",
		}
	end

	if challenge.ChallengeId ~= challengeId then
		return {
			Success = false,
			Error = "ChallengeMismatch",
		}
	end

	local now = getServerTime()
	if now > challenge.ExpiresAt then
		failChallenge(player, challenge, "Timeout")
		return {
			Success = false,
			Error = "Timeout",
		}
	end

	local station = TrainingStationConfig.GetStation(challenge.StationId)
	if station == nil then
		failChallenge(player, challenge, "MissingStation")
		return {
			Success = false,
			Error = "MissingStation",
		}
	end

	local inRange, rangeError = isPlayerInRange(player, station)
	if not inRange then
		failChallenge(player, challenge, rangeError)
		return {
			Success = false,
			Error = rangeError,
		}
	end

	if challenge.Attempts >= challenge.MaxAttempts then
		failChallenge(player, challenge, "TooManyAttempts")
		return {
			Success = false,
			Error = "TooManyAttempts",
		}
	end

	challenge.Attempts += 1
	local evaluation = evaluateChallengeHit(challenge, now)

	if evaluation.Success then
		challenge.SuccessCount += 1
		table.insert(challenge.AccuracySamples, evaluation.Accuracy)
	end

	fireChallengeClient(player, {
		Type = "RepResult",
		ChallengeId = challenge.ChallengeId,
		StationId = challenge.StationId,
		Success = evaluation.Success,
		Accuracy = evaluation.Accuracy,
		Rating = evaluation.Rating,
		MarkerPosition = evaluation.MarkerPosition,
		TargetCenter = evaluation.TargetCenter,
		TargetWidth = evaluation.TargetWidth,
		SuccessCount = challenge.SuccessCount,
		Attempts = challenge.Attempts,
		RequiredSuccesses = challenge.RequiredSuccesses,
		MaxAttempts = challenge.MaxAttempts,
	})

	if challenge.SuccessCount >= challenge.RequiredSuccesses then
		return completeChallenge(player, challenge)
	end

	if challenge.Attempts >= challenge.MaxAttempts then
		failChallenge(player, challenge, "TooManyAttempts")
		return {
			Success = false,
			Error = "TooManyAttempts",
		}
	end

	return {
		Success = true,
		Hit = evaluation.Success,
		Rating = evaluation.Rating,
		SuccessCount = challenge.SuccessCount,
		Attempts = challenge.Attempts,
	}
end

function TrainingStationService.CancelStationMinigame(player, challengeId, reason)
	local challenge = activeChallengesByPlayer[player]
	if challenge == nil then
		return {
			Success = false,
			Error = "NoActiveChallenge",
		}
	end

	if challengeId ~= nil and challenge.ChallengeId ~= challengeId then
		return {
			Success = false,
			Error = "ChallengeMismatch",
		}
	end

	clearChallenge(player, challenge)
	fireChallengeClient(player, {
		Type = "Cancelled",
		ChallengeId = challenge.ChallengeId,
		StationId = challenge.StationId,
		Reason = tostring(reason or "Cancelled"),
	})

	return {
		Success = true,
	}
end

local function handleClientAction(player, payload)
	if typeof(payload) ~= "table" then
		return
	end

	local actionType = payload.Type
	local challengeId = payload.ChallengeId
	if typeof(challengeId) ~= "string" then
		return
	end

	if actionType == "Submit" then
		TrainingStationService.SubmitStationMinigame(player, challengeId)
	elseif actionType == "Cancel" then
		TrainingStationService.CancelStationMinigame(player, challengeId, "ClientCancel")
	end
end

local function configurePrompt(prompt, station)
	prompt.ActionText = station.PromptActionText or "Train"
	prompt.ObjectText = station.PromptObjectText or station.DisplayName or station.Id
	prompt.HoldDuration = tonumber(station.PromptHoldDuration) or 0
	prompt.MaxActivationDistance = tonumber(station.InteractionRange) or prompt.MaxActivationDistance
	prompt.RequiresLineOfSight = false
end

local function bindStation(station)
	if connectionsByStationId[station.Id] then
		return true
	end

	local prompt = resolvePath(station.PromptPath)
	if prompt == nil or not prompt:IsA("ProximityPrompt") then
		warn(("[TrainingStationService] Missing ProximityPrompt for station %s"):format(station.Id))
		return false
	end

	configurePrompt(prompt, station)
	connectionsByStationId[station.Id] = prompt.Triggered:Connect(function(player)
		local result = nil
		if stationUsesMinigame(station) then
			result = TrainingStationService.StartStationMinigame(player, station.Id)
		else
			result = TrainingStationService.TryActivateStation(player, station.Id)
		end

		if not result.Success and result.Error ~= "Cooldown" and result.Error ~= "ActiveChallenge" then
			warn(("[TrainingStationService] Station %s activation failed for %s: %s"):format(station.Id, player.Name, tostring(result.Error)))
		end
	end)

	return true
end

function TrainingStationService.Start()
	if hasStarted then
		return true
	end

	hasStarted = true
	getRewardEvent()
	getChallengeEvent()

	if actionConnection == nil then
		actionConnection = getActionEvent().OnServerEvent:Connect(handleClientAction)
	end

	for _, station in ipairs(TrainingStationConfig.GetStations()) do
		local valid, err = TrainingStationConfig.ValidateStation(station)
		if valid then
			bindStation(station)
		else
			warn(("[TrainingStationService] Invalid station config %s: %s"):format(tostring(station.Id), tostring(err)))
		end
	end

	Players.PlayerRemoving:Connect(function(player)
		cooldownsByPlayer[player] = nil
		activeChallengesByPlayer[player] = nil
	end)

	return true
end

return table.freeze(TrainingStationService)
