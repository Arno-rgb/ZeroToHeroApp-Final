local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ZeroToHeroShared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local StatConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("StatConfig"))

local MAX_QUEUE_SIZE = 12
local MAX_ROWS = 4
local BASE_DISPLAY_SECONDS = 1.55
local DISPLAY_SECONDS_PER_ROW = 0.16
local FADE_SECONDS = 0.22
local POPUP_POSITION = UDim2.new(0.5, 0, 0.58, 0)
local POPUP_START_POSITION = UDim2.new(0.5, 0, 0.58, 30)
local POPUP_END_POSITION = UDim2.new(0.5, 0, 0.58, -20)

local RARITY_COLORS = {
	Common = Color3.fromRGB(214, 224, 232),
	Rare = Color3.fromRGB(80, 183, 255),
	Epic = Color3.fromRGB(181, 111, 255),
	Mythic = Color3.fromRGB(255, 184, 78),
}

local KIND_COLORS = {
	TrainingXP = Color3.fromRGB(255, 142, 42),
	HeroXP = Color3.fromRGB(80, 183, 255),
	Gold = Color3.fromRGB(255, 204, 74),
	Material = Color3.fromRGB(98, 232, 171),
	Item = Color3.fromRGB(181, 111, 255),
	LevelUp = Color3.fromRGB(255, 232, 188),
}

local gui = Instance.new("ScreenGui")
gui.Name = "RewardPopupGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 34
gui.Parent = playerGui

local popup = Instance.new("Frame")
popup.Name = "Popup"
popup.AnchorPoint = Vector2.new(0.5, 0.5)
popup.Position = POPUP_START_POSITION
popup.Size = UDim2.new(0.9, 0, 0, 120)
popup.BackgroundColor3 = Color3.fromRGB(8, 7, 6)
popup.BackgroundTransparency = 1
popup.BorderSizePixel = 0
popup.Visible = false
popup.Parent = gui

local popupConstraint = Instance.new("UISizeConstraint")
popupConstraint.MinSize = Vector2.new(300, 96)
popupConstraint.MaxSize = Vector2.new(440, 230)
popupConstraint.Parent = popup

local popupCorner = Instance.new("UICorner")
popupCorner.CornerRadius = UDim.new(0, 8)
popupCorner.Parent = popup

local popupStroke = Instance.new("UIStroke")
popupStroke.Color = Color3.fromRGB(255, 184, 78)
popupStroke.Thickness = 3
popupStroke.Transparency = 1
popupStroke.Parent = popup

local topRule = Instance.new("Frame")
topRule.Name = "TopRule"
topRule.BackgroundColor3 = Color3.fromRGB(255, 184, 78)
topRule.BackgroundTransparency = 0.26
topRule.BorderSizePixel = 0
topRule.Position = UDim2.fromOffset(18, 8)
topRule.Size = UDim2.new(1, -36, 0, 1)
topRule.Parent = popup

local bottomRule = Instance.new("Frame")
bottomRule.Name = "BottomRule"
bottomRule.AnchorPoint = Vector2.new(0, 1)
bottomRule.BackgroundColor3 = Color3.fromRGB(255, 184, 78)
bottomRule.BackgroundTransparency = 0.36
bottomRule.BorderSizePixel = 0
bottomRule.Position = UDim2.new(0, 18, 1, -8)
bottomRule.Size = UDim2.new(1, -36, 0, 1)
bottomRule.Parent = popup

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundTransparency = 1
header.Position = UDim2.fromOffset(16, 12)
header.Size = UDim2.new(1, -32, 0, 43)
header.Parent = popup

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(0, 0)
title.Size = UDim2.new(1, -104, 0, 23)
title.Font = Enum.Font.GothamBlack
title.Text = "Training Complete"
title.TextColor3 = Color3.fromRGB(255, 232, 188)
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(0, 23)
subtitle.Size = UDim2.new(1, -104, 0, 17)
subtitle.Font = Enum.Font.GothamMedium
subtitle.Text = ""
subtitle.TextColor3 = Color3.fromRGB(193, 205, 218)
subtitle.TextSize = 12
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local levelUpBadge = Instance.new("TextLabel")
levelUpBadge.Name = "LevelUpBadge"
levelUpBadge.AnchorPoint = Vector2.new(1, 0)
levelUpBadge.BackgroundColor3 = Color3.fromRGB(255, 184, 78)
levelUpBadge.BackgroundTransparency = 0
levelUpBadge.BorderSizePixel = 0
levelUpBadge.Position = UDim2.new(1, 0, 0, 3)
levelUpBadge.Size = UDim2.fromOffset(92, 26)
levelUpBadge.Font = Enum.Font.GothamBlack
levelUpBadge.Text = "LEVEL UP"
levelUpBadge.TextColor3 = Color3.fromRGB(16, 11, 8)
levelUpBadge.TextSize = 13
levelUpBadge.Visible = false
levelUpBadge.Parent = header

