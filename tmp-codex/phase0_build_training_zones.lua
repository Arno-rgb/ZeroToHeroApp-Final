local HttpService = game:GetService("HttpService")

local grounds = workspace:FindFirstChild("AscensionGrounds")
assert(grounds, "Workspace.AscensionGrounds not found")

local existing = grounds:FindFirstChild("Phase0TrainingZoneRecreation")
if existing then
	existing:Destroy()
end

local root = Instance.new("Model")
root.Name = "Phase0TrainingZoneRecreation"
root:SetAttribute("Phase", "Phase0TrainingZoneRecreation")
root:SetAttribute("AssetSource", "PrimitiveBuilt")
root:SetAttribute("GameplayCritical", false)
root:SetAttribute("Decorative", true)
root.Parent = grounds

local C = {
	StoneDark = Color3.fromRGB(54, 58, 66),
	StoneMid = Color3.fromRGB(82, 88, 96),
	StoneLight = Color3.fromRGB(135, 138, 135),
	PathStone = Color3.fromRGB(148, 143, 128),
	WoodDark = Color3.fromRGB(75, 48, 29),
	WoodMid = Color3.fromRGB(114, 75, 43),
	MetalDark = Color3.fromRGB(42, 45, 50),
	GrassBase = Color3.fromRGB(72, 111, 55),
	WarmLantern = Color3.fromRGB(255, 174, 74),
	PowerPrimary = Color3.fromRGB(232, 111, 28),
	PowerBright = Color3.fromRGB(255, 169, 47),
	PowerDeep = Color3.fromRGB(128, 48, 19),
	VitalityPrimary = Color3.fromRGB(64, 178, 91),
	VitalityBright = Color3.fromRGB(92, 255, 139),
	VitalityDeep = Color3.fromRGB(35, 91, 51),
	AgilityPrimary = Color3.fromRGB(134, 71, 224),
	AgilityBright = Color3.fromRGB(195, 101, 255),
	AgilityCyan = Color3.fromRGB(70, 222, 255),
	EndurancePrimary = Color3.fromRGB(121, 156, 50),
	EnduranceBright = Color3.fromRGB(190, 220, 77),
	TrackEarth = Color3.fromRGB(145, 98, 55),
	ControlPrimary = Color3.fromRGB(51, 169, 227),
	ControlBright = Color3.fromRGB(86, 224, 255),
	ControlDeep = Color3.fromRGB(23, 76, 118),
	Water = Color3.fromRGB(54, 154, 188),
}

local function setMeta(instance, zoneId, mobilePriority)
	instance:SetAttribute("Phase", "Phase0TrainingZoneRecreation")
	instance:SetAttribute("AssetSource", "PrimitiveBuilt")
	instance:SetAttribute("GameplayCritical", false)
	instance:SetAttribute("Decorative", true)
	if zoneId then
		instance:SetAttribute("ZoneId", zoneId)
	end
	if mobilePriority then
		instance:SetAttribute("MobilePriority", mobilePriority)
	end
end

local function model(name, parent, zoneId)
	local m = Instance.new("Model")
	m.Name = name
	setMeta(m, zoneId, "High")
	m.Parent = parent
	return m
end

local function part(name, parent, cf, size, color, material, canCollide, transparency, shape, zoneId)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = canCollide == true
	p.CanTouch = false
	p.CanQuery = canCollide == true
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CFrame = cf
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Transparency = transparency or 0
	if shape then
		p.Shape = shape
	end
	setMeta(p, zoneId, "High")
	p.Parent = parent
	return p
end

local function light(parent, name, color, range, brightness)
	local l = Instance.new("PointLight")
	l.Name = name
	l.Color = color
	l.Range = range
	l.Brightness = brightness
	l.Shadows = false
	l.Parent = parent
	return l
end

local function roadBetween(parent, name, fromPos, toPos, width, color)
	local mid = (fromPos + toPos) * 0.5
	local length = (Vector3.new(fromPos.X, 0, fromPos.Z) - Vector3.new(toPos.X, 0, toPos.Z)).Magnitude + 10
	local cf = CFrame.lookAt(Vector3.new(mid.X, 0.08, mid.Z), Vector3.new(toPos.X, 0.08, toPos.Z))
	return part(name, parent, cf, Vector3.new(width, 0.22, length), color, Enum.Material.Cobblestone, true, 0, nil, "Shared")
end

local function segmentedRing(parent, name, center, radius, width, thickness, segmentCount, color, material, canCollide, zoneId)
	local ring = model(name, parent, zoneId)
	local length = (2 * math.pi * radius / segmentCount) * 0.82
	for i = 1, segmentCount do
		local theta = (i - 1) / segmentCount * math.pi * 2
		local x = center.X + math.cos(theta) * radius
		local z = center.Z + math.sin(theta) * radius
		local tangent = theta + math.pi / 2
		part(
			string.format("Segment%02d", i),
			ring,
			CFrame.new(x, center.Y, z) * CFrame.Angles(0, -tangent, 0),
			Vector3.new(length, thickness, width),
			color,
			material,
			canCollide,
			0,
			nil,
			zoneId
		)
	end
	return ring
end

