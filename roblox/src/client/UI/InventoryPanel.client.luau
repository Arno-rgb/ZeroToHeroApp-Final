local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ZeroToHeroShared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local ItemConfig = require(ZeroToHeroShared:WaitForChild("Config"):WaitForChild("ItemConfig"))
local remotes = ZeroToHeroShared:WaitForChild("Remotes")
local actionEvent = remotes:WaitForChild("InventoryAction")
local snapshotEvent = remotes:WaitForChild("InventorySnapshot")

local SLOT_ORDER = ItemConfig.GetSlots()
local STAT_ORDER = {
	"PhysicalDamage",
	"BreakDamage",
	"MaxHP",
	"MaxStamina",
	"GuardEffectiveness",
	"SkillEffectiveness",
}

local RARITY_COLORS = {
	Common = Color3.fromRGB(220, 228, 235),
	Rare = Color3.fromRGB(80, 183, 255),
	Epic = Color3.fromRGB(181, 111, 255),
	Mythic = Color3.fromRGB(255, 184, 78),
}

local gui = Instance.new("ScreenGui")
gui.Name = "InventoryPanelGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 15
gui.Parent = playerGui

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "GearButton"
toggleButton.AnchorPoint = Vector2.new(1, 0)
toggleButton.Position = UDim2.new(1, -12, 0, 12)
toggleButton.Size = UDim2.fromOffset(94, 38)
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 25, 31)
toggleButton.BorderSizePixel = 0
toggleButton.Font = Enum.Font.GothamBlack
toggleButton.Text = "GEAR"
toggleButton.TextColor3 = Color3.fromRGB(255, 232, 188)
toggleButton.TextSize = 15
toggleButton.Parent = gui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(255, 184, 78)
toggleStroke.Thickness = 1
toggleStroke.Transparency = 0.2
toggleStroke.Parent = toggleButton

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -12, 0, 58)
panel.Size = UDim2.fromOffset(338, 418)
panel.BackgroundColor3 = Color3.fromRGB(10, 14, 19)
panel.BackgroundTransparency = 0.04
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local panelSize = Instance.new("UISizeConstraint")
panelSize.MinSize = Vector2.new(310, 370)
panelSize.MaxSize = Vector2.new(360, 430)
panelSize.Parent = panel

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(255, 184, 78)
panelStroke.Thickness = 2
panelStroke.Transparency = 0.18
panelStroke.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(14, 10)
title.Size = UDim2.new(1, -86, 0, 28)
title.Font = Enum.Font.GothamBlack
title.Text = "Inventory"
title.TextColor3 = Color3.fromRGB(255, 232, 188)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -10, 0, 10)
closeButton.Size = UDim2.fromOffset(40, 28)
closeButton.BackgroundColor3 = Color3.fromRGB(31, 37, 45)
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.GothamBlack
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(238, 242, 247)
closeButton.TextSize = 14
closeButton.Parent = panel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = closeButton

local equippedFrame = Instance.new("Frame")
equippedFrame.Name = "Equipped"
equippedFrame.BackgroundTransparency = 1
equippedFrame.Position = UDim2.fromOffset(14, 46)
equippedFrame.Size = UDim2.new(1, -28, 0, 92)
equippedFrame.Parent = panel

local equippedLayout = Instance.new("UIListLayout")
equippedLayout.FillDirection = Enum.FillDirection.Vertical
equippedLayout.SortOrder = Enum.SortOrder.LayoutOrder
equippedLayout.Padding = UDim.new(0, 5)
equippedLayout.Parent = equippedFrame

local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "Stats"
statsLabel.BackgroundColor3 = Color3.fromRGB(18, 23, 29)
statsLabel.BorderSizePixel = 0
statsLabel.Position = UDim2.fromOffset(14, 144)
statsLabel.Size = UDim2.new(1, -28, 0, 32)
statsLabel.Font = Enum.Font.GothamBold
statsLabel.Text = "DMG 0   BRK 0   HP 0"
statsLabel.TextColor3 = Color3.fromRGB(220, 227, 235)
statsLabel.TextSize = 12
statsLabel.TextXAlignment = Enum.TextXAlignment.Center
statsLabel.Parent = panel

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 7)
statsCorner.Parent = statsLabel

local itemList = Instance.new("ScrollingFrame")
itemList.Name = "ItemList"
itemList.BackgroundTransparency = 1
itemList.BorderSizePixel = 0
itemList.Position = UDim2.fromOffset(14, 184)
itemList.Size = UDim2.new(1, -28, 0, 128)
itemList.CanvasSize = UDim2.fromOffset(0, 0)
itemList.ScrollBarThickness = 4
itemList.Parent = panel

