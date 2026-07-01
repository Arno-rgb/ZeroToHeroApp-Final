local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ZeroToHeroShared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local CombatActionConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("CombatActionConfig"))
local remotes = ZeroToHeroShared:WaitForChild("Remotes")
local remoteNames = CombatActionConfig.GetRemoteNames()
local actionEvent = remotes:WaitForChild(remoteNames.Action)
local feedbackEvent = remotes:WaitForChild(remoteNames.Feedback)

local TARGET_SEARCH_RANGE = 14
local COMBAT_HUD_RANGE = 64
local COMBAT_HUD_HOLD_SECONDS = 7
local DAMAGE_FLOAT_LIFETIME_SECONDS = 0.8
local IMPACT_EFFECT_LIFETIME_SECONDS = 0.34
local HIT_REACTION_STUDS = 0.55
local dodgeConfig = CombatActionConfig.GetAction("Dodge") or {}
local dodgeStaminaCost = tonumber(dodgeConfig.StaminaCost) or 0

local gui = Instance.new("ScreenGui")
gui.Name = "CombatControllerGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Enabled = true
gui.DisplayOrder = 24
gui:SetAttribute("R3CombatPresentationPolish", true)
gui:SetAttribute("DamageFloatCount", 0)
gui:SetAttribute("ImpactEffectCount", 0)
gui:SetAttribute("SwingTrailCount", 0)
gui.Parent = playerGui

local resourcePanel = Instance.new("Frame")
resourcePanel.Name = "ResourcePanel"
resourcePanel.Position = UDim2.fromOffset(14, 16)
resourcePanel.Size = UDim2.fromOffset(312, 86)
resourcePanel.BackgroundColor3 = Color3.fromRGB(7, 10, 15)
resourcePanel.BackgroundTransparency = 0.04
resourcePanel.BorderSizePixel = 0
resourcePanel.Visible = false
resourcePanel.Parent = gui

local resourceSize = Instance.new("UISizeConstraint")
resourceSize.MinSize = Vector2.new(260, 78)
resourceSize.MaxSize = Vector2.new(350, 94)
resourceSize.Parent = resourcePanel

local resourceCorner = Instance.new("UICorner")
resourceCorner.CornerRadius = UDim.new(0, 8)
resourceCorner.Parent = resourcePanel

local resourceStroke = Instance.new("UIStroke")
resourceStroke.Color = Color3.fromRGB(255, 255, 255)
resourceStroke.Thickness = 1.5
resourceStroke.Transparency = 0.58
resourceStroke.Parent = resourcePanel

local function createBar(name, yOffset, labelText, fillColor)
	local row = Instance.new("Frame")
	row.Name = name
	row.BackgroundTransparency = 1
	row.Position = UDim2.fromOffset(12, yOffset)
	row.Size = UDim2.new(1, -24, 0, 30)
	row.Parent = resourcePanel

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(0, 0)
	label.Size = UDim2.fromOffset(50, 18)
	label.Font = Enum.Font.GothamBlack
	label.Text = labelText
	label.TextColor3 = Color3.fromRGB(238, 242, 247)
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local value = Instance.new("TextLabel")
	value.Name = "Value"
	value.AnchorPoint = Vector2.new(1, 0)
	value.BackgroundTransparency = 1
	value.Position = UDim2.new(1, 0, 0, 0)
	value.Size = UDim2.fromOffset(128, 18)
	value.Font = Enum.Font.GothamBold
	value.Text = "0 / 0"
	value.TextColor3 = Color3.fromRGB(220, 227, 235)
	value.TextSize = 12
	value.TextXAlignment = Enum.TextXAlignment.Right
	value.Parent = row

	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Position = UDim2.fromOffset(0, 19)
	track.Size = UDim2.new(1, 0, 0, 9)
	track.BackgroundColor3 = Color3.fromRGB(39, 44, 52)
	track.BorderSizePixel = 0
	track.Parent = row

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 6)
	trackCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = fillColor
	fill.BorderSizePixel = 0
	fill.Parent = track

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 6)
	fillCorner.Parent = fill

	return {
		Row = row,
		Value = value,
		Fill = fill,
	}
end

local hpBar = createBar("HP", 10, "HP", Color3.fromRGB(236, 83, 83))
local staminaBar = createBar("Stamina", 48, "STA", Color3.fromRGB(72, 210, 147))

