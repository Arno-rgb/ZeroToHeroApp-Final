local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZeroToHeroShared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local HeroProgressionConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("HeroProgressionConfig"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local HeroProgressionService = {}

local REMOTES_FOLDER_NAME = "Remotes"

local hasStarted = false

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

local function readPositiveInteger(value)
	local numericValue = tonumber(value)
	if numericValue == nil then
		return 0
	end

	return math.max(0, math.floor(numericValue))
end

local function getRemotesFolder()
	return ensureFolder(ZeroToHeroShared, REMOTES_FOLDER_NAME)
end

local function getRewardEvent()
	return ensureRemoteEvent(getRemotesFolder(), HeroProgressionConfig.GetRewardRemoteName())
end

local function buildRewardRows(result)
	local rewards = {}

	if result.HeroXPGained > 0 then
		table.insert(rewards, {
			Kind = "HeroXP",
			HeroXP = result.HeroXPGained,
			OldLevel = result.OldHeroLevel,
			NewLevel = result.NewHeroLevel,
			LevelUps = result.LevelUps,
			NewHeroXP = result.NewHeroXP,
			NextHeroXPRequired = result.NextHeroXPRequired,
		})
	end

	if result.GoldGained > 0 then
		table.insert(rewards, {
			Kind = "Gold",
			Gold = result.GoldGained,
			OldGold = result.OldGold,
			NewGold = result.NewGold,
		})
	end

	if result.LevelUps > 0 then
		table.insert(rewards, {
			Kind = "LevelUp",
			Label = "Hero Level",
			NewLevel = result.NewHeroLevel,
			Amount = result.NewHeroLevel,
		})
	end

	return rewards
end

local function buildRewardPayload(result, options)
	options = typeof(options) == "table" and options or {}

	return {
		Title = tostring(options.Title or "Rewards Earned"),
		Subtitle = tostring(options.Subtitle or options.Source or "Hero Progress"),
		Source = tostring(options.Source or "HeroProgression"),
		Reason = tostring(result.Reason or options.Reason or ""),
		EnemyId = options.EnemyId,
		EnemyName = options.EnemyName,
		Rewards = buildRewardRows(result),
		HeroXP = result.HeroXPGained,
		Gold = result.GoldGained,
		OldLevel = result.OldHeroLevel,
		NewLevel = result.NewHeroLevel,
		LevelUps = result.LevelUps,
		NewHeroXP = result.NewHeroXP,
		NextHeroXPRequired = result.NextHeroXPRequired,
		NewGold = result.NewGold,
		DisplaySeconds = tonumber(options.DisplaySeconds) or (result.LevelUps > 0 and 2.15 or 1.8),
	}
end

local function shouldDisplay(options)
	if typeof(options) ~= "table" then
		return true
	end

	return options.Display ~= false
end

function HeroProgressionService.BuildRewardPayload(result, options)
	if typeof(result) ~= "table" then
		return nil
	end

	return buildRewardPayload(result, options)
end

function HeroProgressionService.AwardRewards(player, rewards, options)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return {
			Success = false,
			Error = "InvalidPlayer",
		}
	end

	if typeof(rewards) ~= "table" then
		rewards = {}
	end
	if typeof(options) ~= "table" then
		options = {}
	end

	local heroXPAmount = readPositiveInteger(rewards.HeroXP or rewards.HeroXPGained or rewards.XP)
	local goldAmount = readPositiveInteger(rewards.Gold or rewards.GoldGained)
	if heroXPAmount <= 0 and goldAmount <= 0 then
		return {
			Success = false,
			Error = "NoRewards",
		}
	end

	local reason = tostring(options.Reason or "HeroProgressionReward")
	local heroResult = nil
	if heroXPAmount > 0 then
		heroResult = PlayerDataService.AddHeroXP(player, heroXPAmount, reason)
		if not heroResult.Success then
			return heroResult
		end
	end

	local goldResult = nil
	if goldAmount > 0 then
		goldResult = PlayerDataService.AddGold(player, goldAmount, reason)
		if not goldResult.Success then
			return goldResult
		end
	end

	local currentProgress = PlayerDataService.GetHeroProgressSnapshot(player) or {}
	local result = {
		Success = true,
		Reason = reason,
		Source = tostring(options.Source or "HeroProgression"),
		HeroXPGained = heroResult and heroResult.Amount or 0,
		GoldGained = goldResult and goldResult.Amount or 0,
		OldHeroLevel = heroResult and heroResult.OldHeroLevel or currentProgress.Level,
		NewHeroLevel = heroResult and heroResult.NewHeroLevel or currentProgress.Level,
		OldHeroXP = heroResult and heroResult.OldHeroXP or currentProgress.XP,
		NewHeroXP = heroResult and heroResult.NewHeroXP or currentProgress.XP,
		LevelUps = heroResult and heroResult.LevelUps or 0,
		NextHeroXPRequired = heroResult and heroResult.NextHeroXPRequired or currentProgress.XPRequired,
		AtMaxLevel = heroResult and heroResult.AtMaxLevel or currentProgress.AtMaxLevel,
		OldGold = goldResult and goldResult.OldGold or nil,
		NewGold = goldResult and goldResult.NewGold or nil,
	}
	result.Rewards = buildRewardRows(result)

	if shouldDisplay(options) and #result.Rewards > 0 then
		getRewardEvent():FireClient(player, buildRewardPayload(result, options))
	end

	return result
end

function HeroProgressionService.AwardHeroXP(player, amount, options)
	return HeroProgressionService.AwardRewards(player, {
		HeroXP = amount,
	}, options)
end

function HeroProgressionService.AwardGold(player, amount, options)
	return HeroProgressionService.AwardRewards(player, {
		Gold = amount,
	}, options)
end

function HeroProgressionService.GetRewardEvent()
	return getRewardEvent()
end

function HeroProgressionService.Start()
	if hasStarted then
		return true
	end

	hasStarted = true
	getRewardEvent()
	return true
end

return table.freeze(HeroProgressionService)