local itemLayout = Instance.new("UIListLayout")
itemLayout.FillDirection = Enum.FillDirection.Vertical
itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
itemLayout.Padding = UDim.new(0, 6)
itemLayout.Parent = itemList

local detailFrame = Instance.new("Frame")
detailFrame.Name = "Details"
detailFrame.BackgroundColor3 = Color3.fromRGB(18, 23, 29)
detailFrame.BorderSizePixel = 0
detailFrame.Position = UDim2.fromOffset(14, 320)
detailFrame.Size = UDim2.new(1, -28, 0, 84)
detailFrame.Parent = panel

local detailCorner = Instance.new("UICorner")
detailCorner.CornerRadius = UDim.new(0, 8)
detailCorner.Parent = detailFrame

local detailName = Instance.new("TextLabel")
detailName.Name = "Name"
detailName.BackgroundTransparency = 1
detailName.Position = UDim2.fromOffset(10, 7)
detailName.Size = UDim2.new(1, -108, 0, 20)
detailName.Font = Enum.Font.GothamBlack
detailName.Text = "No item"
detailName.TextColor3 = Color3.fromRGB(238, 242, 247)
detailName.TextSize = 13
detailName.TextXAlignment = Enum.TextXAlignment.Left
detailName.TextTruncate = Enum.TextTruncate.AtEnd
detailName.Parent = detailFrame

local detailStats = Instance.new("TextLabel")
detailStats.Name = "StatDelta"
detailStats.BackgroundTransparency = 1
detailStats.Position = UDim2.fromOffset(10, 29)
detailStats.Size = UDim2.new(1, -20, 0, 20)
detailStats.Font = Enum.Font.GothamMedium
detailStats.Text = ""
detailStats.TextColor3 = Color3.fromRGB(204, 214, 224)
detailStats.TextSize = 11
detailStats.TextXAlignment = Enum.TextXAlignment.Left
detailStats.TextTruncate = Enum.TextTruncate.AtEnd
detailStats.Parent = detailFrame

local equipButton = Instance.new("TextButton")
equipButton.Name = "EquipButton"
equipButton.Position = UDim2.fromOffset(10, 53)
equipButton.Size = UDim2.fromOffset(96, 24)
equipButton.BackgroundColor3 = Color3.fromRGB(255, 204, 92)
equipButton.BorderSizePixel = 0
equipButton.Font = Enum.Font.GothamBlack
equipButton.Text = "EQUIP"
equipButton.TextColor3 = Color3.fromRGB(12, 14, 18)
equipButton.TextSize = 12
equipButton.Parent = detailFrame

local equipCorner = Instance.new("UICorner")
equipCorner.CornerRadius = UDim.new(0, 7)
equipCorner.Parent = equipButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.AnchorPoint = Vector2.new(1, 1)
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.new(1, -10, 1, -6)
statusLabel.Size = UDim2.new(1, -126, 0, 24)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 232, 188)
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Right
statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
statusLabel.Parent = detailFrame

local currentSnapshot = nil
local selectedInstanceId = nil
local equippedRows = {}