local controls = Instance.new("Frame")
controls.Name = "Controls"
controls.AnchorPoint = Vector2.new(1, 1)
controls.Position = UDim2.new(1, -18, 1, -20)
controls.Size = UDim2.fromOffset(316, 208)
controls.BackgroundTransparency = 1
controls.Visible = false
controls.Parent = gui

local controlsSize = Instance.new("UISizeConstraint")
controlsSize.MinSize = Vector2.new(316, 208)
controlsSize.MaxSize = Vector2.new(316, 208)
controlsSize.Parent = controls

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.AnchorPoint = Vector2.new(1, 1)
statusLabel.Position = UDim2.new(1, -18, 1, -236)
statusLabel.Size = UDim2.fromOffset(300, 36)
statusLabel.BackgroundColor3 = Color3.fromRGB(8, 11, 16)
statusLabel.BackgroundTransparency = 0.08
statusLabel.BorderSizePixel = 0
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(238, 242, 247)
statusLabel.TextSize = 14
statusLabel.TextWrapped = true
statusLabel.Visible = false
statusLabel.Parent = gui

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

local targetPanel = Instance.new("Frame")
targetPanel.Name = "TargetPanel"
targetPanel.AnchorPoint = Vector2.new(1, 1)
targetPanel.Position = UDim2.new(1, -18, 1, -282)
targetPanel.Size = UDim2.fromOffset(300, 58)
targetPanel.BackgroundColor3 = Color3.fromRGB(10, 13, 18)
targetPanel.BackgroundTransparency = 0.05
targetPanel.BorderSizePixel = 0
targetPanel.Visible = false
targetPanel.Parent = gui

local targetPanelSize = Instance.new("UISizeConstraint")
targetPanelSize.MinSize = Vector2.new(260, 54)
targetPanelSize.MaxSize = Vector2.new(320, 62)
targetPanelSize.Parent = targetPanel

local targetPanelCorner = Instance.new("UICorner")
targetPanelCorner.CornerRadius = UDim.new(0, 8)
targetPanelCorner.Parent = targetPanel

local targetPanelStroke = Instance.new("UIStroke")
targetPanelStroke.Color = Color3.fromRGB(255, 170, 76)
targetPanelStroke.Thickness = 1.6
targetPanelStroke.Transparency = 0.22
targetPanelStroke.Parent = targetPanel

local targetName = Instance.new("TextLabel")
targetName.Name = "TargetName"
targetName.BackgroundTransparency = 1
targetName.Position = UDim2.fromOffset(12, 6)
targetName.Size = UDim2.new(1, -92, 0, 20)
targetName.Font = Enum.Font.GothamBlack
targetName.Text = "Target"
targetName.TextColor3 = Color3.fromRGB(255, 236, 201)
targetName.TextSize = 14
targetName.TextTruncate = Enum.TextTruncate.AtEnd
targetName.TextXAlignment = Enum.TextXAlignment.Left
targetName.Parent = targetPanel

local targetRange = Instance.new("TextLabel")
targetRange.Name = "Range"
targetRange.AnchorPoint = Vector2.new(1, 0)
targetRange.BackgroundTransparency = 1
targetRange.Position = UDim2.new(1, -12, 0, 7)
targetRange.Size = UDim2.fromOffset(74, 18)
targetRange.Font = Enum.Font.GothamBold
targetRange.Text = ""
targetRange.TextColor3 = Color3.fromRGB(206, 217, 230)
targetRange.TextSize = 11
targetRange.TextXAlignment = Enum.TextXAlignment.Right
targetRange.Parent = targetPanel

local targetHealthTrack = Instance.new("Frame")
targetHealthTrack.Name = "HealthTrack"
targetHealthTrack.Position = UDim2.fromOffset(12, 32)
targetHealthTrack.Size = UDim2.new(1, -24, 0, 11)
targetHealthTrack.BackgroundColor3 = Color3.fromRGB(57, 33, 36)
targetHealthTrack.BorderSizePixel = 0
targetHealthTrack.Parent = targetPanel

local targetHealthTrackCorner = Instance.new("UICorner")
targetHealthTrackCorner.CornerRadius = UDim.new(0, 6)
targetHealthTrackCorner.Parent = targetHealthTrack

