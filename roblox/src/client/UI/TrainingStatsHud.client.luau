local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ZeroToHeroShared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local StatConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("StatConfig"))

local STAT_IDS = StatConfig.GetStatIds()
local ROW_HEIGHT = 48
local ROW_PADDING = 7

local gui = Instance.new("ScreenGui")
gui.Name = "TrainingStatsHudGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 12
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0, 0)
panel.Position = UDim2.fromOffset(12, 12)
panel.Size = UDim2.new(0.92, 0, 0, 346)
panel.BackgroundColor3 = Color3.fromRGB(7, 11, 17)
panel.BackgroundTransparency = 0.02
panel.BorderSizePixel = 0
panel.Parent = gui

local panelConstraint = Instance.new("UISizeConstraint")
panelConstraint.MinSize = Vector2.new(300, 308)
panelConstraint.MaxSize = Vector2.new(442, 346)
panelConstraint.Parent = panel

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(255, 184, 78)
panelStroke.Thickness = 2.5
panelStroke.Transparency = 0.1
panelStroke.Parent = panel

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundTransparency = 1
header.Position = UDim2.fromOffset(14, 12)
header.Size = UDim2.new(1, -28, 0, 36)
header.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(0, 0)
title.Size = UDim2.new(1, -120, 1, 0)
title.Font = Enum.Font.GothamBlack
title.Text = "Training Stats"
title.TextColor3 = Color3.fromRGB(255, 232, 188)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local rankLabel = Instance.new("TextLabel")
rankLabel.Name = "Rank"
rankLabel.AnchorPoint = Vector2.new(1, 0)
rankLabel.BackgroundColor3 = Color3.fromRGB(22, 28, 34)
rankLabel.BackgroundTransparency = 0
rankLabel.BorderSizePixel = 0
rankLabel.Position = UDim2.new(1, 0, 0, 2)
rankLabel.Size = UDim2.fromOffset(112, 30)
rankLabel.Font = Enum.Font.GothamBold
rankLabel.Text = "Rank 0"
rankLabel.TextColor3 = Color3.fromRGB(255, 213, 126)
rankLabel.TextSize = 15
rankLabel.Parent = header

local rankCorner = Instance.new("UICorner")
rankCorner.CornerRadius = UDim.new(0, 7)
rankCorner.Parent = rankLabel

local headerRule = Instance.new("Frame")
headerRule.Name = "HeaderRule"
headerRule.BackgroundColor3 = Color3.fromRGB(255, 184, 78)
headerRule.BackgroundTransparency = 0.32
headerRule.BorderSizePixel = 0
headerRule.Position = UDim2.fromOffset(14, 50)
headerRule.Size = UDim2.new(1, -28, 0, 1)
headerRule.Parent = panel

