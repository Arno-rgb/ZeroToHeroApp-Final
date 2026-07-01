local CombatActionConfig = {}

local REMOTE_NAMES = table.freeze({
	Action = "CombatAction",
	Feedback = "CombatFeedback",
})

local TARGET_ROOT_PATH = table.freeze({
	"Workspace",
	"AscensionGrounds",
	"EnemyArea",
})

local ACTIONS = table.freeze({
	BasicAttack = table.freeze({
		Id = "BasicAttack",
		CooldownSeconds = 0.65,
		Range = 9,
		ArcDot = -0.15,
		DamageMultiplier = 1,
		BreakDamageMultiplier = 1,
	}),
	Guard = table.freeze({
		Id = "Guard",
		MinToggleInterval = 0.16,
	}),
	Dodge = table.freeze({
		Id = "Dodge",
		CooldownSeconds = 1.25,
		StaminaCost = 28,
		InvulnerabilitySeconds = 0.28,
		Distance = 10,
		RaycastPadding = 2,
	}),
})

local STAMINA = table.freeze({
	Minimum = 0,
	RegenDelaySeconds = 0.45,
})

local TARGET_HEALTH = table.freeze({
	DefaultTrainingDummyMaxHealth = 120,
})

local PLACEHOLDER_ACTIONS = table.freeze({
	Skill1 = table.freeze({
		Id = "Skill1",
		Label = "SK1",
		DisplayName = "Skill 1",
	}),
	Skill2 = table.freeze({
		Id = "Skill2",
		Label = "SK2",
		DisplayName = "Skill 2",
	}),
	Ultimate = table.freeze({
		Id = "Ultimate",
		Label = "ULT",
		DisplayName = "Ultimate",
	}),
	Interact = table.freeze({
		Id = "Interact",
		Label = "USE",
		DisplayName = "Interact",
	}),
})

local VALID_ACTION_IDS = {}
for actionId in pairs(ACTIONS) do
	VALID_ACTION_IDS[actionId] = true
end
VALID_ACTION_IDS = table.freeze(VALID_ACTION_IDS)

local function cloneArray(values)
	local copy = {}
	for index, value in ipairs(values) do
		copy[index] = value
	end

	return copy
end

function CombatActionConfig.GetRemoteNames()
	return table.clone(REMOTE_NAMES)
end

function CombatActionConfig.GetTargetRootPath()
	return cloneArray(TARGET_ROOT_PATH)
end

function CombatActionConfig.GetAction(actionId)
	local action = ACTIONS[actionId]
	if action == nil then
		return nil
	end

	return table.clone(action)
end

function CombatActionConfig.IsValidActionId(actionId)
	return typeof(actionId) == "string" and VALID_ACTION_IDS[actionId] == true
end

function CombatActionConfig.GetStaminaConfig()
	return table.clone(STAMINA)
end

function CombatActionConfig.GetTargetHealthConfig()
	return table.clone(TARGET_HEALTH)
end

function CombatActionConfig.GetPlaceholderActions()
	local copy = {}
	for actionId, action in pairs(PLACEHOLDER_ACTIONS) do
		copy[actionId] = table.clone(action)
	end

	return copy
end

return table.freeze(CombatActionConfig)
