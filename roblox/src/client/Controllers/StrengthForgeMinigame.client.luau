local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ZeroToHeroShared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local remotes = ZeroToHeroShared:WaitForChild("Remotes")
local challengeEvent = remotes:WaitForChild("TrainingStationChallenge")
local actionEvent = remotes:WaitForChild("TrainingStationAction")

local gui = Instance.new("ScreenGui")
gui.Name = "StrengthForgeMinigameGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Enabled = true
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.new(0.5, 0, 1, -24)
panel.Size = UDim2.new(0.92, 0, 0, 174)
panel.BackgroundColor3 = Color3.fromRGB(15, 17, 20)
panel.BackgroundTransparency = 0.03
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(288, 174)
sizeConstraint.MaxSize = Vector2.new(430, 174)
sizeConstraint.Parent = panel

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(255, 142, 42)
panelStroke.Thickness = 2
panelStroke.Transparency = 0.14
panelStroke.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(14, 10)
title.Size = UDim2.new(1, -120, 0, 24)
title.Font = Enum.Font.GothamBlack
title.Text = "Strength Forge"
title.TextColor3 = Color3.fromRGB(255, 230, 188)
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local repsLabel = Instance.new("TextLabel")
repsLabel.Name = "Reps"
repsLabel.AnchorPoint = Vector2.new(1, 0)
repsLabel.BackgroundTransparency = 1
repsLabel.Position = UDim2.new(1, -14, 0, 10)
repsLabel.Size = UDim2.fromOffset(94, 24)
repsLabel.Font = Enum.Font.GothamBold
repsLabel.Text = "0 / 3"
repsLabel.TextColor3 = Color3.fromRGB(255, 184, 78)
repsLabel.TextSize = 17
repsLabel.TextXAlignment = Enum.TextXAlignment.Right
repsLabel.Parent = panel

local bar = Instance.new("Frame")
bar.Name = "TimingBar"
bar.Position = UDim2.fromOffset(18, 48)
bar.Size = UDim2.new(1, -36, 0, 44)
bar.BackgroundColor3 = Color3.fromRGB(38, 42, 48)
bar.BorderSizePixel = 0
bar.ClipsDescendants = true
bar.Parent = panel

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 8)
barCorner.Parent = bar

local targetZone = Instance.new("Frame")
targetZone.Name = "TargetZone"
targetZone.BackgroundColor3 = Color3.fromRGB(255, 142, 42)
targetZone.BackgroundTransparency = 0.2
targetZone.BorderSizePixel = 0
targetZone.Size = UDim2.new(0.24, 0, 1, 0)
targetZone.Parent = bar

local targetStroke = Instance.new("UIStroke")
targetStroke.Color = Color3.fromRGB(255, 231, 159)
targetStroke.Thickness = 2
targetStroke.Transparency = 0.2
targetStroke.Parent = targetZone

local perfectZone = Instance.new("Frame")
perfectZone.Name = "PerfectZone"
perfectZone.BackgroundColor3 = Color3.fromRGB(255, 230, 154)
perfectZone.BackgroundTransparency = 0.05
perfectZone.BorderSizePixel = 0
perfectZone.Size = UDim2.new(0.08, 0, 1, 0)
perfectZone.Parent = bar

local marker = Instance.new("Frame")
marker.Name = "Marker"
marker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
marker.BorderSizePixel = 0
marker.Position = UDim2.new(0, -4, 0, 0)
marker.Size = UDim2.new(0, 8, 1, 0)
marker.ZIndex = 5
marker.Parent = bar

local markerStroke = Instance.new("UIStroke")
markerStroke.Color = Color3.fromRGB(255, 142, 42)
markerStroke.Thickness = 1
markerStroke.Transparency = 0.1
markerStroke.Parent = marker

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.fromOffset(18, 100)
statusLabel.Size = UDim2.new(1, -154, 0, 48)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(230, 236, 242)
statusLabel.TextSize = 16
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Center
statusLabel.Parent = panel

