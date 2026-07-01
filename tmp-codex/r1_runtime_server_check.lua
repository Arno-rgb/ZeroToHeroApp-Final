local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local shared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local config = shared:WaitForChild("Config")
local services = ServerScriptService:WaitForChild("ZeroToHeroServer"):WaitForChild("Services")

local FeatureFlags = require(config:WaitForChild("FeatureFlags"))
local CombatService = require(services:WaitForChild("CombatService"))
local EnemyService = require(services:WaitForChild("EnemyService"))
local PlayerDataService = require(services:WaitForChild("PlayerDataService"))

assert(FeatureFlags.IsEnabled("BreakSystemEnabled") == false, "BreakSystemEnabled should be false in normal Play mode")

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

local profile = PlayerDataService.GetProfileSnapshot(player)
startedAt = os.clock()
while profile == nil and os.clock() - startedAt < 10 do
	task.wait(0.1)
	profile = PlayerDataService.GetProfileSnapshot(player)
end
assert(profile ~= nil, "Player profile did not load")

local enemyArea = Workspace:WaitForChild("AscensionGrounds", 10):WaitForChild("EnemyArea", 10)
local shell = enemyArea:WaitForChild("StoneShell", 10)
assert(shell ~= nil, "StoneShell did not spawn")

local state = EnemyService.GetEnemyState("StoneShell")
assert(state ~= nil, "EnemyService state missing for StoneShell")
assert(shell:GetAttribute("BreakEnabled") == false, "StoneShell should not be Break-enabled while flag is false")
assert(shell:FindFirstChild("Break") == nil, "StoneShell Break value should not be created while disabled")
assert(shell:FindFirstChild("MaxBreak") == nil, "StoneShell MaxBreak value should not be created while disabled")
assert(shell:FindFirstChild("BreakState") == nil, "StoneShell BreakState value should not be created while disabled")
assert(shell:GetAttribute("BreakState") == nil, "StoneShell BreakState attribute should not exist while disabled")
assert(shell:GetAttribute("Broken") == false, "StoneShell should not start Broken")
assert(shell:GetAttribute("Vulnerable") == false, "StoneShell should not start Vulnerable")
assert(math.abs(shell:GetAttribute("DamageTakenMultiplier") - 0.65) < 0.001, "StoneShell armor multiplier should stay at 0.65")

local body = shell:WaitForChild("Body")
local billboard = body:FindFirstChild("EnemyBillboard")
assert(billboard ~= nil, "StoneShell billboard missing")
assert(billboard.Size.Y.Offset == 50, "StoneShell billboard should not reserve Break UI space while disabled")
local panel = billboard:FindFirstChild("Panel")
assert(panel ~= nil, "StoneShell billboard panel missing")
assert(panel:FindFirstChild("BreakLabel") == nil, "StoneShell BreakLabel should not exist while disabled")
assert(panel:FindFirstChild("BreakBar") == nil, "StoneShell BreakBar should not exist while disabled")

local moveStart = body.Position
root.CFrame = CFrame.lookAt(moveStart + Vector3.new(0, 0, 18), body.Position)
task.wait(1.4)
local movedDistance = (body.Position - moveStart).Magnitude
assert(movedDistance > 0.1, ("StoneShell should move toward a detected player, moved %.3f"):format(movedDistance))

root.CFrame = CFrame.lookAt(body.Position + Vector3.new(0, 0, 4.5), body.Position)
local attackStartAt = state.LastAttackAt or 0
startedAt = os.clock()
while (state.LastAttackAt or 0) <= attackStartAt and os.clock() - startedAt < 4 do
	task.wait(0.1)
end
assert((state.LastAttackAt or 0) > attackStartAt, "StoneShell should perform an attack with Break disabled")

state.IsDead = false
state.IsAttacking = false
state.IsGuarding = false
state.IsBroken = false
state.BreakTriggeredForCurrentMeter = false
state.TargetPlayer = nil
state.RewardClaimedForSpawn = false
state.Health.Value = state.MaxHealth.Value
state.Model:SetAttribute("RewardClaimed", false)
state.Model:SetAttribute("Broken", false)
state.Model:SetAttribute("Vulnerable", false)
state.Model:SetAttribute("DamageTakenMultiplier", 0.65)
state.CurrentDamageTakenMultiplier = 0.65
state.Telegraph.Transparency = 1