local targetHealthFill = Instance.new("Frame")
targetHealthFill.Name = "Fill"
targetHealthFill.Size = UDim2.fromScale(1, 1)
targetHealthFill.BackgroundColor3 = Color3.fromRGB(241, 87, 87)
targetHealthFill.BorderSizePixel = 0
targetHealthFill.Parent = targetHealthTrack

local targetHealthFillCorner = Instance.new("UICorner")
targetHealthFillCorner.CornerRadius = UDim.new(0, 6)
targetHealthFillCorner.Parent = targetHealthFill

local targetHealthText = Instance.new("TextLabel")
targetHealthText.Name = "HealthText"
targetHealthText.BackgroundTransparency = 1
targetHealthText.Position = UDim2.fromOffset(12, 43)
targetHealthText.Size = UDim2.new(1, -24, 0, 12)
targetHealthText.Font = Enum.Font.GothamBold
targetHealthText.Text = ""
targetHealthText.TextColor3 = Color3.fromRGB(232, 238, 244)
targetHealthText.TextSize = 10
targetHealthText.TextXAlignment = Enum.TextXAlignment.Right
targetHealthText.Parent = targetPanel

local function createButton(name, text, position, size, color)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = color
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Font = Enum.Font.GothamBlack
	button.Text = text
	button.TextColor3 = Color3.fromRGB(245, 248, 252)
	button.TextSize = size.X.Offset >= 72 and 16 or 13
	button.TextScaled = true
	button.TextWrapped = true
	button.Parent = controls

	local corner = Instance.new("UICorner")
	corner.CornerRadius = size.X.Offset == size.Y.Offset and UDim.new(1, 0) or UDim.new(0, 10)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 232, 188)
	stroke.Thickness = size.X.Offset >= 76 and 2 or 1.5
	stroke.Transparency = 0.22
	stroke.Parent = button

	local textConstraint = Instance.new("UITextSizeConstraint")
	textConstraint.MinTextSize = 10
	textConstraint.MaxTextSize = size.X.Offset >= 72 and 16 or 13
	textConstraint.Parent = button

	local cooldown = Instance.new("TextLabel")
	cooldown.Name = "Cooldown"
	cooldown.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
	cooldown.BackgroundTransparency = 0.18
	cooldown.BorderSizePixel = 0
	cooldown.Size = UDim2.fromScale(1, 1)
	cooldown.Font = Enum.Font.GothamBlack
	cooldown.Text = ""
	cooldown.TextColor3 = Color3.fromRGB(245, 248, 252)
	cooldown.TextSize = 16
	cooldown.TextScaled = true
	cooldown.Visible = false
	cooldown.ZIndex = button.ZIndex + 2
	cooldown.Parent = button

	local cooldownCorner = Instance.new("UICorner")
	cooldownCorner.CornerRadius = corner.CornerRadius
	cooldownCorner.Parent = cooldown

	local cooldownTextConstraint = Instance.new("UITextSizeConstraint")
	cooldownTextConstraint.MinTextSize = 10
	cooldownTextConstraint.MaxTextSize = 16
	cooldownTextConstraint.Parent = cooldown

	return {
		Button = button,
		Cooldown = cooldown,
		BaseColor = color,
	}
end

local attack = createButton("AttackButton", "ATK", UDim2.fromOffset(226, 100), UDim2.fromOffset(82, 82), Color3.fromRGB(110, 62, 31))
local guard = createButton("GuardButton", "GUARD", UDim2.fromOffset(148, 112), UDim2.fromOffset(66, 66), Color3.fromRGB(36, 91, 137))
local dodge = createButton("DodgeButton", "DODGE", UDim2.fromOffset(70, 112), UDim2.fromOffset(66, 66), Color3.fromRGB(35, 111, 72))
local interact = createButton("InteractButton", "USE", UDim2.fromOffset(8, 60), UDim2.fromOffset(58, 58), Color3.fromRGB(75, 81, 92))
local skill1 = createButton("Skill1Button", "SK1", UDim2.fromOffset(104, 32), UDim2.fromOffset(58, 58), Color3.fromRGB(42, 72, 117))
local skill2 = createButton("Skill2Button", "SK2", UDim2.fromOffset(170, 32), UDim2.fromOffset(58, 58), Color3.fromRGB(42, 72, 117))
local ultimate = createButton("UltimateButton", "ULT", UDim2.fromOffset(240, 26), UDim2.fromOffset(64, 64), Color3.fromRGB(91, 54, 145))

