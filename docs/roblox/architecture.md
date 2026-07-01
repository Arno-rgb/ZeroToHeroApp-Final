# Roblox Architecture

## Purpose

The Roblox project is a separate game build path from the existing React/Vite mobile coach demo. The mobile app remains the current trainer-facing product baseline. Roblox work belongs in `roblox/` and Roblox-specific planning belongs in `docs/roblox/`.

## Source Layout

- `roblox/default.project.json` maps source files into Roblox services for Rojo-compatible workflows.
- `roblox/src/shared` contains configuration, pure formulas, shared types, utility code, and remote definitions.
- `roblox/src/server` contains server-authoritative services for player data, training, rewards, combat, inventory, economy, and persistence.
- `roblox/src/client` contains UI, presentation, input, local effects, camera, and client-side controllers.
- `roblox/tests` contains pure Luau tests or documented test harnesses when available.
- `roblox/assets/reference/roblox` contains visual references used for direction only.

## Authority Boundaries

The server owns every valuable mutation:

- Training XP
- Hero XP
- Gold
- item ownership
- equipment changes
- reward claims
- damage
- enemy health
- boss rewards
- profile persistence

Clients may request actions and display approved results, but they must not submit final XP, Gold, item ownership, damage, or workout values.

## Feature Flags

Shared Roblox feature flags live in `roblox/src/shared/Config/FeatureFlags.luau` and the matching Studio ModuleScript at `ReplicatedStorage.ZeroToHeroShared.Config.FeatureFlags`.

Flags are for isolating owner-reviewed scope, not for silently shipping new mechanics. Default values must be conservative. A disabled feature must not create active player-facing state, UI, rewards, or combat effects.

Current flags:

- `BreakSystemEnabled = false`: preserves the Phase 6.2 Break implementation for future review while preventing normal Play mode from creating Break meters, Broken/Vulnerable transitions, Break vulnerability modifiers, or Break billboard UI.

## Canonical Runtime Paths

R2 disabled duplicate legacy feedback and combat scripts in the live Studio place. Future Roblox work should use these active paths:

- Sword input and combat HUD: `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Controllers.CombatController`
- Combat validation, damage, cooldowns, stamina, and feedback: `ServerScriptService.ZeroToHeroServer.Services.CombatService`
- Enemy spawn, AI, death, and reward-once delivery: `ServerScriptService.ZeroToHeroServer.Services.EnemyService`
- Strength Forge station and minigame reward validation: `ServerScriptService.ZeroToHeroServer.Services.TrainingStationService`
- Training stat mutation: `ServerScriptService.ZeroToHeroServer.Services.TrainingService`
- Training stat display: `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI.TrainingStatsHud`
- Reward display: `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI.RewardPopup`
- Inventory display and actions: `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI.InventoryPanel` and `ServerScriptService.ZeroToHeroServer.Services.InventoryService`

Disabled legacy scripts may remain in Studio for reference, but they are not valid extension points. `ReplicatedStorage.AscensionRemotes.StatChanged` is retained only as a compatibility bridge while `TrainingStationService` still contains an optional legacy fire path. Do not add new behavior to `AscensionRemotes`.

R3 presentation note: `CombatController` may create client-only target and hit feedback from replicated enemy state and server-confirmed `CombatFeedback`. Current display-only elements include the target panel, local target highlight, damage float, restrained swing trail, restrained impact burst, local enemy hit recoil, and temporary suppression of `TrainingStatsHudGui` while combat HUD is active. These elements must not mutate enemy health, player stats, rewards, cooldowns, inventory, loot, Break state, or remotes. R3 animation and audio asset IDs remain unassigned until the owner approves specific assets.

## MCP And Source Control

Roblox Studio MCP is useful for inspecting and changing the open Studio place. Source-controlled Roblox code and docs should still live under `roblox/` and `docs/roblox/` where practical.

When an MCP change creates meaningful Studio objects or scripts, record the change in `docs/roblox/progression_tracker.md`. If it creates a lasting architecture decision, record it in `docs/roblox/decision_log.md`.

## Mobile-First Roblox UI

Roblox UI must be readable on mobile first:

- large touch targets
- short labels
- no tiny stat tables
- no overloaded hero screen
- clear reward feedback immediately after training and combat

## Training Stats

The five training stats are:

- Power
- Vitality
- Agility
- Endurance
- Control

Players start with 0 earned training stat value. If future implementation uses levels internally, the effective contribution must still begin at 0 until the player trains.

## Build Rule

Build one milestone at a time. Do not start the next milestone until the current milestone has acceptance criteria recorded as complete or the user explicitly changes direction.
