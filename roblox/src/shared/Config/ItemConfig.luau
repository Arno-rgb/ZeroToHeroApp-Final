local CombatStatConfig = require(script.Parent:WaitForChild("CombatStatConfig"))

local ItemConfig = {}

local SLOTS = { "Weapon", "Armour", "Charm" }
local RARITIES = { "Common", "Rare", "Epic", "Mythic" }
local TRADE_POLICIES = { "AccountBound", "BindOnEquip", "Tradeable" }

local SLOT_SET = {}
for _, slot in ipairs(SLOTS) do
	SLOT_SET[slot] = true
end

local RARITY_SET = {}
for _, rarity in ipairs(RARITIES) do
	RARITY_SET[rarity] = true
end

local TRADE_POLICY_SET = {}
for _, tradePolicy in ipairs(TRADE_POLICIES) do
	TRADE_POLICY_SET[tradePolicy] = true
end

local RARITY_BUDGETS = table.freeze({
	Common = 5,
	Rare = 10,
	Epic = 18,
	Mythic = 30,
})

local STAT_BUDGET_WEIGHTS = table.freeze({
	MaxHP = 0.1,
	PhysicalDamage = 1,
	BreakDamage = 1,
	MaxStamina = 0.2,
	StaminaRecovery = 5,
	MoveSpeedBonus = 200,
	CriticalChance = 200,
	GuardEffectiveness = 100,
	SkillEffectiveness = 50,
})

local function cloneArray(values)
	return table.clone(values)
end

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

local function freezeItem(item)
	local copy = table.clone(item)
	copy.StatBonuses = table.freeze(table.clone(item.StatBonuses))
	return table.freeze(copy)
end