local function clearChildren(parent)
	for _, child in ipairs(parent:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
end

local function getRarityColor(rarity)
	return RARITY_COLORS[rarity] or Color3.fromRGB(220, 228, 235)
end

local function formatSigned(value)
	local numericValue = tonumber(value) or 0
	if math.abs(numericValue) < 0.005 then
		return nil
	end

	if math.abs(numericValue) >= 10 then
		numericValue = math.floor(numericValue + 0.5)
	else
		numericValue = math.floor(numericValue * 100 + 0.5) / 100
	end

	return numericValue > 0 and ("+" .. tostring(numericValue)) or tostring(numericValue)
end

local function formatBonuses(bonuses)
	local parts = {}
	for _, statKey in ipairs(STAT_ORDER) do
		local text = formatSigned(bonuses and bonuses[statKey])
		if text then
			table.insert(parts, statKey .. " " .. text)
		end
	end

	return #parts > 0 and table.concat(parts, "  ") or "No stat change"
end

local function getItemByInstanceId(instanceId)
	if currentSnapshot == nil then
		return nil
	end

	for _, item in ipairs(currentSnapshot.Items or {}) do
		if item.InstanceId == instanceId then
			return item
		end
	end

	return nil
end

local function request(action, payload)
	payload = typeof(payload) == "table" and payload or {}
	payload.Action = action
	actionEvent:FireServer(payload)
end

local function selectItem(instanceId)
	selectedInstanceId = instanceId
	gui:SetAttribute("SelectedItemId", selectedInstanceId or "")
	request("Inspect", {
		InstanceId = instanceId,
	})
end

local function createEquippedRow(slot, order)
	local row = Instance.new("Frame")
	row.Name = slot .. "Slot"
	row.LayoutOrder = order
	row.Size = UDim2.new(1, 0, 0, 27)
	row.BackgroundColor3 = Color3.fromRGB(18, 23, 29)
	row.BorderSizePixel = 0
	row.Parent = equippedFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = row

	local name = Instance.new("TextLabel")
	name.Name = "Name"
	name.BackgroundTransparency = 1
	name.Position = UDim2.fromOffset(8, 0)
	name.Size = UDim2.new(1, -86, 1, 0)
	name.Font = Enum.Font.GothamBold
	name.Text = slot .. ": Empty"
	name.TextColor3 = Color3.fromRGB(220, 227, 235)
	name.TextSize = 12
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.TextTruncate = Enum.TextTruncate.AtEnd
	name.Parent = row

	local button = Instance.new("TextButton")
	button.Name = "Unequip"
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -5, 0.5, 0)
	button.Size = UDim2.fromOffset(72, 20)
	button.BackgroundColor3 = Color3.fromRGB(31, 37, 45)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBlack
	button.Text = "UNEQ"
	button.TextColor3 = Color3.fromRGB(238, 242, 247)
	button.TextSize = 10
	button.Parent = row

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button

	button.MouseButton1Click:Connect(function()
		request("Unequip", {
			Slot = slot,
		})
	end)

	equippedRows[slot] = {
		Name = name,
		Button = button,
	}
end

local function renderEquipped(snapshot)
	for index, slot in ipairs(SLOT_ORDER) do
		if equippedRows[slot] == nil then
			createEquippedRow(slot, index)
		end

		local equipped = snapshot.EquippedItems and snapshot.EquippedItems[slot]
		local row = equippedRows[slot]
		if equipped then
			row.Name.Text = slot .. ": " .. equipped.Name
			row.Name.TextColor3 = getRarityColor(equipped.Rarity)
			row.Button.Visible = true
		else
			row.Name.Text = slot .. ": Empty"
			row.Name.TextColor3 = Color3.fromRGB(142, 153, 166)
			row.Button.Visible = false
		end
	end
end

local function createItemRow(item, order)
	local row = Instance.new("TextButton")
	row.Name = item.InstanceId
	row.LayoutOrder = order
	row.Size = UDim2.new(1, -4, 0, 38)
	row.BackgroundColor3 = item.InstanceId == selectedInstanceId and Color3.fromRGB(38, 46, 56) or Color3.fromRGB(18, 23, 29)
	row.BorderSizePixel = 0
	row.AutoButtonColor = true
	row.Font = Enum.Font.GothamBold
	row.Text = ""
	row.Parent = itemList

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = row

	local stroke = Instance.new("UIStroke")
	stroke.Color = getRarityColor(item.Rarity)
	stroke.Thickness = 1
	stroke.Transparency = 0.42
	stroke.Parent = row

	local name = Instance.new("TextLabel")
	name.Name = "Name"
	name.BackgroundTransparency = 1
	name.Position = UDim2.fromOffset(8, 3)
	name.Size = UDim2.new(1, -96, 0, 17)
	name.Font = Enum.Font.GothamBlack
	name.Text = item.Name
	name.TextColor3 = getRarityColor(item.Rarity)
	name.TextSize = 12
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.TextTruncate = Enum.TextTruncate.AtEnd
	name.Parent = row

	local meta = Instance.new("TextLabel")
	meta.Name = "Meta"
	meta.BackgroundTransparency = 1
	meta.Position = UDim2.fromOffset(8, 20)
	meta.Size = UDim2.new(1, -96, 0, 15)
	meta.Font = Enum.Font.GothamMedium
	meta.Text = item.Rarity .. " " .. item.Slot
	meta.TextColor3 = Color3.fromRGB(172, 184, 198)
	meta.TextSize = 10
	meta.TextXAlignment = Enum.TextXAlignment.Left
	meta.TextTruncate = Enum.TextTruncate.AtEnd
	meta.Parent = row

	local badge = Instance.new("TextLabel")
	badge.Name = "Badge"
	badge.AnchorPoint = Vector2.new(1, 0.5)
	badge.BackgroundColor3 = Color3.fromRGB(9, 12, 16)
	badge.BorderSizePixel = 0
	badge.Position = UDim2.new(1, -7, 0.5, 0)
	badge.Size = UDim2.fromOffset(74, 22)
	badge.Font = Enum.Font.GothamBlack
	badge.Text = item.BindingState or ""
	badge.TextColor3 = Color3.fromRGB(220, 227, 235)
	badge.TextSize = 9
	badge.TextTruncate = Enum.TextTruncate.AtEnd
	badge.Parent = row

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(0, 6)
	badgeCorner.Parent = badge

	row.MouseButton1Click:Connect(function()
		selectItem(item.InstanceId)
	end)