local function segmentedEllipse(parent, name, center, radiusX, radiusZ, width, thickness, segmentCount, color, material, zoneId)
	local ring = model(name, parent, zoneId)
	local length = (2 * math.pi * math.sqrt((radiusX * radiusX + radiusZ * radiusZ) / 2) / segmentCount) * 0.92
	for i = 1, segmentCount do
		local theta = (i - 1) / segmentCount * math.pi * 2
		local x = center.X + math.cos(theta) * radiusX
		local z = center.Z + math.sin(theta) * radiusZ
		local tangent = math.atan2(radiusZ * math.cos(theta), -radiusX * math.sin(theta))
		part(
			string.format("TrackSegment%02d", i),
			ring,
			CFrame.new(x, center.Y, z) * CFrame.Angles(0, -tangent, 0),
			Vector3.new(length, thickness, width),
			color,
			material,
			false,
			0,
			nil,
			zoneId
		)
	end
	return ring
end

local function verticalRingXY(parent, name, center, radius, thickness, segmentCount, color, zoneId)
	local ring = model(name, parent, zoneId)
	local length = (2 * math.pi * radius / segmentCount) * 0.82
	for i = 1, segmentCount do
		local theta = (i - 1) / segmentCount * math.pi * 2
		local x = center.X + math.cos(theta) * radius
		local y = center.Y + math.sin(theta) * radius
		part(
			string.format("RingSegment%02d", i),
			ring,
			CFrame.new(x, y, center.Z) * CFrame.Angles(0, 0, theta + math.pi / 2),
			Vector3.new(length, thickness, thickness),
			color,
			Enum.Material.Neon,
			false,
			0,
			nil,
			zoneId
		)
	end
	return ring
end

local function verticalRingZY(parent, name, center, radius, thickness, segmentCount, color, zoneId)
	local ring = model(name, parent, zoneId)
	local length = (2 * math.pi * radius / segmentCount) * 0.82
	for i = 1, segmentCount do
		local theta = (i - 1) / segmentCount * math.pi * 2
		local z = center.Z + math.cos(theta) * radius
		local y = center.Y + math.sin(theta) * radius
		part(
			string.format("RingSegment%02d", i),
			ring,
			CFrame.new(center.X, y, z) * CFrame.Angles(theta + math.pi / 2, 0, 0),
			Vector3.new(length, thickness, thickness),
			color,
			Enum.Material.Neon,
			false,
			0,
			nil,
			zoneId
		)
	end
	return ring
end

local function sign(parent, name, pos, lookAt, title, subtitle, accent, zoneId, width)
	local w = width or 24
	local backing = part(name .. "_Backing", parent, CFrame.lookAt(pos, lookAt), Vector3.new(w, 8, 0.55), C.StoneDark, Enum.Material.Slate, false, 0, nil, zoneId)
	part(name .. "_TrimTop", parent, backing.CFrame * CFrame.new(0, 4.25, -0.05), Vector3.new(w + 1.2, 0.5, 0.7), accent, Enum.Material.SmoothPlastic, false, 0, nil, zoneId)
	part(name .. "_TrimBottom", parent, backing.CFrame * CFrame.new(0, -4.25, -0.05), Vector3.new(w + 1.2, 0.5, 0.7), accent, Enum.Material.SmoothPlastic, false, 0, nil, zoneId)
	part(name .. "_PostLeft", parent, backing.CFrame * CFrame.new(-w * 0.45, -5.8, 0), Vector3.new(0.8, 7.2, 0.8), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, zoneId)
	part(name .. "_PostRight", parent, backing.CFrame * CFrame.new(w * 0.45, -5.8, 0), Vector3.new(0.8, 7.2, 0.8), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, zoneId)

	local gui = Instance.new("BillboardGui")
	gui.Name = name .. "_Billboard"
	gui.Adornee = backing
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0
	gui.MaxDistance = 220
	gui.Size = UDim2.fromOffset(320, 104)
	gui.StudsOffset = Vector3.new(0, 0.1, 0)
	gui.Parent = backing

	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = gui

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = accent
	titleLabel.TextStrokeTransparency = 0.35
	titleLabel.Text = title
	titleLabel.Size = UDim2.fromScale(1, 0.58)
	titleLabel.Parent = frame

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "Subtitle"
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Font = Enum.Font.GothamBold
	subtitleLabel.TextScaled = true
	subtitleLabel.TextColor3 = Color3.fromRGB(236, 241, 245)
	subtitleLabel.TextStrokeTransparency = 0.45
	subtitleLabel.Text = subtitle
	subtitleLabel.Position = UDim2.fromScale(0, 0.56)
	subtitleLabel.Size = UDim2.fromScale(1, 0.34)
	subtitleLabel.Parent = frame
	return backing
end

local function torch(parent, name, pos, accent, zoneId)
	part(name .. "_Post", parent, CFrame.new(pos.X, pos.Y + 3.2, pos.Z), Vector3.new(0.7, 6.4, 0.7), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, zoneId)
	local flame = part(name .. "_Flame", parent, CFrame.new(pos.X, pos.Y + 6.8, pos.Z), Vector3.new(1.4, 2.1, 1.4), accent, Enum.Material.Neon, false, 0.05, Enum.PartType.Ball, zoneId)
	light(flame, name .. "_Light", accent, 18, 0.7)
	return flame
end

local function simpleTree(parent, name, pos, scale, zoneId)
	local tree = model(name, parent, zoneId)
	part("Trunk", tree, CFrame.new(pos.X, pos.Y + 5 * scale, pos.Z), Vector3.new(2.2 * scale, 10 * scale, 2.2 * scale), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, zoneId)
	part("CanopyLower", tree, CFrame.new(pos.X, pos.Y + 12 * scale, pos.Z), Vector3.new(11 * scale, 8 * scale, 11 * scale), C.GrassBase, Enum.Material.Grass, false, 0, Enum.PartType.Ball, zoneId)
	part("CanopyUpper", tree, CFrame.new(pos.X, pos.Y + 18 * scale, pos.Z), Vector3.new(8 * scale, 7 * scale, 8 * scale), C.VitalityPrimary, Enum.Material.Grass, false, 0, Enum.PartType.Ball, zoneId)
	return tree
