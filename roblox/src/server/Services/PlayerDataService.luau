local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZeroToHeroShared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local HeroProgressionConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("HeroProgressionConfig"))
local StatConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("StatConfig"))
local PlayerProfileModel = require(ZeroToHeroShared:WaitForChild("Types"):WaitForChild("PlayerProfileModel"))

local PlayerDataService = {}

local STORE_NAME = "ZeroToHeroPlayerProfiles_v1"
local AUTO_SAVE_INTERVAL_SECONDS = 60
local PROFILE_FOLDER_NAME = "Profile"
local STATS_FOLDER_NAME = "Stats"
local TRAINING_STATS_FOLDER_NAME = "TrainingStats"
local LEADERSTATS_FOLDER_NAME = "leaderstats"

local sessionsByPlayer = {}
local connectionsByPlayer = {}
local profileStore = nil
local hasStarted = false
local bindToCloseBound = false
local storeUnavailableWarningShown = false
local autosaveRunning = false

local function warnOnce(message)
	warn("[PlayerDataService] " .. message)
end

local function profileKey(player)
	return "player_" .. tostring(player.UserId)
end

local function getProfileStore()
	if profileStore ~= nil then
		return profileStore
	end

	local ok, storeOrErr = pcall(function()
		return DataStoreService:GetDataStore(STORE_NAME)
	end)

	if not ok then
		if not storeUnavailableWarningShown then
			warnOnce(("DataStore unavailable, using session-only profiles: %s"):format(tostring(storeOrErr)))
			storeUnavailableWarningShown = true
		end
		return nil
	end

	profileStore = storeOrErr
	return profileStore
end

local function createEnvelope(profile)
	return {
		Schema = "ZeroToHeroPlayerProfile",
		Version = profile.Version,
		Profile = PlayerProfileModel.DeepCopy(profile),
		UpdatedAt = os.time(),
	}
end

local function profileFromLegacyStats(rawData)
	local rawStats = rawData and rawData.stats
	if typeof(rawStats) ~= "table" then
		return nil
	end

	local profile = PlayerProfileModel.CreateDefaultProfile()

	for _, statId in ipairs(StatConfig.GetStatIds()) do
		local value = math.max(0, math.floor(tonumber(rawStats[statId]) or 0))
		profile.TrainingStats[statId].Level = value
		profile.TrainingStats[statId].EffectiveValue = value
	end

	return PlayerProfileModel.RepairProfile(profile)
end

local function repairLoadedProfile(rawData)
	if rawData == nil then
		return {
			Profile = PlayerProfileModel.CreateDefaultProfile(),
			WasRepaired = false,
			Issues = {},
			WasCreated = true,
		}
	end

	local legacyResult = profileFromLegacyStats(rawData)
	if legacyResult then
		legacyResult.WasCreated = false
		legacyResult.WasLegacy = true
		return legacyResult
	end

	local candidate = rawData
	if typeof(rawData) == "table" and typeof(rawData.Profile) == "table" then
		candidate = rawData.Profile
	end

	local migrated = PlayerProfileModel.MigrateProfile(candidate)
	migrated.WasCreated = false
	return migrated
end

local function ensureIntValue(parent, name, value)
	local intValue = parent:FindFirstChild(name)
	if intValue and not intValue:IsA("IntValue") then
		intValue:Destroy()
		intValue = nil
	end

	if not intValue then
		intValue = Instance.new("IntValue")
		intValue.Name = name
		intValue.Parent = parent
	end

	intValue.Value = math.floor(tonumber(value) or 0)
	return intValue
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

local function calculateTrainingRank(profile)
	local statCount = 0
	local total = 0
	local lowest = math.huge

	for _, statId in ipairs(StatConfig.GetStatIds()) do
		local stat = profile.TrainingStats[statId]
		local value = 0
		if stat then
			value = math.max(0, math.floor(tonumber(stat.EffectiveValue) or 0))
		end

		statCount += 1
		total += value
		lowest = math.min(lowest, value)
	end

	if statCount == 0 then
		return 0
	end

	local average = total / statCount
	return math.floor((average + lowest) / 2)
end

