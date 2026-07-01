# Loot Service Examples

Milestone 5.4 adds reusable loot tables and a server-authoritative loot grant path for Lesser Slime drops.

## Edit-Mode Config Check

In Studio Edit mode:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local shared = ReplicatedStorage.ZeroToHeroShared
local lootTableConfig = require(shared.Config.LootTableConfig)
local enemyConfig = require(shared.Config.EnemyConfig)
local playerData = require(ServerScriptService.ZeroToHeroServer.Services.PlayerDataService)

local validation = lootTableConfig.ValidateAllLootTables()
assert(validation.IsValid == true)
assert(validation.TableCount >= 1)
assert(enemyConfig.GetEnemy("LesserSlime").LootTableId == "LesserSlime")
assert(lootTableConfig.GetMaterial("slime_residue").DisplayName == "Slime Residue")
assert(type(playerData.AddMaterial) == "function")
```

## Server Forced Loot Check

In Play mode, run from the server command context:

```lua
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local player = Players:GetPlayers()[1]
assert(player ~= nil)

local services = ServerScriptService.ZeroToHeroServer.Services
local playerData = require(services.PlayerDataService)
local inventoryService = require(services.InventoryService)
local lootService = require(services.LootService)

local beforeProfile = playerData.GetProfile(player)
local beforeInventory = inventoryService.GetSnapshot(player)
local beforeGold = beforeProfile.Gold
local beforeMaterial = (beforeProfile.Materials and beforeProfile.Materials.slime_residue) or 0

local result = lootService.GrantLoot(player, "LesserSlime", {
	RewardKey = "LootServiceExample:" .. player.UserId,
	Reason = "LootServiceExample",
	Source = "Combat",
	Title = "Loot Found",
	Subtitle = "Lesser Slime",
	ForceGoldDrop = true,
	ForceItemDrop = true,
	ForceMaterialDrop = true,
	Random = Random.new(54),
})

assert(result.Success == true)
assert(result.HeroXPGained == 12)
assert(result.GoldGained >= 2 and result.GoldGained <= 4)
assert(#result.Items == 1)
assert(#result.Materials == 1)
assert(result.Materials[1].MaterialId == "slime_residue")

local afterProfile = playerData.GetProfile(player)
local afterInventory = inventoryService.GetSnapshot(player)
assert(afterProfile.Gold == beforeGold + result.GoldGained)
assert(afterProfile.Materials.slime_residue == beforeMaterial + result.Materials[1].Amount)
assert(#afterInventory.Items == #beforeInventory.Items + 1)
```

## Duplicate Reward Check

Run this after the forced loot check with the same `RewardKey`:

```lua
local duplicate = lootService.GrantLoot(player, "LesserSlime", {
	RewardKey = "LootServiceExample:" .. player.UserId,
	Reason = "LootServiceDuplicateExample",
	Source = "Combat",
	ForceGoldDrop = true,
	ForceItemDrop = true,
	ForceMaterialDrop = true,
	Display = false,
})

assert(duplicate.Success == false)
assert(duplicate.Error == "DuplicateReward")
```

## Client Popup And Inventory Check

After a server grant with display enabled:

```lua
local playerGui = game.Players.LocalPlayer.PlayerGui
local rewardGui = playerGui:WaitForChild("RewardPopupGui")
local inventoryGui = playerGui:WaitForChild("InventoryPanelGui")

assert(rewardGui:GetAttribute("LastRewardTitle") == "Loot Found")
assert(rewardGui:GetAttribute("LastRewardPrimary") == "Hero XP")
assert(rewardGui:GetAttribute("LastRewardAmount") == "+12")
assert(inventoryGui:GetAttribute("ItemCount") >= 1)
```

## Scope Check

- Enemy config points to a reusable `LootTableId`; the enemy does not own ad hoc item roll logic.
- Loot rolls happen in server code through `LootService`.
- Item drops are awarded through `InventoryService.AddItem`.
- Material drops are awarded through `PlayerDataService.AddMaterial`.
- Reward display remains presentation-only through the existing popup path.
- Unpublished local Studio cannot verify DataStore-backed rejoin persistence for loot, inventory, or materials.