local ITEMS = {
	freezeItem({
		Id = "starter_training_blade",
		Name = "Starter Training Blade",
		Slot = "Weapon",
		Rarity = "Common",
		StatBonuses = {
			PhysicalDamage = 2,
			BreakDamage = 1,
		},
		PassiveId = "None",
		TradePolicy = "AccountBound",
		Source = "Starter",
		Description = "A blunt-edged practice sword issued to every new adventurer.",
	}),
	freezeItem({
		Id = "slime_cleaned_saber",
		Name = "Slime-Cleaned Saber",
		Slot = "Weapon",
		Rarity = "Common",
		StatBonuses = {
			PhysicalDamage = 2,
			BreakDamage = 1,
		},
		PassiveId = "None",
		TradePolicy = "BindOnEquip",
		Source = "LesserSlime",
		Description = "A basic blade recovered near the slime grounds and scrubbed clean.",
	}),
	freezeItem({
		Id = "gate_hound_fangblade",
		Name = "Gate Hound Fangblade",
		Slot = "Weapon",
		Rarity = "Rare",
		StatBonuses = {
			PhysicalDamage = 4,
			CriticalChance = 0.012,
		},
		PassiveId = "HoundstepEdge",
		TradePolicy = "BindOnEquip",
		Source = "GateHound",
		Description = "A light fang-edged weapon for quick strikes at the Broken Gate.",
	}),
	freezeItem({
		Id = "sentinel_splitter",
		Name = "Sentinel Splitter",
		Slot = "Weapon",
		Rarity = "Epic",
		StatBonuses = {
			PhysicalDamage = 6,
			BreakDamage = 5,
			GuardEffectiveness = 0.01,
		},
		PassiveId = "SentinelPressure",
		TradePolicy = "BindOnEquip",
		Source = "GateSentinel",
		Description = "A heavy sword designed to crack defensive stances.",
	}),
	freezeItem({
		Id = "brakks_gatebreaker",
		Name = "Brakk's Gatebreaker",
		Slot = "Weapon",
		Rarity = "Mythic",
		StatBonuses = {
			PhysicalDamage = 9,
			BreakDamage = 8,
			CriticalChance = 0.018,
		},
		PassiveId = "BrakkBreakPressure",
		TradePolicy = "AccountBound",
		Source = "GatekeeperBrakk",
		Description = "A boss-forged blade carrying the force of Brakk's shattered gate.",
	}),
	freezeItem({
		Id = "starter_padded_armour",
		Name = "Starter Padded Armour",
		Slot = "Armour",
		Rarity = "Common",
		StatBonuses = {
			MaxHP = 20,
			GuardEffectiveness = 0.005,
		},
		PassiveId = "None",
		TradePolicy = "AccountBound",
		Source = "Starter",
		Description = "Light training armour that helps a new player survive early mistakes.",
	}),
	freezeItem({
		Id = "slime_slick_vest",
		Name = "Slime-Slick Vest",
		Slot = "Armour",
		Rarity = "Common",
		StatBonuses = {
			MaxHP = 28,
			StaminaRecovery = 0.18,
		},
		PassiveId = "None",
		TradePolicy = "BindOnEquip",
		Source = "LesserSlime",
		Description = "A flexible vest that shakes off grime and keeps the wearer moving.",
	}),
	freezeItem({
		Id = "stone_shell_guardmail",
		Name = "Stone-Shell Guardmail",
		Slot = "Armour",
		Rarity = "Rare",
		StatBonuses = {
			MaxHP = 60,
			MaxStamina = 10,
			GuardEffectiveness = 0.02,
		},
		PassiveId = "StoneShellGuard",
		TradePolicy = "BindOnEquip",
		Source = "StoneShell",
		Description = "Layered armour that rewards steady guard timing.",
	}),
	freezeItem({
		Id = "sentinel_plate",
		Name = "Sentinel Plate",
		Slot = "Armour",
		Rarity = "Epic",
		StatBonuses = {
			MaxHP = 90,
			MaxStamina = 16,
			GuardEffectiveness = 0.032,
		},
		PassiveId = "SentinelBulwark",
		TradePolicy = "BindOnEquip",
		Source = "GateSentinel",
		Description = "Disciplined plate armour shaped for long fights at the gate.",
	}),
	freezeItem({
		Id = "brakks_wardplate",
		Name = "Brakk's Wardplate",
		Slot = "Armour",
		Rarity = "Mythic",
		StatBonuses = {
			MaxHP = 150,
			MaxStamina = 25,
			GuardEffectiveness = 0.05,
		},
		PassiveId = "BrakkWard",
		TradePolicy = "AccountBound",
		Source = "GatekeeperBrakk",
		Description = "A boss reward that turns hard-earned endurance into staying power.",
	}),
	freezeItem({
		Id = "starter_focus_charm",
		Name = "Starter Focus Charm",
		Slot = "Charm",
		Rarity = "Common",
		StatBonuses = {
			MaxStamina = 10,
			SkillEffectiveness = 0.01,
		},
		PassiveId = "None",
		TradePolicy = "AccountBound",
		Source = "Starter",
		Description = "A simple charm that helps a new adventurer stay composed.",
	}),
	freezeItem({
		Id = "slime_drop_pendant",
		Name = "Slime Drop Pendant",
		Slot = "Charm",
		Rarity = "Common",
		StatBonuses = {
			MaxStamina = 14,
			StaminaRecovery = 0.25,
		},
		PassiveId = "None",
		TradePolicy = "BindOnEquip",
		Source = "LesserSlime",
		Description = "A small pendant that keeps stamina flowing during short fights.",
	}),
	freezeItem({
		Id = "houndstep_charm",
		Name = "Houndstep Charm",
		Slot = "Charm",
		Rarity = "Rare",
		StatBonuses = {
			MoveSpeedBonus = 0.012,
			CriticalChance = 0.012,
		},
		PassiveId = "Houndstep",
		TradePolicy = "BindOnEquip",
		Source = "GateHound",
		Description = "A quick-foot charm for players who like precise movement.",
	}),
	freezeItem({
		Id = "control_sigil",
		Name = "Control Sigil",
		Slot = "Charm",
		Rarity = "Epic",
		StatBonuses = {
			MaxStamina = 25,
			StaminaRecovery = 0.35,
			SkillEffectiveness = 0.055,
		},
		PassiveId = "FocusedTechnique",
		TradePolicy = "BindOnEquip",
		Source = "BrokenGate",
		Description = "A sigil for players who build mastery through clean timing.",
	}),
	freezeItem({
		Id = "brakks_broken_seal",
		Name = "Brakk's Broken Seal",
		Slot = "Charm",
		Rarity = "Mythic",
		StatBonuses = {
			MaxStamina = 35,
			CriticalChance = 0.02,
			GuardEffectiveness = 0.025,
			SkillEffectiveness = 0.09,
		},
		PassiveId = "BrakkSealbreaker",
		TradePolicy = "AccountBound",
		Source = "GatekeeperBrakk",
		Description = "A broken boss seal for controlled, high-pressure combat.",
	}),
}

