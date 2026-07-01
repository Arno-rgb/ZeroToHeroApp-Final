local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player and player:FindFirstChildOfClass("PlayerGui")

local function findDescendantByName(root, name)
	if not root then
		return nil
	end
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant.Name == name then
			return descendant
		end
	end
	return nil
end

local function firstText(root, names)
	if not root then
		return nil
	end
	for _, name in ipairs(names) do
		local instance = findDescendantByName(root, name)
		if instance and (instance:IsA("TextLabel") or instance:IsA("TextButton")) then
			return instance.Text
		end
	end
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			if descendant.Text and descendant.Text ~= "" then
				return descendant.Text
			end
		end
	end
	return nil
end

local rewardGui = playerGui and playerGui:FindFirstChild("RewardPopupGui")
local rewardPopup = rewardGui and rewardGui:FindFirstChild("Popup", true)
local statsGui = playerGui and playerGui:FindFirstChild("TrainingStatsHudGui")
local combatGui = playerGui and playerGui:FindFirstChild("CombatControllerGui")
local inventoryGui = playerGui and playerGui:FindFirstChild("InventoryPanelGui")
local minigameGui = playerGui and playerGui:FindFirstChild("StrengthForgeMinigameGui")

local result = {
	player = player and player.Name or nil,
	playerGui = playerGui ~= nil,
	rewardPopupGui = rewardGui ~= nil,
	rewardPopupVisible = rewardPopup and rewardPopup.Visible or false,
	rewardPopupTitle = firstText(rewardGui, { "Title", "Header", "RewardTitle" }),
	trainingStatsHudGui = statsGui ~= nil,
	trainingStatsHudEnabled = statsGui and statsGui.Enabled or false,
	combatControllerGui = combatGui ~= nil,
	combatControllerEnabled = combatGui and combatGui.Enabled or false,
	inventoryPanelGui = inventoryGui ~= nil,
	inventoryPanelEnabled = inventoryGui and inventoryGui.Enabled or false,
	strengthForgeMinigameGui = minigameGui ~= nil,
	strengthForgeMinigameEnabled = minigameGui and minigameGui.Enabled or false,
}

return HttpService:JSONEncode(result)
