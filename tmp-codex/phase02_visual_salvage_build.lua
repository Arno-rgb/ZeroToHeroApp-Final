local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local PHASE = "Phase0.2VisualSalvage"

local COLORS = {
	Grass = Color3.fromRGB(70, 118, 66),
	GrassDark = Color3.fromRGB(42, 80, 48),
	Stone = Color3.fromRGB(122, 126, 124),
	StoneDark = Color3.fromRGB(54, 58, 66),
	StoneMid = Color3.fromRGB(82, 88, 96),
	Path = Color3.fromRGB(145, 140, 126),
	Wood = Color3.fromRGB(92, 61, 36),
	WoodDark = Color3.fromRGB(61, 41, 27),
	Metal = Color3.fromRGB(46, 48, 52),
	Power = Color3.fromRGB(232, 111, 28),
	PowerBright = Color3.fromRGB(255, 169, 47),
	Vitality = Color3.fromRGB(64, 178, 91),
	VitalityBright = Color3.fromRGB(92, 255, 139),
	Agility = Color3.fromRGB(126, 74, 209),
	AgilityCyan = Color3.fromRGB(70, 222, 255),
	Endurance = Color3.fromRGB(133, 166, 58),
	Track = Color3.fromRGB(145, 91, 48),
	Control = Color3.fromRGB(51, 169, 227),
	ControlBright = Color3.fromRGB(86, 224, 255),
	Danger = Color3.fromRGB(156, 42, 32),
}

local grounds = Workspace:FindFirstChild("AscensionGrounds")
if grounds == nil then
	grounds = Instance.new("Model")
	grounds.Name = "AscensionGrounds"
	grounds.Parent = Workspace
end

local previous = grounds:FindFirstChild("Phase02VisualSalvagePass")
if previous then
	previous:Destroy()
end

local function setAttributes(instance, extra)
	instance:SetAttribute("Phase", PHASE)
	instance:SetAttribute("AssetSource", "PrimitiveBuilt")
	instance:SetAttribute("GameplayCritical", false)
	if extra then
		for key, value in pairs(extra) do
			instance:SetAttribute(key, value)
		end
	end
end

