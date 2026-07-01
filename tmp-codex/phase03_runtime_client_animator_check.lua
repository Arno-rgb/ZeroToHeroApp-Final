local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local deadline = os.clock() + 18
repeat
	player = Players.LocalPlayer
	if not player then
		task.wait(0.2)
	end
until player or os.clock() > deadline
assert(player, "No LocalPlayer in client Play mode")

local playerScripts = player:WaitForChild("PlayerScripts", 10)
assert(playerScripts, "PlayerScripts missing")

local animator = playerScripts
	:WaitForChild("ZeroToHeroClient", 10)
	:WaitForChild("Effects", 10)
	:WaitForChild("TrainingWorldVisualAnimator", 10)
assert(animator and animator:IsA("LocalScript"), "TrainingWorldVisualAnimator LocalScript missing")

local readyDeadline = os.clock() + 12
repeat
	task.wait(0.2)
until animator:GetAttribute("AnimatorReady") == true or os.clock() > readyDeadline
assert(animator:GetAttribute("AnimatorReady") == true, "TrainingWorldVisualAnimator did not report AnimatorReady")
task.wait(3.2)

local grounds = workspace:WaitForChild("AscensionGrounds", 10)
assert(grounds, "AscensionGrounds missing")
local phase03 = grounds:WaitForChild("Phase03EnvironmentalFeedback", 10)
assert(phase03, "Phase03EnvironmentalFeedback missing")

local centralRing = phase03:WaitForChild("CentralPlaza", 10):WaitForChild("CentralSlowShardRing", 10)
local startCFrame = centralRing:GetPivot()
task.wait(1.25)
local endCFrame = centralRing:GetPivot()

local movedStuds = (startCFrame.Position - endCFrame.Position).Magnitude
local lookDelta = (startCFrame.LookVector - endCFrame.LookVector).Magnitude

local function countDescendantTags(tagName)
	local count = 0
	for _, instance in ipairs(CollectionService:GetTagged(tagName)) do
		if instance:IsDescendantOf(phase03) then
			count += 1
		end
	end
	return count
end

return HttpService:JSONEncode({
	animatorReady = animator:GetAttribute("AnimatorReady"),
	pulseCount = animator:GetAttribute("PulseCount"),
	transformCount = animator:GetAttribute("TransformCount"),
	promptFeedbackCount = animator:GetAttribute("PromptFeedbackCount"),
	challengeFeedbackStations = animator:GetAttribute("ChallengeFeedbackStations"),
	tagCounts = {
		pulse = countDescendantTags("ZTH_AmbientPulse"),
		float = countDescendantTags("ZTH_AmbientFloat"),
		rotate = countDescendantTags("ZTH_AmbientRotate"),
		flicker = countDescendantTags("ZTH_AmbientFlicker"),
		particle = countDescendantTags("ZTH_AmbientParticle"),
		promptFeedback = countDescendantTags("ZTH_PromptFeedback"),
		challengeFeedback = countDescendantTags("ZTH_ChallengeFeedback"),
	},
	centralRingMotion = {
		movedStuds = math.round(movedStuds * 1000) / 1000,
		lookDelta = math.round(lookDelta * 1000) / 1000,
		changed = movedStuds > 0.01 or lookDelta > 0.01,
	},
})