local disabledButtons = { interact, skill1, skill2, ultimate }
for _, wrapped in ipairs(disabledButtons) do
	wrapped.Button.Active = false
	wrapped.Button.AutoButtonColor = false
	wrapped.Button.BackgroundTransparency = 0.28
	wrapped.Cooldown.Visible = true
	wrapped.Cooldown.Text = wrapped == interact and "..." or "LOCK"
	wrapped.Cooldown.TextSize = wrapped == interact and 13 or 11
	wrapped.Cooldown.BackgroundTransparency = 0.34
end

local guardActive = false
local hideStatusToken = 0
local lastCombatFeedbackAt = 0
local activeTarget = nil
local trainingStatsHudWasEnabled = nil
local hitReactionTokens = {}
local updateHudErrorReported = false

local targetHighlight = Instance.new("Highlight")
targetHighlight.Name = "CombatTargetHighlight"
targetHighlight.Enabled = false
targetHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
targetHighlight.FillTransparency = 1
targetHighlight.OutlineColor = Color3.fromRGB(255, 173, 76)
targetHighlight.OutlineTransparency = 0.08
targetHighlight.Parent = Workspace

gui.Destroying:Connect(function()
	if targetHighlight.Parent then
		targetHighlight:Destroy()
	end
end)

local function showStatus(text, color)
	hideStatusToken += 1
	local token = hideStatusToken
	lastCombatFeedbackAt = os.clock()

	statusLabel.Text = text
	statusLabel.TextColor3 = color or Color3.fromRGB(238, 242, 247)
	statusLabel.Visible = true

	task.delay(1.15, function()
		if token == hideStatusToken then
			statusLabel.Visible = false
		end
	end)
end

local function getRoot()
	local character = player.Character
	if character == nil then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	local character = player.Character
	if character == nil then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function getEnemyArea()
	local ascensionGrounds = Workspace:FindFirstChild("AscensionGrounds")
	return ascensionGrounds and ascensionGrounds:FindFirstChild("EnemyArea") or nil
end

local function getTargetBody(model)
	local body = model:FindFirstChild("Body")
	if body and body:IsA("BasePart") then
		return body
	end

	if model.PrimaryPart then
		return model.PrimaryPart
	end

	return model:FindFirstChildWhichIsA("BasePart", true)
end

local function getTargetDisplayName(model)
	if typeof(model) ~= "Instance" then
		return "Target"
	end

	local displayName = model:GetAttribute("DisplayName")
	if typeof(displayName) == "string" and displayName ~= "" then
		return displayName
	end

	return model.Name
end

local function getHealthValue(model)
	if typeof(model) ~= "Instance" then
		return nil
	end

	local health = model:FindFirstChild("Health")
	if health and (health:IsA("IntValue") or health:IsA("NumberValue")) then
		return health
	end

	return nil
end

local function getMaxHealth(model, health)
	if typeof(model) ~= "Instance" then
		return math.max(1, tonumber(health and health.Value) or 1)
	end

	local maxHealth = model:FindFirstChild("MaxHealth")
	if maxHealth and (maxHealth:IsA("IntValue") or maxHealth:IsA("NumberValue")) then
		return math.max(1, tonumber(maxHealth.Value) or 1)
	end

	local attributeValue = tonumber(model:GetAttribute("MaxHealth"))
	if attributeValue then
		return math.max(1, attributeValue)
	end

	return math.max(1, tonumber(health and health.Value) or 1)
end

local function findNearestTarget(maxRange)
	local root = getRoot()
	local enemyArea = getEnemyArea()
	if root == nil or enemyArea == nil then
		return nil, math.huge
	end

	local nearestTarget = nil
	local nearestDistance = maxRange or TARGET_SEARCH_RANGE

	for _, child in ipairs(enemyArea:GetChildren()) do
		if child:IsA("Model") then
			local health = getHealthValue(child)
			local body = getTargetBody(child)
			if health and body and tonumber(health.Value) and health.Value > 0 then
				local distance = (body.Position - root.Position).Magnitude
				if distance <= nearestDistance then
					nearestDistance = distance
					nearestTarget = child
				end
			end
		end
	end

	return nearestTarget, nearestDistance
end

