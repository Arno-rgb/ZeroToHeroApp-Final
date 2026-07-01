# Roblox Master Game Blueprint

## Purpose

This document captures the Roblox direction for Zero to Hero. It does not replace the current mobile coach demo. The current app remains the companion training product and proof of the core loop: real training creates permanent hero growth.

The Roblox game should be built as a separate multiplayer action RPG after the smallest sellable coach demo and the local RPG loop are strong enough.

## Core Promise

Train in Roblox. Train in real life. Become permanently stronger.

The game must remain playable without the mobile app. Roblox-only players can progress through avatar training, combat, quests and loot. The mobile app should later accelerate training through verified real workouts, not sell power.

## Product Pillars

- Effort becomes permanent power.
- New players with strong training can still be valuable.
- Combat must be fun without fitness integration.
- Money buys identity, content and convenience, not superior combat capacity.
- The world expands only after retention proves demand.
- Valuable state is server-authoritative.

## Player Fantasy

The player begins as an unknown Adventurer, trains five base attributes, discovers a class path, enters The Broken Gate, earns gear, defeats bosses, joins parties and guilds, and eventually becomes known as an athlete, raider, trader, leader or creator.

## Progression Model

Hero Level is earned through story, enemies, dungeons, raids, events and exploration.

Training Stats are permanent base attributes:

- Power: physical damage, Break damage, charged attacks.
- Vitality: maximum HP, minor resistance, recovery.
- Agility: capped movement speed, critical chance, dodge quality.
- Endurance: stamina, Focus recovery, resistance to sustained pressure.
- Control: skill effectiveness, guard, parry, accuracy and combo quality.

Training Rank should use all five stats so players cannot exploit one-stat growth.

Suggested power contribution:

- Training attributes: about 40%
- Equipment: about 35%
- Class and abilities: about 15%
- Hero progression: about 10%

## Roblox Training

The Ascension Grounds should teach the five attributes through active minigames:

- Strength Forge for Power.
- Guardian Hall for Vitality.
- Agility Tower for Agility.
- Endurance Track for Endurance.
- Control Shrine for Control.

Training must be active, timed and server-validated. AFK training should produce little or no reward.

Suggested daily avatar-training efficiency:

- First 20 minutes: 100%
- Next 20 minutes: 70%
- Next 30 minutes: 40%
- Beyond 70 minutes: 15%

## Combat MVP

Roblox combat should be real-time third-person action combat with:

- Light Attack
- Heavy Attack
- Guard
- Dodge
- Skill 1
- Skill 2
- Ultimate
- Interact

Resources:

- HP from Vitality.
- Stamina from Endurance.
- Focus for normal abilities.
- Resolve as an ultimate meter, not a training stat.

MVP statuses:

- Guarded
- Broken
- Vulnerable
- Bleed
- Exhaust

The server must validate attack rate, distance, cooldowns, state, target validity, damage and rewards.

## Launch Classes

Adventurer is the temporary tutorial state.

Initial class paths:

- Vanguard: Vitality, Power, Control. Tank, guard, counterattack and Break pressure.
- Ranger: Agility, Control, Endurance. Mobile precision and critical chains.
- Monk: Control, Endurance, Agility. Technical counters, efficient resources and Flow.
- Berserker: Power, Vitality, Endurance. High-risk damage, Break and Rage.

Classes should be recommended by training patterns but remain player choice.

## Gear And Economy

MVP slots:

- Weapon
- Armour
- Charm

Rarity:

- Common
- Rare
- Epic
- Mythic

Binding rules:

- Common: usually tradable.
- Rare: bind on equip.
- Epic boss gear: bind on equip.
- Mythic progression rewards: often account-bound.
- Paid cosmetics: account-bound.

Normal gameplay rewards may include Gold, materials, equipment and chest fragments. They must never become cash-withdrawable.

Hard boundary:

- No Gold to Robux.
- No Gold to cash.
- No random loot to cash.
- No premium currency to tradeable combat gear.
- No paid permanent Training Stats.

## Roblox MVP

The MVP should prove that training makes the character stronger, combat is fun, loot matters and players return.

Included:

- Compact Ascension Grounds.
- One Broken Gate route.
- One boss arena.
- Strength Forge fully interactive.
- Four placeholder training stations.
- Five stats.
- Training Rank.
- Diminishing returns.
- Sword combat.
- Basic Attack, Guard, Dodge, Skill 1 and Ultimate placeholder.
- HP, Stamina, Focus and Break.
- Lesser Slime, Gate Hound, Stone Shell, Gate Sentinel and Gatekeeper Brakk.
- Hero Level, Hero XP, Gold, inventory and 15 to 25 items.
- Weapon, Armour and Charm.
- Equipment comparison and loot rewards.
- Real Training Portal with simulated one-time workout claim.
- Verified Trainee cosmetic.
- Basic parties.
- Three to five direct cosmetics.

Excluded from MVP:

- Auction house.
- Guilds.
- Raids.
- PvP.
- Real mobile integration.
- Cash payouts.
- Multiple zones.
- Housing.
- Hundreds of items.

## Immediate Next Roblox Build

The first Roblox proof should answer:

Does training, becoming stronger, fighting and earning loot feel good enough that a player wants to repeat it tomorrow?

VS Code can be connected to Roblox Studio through the workspace MCP config in `.vscode/mcp.json`. Setup instructions are in `docs/roblox_studio_mcp_vscode_setup.md`.

Build order:

1. Roblox foundation and repository workflow.
2. Persistent five-stat profile.
3. Strength Forge minigame.
4. Reward feedback for stat gain.
5. Sword combat.
6. One enemy.
7. One equipment drop.
8. Effective-stat change visible in combat.
9. Simulated mobile reward claim.
10. Gatekeeper Brakk prototype.

## Technical Architecture

Roblox services needed later:

- PlayerDataService
- TrainingService
- CombatService
- InventoryService
- RewardService
- MarketplaceService
- GuildService
- MobileClaimService

Persistent state:

- Progression
- Inventory
- Gold
- Quests
- Guild membership
- Auction ownership
- Mobile claim history

Every valuable system must be server-authoritative. The current browser-local demo is only suitable for presentation and early product testing.

## Build Phases

Phase 0: setup, Rojo workflow, source control, conventions, test place and configuration.

Phase 1: training slice with player data, five stats, Strength Forge, Training Rank, derived stats, reward UI and mobile controls.

Phase 2: combat slice with sword attacks, guard, dodge, stamina, enemy AI, validation and an elite enemy.

Phase 3: loot and progression with Hero XP, Gold, inventory, equipment, items, drops and rewards.

Phase 4: Broken Gate and Brakk with level layout, encounters, boss AI, telegraphs, rewards and VFX/audio.

Phase 5: public alpha with onboarding, mobile optimisation, analytics, exploit review, save testing, cosmetics, closed tests and balancing.

Later phases add dungeons, guilds, auction house, secure mobile integration, raids and expansions only after retention supports the scope.

## Non-Negotiable Rule

Training creates base power. Gameplay creates gear and mastery. Money buys identity, content and convenience, not victory.
