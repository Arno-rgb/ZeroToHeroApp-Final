local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZeroToHeroShared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local ItemConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("ItemConfig"))
local LootTableConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("LootTableConfig"))
local HeroProgressionService = require(script.Parent:WaitForChild("HeroProgressionService"))
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local LootService = {}

local claimedRewardKeys = {}
local hasStarted = false

local function readNonNegativeInteger(value, defaultValue)
	local numericValue = tonumber(value)
	if numericValue == nil or numericValue ~= numericValue or numericValue == math.huge or numericValue == -math.huge then
		return defaultValue or 0
	end

	return math.max(0, math.floor(numericValue))
end

local function readPositiveInteger(value, defaultValue)
	return math.max(1, readNonNegativeInteger(value, defaultValue or 1))
end

local function readChance(value)
	local numericValue = tonumber(value)
	if numericValue == nil or numericValue ~= numericValue or numericValue == math.huge or numericValue == -math.huge then
		return 0
	end

	return math.clamp(numericValue, 0, 1)
end

local function getRandom(options)
	options = typeof(options) == "table" and options or {}
	if typeof(options.Random) == "Random" then
		return options.Random
	end

	return Random.new()
end

local function shouldForce(options, fieldName)
	return typeof(options) == "table" and (options.ForceAllDrops == true or options[fieldName] == true)
end

local function rollChance(chance, options, forceFieldName)
	if shouldForce(options, forceFieldName) then
		return true
	end

	chance = readChance(chance)
	if chance <= 0 then
		return false
	end
	if chance >= 1 then
		return true
	end

	return getRandom(options):NextNumber() <= chance
end

