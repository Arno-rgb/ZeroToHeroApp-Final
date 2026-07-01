local root = workspace:WaitForChild("AscensionGrounds"):WaitForChild("Phase0TrainingZoneRecreation")

local existing = root:FindFirstChild("Phase01VisualDeltaPass")
if existing then
	existing:Destroy()
end

local pass = Instance.new("Model")
pass.Name = "Phase01VisualDeltaPass"
pass:SetAttribute("Phase", "Phase0.1TrainingZoneVisualDelta")
pass:SetAttribute("AssetSource", "PrimitiveBuilt")
pass:SetAttribute("GameplayCritical", false)
pass:SetAttribute("Decorative", true)
pass.Parent = root

local colors = {
	StoneDark = Color3.fromRGB(46, 50, 58),
	StoneMid = Color3.fromRGB(76, 82, 91),
	StoneLight = Color3.fromRGB(132, 136, 140),
	PathStone = Color3.fromRGB(148, 143, 128),
	WoodDark = Color3.fromRGB(74, 47, 29),
	WoodMid = Color3.fromRGB(118, 78, 43),
	MetalDark = Color3.fromRGB(42, 45, 50),
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
}

local function model(name, parent, zoneId)
	local container = Instance.new("Model")
	container.Name = name
	container:SetAttribute("Phase", "Phase0.1TrainingZoneVisualDelta")
	container:SetAttribute("AssetSource", "PrimitiveBuilt")
	container:SetAttribute("GameplayCritical", false)
	container:SetAttribute("Decorative", true)
	if zoneId then
		container:SetAttribute("ZoneId", zoneId)
	end
	container.Parent = parent
	return container
end

local function part(parent, name, size, cf, color, material, options)
	options = options or {}
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = options.canCollide == true
	p.CanTouch = false
	p.CanQuery = options.canQuery == true
	p.CastShadow = options.castShadow == true
	p.Transparency = options.transparency or 0
	if options.shape then
		p.Shape = options.shape
	end
	p:SetAttribute("Phase", "Phase0.1TrainingZoneVisualDelta")
	p:SetAttribute("AssetSource", "PrimitiveBuilt")
	p:SetAttribute("GameplayCritical", false)
	p:SetAttribute("Decorative", true)
	p.Parent = parent
	return p
end

local function wedge(parent, name, size, cf, color, material)
	local p = Instance.new("WedgePart")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p:SetAttribute("Phase", "Phase0.1TrainingZoneVisualDelta")
	p:SetAttribute("AssetSource", "PrimitiveBuilt")
	p:SetAttribute("GameplayCritical", false)
	p:SetAttribute("Decorative", true)
	p.Parent = parent
	return p
end

local function light(parent, color, range, brightness)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Range = range
	l.Brightness = brightness
	l.Shadows = false
	l.Parent = parent
	return l
end

local function lookAtFlat(pos, target)
	local flatTarget = Vector3.new(target.X, pos.Y, target.Z)
	if (flatTarget - pos).Magnitude < 0.001 then
		return CFrame.new(pos)
	end
	return CFrame.lookAt(pos, flatTarget)
end