local function syncReplicatedValues(player, profile)
	local profileFolder = ensureFolder(player, PROFILE_FOLDER_NAME)
	ensureIntValue(profileFolder, "Version", profile.Version)
	ensureIntValue(profileFolder, "HeroLevel", profile.HeroLevel)
	ensureIntValue(profileFolder, "HeroXP", profile.HeroXP)
	ensureIntValue(profileFolder, "HeroXPRequired", HeroProgressionConfig.GetProgress(profile.HeroLevel, profile.HeroXP).XPRequired)
	ensureIntValue(profileFolder, "Gold", profile.Gold)
	ensureIntValue(profileFolder, "TrainingRank", calculateTrainingRank(profile))

	local statsFolder = ensureFolder(player, STATS_FOLDER_NAME)
	local trainingStatsFolder = ensureFolder(player, TRAINING_STATS_FOLDER_NAME)
	for _, statId in ipairs(StatConfig.GetStatIds()) do
		local statDefinition = StatConfig.GetStat(statId)
		local stat = profile.TrainingStats[statId]
		local effectiveValue = stat and stat.EffectiveValue or 0
		local level = stat and stat.Level or 0
		local xp = stat and stat.XP or 0
		local xpRequired = 0
		if statDefinition and level < statDefinition.MaximumTestLevel then
			xpRequired = StatConfig.GetRequiredXPForLevel(statId, level + 1) or 0
		end

		ensureIntValue(statsFolder, statId, effectiveValue)

		local statFolder = ensureFolder(trainingStatsFolder, statId)
		ensureIntValue(statFolder, "Level", level)
		ensureIntValue(statFolder, "XP", xp)
		ensureIntValue(statFolder, "XPRequired", xpRequired)
		ensureIntValue(statFolder, "EffectiveValue", effectiveValue)
	end

	local leaderstats = ensureFolder(player, LEADERSTATS_FOLDER_NAME)
	ensureIntValue(leaderstats, "Power", profile.TrainingStats.Power and profile.TrainingStats.Power.EffectiveValue or 0)
	ensureIntValue(leaderstats, "TrainingRank", calculateTrainingRank(profile))
	ensureIntValue(leaderstats, "HeroLevel", profile.HeroLevel)
end

local function disconnectPlayerConnections(player)
	local connections = connectionsByPlayer[player]
	if not connections then
		return
	end

	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	connectionsByPlayer[player] = nil
end

local function attachProfileValueGuards(player)
	disconnectPlayerConnections(player)
	connectionsByPlayer[player] = {}

	local function watchFolder(folder)
		table.insert(connectionsByPlayer[player], folder.ChildAdded:Connect(function(child)
			if child:IsA("IntValue") then
				local session = sessionsByPlayer[player]
				if session then
					task.defer(function()
						if sessionsByPlayer[player] == session then
							syncReplicatedValues(player, session.Profile)
						end
					end)
				end
			end
		end))
	end

	local profileFolder = player:FindFirstChild(PROFILE_FOLDER_NAME)
	local statsFolder = player:FindFirstChild(STATS_FOLDER_NAME)
	local trainingStatsFolder = player:FindFirstChild(TRAINING_STATS_FOLDER_NAME)

	if profileFolder then
		watchFolder(profileFolder)
	end

	if statsFolder then
		watchFolder(statsFolder)
	end

	if trainingStatsFolder then
		watchFolder(trainingStatsFolder)
		for _, child in ipairs(trainingStatsFolder:GetChildren()) do
			if child:IsA("Folder") then
				watchFolder(child)
			end
		end
	end
end

function PlayerDataService.LoadPlayer(player)
	if sessionsByPlayer[player] then
		return sessionsByPlayer[player]
	end

	local store = getProfileStore()
	local rawData = nil
	local saveEnabled = true
	local loadStatus = "CreatedDefault"
	local loadError = nil

	if store then
		local ok, resultOrErr = pcall(function()
			return store:GetAsync(profileKey(player))
		end)

		if ok then
			rawData = resultOrErr
			loadStatus = rawData == nil and "CreatedDefault" or "Loaded"
		else
			saveEnabled = false
			loadStatus = "LoadFailedSessionOnly"
			loadError = tostring(resultOrErr)
			warnOnce(("Load failed for %s; using unsaved session profile to avoid overwriting stored data: %s"):format(player.Name, loadError))
		end
	else
		saveEnabled = false
		loadStatus = "SessionOnly"
	end

	local repairResult = repairLoadedProfile(rawData)
	if repairResult.WasRepaired or repairResult.WasLegacy then
		local issueCount = repairResult.Issues and #repairResult.Issues or 0
		warnOnce(("Profile for %s required repair or migration (%d issue%s)."):format(player.Name, issueCount, issueCount == 1 and "" or "s"))
	end

	local session = {
		Player = player,
		Profile = repairResult.Profile,
		Dirty = repairResult.WasCreated or repairResult.WasRepaired or repairResult.WasLegacy or false,
		LoadedAt = os.time(),
		LoadStatus = loadStatus,
		LoadError = loadError,
		SaveEnabled = saveEnabled,
	}

	sessionsByPlayer[player] = session
	syncReplicatedValues(player, session.Profile)
	attachProfileValueGuards(player)

	return session
