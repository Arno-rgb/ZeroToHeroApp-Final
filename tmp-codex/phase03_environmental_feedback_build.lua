local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local TAG_PULSE = "ZTH_AmbientPulse"
local TAG_FLOAT = "ZTH_AmbientFloat"
local TAG_ROTATE = "ZTH_AmbientRotate"
local TAG_FLICKER = "ZTH_AmbientFlicker"
local TAG_PARTICLE = "ZTH_AmbientParticle"
local TAG_PROMPT_FEEDBACK = "ZTH_PromptFeedback"
local TAG_CHALLENGE_FEEDBACK = "ZTH_ChallengeFeedback"

local OVERLAY_NAME = "Phase03EnvironmentalFeedback"

local grounds = Workspace:WaitForChild("AscensionGrounds", 15)
assert(grounds, "Workspace.AscensionGrounds missing")

local existing = grounds:FindFirstChild(OVERLAY_NAME)
if existing then
	existing:Destroy()
end

local overlay = Instance.new("Folder")
overlay.Name = OVERLAY_NAME
overlay.Parent = grounds
overlay:SetAttribute("Phase", "0.3")
overlay:SetAttribute("Purpose", "Client-side environmental animation and visual feedback anchors")

local counts = {
	baseParts = 0,
	lights = 0,
	particles = 0,
	models = 0,
}

local function tag(instance, ...)
	for _, tagName in ipairs({ ... }) do
		CollectionService:AddTag(instance, tagName)
	end
end

local function setAttributes(instance, attributes)
	if not attributes then
		return
	end
	for name, value in pairs(attributes) do
		instance:SetAttribute(name, value)
	end
end

local function makeFolder(parent, name)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function makeModel(parent, name, attributes)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	setAttributes(model, attributes)
	counts.models += 1
	return model
end

local function setupPart(part)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	counts.baseParts += 1
	return part
end

local function makePart(parent, name, size, cframe, color, material, transparency, attributes)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Transparency = transparency or 0
	setupPart(part)
	part.Parent = parent
	setAttributes(part, attributes)
	return part
end

local function makeBall(parent, name, size, cframe, color, material, transparency, attributes)
	local part = makePart(parent, name, size, cframe, color, material or Enum.Material.Glass, transparency or 0.25, attributes)
	part.Shape = Enum.PartType.Ball
	return part
end

local function makeCylinder(parent, name, size, cframe, color, material, transparency, attributes)
	local part = makePart(parent, name, size, cframe, color, material or Enum.Material.SmoothPlastic, transparency or 0.2, attributes)
	part.Shape = Enum.PartType.Cylinder
	return part
end

local function makeLight(parent, name, color, brightness, range, attributes)
	local light = Instance.new("PointLight")
	light.Name = name
	light.Color = color
	light.Brightness = brightness
	light.Range = range
	light.Shadows = false
	light.Parent = parent
	setAttributes(light, attributes)
	counts.lights += 1
	return light
end

local function makeEmitter(parent, name, color, count, interval, attributes)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = name
	emitter.Enabled = false
	emitter.Rate = 0
	emitter.Lifetime = NumberRange.new(0.55, 1.05)
	emitter.Speed = NumberRange.new(4, 8)
	emitter.SpreadAngle = Vector2.new(38, 38)
	emitter.Acceleration = Vector3.new(0, 3, 0)
	emitter.Drag = 4
	emitter.Color = ColorSequence.new(color)
	emitter.LightEmission = 0.55
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.12),
		NumberSequenceKeypoint.new(0.55, 0.07),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(0.75, 0.35),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter:SetAttribute("ZTHEmitCount", count)
	emitter:SetAttribute("ZTHEmitInterval", interval)
	setAttributes(emitter, attributes)
	emitter.Parent = parent
	tag(emitter, TAG_PARTICLE)
	counts.particles += 1
	return emitter
end

local function makeHorizontalRing(parent, name, center, radius, segmentCount, color, material, transparency, attributes)
	local model = makeModel(parent, name, attributes)
	for index = 1, segmentCount do
		local angle = (math.pi * 2 / segmentCount) * index
		local position = center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local segmentLength = (math.pi * 2 * radius / segmentCount) * 0.72
		makePart(
			model,
			string.format("%sSegment%02d", name, index),
			Vector3.new(segmentLength, 0.22, 1.15),
			CFrame.new(position) * CFrame.Angles(0, -angle, 0),
			color,
			material,
			transparency
		)
	end
	return model