local function sign(parent, name, pos, lookAt, width, height, accent, title, subtitle)
	local backing = part(parent, name .. "_Backing", Vector3.new(width, height, 0.7), lookAtFlat(pos, lookAt), colors.StoneDark, Enum.Material.Slate)
	backing:SetAttribute("MobilePriority", "High")
	part(parent, name .. "_TrimTop", Vector3.new(width + 2, 0.7, 0.9), backing.CFrame * CFrame.new(0, height / 2 + 0.55, -0.02), accent, Enum.Material.SmoothPlastic)
	part(parent, name .. "_TrimBottom", Vector3.new(width + 2, 0.7, 0.9), backing.CFrame * CFrame.new(0, -height / 2 - 0.55, -0.02), accent, Enum.Material.SmoothPlastic)
	part(parent, name .. "_PostLeft", Vector3.new(1.2, height + 7, 1.2), backing.CFrame * CFrame.new(-width / 2 - 1.6, -1.8, 0.3), colors.WoodDark, Enum.Material.WoodPlanks)
	part(parent, name .. "_PostRight", Vector3.new(1.2, height + 7, 1.2), backing.CFrame * CFrame.new(width / 2 + 1.6, -1.8, 0.3), colors.WoodDark, Enum.Material.WoodPlanks)

	local gui = Instance.new("SurfaceGui")
	gui.Name = name .. "_SurfaceGui"
	gui.Face = Enum.NormalId.Front
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0.2
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 24
	gui.Parent = backing

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -12, 0.62, 0)
	titleLabel.Position = UDim2.new(0, 6, 0, 2)
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.Text = title
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = accent
	titleLabel.TextStrokeTransparency = 0.35
	titleLabel.Parent = gui

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "Subtitle"
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Size = UDim2.new(1, -12, 0.32, 0)
	subtitleLabel.Position = UDim2.new(0, 6, 0.64, 0)
	subtitleLabel.Font = Enum.Font.GothamBold
	subtitleLabel.Text = subtitle
	subtitleLabel.TextScaled = true
	subtitleLabel.TextColor3 = Color3.fromRGB(235, 241, 245)
	subtitleLabel.TextStrokeTransparency = 0.6
	subtitleLabel.Parent = gui

	return backing
end

local function ring(parent, name, center, radius, segmentCount, segmentLength, thickness, color, material, yRotationOffset, verticalAxis)
	local container = model(name, parent)
	for i = 1, segmentCount do
		local theta = ((i - 1) / segmentCount) * math.pi * 2
		local x = math.cos(theta) * radius
		local z = math.sin(theta) * radius
		local position = center + Vector3.new(x, 0, z)
		local tangent = Vector3.new(-math.sin(theta), 0, math.cos(theta))
		local cf = CFrame.lookAt(position, position + tangent) * CFrame.Angles(0, math.rad(90) + (yRotationOffset or 0), 0)
		if verticalAxis == "XY" then
			position = center + Vector3.new(math.cos(theta) * radius, math.sin(theta) * radius, 0)
			tangent = Vector3.new(-math.sin(theta), math.cos(theta), 0)
			cf = CFrame.lookAt(position, position + tangent) * CFrame.Angles(0, math.rad(90), 0)
		elseif verticalAxis == "ZY" then
			position = center + Vector3.new(0, math.sin(theta) * radius, math.cos(theta) * radius)
			tangent = Vector3.new(0, math.cos(theta), -math.sin(theta))
			cf = CFrame.lookAt(position, position + tangent) * CFrame.Angles(0, math.rad(90), 0)
		end
		part(container, string.format("Segment%02d", i), Vector3.new(segmentLength, thickness, thickness), cf, color, material)
	end
	return container
end

local function ellipseSegments(parent, name, center, radiusX, radiusZ, segmentCount, segmentLength, width, color, material, y)
	local container = model(name, parent)
	for i = 1, segmentCount do
		local theta = ((i - 1) / segmentCount) * math.pi * 2
		local position = Vector3.new(center.X + radiusX * math.cos(theta), y, center.Z + radiusZ * math.sin(theta))
		local tangent = Vector3.new(-radiusX * math.sin(theta), 0, radiusZ * math.cos(theta)).Unit
		local cf = CFrame.lookAt(position, position + tangent) * CFrame.Angles(0, math.rad(90), 0)
		part(container, string.format("Segment%02d", i), Vector3.new(segmentLength, 0.28, width), cf, color, material)
	end
	return container
end

local function spoke(parent, name, center, angle, length, width, color, material, y)
	local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
	local pos = center + direction * (length / 2)
	local cf = CFrame.lookAt(Vector3.new(pos.X, y, pos.Z), Vector3.new(pos.X, y, pos.Z) + direction) * CFrame.Angles(0, math.rad(90), 0)
	return part(parent, name, Vector3.new(length, 0.25, width), cf, color, material)
end

local function bannerPair(parent, prefix, x, y, z, color)
	part(parent, prefix .. "_Pole", Vector3.new(0.9, 18, 0.9), CFrame.new(x, y + 8, z), colors.MetalDark, Enum.Material.Metal)
	part(parent, prefix .. "_Banner", Vector3.new(5, 13, 0.45), CFrame.new(x, y + 11, z - 0.6), color, Enum.Material.Fabric)
	part(parent, prefix .. "_Trim", Vector3.new(5.6, 1, 0.5), CFrame.new(x, y + 17.5, z - 0.62), colors.PowerBright, Enum.Material.SmoothPlastic)