local function getCombatHudState()
	local target, distance = findNearestTarget(COMBAT_HUD_RANGE)
	local isVisible = distance <= COMBAT_HUD_RANGE or os.clock() - lastCombatFeedbackAt < COMBAT_HUD_HOLD_SECONDS or guardActive
	return isVisible, target, distance
end

local function setTrainingStatsHudSuppressed(isSuppressed)
	local trainingStatsGui = playerGui:FindFirstChild("TrainingStatsHudGui")
	if trainingStatsGui == nil or not trainingStatsGui:IsA("ScreenGui") then
		return
	end

	if isSuppressed then
		if trainingStatsHudWasEnabled == nil then
			trainingStatsHudWasEnabled = trainingStatsGui.Enabled
		end
		trainingStatsGui.Enabled = false
	elseif trainingStatsHudWasEnabled ~= nil then
		trainingStatsGui.Enabled = trainingStatsHudWasEnabled
		trainingStatsHudWasEnabled = nil
	end
end

local function clearTargetPresentation()
	activeTarget = nil
	targetPanel.Visible = false
	targetHighlight.Enabled = false
	targetHighlight.Adornee = nil
	gui:SetAttribute("TargetPanelVisible", false)
	gui:SetAttribute("CurrentTargetName", "")
	gui:SetAttribute("CurrentTargetHP", 0)
	gui:SetAttribute("CurrentTargetMaxHP", 0)
end

local function updateTargetPresentation(target, distance, isVisible)
	if not isVisible or target == nil or target.Parent == nil then
		clearTargetPresentation()
		return
	end

	local health = getHealthValue(target)
	if health == nil or health.Value <= 0 then
		clearTargetPresentation()
		return
	end

	local currentHealth = math.max(0, tonumber(health.Value) or 0)
	local maximumHealth = getMaxHealth(target, health)
	local ratio = math.clamp(currentHealth / maximumHealth, 0, 1)
	local displayName = getTargetDisplayName(target)
	local roundedDistance = math.floor((tonumber(distance) or 0) + 0.5)

	activeTarget = target
	targetName.Text = displayName
	targetRange.Text = distance <= TARGET_SEARCH_RANGE and "IN RANGE" or string.format("%d st", roundedDistance)
	targetRange.TextColor3 = distance <= TARGET_SEARCH_RANGE and Color3.fromRGB(173, 255, 188) or Color3.fromRGB(206, 217, 230)
	targetHealthFill.Size = UDim2.fromScale(ratio, 1)
	targetHealthText.Text = string.format("%d / %d HP", math.floor(currentHealth + 0.5), math.floor(maximumHealth + 0.5))
	targetPanel.Visible = true
	targetHighlight.Adornee = target
	targetHighlight.Enabled = true

	gui:SetAttribute("TargetPanelVisible", true)
	gui:SetAttribute("CurrentTargetName", displayName)
	gui:SetAttribute("CurrentTargetHP", math.floor(currentHealth + 0.5))
	gui:SetAttribute("CurrentTargetMaxHP", math.floor(maximumHealth + 0.5))
	gui:SetAttribute("CurrentTargetDistance", roundedDistance)
end

local function getMoveDirection()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = getRoot()

	if humanoid and humanoid.MoveDirection.Magnitude > 0.05 then
		return humanoid.MoveDirection
	end

	if root then
		return root.CFrame.LookVector
	end

	return Vector3.new(0, 0, -1)
end

local function getCombatValue(name, fallback)
	local folder = player:FindFirstChild("CombatState")
	local value = folder and folder:FindFirstChild(name)
	if value and (value:IsA("NumberValue") or value:IsA("BoolValue")) then
		return value.Value
	end

	return fallback
end

local function setBar(bar, current, maximum)
	local cleanMaximum = math.max(1, tonumber(maximum) or 1)
	local cleanCurrent = math.clamp(tonumber(current) or 0, 0, cleanMaximum)
	local ratio = cleanCurrent / cleanMaximum
	bar.Value.Text = string.format("%d / %d", math.floor(cleanCurrent + 0.5), math.floor(cleanMaximum + 0.5))
	bar.Fill.Size = UDim2.fromScale(ratio, 1)
end

local function setButtonEnabled(wrapped, enabled)
	wrapped.Button.Active = enabled
	wrapped.Button.AutoButtonColor = enabled
	wrapped.Button.BackgroundTransparency = enabled and 0 or 0.42
	wrapped.Button.TextTransparency = enabled and 0 or 0.25
