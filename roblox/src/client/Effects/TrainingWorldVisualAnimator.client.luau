local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local TAG_PULSE = "ZTH_AmbientPulse"
local TAG_FLOAT = "ZTH_AmbientFloat"
local TAG_ROTATE = "ZTH_AmbientRotate"
local TAG_FLICKER = "ZTH_AmbientFlicker"
local TAG_PARTICLE = "ZTH_AmbientParticle"
local TAG_PROMPT_FEEDBACK = "ZTH_PromptFeedback"
local TAG_CHALLENGE_FEEDBACK = "ZTH_ChallengeFeedback"

local DEFAULT_PULSE_CYCLE = 2.6
local DEFAULT_FLOAT_SPEED = 0.45
local DEFAULT_ROTATE_SPEED = 8
local DEFAULT_FLICKER_INTERVAL = 0.11
local NEARBY_PROMPT_DISTANCE = 90

local pulseConnections: { [Instance]: boolean } = {}
local transformItems: { [Instance]: { base: CFrame, phase: number } } = {}
local flickerItems: { [Instance]: { base: number, nextStep: number } } = {}
local particleEmitters: { ParticleEmitter } = {}
local particleEmitterSet: { [ParticleEmitter]: boolean } = {}
local promptFeedbackItems: { Instance } = {}
local promptFeedbackSet: { [Instance]: boolean } = {}
local challengeFeedbackByStation: { [string]: { Instance } } = {}
local challengeFeedbackSet: { [Instance]: boolean } = {}
local connectedPrompts: { [ProximityPrompt]: boolean } = {}