local strikeButton = Instance.new("TextButton")
strikeButton.Name = "StrikeButton"
strikeButton.AnchorPoint = Vector2.new(1, 0)
strikeButton.Position = UDim2.new(1, -18, 0, 104)
strikeButton.Size = UDim2.fromOffset(118, 44)
strikeButton.BackgroundColor3 = Color3.fromRGB(255, 142, 42)
strikeButton.BorderSizePixel = 0
strikeButton.Font = Enum.Font.GothamBlack
strikeButton.Text = "Strike"
strikeButton.TextColor3 = Color3.fromRGB(18, 12, 8)
strikeButton.TextSize = 18
strikeButton.Parent = panel

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = strikeButton

local activeChallenge = nil
local hideToken = 0
local lastSubmitAt = 0

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

local function getAnchorPosition(anchor)
	if anchor == nil then
		return nil
	end

	if anchor:IsA("BasePart") then
		return anchor.Position
	end

	if anchor:IsA("Model") then
		return anchor:GetPivot().Position
	end

	return nil
end

local function getRootPosition()
	local character = player.Character
	if character == nil then
		return nil
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	return root and root.Position or nil
end

local function setTargetVisual(target)
	if target == nil then
		return
	end

	local center = tonumber(target.Center) or 0.5
	local width = tonumber(target.Width) or 0.24
	local perfectWidth = tonumber(target.PerfectWidth) or 0.08

	targetZone.Position = UDim2.new(center - (width / 2), 0, 0, 0)
	targetZone.Size = UDim2.new(width, 0, 1, 0)
	perfectZone.Position = UDim2.new(center - (perfectWidth / 2), 0, 0, 0)
	perfectZone.Size = UDim2.new(perfectWidth, 0, 1, 0)
end

