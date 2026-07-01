local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local ZeroToHeroShared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local CombatActionConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("CombatActionConfig"))
local FeatureFlags = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("FeatureFlags"))
local DerivedCombatStats = require(ZeroToHeroShared:WaitForChild("Utility"):WaitForChild("DerivedCombatStats"))
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))
local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local CombatService = {}

local REMOTES_FOLDER_NAME = "Remotes"
local COMBAT_STATE_FOLDER_NAME = "CombatState"
local STATE_SYNC_INTERVAL_SECONDS = 0.25
local BREAK_FEATURE_FLAG = "BreakSystemEnabled"
local LEGACY_COMBAT_SCRIPT_NAMES = {
	"EnemyArea.server",
	"AscensionSwordCombatServer",
}

local stateByPlayer = {}
local targetHitCallbacks = {}
local hasStarted = false
local actionConnection = nil
local stateSyncRunning = false

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

local function ensureNumberValue(parent, name, value)
	local numberValue = parent:FindFirstChild(name)
	if numberValue and not numberValue:IsA("NumberValue") then
		numberValue:Destroy()
		numberValue = nil
	end

	if not numberValue then
		numberValue = Instance.new("NumberValue")
		numberValue.Name = name
		numberValue.Parent = parent
	end

	numberValue.Value = tonumber(value) or 0
	return numberValue
end

local function ensureBoolValue(parent, name, value)
	local boolValue = parent:FindFirstChild(name)
	if boolValue and not boolValue:IsA("BoolValue") then
		boolValue:Destroy()
		boolValue = nil
	end

	if not boolValue then
		boolValue = Instance.new("BoolValue")
		boolValue.Name = name
		boolValue.Parent = parent
	end

	boolValue.Value = value == true
	return boolValue
end

local function getRemotesFolder()
	return ensureFolder(ZeroToHeroShared, REMOTES_FOLDER_NAME)
end

local function getActionEvent()
	local remoteNames = CombatActionConfig.GetRemoteNames()
	return ensureRemoteEvent(getRemotesFolder(), remoteNames.Action)
end

local function getFeedbackEvent()
	local remoteNames = CombatActionConfig.GetRemoteNames()
	return ensureRemoteEvent(getRemotesFolder(), remoteNames.Feedback)
end

local function resolvePath(pathSegments)
	local current = game

	for index, segment in ipairs(pathSegments or {}) do
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

local function getTargetRoot()
	return resolvePath(CombatActionConfig.GetTargetRootPath())
end

local function getCharacterRoot(player)
	local character = player.Character
	if character == nil then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(player)
	local character = player.Character
	if character == nil then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function getState(player)
	local state = stateByPlayer[player]
	if state == nil then
		state = {
			Stamina = nil,
			LastStaminaUpdate = os.clock(),
			LastStaminaSpendAt = 0,
			Cooldowns = {},
			IsGuarding = false,
			LastGuardToggleAt = 0,
			DodgeInvulnerableUntil = 0,
			LastDamageResult = nil,
		}
		stateByPlayer[player] = state
	end

	return state
end

local function readNonNegativeNumber(value, defaultValue)
	local numericValue = tonumber(value)
	if numericValue == nil or numericValue ~= numericValue or numericValue == math.huge or numericValue == -math.huge then
		return defaultValue or 0
	end

	return math.max(0, numericValue)
end

local function readTargetDamageMultiplier(targetModel)
	if targetModel == nil then
		return 1
	end

	local multiplier = tonumber(targetModel:GetAttribute("DamageTakenMultiplier"))
	if multiplier == nil or multiplier ~= multiplier or multiplier == math.huge or multiplier == -math.huge then
		return 1
	end

	return math.clamp(multiplier, 0.05, 2)
end

local function getStats(player)
	local profile = PlayerDataService.GetProfileSnapshot(player) or {}
	local result = DerivedCombatStats.CalculateForProfile(profile, {
		EquipmentBonuses = InventoryService.GetEquipmentBonusesFromProfile(profile),
	})
	return result.Stats, result
end