end

local function makeGateLights(parent, prefix, center, width, height, color, stationId)
	local leftPost = makePart(parent, prefix .. "LeftPost", Vector3.new(2.4, height, 2.4), CFrame.new(center + Vector3.new(-width / 2, height / 2, 0)), color, Enum.Material.SmoothPlastic, 0.08)
	local rightPost = makePart(parent, prefix .. "RightPost", Vector3.new(2.4, height, 2.4), CFrame.new(center + Vector3.new(width / 2, height / 2, 0)), color, Enum.Material.SmoothPlastic, 0.08)
	local leftLamp = makeBall(leftPost, prefix .. "LeftLamp", Vector3.new(4.6, 4.6, 4.6), CFrame.new(center + Vector3.new(-width / 2, height + 3, 0)), color, Enum.Material.Neon, 0.16, {
		ZTHCycleSeconds = 1.85,
		ZTHPulseLightMax = 2.4,
	})
	local rightLamp = makeBall(rightPost, prefix .. "RightLamp", Vector3.new(4.6, 4.6, 4.6), CFrame.new(center + Vector3.new(width / 2, height + 3, 0)), color, Enum.Material.Neon, 0.16, {
		ZTHCycleSeconds = 1.85,
		ZTHPhaseOffset = 0.42,
		ZTHPulseLightMax = 2.4,
	})
	makeLight(leftLamp, prefix .. "LeftLight", color, 1.1, 22)
	makeLight(rightLamp, prefix .. "RightLight", color, 1.1, 22)
	tag(leftLamp, TAG_PULSE)
	tag(rightLamp, TAG_PULSE)
	if stationId then
		leftLamp:SetAttribute("StationId", stationId)
		rightLamp:SetAttribute("StationId", stationId)
		tag(leftLamp, TAG_CHALLENGE_FEEDBACK)
		tag(rightLamp, TAG_CHALLENGE_FEEDBACK)
	end
	return leftLamp, rightLamp
end

local function makeBanner(parent, name, center, color, accent, attributes)
	local model = makeModel(parent, name, attributes)
	local pole = makePart(model, name .. "Pole", Vector3.new(1.1, 18, 1.1), CFrame.new(center + Vector3.new(0, 9, 0)), Color3.fromRGB(82, 77, 70), Enum.Material.Wood, 0)
	makePart(model, name .. "ClothA", Vector3.new(7, 9, 0.42), CFrame.new(center + Vector3.new(3.9, 14, 0)), color, Enum.Material.Fabric, 0.04)
	makePart(model, name .. "ClothB", Vector3.new(5.2, 5.2, 0.38), CFrame.new(center + Vector3.new(4.8, 7.7, 0)), accent, Enum.Material.Fabric, 0.08)
	pole:SetAttribute("ZTHBaseTransparency", 0)
	return model
end

local central = makeFolder(overlay, "CentralPlaza")
do
	local crystal = makeBall(central, "CentralCrystalBloom", Vector3.new(12, 18, 12), CFrame.new(0, 20, 0), Color3.fromRGB(71, 219, 255), Enum.Material.Glass, 0.46, {
		ZTHCycleSeconds = 2.2,
		ZTHPulseLightMax = 3.2,
		ZTHPulseTransparencyMin = 0.24,
		ZTHPulseTransparencyMax = 0.58,
	})
	makeLight(crystal, "CentralSoftBloomLight", Color3.fromRGB(91, 228, 255), 1.4, 70, {
		ZTHFlickerBase = 1.2,
		ZTHFlickerAmount = 0.18,
		ZTHFlickerInterval = 0.32,
	})
	tag(crystal, TAG_PULSE)
	tag(crystal:FindFirstChild("CentralSoftBloomLight"), TAG_FLICKER)

	local ring = makeHorizontalRing(central, "CentralSlowShardRing", Vector3.new(0, 15, 0), 24, 18, Color3.fromRGB(87, 222, 255), Enum.Material.Glass, 0.55, {
		ZTHRotateSpeed = 5,
		ZTHFloatHeight = 0.25,
		ZTHFloatSpeed = 0.22,
		ZTHCycleSeconds = 3.1,
		ZTHPulseTransparencyMin = 0.36,
		ZTHPulseTransparencyMax = 0.68,
	})
	tag(ring, TAG_ROTATE, TAG_FLOAT, TAG_PULSE)

	for index, data in ipairs({
		{ angle = 0.2, radius = 17, height = 27 },
		{ angle = 2.35, radius = 21, height = 24 },
		{ angle = 4.45, radius = 19, height = 30 },
	}) do
		local position = Vector3.new(math.cos(data.angle) * data.radius, data.height, math.sin(data.angle) * data.radius)
		local shard = makePart(central, "CentralFloatingShard" .. index, Vector3.new(2.8, 9.5, 2.8), CFrame.new(position) * CFrame.Angles(0.35, data.angle, 0.2), Color3.fromRGB(122, 238, 255), Enum.Material.Glass, 0.28, {
			ZTHFloatHeight = 1.05,
			ZTHFloatSpeed = 0.17 + index * 0.03,
			ZTHRotateSpeed = 10 + index * 2,
			ZTHPhaseOffset = index * 0.42,
			ZTHPulseTransparencyMin = 0.18,
			ZTHPulseTransparencyMax = 0.42,
		})
		tag(shard, TAG_FLOAT, TAG_ROTATE, TAG_PULSE)
	end