end

-- Power / Strength Forge
do
	local zone = model("Power_StrengthForge_Delta", pass, "Power")
	local facade = model("TopGap01_LargerForgeFacade", zone)
	part(facade, "Phase01ForgeRearMass", Vector3.new(96, 14, 48), CFrame.new(-135, 24, -134), colors.StoneDark, Enum.Material.Slate)
	part(facade, "Phase01ForgeWideTopCap", Vector3.new(104, 10, 9), CFrame.new(-135, 52, -131), colors.StoneMid, Enum.Material.Slate)
	part(facade, "Phase01ForgeLeftButtress", Vector3.new(16, 18, 58), CFrame.new(-190, 29, -130), colors.StoneMid, Enum.Material.Slate)
	part(facade, "Phase01ForgeRightButtress", Vector3.new(16, 18, 58), CFrame.new(-80, 29, -130), colors.StoneMid, Enum.Material.Slate)
	part(facade, "Phase01ForgeSignalChimneyLeft", Vector3.new(9, 72, 9), CFrame.new(-184, 55, -140), colors.MetalDark, Enum.Material.Metal)
	part(facade, "Phase01ForgeSignalChimneyRight", Vector3.new(9, 72, 9), CFrame.new(-86, 55, -140), colors.MetalDark, Enum.Material.Metal)
	part(facade, "Phase01ForgeChimneyBeaconLeft", Vector3.new(12, 9, 12), CFrame.new(-184, 95, -140), colors.PowerBright, Enum.Material.Neon, { shape = Enum.PartType.Ball, transparency = 0.18 })
	part(facade, "Phase01ForgeChimneyBeaconRight", Vector3.new(12, 9, 12), CFrame.new(-86, 95, -140), colors.PowerBright, Enum.Material.Neon, { shape = Enum.PartType.Ball, transparency = 0.18 })
	part(facade, "Phase01ForgeMegaFurnaceGlow", Vector3.new(36, 30, 1.2), CFrame.new(-135, 24, -125), colors.PowerBright, Enum.Material.Neon, { transparency = 0.04 })
	part(facade, "Phase01ForgeMegaFurnaceCore", Vector3.new(24, 20, 1.4), CFrame.new(-135, 23, -123.8), colors.PowerPrimary, Enum.Material.Neon)
	part(facade, "Phase01ForgeArchHeader", Vector3.new(48, 7, 4), CFrame.new(-135, 41, -122.5), colors.StoneDark, Enum.Material.Slate)
	part(facade, "Phase01ForgeArchLeft", Vector3.new(7, 31, 4), CFrame.new(-160, 24, -122.5), colors.StoneDark, Enum.Material.Slate)
	part(facade, "Phase01ForgeArchRight", Vector3.new(7, 31, 4), CFrame.new(-110, 24, -122.5), colors.StoneDark, Enum.Material.Slate)
	local glow = part(facade, "Phase01ForgeLightAnchor", Vector3.new(1, 1, 1), CFrame.new(-135, 25, -118), colors.PowerBright, Enum.Material.Neon, { transparency = 1 })
	light(glow, colors.PowerBright, 52, 3.4)
	bannerPair(facade, "Phase01ForgeLeftBanner", -168, 18, -119, colors.PowerDeep)
	bannerPair(facade, "Phase01ForgeRightBanner", -102, 18, -119, colors.PowerDeep)
	part(facade, "Phase01ForgeHammerIconHead", Vector3.new(24, 6, 2), CFrame.new(-135, 59, -121), colors.PowerBright, Enum.Material.Neon)
	part(facade, "Phase01ForgeHammerIconHandle", Vector3.new(4, 15, 2), CFrame.new(-135, 54, -120.8), colors.PowerBright, Enum.Material.Neon)
	sign(facade, "Phase01StrengthForgeHubSign", Vector3.new(-135, 17, -101), Vector3.new(0, 8, 0), 34, 10, colors.PowerBright, "STRENGTH FORGE", "Forge power here")

	local promptPart = workspace.AscensionGrounds.StrengthForge.ForgeCore
	local promptPos = promptPart.Position
	local anvil = model("TopGap02_BiggerAnvilPad", zone)
	ring(anvil, "Phase01ForgeStrikeOuterGlow", Vector3.new(promptPos.X, 1.25, promptPos.Z), 24, 24, 6.2, 0.45, colors.PowerBright, Enum.Material.Neon)
	ring(anvil, "Phase01ForgeStrikeStoneCurb", Vector3.new(promptPos.X, 1.05, promptPos.Z), 18, 18, 5.8, 0.7, colors.StoneLight, Enum.Material.Slate)
	part(anvil, "Phase01ForgeStrikeRaisedAnvilBase", Vector3.new(10, 4, 8), CFrame.new(promptPos.X, 3.2, promptPos.Z), colors.MetalDark, Enum.Material.Metal)
	part(anvil, "Phase01ForgeStrikeRaisedAnvilTop", Vector3.new(18, 3, 6), CFrame.new(promptPos.X, 6.5, promptPos.Z), colors.MetalDark, Enum.Material.Metal)
	wedge(anvil, "Phase01ForgeStrikeAnvilHornLeft", Vector3.new(7, 3, 6), CFrame.new(promptPos.X - 10, 6.5, promptPos.Z) * CFrame.Angles(0, 0, math.rad(180)), colors.MetalDark, Enum.Material.Metal)
	wedge(anvil, "Phase01ForgeStrikeAnvilHornRight", Vector3.new(7, 3, 6), CFrame.new(promptPos.X + 10, 6.5, promptPos.Z), colors.MetalDark, Enum.Material.Metal)

	local side = model("TopGap03_ReadableLiftAndBoulderAreas", zone)
	part(side, "Phase01TitanLiftMegaBar", Vector3.new(38, 2, 2), CFrame.new(-176, 4, -37), colors.MetalDark, Enum.Material.Metal)
	for _, offset in ipairs({ -23, 23 }) do
		part(side, "Phase01TitanLiftPlateA" .. offset, Vector3.new(4, 11, 11), CFrame.new(-176 + offset, 4, -37), colors.MetalDark, Enum.Material.Metal)
		part(side, "Phase01TitanLiftPlateB" .. offset, Vector3.new(3, 15, 15), CFrame.new(-176 + offset * 1.08, 4, -37), colors.StoneDark, Enum.Material.Metal)
	end
	part(side, "Phase01TitanLiftRackLeft", Vector3.new(3, 18, 3), CFrame.new(-198, 9, -37), colors.WoodDark, Enum.Material.WoodPlanks)
	part(side, "Phase01TitanLiftRackRight", Vector3.new(3, 18, 3), CFrame.new(-154, 9, -37), colors.WoodDark, Enum.Material.WoodPlanks)
	part(side, "Phase01TitanLiftRackTop", Vector3.new(48, 3, 3), CFrame.new(-176, 18, -37), colors.WoodDark, Enum.Material.WoodPlanks)
	for i, data in ipairs({
		{ pos = Vector3.new(-100, 6, -38), size = Vector3.new(18, 13, 16) },
		{ pos = Vector3.new(-82, 7, -50), size = Vector3.new(15, 15, 15) },
		{ pos = Vector3.new(-110, 5.5, -58), size = Vector3.new(12, 11, 13) },
	}) do
		part(side, "Phase01BoulderBreakMegaRock" .. i, data.size, CFrame.new(data.pos), colors.StoneDark, Enum.Material.Rock, { shape = Enum.PartType.Ball })
		part(side, "Phase01BoulderBreakOrangeCrack" .. i, Vector3.new(0.8, data.size.Y * 0.75, 0.9), CFrame.new(data.pos + Vector3.new(0, 1, -data.size.Z / 2 - 0.15)) * CFrame.Angles(0, 0, math.rad(20 * i)), colors.PowerBright, Enum.Material.Neon)
	end
