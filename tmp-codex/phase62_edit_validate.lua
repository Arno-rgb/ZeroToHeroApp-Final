local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local shared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local config = shared:WaitForChild("Config")
local services = ServerScriptService:WaitForChild("ZeroToHeroServer"):WaitForChild("Services")

local function requireFresh(moduleScript)
	local clone = moduleScript:Clone()
	clone.Name = moduleScript.Name .. "_Phase62Validate"
	clone.Parent = moduleScript.Parent
	local ok, result = pcall(require, clone)
	clone:Destroy()
	assert(ok, ("Failed to require %s: %s"):format(moduleScript:GetFullName(), tostring(result)))
	return result
end

local EnemyConfig = requireFresh(config:WaitForChild("EnemyConfig"))
local CombatActionConfig = requireFresh(config:WaitForChild("CombatActionConfig"))
local CombatService = requireFresh(services:WaitForChild("CombatService"))
local EnemyService = requireFresh(services:WaitForChild("EnemyService"))

local shell = EnemyConfig.GetEnemy("StoneShell")
assert(shell ~= nil, "StoneShell config missing")
assert(typeof(shell.Break) == "table", "StoneShell Break config missing")
assert(shell.Break.MaxBreak == 16, "StoneShell MaxBreak should be 16")
assert(shell.Break.BrokenDurationSeconds == 2, "StoneShell broken duration should be 2 seconds")
assert(shell.Break.VulnerableDamageTakenMultiplier == 1.35, "StoneShell vulnerable multiplier should be 1.35")
assert(shell.DamageTakenMultiplier == 0.65, "StoneShell base armor multiplier should remain 0.65")

local hound = EnemyConfig.GetEnemy("GateHound")
local sentinel = EnemyConfig.GetEnemy("GateSentinel")
assert(hound.Break == nil, "GateHound should not be Break-enabled in Phase 6.2")
assert(sentinel.Break == nil, "GateSentinel should not be Break-enabled in Phase 6.2")

local action = CombatActionConfig.GetAction("BasicAttack")
assert(action.BreakDamageMultiplier == 1, "BasicAttack should expose BreakDamageMultiplier")
assert(typeof(CombatService.TryBasicAttack) == "function", "CombatService.TryBasicAttack missing")
assert(typeof(EnemyService.GetEnemyState) == "function", "EnemyService.GetEnemyState missing")

print(("PHASE62_EDIT_VALIDATE ok maxBreak=%d vulnerable=%.2f breakMultiplier=%.1f"):format(shell.Break.MaxBreak, shell.Break.VulnerableDamageTakenMultiplier, action.BreakDamageMultiplier))