end

local shared = model("SharedHubAndRoads", root, "Shared")
part("CentralPublicPlazaBroadFloor", shared, CFrame.new(0, 0.02, 0), Vector3.new(108, 0.25, 108), C.PathStone, Enum.Material.Cobblestone, true, 0, nil, "Shared")
segmentedRing(shared, "CentralPlazaOuterReadRing", Vector3.new(0, 0.22, 0), 54, 3.8, 0.28, 28, C.StoneLight, Enum.Material.Slate, false, "Shared")
segmentedRing(shared, "CentralPlazaBlueWayfindingRing", Vector3.new(0, 0.32, 0), 36, 1.2, 0.25, 24, C.ControlBright, Enum.Material.Neon, false, "Shared")
roadBetween(shared, "NorthBrokenGatePublicRoad", Vector3.new(0, 0, -8), Vector3.new(0, 0, -150), 24, C.PathStone)
roadBetween(shared, "SouthGuardianPublicRoad", Vector3.new(0, 0, 30), Vector3.new(0, 0, 175), 24, C.PathStone)
roadBetween(shared, "PowerPublicRoad", Vector3.new(-24, 0, -16), Vector3.new(-112, 0, -58), 22, C.PathStone)
roadBetween(shared, "AgilityPublicRoad", Vector3.new(28, 0, -14), Vector3.new(135, 0, -58), 22, C.PathStone)
roadBetween(shared, "EndurancePublicRoad", Vector3.new(-30, 0, 28), Vector3.new(-140, 0, 105), 22, C.PathStone)
roadBetween(shared, "ControlPublicRoad", Vector3.new(30, 0, 28), Vector3.new(140, 0, 105), 22, C.PathStone)

-- Power / Strength Forge
local power = model("Power_StrengthForge", root, "Power")
part("PowerDistrictFloor_150x115", power, CFrame.new(-135, 0.05, -65), Vector3.new(150, 0.3, 115), Color3.fromRGB(93, 74, 57), Enum.Material.Ground, true, 0, nil, "Power")
part("PowerCentralStoneYard", power, CFrame.new(-123, 0.22, -49), Vector3.new(108, 0.28, 78), C.StoneMid, Enum.Material.Cobblestone, true, 0, nil, "Power")
part("ForgeFacadeMainWall", power, CFrame.new(-135, 16, -120), Vector3.new(64, 32, 10), C.StoneDark, Enum.Material.Slate, false, 0, nil, "Power")
part("ForgeFacadeTopCap", power, CFrame.new(-135, 34, -120), Vector3.new(70, 5, 12), C.StoneMid, Enum.Material.Slate, false, 0, nil, "Power")
part("ForgeTowerLeft", power, CFrame.new(-173, 21, -119), Vector3.new(14, 42, 14), C.StoneDark, Enum.Material.Slate, false, 0, nil, "Power")
part("ForgeTowerRight", power, CFrame.new(-97, 21, -119), Vector3.new(14, 42, 14), C.StoneDark, Enum.Material.Slate, false, 0, nil, "Power")
part("ForgeChimneyLeft", power, CFrame.new(-153, 43, -126), Vector3.new(8, 48, 8), C.MetalDark, Enum.Material.Metal, false, 0, nil, "Power")
part("ForgeChimneyRight", power, CFrame.new(-117, 43, -126), Vector3.new(8, 48, 8), C.MetalDark, Enum.Material.Metal, false, 0, nil, "Power")
local furnace = part("ForgeFurnaceDistantGlow", power, CFrame.new(-135, 15, -114), Vector3.new(20, 20, 1), C.PowerBright, Enum.Material.Neon, false, 0.05, nil, "Power")
light(furnace, "ForgeFurnaceMobileSafeLight", C.PowerBright, 38, 1.5)
part("ForgeArchTop", power, CFrame.new(-135, 27, -112.5), Vector3.new(28, 8, 3), C.StoneMid, Enum.Material.Slate, false, 0, nil, "Power")
part("ForgeArchLeft", power, CFrame.new(-150, 15, -112.5), Vector3.new(5, 24, 3), C.StoneMid, Enum.Material.Slate, false, 0, nil, "Power")
part("ForgeArchRight", power, CFrame.new(-120, 15, -112.5), Vector3.new(5, 24, 3), C.StoneMid, Enum.Material.Slate, false, 0, nil, "Power")
part("ForgeHammerEmblemHead", power, CFrame.new(-135, 38, -113), Vector3.new(16, 5, 2), C.PowerBright, Enum.Material.Neon, false, 0, nil, "Power")
part("ForgeHammerEmblemHandle", power, CFrame.new(-135, 36, -112.6), Vector3.new(3, 9, 2), C.PowerBright, Enum.Material.Neon, false, 0, nil, "Power")
segmentedRing(power, "ForgeStrikePadAroundExistingPrompt", Vector3.new(-78, 0.5, -24), 17, 3, 0.3, 18, C.PowerBright, Enum.Material.Neon, false, "Power")
part("ForgeStrikeRaisedStonePad", power, CFrame.new(-78, 0.42, -24), Vector3.new(30, 0.55, 30), C.StoneDark, Enum.Material.Slate, true, 0, nil, "Power")
part("ForgeStrikeAnvilBase", power, CFrame.new(-78, 2.2, -24), Vector3.new(6, 3.4, 5), C.MetalDark, Enum.Material.Metal, false, 0, nil, "Power")
part("ForgeStrikeAnvilTop", power, CFrame.new(-78, 4.3, -24), Vector3.new(10, 1.2, 4.2), C.MetalDark, Enum.Material.Metal, false, 0, nil, "Power")
part("TitanLiftPad", power, CFrame.new(-180, 0.38, -45), Vector3.new(38, 0.4, 34), C.StoneDark, Enum.Material.Slate, true, 0, nil, "Power")
for i, z in ipairs({ -56, -45, -34 }) do
	part("TitanLiftBar" .. i, power, CFrame.new(-180, 3.2, z), Vector3.new(22, 0.8, 0.8), C.MetalDark, Enum.Material.Metal, false, 0, nil, "Power")
	part("TitanLiftPlateL" .. i, power, CFrame.new(-193, 3.2, z), Vector3.new(2.8, 5, 5), C.PowerDeep, Enum.Material.Metal, false, 0, nil, "Power")
	part("TitanLiftPlateR" .. i, power, CFrame.new(-167, 3.2, z), Vector3.new(2.8, 5, 5), C.PowerDeep, Enum.Material.Metal, false, 0, nil, "Power")