local ITEMS_BY_ID = {}
local ITEM_IDS = {}

for index, item in ipairs(ITEMS) do
	ITEMS_BY_ID[item.Id] = item
	ITEM_IDS[index] = item.Id
end

local function appendIssue(issues, field, message)
	table.insert(issues, {
		Field = field,
		Message = message,
	})
end

local function isNonEmptyString(value)
	return typeof(value) == "string" and value ~= ""
end

local function readNonNegativeNumber(value)
	local numericValue = tonumber(value)
	if numericValue == nil or numericValue ~= numericValue or numericValue == math.huge or numericValue == -math.huge then
		return nil
	end

	if numericValue < 0 then
		return nil
	end

	return numericValue
end

function ItemConfig.GetSlots()
	return cloneArray(SLOTS)
end

function ItemConfig.GetRarities()
	return cloneArray(RARITIES)
end

function ItemConfig.GetTradePolicies()
	return cloneArray(TRADE_POLICIES)
end

function ItemConfig.IsValidSlot(slot)
	return typeof(slot) == "string" and SLOT_SET[slot] == true
end

function ItemConfig.IsValidRarity(rarity)
	return typeof(rarity) == "string" and RARITY_SET[rarity] == true
end

function ItemConfig.IsValidTradePolicy(tradePolicy)
	return typeof(tradePolicy) == "string" and TRADE_POLICY_SET[tradePolicy] == true
end

function ItemConfig.GetRarityBudget(rarity)
	if not ItemConfig.IsValidRarity(rarity) then
		return nil
	end

	return RARITY_BUDGETS[rarity]
end

function ItemConfig.GetStatBudgetWeights()
	return table.clone(STAT_BUDGET_WEIGHTS)
end

function ItemConfig.CalculateStatBudget(statBonuses)
	if typeof(statBonuses) ~= "table" then
		return 0
	end

	local total = 0
	for statKey, amount in pairs(statBonuses) do
		if CombatStatConfig.IsCombatStatKey(statKey) then
			local cleanAmount = readNonNegativeNumber(amount)
			if cleanAmount ~= nil then
				total += cleanAmount * (STAT_BUDGET_WEIGHTS[statKey] or 1)
			end
		end
	end

	return math.floor((total * 100) + 0.5) / 100
end

function ItemConfig.GetItemIds()
	return cloneArray(ITEM_IDS)
end

function ItemConfig.GetItem(itemId)
	if typeof(itemId) ~= "string" then
		return nil
	end

	local item = ITEMS_BY_ID[itemId]
	if item == nil then
		return nil
	end

	return deepCopy(item)
end

function ItemConfig.GetItems()
	local copy = {}
	for index, item in ipairs(ITEMS) do
		copy[index] = deepCopy(item)
	end

	return copy
end

function ItemConfig.GetItemsBySlot(slot)
	if not ItemConfig.IsValidSlot(slot) then
		return {}
	end

	local results = {}
	for _, item in ipairs(ITEMS) do
		if item.Slot == slot then
			table.insert(results, deepCopy(item))
		end
	end

	return results
end

function ItemConfig.GetItemsByRarity(rarity)
	if not ItemConfig.IsValidRarity(rarity) then
		return {}
	end

	local results = {}
	for _, item in ipairs(ITEMS) do
		if item.Rarity == rarity then
			table.insert(results, deepCopy(item))
		end
	end

	return results