end

local power = makeFolder(overlay, "PowerStrengthForge")
do
	local furnaceGlow = makeBall(power, "ForgeFurnaceFlickerGlow", Vector3.new(22, 18, 8), CFrame.new(-150, 17, -118), Color3.fromRGB(255, 129, 34), Enum.Material.Neon, 0.46, {
		StationId = "StrengthForge",
		ZTHCycleSeconds = 1.35,
		ZTHPulseLightMax = 4,
		ZTHPulseTransparencyMin = 0.2,
		ZTHPulseTransparencyMax = 0.62,
	})
	local light = makeLight(furnaceGlow, "ForgeHeatLight", Color3.fromRGB(255, 140, 43), 2.1, 62, {
		ZTHFlickerBase = 2.15,
		ZTHFlickerAmount = 1.15,
		ZTHFlickerInterval = 0.09,
	})
	tag(furnaceGlow, TAG_PULSE, TAG_CHALLENGE_FEEDBACK)
	tag(light, TAG_FLICKER)
	makeEmitter(furnaceGlow, "ForgeSparks", Color3.fromRGB(255, 173, 70), 4, 1.5, { StationId = "StrengthForge" })

	local pad = makeCylinder(power, "PowerTrainingPadPulse", Vector3.new(1.1, 22, 22), CFrame.new(-78, 6.15, -24) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(255, 176, 58), Enum.Material.Neon, 0.62, {
		StationId = "StrengthForge",
		ZTHCycleSeconds = 1.9,
		ZTHPulseTransparencyMin = 0.32,
		ZTHPulseTransparencyMax = 0.74,
	})
	tag(pad, TAG_PULSE, TAG_PROMPT_FEEDBACK, TAG_CHALLENGE_FEEDBACK)

	local hammer = makeModel(power, "ForgeIdleHammer", {
		StationId = "StrengthForge",
		ZTHFloatHeight = 0.35,
		ZTHFloatSpeed = 0.32,
		ZTHRotateAxis = "Z",
		ZTHRotateSpeed = 2.2,
		ZTHCycleSeconds = 2.4,
	})
	makePart(hammer, "ForgeIdleHammerHandle", Vector3.new(2.2, 21, 2.2), CFrame.new(-98, 17, -43) * CFrame.Angles(0, 0, math.rad(22)), Color3.fromRGB(92, 62, 38), Enum.Material.Wood, 0)
	makePart(hammer, "ForgeIdleHammerHead", Vector3.new(11, 4.6, 5.5), CFrame.new(-92.4, 22.1, -43), Color3.fromRGB(115, 118, 125), Enum.Material.Metal, 0.04)
	makeLight(hammer:FindFirstChild("ForgeIdleHammerHead"), "HammerWarmEdgeLight", Color3.fromRGB(255, 135, 53), 0.7, 18)
	tag(hammer, TAG_FLOAT, TAG_ROTATE, TAG_PULSE, TAG_PROMPT_FEEDBACK, TAG_CHALLENGE_FEEDBACK)

	for index, position in ipairs({
		Vector3.new(-126, 10, -42),
		Vector3.new(-178, 10, -52),
	}) do
		local ember = makeBall(power, "BoulderEmberGlow" .. index, Vector3.new(8, 5, 8), CFrame.new(position), Color3.fromRGB(255, 112, 39), Enum.Material.Neon, 0.66, {
			ZTHCycleSeconds = 2.5 + index * 0.2,
			ZTHPulseTransparencyMin = 0.4,
			ZTHPulseTransparencyMax = 0.78,
		})
		tag(ember, TAG_PULSE)
	end

	local prompt = grounds:FindFirstChild("StrengthForge") and grounds.StrengthForge:FindFirstChild("ForgeCore")
	if prompt then
		local trainPrompt = prompt:FindFirstChild("TrainStrengthPrompt")
		if trainPrompt and trainPrompt:IsA("ProximityPrompt") then
			trainPrompt:SetAttribute("StationId", "StrengthForge")
		end
	end