end
part("BoulderBreakPad", power, CFrame.new(-92, 0.38, -64), Vector3.new(42, 0.4, 34), C.StoneDark, Enum.Material.Slate, true, 0, nil, "Power")
for i, data in ipairs({ { -106, -68, 8 }, { -92, -60, 10 }, { -78, -72, 12 } }) do
	local x, z, s = data[1], data[2], data[3]
	part("BoulderBreakRock" .. i, power, CFrame.new(x, s * 0.45 + 0.6, z), Vector3.new(s, s * 0.9, s), C.StoneMid, Enum.Material.Rock, false, 0, Enum.PartType.Ball, "Power")
	part("BoulderBreakCrack" .. i, power, CFrame.new(x, s * 0.65 + 0.6, z - s * 0.45), Vector3.new(s * 0.1, s * 0.55, 0.25), C.PowerBright, Enum.Material.Neon, false, 0, nil, "Power")
end
sign(power, "PowerZoneSign", Vector3.new(-112, 9, 2), Vector3.new(-112, 7, -60), "STRENGTH FORGE", "Power district", C.PowerBright, "Power", 28)
sign(power, "ForgeStrikeSign", Vector3.new(-58, 7, -7), Vector3.new(-78, 4, -24), "FORGE STRIKE", "Time your hammer", C.PowerBright, "Power", 18)
sign(power, "TitanLiftSign", Vector3.new(-180, 7, -18), Vector3.new(-180, 4, -45), "TITAN LIFT", "Raise the weight", C.PowerBright, "Power", 16)
sign(power, "BoulderBreakSign", Vector3.new(-92, 7, -28), Vector3.new(-92, 4, -64), "BOULDER BREAK", "Smash the stone", C.PowerBright, "Power", 16)
torch(power, "PowerTorchLeft", Vector3.new(-170, 0, -96), C.PowerBright, "Power")
torch(power, "PowerTorchRight", Vector3.new(-100, 0, -96), C.PowerBright, "Power")

-- Vitality / Guardian Grove
local vitality = model("Vitality_GuardianGrove", root, "Vitality")
part("GuardianGroveDistrictFloor_165x125", vitality, CFrame.new(0, 0.05, 185), Vector3.new(165, 0.3, 125), C.GrassBase, Enum.Material.Grass, true, 0, nil, "Vitality")
segmentedRing(vitality, "GuardianPulseMainCircle", Vector3.new(0, 0.48, 185), 31, 3, 0.3, 24, C.VitalityBright, Enum.Material.Neon, false, "Vitality")
part("GuardianTreeRaisedPlatform", vitality, CFrame.new(0, 1.5, 185), Vector3.new(34, 3, 34), C.StoneMid, Enum.Material.Slate, true, 0, nil, "Vitality")
part("GuardianTreeTrunkLower", vitality, CFrame.new(0, 14, 185), Vector3.new(9, 26, 9), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, "Vitality")
part("GuardianTreeTrunkUpper", vitality, CFrame.new(0, 34, 185), Vector3.new(6, 20, 6), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, "Vitality")
for i, data in ipairs({ { -10, 38, 0, 18 }, { 10, 39, 0, 18 }, { 0, 45, -9, 16 }, { 0, 46, 10, 16 }, { 0, 54, 0, 14 } }) do
	part("GuardianCanopyCluster" .. i, vitality, CFrame.new(data[1], data[2], 185 + data[3]), Vector3.new(data[4], data[4] * 0.75, data[4]), C.VitalityPrimary, Enum.Material.Grass, false, 0, Enum.PartType.Ball, "Vitality")
end
local heart = part("GuardianHeartCrystal", vitality, CFrame.new(0, 22, 179.5), Vector3.new(9, 13, 3.5), C.VitalityBright, Enum.Material.Neon, false, 0.08, nil, "Vitality")
light(heart, "GuardianHeartSoftLight", C.VitalityBright, 45, 1.2)
for i, angle in ipairs({ 0, math.pi / 2, math.pi, math.pi * 1.5 }) do
	local x = math.cos(angle) * 25
	local z = math.sin(angle) * 25
	part("GuardianShieldMarker" .. i, vitality, CFrame.new(x, 1.1, 185 + z), Vector3.new(6, 0.45, 6), C.VitalityBright, Enum.Material.Neon, false, 0.08, nil, "Vitality")