end

local function renderItems(snapshot)
	clearChildren(itemList)

	for index, item in ipairs(snapshot.Items or {}) do
		createItemRow(item, index)
	end

	task.defer(function()
		itemList.CanvasSize = UDim2.fromOffset(0, itemLayout.AbsoluteContentSize.Y + 6)
	end)
end

local function renderStats(snapshot)
	local stats = snapshot.EffectiveStats or {}
	statsLabel.Text = string.format(
		"DMG %s   BRK %s   HP %s",
		tostring(stats.PhysicalDamage or 0),
		tostring(stats.BreakDamage or 0),
		tostring(stats.MaxHP or 0)
	)
	gui:SetAttribute("EffectivePhysicalDamage", tonumber(stats.PhysicalDamage) or 0)
	gui:SetAttribute("EffectiveBreakDamage", tonumber(stats.BreakDamage) or 0)
	gui:SetAttribute("EffectiveMaxHP", tonumber(stats.MaxHP) or 0)
end

local function renderDetails(snapshot)
	local selectedItem = snapshot.SelectedItem or getItemByInstanceId(selectedInstanceId)
	local comparison = snapshot.Comparison

	if selectedItem == nil then
		detailName.Text = "No item"
		detailName.TextColor3 = Color3.fromRGB(238, 242, 247)
		detailStats.Text = ""
		equipButton.Active = false
		equipButton.AutoButtonColor = false
		equipButton.BackgroundTransparency = 0.42
		statusLabel.Text = ""
		return
	end

	detailName.Text = selectedItem.Name
	detailName.TextColor3 = getRarityColor(selectedItem.Rarity)
	detailStats.Text = formatBonuses(comparison and comparison.StatDelta or selectedItem.StatBonuses)
	equipButton.Active = true
	equipButton.AutoButtonColor = true
	equipButton.BackgroundTransparency = 0
	statusLabel.Text = selectedItem.Slot
end

local function renderStatus(snapshot)
	local result = snapshot.LastResult
	if typeof(result) ~= "table" then
		return
	end

	if result.Success then
		statusLabel.Text = result.Action or ""
	else
		statusLabel.Text = result.Error or "Action failed"
	end
end

local function render(snapshot)
	currentSnapshot = snapshot
	if selectedInstanceId ~= nil and getItemByInstanceId(selectedInstanceId) == nil then
		selectedInstanceId = nil
	end

	gui:SetAttribute("ItemCount", #(snapshot.Items or {}))
	gui:SetAttribute("WeaponEquipped", snapshot.Equipment and tostring(snapshot.Equipment.Weapon or "") or "")
	gui:SetAttribute("ArmourEquipped", snapshot.Equipment and tostring(snapshot.Equipment.Armour or "") or "")
	gui:SetAttribute("CharmEquipped", snapshot.Equipment and tostring(snapshot.Equipment.Charm or "") or "")

	renderEquipped(snapshot)
	renderStats(snapshot)
	renderItems(snapshot)
	renderDetails(snapshot)
	renderStatus(snapshot)
end

toggleButton.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
	gui:SetAttribute("PanelVisible", panel.Visible)
	if panel.Visible then
		request("RequestSnapshot", {
			InstanceId = selectedInstanceId,
		})
	end
end)

closeButton.MouseButton1Click:Connect(function()
	panel.Visible = false
	gui:SetAttribute("PanelVisible", false)
end)

equipButton.MouseButton1Click:Connect(function()
	if selectedInstanceId then
		request("Equip", {
			InstanceId = selectedInstanceId,
		})
	end
end)

snapshotEvent.OnClientEvent:Connect(render)

task.defer(function()
	request("RequestSnapshot")
end)