end

local function setCooldown(wrapped, milliseconds, fallbackText)
	local seconds = math.max(0, (tonumber(milliseconds) or 0) / 1000)
	if seconds > 0 then
		wrapped.Cooldown.Visible = true
		wrapped.Cooldown.Text = string.format("%.1f", seconds)
		return true
	end

	wrapped.Cooldown.Visible = fallbackText ~= nil
	wrapped.Cooldown.Text = fallbackText or ""
	return false
end

local function pulseButton(wrapped)
	local button = wrapped.Button
	local originalSize = button.Size
	TweenService:Create(button, TweenInfo.new(0.08), {
		Size = originalSize + UDim2.fromOffset(4, 4),
	}):Play()
	task.delay(0.09, function()
		if button.Parent then
			TweenService:Create(button, TweenInfo.new(0.12), {
				Size = originalSize,
			}):Play()
		end
	end)
end

local function requestAttack()
	local target = findNearestTarget(TARGET_SEARCH_RANGE)
	pulseButton(attack)
	actionEvent:FireServer({
		Type = "BasicAttack",
		Target = target,
	})
end

local function setGuard(isActive)
	if guardActive == isActive then
		return
	end

	guardActive = isActive
	guard.Button.BackgroundColor3 = guardActive and Color3.fromRGB(74, 155, 255) or guard.BaseColor
	actionEvent:FireServer({
		Type = "Guard",
		IsActive = guardActive,
	})
end

local function toggleGuard()
	setGuard(not guardActive)
end

local function requestDodge()
	local stamina = tonumber(getCombatValue("Stamina", 0)) or 0
	if stamina < dodgeStaminaCost then
		showStatus("Not enough stamina", Color3.fromRGB(255, 132, 112))
		return
	end

	pulseButton(dodge)
	actionEvent:FireServer({
		Type = "Dodge",
		Direction = getMoveDirection(),
	})
end

local function flashTarget(target)
	if typeof(target) ~= "Instance" then
		return
	end

	local body = getTargetBody(target)
	if body == nil then
		return
	end

	local originalColor = body.Color
	body.Color = Color3.fromRGB(255, 238, 136)
	task.delay(0.12, function()
		if body.Parent then
			body.Color = originalColor
		end
	end)
end

local function incrementGuiCounter(attributeName)
	gui:SetAttribute(attributeName, (tonumber(gui:GetAttribute(attributeName)) or 0) + 1)
end

local function playSwingTrail()
	local root = getRoot()
	if root == nil then
		return
	end

	local marker = Instance.new("Part")
	marker.Name = "LocalSwordTrail"
	marker.Anchored = true
	marker.CanCollide = false
	marker.CanTouch = false
	marker.CanQuery = false
	marker.Transparency = 1
	marker.Size = Vector3.new(0.1, 0.1, 0.1)
	marker.CFrame = root.CFrame * CFrame.new(1.65, 0.35, -3.1)
	marker.Parent = Workspace

	local attachment0 = Instance.new("Attachment")
	attachment0.Name = "TrailTop"
	attachment0.Position = Vector3.new(0, 0.95, 0)
	attachment0.Parent = marker

	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "TrailBottom"
	attachment1.Position = Vector3.new(0, -0.95, 0)
	attachment1.Parent = marker

	local trail = Instance.new("Trail")
	trail.Name = "ConfirmedSwingTrail"
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 208, 116), Color3.fromRGB(255, 128, 74))
	trail.LightEmission = 0.55
	trail.Lifetime = 0.22
	trail.MinLength = 0.04
	trail.FaceCamera = true
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.12),
		NumberSequenceKeypoint.new(0.55, 0.25),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0.18),
	})
	trail.Parent = marker

	TweenService:Create(marker, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = root.CFrame * CFrame.new(-1.35, 0.25, -3.05) * CFrame.Angles(0, 0, math.rad(-28)),
	}):Play()

	incrementGuiCounter("SwingTrailCount")
	task.delay(0.38, function()
		if marker.Parent then
			marker:Destroy()
		end
	end)
end