root.CFrame = CFrame.lookAt(body.Position + Vector3.new(0, 0, 6), body.Position)
task.wait(0.8)

local oldHealth = state.Health.Value
local firstHit = CombatService.TryBasicAttack(player, shell)
assert(firstHit.Success, "StoneShell damage attack failed: " .. tostring(firstHit.Error))
assert(firstHit.Damage > 0, "StoneShell should take health damage")
assert(firstHit.RawDamage > 0, "StoneShell raw damage should be reported")
assert(firstHit.BreakDamage == 0, "BreakDamage should be 0 while Break is disabled")
assert(firstHit.RawBreakDamage == 0, "RawBreakDamage should be 0 while Break is disabled")
assert(firstHit.TargetDamageMultiplier == 0.65, "StoneShell should keep armor multiplier, not Break vulnerability")
assert(state.Health.Value == oldHealth - firstHit.Damage, "StoneShell health should decrease by normal damage")
assert(shell:FindFirstChild("Break") == nil, "Attack should not create a Break meter")
assert(shell:GetAttribute("Broken") == false, "Attack should not trigger Broken state")
assert(shell:GetAttribute("Vulnerable") == false, "Attack should not trigger Vulnerable state")
assert(math.abs(shell:GetAttribute("DamageTakenMultiplier") - 0.65) < 0.001, "Attack should not change armor multiplier")

local beforeRewardProfile = PlayerDataService.GetProfileSnapshot(player)
local beforeHeroLevel = beforeRewardProfile.HeroLevel or 1
local beforeHeroXP = beforeRewardProfile.HeroXP or 0
local beforeGold = beforeRewardProfile.Gold or 0

state.Health.Value = 1
task.wait(0.75)
root.CFrame = CFrame.lookAt(body.Position + Vector3.new(0, 0, 6), body.Position)
local killHit = CombatService.TryBasicAttack(player, shell)
assert(killHit.Success, "StoneShell kill attack failed: " .. tostring(killHit.Error))
assert(killHit.Defeated == true, "StoneShell kill attack should defeat the enemy")

startedAt = os.clock()
local afterRewardProfile = PlayerDataService.GetProfileSnapshot(player)
while afterRewardProfile ~= nil and (afterRewardProfile.Gold or 0) < beforeGold + 2 and os.clock() - startedAt < 4 do
	task.wait(0.1)
	afterRewardProfile = PlayerDataService.GetProfileSnapshot(player)
end
assert(afterRewardProfile ~= nil, "Profile missing after StoneShell reward")

local heroProgressed = (afterRewardProfile.HeroLevel or 1) > beforeHeroLevel or (afterRewardProfile.HeroXP or 0) > beforeHeroXP
assert(heroProgressed, "StoneShell should grant Hero XP or a Hero Level increase")
assert((afterRewardProfile.Gold or 0) >= beforeGold + 2, "StoneShell should grant guaranteed Gold")
assert(shell:GetAttribute("RewardClaimed") == true, "StoneShell should mark reward claimed")
assert(state.IsDead == true, "StoneShell should be dead after defeat")

task.wait(0.75)
local duplicate = CombatService.TryBasicAttack(player, shell)
assert(duplicate.Success == false and duplicate.Error == "TargetDefeated", "Duplicate attack should not damage defeated StoneShell")
task.wait(0.2)
local afterDuplicateProfile = PlayerDataService.GetProfileSnapshot(player)
assert(afterDuplicateProfile ~= nil, "Profile missing after duplicate check")
assert(afterDuplicateProfile.HeroLevel == afterRewardProfile.HeroLevel, "Duplicate attack should not grant extra Hero Level")
assert(afterDuplicateProfile.HeroXP == afterRewardProfile.HeroXP, "Duplicate attack should not grant extra Hero XP")
assert(afterDuplicateProfile.Gold == afterRewardProfile.Gold, "Duplicate attack should not grant extra Gold")

print(("R1_RUNTIME_SERVER ok moved=%.2f firstDamage=%d break=%d goldGain=%d heroBefore=%d/%d heroAfter=%d/%d"):format(
	movedDistance,
	firstHit.Damage,
	firstHit.BreakDamage,
	(afterRewardProfile.Gold or 0) - beforeGold,
	beforeHeroLevel,
	beforeHeroXP,
	afterRewardProfile.HeroLevel or 1,
	afterRewardProfile.HeroXP or 0
))
