local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ZeroToHeroShared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local EnemyConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("EnemyConfig"))
local FeatureFlags = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("FeatureFlags"))
local CombatService = require(script.Parent:WaitForChild("CombatService"))
local LootService = require(script.Parent:WaitForChild("LootService"))

local EnemyService = {}

local ENEMY_ROOT_NAMES = { "AscensionGrounds", "EnemyArea" }
local BREAK_FEATURE_FLAG = "BreakSystemEnabled"

local enemiesByModel = {}
local hasStarted = false
local hitCallbackRegistered = false

local function isBreakSystemEnabled()
	return FeatureFlags.IsEnabled(BREAK_FEATURE_FLAG)
end

local function getEnabledBreakConfig(config)
	if isBreakSystemEnabled() and typeof(config.Break) == "table" then
		return config.Break
	end

	return nil
end

local function readNumber(value, defaultValue)
	local numericValue = tonumber(value)
	if numericValue == nil or numericValue ~= numericValue or numericValue == math.huge or numericValue == -math.huge then
		return defaultValue or 0
	end

	return numericValue
end

local function readPositiveInteger(value, defaultValue)
	return math.max(1, math.floor(readNumber(value, defaultValue or 1)))
end

local function readDamageMultiplier(value, defaultValue)
	local multiplier = readNumber(value, defaultValue or 1)
	return math.clamp(multiplier, 0.05, 2)
end

local function ensureModel(parent, name)
	local model = parent:FindFirstChild(name)
	if model and not model:IsA("Model") then
		model:Destroy()
		model = nil
	end

	if not model then
		model = Instance.new("Model")
		model.Name = name
		model.Parent = parent
	end

	return model
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

local function ensureStringValue(parent, name, value)
	local stringValue = parent:FindFirstChild(name)
	if stringValue and not stringValue:IsA("StringValue") then
		stringValue:Destroy()
		stringValue = nil
	end

	if not stringValue then
		stringValue = Instance.new("StringValue")
		stringValue.Name = name
		stringValue.Parent = parent
	end

	stringValue.Value = tostring(value or "")
	return stringValue
end

local function getEnemyRoot()
	local ascensionGrounds = Workspace:FindFirstChild(ENEMY_ROOT_NAMES[1])
	if ascensionGrounds == nil then
		ascensionGrounds = Instance.new("Model")
		ascensionGrounds.Name = ENEMY_ROOT_NAMES[1]
		ascensionGrounds.Parent = Workspace
	end

	return ensureModel(ascensionGrounds, ENEMY_ROOT_NAMES[2])
end

local function getPlayerRoot(player)
	local character = player.Character
	if character == nil then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function isAlivePlayer(player)
	local character = player.Character
	if character == nil then
		return false
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0 and getPlayerRoot(player) ~= nil
end

