local ItemConfig = require(script.Parent:WaitForChild("ItemConfig"))

local LootTableConfig = {}

local MATERIALS = table.freeze({
	slime_residue = table.freeze({
		Id = "slime_residue",
		DisplayName = "Slime Residue",
		Source = "LesserSlime",
		Description = "A placeholder crafting material from early slime fights.",
	}),
	gate_hound_fang = table.freeze({
		Id = "gate_hound_fang",
		DisplayName = "Gate Hound Fang",
		Source = "GateHound",
		Description = "A sharp fang placeholder material from fast Broken Gate enemies.",
	}),
	stone_shell_shard = table.freeze({
		Id = "stone_shell_shard",
		DisplayName = "Stone Shell Shard",
		Source = "StoneShell",
		Description = "A dense shell fragment placeholder material from armoured enemies.",
	}),
	sentinel_core_chip = table.freeze({
		Id = "sentinel_core_chip",
		DisplayName = "Sentinel Core Chip",
		Source = "GateSentinel",
		Description = "A guarded core fragment placeholder material from gate sentinels.",
	}),
})

local LOOT_TABLES = {
	LesserSlime = {
		Id = "LesserSlime",
		DisplayName = "Lesser Slime Drops",
		AllowedItemRarities = { "Common" },
		Guaranteed = {
			HeroXP = 12,
			Gold = 0,
			Items = {},
			Materials = {},
		},
		Gold = {
			Chance = 0.35,
			Min = 2,
			Max = 4,
		},
		ItemDrop = {
			Chance = 0.2,
			Rolls = 1,
			Entries = {
				{
					ItemId = "slime_cleaned_saber",
					Weight = 1,
				},
				{
					ItemId = "slime_slick_vest",
					Weight = 1,
				},
				{
					ItemId = "slime_drop_pendant",
					Weight = 1,
				},
			},
		},
		Materials = {
			Chance = 0.3,
			Rolls = 1,
			Entries = {
				{
					MaterialId = "slime_residue",
					Min = 1,
					Max = 2,
					Weight = 1,
				},
			},
		},
	},
	GateHound = {
		Id = "GateHound",
		DisplayName = "Gate Hound Drops",
		AllowedItemRarities = { "Rare" },
		Guaranteed = {
			HeroXP = 18,
			Gold = 1,
			Items = {},
			Materials = {},
		},
		Gold = {
			Chance = 0.45,
			Min = 2,
			Max = 5,
		},
		ItemDrop = {
			Chance = 0.14,
			Rolls = 1,
			Entries = {
				{
					ItemId = "gate_hound_fangblade",
					Weight = 1,
				},
				{
					ItemId = "houndstep_charm",
					Weight = 1,
				},
			},
		},
		Materials = {
			Chance = 0.45,
			Rolls = 1,
			Entries = {
				{
					MaterialId = "gate_hound_fang",
					Min = 1,
					Max = 2,
					Weight = 1,
				},
			},
		},
	},
	StoneShell = {
		Id = "StoneShell",
		DisplayName = "Stone Shell Drops",
		AllowedItemRarities = { "Rare" },
		Guaranteed = {
			HeroXP = 24,
			Gold = 2,
			Items = {},
			Materials = {},
		},
		Gold = {
			Chance = 0.5,
			Min = 3,
			Max = 6,
		},
		ItemDrop = {
			Chance = 0.13,
			Rolls = 1,
			Entries = {
				{
					ItemId = "stone_shell_guardmail",
					Weight = 1,
				},
			},
		},
		Materials = {
			Chance = 0.5,
			Rolls = 1,
			Entries = {
				{
					MaterialId = "stone_shell_shard",
					Min = 1,
					Max = 2,
					Weight = 1,
				},
			},
		},
	},
	GateSentinel = {
		Id = "GateSentinel",
		DisplayName = "Gate Sentinel Drops",
		AllowedItemRarities = { "Epic" },
		Guaranteed = {
			HeroXP = 36,
			Gold = 4,
			Items = {},
			Materials = {},
		},
		Gold = {
			Chance = 0.55,
			Min = 4,
			Max = 8,
		},
		ItemDrop = {
			Chance = 0.1,
			Rolls = 1,
			Entries = {
				{
					ItemId = "sentinel_splitter",
					Weight = 1,
				},
				{
					ItemId = "sentinel_plate",
					Weight = 1,
				},
			},
		},
		Materials = {
			Chance = 0.55,
			Rolls = 1,
			Entries = {
				{
					MaterialId = "sentinel_core_chip",
					Min = 1,
					Max = 1,
					Weight = 1,
				},
			},
		},
	},
}