end
part("HealingBrewPad", vitality, CFrame.new(-56, 0.4, 185), Vector3.new(42, 0.4, 34), C.VitalityDeep, Enum.Material.Grass, true, 0, nil, "Vitality")
part("HealingBrewShelterBack", vitality, CFrame.new(-56, 8, 171), Vector3.new(28, 16, 2), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, "Vitality")
part("HealingBrewRoof", vitality, CFrame.new(-56, 17, 178), Vector3.new(32, 4, 22), C.VitalityDeep, Enum.Material.WoodPlanks, false, 0, nil, "Vitality")
part("HealingBrewCauldron", vitality, CFrame.new(-56, 3, 187), Vector3.new(8, 4, 8), C.MetalDark, Enum.Material.Metal, false, 0, Enum.PartType.Ball, "Vitality")
for i, x in ipairs({ -68, -44 }) do
	part("HealingBrewTable" .. i, vitality, CFrame.new(x, 2.3, 196), Vector3.new(12, 1.2, 5), C.WoodMid, Enum.Material.WoodPlanks, false, 0, nil, "Vitality")
	for b = 1, 3 do
		part("HealingBottle" .. i .. "_" .. b, vitality, CFrame.new(x - 4 + b * 3, 3.6, 196), Vector3.new(1, 2, 1), C.VitalityBright, Enum.Material.Glass, false, 0.2, nil, "Vitality")
	end
end
segmentedRing(vitality, "ResilienceTrialHazardRing", Vector3.new(56, 0.55, 185), 20, 5, 0.32, 16, C.PowerBright, Enum.Material.SmoothPlastic, false, "Vitality")
part("ResilienceTrialBase", vitality, CFrame.new(56, 0.34, 185), Vector3.new(42, 0.4, 42), C.StoneDark, Enum.Material.Slate, true, 0, nil, "Vitality")
for i = 1, 8 do
	local theta = (i - 1) / 8 * math.pi * 2
	local color = (i % 3 == 0) and C.PowerPrimary or C.VitalityPrimary
	part("ResilienceTile" .. i, vitality, CFrame.new(56 + math.cos(theta) * 12, 0.7, 185 + math.sin(theta) * 12), Vector3.new(7, 0.25, 7), color, Enum.Material.SmoothPlastic, false, 0, nil, "Vitality")
end
part("HealerShelterFloor", vitality, CFrame.new(45, 0.4, 226), Vector3.new(30, 0.4, 22), C.StoneMid, Enum.Material.Slate, true, 0, nil, "Vitality")
part("HealerShelterCabin", vitality, CFrame.new(45, 7, 229), Vector3.new(26, 14, 12), C.WoodMid, Enum.Material.WoodPlanks, false, 0, nil, "Vitality")
part("HealerShelterRoof", vitality, CFrame.new(45, 16, 229), Vector3.new(30, 4, 17), C.VitalityDeep, Enum.Material.WoodPlanks, false, 0, nil, "Vitality")
sign(vitality, "VitalityZoneSign", Vector3.new(0, 9, 123), Vector3.new(0, 8, 185), "GUARDIAN GROVE", "Vitality district", C.VitalityBright, "Vitality", 28)
sign(vitality, "GuardianPulseSign", Vector3.new(-24, 7, 150), Vector3.new(0, 8, 185), "GUARDIAN PULSE", "Shield training", C.VitalityBright, "Vitality", 18)
sign(vitality, "HealingBrewSign", Vector3.new(-78, 7, 206), Vector3.new(-56, 4, 185), "HEALING BREW", "Potion crafting", C.VitalityBright, "Vitality", 16)
sign(vitality, "ResilienceTrialSign", Vector3.new(78, 7, 206), Vector3.new(56, 4, 185), "RESILIENCE TRIAL", "Avoid and endure", C.VitalityBright, "Vitality", 18)

-- Agility / Skyward Tower
local agility = model("Agility_SkywardTower", root, "Agility")
part("SkywardTowerDistrictFloor_160x120", agility, CFrame.new(150, 0.05, -65), Vector3.new(160, 0.3, 120), Color3.fromRGB(73, 67, 91), Enum.Material.Ground, true, 0, nil, "Agility")
part("SkylineEntryPlaza", agility, CFrame.new(150, 0.35, -20), Vector3.new(38, 0.45, 28), C.StoneMid, Enum.Material.Slate, true, 0, nil, "Agility")
local towerCenter = Vector3.new(150, 0, -82)
for level = 1, 4 do
	local y = 8 + (level - 1) * 17
	for i = 1, 8 do
		local theta = (i - 1) / 8 * math.pi * 2
		local x = towerCenter.X + math.cos(theta) * 17
		local z = towerCenter.Z + math.sin(theta) * 17
		part("SkywardTowerL" .. level .. "_Wall" .. i, agility, CFrame.new(x, y, z) * CFrame.Angles(0, -theta, 0), Vector3.new(12, 16, 2), C.StoneDark, Enum.Material.Slate, false, 0, nil, "Agility")
	end
	part("SkywardTowerLevelPlatform" .. level, agility, CFrame.new(towerCenter.X, y + 8.2, towerCenter.Z), Vector3.new(40, 1, 40), C.WoodMid, Enum.Material.WoodPlanks, true, 0, nil, "Agility")