local list = Instance.new("Frame")
list.Name = "Rows"
list.BackgroundTransparency = 1
list.Position = UDim2.fromOffset(14, 56)
list.Size = UDim2.new(1, -28, 0, (#STAT_IDS * ROW_HEIGHT) + ((#STAT_IDS - 1) * ROW_PADDING))
list.Parent = panel

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, ROW_PADDING)
listLayout.Parent = list

local rows = {}
local statConnections = {}
local rankConnections = {}

local function getStatColor(statId)
	local statDefinition = StatConfig.GetStat(statId)
	return statDefinition and statDefinition.Colour or Color3.fromRGB(255, 184, 78)
end

local function cleanInteger(value)
	return math.max(0, math.floor(tonumber(value) or 0))
end

local function readIntValue(parent, name, defaultValue)
	local value = parent and parent:FindFirstChild(name)
	if value and value:IsA("IntValue") then
		return cleanInteger(value.Value)
	end

	return defaultValue or 0
end

local function createRow(statId, order)
	local statDefinition = StatConfig.GetStat(statId)
	local statColor = getStatColor(statId)

	local row = Instance.new("Frame")
	row.Name = statId .. "Row"
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
	row.BackgroundColor3 = Color3.fromRGB(13, 18, 25)
	row.BackgroundTransparency = 0
	row.BorderSizePixel = 0
	row.Parent = list

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 8)
	rowCorner.Parent = row

	local rowStroke = Instance.new("UIStroke")
	rowStroke.Color = statColor
	rowStroke.Thickness = 1
	rowStroke.Transparency = 0.32
	rowStroke.Parent = row

	local accent = Instance.new("Frame")
	accent.Name = "Accent"
	accent.BackgroundColor3 = statColor
	accent.BorderSizePixel = 0
	accent.Position = UDim2.fromOffset(0, 0)
	accent.Size = UDim2.new(0, 4, 1, 0)
	accent.Parent = row

	local badge = Instance.new("TextLabel")
	badge.Name = "Badge"
	badge.BackgroundColor3 = statColor
	badge.BorderSizePixel = 0
	badge.Position = UDim2.fromOffset(9, 8)
	badge.Size = UDim2.fromOffset(32, 32)
	badge.Font = Enum.Font.GothamBlack
	badge.Text = string.sub(statId, 1, 1)
	badge.TextColor3 = Color3.fromRGB(7, 11, 17)
	badge.TextSize = 16
	badge.Parent = row

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(1, 0)
	badgeCorner.Parent = badge

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(50, 5)
	nameLabel.Size = UDim2.new(0.38, -16, 0, 19)
	nameLabel.Font = Enum.Font.GothamBlack
	nameLabel.Text = statDefinition and statDefinition.DisplayName or statId
	nameLabel.TextColor3 = Color3.fromRGB(240, 245, 250)
	nameLabel.TextSize = 14
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = row

	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "Level"
	levelLabel.BackgroundTransparency = 1
	levelLabel.Position = UDim2.new(0.46, 0, 0, 5)
	levelLabel.Size = UDim2.new(0.18, 0, 0, 19)
	levelLabel.Font = Enum.Font.GothamBold
	levelLabel.Text = "Lv 0"
	levelLabel.TextColor3 = Color3.fromRGB(255, 232, 188)
	levelLabel.TextSize = 13
	levelLabel.TextXAlignment = Enum.TextXAlignment.Left
	levelLabel.Parent = row

	local xpLabel = Instance.new("TextLabel")
	xpLabel.Name = "XP"
	xpLabel.AnchorPoint = Vector2.new(1, 0)
	xpLabel.BackgroundTransparency = 1
	xpLabel.Position = UDim2.new(1, -10, 0, 5)
	xpLabel.Size = UDim2.new(0.38, 0, 0, 19)
	xpLabel.Font = Enum.Font.GothamMedium
	xpLabel.Text = "0 / 100 XP"
	xpLabel.TextColor3 = Color3.fromRGB(204, 214, 224)
	xpLabel.TextSize = 12
	xpLabel.TextXAlignment = Enum.TextXAlignment.Right
	xpLabel.Parent = row

	local barBack = Instance.new("Frame")
	barBack.Name = "XPBar"
	barBack.BackgroundColor3 = Color3.fromRGB(4, 7, 11)
	barBack.BorderSizePixel = 0
	barBack.Position = UDim2.fromOffset(50, 32)
	barBack.Size = UDim2.new(1, -62, 0, 8)
	barBack.Parent = row

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = barBack

	local barFill = Instance.new("Frame")
	barFill.Name = "Fill"
	barFill.BackgroundColor3 = statColor
	barFill.BorderSizePixel = 0
	barFill.Size = UDim2.new(0, 0, 1, 0)
	barFill.Parent = barBack

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = barFill

	rows[statId] = {
		Frame = row,
		Stroke = rowStroke,
		Badge = badge,
		LevelLabel = levelLabel,
		XPLabel = xpLabel,
		Fill = barFill,
		StatColor = statColor,
		State = {
			Level = nil,
			XP = nil,
			XPRequired = nil,
			EffectiveValue = nil,
		},
	}
end

local function pulseRow(rowData, isLevelUp)
	local frame = rowData.Frame
	local stroke = rowData.Stroke
	local badge = rowData.Badge
	if not frame.Parent then
		return
	end

	local originalTransparency = stroke.Transparency
	stroke.Transparency = isLevelUp and 0.02 or 0.18
	badge.BackgroundColor3 = rowData.StatColor
	badge.TextColor3 = Color3.fromRGB(7, 11, 17)

	task.delay(isLevelUp and 0.5 or 0.25, function()
		if not frame.Parent then
			return
		end

		TweenService:Create(stroke, TweenInfo.new(0.25), {
			Transparency = originalTransparency,
		}):Play()
		TweenService:Create(badge, TweenInfo.new(0.25), {
				BackgroundColor3 = rowData.StatColor,
				TextColor3 = Color3.fromRGB(7, 11, 17),
		}):Play()
	end)
end

local function updateRow(statId, statFolder, shouldAnimate)
	local rowData = rows[statId]
	if rowData == nil then
		return
	end

	local level = readIntValue(statFolder, "Level", 0)
	local xp = readIntValue(statFolder, "XP", 0)
	local xpRequired = readIntValue(statFolder, "XPRequired", StatConfig.GetRequiredXPForLevel(statId, level + 1) or 0)
	local effectiveValue = readIntValue(statFolder, "EffectiveValue", level)
	local previous = rowData.State
	local levelUp = previous.Level ~= nil and level > previous.Level
	local xpChanged = previous.XP ~= nil and xp ~= previous.XP
	local progress = 1

	if xpRequired > 0 then
		progress = math.clamp(xp / xpRequired, 0, 1)
		rowData.XPLabel.Text = string.format("%d / %d XP", xp, xpRequired)
	else
		rowData.XPLabel.Text = "MAX"
	end

	rowData.LevelLabel.Text = string.format("Lv %d", level)
	rowData.Badge.Text = tostring(effectiveValue)

	local targetSize = UDim2.new(progress, 0, 1, 0)
	if shouldAnimate then
		TweenService:Create(rowData.Fill, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = targetSize,
		}):Play()
	else
		rowData.Fill.Size = targetSize
	end

	rowData.State = {
		Level = level,
		XP = xp,
		XPRequired = xpRequired,
		EffectiveValue = effectiveValue,
	}

	if levelUp or xpChanged then
		pulseRow(rowData, levelUp)
	end