end

local vitality = makeFolder(overlay, "VitalityGuardianGrove")
do
	local heartstone = makeBall(vitality, "GuardianHeartstonePulse", Vector3.new(14, 18, 14), CFrame.new(0, 32, 260), Color3.fromRGB(83, 255, 139), Enum.Material.Glass, 0.34, {
		ZTHCycleSeconds = 2.45,
		ZTHPulseLightMax = 3.1,
		ZTHPulseTransparencyMin = 0.18,
		ZTHPulseTransparencyMax = 0.52,
	})
	makeLight(heartstone, "GuardianHeartstoneLight", Color3.fromRGB(103, 255, 148), 1.2, 58)
	tag(heartstone, TAG_PULSE)

	local shield = makeHorizontalRing(vitality, "GuardianShieldHalo", Vector3.new(0, 30, 260), 22, 20, Color3.fromRGB(109, 255, 162), Enum.Material.Glass, 0.64, {
		ZTHRotateSpeed = 4.5,
		ZTHRotateAxis = "Y",
		ZTHCycleSeconds = 3.2,
		ZTHPulseTransparencyMin = 0.38,
		ZTHPulseTransparencyMax = 0.74,
	})
	tag(shield, TAG_ROTATE, TAG_PULSE)

	local pool = makeCylinder(vitality, "HealingPoolShimmer", Vector3.new(0.6, 38, 38), CFrame.new(0, 5.2, 237) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(75, 226, 190), Enum.Material.Glass, 0.58, {
		ZTHCycleSeconds = 2.0,
		ZTHPulseTransparencyMin = 0.34,
		ZTHPulseTransparencyMax = 0.7,
	})
	tag(pool, TAG_PULSE)

	local motesAnchor = makeBall(vitality, "GuardianMoteAnchor", Vector3.new(2, 2, 2), CFrame.new(0, 18, 250), Color3.fromRGB(91, 255, 134), Enum.Material.Neon, 1, {
		ZTHEmitCount = 4,
	})
	makeEmitter(motesAnchor, "GuardianLeafMotes", Color3.fromRGB(109, 255, 163), 3, 2.0)
end