end
segmentedRing(agility, "SkylineRushFinishRing", Vector3.new(towerCenter.X, 84, towerCenter.Z), 18, 1.2, 0.8, 24, C.AgilityBright, Enum.Material.Neon, false, "Agility")
local routePoints = {
	{ 130, 4, -50 }, { 170, 14, -58 }, { 128, 24, -80 }, { 172, 38, -95 }, { 135, 54, -108 }, { 165, 70, -88 },
}
for i, pnt in ipairs(routePoints) do
	part("SkylineRushRoutePlatform" .. i, agility, CFrame.new(pnt[1], pnt[2], pnt[3]), Vector3.new(16, 1, 10), C.WoodMid, Enum.Material.WoodPlanks, true, 0, nil, "Agility")
	part("SkylineRushRail" .. i, agility, CFrame.new(pnt[1], pnt[2] + 3, pnt[3] - 5.2), Vector3.new(16, 3, 0.6), C.AgilityPrimary, Enum.Material.SmoothPlastic, false, 0, nil, "Agility")
end
part("ReactionDashPad", agility, CFrame.new(102, 0.4, -24), Vector3.new(38, 0.45, 38), C.StoneDark, Enum.Material.Slate, true, 0, nil, "Agility")
segmentedRing(agility, "ReactionDashOuterGlow", Vector3.new(102, 0.65, -24), 18, 1.4, 0.25, 16, C.AgilityCyan, Enum.Material.Neon, false, "Agility")
for i, offset in ipairs({ Vector3.new(0, 0, -11), Vector3.new(11, 0, 0), Vector3.new(0, 0, 11), Vector3.new(-11, 0, 0) }) do
	part("ReactionDashTargetPad" .. i, agility, CFrame.new(102 + offset.X, 0.9, -24 + offset.Z), Vector3.new(6, 0.35, 6), C.AgilityBright, Enum.Material.Neon, false, 0.1, nil, "Agility")
end
part("CourierRunStagingFloor", agility, CFrame.new(198, 0.4, -24), Vector3.new(42, 0.45, 32), C.StoneMid, Enum.Material.Slate, true, 0, nil, "Agility")
part("CourierCounter", agility, CFrame.new(198, 3, -36), Vector3.new(20, 4, 5), C.WoodMid, Enum.Material.WoodPlanks, false, 0, nil, "Agility")
for i = 1, 10 do
	local x = 184 + (i % 5) * 7
	local z = -18 + math.floor((i - 1) / 5) * 7
	part("CourierCrate" .. i, agility, CFrame.new(x, 2, z), Vector3.new(4, 4, 4), C.WoodMid, Enum.Material.WoodPlanks, false, 0, nil, "Agility")
end
sign(agility, "AgilityZoneSign", Vector3.new(150, 9, -5), Vector3.new(150, 28, -82), "SKYWARD TOWER", "Agility district", C.AgilityBright, "Agility", 28)
sign(agility, "SkylineRushSign", Vector3.new(127, 9, -39), Vector3.new(150, 28, -82), "SKYLINE RUSH", "Reach the top", C.AgilityBright, "Agility", 18)
sign(agility, "ReactionDashSign", Vector3.new(102, 7, 4), Vector3.new(102, 4, -24), "REACTION DASH", "Hit the pads", C.AgilityCyan, "Agility", 18)
sign(agility, "CourierRunSign", Vector3.new(198, 7, 4), Vector3.new(198, 4, -24), "COURIER RUN", "Grab a parcel", C.AgilityCyan, "Agility", 16)

-- Endurance / Heroes Track
local endurance = model("Endurance_HeroesTrack", root, "Endurance")
part("HeroesTrackDistrictFloor_195x145", endurance, CFrame.new(-150, 0.05, 115), Vector3.new(195, 0.3, 145), C.GrassBase, Enum.Material.Grass, true, 0, nil, "Endurance")
part("HeroesTrackCenterField", endurance, CFrame.new(-150, 0.18, 115), Vector3.new(102, 0.22, 56), Color3.fromRGB(84, 132, 63), Enum.Material.Grass, true, 0, nil, "Endurance")
segmentedEllipse(endurance, "HeroesTrackOvalSurface", Vector3.new(-150, 0.5, 115), 65, 40, 18, 0.3, 36, C.TrackEarth, Enum.Material.Ground, "Endurance")
segmentedEllipse(endurance, "HeroesTrackInnerLaneLine", Vector3.new(-150, 0.72, 115), 52, 30, 0.6, 0.18, 36, Color3.fromRGB(240, 240, 228), Enum.Material.SmoothPlastic, "Endurance")
part("PaceTrialStartLine", endurance, CFrame.new(-150, 0.9, 157), Vector3.new(24, 0.25, 1.2), Color3.fromRGB(240, 240, 228), Enum.Material.SmoothPlastic, false, 0, nil, "Endurance")
part("PaceTrialTimerGateLeft", endurance, CFrame.new(-164, 8, 75), Vector3.new(3, 16, 3), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, "Endurance")
part("PaceTrialTimerGateRight", endurance, CFrame.new(-136, 8, 75), Vector3.new(3, 16, 3), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, "Endurance")
part("PaceTrialTimerCrossbar", endurance, CFrame.new(-150, 16, 75), Vector3.new(34, 3, 3), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, "Endurance")
part("PaceTrialTimerPanel", endurance, CFrame.new(-150, 13, 77), Vector3.new(18, 5, 1), C.EnduranceBright, Enum.Material.Neon, false, 0.1, nil, "Endurance")
part("HurdleCircuitLane", endurance, CFrame.new(-224, 0.45, 115), Vector3.new(14, 0.4, 72), C.StoneMid, Enum.Material.Cobblestone, true, 0, nil, "Endurance")
for i, z in ipairs({ 92, 113, 134 }) do
	part("HurdlePostL" .. i, endurance, CFrame.new(-229, 2.2, z), Vector3.new(0.8, 4.4, 0.8), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, "Endurance")
	part("HurdlePostR" .. i, endurance, CFrame.new(-219, 2.2, z), Vector3.new(0.8, 4.4, 0.8), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, "Endurance")
	part("HurdleBar" .. i, endurance, CFrame.new(-224, 4.1, z), Vector3.new(12, 0.7, 0.7), C.EnduranceBright, Enum.Material.SmoothPlastic, false, 0, nil, "Endurance")