local badgeCorner = Instance.new("UICorner")
badgeCorner.CornerRadius = UDim.new(0, 7)
badgeCorner.Parent = levelUpBadge

local rowsFrame = Instance.new("Frame")
rowsFrame.Name = "RewardRows"
rowsFrame.BackgroundTransparency = 1
rowsFrame.Position = UDim2.fromOffset(16, 60)
rowsFrame.Size = UDim2.new(1, -32, 0, 140)
rowsFrame.Parent = popup

local rowsLayout = Instance.new("UIListLayout")
rowsLayout.FillDirection = Enum.FillDirection.Vertical
rowsLayout.SortOrder = Enum.SortOrder.LayoutOrder
rowsLayout.Padding = UDim.new(0, 5)
rowsLayout.Parent = rowsFrame

local rowSlots = {}

local function createRowSlot(index)
	local row = Instance.new("Frame")
	row.Name = "RewardRow" .. tostring(index)
	row.LayoutOrder = index
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = Color3.fromRGB(16, 15, 14)
	row.BackgroundTransparency = 0
	row.BorderSizePixel = 0
	row.Visible = false
	row.Parent = rowsFrame

	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 7)
	rowCorner.Parent = row

	local rowStroke = Instance.new("UIStroke")
	rowStroke.Color = Color3.fromRGB(255, 184, 78)
	rowStroke.Thickness = 1
	rowStroke.Transparency = 0.45
	rowStroke.Parent = row

	local badge = Instance.new("TextLabel")
	badge.Name = "Badge"
	badge.BackgroundColor3 = Color3.fromRGB(11, 15, 20)
	badge.BorderSizePixel = 0
	badge.Position = UDim2.fromOffset(7, 5)
	badge.Size = UDim2.fromOffset(44, 20)
	badge.Font = Enum.Font.GothamBlack
	badge.Text = "XP"
	badge.TextColor3 = Color3.fromRGB(255, 184, 78)
	badge.TextSize = 11
	badge.Parent = row

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(0, 6)
	badgeCorner.Parent = badge

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(61, 0)
	label.Size = UDim2.new(1, -146, 1, 0)
	label.Font = Enum.Font.GothamBold
	label.Text = ""
	label.TextColor3 = Color3.fromRGB(236, 242, 248)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = row

	local amount = Instance.new("TextLabel")
	amount.Name = "Amount"
	amount.AnchorPoint = Vector2.new(1, 0)
	amount.BackgroundTransparency = 1
	amount.Position = UDim2.new(1, -8, 0, 0)
	amount.Size = UDim2.fromOffset(82, 30)
	amount.Font = Enum.Font.GothamBlack
	amount.Text = ""
	amount.TextColor3 = Color3.fromRGB(255, 232, 188)
	amount.TextSize = 15
	amount.TextXAlignment = Enum.TextXAlignment.Right
	amount.Parent = row

	rowSlots[index] = {
		Frame = row,
		Stroke = rowStroke,
		Badge = badge,
		Label = label,
		Amount = amount,
	}
end

for index = 1, MAX_ROWS do
	createRowSlot(index)
end

local rewardQueue = {}
local isShowing = false
local activeDisplayToken = 0
local processQueue = nil

local function cleanInteger(value, defaultValue)
	local numericValue = tonumber(value)
	if numericValue == nil then
		return defaultValue or 0
	end

	return math.max(0, math.floor(numericValue + 0.5))
end

local function getStatColor(statId)
	local statDefinition = StatConfig.GetStat(statId)
	return statDefinition and statDefinition.Colour or KIND_COLORS.TrainingXP