local function deepCopy(value)
	if typeof(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, child in pairs(value) do
		copy[deepCopy(key)] = deepCopy(child)
	end

	return copy
end

local function appendIssue(issues, path, message)
	table.insert(issues, {
		Path = path,
		Message = message,
	})
end

local function readChance(value)
	local numericValue = tonumber(value)
	if numericValue == nil or numericValue ~= numericValue or numericValue == math.huge or numericValue == -math.huge then
		return nil
	end

	if numericValue < 0 or numericValue > 1 then
		return nil
	end

	return numericValue
end

local function readPositiveInteger(value)
	local numericValue = tonumber(value)
	if numericValue == nil then
		return nil
	end

	numericValue = math.floor(numericValue)
	if numericValue < 1 then
		return nil
	end

	return numericValue
end

local function validateWeightedEntries(entries, issues, path, validator)
	if typeof(entries) ~= "table" or #entries == 0 then
		appendIssue(issues, path, "Expected at least one weighted entry")
		return
	end

	local totalWeight = 0
	for index, entry in ipairs(entries) do
		local entryPath = path .. "." .. tostring(index)
		if typeof(entry) ~= "table" then
			appendIssue(issues, entryPath, "Expected table")
		else
			local weight = tonumber(entry.Weight)
			if weight == nil or weight <= 0 then
				appendIssue(issues, entryPath .. ".Weight", "Expected positive weight")
			else
				totalWeight += weight
			end

			validator(entry, issues, entryPath)
		end
	end

	if totalWeight <= 0 then
		appendIssue(issues, path, "Expected total weight above zero")
	end
end

local function getAllowedRaritySet(lootTable)
	local allowed = {}
	if typeof(lootTable.AllowedItemRarities) ~= "table" then
		return allowed
	end

	for _, rarity in ipairs(lootTable.AllowedItemRarities) do
		if ItemConfig.IsValidRarity(rarity) then
			allowed[rarity] = true
		end
	end

	return allowed
end

local function validateItemEntry(entry, issues, path, lootTable)
	if not ItemConfig.IsValidItemId(entry.ItemId) then
		appendIssue(issues, path .. ".ItemId", "Expected configured item id")
		return
	end

	local item = ItemConfig.GetItem(entry.ItemId)
	local allowedRarities = getAllowedRaritySet(lootTable)
	local hasAllowedRarity = false
	for _ in pairs(allowedRarities) do
		hasAllowedRarity = true
		break
	end

	if hasAllowedRarity and not allowedRarities[item.Rarity] then
		appendIssue(issues, path .. ".ItemId", "Item rarity is not allowed by this loot table")
	end
end

local function validateMaterialEntry(entry, issues, path)
	if typeof(entry.MaterialId) ~= "string" or MATERIALS[entry.MaterialId] == nil then
		appendIssue(issues, path .. ".MaterialId", "Expected configured material id")
	end

	local minAmount = readPositiveInteger(entry.Min)
	local maxAmount = readPositiveInteger(entry.Max)
	if minAmount == nil then
		appendIssue(issues, path .. ".Min", "Expected positive integer")
	end
	if maxAmount == nil then
		appendIssue(issues, path .. ".Max", "Expected positive integer")
	end
	if minAmount ~= nil and maxAmount ~= nil and maxAmount < minAmount then
		appendIssue(issues, path .. ".Max", "Expected Max >= Min")
	end
end

function LootTableConfig.GetMaterial(materialId)
	local material = MATERIALS[materialId]
	if material == nil then
		return nil
	end

	return deepCopy(material)
end

function LootTableConfig.IsValidMaterialId(materialId)
	return typeof(materialId) == "string" and MATERIALS[materialId] ~= nil
end

function LootTableConfig.GetLootTable(tableId)
	local lootTable = LOOT_TABLES[tableId]
	if lootTable == nil then
		return nil
	end

	return deepCopy(lootTable)
end

function LootTableConfig.GetLootTableIds()
	local ids = {}
	for tableId in pairs(LOOT_TABLES) do
		table.insert(ids, tableId)
	end

	table.sort(ids)
	return ids
end

function LootTableConfig.ValidateLootTable(lootTable)
	local issues = {}

	if typeof(lootTable) ~= "table" then
		appendIssue(issues, "LootTable", "Expected table")
		return {
			IsValid = false,
			Issues = issues,
		}
	end

	if typeof(lootTable.Id) ~= "string" or lootTable.Id == "" then
		appendIssue(issues, "Id", "Expected non-empty string")
	end

	if typeof(lootTable.DisplayName) ~= "string" or lootTable.DisplayName == "" then
		appendIssue(issues, "DisplayName", "Expected non-empty string")
	end

	local guaranteed = lootTable.Guaranteed or {}
	if typeof(guaranteed) ~= "table" then
		appendIssue(issues, "Guaranteed", "Expected table")
	else
		local heroXP = math.floor(tonumber(guaranteed.HeroXP) or 0)
		local gold = math.floor(tonumber(guaranteed.Gold) or 0)
		if heroXP < 0 then
			appendIssue(issues, "Guaranteed.HeroXP", "Expected non-negative integer")
		end
		if gold < 0 then
			appendIssue(issues, "Guaranteed.Gold", "Expected non-negative integer")
		end
	end

	local goldDrop = lootTable.Gold
	if goldDrop ~= nil then
		if typeof(goldDrop) ~= "table" then
			appendIssue(issues, "Gold", "Expected table")
		else
			if readChance(goldDrop.Chance) == nil then
				appendIssue(issues, "Gold.Chance", "Expected chance from 0 to 1")
			end

			local minGold = math.floor(tonumber(goldDrop.Min) or -1)
			local maxGold = math.floor(tonumber(goldDrop.Max) or -1)
			if minGold < 0 then
				appendIssue(issues, "Gold.Min", "Expected non-negative integer")
			end
			if maxGold < minGold then
				appendIssue(issues, "Gold.Max", "Expected Max >= Min")
			end
		end
	end

	local itemDrop = lootTable.ItemDrop
	if itemDrop ~= nil then
		if typeof(itemDrop) ~= "table" then
			appendIssue(issues, "ItemDrop", "Expected table")
		else
			if readChance(itemDrop.Chance) == nil then
				appendIssue(issues, "ItemDrop.Chance", "Expected chance from 0 to 1")
			end
			if readPositiveInteger(itemDrop.Rolls or 1) == nil then
				appendIssue(issues, "ItemDrop.Rolls", "Expected positive integer")
			end
			validateWeightedEntries(itemDrop.Entries, issues, "ItemDrop.Entries", function(entry, nestedIssues, entryPath)
				validateItemEntry(entry, nestedIssues, entryPath, lootTable)
			end)
		end
	end

	local materialDrop = lootTable.Materials
	if materialDrop ~= nil then
		if typeof(materialDrop) ~= "table" then
			appendIssue(issues, "Materials", "Expected table")
		else
			if readChance(materialDrop.Chance) == nil then
				appendIssue(issues, "Materials.Chance", "Expected chance from 0 to 1")
			end
			if readPositiveInteger(materialDrop.Rolls or 1) == nil then
				appendIssue(issues, "Materials.Rolls", "Expected positive integer")
			end
			validateWeightedEntries(materialDrop.Entries, issues, "Materials.Entries", validateMaterialEntry)
		end
	end

	return {
		IsValid = #issues == 0,
		Issues = issues,
	}
end

function LootTableConfig.ValidateAllLootTables()
	local issues = {}
	local count = 0

	for tableId, lootTable in pairs(LOOT_TABLES) do
		count += 1
		local result = LootTableConfig.ValidateLootTable(lootTable)
		for _, issue in ipairs(result.Issues) do
			appendIssue(issues, tableId .. "." .. issue.Path, issue.Message)
		end
	end

	if count == 0 then
		appendIssue(issues, "LootTables", "Expected at least one loot table")
	end

	return {
		IsValid = #issues == 0,
		Issues = issues,
		TableCount = count,
	}
end

return table.freeze(LootTableConfig)