end

-- Vitality / Guardian Grove
do
	local zone = model("Vitality_GuardianGrove_Delta", pass, "Vitality")
	local tree = model("TopGap01_LargerLifeTree", zone)
	part(tree, "Phase01GuardianGreatRootBase", Vector3.new(40, 3, 40), CFrame.new(0, 1.7, 185), colors.VitalityDeep, Enum.Material.Grass, { transparency = 0.08 })
	part(tree, "Phase01GuardianTrunkReinforcedLower", Vector3.new(14, 38, 14), CFrame.new(0, 22, 185), colors.WoodDark, Enum.Material.WoodPlanks)
	part(tree, "Phase01GuardianTrunkReinforcedUpper", Vector3.new(9, 34, 9), CFrame.new(0, 56, 185), colors.WoodMid, Enum.Material.WoodPlanks)
	part(tree, "Phase01GuardianLifeCrystalCore", Vector3.new(10, 30, 6), CFrame.new(0, 43, 178.5), colors.VitalityBright, Enum.Material.Neon, { transparency = 0.02 })
	local crystalLightAnchor = part(tree, "Phase01GuardianLifeLightAnchor", Vector3.new(1, 1, 1), CFrame.new(0, 45, 179), colors.VitalityBright, Enum.Material.Neon, { transparency = 1 })
	light(crystalLightAnchor, colors.VitalityBright, 48, 2.7)
	for i, data in ipairs({
		{ x = -16, y = 61, z = 185, sx = 28, sy = 18, sz = 28 },
		{ x = 16, y = 62, z = 185, sx = 28, sy = 18, sz = 28 },
		{ x = 0, y = 69, z = 174, sx = 30, sy = 19, sz = 26 },
		{ x = 0, y = 71, z = 198, sx = 30, sy = 18, sz = 26 },
		{ x = 0, y = 82, z = 185, sx = 24, sy = 18, sz = 24 },
	}) do
		part(tree, "Phase01GuardianHighCanopy" .. i, Vector3.new(data.sx, data.sy, data.sz), CFrame.new(data.x, data.y, data.z), i == 5 and colors.VitalityBright or colors.VitalityPrimary, Enum.Material.Grass, { shape = Enum.PartType.Ball })
	end

	local protection = model("TopGap02_ProtectiveRootAndShieldRing", zone)
	for i = 1, 8 do
		local theta = (i - 1) / 8 * math.pi * 2
		local dir = Vector3.new(math.cos(theta), 0, math.sin(theta))
		local pos = Vector3.new(0, 2.8, 185) + dir * 26
		local cf = CFrame.lookAt(pos, pos + dir) * CFrame.Angles(0, math.rad(90), 0)
		part(protection, "Phase01GuardianRootSpoke" .. i, Vector3.new(24, 2.2, 4), cf, colors.WoodDark, Enum.Material.WoodPlanks)
		part(protection, "Phase01GuardianShieldStone" .. i, Vector3.new(4, 12, 2.5), CFrame.new(0, 7, 185) * CFrame.new(dir * 38) * CFrame.Angles(0, -theta, 0), colors.StoneMid, Enum.Material.Slate)
		part(protection, "Phase01GuardianShieldGlow" .. i, Vector3.new(2.5, 6, 0.5), CFrame.new(0, 8, 185) * CFrame.new(dir * 36.6) * CFrame.Angles(0, -theta, 0), colors.VitalityBright, Enum.Material.Neon)
	end

	local signs = model("TopGap03_HubReadableGroveColor", zone)
	sign(signs, "Phase01GuardianGroveHubSign", Vector3.new(0, 15, 122), Vector3.new(0, 8, 0), 34, 10, colors.VitalityBright, "GUARDIAN GROVE", "Grow stronger")
	for _, x in ipairs({ -52, 52 }) do
		part(signs, "Phase01GuardianLargeBannerPole" .. x, Vector3.new(1, 22, 1), CFrame.new(x, 11, 133), colors.WoodDark, Enum.Material.WoodPlanks)
		part(signs, "Phase01GuardianLargeBanner" .. x, Vector3.new(7, 16, 0.45), CFrame.new(x, 14, 132.4), colors.VitalityPrimary, Enum.Material.Fabric)
	end