end

local function getRarityColor(rarity)
	if typeof(rarity) ~= "string" then
		return RARITY_COLORS.Common
	end

	return RARITY_COLORS[rarity] or RARITY_COLORS.Common
end

local function getRowColor(row)
	if typeof(row.Stat) == "string" and StatConfig.IsValidStatId(row.Stat) then
		return getStatColor(row.Stat)
	end

	if row.Kind == "Item" then
		return getRarityColor(row.Rarity)
	end

	return KIND_COLORS[row.Kind] or RARITY_COLORS.Common
end

local function formatAmount(value, suffix)
	local amount = cleanInteger(value, 0)
	if suffix and suffix ~= "" then
		return string.format("+%d %s", amount, suffix)
	end

	return string.format("+%d", amount)
end

local function hasRewardsArray(payload)
	return typeof(payload.Rewards) == "table" and #payload.Rewards > 0
end

local function makeTrainingXpRow(entry)
	local statId = entry.Stat or entry.StatId
	local amount = entry.XPGained or entry.Amount or entry.XP or entry.TrainingXP

	if typeof(statId) ~= "string" or not StatConfig.IsValidStatId(statId) or tonumber(amount) == nil then
		return nil
	end

	return {
		Kind = "TrainingXP",
		Stat = statId,
		Badge = "XP",
		Label = statId .. " XP",
		AmountText = formatAmount(amount),
	}
end

local function makeHeroXpRow(entry)
	local amount = entry.HeroXP or entry.HeroXPGained or entry.Amount or entry.XP
	if tonumber(amount) == nil then
		return nil
	end

	return {
		Kind = "HeroXP",
		Badge = "HXP",
		Label = "Hero XP",
		AmountText = formatAmount(amount),
	}
end

local function makeGoldRow(entry)
	local amount = entry.Gold or entry.GoldGained or entry.Amount
	if tonumber(amount) == nil then
		return nil
	end

	return {
		Kind = "Gold",
		Badge = "G",
		Label = "Gold",
		AmountText = formatAmount(amount),
	}
end

local function makeItemRow(entry)
	local name = entry.ItemName or entry.Name or entry.DisplayName or entry.ItemId
	if typeof(name) ~= "string" or name == "" then
		return nil
	end

	return {
		Kind = "Item",
		Badge = typeof(entry.Rarity) == "string" and string.sub(entry.Rarity, 1, 1) or "ITM",
		Label = name,
		AmountText = formatAmount(entry.Amount or entry.Quantity or 1),
		Rarity = entry.Rarity or "Common",
	}
end

local function makeMaterialRow(entry)
	local name = entry.MaterialName or entry.Name or entry.DisplayName or entry.MaterialId
	if typeof(name) ~= "string" or name == "" then
		return nil
	end

	return {
		Kind = "Material",
		Badge = "MAT",
		Label = name,
		AmountText = formatAmount(entry.Amount or entry.Quantity or 1),
	}
end

local function makeLevelUpRow(entry)
	local statId = entry.Stat or entry.StatId
	local label = typeof(statId) == "string" and (statId .. " Level") or "Level Up"
	local newLevel = entry.NewLevel or entry.Level or entry.Amount
	local amountText = tonumber(newLevel) and tostring(cleanInteger(newLevel, 0)) or ""

	return {
		Kind = "LevelUp",
		Stat = statId,
		Badge = "LVL",
		Label = label,
		AmountText = amountText,
	}
end

local function normalizeRewardEntry(entry)
	if typeof(entry) ~= "table" then
		return nil
	end

	local kind = entry.Kind or entry.Type or entry.kind or entry.type

	if kind == "TrainingXP" or entry.TrainingXP ~= nil or (entry.Stat ~= nil and entry.XPGained ~= nil) then
		return makeTrainingXpRow(entry)
	elseif kind == "HeroXP" or entry.HeroXP ~= nil or entry.HeroXPGained ~= nil then
		return makeHeroXpRow(entry)
	elseif kind == "Gold" or entry.Gold ~= nil or entry.GoldGained ~= nil then
		return makeGoldRow(entry)
	elseif kind == "Material" or entry.MaterialName ~= nil or entry.MaterialId ~= nil then
		return makeMaterialRow(entry)
	elseif kind == "Item" or entry.ItemName ~= nil or entry.ItemId ~= nil then
		return makeItemRow(entry)
	elseif kind == "LevelUp" then
		return makeLevelUpRow(entry)
	end

	return nil