local function updateStamina(player, stats)
	local state = getState(player)
	local now = os.clock()
	local maxStamina = math.max(1, readNonNegativeNumber(stats.MaxStamina, 100))
	local regen = readNonNegativeNumber(stats.StaminaRecovery, 0)

	if state.Stamina == nil then
		state.Stamina = maxStamina
		state.LastStaminaUpdate = now
		return state.Stamina, maxStamina
	end

	local elapsed = math.max(0, now - (state.LastStaminaUpdate or now))
	local staminaConfig = CombatActionConfig.GetStaminaConfig()
	local regenDelay = readNonNegativeNumber(staminaConfig.RegenDelaySeconds, 0)
	if elapsed > 0 and now - (state.LastStaminaSpendAt or 0) >= regenDelay then
		state.Stamina = math.min(maxStamina, state.Stamina + (regen * elapsed))
	end

	state.Stamina = math.clamp(state.Stamina, 0, maxStamina)
	state.LastStaminaUpdate = now
	return state.Stamina, maxStamina
end

local function syncHumanoidStats(player, stats)
	local humanoid = getHumanoid(player)
	if humanoid == nil then
		return nil
	end

	local maxHP = math.max(1, readNonNegativeNumber(stats.MaxHP, 100))
	if math.abs(humanoid.MaxHealth - maxHP) > 0.5 then
		local currentRatio = 1
		if humanoid.MaxHealth > 0 then
			currentRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
		end

		humanoid.MaxHealth = maxHP
		humanoid.Health = humanoid.Health > 0 and math.max(1, math.min(maxHP, maxHP * currentRatio)) or 0
	end

	return humanoid
end

local function getCooldownRemainingMs(state, actionId)
	local now = os.clock()
	local nextAllowedAt = state.Cooldowns[actionId] or 0
	return math.max(0, math.floor((nextAllowedAt - now) * 1000 + 0.5))
end