end

function ItemConfig.IsValidItemId(itemId)
	return typeof(itemId) == "string" and ITEMS_BY_ID[itemId] ~= nil
end

function ItemConfig.ValidateItem(item)
	local issues = {}

	if typeof(item) ~= "table" then
		appendIssue(issues, "Item", "Expected table")
		return {
			IsValid = false,
			Issues = issues,
			Budget = 0,
			MaxBudget = nil,
		}
	end

	if not isNonEmptyString(item.Id) then
		appendIssue(issues, "Id", "Expected non-empty string")
	end

	if not isNonEmptyString(item.Name) then
		appendIssue(issues, "Name", "Expected non-empty string")
	end

	if not ItemConfig.IsValidSlot(item.Slot) then
		appendIssue(issues, "Slot", "Expected Weapon, Armour, or Charm")
	end

	if not ItemConfig.IsValidRarity(item.Rarity) then
		appendIssue(issues, "Rarity", "Expected Common, Rare, Epic, or Mythic")
	end

	if not isNonEmptyString(item.PassiveId) then
		appendIssue(issues, "PassiveId", "Expected non-empty string")
	end

	if not ItemConfig.IsValidTradePolicy(item.TradePolicy) then
		appendIssue(issues, "TradePolicy", "Expected AccountBound, BindOnEquip, or Tradeable")
	end

	if not isNonEmptyString(item.Source) then
		appendIssue(issues, "Source", "Expected non-empty string")
	end

	if not isNonEmptyString(item.Description) then
		appendIssue(issues, "Description", "Expected non-empty string")
	end

	if typeof(item.StatBonuses) ~= "table" then
		appendIssue(issues, "StatBonuses", "Expected table")
	else
		local hasBonus = false
		for statKey, amount in pairs(item.StatBonuses) do
			hasBonus = true
			if not CombatStatConfig.IsCombatStatKey(statKey) then
				appendIssue(issues, "StatBonuses." .. tostring(statKey), "Expected combat stat key")
			elseif readNonNegativeNumber(amount) == nil then
				appendIssue(issues, "StatBonuses." .. tostring(statKey), "Expected non-negative number")
			end
		end

		if not hasBonus then
			appendIssue(issues, "StatBonuses", "Expected at least one stat bonus")
		end
	end

	local budget = ItemConfig.CalculateStatBudget(item.StatBonuses)
	local maxBudget = ItemConfig.GetRarityBudget(item.Rarity)
	if maxBudget ~= nil and budget > maxBudget then
		appendIssue(issues, "StatBonuses", ("Budget %.2f exceeds %s cap %.2f"):format(budget, item.Rarity, maxBudget))
	end

	return {
		IsValid = #issues == 0,
		Issues = issues,
		Budget = budget,
		MaxBudget = maxBudget,
	}
end

function ItemConfig.ValidateAllItems()
	local issues = {}
	local seenIds = {}
	local slotCounts = {
		Weapon = 0,
		Armour = 0,
		Charm = 0,
	}

	for _, item in ipairs(ITEMS) do
		if seenIds[item.Id] then
			appendIssue(issues, item.Id, "Duplicate item id")
		end
		seenIds[item.Id] = true

		if ItemConfig.IsValidSlot(item.Slot) then
			slotCounts[item.Slot] += 1
		end

		local itemResult = ItemConfig.ValidateItem(item)
		for _, issue in ipairs(itemResult.Issues) do
			appendIssue(issues, item.Id .. "." .. issue.Field, issue.Message)
		end
	end

	if #ITEMS ~= 15 then
		appendIssue(issues, "Items", "Expected exactly 15 items")
	end

	for _, slot in ipairs(SLOTS) do
		if slotCounts[slot] == 0 then
			appendIssue(issues, "Slots." .. slot, "Expected at least one item")
		end
	end

	return {
		IsValid = #issues == 0,
		Issues = issues,
		ItemCount = #ITEMS,
		SlotCounts = slotCounts,
	}
end

return table.freeze(ItemConfig)
