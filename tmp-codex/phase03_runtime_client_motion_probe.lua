local HttpService = game:GetService("HttpService")

local grounds = workspace:WaitForChild("AscensionGrounds", 10)
local phase03 = grounds:WaitForChild("Phase03EnvironmentalFeedback", 10)

local probes = {
	{
		name = "centralRingSegment",
		instance = phase03.CentralPlaza.CentralSlowShardRing:FindFirstChild("CentralSlowShardRingSegment01"),
	},
	{
		name = "centralShard",
		instance = phase03.CentralPlaza:FindFirstChild("CentralFloatingShard1"),
	},
	{
		name = "skywardHaloSegment",
		instance = phase03.AgilitySkywardTower.SkywardBeaconHalo:FindFirstChild("SkywardBeaconHaloSegment01"),
	},
	{
		name = "arcaneRingSegment",
		instance = phase03.ControlArcaneShrine.ArcaneControlledRingA:FindFirstChild("ArcaneControlledRingASegment01"),
	},
}

local before = {}
for _, probe in ipairs(probes) do
	if probe.instance and probe.instance:IsA("BasePart") then
		before[probe.name] = probe.instance.CFrame
	end
end

task.wait(1.5)

local result = {}
for _, probe in ipairs(probes) do
	if probe.instance and probe.instance:IsA("BasePart") and before[probe.name] then
		local after = probe.instance.CFrame
		local movedStuds = (before[probe.name].Position - after.Position).Magnitude
		local lookDelta = (before[probe.name].LookVector - after.LookVector).Magnitude
		result[probe.name] = {
			movedStuds = math.round(movedStuds * 1000) / 1000,
			lookDelta = math.round(lookDelta * 1000) / 1000,
			changed = movedStuds > 0.01 or lookDelta > 0.01,
		}
	else
		result[probe.name] = {
			missing = true,
		}
	end
end

return HttpService:JSONEncode(result)