local agility = makeFolder(overlay, "AgilitySkywardTower")
do
	local beacon = makeBall(agility, "SkywardBeaconPulse", Vector3.new(18, 18, 18), CFrame.new(260, 188, -112), Color3.fromRGB(126, 106, 255), Enum.Material.Neon, 0.34, {
		ZTHCycleSeconds = 1.9,
		ZTHPulseLightMax = 3.5,
		ZTHPulseTransparencyMin = 0.16,
		ZTHPulseTransparencyMax = 0.54,
	})
	makeLight(beacon, "SkywardBeaconLight", Color3.fromRGB(111, 226, 255), 1.6, 86)
	tag(beacon, TAG_PULSE)

	local halo = makeHorizontalRing(agility, "SkywardBeaconHalo", Vector3.new(260, 178, -112), 20, 18, Color3.fromRGB(92, 232, 255), Enum.Material.Glass, 0.62, {
		ZTHRotateSpeed = 7.5,
		ZTHFloatHeight = 0.5,
		ZTHFloatSpeed = 0.18,
		ZTHCycleSeconds = 2.7,
		ZTHPulseTransparencyMin = 0.38,
		ZTHPulseTransparencyMax = 0.72,
	})
	tag(halo, TAG_ROTATE, TAG_FLOAT, TAG_PULSE)

	for index, data in ipairs({
		{ position = Vector3.new(228, 18, -96), color = Color3.fromRGB(101, 232, 255) },
		{ position = Vector3.new(246, 43, -112), color = Color3.fromRGB(147, 112, 255) },
		{ position = Vector3.new(270, 70, -104), color = Color3.fromRGB(101, 232, 255) },
		{ position = Vector3.new(255, 101, -122), color = Color3.fromRGB(147, 112, 255) },
	}) do
		local marker = makeBall(agility, "SkywardRouteMarkerGlow" .. index, Vector3.new(5.5, 5.5, 5.5), CFrame.new(data.position), data.color, Enum.Material.Neon, 0.4, {
			ZTHCycleSeconds = 1.65,
			ZTHPhaseOffset = index * 0.22,
			ZTHPulseTransparencyMin = 0.2,
			ZTHPulseTransparencyMax = 0.58,
		})
		tag(marker, TAG_PULSE)
	end

	local bannerA = makeBanner(agility, "SkywardEntryBannerA", Vector3.new(220, 4, -52), Color3.fromRGB(82, 67, 186), Color3.fromRGB(93, 232, 255), {
		ZTHFloatHeight = 0.28,
		ZTHFloatSpeed = 0.3,
		ZTHRotateSpeed = 1.2,
	})
	local bannerB = makeBanner(agility, "SkywardEntryBannerB", Vector3.new(302, 4, -52), Color3.fromRGB(82, 67, 186), Color3.fromRGB(93, 232, 255), {
		ZTHFloatHeight = 0.24,
		ZTHFloatSpeed = 0.33,
		ZTHRotateSpeed = -1.1,
		ZTHPhaseOffset = 0.7,
	})
	tag(bannerA, TAG_FLOAT, TAG_ROTATE)
	tag(bannerB, TAG_FLOAT, TAG_ROTATE)
end

local endurance = makeFolder(overlay, "EnduranceHeroesTrack")
do
	makeGateLights(endurance, "HeroesLapGate", Vector3.new(-260, 6, 95), 58, 19, Color3.fromRGB(255, 219, 92))

	local startPulse = makePart(endurance, "HeroesStartLinePulse", Vector3.new(64, 0.35, 3.5), CFrame.new(-260, 5.7, 122), Color3.fromRGB(255, 238, 126), Enum.Material.Neon, 0.58, {
		ZTHCycleSeconds = 1.55,
		ZTHPulseTransparencyMin = 0.3,
		ZTHPulseTransparencyMax = 0.72,
	})
	tag(startPulse, TAG_PULSE)

	for index, center in ipairs({
		Vector3.new(-318, 4, 126),
		Vector3.new(-202, 4, 126),
		Vector3.new(-318, 4, 210),
		Vector3.new(-202, 4, 210),
	}) do
		local flag = makeBanner(endurance, "HeroesTrackFlag" .. index, center, Color3.fromRGB(255, 210, 71), Color3.fromRGB(91, 176, 255), {
			ZTHFloatHeight = 0.32,
			ZTHFloatSpeed = 0.27 + index * 0.02,
			ZTHRotateSpeed = (index % 2 == 0 and 1.25 or -1.25),
			ZTHPhaseOffset = index * 0.3,
		})
		tag(flag, TAG_FLOAT, TAG_ROTATE)
	end

	local hydration = makeBall(endurance, "WaterStationShimmer", Vector3.new(9, 9, 9), CFrame.new(-211, 14, 155), Color3.fromRGB(95, 210, 255), Enum.Material.Glass, 0.45, {
		ZTHCycleSeconds = 2.15,
		ZTHPulseTransparencyMin = 0.22,
		ZTHPulseTransparencyMax = 0.58,
	})
	tag(hydration, TAG_PULSE)
end

