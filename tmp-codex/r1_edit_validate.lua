local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local shared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local config = shared:WaitForChild("Config")
local services = ServerScriptService:WaitForChild("ZeroToHeroServer"):WaitForChild("Services")

local function requireFresh(moduleScript)
	local clone = moduleScript:Clone()
	clone.Name = moduleScript.Name .. "_R1Validate"
	clone.Parent = moduleScript.Parent
	local ok, result = pcall(require, clone)
	clone:Destroy()
	assert(ok, ("Failed to require %s: %s"):format(moduleScript:GetFullName(), tostring(result)))
	return result
end

local FeatureFlags = requireFresh(config:WaitForChild("FeatureFlags"))
local EnemyConfig = requireFresh(config:WaitForChild("EnemyConfig"))
local CombatActionConfig = requireFresh(config:WaitForChild("CombatActionConfig"))
local CombatService = requireFresh(services:WaitForChild("CombatService"))
local EnemyService = requireFresh(services:WaitForChild("EnemyService"))

assert(FeatureFlags.GetFlag("BreakSystemEnabled") == false, "BreakSystemEnabled should default to false")
assert(FeatureFlags.IsEnabled("BreakSystemEnabled") == false, "BreakSystemEnabled should not be enabled")

local shell = EnemyConfig.GetEnemy("StoneShell")
assert(shell ~= nil, "StoneShell config missing")
assert(typeof(shell.Break) == "table", "StoneShell Break config should remain preserved in source config")
assert(shell.Break.MaxBreak == 16, "StoneShell preserved Break MaxBreak should remain 16")
assert(shell.DamageTakenMultiplier == 0.65, "StoneShell base armor multiplier should remain 0.65")
assert(shell.LootTableId == "StoneShell", "StoneShell loot table should remain unchanged")

local action = CombatActionConfig.GetAction("BasicAttack")
assert(action ~= nil, "BasicAttack config missing")
assert(action.BreakDamageMultiplier == 1, "BreakDamageMultiplier should remain recoverable in config")
assert(typeof(CombatService.TryBasicAttack) == "function", "CombatService.TryBasicAttack missing")
assert(typeof(EnemyService.GetEnemyState) == "function", "EnemyService.GetEnemyState missing")

print("R1_EDIT_VALIDATE ok BreakSystemEnabled=false preservedBreakConfig=true")