local function chooseWeightedEntry(entries, random)
	if typeof(entries) ~= "table" or #entries == 0 then
		return nil
	end

	local totalWeight = 0
	for _, entry in ipairs(entries) do
		totalWeight += math.max(0, tonumber(entry.Weight) or 0)
	end

	if totalWeight <= 0 then
		return nil
	end

	local pick = random:NextNumber() * totalWeight
	local running = 0
	for _, entry in ipairs(entries) do
		running += math.max(0, tonumber(entry.Weight) or 0)
		if pick <= running then
			return entry
		end
	end

	return entries[#entries]
end

local function addMaterial(result, materialId, amount)
	local material = LootTableConfig.GetMaterial(materialId)
	if material == nil then
		return
	end

	amount = readPositiveInteger(amount, 1)
	for _, existing in ipairs(result.Materials) do
		if existing.MaterialId == material.Id then
			existing.Amount += amount
			return
		end
	end

	table.insert(result.Materials, {
		MaterialId = material.Id,
		MaterialName = material.DisplayName,
		Amount = amount,
		Source = material.Source,
	})
end

local function addItem(result, itemId)
	local item = ItemConfig.GetItem(itemId)
	if item == nil then
		return
	end

	table.insert(result.Items, {
		ItemId = item.Id,
		ItemName = item.Name,
		Rarity = item.Rarity,
		Slot = item.Slot,
		Amount = 1,
	})
end

local function applyGuaranteed(result, guaranteed)
	if typeof(guaranteed) ~= "table" then
		return
	end

	result.HeroXP += readNonNegativeInteger(guaranteed.HeroXP, 0)
	result.Gold += readNonNegativeInteger(guaranteed.Gold, 0)

	if typeof(guaranteed.Items) == "table" then
		for _, itemDrop in ipairs(guaranteed.Items) do
			if typeof(itemDrop) == "table" then
				addItem(result, itemDrop.ItemId)
			elseif typeof(itemDrop) == "string" then
				addItem(result, itemDrop)
			end
		end
	end

	if typeof(guaranteed.Materials) == "table" then
		for _, materialDrop in ipairs(guaranteed.Materials) do
			if typeof(materialDrop) == "table" then
				addMaterial(result, materialDrop.MaterialId, materialDrop.Amount or materialDrop.Quantity or 1)
			end
		end
	end
end

local function rollGold(result, lootTable, options)
	local goldDrop = lootTable.Gold
	if typeof(goldDrop) ~= "table" then
		return
	end

	if not rollChance(goldDrop.Chance, options, "ForceGoldDrop") then
		return
	end

	local minGold = readNonNegativeInteger(goldDrop.Min, 0)
	local maxGold = math.max(minGold, readNonNegativeInteger(goldDrop.Max, minGold))
	if maxGold <= 0 then
		return
	end

	result.Gold += getRandom(options):NextInteger(minGold, maxGold)
end

local function rollItems(result, lootTable, options)
	local itemDrop = lootTable.ItemDrop
	if typeof(itemDrop) ~= "table" then
		return
	end

	if not rollChance(itemDrop.Chance, options, "ForceItemDrop") then
		return
	end

	local random = getRandom(options)
	local rolls = readPositiveInteger(itemDrop.Rolls, 1)
	for _ = 1, rolls do
		local entry = chooseWeightedEntry(itemDrop.Entries, random)
		if entry then
			addItem(result, entry.ItemId)
		end
	end
end

local function rollMaterials(result, lootTable, options)
	local materialDrop = lootTable.Materials
	if typeof(materialDrop) ~= "table" then
		return
	end

	if not rollChance(materialDrop.Chance, options, "ForceMaterialDrop") then
		return
	end

	local random = getRandom(options)
	local rolls = readPositiveInteger(materialDrop.Rolls, 1)
	for _ = 1, rolls do
		local entry = chooseWeightedEntry(materialDrop.Entries, random)
		if entry then
			local minAmount = readPositiveInteger(entry.Min, 1)
			local maxAmount = math.max(minAmount, readPositiveInteger(entry.Max, minAmount))
			addMaterial(result, entry.MaterialId, random:NextInteger(minAmount, maxAmount))
		end
	end
end

local function buildRewardRows(result)
	local rows = {}

	if result.HeroXPGained > 0 then
		table.insert(rows, {
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
		table.insert(rows, {
			Kind = "Gold",
			Gold = result.GoldGained,
			OldGold = result.OldGold,
			NewGold = result.NewGold,
		})
	end

	for _, material in ipairs(result.Materials) do
		table.insert(rows, {
			Kind = "Material",
			MaterialId = material.MaterialId,
			MaterialName = material.MaterialName,
			Amount = material.Amount,
		})
	end

	for _, item in ipairs(result.Items) do
		table.insert(rows, {
			Kind = "Item",
			ItemId = item.ItemId,
			ItemName = item.ItemName,
			Rarity = item.Rarity,
			Amount = item.Amount or 1,
		})
	end

	if result.LevelUps > 0 then
		table.insert(rows, {
			Kind = "LevelUp",
			Label = "Hero Level",
			NewLevel = result.NewHeroLevel,
			Amount = result.NewHeroLevel,
		})
	end

	return rows
end

local function fireRewardPayload(player, result, options)
	if typeof(options) == "table" and options.Display == false then
		return
	end

	local rows = buildRewardRows(result)
	if #rows == 0 then
		return
	end

	HeroProgressionService.GetRewardEvent():FireClient(player, {
		Title = tostring(options.Title or "Loot Found"),
		Subtitle = tostring(options.Subtitle or options.Source or "Combat"),
		Source = tostring(options.Source or "Loot"),
		Reason = tostring(result.Reason or ""),
		EnemyId = options.EnemyId,
		EnemyName = options.EnemyName,
		Rewards = rows,
		HeroXP = result.HeroXPGained,
		Gold = result.GoldGained,
		OldLevel = result.OldHeroLevel,
		NewLevel = result.NewHeroLevel,
		LevelUps = result.LevelUps,
		NewHeroXP = result.NewHeroXP,
		NextHeroXPRequired = result.NextHeroXPRequired,
		NewGold = result.NewGold,
		DisplaySeconds = tonumber(options.DisplaySeconds) or (result.LevelUps > 0 and 2.15 or 1.9),
	})
end

function LootService.RollLootTable(tableId, options)
	local lootTable = LootTableConfig.GetLootTable(tableId)
	if lootTable == nil then
		return {
			Success = false,
			Error = "UnknownLootTable",
		}
	end

	local result = {
		Success = true,
		TableId = lootTable.Id,
		DisplayName = lootTable.DisplayName,
		HeroXP = 0,
		Gold = 0,
		Items = {},
		Materials = {},
	}

	options = typeof(options) == "table" and options or {}
	applyGuaranteed(result, lootTable.Guaranteed)
	rollGold(result, lootTable, options)
	rollMaterials(result, lootTable, options)
	rollItems(result, lootTable, options)

	return result
end

function LootService.GrantLoot(player, tableId, options)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return {
			Success = false,
			Error = "InvalidPlayer",
		}
	end

	options = typeof(options) == "table" and options or {}
	local rewardKey = options.RewardKey
	if typeof(rewardKey) == "string" and rewardKey ~= "" and claimedRewardKeys[rewardKey] then
		return {
			Success = false,
			Error = "DuplicateReward",
			RewardKey = rewardKey,
		}
	end

	local roll = LootService.RollLootTable(tableId, options)
	if not roll.Success then
		return roll
	end

	if roll.HeroXP <= 0 and roll.Gold <= 0 and #roll.Items == 0 and #roll.Materials == 0 then
		return {
			Success = false,
			Error = "NoRewards",
			RewardKey = rewardKey,
			Roll = roll,
		}
	end

	local reason = tostring(options.Reason or (tableId .. "Loot"))
	local result = {
		Success = true,
		Reason = reason,
		RewardKey = rewardKey,
		TableId = tableId,
		Source = tostring(options.Source or "Loot"),
		HeroXPGained = 0,
		GoldGained = 0,
		OldHeroLevel = nil,
		NewHeroLevel = nil,
		OldHeroXP = nil,
		NewHeroXP = nil,
		LevelUps = 0,
		NextHeroXPRequired = nil,
		OldGold = nil,
		NewGold = nil,
		Items = {},
		Materials = {},
		Roll = roll,
	}

	if roll.HeroXP > 0 or roll.Gold > 0 then
		local progression = HeroProgressionService.AwardRewards(player, {
			HeroXP = roll.HeroXP,
			Gold = roll.Gold,
		}, {
			Reason = reason,
			Source = result.Source,
			Display = false,
		})
		if not progression.Success then
			return progression
		end

		result.HeroXPGained = progression.HeroXPGained or 0
		result.GoldGained = progression.GoldGained or 0
		result.OldHeroLevel = progression.OldHeroLevel
		result.NewHeroLevel = progression.NewHeroLevel
		result.OldHeroXP = progression.OldHeroXP
		result.NewHeroXP = progression.NewHeroXP
		result.LevelUps = progression.LevelUps or 0
		result.NextHeroXPRequired = progression.NextHeroXPRequired
		result.OldGold = progression.OldGold
		result.NewGold = progression.NewGold
	end

	for _, material in ipairs(roll.Materials) do
		local materialResult = PlayerDataService.AddMaterial(player, material.MaterialId, material.Amount, reason)
		if not materialResult.Success then
			return materialResult
		end

		table.insert(result.Materials, {
			MaterialId = material.MaterialId,
			MaterialName = material.MaterialName,
			Amount = material.Amount,
			OldAmount = materialResult.OldAmount,
			NewAmount = materialResult.NewAmount,
		})
	end

	for _, item in ipairs(roll.Items) do
		local addResult = InventoryService.AddItem(player, item.ItemId, {
			Reason = reason,
			Source = options.Source or tableId,
			Display = options.InventorySnapshot ~= false,
		})
		if not addResult.Success then
			return addResult
		end

		local itemConfig = ItemConfig.GetItem(item.ItemId)
		table.insert(result.Items, {
			InstanceId = addResult.InstanceId,
			ItemId = item.ItemId,
			ItemName = itemConfig and itemConfig.Name or item.ItemName,
			Rarity = itemConfig and itemConfig.Rarity or item.Rarity,
			Slot = itemConfig and itemConfig.Slot or item.Slot,
			Amount = 1,
		})
	end

	if typeof(rewardKey) == "string" and rewardKey ~= "" then
		claimedRewardKeys[rewardKey] = true
	end

	fireRewardPayload(player, result, options)
	return result
end

function LootService.HasClaimedReward(rewardKey)
	return typeof(rewardKey) == "string" and claimedRewardKeys[rewardKey] == true
end

function LootService.Start()
	if hasStarted then
		return true
	end

	hasStarted = true
	HeroProgressionService.Start()
	InventoryService.Start()
	return true
end

return table.freeze(LootService)