end

local function getLevelSubtitle(payload)
	local levelUps = cleanInteger(payload.LevelUps, 0)
	local oldLevel = tonumber(payload.OldLevel)
	local newLevel = tonumber(payload.NewLevel)

	if levelUps <= 0 or oldLevel == nil or newLevel == nil then
		return nil
	end

	return string.format("Lv %d -> %d", oldLevel, newLevel)
end

local function normalizePayload(payload)
	if typeof(payload) ~= "table" then
		return nil
	end

	local rows = {}
	if hasRewardsArray(payload) then
		for _, entry in ipairs(payload.Rewards) do
			local row = normalizeRewardEntry(entry)
			if row then
				table.insert(rows, row)
			end
		end
	else
		local trainingRow = normalizeRewardEntry(payload)
		if trainingRow then
			table.insert(rows, trainingRow)
		end

		if payload.HeroXP ~= nil or payload.HeroXPGained ~= nil then
			local heroRow = makeHeroXpRow(payload)
			if heroRow then
				table.insert(rows, heroRow)
			end
		end

		if payload.Gold ~= nil or payload.GoldGained ~= nil then
			local goldRow = makeGoldRow(payload)
			if goldRow then
				table.insert(rows, goldRow)
			end
		end

		if payload.MaterialName ~= nil or payload.MaterialId ~= nil then
			local materialRow = makeMaterialRow(payload)
			if materialRow then
				table.insert(rows, materialRow)
			end
		end

		if payload.ItemName ~= nil or payload.ItemId ~= nil then
			local itemRow = makeItemRow(payload)
			if itemRow then
				table.insert(rows, itemRow)
			end
		end
	end

	if #rows == 0 then
		return nil
	end

	local levelSubtitle = getLevelSubtitle(payload)
	local levelUp = cleanInteger(payload.LevelUps, 0) > 0
	local titleText = payload.Title or payload.RewardTitle or "Training Complete"
	local subtitleText = levelSubtitle or payload.Subtitle or payload.StationName or payload.Source or ""
	local displaySeconds = tonumber(payload.DisplaySeconds)

	return {
		Title = tostring(titleText),
		Subtitle = tostring(subtitleText),
		Rows = rows,
		LevelUp = levelUp,
		DisplaySeconds = displaySeconds and math.clamp(displaySeconds, 0.6, 15) or nil,
	}
end

local function getGroupAccentColor(group)
	local strongestRarity = nil
	for _, row in ipairs(group.Rows) do
		if row.Kind == "Item" and row.Rarity then
			if row.Rarity == "Mythic" then
				return getRarityColor("Mythic")
			elseif row.Rarity == "Epic" then
				strongestRarity = "Epic"
			elseif row.Rarity == "Rare" and strongestRarity == nil then
				strongestRarity = "Rare"
			end
		end
	end

	if strongestRarity then
		return getRarityColor(strongestRarity)
	end

	if group.LevelUp then
		return Color3.fromRGB(255, 232, 188)
	end

	return getRowColor(group.Rows[1])
end

local function hideLegacyRewardToast()
	local legacyGui = playerGui:FindFirstChild("AscensionTrainingFeedbackGui")
	if legacyGui == nil then
		return
	end

	local legacyToast = legacyGui:FindFirstChild("RewardToast")
	if legacyToast and legacyToast:IsA("GuiObject") then
		legacyToast.Visible = false
		legacyToast.BackgroundTransparency = 1

		if legacyToast:IsA("TextLabel") then
			legacyToast.TextTransparency = 1
		end
	end
end