local function showDamageFloat(target, damage, defeated)
	if typeof(target) ~= "Instance" then
		return
	end

	local body = getTargetBody(target)
	if body == nil then
		return
	end

	local cleanDamage = math.max(0, math.floor((tonumber(damage) or 0) + 0.5))
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DamageFloat"
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.fromOffset(82, 30)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, math.max(2.2, body.Size.Y * 0.55 + 1.25), 0)
	billboard.MaxDistance = 86
	billboard.Parent = body

	local label = Instance.new("TextLabel")
	label.Name = "Value"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.Text = string.format("-%d", cleanDamage)
	label.TextColor3 = defeated and Color3.fromRGB(255, 236, 150) or Color3.fromRGB(255, 180, 106)
	label.TextSize = defeated and 24 or 22
	label.TextStrokeColor3 = Color3.fromRGB(24, 12, 8)
	label.TextStrokeTransparency = 0.15
	label.Parent = billboard

	local startOffset = billboard.StudsOffsetWorldSpace
	TweenService:Create(billboard, TweenInfo.new(DAMAGE_FLOAT_LIFETIME_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffsetWorldSpace = startOffset + Vector3.new(0, 1.25, 0),
	}):Play()
	TweenService:Create(label, TweenInfo.new(DAMAGE_FLOAT_LIFETIME_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()

	incrementGuiCounter("DamageFloatCount")
	gui:SetAttribute("LastDamageAmount", cleanDamage)
	gui:SetAttribute("LastDamageTarget", getTargetDisplayName(target))
	task.delay(DAMAGE_FLOAT_LIFETIME_SECONDS + 0.05, function()
		if billboard.Parent then
			billboard:Destroy()
		end
	end)
end

local function playImpactEffect(target)
	if typeof(target) ~= "Instance" then
		return
	end

	local body = getTargetBody(target)
	if body == nil then
		return
	end

	local burst = Instance.new("Part")
	burst.Name = "LocalImpactBurst"
	burst.Shape = Enum.PartType.Ball
	burst.Anchored = true
	burst.CanCollide = false
	burst.CanTouch = false
	burst.CanQuery = false
	burst.Material = Enum.Material.Neon
	burst.Color = Color3.fromRGB(255, 186, 86)
	burst.Size = Vector3.new(0.28, 0.28, 0.28)
	burst.Transparency = 0.12
	burst.CFrame = body.CFrame
	burst.Parent = Workspace

	local light = Instance.new("PointLight")
	light.Name = "ImpactLight"
	light.Brightness = 0.65
	light.Range = 7
	light.Color = burst.Color
	light.Parent = burst

	TweenService:Create(burst, TweenInfo.new(IMPACT_EFFECT_LIFETIME_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(2.15, 2.15, 2.15),
		Transparency = 1,
	}):Play()
	TweenService:Create(light, TweenInfo.new(IMPACT_EFFECT_LIFETIME_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = 0,
	}):Play()

	incrementGuiCounter("ImpactEffectCount")
	task.delay(IMPACT_EFFECT_LIFETIME_SECONDS + 0.05, function()
		if burst.Parent then
			burst:Destroy()
		end
	end)
end

local function playEnemyHitReaction(target)
	if typeof(target) ~= "Instance" then
		return
	end

	local body = getTargetBody(target)
	local root = getRoot()
	if body == nil or root == nil then
		return
	end

	local away = body.Position - root.Position
	if away.Magnitude < 0.05 then
		away = -root.CFrame.LookVector
	end
	away = away.Unit

	local originalCFrame = body.CFrame
	local token = (hitReactionTokens[body] or 0) + 1
	hitReactionTokens[body] = token

	local recoil = TweenService:Create(body, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = originalCFrame + away * HIT_REACTION_STUDS,
	})
	recoil:Play()
	recoil.Completed:Connect(function()
		if hitReactionTokens[body] ~= token or body.Parent == nil then
			return
		end

		TweenService:Create(body, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = originalCFrame,
		}):Play()
	end)
end