local function getCurrentTarget()
	if activeChallenge == nil then
		return nil
	end

	local index = math.clamp(activeChallenge.SuccessCount + 1, 1, #activeChallenge.TargetZones)
	return activeChallenge.TargetZones[index]
end

local function setRepsText()
	if activeChallenge == nil then
		repsLabel.Text = "0 / 3"
		return
	end

	repsLabel.Text = string.format("%d / %d", activeChallenge.SuccessCount, activeChallenge.RequiredSuccesses)
end

local function hidePanelSoon(delaySeconds)
	hideToken += 1
	local token = hideToken

	task.delay(delaySeconds, function()
		if token == hideToken then
			panel.Visible = false
			activeChallenge = nil
		end
	end)
end

local function showNotice(message, color)
	hideToken += 1
	activeChallenge = nil
	panel.Visible = true
	statusLabel.Text = message
	statusLabel.TextColor3 = color or Color3.fromRGB(230, 236, 242)
	strikeButton.AutoButtonColor = false
	strikeButton.Active = false
	marker.Position = UDim2.new(0, -4, 0, 0)
	hidePanelSoon(1.25)
end

local function startChallenge(payload)
	hideToken += 1

	activeChallenge = {
		ChallengeId = payload.ChallengeId,
		StationId = payload.StationId,
		ServerStartTime = payload.ServerStartTime,
		MarkerPeriodSeconds = payload.MarkerPeriodSeconds,
		RequiredSuccesses = payload.RequiredSuccesses,
		MaxAttempts = payload.MaxAttempts,
		ChallengeTimeoutSeconds = payload.ChallengeTimeoutSeconds,
		InteractionRange = payload.InteractionRange,
		AnchorPath = payload.AnchorPath,
		TargetZones = payload.TargetZones or {},
		SuccessCount = 0,
		Attempts = 0,
	}

	panel.Visible = true
	strikeButton.Active = true
	strikeButton.AutoButtonColor = true
	statusLabel.Text = "Rep 1"
	statusLabel.TextColor3 = Color3.fromRGB(230, 236, 242)
	setRepsText()
	setTargetVisual(getCurrentTarget())
end

local function submitStrike()
	if activeChallenge == nil then
		return
	end

	local now = os.clock()
	if now - lastSubmitAt < 0.12 then
		return
	end

	lastSubmitAt = now
	actionEvent:FireServer({
		Type = "Submit",
		ChallengeId = activeChallenge.ChallengeId,
	})
end

local function cancelChallenge(reason)
	if activeChallenge == nil then
		return
	end

	actionEvent:FireServer({
		Type = "Cancel",
		ChallengeId = activeChallenge.ChallengeId,
		Reason = reason,
	})
	activeChallenge = nil
	panel.Visible = false
end

local function handleRepResult(payload)
	if activeChallenge == nil or payload.ChallengeId ~= activeChallenge.ChallengeId then
		return
	end

	activeChallenge.SuccessCount = payload.SuccessCount or activeChallenge.SuccessCount
	activeChallenge.Attempts = payload.Attempts or activeChallenge.Attempts
	setRepsText()
	setTargetVisual(getCurrentTarget())

	if payload.Success then
		statusLabel.Text = tostring(payload.Rating or "Hit")
		statusLabel.TextColor3 = Color3.fromRGB(255, 213, 126)
		TweenService:Create(panelStroke, TweenInfo.new(0.12), {
			Transparency = 0,
		}):Play()
		task.delay(0.18, function()
			if panelStroke.Parent then
				TweenService:Create(panelStroke, TweenInfo.new(0.18), {
					Transparency = 0.14,
				}):Play()
			end
		end)
	else
		statusLabel.Text = "Miss"
		statusLabel.TextColor3 = Color3.fromRGB(255, 112, 96)
	end
end

local function handleChallengePayload(payload)
	if typeof(payload) ~= "table" then
		return
	end

	if payload.Type == "Started" then
		startChallenge(payload)
	elseif payload.Type == "RepResult" then
		handleRepResult(payload)
	elseif payload.Type == "Completed" then
		if activeChallenge and payload.ChallengeId == activeChallenge.ChallengeId then
			statusLabel.Text = "Set complete"
			statusLabel.TextColor3 = Color3.fromRGB(255, 213, 126)
			hidePanelSoon(0.45)
		end
	elseif payload.Type == "Failed" then
		showNotice("Set failed", Color3.fromRGB(255, 112, 96))
	elseif payload.Type == "Cancelled" then
		panel.Visible = false
		activeChallenge = nil
	elseif payload.Type == "Rejected" then
		if payload.Error == "Cooldown" then
			showNotice("Cooling down", Color3.fromRGB(255, 184, 78))
		else
			showNotice("Not ready", Color3.fromRGB(255, 112, 96))
		end
	end
end

strikeButton.Activated:Connect(submitStrike)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or activeChallenge == nil then
		return
	end

	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then
		submitStrike()
	end
end)

RunService.RenderStepped:Connect(function()
	if activeChallenge == nil then
		return
	end

	local elapsed = math.max(0, Workspace:GetServerTimeNow() - activeChallenge.ServerStartTime)
	local phase = (elapsed / activeChallenge.MarkerPeriodSeconds) % 1
	local markerPosition = phase <= 0.5 and phase * 2 or (1 - phase) * 2
	marker.Position = UDim2.new(markerPosition, -4, 0, 0)

	local anchor = resolvePath(activeChallenge.AnchorPath)
	local anchorPosition = getAnchorPosition(anchor)
	local rootPosition = getRootPosition()
	if anchorPosition and rootPosition then
		local allowedRange = (tonumber(activeChallenge.InteractionRange) or 0) + 6
		if (rootPosition - anchorPosition).Magnitude > allowedRange then
			cancelChallenge("LeftRange")
		end
	end
end)

player.CharacterRemoving:Connect(function()
	cancelChallenge("CharacterRemoving")
end)

challengeEvent.OnClientEvent:Connect(handleChallengePayload)