local function syncCombatState(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return nil
	end

	local stats = getStats(player)
	local state = getState(player)
	local stamina, maxStamina = updateStamina(player, stats)
	local humanoid = syncHumanoidStats(player, stats)
	local health = humanoid and humanoid.Health or stats.MaxHP
	local maxHealth = humanoid and humanoid.MaxHealth or stats.MaxHP

	local folder = ensureFolder(player, COMBAT_STATE_FOLDER_NAME)
	ensureNumberValue(folder, "HP", math.floor(health + 0.5))
	ensureNumberValue(folder, "MaxHP", math.floor(maxHealth + 0.5))
	ensureNumberValue(folder, "Stamina", math.floor(stamina + 0.5))
	ensureNumberValue(folder, "MaxStamina", math.floor(maxStamina + 0.5))
	ensureNumberValue(folder, "AttackCooldownMs", getCooldownRemainingMs(state, "BasicAttack"))
	ensureNumberValue(folder, "DodgeCooldownMs", getCooldownRemainingMs(state, "Dodge"))
	ensureBoolValue(folder, "IsGuarding", state.IsGuarding)
	ensureBoolValue(folder, "DodgeInvulnerable", os.clock() < (state.DodgeInvulnerableUntil or 0))

	return folder
end

local function fireFeedback(player, payload)
	getFeedbackEvent():FireClient(player, payload)
end

local function fireTargetHitCallbacks(player, targetModel, result)
	for _, callback in ipairs(targetHitCallbacks) do
		local ok, err = pcall(callback, player, targetModel, result)
		if not ok then
			warn(("[CombatService] Target hit callback failed for %s: %s"):format(targetModel and targetModel.Name or "Unknown", tostring(err)))
		end
	end
end

local function isOnCooldown(state, actionId)
	local action = CombatActionConfig.GetAction(actionId)
	if action == nil then
		return false, 0
	end

	local now = os.clock()
	local nextAllowedAt = state.Cooldowns[actionId] or 0
	if now < nextAllowedAt then
		return true, nextAllowedAt - now
	end

	return false, 0
end

local function setCooldown(state, actionId)
	local action = CombatActionConfig.GetAction(actionId)
	if action == nil then
		return
	end

	state.Cooldowns[actionId] = os.clock() + readNonNegativeNumber(action.CooldownSeconds, 0)
end

local function getTargetModel(target)
	if typeof(target) ~= "Instance" then
		return nil
	end

	if target:IsA("Model") then
		return target
	end

	return target:FindFirstAncestorOfClass("Model")
end

local function getTargetBody(targetModel)
	if targetModel == nil then
		return nil
	end

	local body = targetModel:FindFirstChild("Body")
	if body and body:IsA("BasePart") then
		return body
	end

	if targetModel.PrimaryPart then
		return targetModel.PrimaryPart
	end

	return targetModel:FindFirstChildWhichIsA("BasePart", true)
end

local function getHealthValue(targetModel)
	local health = targetModel and targetModel:FindFirstChild("Health")
	if health and (health:IsA("IntValue") or health:IsA("NumberValue")) then
		return health
	end

	return nil
end

local function validateTarget(player, target, action)
	local targetModel = getTargetModel(target)
	local targetRoot = getTargetRoot()
	if targetModel == nil or targetRoot == nil or not targetModel:IsDescendantOf(targetRoot) then
		return nil, nil, "InvalidTarget"
	end

	local health = getHealthValue(targetModel)
	if health == nil or health.Value <= 0 then
		return nil, nil, "TargetDefeated"
	end

	local root = getCharacterRoot(player)
	local body = getTargetBody(targetModel)
	if root == nil then
		return nil, nil, "NoCharacterRoot"
	end
	if body == nil then
		return nil, nil, "MissingTargetBody"
	end

	local offset = body.Position - root.Position
	local distance = offset.Magnitude
	local range = readNonNegativeNumber(action.Range, 0)
	if distance > range then
		return nil, nil, "OutOfRange"
	end

	if distance > 0.05 then
		local direction = offset.Unit
		local facing = root.CFrame.LookVector
		local facingFlat = Vector3.new(facing.X, 0, facing.Z)
		local directionFlat = Vector3.new(direction.X, 0, direction.Z)
		if facingFlat.Magnitude > 0.01 and directionFlat.Magnitude > 0.01 then
			local arcDot = math.clamp(tonumber(action.ArcDot) or 0, -1, 1)
			local dot = facingFlat.Unit:Dot(directionFlat.Unit)
			if dot < arcDot then
				return nil, nil, "TargetOutsideArc"
			end
		end
	end

	return targetModel, health, nil
end

local function getCleanHorizontalDirection(value, player)
	local direction = nil
	if typeof(value) == "Vector3" then
		direction = value
	end

	local root = getCharacterRoot(player)
	if direction == nil or direction.Magnitude < 0.01 then
		direction = root and root.CFrame.LookVector or Vector3.new(0, 0, -1)
	end

	local clean = Vector3.new(direction.X, 0, direction.Z)
	if clean.Magnitude < 0.01 then
		return Vector3.new(0, 0, -1)
	end

	if clean.X ~= clean.X or clean.Y ~= clean.Y or clean.Z ~= clean.Z then
		return Vector3.new(0, 0, -1)
	end

	return clean.Unit
end

local function applyDodgeDisplacement(player, direction, action)
	local root = getCharacterRoot(player)
	if root == nil then
		return 0
	end

	local distance = readNonNegativeNumber(action.Distance, 0)
	local padding = readNonNegativeNumber(action.RaycastPadding, 0)
	local finalDistance = distance
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { player.Character }

	local result = Workspace:Raycast(root.Position, direction * distance, raycastParams)
	if result then
		finalDistance = math.max(0, result.Distance - padding)
	end

	if finalDistance > 0 then
		root.CFrame = root.CFrame + (direction * finalDistance)
	end

	return finalDistance
end

local function handleBasicAttack(player, payload)
	local state = getState(player)
	local onCooldown, remaining = isOnCooldown(state, "BasicAttack")
	if onCooldown then
		return {
			Success = false,
			Error = "Cooldown",
			CooldownRemaining = remaining,
		}
	end

	local action = CombatActionConfig.GetAction("BasicAttack")
	local targetModel, health, targetError = validateTarget(player, payload.Target, action)
	if targetError then
		return {
			Success = false,
			Error = targetError,
		}
	end

	local stats = getStats(player)
	updateStamina(player, stats)
	setCooldown(state, "BasicAttack")

	local damageMultiplier = readNonNegativeNumber(action.DamageMultiplier, 1)
	local breakDamageMultiplier = FeatureFlags.IsEnabled(BREAK_FEATURE_FLAG) and readNonNegativeNumber(action.BreakDamageMultiplier, 1) or 0
	local rawDamage = math.max(1, math.floor((readNonNegativeNumber(stats.PhysicalDamage, 1) * damageMultiplier) + 0.5))
	local rawBreakDamage = math.max(0, math.floor((readNonNegativeNumber(stats.BreakDamage, 0) * breakDamageMultiplier) + 0.5))
	local targetDamageMultiplier = readTargetDamageMultiplier(targetModel)
	local damage = math.max(1, math.floor((rawDamage * targetDamageMultiplier) + 0.5))
	local oldHealth = health.Value
	local newHealth = math.max(0, oldHealth - damage)
	health.Value = newHealth

	local result = {
		Success = true,
		Type = "BasicAttack",
		Action = "BasicAttack",
		Target = targetModel,
		TargetName = targetModel.Name,
		Damage = damage,
		RawDamage = rawDamage,
		BreakDamage = rawBreakDamage,
		RawBreakDamage = rawBreakDamage,
		TargetDamageMultiplier = targetDamageMultiplier,
		OldHealth = oldHealth,
		NewHealth = newHealth,
		Defeated = newHealth <= 0,
	}

	fireTargetHitCallbacks(player, targetModel, result)
	syncCombatState(player)
	fireFeedback(player, result)
	return result
end

local function handleGuard(player, payload)
	local state = getState(player)
	local action = CombatActionConfig.GetAction("Guard")
	local now = os.clock()
	local minToggleInterval = readNonNegativeNumber(action.MinToggleInterval, 0)

	if now - (state.LastGuardToggleAt or 0) < minToggleInterval then
		return {
			Success = false,
			Error = "GuardToggleRateLimited",
		}
	end

	local desired = payload.IsActive
	if typeof(desired) ~= "boolean" then
		desired = not state.IsGuarding
	end

	state.IsGuarding = desired
	state.LastGuardToggleAt = now

	local stats = getStats(player)
	local stamina, maxStamina = updateStamina(player, stats)
	local result = {
		Success = true,
		Type = "Guard",
		Action = "Guard",
		IsGuarding = state.IsGuarding,
		GuardEffectiveness = stats.GuardEffectiveness,
		Stamina = math.floor(stamina + 0.5),
		MaxStamina = math.floor(maxStamina + 0.5),
	}

	syncCombatState(player)
	fireFeedback(player, result)
	return result
end

local function handleDodge(player, payload)
	local state = getState(player)
	local onCooldown, remaining = isOnCooldown(state, "Dodge")
	if onCooldown then
		return {
			Success = false,
			Error = "Cooldown",
			CooldownRemaining = remaining,
		}
	end

	if getCharacterRoot(player) == nil then
		return {
			Success = false,
			Error = "NoCharacterRoot",
		}
	end

	local stats = getStats(player)
	local stamina, maxStamina = updateStamina(player, stats)
	local action = CombatActionConfig.GetAction("Dodge")
	local cost = readNonNegativeNumber(action.StaminaCost, 0)
	if stamina < cost then
		return {
			Success = false,
			Error = "NotEnoughStamina",
			Stamina = math.floor(stamina + 0.5),
			MaxStamina = math.floor(maxStamina + 0.5),
		}
	end

	local direction = getCleanHorizontalDirection(payload.Direction, player)
	state.Stamina = math.max(0, stamina - cost)
	state.LastStaminaSpendAt = os.clock()
	state.LastStaminaUpdate = os.clock()
	state.DodgeInvulnerableUntil = os.clock() + readNonNegativeNumber(action.InvulnerabilitySeconds, 0)
	state.IsGuarding = false
	setCooldown(state, "Dodge")

	local movedDistance = applyDodgeDisplacement(player, direction, action)
	local result = {
		Success = true,
		Type = "Dodge",
		Action = "Dodge",
		Stamina = math.floor(state.Stamina + 0.5),
		MaxStamina = math.floor(maxStamina + 0.5),
		InvulnerableSeconds = action.InvulnerabilitySeconds,
		MovedDistance = movedDistance,
	}

	syncCombatState(player)
	fireFeedback(player, result)
	return result
end

function CombatService.ApplyIncomingDamage(player, rawDamage, options)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return {
			Success = false,
			Error = "InvalidPlayer",
		}
	end

	if typeof(options) ~= "table" then
		options = {}
	end

	local baseDamage = readNonNegativeNumber(rawDamage, 0)
	local stats = getStats(player)
	local state = getState(player)
	updateStamina(player, stats)

	local now = os.clock()
	local dodged = now < (state.DodgeInvulnerableUntil or 0)
	local guardReduction = 0
	if state.IsGuarding and not dodged then
		guardReduction = math.clamp(readNonNegativeNumber(stats.GuardEffectiveness, 0), 0, 0.75)
	end

	local finalDamage = baseDamage
	if dodged then
		finalDamage = 0
	elseif guardReduction > 0 and baseDamage > 0 then
		finalDamage = math.max(1, math.floor(baseDamage * (1 - guardReduction) + 0.5))
	end

	local humanoid = getHumanoid(player)
	if humanoid and finalDamage > 0 and options.ApplyToHumanoid ~= false then
		humanoid:TakeDamage(finalDamage)
	end

	local result = {
		Success = true,
		Type = "IncomingDamage",
		RawDamage = baseDamage,
		FinalDamage = finalDamage,
		GuardReduction = guardReduction,
		IsGuarding = state.IsGuarding,
		Dodged = dodged,
		Source = tostring(options.Source or "Unknown"),
	}

	state.LastDamageResult = result
	syncCombatState(player)
	fireFeedback(player, result)
	return result
end

function CombatService.GetPlayerCombatSnapshot(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return nil
	end

	local stats = getStats(player)
	local state = getState(player)
	local stamina, maxStamina = updateStamina(player, stats)

	return {
		Stats = table.clone(stats),
		Stamina = stamina,
		MaxStamina = maxStamina,
		IsGuarding = state.IsGuarding,
		DodgeInvulnerableUntil = state.DodgeInvulnerableUntil,
		Cooldowns = table.clone(state.Cooldowns),
		LastDamageResult = state.LastDamageResult,
	}
end

function CombatService.SyncCombatState(player)
	return syncCombatState(player)
end

function CombatService.GetActionEvent()
	return getActionEvent()
end

function CombatService.GetFeedbackEvent()
	return getFeedbackEvent()
end

function CombatService.RegisterTargetHitCallback(callback)
	if typeof(callback) ~= "function" then
		return false, "Callback must be a function"
	end

	table.insert(targetHitCallbacks, callback)
	return true
end

function CombatService.TryBasicAttack(player, target)
	return handleBasicAttack(player, {
		Target = target,
	})
end

function CombatService.SetGuarding(player, isGuarding)
	return handleGuard(player, {
		IsActive = isGuarding == true,
	})
end

function CombatService.TryDodge(player, direction)
	return handleDodge(player, {
		Direction = direction,
	})
end

local function handleClientAction(player, payload)
	if typeof(payload) ~= "table" then
		return
	end

	local actionType = payload.Type
	local result = nil

	if actionType == "BasicAttack" then
		result = handleBasicAttack(player, payload)
	elseif actionType == "Guard" then
		result = handleGuard(player, payload)
	elseif actionType == "Dodge" then
		result = handleDodge(player, payload)
	else
		return
	end

	if result and not result.Success then
		fireFeedback(player, {
			Success = false,
			Type = actionType,
			Action = actionType,
			Error = result.Error,
			CooldownRemaining = result.CooldownRemaining,
			Stamina = result.Stamina,
			MaxStamina = result.MaxStamina,
		})
	end
end

local function configureTrainingDummy()
	local targetRoot = getTargetRoot()
	if targetRoot == nil then
		return
	end

	local healthConfig = CombatActionConfig.GetTargetHealthConfig()
	for _, child in ipairs(targetRoot:GetChildren()) do
		if child:IsA("Model") then
			local health = getHealthValue(child)
			if health then
				local maxHealth = child:FindFirstChild("MaxHealth")
				if maxHealth and not maxHealth:IsA("IntValue") then
					maxHealth:Destroy()
					maxHealth = nil
				end

				if maxHealth == nil then
					maxHealth = Instance.new("IntValue")
					maxHealth.Name = "MaxHealth"
					maxHealth.Value = math.max(health.Value, healthConfig.DefaultTrainingDummyMaxHealth)
					maxHealth.Parent = child
				end

				if health.Value <= 0 then
					health.Value = maxHealth.Value
				end
			end
		end
	end
end

local function disableLegacyCombatScripts()
	for _, scriptName in ipairs(LEGACY_COMBAT_SCRIPT_NAMES) do
		local legacyScript = ServerScriptService:FindFirstChild(scriptName)
		if legacyScript and legacyScript:IsA("BaseScript") then
			legacyScript.Disabled = true
		end
	end
end

function CombatService.Start()
	if hasStarted then
		return true
	end

	hasStarted = true
	disableLegacyCombatScripts()
	configureTrainingDummy()
	getFeedbackEvent()

	if actionConnection == nil then
		actionConnection = getActionEvent().OnServerEvent:Connect(handleClientAction)
	end

	Players.PlayerRemoving:Connect(function(player)
		stateByPlayer[player] = nil
	end)

	Players.PlayerAdded:Connect(function(player)
		getState(player)
		task.defer(function()
			syncCombatState(player)
		end)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		getState(player)
		task.defer(function()
			syncCombatState(player)
		end)
	end

	if not stateSyncRunning then
		stateSyncRunning = true
		task.spawn(function()
			while stateSyncRunning do
				task.wait(STATE_SYNC_INTERVAL_SECONDS)
				for _, player in ipairs(Players:GetPlayers()) do
					syncCombatState(player)
				end
			end
		end)
	end

	return true
end

return table.freeze(CombatService)