end

function PlayerDataService.GetSession(player)
	return sessionsByPlayer[player]
end

function PlayerDataService.GetProfile(player)
	local session = sessionsByPlayer[player]
	if not session then
		return nil
	end

	return PlayerProfileModel.DeepCopy(session.Profile)
end

function PlayerDataService.GetProfileSnapshot(player)
	return PlayerDataService.GetProfile(player)
end

local function readPositiveIntegerAmount(amount)
	local cleanAmount = math.floor(tonumber(amount) or 0)
	if cleanAmount <= 0 then
		return nil
	end

	return cleanAmount
end

function PlayerDataService.MutateProfile(player, reason, mutator)
	if typeof(mutator) ~= "function" then
		return false, "Mutator must be a function"
	end

	local session = sessionsByPlayer[player] or PlayerDataService.LoadPlayer(player)
	if not session then
		return false, "No session"
	end

	local before = PlayerProfileModel.DeepCopy(session.Profile)
	local ok, resultOrErr = pcall(mutator, session.Profile)
	if not ok then
		session.Profile = before
		warnOnce(("Mutation '%s' failed for %s: %s"):format(tostring(reason), player.Name, tostring(resultOrErr)))
		return false, resultOrErr
	end

	local repairResult = PlayerProfileModel.RepairProfile(session.Profile)
	session.Profile = repairResult.Profile
	session.Dirty = true
	syncReplicatedValues(player, session.Profile)

	if repairResult.WasRepaired then
		warnOnce(("Mutation '%s' for %s produced invalid fields; repaired profile before caching."):format(tostring(reason), player.Name))
	end

	return true, resultOrErr
end

function PlayerDataService.AddHeroXP(player, amount, reason)
	local cleanAmount = readPositiveIntegerAmount(amount)
	if cleanAmount == nil then
		return {
			Success = false,
			Error = "InvalidAmount",
		}
	end

	local oldHeroLevel = nil
	local oldHeroXP = nil
	local newHeroLevel = nil
	local newHeroXP = nil
	local levelUps = 0
	local success, err = PlayerDataService.MutateProfile(player, reason or "AddHeroXP", function(profile)
		oldHeroLevel = math.clamp(math.floor(tonumber(profile.HeroLevel) or 1), 1, HeroProgressionConfig.GetMaxHeroLevel())
		oldHeroXP = math.max(0, math.floor(tonumber(profile.HeroXP) or 0))

		local level = oldHeroLevel
		local xp = oldHeroXP + cleanAmount
		while level < HeroProgressionConfig.GetMaxHeroLevel() do
			local requiredXP = HeroProgressionConfig.GetRequiredXPForLevel(level + 1)
			if requiredXP == nil or xp < requiredXP then
				break
			end

			xp -= requiredXP
			level += 1
			levelUps += 1
		end

		profile.HeroLevel = level
		profile.HeroXP = xp
		newHeroLevel = level
		newHeroXP = xp
	end)

	if not success then
		return {
			Success = false,
			Error = tostring(err),
		}
	end

	return {
		Success = true,
		Amount = cleanAmount,
		OldHeroLevel = oldHeroLevel,
		NewHeroLevel = newHeroLevel,
		OldHeroXP = oldHeroXP,
		NewHeroXP = newHeroXP,
		LevelUps = levelUps,
		NextHeroXPRequired = HeroProgressionConfig.GetRequiredXPForLevel((newHeroLevel or 1) + 1) or 0,
		AtMaxLevel = (newHeroLevel or 1) >= HeroProgressionConfig.GetMaxHeroLevel(),
	}
end

function PlayerDataService.AddGold(player, amount, reason)
	local cleanAmount = readPositiveIntegerAmount(amount)
	if cleanAmount == nil then
		return {
			Success = false,
			Error = "InvalidAmount",
		}
	end

	local oldGold = nil
	local newGold = nil
	local success, err = PlayerDataService.MutateProfile(player, reason or "AddGold", function(profile)
		oldGold = math.max(0, math.floor(tonumber(profile.Gold) or 0))
		profile.Gold += cleanAmount
		newGold = profile.Gold
	end)

	if not success then
		return {
			Success = false,
			Error = tostring(err),
		}
	end

	return {
		Success = true,
		Amount = cleanAmount,
		OldGold = oldGold,
		NewGold = newGold,
	}