local control = makeFolder(overlay, "ControlArcaneShrine")
do
	local orb = makeBall(control, "ArcaneOrbPulse", Vector3.new(20, 20, 20), CFrame.new(260, 35, 184), Color3.fromRGB(87, 220, 255), Enum.Material.Glass, 0.32, {
		ZTHCycleSeconds = 2.05,
		ZTHPulseLightMax = 3.7,
		ZTHPulseTransparencyMin = 0.14,
		ZTHPulseTransparencyMax = 0.5,
	})
	makeLight(orb, "ArcaneOrbLight", Color3.fromRGB(92, 226, 255), 1.6, 72)
	tag(orb, TAG_PULSE)

	local ringA = makeHorizontalRing(control, "ArcaneControlledRingA", Vector3.new(260, 35, 184), 29, 22, Color3.fromRGB(87, 220, 255), Enum.Material.Glass, 0.6, {
		ZTHRotateSpeed = 5.2,
		ZTHRotateAxis = "Y",
		ZTHCycleSeconds = 2.9,
		ZTHPulseTransparencyMin = 0.36,
		ZTHPulseTransparencyMax = 0.72,
	})
	local ringB = makeHorizontalRing(control, "ArcaneControlledRingB", Vector3.new(260, 44, 184), 19, 18, Color3.fromRGB(127, 111, 255), Enum.Material.Glass, 0.64, {
		ZTHRotateSpeed = -7.1,
		ZTHRotateAxis = "Y",
		ZTHCycleSeconds = 3.2,
		ZTHPulseTransparencyMin = 0.42,
		ZTHPulseTransparencyMax = 0.76,
	})
	tag(ringA, TAG_ROTATE, TAG_PULSE)
	tag(ringB, TAG_ROTATE, TAG_PULSE)

	local runeRing = makeHorizontalRing(control, "ArcaneRuneFloorShimmer", Vector3.new(260, 5.55, 184), 37, 28, Color3.fromRGB(75, 224, 255), Enum.Material.Glass, 0.66, {
		ZTHRotateSpeed = 1.9,
		ZTHCycleSeconds = 2.15,
		ZTHPulseTransparencyMin = 0.42,
		ZTHPulseTransparencyMax = 0.78,
	})
	tag(runeRing, TAG_ROTATE, TAG_PULSE)

	local moteAnchor = makeBall(control, "ArcaneMoteAnchor", Vector3.new(2, 2, 2), CFrame.new(260, 28, 184), Color3.fromRGB(91, 228, 255), Enum.Material.Neon, 1)
	makeEmitter(moteAnchor, "ArcaneSoftMotes", Color3.fromRGB(91, 228, 255), 3, 2.4)
end

local function collectCounts(root)
	local result = {
		totalDescendants = 0,
		baseParts = 0,
		collidableParts = 0,
		unanchoredParts = 0,
		scripts = 0,
		localScripts = 0,
		moduleScripts = 0,
		remoteEvents = 0,
		remoteFunctions = 0,
		bindables = 0,
		lights = 0,
		particleEmitters = 0,
		neonParts = 0,
	}
	for _, descendant in ipairs(root:GetDescendants()) do
		result.totalDescendants += 1
		if descendant:IsA("BasePart") then
			result.baseParts += 1
			if descendant.CanCollide then
				result.collidableParts += 1
			end
			if not descendant.Anchored then
				result.unanchoredParts += 1
			end
			if descendant.Material == Enum.Material.Neon then
				result.neonParts += 1
			end
		elseif descendant:IsA("Script") then
			result.scripts += 1
		elseif descendant:IsA("LocalScript") then
			result.localScripts += 1
		elseif descendant:IsA("ModuleScript") then
			result.moduleScripts += 1
		elseif descendant:IsA("RemoteEvent") then
			result.remoteEvents += 1
		elseif descendant:IsA("RemoteFunction") then
			result.remoteFunctions += 1
		elseif descendant:IsA("BindableEvent") or descendant:IsA("BindableFunction") then
			result.bindables += 1
		elseif descendant:IsA("Light") then
			result.lights += 1
		elseif descendant:IsA("ParticleEmitter") then
			result.particleEmitters += 1
		end
	end
	return result
end

local tagCounts = {}
for _, tagName in ipairs({
	TAG_PULSE,
	TAG_FLOAT,
	TAG_ROTATE,
	TAG_FLICKER,
	TAG_PARTICLE,
	TAG_PROMPT_FEEDBACK,
	TAG_CHALLENGE_FEEDBACK,
}) do
	local count = 0
	for _, instance in ipairs(CollectionService:GetTagged(tagName)) do
		if instance:IsDescendantOf(overlay) then
			count += 1
		end
	end
	tagCounts[tagName] = count
end

return HttpService:JSONEncode({
	overlay = overlay:GetFullName(),
	created = counts,
	counts = collectCounts(overlay),
	tagCounts = tagCounts,
	strengthPromptStationId = grounds.StrengthForge.ForgeCore.TrainStrengthPrompt:GetAttribute("StationId"),
})