end
part("TeamRelayLane", endurance, CFrame.new(-76, 0.45, 115), Vector3.new(16, 0.4, 68), C.StoneMid, Enum.Material.Cobblestone, true, 0, nil, "Endurance")
for i, z in ipairs({ 96, 115, 134 }) do
	local baton = part("RelayBatonPost" .. i, endurance, CFrame.new(-76, 5, z), Vector3.new(2, 10, 2), (i == 1 and C.ControlBright or i == 2 and C.AgilityBright or C.EnduranceBright), Enum.Material.Neon, false, 0.05, nil, "Endurance")
	light(baton, "RelayBatonLight" .. i, baton.Color, 16, 0.4)
end
part("SpectatorStandBase", endurance, CFrame.new(-96, 1.2, 65), Vector3.new(40, 2.4, 18), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, "Endurance")
for row = 1, 3 do
	part("SpectatorStandRow" .. row, endurance, CFrame.new(-96, 3 + row * 2, 60 + row * 4), Vector3.new(38, 1, 4), C.WoodMid, Enum.Material.WoodPlanks, false, 0, nil, "Endurance")
end
part("WaterStationAwning", endurance, CFrame.new(-220, 8, 165), Vector3.new(22, 3, 14), C.EndurancePrimary, Enum.Material.Fabric, false, 0, nil, "Endurance")
part("WaterStationTable", endurance, CFrame.new(-220, 3, 165), Vector3.new(18, 2, 6), C.WoodMid, Enum.Material.WoodPlanks, false, 0, nil, "Endurance")
sign(endurance, "EnduranceZoneSign", Vector3.new(-150, 9, 178), Vector3.new(-150, 4, 115), "HEROES' TRACK", "Endurance district", C.EnduranceBright, "Endurance", 28)
sign(endurance, "PaceTrialSign", Vector3.new(-130, 7, 160), Vector3.new(-150, 4, 115), "PACE TRIAL", "Run the loop", C.EnduranceBright, "Endurance", 16)
sign(endurance, "HurdleCircuitSign", Vector3.new(-224, 7, 158), Vector3.new(-224, 4, 115), "HURDLE CIRCUIT", "Jump and vault", C.EnduranceBright, "Endurance", 18)
sign(endurance, "TeamRelaySign", Vector3.new(-76, 7, 158), Vector3.new(-76, 4, 115), "TEAM RELAY", "Pass and run", C.EnduranceBright, "Endurance", 16)

-- Control / Arcane Shrine
local control = model("Control_ArcaneShrine", root, "Control")
part("ArcaneShrineDistrictFloor_165x125", control, CFrame.new(150, 0.05, 115), Vector3.new(165, 0.3, 125), Color3.fromRGB(52, 77, 89), Enum.Material.Slate, true, 0, nil, "Control")
segmentedRing(control, "RuneAlignmentOuterPlatform", Vector3.new(150, 0.55, 105), 36, 4, 0.35, 28, C.ControlPrimary, Enum.Material.Slate, false, "Control")
segmentedRing(control, "RuneAlignmentCyanRuneRing", Vector3.new(150, 0.85, 105), 25, 1.2, 0.25, 24, C.ControlBright, Enum.Material.Neon, false, "Control")
part("ArmillaryBase", control, CFrame.new(150, 3, 105), Vector3.new(26, 6, 26), C.StoneDark, Enum.Material.Slate, false, 0, nil, "Control")
segmentedRing(control, "ArmillaryHorizontalRing", Vector3.new(150, 24, 105), 22, 0.9, 0.5, 28, C.ControlBright, Enum.Material.Neon, false, "Control")
verticalRingXY(control, "ArmillaryVerticalRingXY", Vector3.new(150, 26, 105), 22, 0.7, 24, C.ControlBright, "Control")
verticalRingZY(control, "ArmillaryVerticalRingZY", Vector3.new(150, 26, 105), 19, 0.7, 24, C.AgilityCyan, "Control")
local orb = part("CentralControlOrb", control, CFrame.new(150, 26, 105), Vector3.new(7, 7, 7), C.ControlBright, Enum.Material.Neon, false, 0.08, Enum.PartType.Ball, "Control")
light(orb, "CentralControlOrbLight", C.ControlBright, 45, 1.1)
for i, data in ipairs({ { 125, 100 }, { 175, 100 }, { 125, 130 }, { 175, 130 } }) do
	part("RuneConsole" .. i, control, CFrame.new(data[1], 2, data[2]), Vector3.new(5, 4, 5), C.StoneMid, Enum.Material.Slate, false, 0, nil, "Control")
	part("RuneConsoleGlow" .. i, control, CFrame.new(data[1], 4.25, data[2]), Vector3.new(4, 0.3, 4), C.ControlBright, Enum.Material.Neon, false, 0.15, nil, "Control")
