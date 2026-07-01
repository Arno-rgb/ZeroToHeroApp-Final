# Item Configuration Examples

Milestone 5.2 adds the first 15-item configuration only. It does not add inventory ownership, equip actions, loot tables, or item UI.

## Edit-Mode Config Check

In Studio Edit mode:

```lua
local itemConfig = require(game.ReplicatedStorage.ZeroToHeroShared.Config.ItemConfig)

local ids = itemConfig.GetItemIds()
assert(#ids == 15)

local validation = itemConfig.ValidateAllItems()
assert(validation.IsValid == true)
assert(validation.ItemCount == 15)
assert(validation.SlotCounts.Weapon == 5)
assert(validation.SlotCounts.Armour == 5)
assert(validation.SlotCounts.Charm == 5)

assert(itemConfig.IsValidSlot("Weapon") == true)
assert(itemConfig.IsValidSlot("Armour") == true)
assert(itemConfig.IsValidSlot("Charm") == true)
assert(itemConfig.IsValidSlot("Strength") == false)

assert(itemConfig.IsValidRarity("Common") == true)
assert(itemConfig.IsValidRarity("Rare") == true)
assert(itemConfig.IsValidRarity("Epic") == true)
assert(itemConfig.IsValidRarity("Mythic") == true)
assert(itemConfig.IsValidRarity("Legendary") == false)

assert(itemConfig.IsValidItemId("starter_training_blade") == true)
assert(itemConfig.IsValidItemId("brakks_gatebreaker") == true)
assert(itemConfig.IsValidItemId("missing_item") == false)
```

## Required Field Check

```lua
local itemConfig = require(game.ReplicatedStorage.ZeroToHeroShared.Config.ItemConfig)

local item = itemConfig.GetItem("starter_training_blade")
assert(item.Id == "starter_training_blade")
assert(item.Name == "Starter Training Blade")
assert(item.Slot == "Weapon")
assert(item.Rarity == "Common")
assert(type(item.StatBonuses) == "table")
assert(item.PassiveId ~= nil)
assert(item.TradePolicy == "AccountBound")
assert(item.Source == "Starter")
assert(type(item.Description) == "string")
```

## Budget Check

```lua
local itemConfig = require(game.ReplicatedStorage.ZeroToHeroShared.Config.ItemConfig)

for _, itemId in ipairs(itemConfig.GetItemIds()) do
	local item = itemConfig.GetItem(itemId)
	local result = itemConfig.ValidateItem(item)
	assert(result.IsValid == true, itemId)
	assert(result.Budget <= result.MaxBudget, itemId)
end
```

## Invalid Item Check

```lua
local itemConfig = require(game.ReplicatedStorage.ZeroToHeroShared.Config.ItemConfig)

local result = itemConfig.ValidateItem({
	Id = "bad_strength_item",
	Name = "Bad Strength Item",
	Slot = "Ring",
	Rarity = "Legendary",
	StatBonuses = {
		Strength = 99,
	},
	PassiveId = "",
	TradePolicy = "CashTrade",
	Source = "",
	Description = "",
})

assert(result.IsValid == false)
assert(#result.Issues >= 1)
```

## Scope Check

The milestone is intentionally config-only:

- No inventory instances are added.
- No equip or unequip actions are added.
- No loot table rolls are added.
- No client item creation path is added.
- No old permanent stat names such as `Strength` are valid stat bonus keys.
