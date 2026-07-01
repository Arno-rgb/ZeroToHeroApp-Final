local EnemyConfig = {}

local ENEMIES = {
	LesserSlime = {
		Id = "LesserSlime",
		DisplayName = "Lesser Slime",
		MaxHealth = 42,
		SpawnPosition = Vector3.new(16, 4.2, -126),
		BodySize = Vector3.new(4.8, 3.2, 4.8),
		DetectRange = 34,
		ChaseRange = 54,
		AttackRange = 5.5,
		AttackDamage = 9,
		AttackCooldownSeconds = 2.2,
		AttackTelegraphSeconds = 0.55,
		AttackWindDownSeconds = 0.25,
		MoveSpeed = 8,
		TickSeconds = 0.25,
		RespawnSeconds = 7,
		DamageTakenMultiplier = 1,
		LootTableId = "LesserSlime",
		RewardTitle = "Slime Defeated",
		BehaviorTags = { "Starter" },
		Visual = {
			BodyShape = Enum.PartType.Ball,
			BodyColor = Color3.fromRGB(70, 214, 111),
			BaseColor = Color3.fromRGB(22, 38, 30),
			BillboardStrokeColor = Color3.fromRGB(98, 255, 144),
			TelegraphColor = Color3.fromRGB(255, 68, 68),
		},
	},
	GateHound = {
		Id = "GateHound",
		DisplayName = "Gate Hound",
		MaxHealth = 34,
		SpawnPosition = Vector3.new(-12, 4.2, -108),
		BodySize = Vector3.new(3.6, 2.4, 5.4),
		DetectRange = 42,
		ChaseRange = 68,
		AttackRange = 5.2,
		AttackDamage = 8,
		AttackCooldownSeconds = 1.35,
		AttackTelegraphSeconds = 0.35,
		AttackWindDownSeconds = 0.18,
		MoveSpeed = 15,
		TickSeconds = 0.18,
		RespawnSeconds = 8,
		DamageTakenMultiplier = 1,
		LootTableId = "GateHound",
		RewardTitle = "Hound Defeated",
		BehaviorTags = { "Fast", "Fragile" },
		Visual = {
			BodyShape = Enum.PartType.Block,
			BodyColor = Color3.fromRGB(119, 42, 48),
			AccentColor = Color3.fromRGB(236, 82, 70),
			BaseColor = Color3.fromRGB(44, 20, 24),
			BillboardStrokeColor = Color3.fromRGB(255, 102, 78),
			TelegraphColor = Color3.fromRGB(255, 60, 48),
		},
	},
	StoneShell = {
		Id = "StoneShell",
		DisplayName = "Stone Shell",
		MaxHealth = 96,
		SpawnPosition = Vector3.new(12, 4.4, -116),
		BodySize = Vector3.new(5.8, 4.2, 5.8),
		DetectRange = 30,
		ChaseRange = 48,
		AttackRange = 6,
		AttackDamage = 13,
		AttackCooldownSeconds = 2.8,
		AttackTelegraphSeconds = 0.85,
		AttackWindDownSeconds = 0.35,
		MoveSpeed = 4.6,
		TickSeconds = 0.3,
		RespawnSeconds = 10,
		DamageTakenMultiplier = 0.65,
		Break = {
			MaxBreak = 16,
			BrokenDurationSeconds = 2,
			VulnerableDamageTakenMultiplier = 1.35,
		},
		LootTableId = "StoneShell",
		RewardTitle = "Stone Shell Broken",
		BehaviorTags = { "Slow", "Armoured" },
		Visual = {
			BodyShape = Enum.PartType.Ball,
			BodyColor = Color3.fromRGB(92, 94, 94),
			AccentColor = Color3.fromRGB(155, 161, 151),
			BaseColor = Color3.fromRGB(38, 39, 38),
			BillboardStrokeColor = Color3.fromRGB(175, 181, 165),
			TelegraphColor = Color3.fromRGB(255, 88, 64),
		},
	},
	GateSentinel = {
		Id = "GateSentinel",
		DisplayName = "Gate Sentinel",
		MaxHealth = 120,
		SpawnPosition = Vector3.new(0, 4.8, -129),
		BodySize = Vector3.new(4.4, 6.2, 4.2),
		DetectRange = 38,
		ChaseRange = 58,
		AttackRange = 6.5,
		AttackDamage = 16,
		AttackCooldownSeconds = 2.4,
		AttackTelegraphSeconds = 0.75,
		AttackWindDownSeconds = 0.32,
		MoveSpeed = 6.5,
		TickSeconds = 0.25,
		RespawnSeconds = 12,
		DamageTakenMultiplier = 1,
		LootTableId = "GateSentinel",
		RewardTitle = "Sentinel Defeated",
		BehaviorTags = { "Defensive", "Guard" },
		DefensivePattern = {
			GuardCooldownSeconds = 4.5,
			GuardDurationSeconds = 1.45,
			GuardDamageTakenMultiplier = 0.45,
			TriggerRange = 22,
		},
		Visual = {
			BodyShape = Enum.PartType.Block,
			BodyColor = Color3.fromRGB(68, 73, 84),
			AccentColor = Color3.fromRGB(202, 65, 58),
			GuardColor = Color3.fromRGB(255, 75, 68),
			BaseColor = Color3.fromRGB(31, 31, 38),
			BillboardStrokeColor = Color3.fromRGB(255, 88, 78),
			TelegraphColor = Color3.fromRGB(255, 38, 38),
		},
	},
}

local function deepCopy(value)
	if typeof(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, child in pairs(value) do
		copy[deepCopy(key)] = deepCopy(child)
	end

	return copy
end

function EnemyConfig.GetEnemy(enemyId)
	local enemy = ENEMIES[enemyId]
	if enemy == nil then
		return nil
	end

	return deepCopy(enemy)
end

function EnemyConfig.GetEnemyIds()
	local ids = {}

	for enemyId in pairs(ENEMIES) do
		table.insert(ids, enemyId)
	end

	table.sort(ids)
	return ids
end

return table.freeze(EnemyConfig)