end
part("OrbGuidanceWaterChannel", control, CFrame.new(100, 0.45, 130), Vector3.new(48, 0.35, 18), C.Water, Enum.Material.Glass, false, 0.35, nil, "Control")
for i = 1, 6 do
	local x = 82 + i * 7
	local z = 124 + math.sin(i) * 7
	segmentedRing(control, "OrbGuidanceRing" .. i, Vector3.new(x, 5.5, z), 4.5, 0.45, 0.25, 10, C.ControlBright, Enum.Material.Neon, false, "Control")
end
part("OrbGuidanceOrb", control, CFrame.new(104, 5.5, 130), Vector3.new(2.4, 2.4, 2.4), C.ControlBright, Enum.Material.Neon, false, 0.05, Enum.PartType.Ball, "Control")
part("FocusSequencePad", control, CFrame.new(202, 0.5, 135), Vector3.new(38, 0.4, 38), C.StoneDark, Enum.Material.Slate, true, 0, nil, "Control")
segmentedRing(control, "FocusSequenceOuterRunes", Vector3.new(202, 0.85, 135), 18, 1.1, 0.25, 16, C.ControlBright, Enum.Material.Neon, false, "Control")
for i = 1, 8 do
	local theta = (i - 1) / 8 * math.pi * 2
	part("FocusRuneTile" .. i, control, CFrame.new(202 + math.cos(theta) * 13, 1.1, 135 + math.sin(theta) * 13), Vector3.new(4.5, 0.35, 4.5), (i == 1 and C.WarmLantern or C.ControlPrimary), Enum.Material.Neon, false, i == 1 and 0.08 or 0.25, nil, "Control")
end
part("ShrineScholarKioskBase", control, CFrame.new(198, 0.6, 78), Vector3.new(30, 0.5, 20), C.StoneMid, Enum.Material.Slate, true, 0, nil, "Control")
part("ShrineScholarKioskBack", control, CFrame.new(198, 8, 69), Vector3.new(30, 16, 2), C.WoodDark, Enum.Material.WoodPlanks, false, 0, nil, "Control")
part("ShrineScholarKioskRoof", control, CFrame.new(198, 18, 78), Vector3.new(34, 4, 24), C.ControlDeep, Enum.Material.WoodPlanks, false, 0, nil, "Control")
sign(control, "ControlZoneSign", Vector3.new(150, 9, 175), Vector3.new(150, 18, 105), "ARCANE SHRINE", "Control district", C.ControlBright, "Control", 28)
sign(control, "RuneAlignmentSign", Vector3.new(120, 7, 145), Vector3.new(150, 10, 105), "RUNE ALIGNMENT", "Match the rings", C.ControlBright, "Control", 18)
sign(control, "OrbGuidanceSign", Vector3.new(100, 7, 158), Vector3.new(100, 4, 130), "ORB GUIDANCE", "Guide the orb", C.ControlBright, "Control", 16)
sign(control, "FocusSequenceSign", Vector3.new(202, 7, 166), Vector3.new(202, 4, 135), "FOCUS SEQUENCE", "Repeat the runes", C.ControlBright, "Control", 18)

for i, pos in ipairs({
	Vector3.new(-205, 0, -110), Vector3.new(-66, 0, -118), Vector3.new(-82, 0, 236), Vector3.new(82, 0, 235),
	Vector3.new(78, 0, -122), Vector3.new(220, 0, -116), Vector3.new(-244, 0, 54), Vector3.new(-244, 0, 172),
	Vector3.new(234, 0, 68), Vector3.new(234, 0, 172),
}) do
	simpleTree(shared, "PerimeterScaleTree" .. i, pos, (i % 3 == 0) and 1.25 or 1.0, "Shared")
end

local counts = {
	total = 0,
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
	particles = 0,
	beams = 0,
	trails = 0,
}
for _, obj in ipairs(root:GetDescendants()) do
	counts.total += 1
	if obj:IsA("BasePart") then
		counts.baseParts += 1
		if obj.CanCollide then
			counts.collidableParts += 1
		end
		if not obj.Anchored then
			counts.unanchoredParts += 1
		end
	elseif obj:IsA("Script") then
		counts.scripts += 1
	elseif obj:IsA("LocalScript") then
		counts.localScripts += 1
	elseif obj:IsA("ModuleScript") then
		counts.moduleScripts += 1
	elseif obj:IsA("RemoteEvent") then
		counts.remoteEvents += 1
	elseif obj:IsA("RemoteFunction") then
		counts.remoteFunctions += 1
	elseif obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
		counts.bindables += 1
	elseif obj:IsA("Light") then
		counts.lights += 1
	elseif obj:IsA("ParticleEmitter") then
		counts.particles += 1
	elseif obj:IsA("Beam") then
		counts.beams += 1
	elseif obj:IsA("Trail") then
		counts.trails += 1
	end
end

return HttpService:JSONEncode({
	created = root:GetFullName(),
	counts = counts,
	strengthForgePromptMoved = false,
	note = "Static visual training-zone recreation overlay created. Existing prompts, remotes, services, enemy logic, profile data, and rewards were not edited.",
})