end

function PlayerDataService.AddMaterial(player, materialId, amount, reason)
	if typeof(materialId) ~= "string" or materialId == "" then
		return {
			Success = false,
			Error = "InvalidMaterial",
		}
	end

	local cleanAmount = readPositiveIntegerAmount(amount)
	if cleanAmount == nil then
		return {
			Success = false,
			Error = "InvalidAmount",
		}
	end

	local oldAmount = nil
	local newAmount = nil
	local success, err = PlayerDataService.MutateProfile(player, reason or "AddMaterial", function(profile)
		if typeof(profile.Materials) ~= "table" then
			profile.Materials = {}
		end

		oldAmount = math.max(0, math.floor(tonumber(profile.Materials[materialId]) or 0))
		profile.Materials[materialId] = oldAmount + cleanAmount
		newAmount = profile.Materials[materialId]
	end)

	if not success then
		return {
			Success = false,
			Error = tostring(err),
		}
	end

	return {
		Success = true,
		MaterialId = materialId,
		Amount = cleanAmount,
		OldAmount = oldAmount,
		NewAmount = newAmount,
	}
end

function PlayerDataService.GetHeroProgressSnapshot(player)
	local profile = PlayerDataService.GetProfileSnapshot(player)
	if profile == nil then
		return nil
	end

	return HeroProgressionConfig.GetProgress(profile.HeroLevel, profile.HeroXP)
end

function PlayerDataService.AddTrainingStatValue(player, statId, amount, reason)
	if not StatConfig.IsValidStatId(statId) then
		return {
			Success = false,
			Error = "InvalidStat",
		}
	end

	local cleanAmount = readPositiveIntegerAmount(amount)
	if cleanAmount == nil then
		return {
			Success = false,
			Error = "InvalidAmount",
		}
	end

	local newValue = nil
	local success, err = PlayerDataService.MutateProfile(player, reason or "AddTrainingStatValue", function(profile)
		local stat = profile.TrainingStats[statId]
		stat.EffectiveValue += cleanAmount
		stat.Level = math.max(stat.Level, stat.EffectiveValue)
		newValue = stat.EffectiveValue
	end)

	if not success then
		return {
			Success = false,
			Error = tostring(err),
		}
	end

	return {
		Success = true,
		Stat = statId,
		Amount = cleanAmount,
		Value = newValue,
	}
end

function PlayerDataService.SavePlayer(player, force)
	local session = sessionsByPlayer[player]
	if not session then
		return false, "NoSession"
	end

	if not force and not session.Dirty then
		return true, "SkippedClean"
	end

	if not session.SaveEnabled then
		return false, session.LoadStatus or "SessionOnly"
	end

	local store = getProfileStore()
	if not store then
		session.SaveEnabled = false
		return false, "DataStoreUnavailable"
	end

	local repairResult = PlayerProfileModel.RepairProfile(session.Profile)
	session.Profile = repairResult.Profile
	syncReplicatedValues(player, session.Profile)

	local envelope = createEnvelope(session.Profile)
	local ok, err = pcall(function()
		store:UpdateAsync(profileKey(player), function()
			return envelope
		end)
	end)

	if not ok then
		warnOnce(("Save failed for %s: %s"):format(player.Name, tostring(err)))
		return false, tostring(err)
	end

	session.Dirty = false
	session.LastSavedAt = os.time()
	return true, "Saved"
end

function PlayerDataService.ReleasePlayer(player)
	local saveOk, saveStatus = PlayerDataService.SavePlayer(player, true)
	disconnectPlayerConnections(player)
	sessionsByPlayer[player] = nil

	return saveOk, saveStatus
end

function PlayerDataService.Start()
	if hasStarted then
		return true
	end

	hasStarted = true

	Players.PlayerAdded:Connect(function(player)
		PlayerDataService.LoadPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		PlayerDataService.ReleasePlayer(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		task.defer(function()
			PlayerDataService.LoadPlayer(player)
		end)
	end

	if not autosaveRunning then
		autosaveRunning = true
		task.spawn(function()
			while autosaveRunning do
				task.wait(AUTO_SAVE_INTERVAL_SECONDS)
				for player in pairs(sessionsByPlayer) do
					PlayerDataService.SavePlayer(player, false)
				end
			end
		end)
	end

	if not bindToCloseBound then
		bindToCloseBound = true
		game:BindToClose(function()
			for player in pairs(sessionsByPlayer) do
				PlayerDataService.SavePlayer(player, true)
			end
		end)
	end

	return true
end

return table.freeze(PlayerDataService)
