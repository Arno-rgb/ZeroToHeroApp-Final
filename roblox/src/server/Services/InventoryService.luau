local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZeroToHeroShared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local CombatStatConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("CombatStatConfig"))
local ItemConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("ItemConfig"))
local DerivedCombatStats = require(ZeroToHeroShared:WaitForChild("Utility"):WaitForChild("DerivedCombatStats"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local InventoryService = {}

local REMOTES_FOLDER_NAME = "Remotes"
local ACTION_EVENT_NAME = "InventoryAction"
local SNAPSHOT_EVENT_NAME = "InventorySnapshot"

local hasStarted = false
local actionConnection = nil

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

local function getActionEvent()
	return ensureRemoteEvent(getRemotesFolder(), ACTION_EVENT_NAME)
end

local function getSnapshotEvent()
	return ensureRemoteEvent(getRemotesFolder(), SNAPSHOT_EVENT_NAME)
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

local function createStatMap(defaultValue)
	local statMap = {}
	for _, statKey in ipairs(CombatStatConfig.GetCombatStatKeys()) do
		statMap[statKey] = defaultValue or 0
	end

	return statMap
end

local function addBonuses(target, bonuses)
	if typeof(bonuses) ~= "table" then
		return
	end

	for statKey, amount in pairs(bonuses) do
		if CombatStatConfig.IsCombatStatKey(statKey) then
			target[statKey] += math.max(0, tonumber(amount) or 0)
		end
	end
end

local function getProfile(player)
	PlayerDataService.LoadPlayer(player)
	return PlayerDataService.GetProfileSnapshot(player)
end

local function getInventory(profile)
	if typeof(profile) ~= "table" or typeof(profile.Inventory) ~= "table" then
		return {
			Items = {},
			NextItemInstanceId = 1,
		}
	end

	if typeof(profile.Inventory.Items) ~= "table" then
		profile.Inventory.Items = {}
	end

	return profile.Inventory
end

local function normalizeInstanceId(instanceId)
	if typeof(instanceId) ~= "string" or instanceId == "" then
		return nil
	end

	return instanceId
end

local function getOwnedItem(profile, instanceId)
	local cleanInstanceId = normalizeInstanceId(instanceId)
	if cleanInstanceId == nil then
		return nil, nil, "InvalidInstanceId"
	end

	local inventory = getInventory(profile)
	local itemInstance = inventory.Items[cleanInstanceId]
	if typeof(itemInstance) ~= "table" then
		return nil, nil, "ItemNotOwned"
	end

	local item = ItemConfig.GetItem(itemInstance.ItemId)
	if item == nil then
		return nil, nil, "UnknownItem"
	end

	return itemInstance, item, nil
end

local function getBindingState(item)
	if item.TradePolicy == "AccountBound" then
		return "AccountBound"
	end

	return "Unbound"
end

local function buildItemSnapshot(itemInstance, item)
	return {
		InstanceId = itemInstance.InstanceId,
		ItemId = item.Id,
		Name = item.Name,
		Slot = item.Slot,
		Rarity = item.Rarity,
		StatBonuses = deepCopy(item.StatBonuses),
		PassiveId = item.PassiveId,
		TradePolicy = item.TradePolicy,
		Source = itemInstance.Source or item.Source,
		Description = item.Description,
		BindingState = itemInstance.BindingState or getBindingState(item),
		CreatedAt = itemInstance.CreatedAt or 0,
	}
end

local function buildItems(profile)
	local items = {}
	for instanceId, itemInstance in pairs(getInventory(profile).Items) do
		local item = ItemConfig.GetItem(itemInstance.ItemId)
		if item then
			local snapshot = buildItemSnapshot(itemInstance, item)
			table.insert(items, snapshot)
		else
			table.insert(items, {
				InstanceId = instanceId,
				ItemId = itemInstance.ItemId,
				Name = "Unknown Item",
				Slot = "Unknown",
				Rarity = "Unknown",
				StatBonuses = {},
				PassiveId = "None",
				TradePolicy = "AccountBound",
				Source = itemInstance.Source or "Unknown",
				Description = "Missing item configuration.",
				BindingState = itemInstance.BindingState or "Unknown",
				CreatedAt = itemInstance.CreatedAt or 0,
			})
		end
	end

	table.sort(items, function(left, right)
		if left.CreatedAt == right.CreatedAt then
			return left.InstanceId < right.InstanceId
		end

		return left.CreatedAt < right.CreatedAt
	end)

	return items
end

function InventoryService.GetEquipmentBonusesFromProfile(profile, overrideSlot, overrideInstanceId)
	local bonuses = createStatMap(0)
	local equipment = typeof(profile) == "table" and profile.Equipment or {}

	for _, slot in ipairs(ItemConfig.GetSlots()) do
		local instanceId = equipment and equipment[slot] or false
		if overrideSlot == slot then
			instanceId = overrideInstanceId
		end

		if instanceId and instanceId ~= false then
			local _, item = getOwnedItem(profile, instanceId)
			if item then
				addBonuses(bonuses, item.StatBonuses)
			end
		end
	end

	return bonuses
end

function InventoryService.GetEquipmentBonuses(player)
	local profile = getProfile(player)
	if profile == nil then
		return createStatMap(0)
	end

	return InventoryService.GetEquipmentBonusesFromProfile(profile)
end

local function calculateStats(profile, bonuses)
	return DerivedCombatStats.CalculateForProfile(profile, {
		EquipmentBonuses = bonuses or InventoryService.GetEquipmentBonusesFromProfile(profile),
	})
end

local function buildEquippedItems(profile)
	local equippedItems = {}
	local equipment = typeof(profile) == "table" and profile.Equipment or {}

	for _, slot in ipairs(ItemConfig.GetSlots()) do
		local instanceId = equipment[slot]
		if instanceId and instanceId ~= false then
			local itemInstance, item = getOwnedItem(profile, instanceId)
			if itemInstance and item then
				equippedItems[slot] = buildItemSnapshot(itemInstance, item)
			end
		end
	end

	return equippedItems
end

local function buildComparison(profile, instanceId)
	local itemInstance, item, errorCode = getOwnedItem(profile, instanceId)
	if errorCode then
		return nil, errorCode
	end

	local currentBonuses = InventoryService.GetEquipmentBonusesFromProfile(profile)
	local newBonuses = InventoryService.GetEquipmentBonusesFromProfile(profile, item.Slot, itemInstance.InstanceId)
	local currentStats = calculateStats(profile, currentBonuses).Stats
	local newStats = calculateStats(profile, newBonuses).Stats
	local statDelta = createStatMap(0)
	local bonusDelta = createStatMap(0)

	for _, statKey in ipairs(CombatStatConfig.GetCombatStatKeys()) do
		statDelta[statKey] = (newStats[statKey] or 0) - (currentStats[statKey] or 0)
		bonusDelta[statKey] = (newBonuses[statKey] or 0) - (currentBonuses[statKey] or 0)
	end

	return {
		InstanceId = itemInstance.InstanceId,
		ItemId = item.Id,
		Slot = item.Slot,
		CurrentInstanceId = profile.Equipment[item.Slot] or false,
		StatDelta = statDelta,
		EquipmentBonusDelta = bonusDelta,
		CurrentStats = currentStats,
		NewStats = newStats,
	}, nil
end

function InventoryService.GetSnapshot(player, selectedInstanceId)
	local profile = getProfile(player)
	if profile == nil then
		return {
			Success = false,
			Error = "NoProfile",
		}
	end

	local bonuses = InventoryService.GetEquipmentBonusesFromProfile(profile)
	local statResult = calculateStats(profile, bonuses)
	local selectedItem = nil
	local comparison = nil
	local comparisonError = nil

	if selectedInstanceId ~= nil then
		local itemInstance, item, errorCode = getOwnedItem(profile, selectedInstanceId)
		if itemInstance and item then
			selectedItem = buildItemSnapshot(itemInstance, item)
			comparison, comparisonError = buildComparison(profile, selectedInstanceId)
		else
			comparisonError = errorCode
		end
	end

	return {
		Success = true,
		Items = buildItems(profile),
		Equipment = deepCopy(profile.Equipment),
		EquippedItems = buildEquippedItems(profile),
		EquipmentBonuses = bonuses,
		EffectiveStats = statResult.Stats,
		EquipmentContribution = statResult.Contributions.Equipment,
		SelectedItem = selectedItem,
		Comparison = comparison,
		ComparisonError = comparisonError,
	}
end

local function fireSnapshot(player, result, selectedInstanceId)
	local snapshot = InventoryService.GetSnapshot(player, selectedInstanceId)
	snapshot.LastResult = result
	getSnapshotEvent():FireClient(player, snapshot)
	return snapshot
end

function InventoryService.AddItem(player, itemId, options)
	local item = ItemConfig.GetItem(itemId)
	if item == nil then
		return {
			Success = false,
			Error = "InvalidItemId",
		}
	end

	options = typeof(options) == "table" and options or {}
	local createdInstanceId = nil
	local success, err = PlayerDataService.MutateProfile(player, options.Reason or "AddItem", function(profile)
		local inventory = getInventory(profile)
		local nextId = math.max(1, math.floor(tonumber(inventory.NextItemInstanceId) or 1))
		local instanceId = ("item_%06d"):format(nextId)

		while inventory.Items[instanceId] ~= nil do
			nextId += 1
			instanceId = ("item_%06d"):format(nextId)
		end

		inventory.Items[instanceId] = {
			InstanceId = instanceId,
			ItemId = item.Id,
			Source = options.Source or item.Source,
			CreatedAt = os.time(),
			BindingState = getBindingState(item),
		}
		inventory.NextItemInstanceId = nextId + 1
		createdInstanceId = instanceId
	end)

	if not success then
		return {
			Success = false,
			Error = tostring(err),
		}
	end

	local result = {
		Success = true,
		Action = "AddItem",
		InstanceId = createdInstanceId,
		ItemId = item.Id,
		Item = ItemConfig.GetItem(item.Id),
	}

	if options.Display ~= false then
		fireSnapshot(player, result, createdInstanceId)
	end

	return result
end

function InventoryService.RemoveItem(player, instanceId)
	local profile = getProfile(player)
	local itemInstance, item, errorCode = getOwnedItem(profile, instanceId)
	if errorCode then
		return {
			Success = false,
			Error = errorCode,
		}
	end

	for slot, equippedInstanceId in pairs(profile.Equipment) do
		if equippedInstanceId == itemInstance.InstanceId then
			return {
				Success = false,
				Error = "ItemEquipped",
				Slot = slot,
			}
		end
	end

	local success, err = PlayerDataService.MutateProfile(player, "RemoveItem", function(mutableProfile)
		mutableProfile.Inventory.Items[itemInstance.InstanceId] = nil
	end)

	if not success then
		return {
			Success = false,
			Error = tostring(err),
		}
	end

	local result = {
		Success = true,
		Action = "RemoveItem",
		InstanceId = itemInstance.InstanceId,
		ItemId = item.Id,
	}
	fireSnapshot(player, result)
	return result
end

function InventoryService.InspectItem(player, instanceId)
	local profile = getProfile(player)
	local itemInstance, item, errorCode = getOwnedItem(profile, instanceId)
	if errorCode then
		return {
			Success = false,
			Error = errorCode,
		}
	end

	return {
		Success = true,
		Action = "InspectItem",
		Item = buildItemSnapshot(itemInstance, item),
		Comparison = buildComparison(profile, itemInstance.InstanceId),
	}
end

function InventoryService.CompareItem(player, instanceId)
	local profile = getProfile(player)
	local comparison, errorCode = buildComparison(profile, instanceId)
	if errorCode then
		return {
			Success = false,
			Error = errorCode,
		}
	end

	return {
		Success = true,
		Action = "CompareItem",
		Comparison = comparison,
	}
end

function InventoryService.EquipItem(player, instanceId, requestedSlot)
	local profile = getProfile(player)
	local itemInstance, item, errorCode = getOwnedItem(profile, instanceId)
	if errorCode then
		return {
			Success = false,
			Error = errorCode,
		}
	end

	if requestedSlot ~= nil and requestedSlot ~= item.Slot then
		return {
			Success = false,
			Error = "SlotMismatch",
			ExpectedSlot = item.Slot,
			RequestedSlot = requestedSlot,
		}
	end

	local before = InventoryService.GetSnapshot(player, itemInstance.InstanceId)
	local oldInstanceId = profile.Equipment[item.Slot] or false
	local success, err = PlayerDataService.MutateProfile(player, "EquipItem", function(mutableProfile)
		local mutableItem = mutableProfile.Inventory.Items[itemInstance.InstanceId]
		mutableProfile.Equipment[item.Slot] = itemInstance.InstanceId
		if mutableItem and item.TradePolicy == "BindOnEquip" and mutableItem.BindingState == "Unbound" then
			mutableItem.BindingState = "Bound"
		end
	end)

	if not success then
		return {
			Success = false,
			Error = tostring(err),
		}
	end

	local after = InventoryService.GetSnapshot(player, itemInstance.InstanceId)
	local result = {
		Success = true,
		Action = "EquipItem",
		Slot = item.Slot,
		InstanceId = itemInstance.InstanceId,
		ItemId = item.Id,
		OldInstanceId = oldInstanceId,
		BeforeStats = before.EffectiveStats,
		AfterStats = after.EffectiveStats,
		Comparison = after.Comparison,
	}
	fireSnapshot(player, result, itemInstance.InstanceId)
	return result
end

function InventoryService.UnequipItem(player, slot)
	if not ItemConfig.IsValidSlot(slot) then
		return {
			Success = false,
			Error = "InvalidSlot",
		}
	end

	local profile = getProfile(player)
	local oldInstanceId = profile.Equipment[slot]
	if oldInstanceId == nil or oldInstanceId == false then
		return {
			Success = false,
			Error = "SlotEmpty",
			Slot = slot,
		}
	end

	local success, err = PlayerDataService.MutateProfile(player, "UnequipItem", function(mutableProfile)
		mutableProfile.Equipment[slot] = false
	end)

	if not success then
		return {
			Success = false,
			Error = tostring(err),
		}
	end

	local result = {
		Success = true,
		Action = "UnequipItem",
		Slot = slot,
		OldInstanceId = oldInstanceId,
	}
	fireSnapshot(player, result, oldInstanceId)
	return result
end

local function handleClientAction(player, payload)
	if typeof(payload) ~= "table" then
		return
	end

	local action = payload.Action
	local result = nil
	local selectedInstanceId = payload.InstanceId
	local alreadyFiredSnapshot = false

	if action == "RequestSnapshot" then
		result = {
			Success = true,
			Action = action,
		}
	elseif action == "Inspect" then
		result = InventoryService.InspectItem(player, payload.InstanceId)
	elseif action == "Compare" then
		result = InventoryService.CompareItem(player, payload.InstanceId)
	elseif action == "Equip" then
		result = InventoryService.EquipItem(player, payload.InstanceId, payload.Slot)
		alreadyFiredSnapshot = result.Success == true
	elseif action == "Unequip" then
		result = InventoryService.UnequipItem(player, payload.Slot)
		selectedInstanceId = nil
		alreadyFiredSnapshot = result.Success == true
	elseif action == "Remove" then
		result = InventoryService.RemoveItem(player, payload.InstanceId)
		selectedInstanceId = nil
		alreadyFiredSnapshot = result.Success == true
	else
		result = {
			Success = false,
			Error = "UnknownAction",
		}
	end

	if not alreadyFiredSnapshot then
		fireSnapshot(player, result, selectedInstanceId)
	end
end

function InventoryService.GetActionEvent()
	return getActionEvent()
end

function InventoryService.GetSnapshotEvent()
	return getSnapshotEvent()
end

function InventoryService.Start()
	if hasStarted then
		return true
	end

	hasStarted = true
	getSnapshotEvent()

	if actionConnection == nil then
		actionConnection = getActionEvent().OnServerEvent:Connect(handleClientAction)
	end

	Players.PlayerAdded:Connect(function(player)
		task.defer(function()
			PlayerDataService.LoadPlayer(player)
			task.wait(0.5)
			if player.Parent then
				fireSnapshot(player, {
					Success = true,
					Action = "InitialSnapshot",
				})
			end
		end)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		task.defer(function()
			PlayerDataService.LoadPlayer(player)
			task.wait(0.5)
			if player.Parent then
				fireSnapshot(player, {
					Success = true,
					Action = "InitialSnapshot",
				})
			end
		end)
	end

	return true
end

return table.freeze(InventoryService)