end

-- Agility / Skyward Tower
do
	local zone = model("Agility_SkywardTower_Delta", pass, "Agility")
	local spire = model("TopGap01_TallerTowerSilhouette", zone)
	part(spire, "Phase01SkywardUpperSpireCore", Vector3.new(12, 42, 12), CFrame.new(150, 104, -80), colors.StoneDark, Enum.Material.Slate)
	part(spire, "Phase01SkywardSpireNeedle", Vector3.new(5, 34, 5), CFrame.new(150, 142, -80), colors.AgilityPrimary, Enum.Material.SmoothPlastic)
	part(spire, "Phase01SkywardTopCrystal", Vector3.new(11, 16, 11), CFrame.new(150, 165, -80), colors.AgilityCyan, Enum.Material.Neon, { shape = Enum.PartType.Ball, transparency = 0.08 })
	local topLight = part(spire, "Phase01SkywardTopLightAnchor", Vector3.new(1, 1, 1), CFrame.new(150, 160, -80), colors.AgilityCyan, Enum.Material.Neon, { transparency = 1 })
	light(topLight, colors.AgilityCyan, 55, 2.6)
	for _, offset in ipairs({
		Vector3.new(10, 0, 0),
		Vector3.new(-10, 0, 0),
		Vector3.new(0, 0, 10),
		Vector3.new(0, 0, -10),
	}) do
		part(spire, "Phase01SkywardVerticalCyanStrip" .. tostring(offset.X) .. "_" .. tostring(offset.Z), Vector3.new(offset.X == 0 and 2 or 1.4, 72, offset.Z == 0 and 2 or 1.4), CFrame.new(150, 92, -80) + offset, colors.AgilityCyan, Enum.Material.Neon)
	end
	sign(spire, "Phase01SkywardTowerHubSign", Vector3.new(150, 18, -5), Vector3.new(0, 8, 0), 32, 10, colors.AgilityBright, "SKYWARD TOWER", "Climb the route")

	local route = model("TopGap02_ClearVerticalRouteMarkers", zone)
	for i = 1, 8 do
		local y = 12 + i * 10
		local x = 132 + (i % 2) * 36
		local z = -41 - i * 5
		part(route, "Phase01SkylineRouteArrowPad" .. i, Vector3.new(15, 0.35, 7), CFrame.new(x, y, z) * CFrame.Angles(0, math.rad((i % 2 == 0) and -35 or 35), 0), i % 2 == 0 and colors.AgilityBright or colors.AgilityCyan, Enum.Material.Neon)
		part(route, "Phase01SkylineSafetyRailGlow" .. i, Vector3.new(16, 1.2, 1), CFrame.new(x, y + 2.4, z - 6), colors.AgilityPrimary, Enum.Material.SmoothPlastic)
	end

	local side = model("TopGap03_ReadableReactionAndCourierAreas", zone)
	part(side, "Phase01ReactionDashStartArchLeft", Vector3.new(3, 18, 3), CFrame.new(89, 9, -42), colors.AgilityPrimary, Enum.Material.SmoothPlastic)
	part(side, "Phase01ReactionDashStartArchRight", Vector3.new(3, 18, 3), CFrame.new(119, 9, -42), colors.AgilityPrimary, Enum.Material.SmoothPlastic)
	part(side, "Phase01ReactionDashStartArchTop", Vector3.new(34, 3, 3), CFrame.new(104, 18, -42), colors.AgilityCyan, Enum.Material.Neon)
	for i = 1, 4 do
		part(side, "Phase01ReactionDashTallTarget" .. i, Vector3.new(5, 14 + i * 2, 5), CFrame.new(88 + i * 9, 7 + i, -13), i % 2 == 0 and colors.AgilityCyan or colors.AgilityBright, Enum.Material.Neon)
	end
	part(side, "Phase01CourierRunTallCraneMast", Vector3.new(4, 32, 4), CFrame.new(211, 16, -40), colors.WoodDark, Enum.Material.WoodPlanks)
	part(side, "Phase01CourierRunTallCraneArm", Vector3.new(34, 3, 3), CFrame.new(196, 31, -40), colors.WoodDark, Enum.Material.WoodPlanks)
	part(side, "Phase01CourierRunHangingParcel", Vector3.new(8, 8, 8), CFrame.new(181, 22, -40), colors.WoodMid, Enum.Material.WoodPlanks)
