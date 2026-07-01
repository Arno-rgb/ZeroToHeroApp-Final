# Inventory Service Examples

Milestone 5.3 adds server-authoritative inventory instances, equipment slots, item inspection, item comparison, and a compact mobile inventory UI.

## Edit-Mode Require Check

In Studio Edit mode:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local shared = ReplicatedStorage.ZeroToHeroShared
local itemConfig = require(shared.Config.ItemConfig)
local inventoryService = require(ServerScriptService.ZeroToHeroServer.Services.InventoryService)
local combatService = require(ServerScriptService.ZeroToHeroServer.Services.CombatService)

inventoryService.Start()

assert(inventoryService.GetActionEvent().Name == "InventoryAction")
assert(inventoryService.GetSnapshotEvent().Name == "InventorySnapshot")
assert(type(inventoryService.AddItem) == "function")
assert(type(combatService.GetPlayerCombatSnapshot) == "function")
assert(itemConfig.GetItem("starter_training_blade").Slot == "Weapon")
```

## Server Play-Mode Check

In Play mode, run from the server command context:

```lua
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players:GetPlayers()[1]
assert(player ~= nil)

local services = ServerScriptService.ZeroToHeroServer.Services
local itemConfig = require(ReplicatedStorage.ZeroToHeroShared.Config.ItemConfig)
local inventoryService = require(services.InventoryService)
local combatService = require(services.CombatService)

local before = inventoryService.GetSnapshot(player)
if before.Equipment.Weapon and before.Equipment.Weapon ~= false then
	inventoryService.UnequipItem(player, "Weapon")
	before = inventoryService.GetSnapshot(player)
end

local sword = itemConfig.GetItem("starter_training_blade")
local added = inventoryService.AddItem(player, "starter_training_blade", {
	Reason = "Milestone53TestSword",
	Source = "ManualCheck",
})
assert(added.Success == true)

local inspect = inventoryService.InspectItem(player, added.InstanceId)
assert(inspect.Success == true)
assert(inspect.Item.ItemId == "starter_training_blade")

local wrongSlot = inventoryService.EquipItem(player, added.InstanceId, "Charm")
assert(wrongSlot.Success == false)
assert(wrongSlot.Error == "SlotMismatch")

local equip = inventoryService.EquipItem(player, added.InstanceId)
assert(equip.Success == true)

local equipped = inventoryService.GetSnapshot(player, added.InstanceId)
assert(equipped.Equipment.Weapon == added.InstanceId)
assert(equipped.EquipmentBonuses.PhysicalDamage == sword.StatBonuses.PhysicalDamage)
assert(equipped.EquipmentBonuses.BreakDamage == sword.StatBonuses.BreakDamage)

local combat = combatService.GetPlayerCombatSnapshot(player)
assert(combat.Stats.PhysicalDamage == equipped.EffectiveStats.PhysicalDamage)
assert(combat.Stats.BreakDamage == equipped.EffectiveStats.BreakDamage)

local removeEquipped = inventoryService.RemoveItem(player, added.InstanceId)
assert(removeEquipped.Success == false)
assert(removeEquipped.Error == "ItemEquipped")
```

## Client UI Check

After the server check leaves the sword equipped:

```lua
local gui = game.Players.LocalPlayer.PlayerGui:WaitForChild("InventoryPanelGui")

assert(gui:GetAttribute("ItemCount") >= 1)
assert(gui:GetAttribute("WeaponEquipped") ~= "")
assert(gui:GetAttribute("EffectivePhysicalDamage") > 0)
assert(gui:GetAttribute("EffectiveBreakDamage") > 0)
assert(gui.GearButton:IsA("TextButton"))
assert(gui.Panel:IsA("Frame"))
```

## Published Rejoin Persistence Check

This cannot be proven in unpublished local Studio because DataStores are unavailable.

1. Publish the Roblox place.
2. Enable Studio API/DataStore access.
3. Start Play mode with the same test account.
4. Add and equip `starter_training_blade` through `InventoryService.AddItem` and `InventoryService.EquipItem`.
5. Save or leave the session so `PlayerDataService` can persist the profile.
6. Rejoin with the same account.
7. Confirm `InventoryService.GetSnapshot(player).Items` still contains the item instance.
8. Confirm `InventoryService.GetSnapshot(player).Equipment.Weapon` still points to the saved item instance.
9. Confirm `CombatService.GetPlayerCombatSnapshot(player).Stats` still includes the equipped item bonuses.

## Scope Check

- Item creation is only exposed through server API `InventoryService.AddItem`.
- `InventoryAction` supports request, inspect, compare, equip, unequip, and remove actions only.
- Equip validates item ownership and slot compatibility.
- Effective combat stats are recalculated from equipped item bonuses.
- Client UI displays server snapshots and does not create item instances.