local function hidePreviousVisualLayer(layer)
	if layer == nil then
		return
	end
	layer:SetAttribute("Phase02HiddenBySalvage", true)
	for _, descendant in ipairs(layer:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
			descendant.CastShadow = false
		elseif descendant:IsA("PointLight") or descendant:IsA("SpotLight") or descendant:IsA("SurfaceLight") then
			descendant.Enabled = false
		elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Trail") then
			descendant.Enabled = false
		elseif descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
			descendant.Enabled = false
		end
	end
end

for _, layerName in ipairs({
	"ReferenceSpacingBlockout",
	"Phase0VisualScalePolish",
	"Phase0TrainingZoneRecreation",
}) do
	hidePreviousVisualLayer(grounds:FindFirstChild(layerName))
end

local root = Instance.new("Model")
root.Name = "Phase02VisualSalvagePass"
setAttributes(root, {
	Decorative = true,
	MobilePriority = "High",
})
root.Parent = grounds

local folders = {}
for _, folderName in ipairs({
	"Ground",
	"Roads",
	"CentralPlaza",
	"Districts",
	"Landmarks",
	"Signs",
	"Lighting",
	"Background",
}) do
	local folder = Instance.new("Folder")
	folder.Name = folderName
	setAttributes(folder, { Decorative = true })
	folder.Parent = root
	folders[folderName] = folder
end

local function createPart(parent, name, size, cframe, color, material, canCollide, attributes)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = canCollide == true
	part.CanTouch = false
	part.CanQuery = canCollide == true
	part.CastShadow = attributes and attributes.CastShadow == true or false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	setAttributes(part, attributes)
	part.Parent = parent
	return part
end

local function createLight(parent, name, color, brightness, range)
	local light = Instance.new("PointLight")
	light.Name = name
	light.Color = color
	light.Brightness = brightness
	light.Range = range
	light.Shadows = false
	light.Parent = parent
	return light
end

local function createModel(parent, name, attributes)
	local model = Instance.new("Model")
	model.Name = name
	setAttributes(model, attributes)
	model.Parent = parent
	return model
end

local function createRoad(parent, name, startPosition, endPosition, width, color, material)
	local delta = endPosition - startPosition
	local length = delta.Magnitude
	local midpoint = (startPosition + endPosition) / 2
	local yaw = math.atan2(delta.X, delta.Z)
	local road = createPart(
		parent,
		name,
		Vector3.new(width, 1, length),
		CFrame.new(midpoint) * CFrame.Angles(0, yaw, 0),
		color,
		material or Enum.Material.Cobblestone,
		true,
		{ Decorative = false, MobilePriority = "High" }
	)
	local curbOffset = width / 2 + 1.25
	local right = Vector3.new(math.cos(yaw), 0, -math.sin(yaw))
	for sideIndex, side in ipairs({ -1, 1 }) do
		createPart(
			parent,
			name .. "_Curb" .. sideIndex,
			Vector3.new(1.8, 1.4, length),
			CFrame.new(midpoint + right * curbOffset * side) * CFrame.Angles(0, yaw, 0),
			COLORS.StoneDark,
			Enum.Material.Slate,
			false,
			{ Decorative = true, MobilePriority = "Medium" }
		)
	end
	return road
end

local function createBlockySign(parent, name, position, target, title, accentColor, zoneId)
	local signModel = createModel(parent, name, { ZoneId = zoneId, Decorative = true, MobilePriority = "High" })
	local yaw = math.atan2((target - position).X, (target - position).Z)
	local backing = createPart(
		signModel,
		"Backing",
		Vector3.new(30, 9, 1.2),
		CFrame.new(position) * CFrame.Angles(0, yaw, 0),
		COLORS.StoneDark,
		Enum.Material.Slate,
		false,
		{ ZoneId = zoneId, Decorative = true, MobilePriority = "High" }
	)
	createPart(signModel, "AccentTop", Vector3.new(32, 1, 1.5), backing.CFrame * CFrame.new(0, 4.4, -0.1), accentColor, Enum.Material.SmoothPlastic, false, { ZoneId = zoneId })
	createPart(signModel, "AccentBottom", Vector3.new(32, 1, 1.5), backing.CFrame * CFrame.new(0, -4.4, -0.1), accentColor, Enum.Material.SmoothPlastic, false, { ZoneId = zoneId })
	createPart(signModel, "PostLeft", Vector3.new(2, 14, 2), backing.CFrame * CFrame.new(-13, -7, 0), COLORS.WoodDark, Enum.Material.WoodPlanks, false, { ZoneId = zoneId })
	createPart(signModel, "PostRight", Vector3.new(2, 14, 2), backing.CFrame * CFrame.new(13, -7, 0), COLORS.WoodDark, Enum.Material.WoodPlanks, false, { ZoneId = zoneId })

	local gui = Instance.new("BillboardGui")
	gui.Name = "ReadableTitle"
	gui.Adornee = backing
	gui.AlwaysOnTop = false
	gui.MaxDistance = 220
	gui.Size = UDim2.fromOffset(250, 72)
	gui.StudsOffset = Vector3.new(0, 0, -0.75)
	gui.Parent = backing

	local label = Instance.new("TextLabel")
	label.Name = "Title"
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.Text = title
	label.TextColor3 = Color3.fromRGB(248, 245, 220)
	label.TextScaled = true
	label.TextStrokeTransparency = 0.3
	label.Parent = gui

	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = 18
	constraint.MaxTextSize = 34
	constraint.Parent = label
	return signModel
end

local function createPad(parent, name, center, radius, segmentCount, color, material, canCollide, attributes)
	local model = createModel(parent, name, attributes)
	local segmentLength = (2 * math.pi * radius) / segmentCount * 0.82
	for index = 1, segmentCount do
		local theta = (index - 1) / segmentCount * math.pi * 2
		local x = center.X + math.cos(theta) * radius
		local z = center.Z + math.sin(theta) * radius
		local yaw = -theta
		createPart(
			model,
			string.format("Segment%02d", index),
			Vector3.new(segmentLength, 0.8, radius * 0.18),
			CFrame.new(x, center.Y, z) * CFrame.Angles(0, yaw, 0),
			color,
			material,
			canCollide,
			attributes
		)
	end
	return model
end

local function createTree(parent, name, position, scale, accent)
	local model = createModel(parent, name, { Decorative = true, MobilePriority = "Medium" })
	createPart(model, "TrunkLower", Vector3.new(6 * scale, 22 * scale, 6 * scale), CFrame.new(position + Vector3.new(0, 11 * scale, 0)), COLORS.Wood, Enum.Material.WoodPlanks, false)
	createPart(model, "TrunkUpper", Vector3.new(4 * scale, 18 * scale, 4 * scale), CFrame.new(position + Vector3.new(0, 31 * scale, 0)), COLORS.WoodDark, Enum.Material.WoodPlanks, false)
	for index, offset in ipairs({
		Vector3.new(0, 46, 0),
		Vector3.new(-8, 40, 2),
		Vector3.new(8, 40, -2),
		Vector3.new(0, 54, 0),
		Vector3.new(-2, 47, -10),
		Vector3.new(2, 47, 10),
	}) do
		local canopy = createPart(model, "Canopy" .. index, Vector3.new(20 * scale, 14 * scale, 20 * scale), CFrame.new(position + offset * scale), accent, Enum.Material.Grass, false)
		canopy.Shape = Enum.PartType.Ball
	end
	return model
end

local function createBackgroundPine(parent, name, position, scale)
	local model = createModel(parent, name, { Decorative = true, MobilePriority = "Low" })
	createPart(model, "Trunk", Vector3.new(3 * scale, 16 * scale, 3 * scale), CFrame.new(position + Vector3.new(0, 8 * scale, 0)), COLORS.WoodDark, Enum.Material.WoodPlanks, false)
	for index, offsetY in ipairs({ 18, 27, 36 }) do
		local block = createPart(model, "Needles" .. index, Vector3.new(18 * scale / index, 10 * scale, 18 * scale / index), CFrame.new(position + Vector3.new(0, offsetY * scale, 0)), COLORS.GrassDark, Enum.Material.Grass, false)
		block.Shape = Enum.PartType.Ball
	end
	return model
end

local function createDistrictFloor(parent, name, center, size, color, zoneId)
	local model = createModel(parent, name, { ZoneId = zoneId, Decorative = false, MobilePriority = "High" })
	createPart(model, "WalkableGround", Vector3.new(size.X, 1.2, size.Z), CFrame.new(center), color, Enum.Material.Grass, true, { ZoneId = zoneId, Decorative = false, MobilePriority = "High" })
	local wallY = center.Y - 2.6
	createPart(model, "BackRetainingWall", Vector3.new(size.X, 5, 4), CFrame.new(center.X, wallY, center.Z - size.Z / 2), COLORS.StoneDark, Enum.Material.Slate, false, { ZoneId = zoneId })
	createPart(model, "FrontRetainingWall", Vector3.new(size.X, 5, 4), CFrame.new(center.X, wallY, center.Z + size.Z / 2), COLORS.StoneDark, Enum.Material.Slate, false, { ZoneId = zoneId })
	createPart(model, "LeftRetainingWall", Vector3.new(4, 5, size.Z), CFrame.new(center.X - size.X / 2, wallY, center.Z), COLORS.StoneDark, Enum.Material.Slate, false, { ZoneId = zoneId })
	createPart(model, "RightRetainingWall", Vector3.new(4, 5, size.Z), CFrame.new(center.X + size.X / 2, wallY, center.Z), COLORS.StoneDark, Enum.Material.Slate, false, { ZoneId = zoneId })
	return model
end

-- Global ground and roads
createPart(folders.Ground, "MainTownGrassBase_640x520", Vector3.new(640, 2, 520), CFrame.new(0, -1, 45), COLORS.Grass, Enum.Material.Grass, true, { Decorative = false, MobilePriority = "High" })
createPart(folders.Ground, "NorthCliffBackplate", Vector3.new(620, 42, 16), CFrame.new(0, 20, -220), COLORS.StoneDark, Enum.Material.Rock, false, { Decorative = true, MobilePriority = "Low" })
createPart(folders.Ground, "EastCliffBackplate", Vector3.new(16, 36, 440), CFrame.new(330, 17, 45), COLORS.StoneDark, Enum.Material.Rock, false, { Decorative = true, MobilePriority = "Low" })
createPart(folders.Ground, "WestCliffBackplate", Vector3.new(16, 36, 440), CFrame.new(-330, 17, 45), COLORS.StoneDark, Enum.Material.Rock, false, { Decorative = true, MobilePriority = "Low" })

createPart(folders.CentralPlaza, "CentralPlazaStoneCore", Vector3.new(112, 1.1, 112), CFrame.new(0, 0.15, 0), COLORS.Stone, Enum.Material.Cobblestone, true, { Decorative = false, MobilePriority = "High" })
createPart(folders.CentralPlaza, "CentralPlazaNorthApron", Vector3.new(78, 1.05, 38), CFrame.new(0, 0.18, -74), COLORS.Stone, Enum.Material.Cobblestone, true, { Decorative = false, MobilePriority = "High" })
createPart(folders.CentralPlaza, "CentralPlazaSouthApron", Vector3.new(78, 1.05, 38), CFrame.new(0, 0.18, 74), COLORS.Stone, Enum.Material.Cobblestone, true, { Decorative = false, MobilePriority = "High" })
createPart(folders.CentralPlaza, "CentralPlazaWestApron", Vector3.new(38, 1.05, 78), CFrame.new(-74, 0.18, 0), COLORS.Stone, Enum.Material.Cobblestone, true, { Decorative = false, MobilePriority = "High" })
createPart(folders.CentralPlaza, "CentralPlazaEastApron", Vector3.new(38, 1.05, 78), CFrame.new(74, 0.18, 0), COLORS.Stone, Enum.Material.Cobblestone, true, { Decorative = false, MobilePriority = "High" })
createPart(folders.CentralPlaza, "CentralLowCrystalBase", Vector3.new(18, 5, 18), CFrame.new(0, 3, 0), COLORS.StoneDark, Enum.Material.Slate, false, { Decorative = true, MobilePriority = "High" })
local crystal = createPart(folders.CentralPlaza, "CentralAscensionCrystal_Calm", Vector3.new(10, 34, 10), CFrame.new(0, 23, 0) * CFrame.Angles(0, math.rad(45), 0), COLORS.ControlBright, Enum.Material.Glass, false, { Decorative = true, MobilePriority = "High" })
crystal.Transparency = 0.18
createLight(crystal, "CentralSoftGlow", COLORS.ControlBright, 1.2, 32)

createRoad(folders.Roads, "SpawnToCentralBroadRoad_34", Vector3.new(0, 0.32, 140), Vector3.new(0, 0.32, 55), 34, COLORS.Path)
createRoad(folders.Roads, "CentralToBrokenGateBroadRoad_34", Vector3.new(0, 0.34, -55), Vector3.new(0, 0.34, -176), 34, COLORS.Path)
createRoad(folders.Roads, "CentralToPowerBroadRoad_32", Vector3.new(-50, 0.36, -20), Vector3.new(-118, 0.36, -62), 32, COLORS.Path)
createRoad(folders.Roads, "CentralToVitalityBroadRoad_32", Vector3.new(0, 0.36, 56), Vector3.new(0, 0.36, 190), 32, COLORS.Path)
createRoad(folders.Roads, "CentralToAgilityBroadRoad_32", Vector3.new(58, 0.36, -24), Vector3.new(198, 0.36, -76), 32, COLORS.Path)
createRoad(folders.Roads, "CentralToEnduranceBroadRoad_32", Vector3.new(-58, 0.36, 40), Vector3.new(-188, 0.36, 138), 32, COLORS.Path)
createRoad(folders.Roads, "CentralToControlBroadRoad_32", Vector3.new(58, 0.36, 42), Vector3.new(198, 0.36, 148), 32, COLORS.Path)

-- District ground plates
createDistrictFloor(folders.Districts, "Power_StrengthForge_Ground", Vector3.new(-150, 0, -88), Vector3.new(225, 0, 170), Color3.fromRGB(104, 82, 60), "Power")
createDistrictFloor(folders.Districts, "Vitality_GuardianGrove_Ground", Vector3.new(0, 0, 260), Vector3.new(225, 0, 180), Color3.fromRGB(52, 116, 58), "Vitality")
createDistrictFloor(folders.Districts, "Agility_SkywardTower_Ground", Vector3.new(260, 0, -86), Vector3.new(205, 0, 190), Color3.fromRGB(79, 74, 96), "Agility")
createDistrictFloor(folders.Districts, "Endurance_HeroesTrack_Ground", Vector3.new(-260, 0, 174), Vector3.new(270, 0, 210), Color3.fromRGB(79, 118, 55), "Endurance")
createDistrictFloor(folders.Districts, "Control_ArcaneShrine_Ground", Vector3.new(260, 0, 184), Vector3.new(225, 0, 180), Color3.fromRGB(60, 94, 113), "Control")

-- Power landmark
do
	local model = createModel(folders.Landmarks, "Power_LargeForgeBuilding", { ZoneId = "Power", Decorative = true, MobilePriority = "High" })
	createPart(model, "DeepForgeHall", Vector3.new(108, 38, 34), CFrame.new(-150, 19, -154), COLORS.StoneDark, Enum.Material.Slate, false, { ZoneId = "Power", CastShadow = true })
	createPart(model, "ForgeFrontButtressLeft", Vector3.new(18, 48, 32), CFrame.new(-214, 24, -136), COLORS.StoneMid, Enum.Material.Slate, false, { ZoneId = "Power", CastShadow = true })
	createPart(model, "ForgeFrontButtressRight", Vector3.new(18, 48, 32), CFrame.new(-86, 24, -136), COLORS.StoneMid, Enum.Material.Slate, false, { ZoneId = "Power", CastShadow = true })
	createPart(model, "ForgeHeavyRoof", Vector3.new(126, 10, 42), CFrame.new(-150, 44, -154), COLORS.Metal, Enum.Material.Metal, false, { ZoneId = "Power", CastShadow = true })
	createPart(model, "ForgeChimneyLeft_Massive", Vector3.new(13, 72, 13), CFrame.new(-188, 73, -166), COLORS.Metal, Enum.Material.Metal, false, { ZoneId = "Power", CastShadow = true })
	createPart(model, "ForgeChimneyRight_Massive", Vector3.new(13, 72, 13), CFrame.new(-112, 73, -166), COLORS.Metal, Enum.Material.Metal, false, { ZoneId = "Power", CastShadow = true })
	local furnace = createPart(model, "ControlledFurnaceMouth", Vector3.new(34, 24, 1.2), CFrame.new(-150, 18, -118), COLORS.PowerBright, Enum.Material.Neon, false, { ZoneId = "Power", MobilePriority = "High" })
	createLight(furnace, "FurnaceLocalGlow", COLORS.PowerBright, 2.2, 40)
	createPart(model, "FurnaceStoneArchTop", Vector3.new(46, 8, 5), CFrame.new(-150, 32, -116), COLORS.StoneMid, Enum.Material.Slate, false, { ZoneId = "Power", CastShadow = true })
	createPart(model, "FurnaceStoneArchLeft", Vector3.new(7, 29, 5), CFrame.new(-174, 17, -116), COLORS.StoneMid, Enum.Material.Slate, false, { ZoneId = "Power", CastShadow = true })
	createPart(model, "FurnaceStoneArchRight", Vector3.new(7, 29, 5), CFrame.new(-126, 17, -116), COLORS.StoneMid, Enum.Material.Slate, false, { ZoneId = "Power", CastShadow = true })
	createPart(model, "AnvilYardWalkablePad", Vector3.new(58, 1.2, 54), CFrame.new(-86, 1.1, -28), COLORS.Stone, Enum.Material.Cobblestone, true, { ZoneId = "Power", Decorative = false, MobilePriority = "High" })
	createPart(model, "LargeAnvilBase_KeepPromptClear", Vector3.new(16, 7, 18), CFrame.new(-96, 4.7, -40), COLORS.Metal, Enum.Material.Metal, false, { ZoneId = "Power" })
	createPart(model, "LargeAnvilTop_KeepPromptClear", Vector3.new(30, 5, 10), CFrame.new(-96, 10.7, -40), COLORS.Metal, Enum.Material.Metal, false, { ZoneId = "Power" })
	createPart(model, "TitanLiftSilhouetteBars", Vector3.new(64, 4, 7), CFrame.new(-190, 5.5, -38), COLORS.Metal, Enum.Material.Metal, false, { ZoneId = "Power" })
	createPart(model, "TitanLiftWeightLeft", Vector3.new(10, 18, 18), CFrame.new(-226, 10, -38), COLORS.Metal, Enum.Material.Metal, false, { ZoneId = "Power" })
	createPart(model, "TitanLiftWeightRight", Vector3.new(10, 18, 18), CFrame.new(-154, 10, -38), COLORS.Metal, Enum.Material.Metal, false, { ZoneId = "Power" })
	createPart(model, "BoulderBreakBigRock", Vector3.new(30, 24, 28), CFrame.new(-70, 13, -82) * CFrame.Angles(0, math.rad(17), 0), COLORS.StoneMid, Enum.Material.Rock, false, { ZoneId = "Power", CastShadow = true })
	createPart(model, "BoulderBreakWarmCrack", Vector3.new(3, 19, 1), CFrame.new(-70, 15, -67), COLORS.PowerBright, Enum.Material.Neon, false, { ZoneId = "Power" })
end

-- Vitality landmark
do
	local model = createModel(folders.Landmarks, "Vitality_GiantLifeTreeGrove", { ZoneId = "Vitality", Decorative = true, MobilePriority = "High" })
	createPart(model, "GuardianClearingWalkableCircleBase", Vector3.new(92, 1.2, 92), CFrame.new(0, 1, 260), Color3.fromRGB(74, 138, 72), Enum.Material.Grass, true, { ZoneId = "Vitality", Decorative = false, MobilePriority = "High" })
	createTree(model, "GuardianLifeTree_Massive", Vector3.new(0, 1, 282), 1.45, Color3.fromRGB(50, 150, 72))
	local crystal = createPart(model, "HeartCrystalLarge", Vector3.new(11, 24, 5), CFrame.new(0, 23, 252) * CFrame.Angles(0, math.rad(45), 0), COLORS.VitalityBright, Enum.Material.Neon, false, { ZoneId = "Vitality" })
	createLight(crystal, "LifeCrystalGlow", COLORS.VitalityBright, 1.6, 42)
	for index = 1, 8 do
		local theta = (index - 1) / 8 * math.pi * 2
		local position = Vector3.new(math.cos(theta) * 48, 2.2, 260 + math.sin(theta) * 48)
		local yaw = -theta
		createPart(model, "ProtectiveRootArch" .. index, Vector3.new(24, 3, 5), CFrame.new(position) * CFrame.Angles(0, yaw, 0), COLORS.WoodDark, Enum.Material.WoodPlanks, false, { ZoneId = "Vitality" })
	end
	for index, x in ipairs({ -64, 64 }) do
		createPart(model, "GuardianShelter_" .. index, Vector3.new(34, 18, 22), CFrame.new(x, 9.5, 232), COLORS.Wood, Enum.Material.WoodPlanks, false, { ZoneId = "Vitality", CastShadow = true })
		createPart(model, "GuardianShelterRoof_" .. index, Vector3.new(42, 7, 28), CFrame.new(x, 22, 232), Color3.fromRGB(43, 103, 50), Enum.Material.Grass, false, { ZoneId = "Vitality", CastShadow = true })
	end
end

-- Agility landmark
do
	local model = createModel(folders.Landmarks, "Agility_SkywardTowerSolidRoute", { ZoneId = "Agility", Decorative = true, MobilePriority = "High" })
	createPart(model, "TowerStoneBase", Vector3.new(58, 18, 58), CFrame.new(260, 9.5, -112), COLORS.StoneDark, Enum.Material.Slate, false, { ZoneId = "Agility", CastShadow = true })
	createPart(model, "TowerMidMass", Vector3.new(42, 64, 42), CFrame.new(260, 49, -112), COLORS.StoneMid, Enum.Material.Slate, false, { ZoneId = "Agility", CastShadow = true })
	createPart(model, "TowerUpperMass", Vector3.new(32, 58, 32), CFrame.new(260, 106, -112), COLORS.StoneDark, Enum.Material.Slate, false, { ZoneId = "Agility", CastShadow = true })
	createPart(model, "TowerTopSpire", Vector3.new(18, 42, 18), CFrame.new(260, 156, -112), COLORS.Agility, Enum.Material.Slate, false, { ZoneId = "Agility", CastShadow = true })
	local beacon = createPart(model, "TopCyanFinishBeacon", Vector3.new(10, 20, 10), CFrame.new(260, 188, -112) * CFrame.Angles(0, math.rad(45), 0), COLORS.AgILITYCYAN or COLORS.AgilityCyan, Enum.Material.Neon, false, { ZoneId = "Agility", MobilePriority = "High" })
	createLight(beacon, "TowerTopSoftGlow", COLORS.AgilityCyan, 1.2, 46)
	for index, data in ipairs({
		{ offset = Vector3.new(-44, 18, 18), size = Vector3.new(48, 3, 18) },
		{ offset = Vector3.new(38, 38, -22), size = Vector3.new(44, 3, 18) },
		{ offset = Vector3.new(-36, 60, -30), size = Vector3.new(42, 3, 16) },
		{ offset = Vector3.new(36, 82, 22), size = Vector3.new(40, 3, 16) },
		{ offset = Vector3.new(-28, 108, 20), size = Vector3.new(36, 3, 14) },
	}) do
		createPart(model, "ReadableRoutePlatform" .. index, data.size, CFrame.new(Vector3.new(260, 0, -112) + data.offset), COLORS.Wood, Enum.Material.WoodPlanks, false, { ZoneId = "Agility", MobilePriority = "High" })
		createPart(model, "RouteCyanGuide" .. index, Vector3.new(data.size.X, 0.8, 2), CFrame.new(Vector3.new(260, 0, -112) + data.offset + Vector3.new(0, 2.2, 0)), COLORS.AgilityCyan, Enum.Material.Neon, false, { ZoneId = "Agility" })
	end
	createPart(model, "GroundEntryArchLeft", Vector3.new(6, 30, 6), CFrame.new(232, 15, -38), COLORS.StoneDark, Enum.Material.Slate, false, { ZoneId = "Agility" })
	createPart(model, "GroundEntryArchRight", Vector3.new(6, 30, 6), CFrame.new(288, 15, -38), COLORS.StoneDark, Enum.Material.Slate, false, { ZoneId = "Agility" })
	createPart(model, "GroundEntryArchTop", Vector3.new(68, 6, 7), CFrame.new(260, 31, -38), COLORS.Agility, Enum.Material.Slate, false, { ZoneId = "Agility" })
end

-- Endurance landmark
do
	local model = createModel(folders.Landmarks, "Endurance_OpenOvalTrack", { ZoneId = "Endurance", Decorative = false, MobilePriority = "High" })
	createPart(model, "OpenCenterField", Vector3.new(118, 1, 70), CFrame.new(-260, 1, 174), Color3.fromRGB(71, 132, 58), Enum.Material.Grass, true, { ZoneId = "Endurance", Decorative = false })
	local segmentCount = 32
	local radiusX = 96
	local radiusZ = 62
	for index = 1, segmentCount do
		local theta = (index - 1) / segmentCount * math.pi * 2
		local x = -260 + math.cos(theta) * radiusX
		local z = 174 + math.sin(theta) * radiusZ
		local tangent = math.atan2(radiusZ * math.cos(theta), -radiusX * math.sin(theta))
		createPart(model, string.format("WideTrackSegment%02d", index), Vector3.new(22, 0.9, 23), CFrame.new(x, 1.2, z) * CFrame.Angles(0, tangent, 0), COLORS.Track, Enum.Material.Ground, true, { ZoneId = "Endurance", Decorative = false })
		if index % 2 == 0 then
			createPart(model, string.format("LaneMarker%02d", index), Vector3.new(2, 0.35, 16), CFrame.new(x, 2, z) * CFrame.Angles(0, tangent, 0), Color3.fromRGB(235, 235, 210), Enum.Material.SmoothPlastic, false, { ZoneId = "Endurance" })
		end
	end
	createPart(model, "TimerGateLeftTall", Vector3.new(7, 36, 7), CFrame.new(-286, 19, 91), COLORS.WoodDark, Enum.Material.WoodPlanks, false, { ZoneId = "Endurance", CastShadow = true })
	createPart(model, "TimerGateRightTall", Vector3.new(7, 36, 7), CFrame.new(-234, 19, 91), COLORS.WoodDark, Enum.Material.WoodPlanks, false, { ZoneId = "Endurance", CastShadow = true })
	createPart(model, "TimerGateCrossbarTall", Vector3.new(68, 8, 7), CFrame.new(-260, 38, 91), COLORS.Wood, Enum.Material.WoodPlanks, false, { ZoneId = "Endurance", CastShadow = true })
	local timer = createPart(model, "CalmTimerPanel", Vector3.new(32, 9, 1.2), CFrame.new(-260, 30, 97), COLORS.Endurance, Enum.Material.Neon, false, { ZoneId = "Endurance" })
	createLight(timer, "TimerGateGlow", COLORS.Endurance, 0.9, 30)
	createPart(model, "SpectatorStandLargeBase", Vector3.new(62, 8, 22), CFrame.new(-168, 5, 226), COLORS.Wood, Enum.Material.WoodPlanks, false, { ZoneId = "Endurance", CastShadow = true })
	createPart(model, "WaterStationReadableAwning", Vector3.new(36, 12, 24), CFrame.new(-350, 8, 132), COLORS.Endurance, Enum.Material.Fabric, false, { ZoneId = "Endurance", CastShadow = true })
end

-- Control landmark
do
	local model = createModel(folders.Landmarks, "Control_CalmArcaneShrine", { ZoneId = "Control", Decorative = true, MobilePriority = "High" })
	createPart(model, "ShrineCourtyardWalkable", Vector3.new(110, 1.2, 110), CFrame.new(260, 1.1, 184), Color3.fromRGB(93, 113, 124), Enum.Material.Cobblestone, true, { ZoneId = "Control", Decorative = false })
	createPad(model, "OuterRuneCurb_Subtle", Vector3.new(260, 2.1, 184), 58, 20, COLORS.Control, Enum.Material.SmoothPlastic, false, { ZoneId = "Control", Decorative = true, MobilePriority = "Medium" })
	createPart(model, "ArmillaryStoneBase", Vector3.new(34, 7, 34), CFrame.new(260, 5, 184), COLORS.StoneDark, Enum.Material.Slate, false, { ZoneId = "Control", CastShadow = true })
	local orb = createPart(model, "CentralOrb_LargeCalm", Vector3.new(15, 15, 15), CFrame.new(260, 35, 184), COLORS.ControlBright, Enum.Material.Glass, false, { ZoneId = "Control", MobilePriority = "High" })
	orb.Shape = Enum.PartType.Ball
	orb.Transparency = 0.12
	createLight(orb, "OrbSoftGlow", COLORS.ControlBright, 1.4, 44)
	for ringIndex, radius in ipairs({ 28, 36 }) do
		local ring = createModel(model, "CalmArmillaryRing" .. ringIndex, { ZoneId = "Control", Decorative = true, MobilePriority = "Medium" })
		for index = 1, 16 do
			local theta = (index - 1) / 16 * math.pi * 2
			local x = 260 + math.cos(theta) * radius
			local y = 35 + math.sin(theta) * radius * 0.58
			local yaw = -theta
			createPart(ring, "RingSegment" .. index, Vector3.new(5.8, 1.1, 1.1), CFrame.new(x, y, 184) * CFrame.Angles(0, yaw, 0), ringIndex == 1 and COLORS.Control or COLORS.Stone, ringIndex == 1 and Enum.Material.Neon or Enum.Material.Metal, false, { ZoneId = "Control" })
		end
	end
	for index, offset in ipairs({
		Vector3.new(-48, 0, -48),
		Vector3.new(48, 0, -48),
		Vector3.new(-48, 0, 48),
		Vector3.new(48, 0, 48),
	}) do
		createPart(model, "ShrinePillar" .. index, Vector3.new(9, 30, 9), CFrame.new(Vector3.new(260, 16, 184) + offset), COLORS.StoneDark, Enum.Material.Slate, false, { ZoneId = "Control", CastShadow = true })
		local crystal = createPart(model, "PillarCrystal" .. index, Vector3.new(7, 11, 7), CFrame.new(Vector3.new(260, 38, 184) + offset) * CFrame.Angles(0, math.rad(45), 0), COLORS.ControlBright, Enum.Material.Glass, false, { ZoneId = "Control" })
		crystal.Transparency = 0.2
	end
end

-- Signs
createBlockySign(folders.Signs, "PowerDistrictSign", Vector3.new(-132, 18, 24), Vector3.new(-150, 12, -88), "STRENGTH FORGE", COLORS.PowerBright, "Power")
createBlockySign(folders.Signs, "VitalityDistrictSign", Vector3.new(-46, 18, 164), Vector3.new(0, 18, 260), "GUARDIAN GROVE", COLORS.VitalityBright, "Vitality")
createBlockySign(folders.Signs, "AgilityDistrictSign", Vector3.new(176, 18, 2), Vector3.new(260, 26, -86), "SKYWARD TOWER", COLORS.AgilityCyan, "Agility")
createBlockySign(folders.Signs, "EnduranceDistrictSign", Vector3.new(-206, 18, 110), Vector3.new(-260, 12, 174), "HEROES' TRACK", COLORS.Endurance, "Endurance")
createBlockySign(folders.Signs, "ControlDistrictSign", Vector3.new(190, 18, 128), Vector3.new(260, 20, 184), "ARCANE SHRINE", COLORS.ControlBright, "Control")

-- Background trees and simple town scale markers
local treePositions = {
	Vector3.new(-295, 0, -160),
	Vector3.new(-250, 0, -202),
	Vector3.new(-70, 0, -210),
	Vector3.new(70, 0, -210),
	Vector3.new(230, 0, -200),
	Vector3.new(300, 0, -144),
	Vector3.new(-310, 0, 270),
	Vector3.new(-220, 0, 310),
	Vector3.new(-60, 0, 325),
	Vector3.new(70, 0, 326),
	Vector3.new(220, 0, 315),
	Vector3.new(310, 0, 260),
}
for index, position in ipairs(treePositions) do
	createBackgroundPine(folders.Background, "LargePerimeterPine" .. index, position, 1.25 + (index % 3) * 0.18)
end

-- Calm global lighting nudge for readability. This avoids per-zone global color changes.
Lighting.ClockTime = 14.4
Lighting.Brightness = math.max(Lighting.Brightness, 2)
Lighting.Ambient = Color3.fromRGB(92, 96, 104)
Lighting.OutdoorAmbient = Color3.fromRGB(132, 138, 146)

return "Phase02VisualSalvagePass built; previous visual-only layers hidden; gameplay prompts preserved"