local function setPopupForGroup(group)
	local rowCount = math.min(#group.Rows, MAX_ROWS)
	local accentColor = getGroupAccentColor(group)
	local targetHeight = 80 + (rowCount * 35)

	popup.Size = UDim2.new(0.9, 0, 0, targetHeight)
	popupStroke.Color = accentColor
	popupStroke.Thickness = group.LevelUp and 3 or 2
	title.Text = group.Title
	subtitle.Text = group.Subtitle
	levelUpBadge.Visible = group.LevelUp

	for index, slot in ipairs(rowSlots) do
		local row = group.Rows[index]
		if row then
			local rowColor = getRowColor(row)
			slot.Frame.Visible = true
			slot.Stroke.Color = rowColor
			slot.Stroke.Transparency = group.LevelUp and 0.18 or 0.42
			slot.Badge.Text = row.Badge
			slot.Badge.TextColor3 = rowColor
			slot.Label.Text = row.Label
			slot.Label.TextColor3 = rowColor
			slot.Amount.Text = row.AmountText
			slot.Amount.TextColor3 = rowColor
		else
			slot.Frame.Visible = false
		end
	end
end

local function showGroup(group)
	activeDisplayToken += 1
	local token = activeDisplayToken
	local displaySeconds = group.DisplaySeconds or (BASE_DISPLAY_SECONDS + (math.min(#group.Rows, MAX_ROWS) * DISPLAY_SECONDS_PER_ROW))

	setPopupForGroup(group)
	hideLegacyRewardToast()

	popup.Visible = true
	popup.Position = POPUP_START_POSITION
	popup.BackgroundTransparency = 0.02
	popupStroke.Transparency = group.LevelUp and 0.02 or 0.08
	isShowing = true
	gui:SetAttribute("IsShowing", true)
	gui:SetAttribute("QueueDepth", #rewardQueue)
	gui:SetAttribute("LastRewardTitle", group.Title)
	gui:SetAttribute("LastRewardPrimary", group.Rows[1] and group.Rows[1].Label or "")
	gui:SetAttribute("LastRewardAmount", group.Rows[1] and group.Rows[1].AmountText or "")
	gui:SetAttribute("LastDisplaySeconds", displaySeconds)

	TweenService:Create(popup, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = POPUP_POSITION,
	}):Play()

	task.delay(displaySeconds, function()
		if token ~= activeDisplayToken then
			return
		end

		hideLegacyRewardToast()

		local fade = TweenService:Create(popup, TweenInfo.new(FADE_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = POPUP_END_POSITION,
			BackgroundTransparency = 1,
		})

		TweenService:Create(popupStroke, TweenInfo.new(FADE_SECONDS), {
			Transparency = 1,
		}):Play()
		fade:Play()
		fade.Completed:Wait()

		if token ~= activeDisplayToken then
			return
		end

		popup.Visible = false
		isShowing = false
		gui:SetAttribute("IsShowing", false)
		gui:SetAttribute("QueueDepth", #rewardQueue)
		processQueue()
	end)
end

processQueue = function()
	if isShowing then
		return
	end

	local group = table.remove(rewardQueue, 1)
	gui:SetAttribute("QueueDepth", #rewardQueue)
	if group then
		showGroup(group)
	end
end

local function enqueueGroup(group)
	table.insert(rewardQueue, group)

	while #rewardQueue > MAX_QUEUE_SIZE do
		table.remove(rewardQueue, 1)
	end

	gui:SetAttribute("QueueDepth", #rewardQueue)
	processQueue()
end

local function handleRewardPayload(payload)
	local group = normalizePayload(payload)
	if group == nil then
		return
	end

	hideLegacyRewardToast()
	task.delay(0.05, hideLegacyRewardToast)
	task.delay(0.2, hideLegacyRewardToast)
	task.delay(0.6, hideLegacyRewardToast)
	enqueueGroup(group)
end

task.spawn(function()
	for _ = 1, 40 do
		hideLegacyRewardToast()
		task.wait(0.25)
	end
end)

playerGui.ChildAdded:Connect(function(child)
	if child.Name == "AscensionTrainingFeedbackGui" then
		task.defer(hideLegacyRewardToast)
	end
end)

task.spawn(function()
	local remotesFolder = ZeroToHeroShared:WaitForChild("Remotes", 15)
	if remotesFolder == nil then
		warn("[RewardPopup] ZeroToHeroShared.Remotes was not available")
		return
	end

	local rewardEvent = remotesFolder:WaitForChild("TrainingStationReward", 15)
	if rewardEvent == nil or not rewardEvent:IsA("RemoteEvent") then
		warn("[RewardPopup] TrainingStationReward RemoteEvent was not available")
		return
	end

	rewardEvent.OnClientEvent:Connect(handleRewardPayload)
end)
