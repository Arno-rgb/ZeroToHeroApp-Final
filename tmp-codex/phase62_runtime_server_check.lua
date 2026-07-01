local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local shared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local services = ServerScriptService:WaitForChild("ZeroToHeroServer"):WaitForChild("Services")
local CombatService = require(services:WaitForChild("CombatService"))
local EnemyService = require(services:WaitForChild("EnemyService"))

CombatService.Start()
EnemyService.Start()

local player = Players:GetPlayers()[1]
local startedAt = os.clock()
while player == nil and os.clock() - startedAt < 10 do
	task.wait(0.1)
	player = Players:GetPlayers()[1]
end
assert(player ~= nil, "No player found in Play mode")

local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart", 10)
assert(root ~= nil, "Player HumanoidRootPart missing")

local enemyArea = Workspace:WaitForChild("AscensionGrounds", 10):WaitForChild("EnemyArea", 10)
local shell = enemyArea:WaitForChild("StoneShell", 10)
assert(shell ~= nil, "StoneShell did not spawn")

local state = EnemyService.GetEnemyState("StoneShell")
assert(state ~= nil, "EnemyService state missing for StoneShell")
assert(shell:GetAttribute("BreakEnabled") == true, "StoneShell should be Break-enabled")
assert(shell:FindFirstChild("Break") ~= nil, "StoneShell Break value missing")
assert(shell:FindFirstChild("MaxBreak") ~= nil, "StoneShell MaxBreak value missing")
assert(shell:FindFirstChild("BreakState") ~= nil, "StoneShell BreakState value missing")
assert(shell.MaxBreak.Value == 16, "StoneShell MaxBreak runtime value should be 16")
assert(shell:GetAttribute("DamageTakenMultiplier") == 0.65, "StoneShell base armor multiplier should be 0.65")

local billboard = shell.Body:FindFirstChild("EnemyBillboard")
assert(billboard ~= nil, "StoneShell billboard missing")
local panel = billboard:FindFirstChild("Panel")
assert(panel ~= nil, "StoneShell billboard panel missing")
assert(panel:FindFirstChild("BreakLabel") ~= nil, "StoneShell BreakLabel missing")
assert(panel:FindFirstChild("BreakBar") ~= nil, "StoneShell BreakBar missing")

state.IsDead = false
state.IsAttacking = false
state.IsGuarding = false
state.IsBroken = false
state.BreakTriggeredForCurrentMeter = false
state.TargetPlayer = nil
state.Health.Value = 10000
state.MaxHealth.Value = 10000
state.Break.Value = 0
state.BreakStateValue.Value = "Stable"
state.Model:SetAttribute("Broken", false)
state.Model:SetAttribute("Vulnerable", false)
state.Model:SetAttribute("DamageTakenMultiplier", 0.65)
state.CurrentDamageTakenMultiplier = 0.65
state.Telegraph.Transparency = 1

local body = shell:WaitForChild("Body")
root.CFrame = CFrame.lookAt(body.Position + Vector3.new(0, 0, 6), body.Position)
task.wait(0.8)

local function attackShell()
	root.CFrame = CFrame.lookAt(body.Position + Vector3.new(0, 0, 6), body.Position)
	task.wait(0.05)
	local result = CombatService.TryBasicAttack(player, shell)
	assert(result.Success, "Basic attack failed: " .. tostring(result.Error))
	return result
end

local firstHealth = state.Health.Value
local firstBreak = state.Break.Value
local firstHit = attackShell()
assert(type(firstHit.Damage) == "number" and firstHit.Damage > 0, "Health damage missing")
assert(type(firstHit.RawDamage) == "number" and firstHit.RawDamage > 0, "Raw damage missing")
assert(type(firstHit.BreakDamage) == "number" and firstHit.BreakDamage > 0, "Break damage missing")
assert(type(firstHit.RawBreakDamage) == "number" and firstHit.RawBreakDamage == firstHit.BreakDamage, "Raw Break damage missing")
assert(firstHit.TargetDamageMultiplier == 0.65, "First hit should use StoneShell armor multiplier")
assert(state.Health.Value == firstHealth - firstHit.Damage, "Health damage should reduce HP only by Damage")
assert(state.Break.Value == math.min(state.MaxBreak.Value, firstBreak + firstHit.BreakDamage), "Break damage should fill Break meter separately")

local hits = 1
while shell:GetAttribute("Broken") ~= true and hits < 6 do
	task.wait(0.75)
	attackShell()
	hits += 1
end

assert(shell:GetAttribute("Broken") == true, "StoneShell should enter Broken state")
assert(shell:GetAttribute("Vulnerable") == true, "Broken StoneShell should be vulnerable")
assert(state.StateValue.Value == "Broken", "StoneShell State should be Broken")
assert(state.BreakStateValue.Value == "Broken", "StoneShell BreakState should be Broken")
assert(state.Break.Value == state.MaxBreak.Value, "Break meter should be full while Broken")
local vulnerableMultiplier = shell:GetAttribute("DamageTakenMultiplier")
assert(vulnerableMultiplier > 1, "Broken vulnerability should raise DamageTakenMultiplier above 1")

task.wait(0.75)
local vulnerableHit = attackShell()
assert(vulnerableHit.TargetDamageMultiplier == vulnerableMultiplier, "Vulnerable hit should use Broken damage multiplier")
assert(state.Break.Value == state.MaxBreak.Value, "Additional Broken hits should not retrigger or overfill Break")

task.wait(2.35)
assert(shell:GetAttribute("Broken") == false, "Broken state should end after recovery")
assert(shell:GetAttribute("Vulnerable") == false, "Vulnerability should end after recovery")
assert(state.BreakStateValue.Value == "Stable", "BreakState should recover to Stable")
assert(state.Break.Value == 0, "Break meter should reset after recovery")
assert(math.abs(shell:GetAttribute("DamageTakenMultiplier") - 0.65) < 0.001, "DamageTakenMultiplier should recover to base armor")

print(("PHASE62_RUNTIME_SERVER ok hits=%d firstDamage=%d raw=%d break=%d vulnerableMultiplier=%.2f"):format(
	hits,
	firstHit.Damage,
	firstHit.RawDamage,
	firstHit.BreakDamage,
	vulnerableMultiplier
))