local function createBillboard(body, displayName, strokeColor, includeBreakUi)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "EnemyBillboard"
	billboard.Size = UDim2.fromOffset(168, includeBreakUi == true and 68 or 50)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 3.6, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = body

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.BackgroundColor3 = Color3.fromRGB(12, 16, 20)
	panel.BackgroundTransparency = 0.12
	panel.BorderSizePixel = 0
	panel.Size = UDim2.fromScale(1, 1)
	panel.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = panel

	local stroke = Instance.new("UIStroke")
	stroke.Name = "Stroke"
	stroke.Color = strokeColor or Color3.fromRGB(98, 255, 144)
	stroke.Thickness = 2
	stroke.Transparency = 0.2
	stroke.Parent = panel

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.Text = displayName
	label.TextColor3 = Color3.fromRGB(226, 255, 232)
	label.TextSize = 15
	label.Size = UDim2.new(1, -12, 0, 24)
	label.Position = UDim2.fromOffset(6, 3)
	label.Parent = panel

	local healthLabel = Instance.new("TextLabel")
	healthLabel.Name = "HealthLabel"
	healthLabel.BackgroundTransparency = 1
	healthLabel.Font = Enum.Font.GothamBold
	healthLabel.Text = ""
	healthLabel.TextColor3 = Color3.fromRGB(188, 218, 199)
	healthLabel.TextSize = 12
	healthLabel.Size = UDim2.new(1, -12, 0, 18)
	healthLabel.Position = UDim2.fromOffset(6, 27)
	healthLabel.Parent = panel

	local breakLabel = nil
	local breakBar = nil
	local breakFill = nil
	if includeBreakUi == true then
		breakLabel = Instance.new("TextLabel")
		breakLabel.Name = "BreakLabel"
		breakLabel.BackgroundTransparency = 1
		breakLabel.Font = Enum.Font.GothamBold
		breakLabel.Text = ""
		breakLabel.TextColor3 = Color3.fromRGB(255, 196, 116)
		breakLabel.TextSize = 10
		breakLabel.TextXAlignment = Enum.TextXAlignment.Left
		breakLabel.Visible = false
		breakLabel.Size = UDim2.new(1, -12, 0, 12)
		breakLabel.Position = UDim2.fromOffset(6, 45)
		breakLabel.Parent = panel

		breakBar = Instance.new("Frame")
		breakBar.Name = "BreakBar"
		breakBar.BackgroundColor3 = Color3.fromRGB(54, 44, 38)
		breakBar.BorderSizePixel = 0
		breakBar.Visible = false
		breakBar.Size = UDim2.new(1, -12, 0, 5)
		breakBar.Position = UDim2.fromOffset(6, 58)
		breakBar.Parent = panel

		breakFill = Instance.new("Frame")
		breakFill.Name = "Fill"
		breakFill.BackgroundColor3 = Color3.fromRGB(255, 156, 72)
		breakFill.BorderSizePixel = 0
		breakFill.Size = UDim2.fromScale(0, 1)
		breakFill.Parent = breakBar
	end

	return {
		HealthLabel = healthLabel,
		BreakLabel = breakLabel,
		BreakBar = breakBar,
		BreakFill = breakFill,
	}
end

local function getVisualConfig(config)
	if typeof(config.Visual) == "table" then
		return config.Visual
	end

	return {}
end