end

-- Endurance / Heroes' Track
do
	local zone = model("Endurance_HeroesTrack_Delta", pass, "Endurance")
	local gate = model("TopGap01_LargerTimerGate", zone)
	part(gate, "Phase01PaceTrialMegaGateLeft", Vector3.new(5, 38, 5), CFrame.new(-172, 19, 72), colors.WoodDark, Enum.Material.WoodPlanks)
	part(gate, "Phase01PaceTrialMegaGateRight", Vector3.new(5, 38, 5), CFrame.new(-128, 19, 72), colors.WoodDark, Enum.Material.WoodPlanks)
	part(gate, "Phase01PaceTrialMegaGateCrossbar", Vector3.new(52, 5, 5), CFrame.new(-150, 38, 72), colors.WoodDark, Enum.Material.WoodPlanks)
	part(gate, "Phase01PaceTrialMegaTimerPanel", Vector3.new(30, 10, 1), CFrame.new(-150, 30, 75), colors.EnduranceBright, Enum.Material.Neon)
	sign(gate, "Phase01HeroesTrackHubSign", Vector3.new(-150, 17, 182), Vector3.new(0, 8, 0), 34, 10, colors.EnduranceBright, "HEROES' TRACK", "Run the loop")

	local track = model("TopGap02_StrongerOvalAndStartRead", zone)
	ellipseSegments(track, "Phase01TrackOuterBrightCurb", Vector3.new(-150, 0, 115), 76, 50, 40, 12, 1.2, colors.EnduranceBright, Enum.Material.SmoothPlastic, 0.8)
	ellipseSegments(track, "Phase01TrackInnerStoneCurb", Vector3.new(-150, 0, 115), 54, 31, 40, 9, 0.9, colors.StoneLight, Enum.Material.Slate, 0.85)
	ellipseSegments(track, "Phase01TrackWhiteLaneLine", Vector3.new(-150, 0, 115), 65, 40, 40, 7, 0.5, Color3.fromRGB(240, 240, 225), Enum.Material.SmoothPlastic, 1.05)
	part(track, "Phase01PaceTrialBroadStartLine", Vector3.new(42, 0.35, 3), CFrame.new(-150, 1.3, 163), Color3.fromRGB(245, 245, 235), Enum.Material.SmoothPlastic)
	for i = 1, 6 do
		local theta = (i - 1) / 6 * math.pi * 2
		local pos = Vector3.new(-150 + 70 * math.cos(theta), 6, 115 + 45 * math.sin(theta))
		part(track, "Phase01TrackCheckpointFlagPole" .. i, Vector3.new(0.8, 12, 0.8), CFrame.new(pos), colors.WoodDark, Enum.Material.WoodPlanks)
		part(track, "Phase01TrackCheckpointFlag" .. i, Vector3.new(6, 4, 0.35), CFrame.new(pos + Vector3.new(2.5, 3.5, 0)), colors.EnduranceBright, Enum.Material.Fabric)
	end

	local side = model("TopGap03_ReadableSpectatorAndWater", zone)
	part(side, "Phase01SpectatorStandTallBase", Vector3.new(46, 5, 20), CFrame.new(-76, 2.8, 83), colors.WoodDark, Enum.Material.WoodPlanks)
	for i = 1, 4 do
		part(side, "Phase01SpectatorStandLargeRow" .. i, Vector3.new(44, 3, 5), CFrame.new(-76, 6 + i * 3, 73 + i * 4), colors.WoodMid, Enum.Material.WoodPlanks)
	end
	part(side, "Phase01SpectatorStandGreenCanopy", Vector3.new(50, 4, 24), CFrame.new(-76, 24, 93), colors.EndurancePrimary, Enum.Material.Fabric)
	part(side, "Phase01WaterStationTallAwning", Vector3.new(34, 4, 18), CFrame.new(-225, 14, 144), Color3.fromRGB(78, 185, 220), Enum.Material.Fabric)
	part(side, "Phase01WaterStationBackboard", Vector3.new(32, 16, 2), CFrame.new(-225, 8, 136), colors.WoodDark, Enum.Material.WoodPlanks)
	for i = 1, 4 do
		part(side, "Phase01WaterBarrel" .. i, Vector3.new(5, 8, 5), CFrame.new(-239 + i * 8, 4, 148), Color3.fromRGB(75, 120, 145), Enum.Material.WoodPlanks, { shape = Enum.PartType.Cylinder })
	end