end

local function disconnectStatConnections(statId)
	local connections = statConnections[statId]
	if connections then
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
	end

	statConnections[statId] = {}
end

local function connectStatFolder(statId, statFolder)
	disconnectStatConnections(statId)
	updateRow(statId, statFolder, false)

	for _, valueName in ipairs({ "Level", "XP", "XPRequired", "EffectiveValue" }) do
		local value = statFolder:FindFirstChild(valueName)
		if value and value:IsA("IntValue") then
			table.insert(statConnections[statId], value.Changed:Connect(function()
				updateRow(statId, statFolder, true)
			end))
		end
	end

	table.insert(statConnections[statId], statFolder.ChildAdded:Connect(function(child)
		if child:IsA("IntValue") then
			updateRow(statId, statFolder, true)
			table.insert(statConnections[statId], child.Changed:Connect(function()
				updateRow(statId, statFolder, true)
			end))
		end
	end))
end

local function connectTrainingStats(trainingStatsFolder)
	for _, statId in ipairs(STAT_IDS) do
		local statFolder = trainingStatsFolder:FindFirstChild(statId)
		if statFolder and statFolder:IsA("Folder") then
			connectStatFolder(statId, statFolder)
		else
			updateRow(statId, nil, false)
		end
	end

	trainingStatsFolder.ChildAdded:Connect(function(child)
		if child:IsA("Folder") and rows[child.Name] then
			connectStatFolder(child.Name, child)
		end
	end)
end

local function disconnectRankConnections()
	for _, connection in ipairs(rankConnections) do
		connection:Disconnect()
	end

	rankConnections = {}
end

local function setRank(value)
	rankLabel.Text = string.format("Rank %d", cleanInteger(value))
end

local function connectRank()
	disconnectRankConnections()

	local profileFolder = player:FindFirstChild("Profile")
	local leaderstats = player:FindFirstChild("leaderstats")
	local profileRank = profileFolder and profileFolder:FindFirstChild("TrainingRank")
	local leaderRank = leaderstats and leaderstats:FindFirstChild("TrainingRank")
	local rankValue = profileRank or leaderRank

	if rankValue and rankValue:IsA("IntValue") then
		setRank(rankValue.Value)
		table.insert(rankConnections, rankValue.Changed:Connect(setRank))
	else
		setRank(0)
	end
end

local function hideLegacyStatsPanel()
	local legacyGui = playerGui:FindFirstChild("AscensionTrainingFeedbackGui")
	if legacyGui then
		local legacyPanel = legacyGui:FindFirstChild("StatsPanel")
		if legacyPanel and legacyPanel:IsA("GuiObject") then
			legacyPanel.Visible = false
		end
	end
end

for index, statId in ipairs(STAT_IDS) do
	createRow(statId, index)
	statConnections[statId] = {}
end

local existingTrainingStats = player:FindFirstChild("TrainingStats")
if existingTrainingStats then
	connectTrainingStats(existingTrainingStats)
else
	player.ChildAdded:Connect(function(child)
		if child.Name == "TrainingStats" and child:IsA("Folder") then
			connectTrainingStats(child)
		end
	end)
end

player.ChildAdded:Connect(function(child)
	if child.Name == "Profile" or child.Name == "leaderstats" then
		task.defer(connectRank)
	end
end)
connectRank()

task.spawn(function()
	for _ = 1, 40 do
		hideLegacyStatsPanel()
		task.wait(0.25)
	end
end)
playerGui.ChildAdded:Connect(function(child)
	if child.Name == "AscensionTrainingFeedbackGui" then
		task.defer(hideLegacyStatsPanel)
	end
end)

task.spawn(function()
	local remotesFolder = ZeroToHeroShared:WaitForChild("Remotes", 10)
	if remotesFolder == nil then
		return
	end

	local rewardEvent = remotesFolder:WaitForChild("TrainingStationReward", 10)
	if rewardEvent and rewardEvent:IsA("RemoteEvent") then
		rewardEvent.OnClientEvent:Connect(function(payload)
			if typeof(payload) == "table" and typeof(payload.Stat) == "string" and rows[payload.Stat] then
				pulseRow(rows[payload.Stat], (tonumber(payload.LevelUps) or 0) > 0)
			end
		end)
	end
end)