local function handleFeedback(payload)
	if typeof(payload) ~= "table" then
		return
	end

	lastCombatFeedbackAt = os.clock()

	if payload.Success == false then
		local message = tostring(payload.Error or "Action failed")
		if payload.Error == "Cooldown" and payload.CooldownRemaining then
			message = string.format("Cooling down %.1fs", payload.CooldownRemaining)
		elseif payload.Error == "NotEnoughStamina" then
			message = "Not enough stamina"
		elseif payload.Error == "OutOfRange" or payload.Error == "InvalidTarget" then
			message = "No target in range"
		end

		showStatus(message, Color3.fromRGB(255, 132, 112))
		return
	end

	if payload.Type == "BasicAttack" then
		playSwingTrail()
		flashTarget(payload.Target)
		showDamageFloat(payload.Target, payload.Damage, payload.Defeated == true)
		playImpactEffect(payload.Target)
		playEnemyHitReaction(payload.Target)
		showStatus(
			string.format("%s -%d", tostring(payload.TargetName or "Target"), tonumber(payload.Damage) or 0),
			Color3.fromRGB(255, 220, 126)
		)
	elseif payload.Type == "Guard" then
		guardActive = payload.IsGuarding == true
		guard.Button.BackgroundColor3 = guardActive and Color3.fromRGB(74, 155, 255) or guard.BaseColor
		showStatus(guardActive and "Guard up" or "Guard down", Color3.fromRGB(162, 216, 255))
	elseif payload.Type == "Dodge" then
		guardActive = false
		guard.Button.BackgroundColor3 = guard.BaseColor
		showStatus(
			string.format("Dodge %.0f / %.0f stamina", tonumber(payload.Stamina) or 0, tonumber(payload.MaxStamina) or 0),
			Color3.fromRGB(172, 255, 201)
		)
	elseif payload.Type == "IncomingDamage" then
		if payload.Dodged then
			showStatus("Dodged", Color3.fromRGB(172, 255, 201))
		elseif (tonumber(payload.GuardReduction) or 0) > 0 then
			showStatus(
				string.format("Guarded -%d", tonumber(payload.FinalDamage) or 0),
				Color3.fromRGB(162, 216, 255)
			)
		else
			showStatus(
				string.format("Hit -%d", tonumber(payload.FinalDamage) or 0),
				Color3.fromRGB(255, 132, 112)
			)
		end
	end
end

local function updateHud()
	local humanoid = getHumanoid()
	local hp = getCombatValue("HP", humanoid and humanoid.Health or 0)
	local maxHP = getCombatValue("MaxHP", humanoid and humanoid.MaxHealth or 100)
	local stamina = getCombatValue("Stamina", 0)
	local maxStamina = getCombatValue("MaxStamina", 100)
	local attackCooldownMs = getCombatValue("AttackCooldownMs", 0)
	local dodgeCooldownMs = getCombatValue("DodgeCooldownMs", 0)

	setBar(hpBar, hp, maxHP)
	setBar(staminaBar, stamina, maxStamina)

	local attackCoolingDown = setCooldown(attack, attackCooldownMs)
	setButtonEnabled(attack, not attackCoolingDown)

	local dodgeCoolingDown = setCooldown(dodge, dodgeCooldownMs, stamina < dodgeStaminaCost and "STA" or nil)
	setButtonEnabled(dodge, not dodgeCoolingDown and stamina >= dodgeStaminaCost)

	guardActive = getCombatValue("IsGuarding", guardActive) == true
	guard.Button.BackgroundColor3 = guardActive and Color3.fromRGB(74, 155, 255) or guard.BaseColor

	local visible, target, distance = getCombatHudState()
	resourcePanel.Visible = visible
	controls.Visible = visible
	updateTargetPresentation(target, distance, visible)
	setTrainingStatsHudSuppressed(visible)
	gui:SetAttribute("CombatHudVisible", visible)
end

attack.Button.Activated:Connect(requestAttack)
guard.Button.Activated:Connect(toggleGuard)
dodge.Button.Activated:Connect(requestDodge)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		requestAttack()
	elseif input.KeyCode == Enum.KeyCode.F then
		setGuard(true)
	elseif input.KeyCode == Enum.KeyCode.Q then
		requestDodge()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		setGuard(false)
	end
end)

player.CharacterRemoving:Connect(function()
	if guardActive then
		setGuard(false)
	end
	setTrainingStatsHudSuppressed(false)
	clearTargetPresentation()
end)

local function runUpdateHud()
	local ok, err = pcall(updateHud)
	if ok then
		return
	end

	gui:SetAttribute("LastHudError", tostring(err))
	if not updateHudErrorReported then
		updateHudErrorReported = true
		warn("[CombatController] updateHud failed:", err)
	end
end

feedbackEvent.OnClientEvent:Connect(handleFeedback)
task.defer(runUpdateHud)
RunService.Heartbeat:Connect(runUpdateHud)