local function updateAnimatorStats()
	script:SetAttribute("PulseCount", #CollectionService:GetTagged(TAG_PULSE))
	script:SetAttribute("FloatCount", #CollectionService:GetTagged(TAG_FLOAT))
	script:SetAttribute("RotateCount", #CollectionService:GetTagged(TAG_ROTATE))
	script:SetAttribute("TransformCount", #CollectionService:GetTagged(TAG_FLOAT) + #CollectionService:GetTagged(TAG_ROTATE))
	script:SetAttribute("ParticleCount", #CollectionService:GetTagged(TAG_PARTICLE))
	script:SetAttribute("PromptFeedbackCount", #promptFeedbackItems)
	script:SetAttribute("ChallengeFeedbackCount", #CollectionService:GetTagged(TAG_CHALLENGE_FEEDBACK))
	script:SetAttribute("ChallengeFeedbackStations", #CollectionService:GetTagged(TAG_CHALLENGE_FEEDBACK))
end

local function getNumber(instance: Instance, name: string, default: number): number
	local value = instance:GetAttribute(name)
	if typeof(value) == "number" then
		return value
	end
	return default
end

local function getString(instance: Instance, name: string, default: string): string
	local value = instance:GetAttribute(name)
	if typeof(value) == "string" and value ~= "" then
		return value
	end
	return default
end

local function getWorldCFrame(instance: Instance): CFrame?
	if instance:IsA("BasePart") then
		return instance.CFrame
	elseif instance:IsA("Model") then
		return instance:GetPivot()
	elseif instance:IsA("Attachment") then
		return instance.WorldCFrame
	end
	return nil
end

local function setWorldCFrame(instance: Instance, cframe: CFrame)
	if instance:IsA("BasePart") then
		instance.CFrame = cframe
	elseif instance:IsA("Model") then
		instance:PivotTo(cframe)
	end
end

local function getWorldPosition(instance: Instance): Vector3?
	local cframe = getWorldCFrame(instance)
	if cframe then
		return cframe.Position
	elseif instance:IsA("Light") or instance:IsA("ParticleEmitter") then
		local parent = instance.Parent
		if parent then
			return getWorldPosition(parent)
		end
	end
	return nil
end

local function collectParts(instance: Instance): { BasePart }
	local parts = {}
	if instance:IsA("BasePart") then
		table.insert(parts, instance)
	end
	for _, descendant in ipairs(instance:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(parts, descendant)
		end
	end
	return parts
end

local function collectLights(instance: Instance): { Light }
	local lights = {}
	if instance:IsA("Light") then
		table.insert(lights, instance)
	end
	for _, descendant in ipairs(instance:GetDescendants()) do
		if descendant:IsA("Light") then
			table.insert(lights, descendant)
		end
	end
	return lights
end

local function getAxis(instance: Instance): Vector3
	local axisName = string.lower(getString(instance, "ZTHRotateAxis", "Y"))
	if axisName == "x" then
		return Vector3.new(1, 0, 0)
	elseif axisName == "z" then
		return Vector3.new(0, 0, 1)
	end
	return Vector3.new(0, 1, 0)
end

local function rotationFromAxis(axis: Vector3, angle: number): CFrame
	if math.abs(axis.X) > 0.5 then
		return CFrame.Angles(angle, 0, 0)
	elseif math.abs(axis.Z) > 0.5 then
		return CFrame.Angles(0, 0, angle)
	end
	return CFrame.Angles(0, angle, 0)
end

local function tweenInstance(instance: Instance, duration: number, properties: { [string]: any })
	local ok = pcall(function()
		local tween = TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), properties)
		tween:Play()
	end)
	return ok
end

local function pulseOnce(instance: Instance, strength: number?)
	local multiplier = strength or 1
	local upDuration = getNumber(instance, "ZTHPulseUpSeconds", 0.42)
	local downDuration = getNumber(instance, "ZTHPulseDownSeconds", 0.62)

	for _, part in ipairs(collectParts(instance)) do
		local baseTransparency = getNumber(part, "ZTHBaseTransparency", part.Transparency)
		local brightTransparency = getNumber(instance, "ZTHPulseTransparencyMin", math.max(0, baseTransparency - 0.18 * multiplier))
		local dimTransparency = getNumber(instance, "ZTHPulseTransparencyMax", math.min(0.78, baseTransparency + 0.08))
		local baseSize = part:GetAttribute("ZTHBaseSize")
		if typeof(baseSize) ~= "Vector3" then
			baseSize = part.Size
			part:SetAttribute("ZTHBaseSize", baseSize)
		end
		local scale = getNumber(instance, "ZTHPulseScale", 1.035 + 0.025 * multiplier)
		tweenInstance(part, upDuration, {
			Transparency = brightTransparency,
			Size = baseSize * scale,
		})
		task.delay(upDuration, function()
			if part.Parent then
				tweenInstance(part, downDuration, {
					Transparency = dimTransparency,
					Size = baseSize,
				})
			end
		end)
	end

	for _, light in ipairs(collectLights(instance)) do
		local baseBrightness = getNumber(light, "ZTHBaseBrightness", light.Brightness)
		local highBrightness = getNumber(instance, "ZTHPulseLightMax", baseBrightness + 0.9 * multiplier)
		local lowBrightness = getNumber(instance, "ZTHPulseLightMin", math.max(0, baseBrightness * 0.72))
		tweenInstance(light, upDuration, { Brightness = highBrightness })
		task.delay(upDuration, function()
			if light.Parent then
				tweenInstance(light, downDuration, { Brightness = lowBrightness })
			end
		end)
	end
end

local function registerPulse(instance: Instance)
	if pulseConnections[instance] then
		return
	end
	pulseConnections[instance] = true
	task.spawn(function()
		local cycleSeconds = getNumber(instance, "ZTHCycleSeconds", DEFAULT_PULSE_CYCLE)
		local phase = getNumber(instance, "ZTHPhaseOffset", 0)
		if phase > 0 then
			task.wait(phase)
		end
		while instance.Parent do
			pulseOnce(instance, 1)
			task.wait(cycleSeconds)
		end
		pulseConnections[instance] = nil
	end)
end

local function registerTransform(instance: Instance)
	if transformItems[instance] then
		return
	end
	local cframe = getWorldCFrame(instance)
	if not cframe then
		return
	end
	transformItems[instance] = {
		base = cframe,
		phase = getNumber(instance, "ZTHPhaseOffset", 0),
	}
end

local function registerFlicker(instance: Instance)
	if flickerItems[instance] then
		return
	end
	if instance:IsA("Light") then
		flickerItems[instance] = {
			base = getNumber(instance, "ZTHFlickerBase", instance.Brightness),
			nextStep = 0,
		}
	elseif instance:IsA("BasePart") then
		flickerItems[instance] = {
			base = getNumber(instance, "ZTHFlickerBase", instance.Transparency),
			nextStep = 0,
		}
	end
end

local function registerParticle(instance: Instance)
	if instance:IsA("ParticleEmitter") and not particleEmitterSet[instance] then
		instance.Enabled = false
		particleEmitterSet[instance] = true
		table.insert(particleEmitters, instance)
	end
end

local function registerPromptFeedback(instance: Instance)
	if promptFeedbackSet[instance] then
		return
	end
	promptFeedbackSet[instance] = true
	table.insert(promptFeedbackItems, instance)
	updateAnimatorStats()
end

local function registerChallengeFeedback(instance: Instance)
	if challengeFeedbackSet[instance] then
		return
	end
	challengeFeedbackSet[instance] = true
	local stationId = getString(instance, "StationId", "Global")
	challengeFeedbackByStation[stationId] = challengeFeedbackByStation[stationId] or {}
	table.insert(challengeFeedbackByStation[stationId], instance)
	updateAnimatorStats()
end

local function flashItems(items: { Instance }?, strength: number)
	if not items then
		return
	end
	for _, item in ipairs(items) do
		if item.Parent then
			pulseOnce(item, strength)
			for _, emitter in ipairs(item:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(math.floor(getNumber(emitter, "ZTHEmitCount", 5) * strength))
				end
			end
		end
	end
end

local function connectPrompt(prompt: ProximityPrompt)
	if connectedPrompts[prompt] then
		return
	end
	connectedPrompts[prompt] = true
	prompt.PromptShown:Connect(function()
		local promptPosition = getWorldPosition(prompt.Parent)
		local stationId = getString(prompt, "StationId", "")
		local nearby = {}
		for _, item in ipairs(promptFeedbackItems) do
			if item.Parent then
				local itemStationId = getString(item, "StationId", "")
				local matchesStation = stationId ~= "" and itemStationId == stationId
				local itemPosition = getWorldPosition(item)
				local isNearby = promptPosition and itemPosition and (promptPosition - itemPosition).Magnitude <= NEARBY_PROMPT_DISTANCE
				if matchesStation or isNearby then
					table.insert(nearby, item)
				end
			end
		end
		flashItems(nearby, 1.35)
	end)
	prompt.PromptHidden:Connect(function()
		local stationId = getString(prompt, "StationId", "")
		if stationId ~= "" then
			flashItems(challengeFeedbackByStation[stationId], 0.65)
		end
	end)
end

local function connectExistingPrompts()
	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant:IsA("ProximityPrompt") then
			connectPrompt(descendant)
		end
	end
	Workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("ProximityPrompt") then
			connectPrompt(descendant)
		end
	end)
end

local function bindTag(tagName: string, callback: (Instance) -> ())
	for _, instance in ipairs(CollectionService:GetTagged(tagName)) do
		callback(instance)
	end
	CollectionService:GetInstanceAddedSignal(tagName):Connect(callback)
end

local function registerCurrentTags()
	for _, instance in ipairs(CollectionService:GetTagged(TAG_PULSE)) do
		registerPulse(instance)
	end
	for _, instance in ipairs(CollectionService:GetTagged(TAG_FLOAT)) do
		registerTransform(instance)
	end
	for _, instance in ipairs(CollectionService:GetTagged(TAG_ROTATE)) do
		registerTransform(instance)
	end
	for _, instance in ipairs(CollectionService:GetTagged(TAG_FLICKER)) do
		registerFlicker(instance)
	end
	for _, instance in ipairs(CollectionService:GetTagged(TAG_PARTICLE)) do
		registerParticle(instance)
	end
	for _, instance in ipairs(CollectionService:GetTagged(TAG_PROMPT_FEEDBACK)) do
		registerPromptFeedback(instance)
	end
	for _, instance in ipairs(CollectionService:GetTagged(TAG_CHALLENGE_FEEDBACK)) do
		registerChallengeFeedback(instance)
	end
	updateAnimatorStats()
end

local function connectChallengeFeedback()
	local shared = ReplicatedStorage:FindFirstChild("ZeroToHeroShared")
	if not shared then
		return
	end
	local remotes = shared:FindFirstChild("Remotes")
	if not remotes then
		return
	end
	local challengeEvent = remotes:FindFirstChild("TrainingStationChallenge")
	if not challengeEvent or not challengeEvent:IsA("RemoteEvent") then
		return
	end

	challengeEvent.OnClientEvent:Connect(function(payload)
		if typeof(payload) ~= "table" then
			return
		end
		local stationId = payload.StationId
		if typeof(stationId) ~= "string" or stationId == "" then
			stationId = "Global"
		end
		local messageType = payload.Type
		local strength = 1
		if messageType == "Started" then
			strength = 1.75
		elseif messageType == "Completed" then
			strength = 2
		elseif messageType == "Failed" or messageType == "Cancelled" then
			strength = 0.85
		end
		script:SetAttribute("LastChallengeFeedback", tostring(messageType))
		script:SetAttribute("LastChallengeStationId", stationId)
		flashItems(challengeFeedbackByStation[stationId], strength)
		flashItems(challengeFeedbackByStation.Global, strength)
	end)
end

local function updateTransforms(now: number)
	for instance, item in pairs(transformItems) do
		if not instance.Parent then
			transformItems[instance] = nil
		else
			local cframe = item.base
			if CollectionService:HasTag(instance, TAG_FLOAT) then
				local height = getNumber(instance, "ZTHFloatHeight", 0.45)
				local speed = getNumber(instance, "ZTHFloatSpeed", DEFAULT_FLOAT_SPEED)
				cframe *= CFrame.new(0, math.sin((now + item.phase) * math.pi * 2 * speed) * height, 0)
			end
			if CollectionService:HasTag(instance, TAG_ROTATE) then
				local speed = math.rad(getNumber(instance, "ZTHRotateSpeed", DEFAULT_ROTATE_SPEED))
				cframe *= rotationFromAxis(getAxis(instance), (now + item.phase) * speed)
			end
			setWorldCFrame(instance, cframe)
		end
	end
end

local function updateFlickers(now: number)
	for instance, item in pairs(flickerItems) do
		if not instance.Parent then
			flickerItems[instance] = nil
		elseif now >= item.nextStep then
			local interval = getNumber(instance, "ZTHFlickerInterval", DEFAULT_FLICKER_INTERVAL)
			local amount = getNumber(instance, "ZTHFlickerAmount", 0.34)
			item.nextStep = now + interval + math.random() * interval
			if instance:IsA("Light") then
				instance.Brightness = math.max(0, item.base + (math.random() - 0.5) * amount)
			elseif instance:IsA("BasePart") then
				instance.Transparency = math.clamp(item.base + (math.random() - 0.5) * amount, 0, 0.85)
			end
		end
	end
end

local function updateParticles(now: number)
	for index = #particleEmitters, 1, -1 do
		local emitter = particleEmitters[index]
		if not emitter.Parent then
			table.remove(particleEmitters, index)
		else
			local nextEmit = getNumber(emitter, "ZTHNextEmitAt", 0)
			if now >= nextEmit then
				local interval = getNumber(emitter, "ZTHEmitInterval", 2.2)
				emitter:SetAttribute("ZTHNextEmitAt", now + interval + math.random() * interval)
				emitter:Emit(math.floor(getNumber(emitter, "ZTHEmitCount", 3)))
			end
		end
	end
end

bindTag(TAG_PULSE, registerPulse)
bindTag(TAG_FLOAT, registerTransform)
bindTag(TAG_ROTATE, registerTransform)
bindTag(TAG_FLICKER, registerFlicker)
bindTag(TAG_PARTICLE, registerParticle)
bindTag(TAG_PROMPT_FEEDBACK, registerPromptFeedback)
bindTag(TAG_CHALLENGE_FEEDBACK, registerChallengeFeedback)
registerCurrentTags()
task.delay(1, registerCurrentTags)
task.delay(3, registerCurrentTags)
connectExistingPrompts()
connectChallengeFeedback()

RunService.RenderStepped:Connect(function()
	local now = os.clock()
	updateTransforms(now)
	updateFlickers(now)
	updateParticles(now)
end)

script:SetAttribute("AnimatorReady", true)
updateAnimatorStats()
