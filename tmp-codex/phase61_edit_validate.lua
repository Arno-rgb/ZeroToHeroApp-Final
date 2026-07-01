local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local shared = ReplicatedStorage:WaitForChild("ZeroToHeroShared")
local config = shared:WaitForChild("Config")
local services = ServerScriptService:WaitForChild("ZeroToHeroServer"):WaitForChild("Services")

local EnemyConfig = require(config:WaitForChild("EnemyConfig"))
local LootTableConfig = require(config:WaitForChild("LootTableConfig"))
require(services:WaitForChild("CombatService"))
require(services:WaitForChild("EnemyService"))

local expectedEnemyIds = {
	"GateHound",
	"GateSentinel",
	"LesserSlime",
	"StoneShell",
}

local ids = EnemyConfig.GetEnemyIds()
for index, expectedId in ipairs(expectedEnemyIds) do
	assert(ids[index] == expectedId, ("enemy id order mismatch at %d: expected %s, got %s"):format(index, expectedId, tostring(ids[index])))
	local enemy = EnemyConfig.GetEnemy(expectedId)
	assert(enemy ~= nil, expectedId .. " missing from EnemyConfig")
	assert(enemy.LootTableId ~= nil, expectedId .. " missing loot table id")
	assert(LootTableConfig.GetLootTable(enemy.LootTableId) ~= nil, expectedId .. " loot table missing")
end

local validation = LootTableConfig.ValidateAllLootTables()
assert(validation.IsValid == true, "loot table validation failed")
assert(validation.TableCount >= 4, "expected at least four loot tables")

assert(EnemyConfig.GetEnemy("GateHound").MoveSpeed > EnemyConfig.GetEnemy("LesserSlime").MoveSpeed, "GateHound should be faster than LesserSlime")
assert(EnemyConfig.GetEnemy("GateHound").MaxHealth < EnemyConfig.GetEnemy("LesserSlime").MaxHealth, "GateHound should be more fragile than LesserSlime")
assert(EnemyConfig.GetEnemy("StoneShell").MoveSpeed < EnemyConfig.GetEnemy("LesserSlime").MoveSpeed, "StoneShell should be slower than LesserSlime")
assert((EnemyConfig.GetEnemy("StoneShell").DamageTakenMultiplier or 1) < 1, "StoneShell should be armoured")
assert(type(EnemyConfig.GetEnemy("GateSentinel").DefensivePattern) == "table", "GateSentinel should have a defensive pattern")

print(("PHASE61_EDIT_VALIDATE ok enemies=%d lootTables=%d"):format(#ids, validation.TableCount))