local function createVisualPart(model, name, size, localCFrame, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = material or Enum.Material.SmoothPlastic
	part.Color = color or Color3.fromRGB(120, 120, 120)
	part.Size = size
	part.CFrame = localCFrame
	part.Parent = model

	return {
		Part = part,
		LocalCFrame = localCFrame,
	}
end

local function createEnemyAccentParts(model, config, visual)
	local visualParts = {}
	local bodySize = config.BodySize
	local accentColor = visual.AccentColor or visual.BodyColor or Color3.fromRGB(120, 120, 120)

	if config.Id == "GateHound" then
		table.insert(visualParts, createVisualPart(model, "Head", Vector3.new(2.4, 1.45, 1.6), CFrame.new(0, 0.25, -(bodySize.Z * 0.56)), accentColor))
		table.insert(visualParts, createVisualPart(model, "LeftEar", Vector3.new(0.55, 1.1, 0.35), CFrame.new(-0.85, 1.15, -(bodySize.Z * 0.62)) * CFrame.Angles(0, 0, math.rad(-18)), accentColor))
		table.insert(visualParts, createVisualPart(model, "RightEar", Vector3.new(0.55, 1.1, 0.35), CFrame.new(0.85, 1.15, -(bodySize.Z * 0.62)) * CFrame.Angles(0, 0, math.rad(18)), accentColor))
		table.insert(visualParts, createVisualPart(model, "FangLeft", Vector3.new(0.22, 0.62, 0.22), CFrame.new(-0.46, -0.42, -(bodySize.Z * 0.82)), Color3.fromRGB(238, 221, 188)))
		table.insert(visualParts, createVisualPart(model, "FangRight", Vector3.new(0.22, 0.62, 0.22), CFrame.new(0.46, -0.42, -(bodySize.Z * 0.82)), Color3.fromRGB(238, 221, 188)))
	elseif config.Id == "StoneShell" then
		table.insert(visualParts, createVisualPart(model, "ShellCrown", Vector3.new(bodySize.X * 0.82, 0.45, bodySize.Z * 0.72), CFrame.new(0, bodySize.Y * 0.48, 0), accentColor, Enum.Material.Slate))
		table.insert(visualParts, createVisualPart(model, "ShellPlateLeft", Vector3.new(0.38, bodySize.Y * 0.68, bodySize.Z * 0.76), CFrame.new(-(bodySize.X * 0.48), 0.05, 0), accentColor, Enum.Material.Slate))
		table.insert(visualParts, createVisualPart(model, "ShellPlateRight", Vector3.new(0.38, bodySize.Y * 0.68, bodySize.Z * 0.76), CFrame.new(bodySize.X * 0.48, 0.05, 0), accentColor, Enum.Material.Slate))
	elseif config.Id == "GateSentinel" then
		table.insert(visualParts, createVisualPart(model, "ShieldPlate", Vector3.new(bodySize.X * 1.08, bodySize.Y * 0.72, 0.38), CFrame.new(0, -0.05, -(bodySize.Z * 0.68)), accentColor, Enum.Material.Metal))
		table.insert(visualParts, createVisualPart(model, "Crest", Vector3.new(bodySize.X * 0.52, 0.75, 0.5), CFrame.new(0, bodySize.Y * 0.62, 0), accentColor, Enum.Material.Metal))
		table.insert(visualParts, createVisualPart(model, "BladeMarker", Vector3.new(0.42, bodySize.Y * 0.84, 0.42), CFrame.new(bodySize.X * 0.76, -0.22, -(bodySize.Z * 0.2)), Color3.fromRGB(176, 184, 190), Enum.Material.Metal))
	end

	return visualParts
end

local function createEnemyModel(config)
	local root = getEnemyRoot()
	local existing = root:FindFirstChild(config.Id)
	if existing then
		enemiesByModel[existing] = nil
		existing:Destroy()
	end

	local visual = getVisualConfig(config)
	local breakConfig = getEnabledBreakConfig(config)
	local model = Instance.new("Model")
	model.Name = config.Id
	model.Parent = root
	model:SetAttribute("EnemyId", config.Id)
	model:SetAttribute("DisplayName", config.DisplayName)
	model:SetAttribute("DamageTakenMultiplier", readDamageMultiplier(config.DamageTakenMultiplier, 1))
	model:SetAttribute("BaseDamageTakenMultiplier", readDamageMultiplier(config.DamageTakenMultiplier, 1))
	model:SetAttribute("Guarded", false)
	model:SetAttribute("BreakEnabled", breakConfig ~= nil)
	model:SetAttribute("Broken", false)
	model:SetAttribute("Vulnerable", false)

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = visual.BodyShape or Enum.PartType.Ball
	body.Anchored = true
	body.CanCollide = false
	body.CanTouch = false
	body.CanQuery = true
	body.Material = visual.BodyMaterial or Enum.Material.SmoothPlastic
	body.Color = visual.BodyColor or Color3.fromRGB(70, 214, 111)
	body.Size = config.BodySize
	body.Position = config.SpawnPosition
	body.Parent = model
	model.PrimaryPart = body

	local base = Instance.new("Part")
	base.Name = "BaseShadow"
	base.Anchored = true
	base.CanCollide = false
	base.CanTouch = false
	base.CanQuery = false
	base.Material = Enum.Material.SmoothPlastic
	base.Color = visual.BaseColor or Color3.fromRGB(22, 38, 30)
	base.Transparency = 0.35
	base.Size = Vector3.new(config.BodySize.X * 1.05, 0.16, config.BodySize.Z * 1.05)
	base.CFrame = CFrame.new(config.SpawnPosition - Vector3.new(0, config.BodySize.Y * 0.5, 0))
	base.Parent = model

	local telegraph = Instance.new("Part")
	telegraph.Name = "AttackTelegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.CanTouch = false
	telegraph.CanQuery = false
	telegraph.Material = Enum.Material.Neon
	telegraph.Color = visual.TelegraphColor or Color3.fromRGB(255, 68, 68)
	telegraph.Transparency = 1
	telegraph.Size = Vector3.new(config.AttackRange * 2, 0.12, config.AttackRange * 2)
	telegraph.CFrame = CFrame.new(config.SpawnPosition - Vector3.new(0, config.BodySize.Y * 0.5 - 0.08, 0))
	telegraph.Parent = model

	local visualParts = createEnemyAccentParts(model, config, visual)
	local guardTelegraph = nil
	if typeof(config.DefensivePattern) == "table" then
		local guardLocalCFrame = CFrame.new(0, 0, -(config.BodySize.Z * 0.78))
		local guardPart = Instance.new("Part")
		guardPart.Name = "GuardTelegraph"
		guardPart.Anchored = true
		guardPart.CanCollide = false
		guardPart.CanTouch = false
		guardPart.CanQuery = false
		guardPart.Material = Enum.Material.Neon
		guardPart.Color = visual.GuardColor or Color3.fromRGB(255, 68, 68)
		guardPart.Transparency = 1
		guardPart.Size = Vector3.new(config.BodySize.X * 1.25, config.BodySize.Y * 0.82, 0.16)
		guardPart.CFrame = CFrame.new(config.SpawnPosition) * guardLocalCFrame
		guardPart.Parent = model
		guardTelegraph = {
			Part = guardPart,
			LocalCFrame = guardLocalCFrame,
		}
	end

	local maxHealth = ensureIntValue(model, "MaxHealth", config.MaxHealth)
	local health = ensureIntValue(model, "Health", config.MaxHealth)
	local stateValue = ensureStringValue(model, "State", "Idle")
	local maxBreak = nil
	local breakMeter = nil
	local breakStateValue = nil
	if breakConfig ~= nil then
		maxBreak = ensureIntValue(model, "MaxBreak", breakConfig.MaxBreak)
		breakMeter = ensureIntValue(model, "Break", 0)
		breakStateValue = ensureStringValue(model, "BreakState", "Stable")
	end
	local billboardParts = createBillboard(body, config.DisplayName, visual.BillboardStrokeColor, breakConfig ~= nil)

	return {
		Model = model,
		Body = body,
		Base = base,
		Telegraph = telegraph,
		GuardTelegraph = guardTelegraph,
		VisualParts = visualParts,
		Health = health,
		MaxHealth = maxHealth,
		StateValue = stateValue,
		Break = breakMeter,
		MaxBreak = maxBreak,
		BreakStateValue = breakStateValue,
		HealthLabel = billboardParts.HealthLabel,
		BreakLabel = billboardParts.BreakLabel,
		BreakBar = billboardParts.BreakBar,
		BreakFill = billboardParts.BreakFill,
	}
end

local function pivotEnemy(state, position, lookAtPosition)
	local body = state.Body
	if body == nil then
		return
	end

	local target = lookAtPosition or (position + Vector3.new(0, 0, -1))
	local flatTarget = Vector3.new(target.X, position.Y, target.Z)
	if (flatTarget - position).Magnitude < 0.05 then
		flatTarget = position + Vector3.new(0, 0, -1)
	end

	local bodyCFrame = CFrame.lookAt(position, flatTarget)
	body.CFrame = bodyCFrame
	for _, visualPart in ipairs(state.VisualParts or {}) do
		if visualPart.Part and visualPart.Part.Parent ~= nil then
			visualPart.Part.CFrame = bodyCFrame * visualPart.LocalCFrame
		end
	end
	if state.GuardTelegraph and state.GuardTelegraph.Part and state.GuardTelegraph.Part.Parent ~= nil then
		state.GuardTelegraph.Part.CFrame = bodyCFrame * state.GuardTelegraph.LocalCFrame
	end
	state.Base.CFrame = CFrame.new(position - Vector3.new(0, state.Config.BodySize.Y * 0.5, 0))
	state.Telegraph.CFrame = CFrame.new(position - Vector3.new(0, state.Config.BodySize.Y * 0.5 - 0.08, 0))
end

local function setEnemyState(state, stateName)
	state.State = stateName
	state.StateValue.Value = stateName
	state.Model:SetAttribute("State", stateName)
end

local function refreshEnemyDisplay(state)
	state.HealthLabel.Text = string.format("%d / %d HP", state.Health.Value, state.MaxHealth.Value)
	if state.Break and state.MaxBreak and state.BreakLabel and state.BreakBar and state.BreakFill then
		local maxBreak = math.max(1, state.MaxBreak.Value)
		local breakValue = math.clamp(state.Break.Value, 0, maxBreak)
		state.BreakLabel.Visible = true
		state.BreakBar.Visible = true
		state.BreakLabel.Text = state.IsBroken and "BROKEN" or string.format("BREAK %d / %d", breakValue, maxBreak)
		state.BreakFill.Size = UDim2.fromScale(breakValue / maxBreak, 1)
	elseif state.BreakLabel and state.BreakBar then
		state.BreakLabel.Visible = false
		state.BreakBar.Visible = false
	end
	state.Body.Transparency = state.IsDead and 0.65 or 0
	state.Base.Transparency = state.IsDead and 1 or 0.35
	for _, visualPart in ipairs(state.VisualParts or {}) do
		if visualPart.Part and visualPart.Part.Parent ~= nil then
			visualPart.Part.Transparency = state.IsDead and 0.75 or 0
		end
	end
	if state.GuardTelegraph and state.GuardTelegraph.Part and state.IsDead then
		state.GuardTelegraph.Part.Transparency = 1
	end
end

local function setDamageTakenMultiplier(state, multiplier)
	local cleanMultiplier = readDamageMultiplier(multiplier, 1)
	state.CurrentDamageTakenMultiplier = cleanMultiplier
	state.Model:SetAttribute("DamageTakenMultiplier", cleanMultiplier)
end

local function getBreakConfig(state)
	if state == nil or typeof(state.Config.Break) ~= "table" or state.Break == nil or state.MaxBreak == nil then
		return nil
	end

	return state.Config.Break
end

local function setBreakStateValue(state, stateName)
	if state.BreakStateValue then
		state.BreakStateValue.Value = stateName
		state.Model:SetAttribute("BreakState", stateName)
	else
		state.Model:SetAttribute("BreakState", nil)
	end
end

local function resetBreakState(state)
	if state.Break then
		state.Break.Value = 0
	end
	state.IsBroken = false
	state.BreakTriggeredForCurrentMeter = false
	state.Model:SetAttribute("Broken", false)
	state.Model:SetAttribute("Vulnerable", false)
	setBreakStateValue(state, "Stable")
end

local function recoverBreak(state, spawnId)
	if state.Model.Parent == nil or state.IsDead or state.SpawnId ~= spawnId then
		return
	end

	resetBreakState(state)
	setDamageTakenMultiplier(state, state.Config.DamageTakenMultiplier)
	setEnemyState(state, "Idle")
	refreshEnemyDisplay(state)
end

local function triggerBrokenState(state)
	local breakConfig = getBreakConfig(state)
	if breakConfig == nil or state.IsDead or state.IsBroken then
		return
	end

	state.IsBroken = true
	state.BreakTriggeredForCurrentMeter = true
	state.IsAttacking = false
	state.IsGuarding = false
	state.TargetPlayer = nil
	state.GuardEndsAt = 0
	state.Model:SetAttribute("Broken", true)
	state.Model:SetAttribute("Vulnerable", true)
	state.Model:SetAttribute("Guarded", false)
	if state.Break and state.MaxBreak then
		state.Break.Value = state.MaxBreak.Value
	end
	setBreakStateValue(state, "Broken")
	setDamageTakenMultiplier(state, breakConfig.VulnerableDamageTakenMultiplier or 1.35)
	setEnemyState(state, "Broken")
	state.Telegraph.Transparency = 1
	if state.GuardTelegraph and state.GuardTelegraph.Part then
		state.GuardTelegraph.Part.Transparency = 1
	end
	refreshEnemyDisplay(state)

	local duration = math.max(0.25, readNumber(breakConfig.BrokenDurationSeconds, 2))
	local spawnId = state.SpawnId
	task.delay(duration, function()
		recoverBreak(state, spawnId)
	end)
end

local function applyBreakDamage(state, result)
	local breakConfig = getBreakConfig(state)
	if breakConfig == nil or state.IsDead then
		return
	end

	local breakDamage = math.max(0, math.floor(readNumber(result and (result.BreakDamage or result.RawBreakDamage), 0) + 0.5))
	if breakDamage <= 0 then
		return
	end

	if state.IsBroken then
		refreshEnemyDisplay(state)
		return
	end

	local maxBreak = math.max(1, state.MaxBreak.Value)
	local newBreak = math.min(maxBreak, state.Break.Value + breakDamage)
	state.Break.Value = newBreak
	setBreakStateValue(state, newBreak > 0 and "Pressured" or "Stable")
	if newBreak >= maxBreak and not state.BreakTriggeredForCurrentMeter then
		triggerBrokenState(state)
	else
		refreshEnemyDisplay(state)
	end
end

local function setGuardState(state, isGuarding)
	if typeof(state.Config.DefensivePattern) ~= "table" then
		return
	end

	state.IsGuarding = isGuarding == true
	state.Model:SetAttribute("Guarded", state.IsGuarding)
	if state.IsGuarding then
		local guardMultiplier = state.Config.DefensivePattern.GuardDamageTakenMultiplier or state.Config.DamageTakenMultiplier
		setDamageTakenMultiplier(state, guardMultiplier)
		setEnemyState(state, "Guard")
		if state.GuardTelegraph and state.GuardTelegraph.Part then
			state.GuardTelegraph.Part.Transparency = 0.32
		end
	else
		setDamageTakenMultiplier(state, state.Config.DamageTakenMultiplier)
		if state.GuardTelegraph and state.GuardTelegraph.Part then
			state.GuardTelegraph.Part.Transparency = 1
		end
	end
end

local function resetEnemy(state)
	state.SpawnId += 1
	state.IsDead = false
	state.IsAttacking = false
	state.IsGuarding = false
	state.TargetPlayer = nil
	state.RewardClaimedForSpawn = false
	state.LastAttackAt = 0
	state.LastGuardAt = os.clock()
	state.GuardEndsAt = 0
	state.Health.Value = state.MaxHealth.Value
	state.Model:SetAttribute("SpawnId", state.SpawnId)
	state.Model:SetAttribute("RewardClaimed", false)
	state.Model:SetAttribute("Guarded", false)
	resetBreakState(state)
	state.Telegraph.Transparency = 1
	if state.GuardTelegraph and state.GuardTelegraph.Part then
		state.GuardTelegraph.Part.Transparency = 1
	end
	setDamageTakenMultiplier(state, state.Config.DamageTakenMultiplier)
	pivotEnemy(state, state.Config.SpawnPosition)
	setEnemyState(state, "Idle")
	refreshEnemyDisplay(state)
end

local function findNearestPlayer(state, range)
	local nearestPlayer = nil
	local nearestDistance = math.huge
	local enemyPosition = state.Body.Position

	for _, player in ipairs(Players:GetPlayers()) do
		if isAlivePlayer(player) then
			local root = getPlayerRoot(player)
			local distance = (root.Position - enemyPosition).Magnitude
			if distance <= range and distance < nearestDistance then
				nearestPlayer = player
				nearestDistance = distance
			end
		end
	end

	return nearestPlayer, nearestDistance
end

local function moveTowardTarget(state, targetRoot, deltaSeconds)
	local offset = targetRoot.Position - state.Body.Position
	local horizontal = Vector3.new(offset.X, 0, offset.Z)
	if horizontal.Magnitude < 0.05 then
		return
	end

	local maxStep = math.max(0, state.Config.MoveSpeed) * deltaSeconds
	local step = math.min(horizontal.Magnitude, maxStep)
	local newPosition = state.Body.Position + (horizontal.Unit * step)
	pivotEnemy(state, newPosition, targetRoot.Position)
end

local function grantDeathReward(state, player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return {
			Success = false,
			Error = "InvalidPlayer",
		}
	end

	return LootService.GrantLoot(player, state.Config.LootTableId or state.Config.Id, {
		RewardKey = ("%s:%d:%d"):format(state.Config.Id, state.SpawnId, player.UserId),
		Reason = state.Config.Id .. "Defeat",
		Source = "Combat",
		Title = state.Config.RewardTitle or "Enemy Defeated",
		Subtitle = state.Config.DisplayName,
		EnemyId = state.Config.Id,
		EnemyName = state.Config.DisplayName,
		DisplaySeconds = 1.8,
	})
end

local function defeatEnemy(state, player)
	if state.IsDead then
		return false
	end

	state.IsDead = true
	state.IsAttacking = false
	state.TargetPlayer = nil
	state.RewardClaimedForSpawn = true
	state.Health.Value = 0
	state.Model:SetAttribute("RewardClaimed", true)
	state.Telegraph.Transparency = 1
	setGuardState(state, false)
	resetBreakState(state)
	setEnemyState(state, "Dead")
	refreshEnemyDisplay(state)
	grantDeathReward(state, player)

	task.delay(state.Config.RespawnSeconds, function()
		if state.Model.Parent == nil then
			return
		end

		setEnemyState(state, "Respawn")
		resetEnemy(state)
	end)

	return true
end

local function attackTarget(state, player)
	if state.IsDead or state.IsAttacking then
		return
	end

	local root = getPlayerRoot(player)
	if root == nil then
		return
	end

	state.IsAttacking = true
	state.LastAttackAt = os.clock()
	setEnemyState(state, "Attack")
	state.Telegraph.Transparency = 0.58

	local spawnId = state.SpawnId
	task.delay(state.Config.AttackTelegraphSeconds, function()
		state.Telegraph.Transparency = 1
		if state.Model.Parent == nil or state.IsDead or state.SpawnId ~= spawnId then
			state.IsAttacking = false
			return
		end

		if isAlivePlayer(player) then
			local currentRoot = getPlayerRoot(player)
			local distance = currentRoot and (currentRoot.Position - state.Body.Position).Magnitude or math.huge
			if distance <= state.Config.AttackRange then
				CombatService.ApplyIncomingDamage(player, state.Config.AttackDamage, {
					Source = state.Config.Id,
				})
			end
		end

		task.delay(state.Config.AttackWindDownSeconds, function()
			if state.Model.Parent == nil or state.IsDead or state.SpawnId ~= spawnId then
				state.IsAttacking = false
				return
			end

			state.IsAttacking = false
			setEnemyState(state, state.TargetPlayer and "Chase" or "Idle")
		end)
	end)
end

local function updateDefensivePattern(state, targetRoot, distance)
	local pattern = state.Config.DefensivePattern
	if typeof(pattern) ~= "table" or targetRoot == nil or state.IsAttacking or state.IsDead then
		return false
	end

	local now = os.clock()
	if state.IsGuarding then
		pivotEnemy(state, state.Body.Position, targetRoot.Position)
		if now >= (state.GuardEndsAt or 0) then
			setGuardState(state, false)
			state.LastGuardAt = now
			return false
		end

		return true
	end

	local triggerRange = math.max(state.Config.AttackRange, readNumber(pattern.TriggerRange, state.Config.DetectRange))
	local guardCooldown = math.max(0.5, readNumber(pattern.GuardCooldownSeconds, 4))
	if distance <= triggerRange and now - (state.LastGuardAt or 0) >= guardCooldown then
		state.GuardEndsAt = now + math.max(0.25, readNumber(pattern.GuardDurationSeconds, 1.25))
		setGuardState(state, true)
		pivotEnemy(state, state.Body.Position, targetRoot.Position)
		return true
	end

	return false
end

local function updateEnemy(state, deltaSeconds)
	if state.Health.Value <= 0 and not state.IsDead then
		defeatEnemy(state, state.TargetPlayer)
	end

	if state.IsDead then
		return
	end

	refreshEnemyDisplay(state)
	if state.IsBroken then
		return
	end

	local target = state.TargetPlayer
	if target == nil or not isAlivePlayer(target) then
		target = nil
	end

	local targetRoot = target and getPlayerRoot(target) or nil
	local distance = targetRoot and (targetRoot.Position - state.Body.Position).Magnitude or math.huge
	if target == nil or distance > state.Config.ChaseRange then
		target, distance = findNearestPlayer(state, state.Config.DetectRange)
		state.TargetPlayer = target
		if target then
			setEnemyState(state, "Detect")
		else
			setEnemyState(state, "Idle")
			return
		end
	end

	targetRoot = getPlayerRoot(target)
	if targetRoot == nil then
		state.TargetPlayer = nil
		setEnemyState(state, "Idle")
		return
	end

	distance = (targetRoot.Position - state.Body.Position).Magnitude
	if updateDefensivePattern(state, targetRoot, distance) then
		return
	end

	if distance <= state.Config.AttackRange then
		if os.clock() - state.LastAttackAt >= state.Config.AttackCooldownSeconds then
			attackTarget(state, target)
		elseif not state.IsAttacking then
			setEnemyState(state, "Attack")
			pivotEnemy(state, state.Body.Position, targetRoot.Position)
		end
	else
		if not state.IsAttacking then
			setEnemyState(state, "Chase")
			moveTowardTarget(state, targetRoot, deltaSeconds)
		end
	end
end

local function startEnemyLoop(state)
	task.spawn(function()
		local lastTick = os.clock()
		while hasStarted and state.Model.Parent ~= nil do
			local tickSeconds = math.max(0.1, readNumber(state.Config.TickSeconds, 0.25))
			task.wait(tickSeconds)
			local now = os.clock()
			local deltaSeconds = math.max(0, now - lastTick)
			lastTick = now
			updateEnemy(state, deltaSeconds)
		end
	end)
end

local function spawnEnemy(enemyId)
	local config = EnemyConfig.GetEnemy(enemyId)
	if config == nil then
		return nil, "UnknownEnemy"
	end

	config.MaxHealth = readPositiveInteger(config.MaxHealth, 1)
	config.AttackRange = math.max(1, readNumber(config.AttackRange, 5))
	config.AttackDamage = math.max(0, readNumber(config.AttackDamage, 0))
	config.AttackCooldownSeconds = math.max(0.1, readNumber(config.AttackCooldownSeconds, 2))
	config.AttackTelegraphSeconds = math.max(0, readNumber(config.AttackTelegraphSeconds, 0.5))
	config.AttackWindDownSeconds = math.max(0, readNumber(config.AttackWindDownSeconds, 0.2))
	config.MoveSpeed = math.max(0, readNumber(config.MoveSpeed, 8))
	config.RespawnSeconds = math.max(1, readNumber(config.RespawnSeconds, 6))
	local breakConfig = getEnabledBreakConfig(config)
	if breakConfig ~= nil then
		breakConfig.MaxBreak = readPositiveInteger(breakConfig.MaxBreak, 16)
		breakConfig.BrokenDurationSeconds = math.max(0.25, readNumber(breakConfig.BrokenDurationSeconds, 2))
		breakConfig.VulnerableDamageTakenMultiplier = readDamageMultiplier(breakConfig.VulnerableDamageTakenMultiplier, 1.35)
	else
		config.Break = nil
	end

	local parts = createEnemyModel(config)
	local state = {
		Config = config,
		Model = parts.Model,
		Body = parts.Body,
		Base = parts.Base,
		Telegraph = parts.Telegraph,
		GuardTelegraph = parts.GuardTelegraph,
		VisualParts = parts.VisualParts,
		Health = parts.Health,
		MaxHealth = parts.MaxHealth,
		StateValue = parts.StateValue,
		Break = parts.Break,
		MaxBreak = parts.MaxBreak,
		BreakStateValue = parts.BreakStateValue,
		HealthLabel = parts.HealthLabel,
		BreakLabel = parts.BreakLabel,
		BreakBar = parts.BreakBar,
		BreakFill = parts.BreakFill,
		State = "Idle",
		TargetPlayer = nil,
		IsDead = false,
		IsAttacking = false,
		IsGuarding = false,
		IsBroken = false,
		BreakTriggeredForCurrentMeter = false,
		LastAttackAt = 0,
		LastGuardAt = 0,
		GuardEndsAt = 0,
		CurrentDamageTakenMultiplier = readDamageMultiplier(config.DamageTakenMultiplier, 1),
		SpawnId = 0,
		RewardClaimedForSpawn = false,
	}

	enemiesByModel[state.Model] = state
	resetEnemy(state)
	startEnemyLoop(state)
	return state
end

local function handleCombatTargetHit(player, targetModel, result)
	local state = enemiesByModel[targetModel]
	if state == nil or state.IsDead then
		return
	end

	if result and result.Defeated and not state.RewardClaimedForSpawn then
		defeatEnemy(state, player)
		return
	end

	applyBreakDamage(state, result)
	refreshEnemyDisplay(state)
end

function EnemyService.GetEnemyState(enemyId)
	for model, state in pairs(enemiesByModel) do
		if model:GetAttribute("EnemyId") == enemyId then
			return state
		end
	end

	return nil
end

function EnemyService.Start()
	if hasStarted then
		return true
	end

	hasStarted = true
	LootService.Start()

	if not hitCallbackRegistered then
		hitCallbackRegistered = true
		CombatService.RegisterTargetHitCallback(handleCombatTargetHit)
	end

	for _, enemyId in ipairs(EnemyConfig.GetEnemyIds()) do
		spawnEnemy(enemyId)
	end
	return true
end

return table.freeze(EnemyService)