end

-- Control / Arcane Shrine
do
	local zone = model("Control_ArcaneShrine_Delta", pass, "Control")
	local armillary = model("TopGap01_LargerOrbAndRings", zone)
	part(armillary, "Phase01ArcaneCentralOrbLarge", Vector3.new(16, 16, 16), CFrame.new(150, 43, 105), colors.ControlBright, Enum.Material.Neon, { shape = Enum.PartType.Ball, transparency = 0.08 })
	local orbLight = part(armillary, "Phase01ArcaneOrbLightAnchor", Vector3.new(1, 1, 1), CFrame.new(150, 43, 105), colors.ControlBright, Enum.Material.Neon, { transparency = 1 })
	light(orbLight, colors.ControlBright, 56, 2.8)
	ring(armillary, "Phase01ArcaneOuterHorizontalRing", Vector3.new(150, 43, 105), 36, 24, 9.5, 0.9, colors.ControlBright, Enum.Material.Neon)
	ring(armillary, "Phase01ArcaneOuterVerticalRingXY", Vector3.new(150, 43, 105), 31, 20, 8, 0.85, colors.ControlPrimary, Enum.Material.SmoothPlastic, 0, "XY")
	ring(armillary, "Phase01ArcaneOuterVerticalRingZY", Vector3.new(150, 43, 105), 31, 20, 8, 0.85, colors.ControlPrimary, Enum.Material.SmoothPlastic, 0, "ZY")

	local rune = model("TopGap02_ClearerRunePad", zone)
	ring(rune, "Phase01ArcaneGroundRuneOuter", Vector3.new(150, 1.15, 105), 33, 24, 8.5, 0.35, colors.ControlBright, Enum.Material.Neon)
	ring(rune, "Phase01ArcaneGroundRuneInner", Vector3.new(150, 1.2, 105), 20, 18, 6.2, 0.3, colors.ControlPrimary, Enum.Material.SmoothPlastic)
	for i = 1, 12 do
		local angle = (i - 1) / 12 * math.pi * 2
		spoke(rune, "Phase01ArcaneRuneSpoke" .. i, Vector3.new(150, 0, 105), angle, 30, 0.6, i % 3 == 0 and colors.ControlBright or colors.ControlPrimary, i % 3 == 0 and Enum.Material.Neon or Enum.Material.SmoothPlastic, 1.28)
		local pos = Vector3.new(150 + 38 * math.cos(angle), 2.2, 105 + 38 * math.sin(angle))
		part(rune, "Phase01ArcaneOuterRuneTile" .. i, Vector3.new(5, 0.5, 5), CFrame.new(pos) * CFrame.Angles(0, -angle, 0), colors.ControlBright, Enum.Material.Neon, { transparency = 0.05 })
	end
	sign(rune, "Phase01ArcaneShrineHubSign", Vector3.new(150, 16, 176), Vector3.new(0, 8, 0), 32, 10, colors.ControlBright, "ARCANE SHRINE", "Align the runes")

	local pillars = model("TopGap03_TallCrystalsAndPillars", zone)
	for i, data in ipairs({
		{ x = 109, z = 75 },
		{ x = 191, z = 75 },
		{ x = 109, z = 139 },
		{ x = 191, z = 139 },
	}) do
		part(pillars, "Phase01ArcaneTallPillar" .. i, Vector3.new(5, 24, 5), CFrame.new(data.x, 12, data.z), colors.StoneMid, Enum.Material.Slate)
		part(pillars, "Phase01ArcaneTallCrystal" .. i, Vector3.new(8, 14, 8), CFrame.new(data.x, 31, data.z), i % 2 == 0 and colors.ControlBright or colors.ControlPrimary, Enum.Material.Neon, { shape = Enum.PartType.Ball, transparency = 0.08 })
	end
end

return "Phase01 visual delta overlay created at " .. pass:GetFullName()
