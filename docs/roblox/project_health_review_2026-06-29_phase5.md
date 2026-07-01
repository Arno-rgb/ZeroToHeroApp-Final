# Project Health Review - 2026-06-29 - Phase 5 Rewards, Inventory, And Loot

## Result

PASS WITH CONDITIONS - the project may continue to Phase 6.1 after this review, but Phase 6.1 was not started during this task.

The core Phase 5 architecture is coherent enough to build the next enemy set on top of `EnemyService`, `CombatService`, `InventoryService`, `HeroProgressionService`, and `LootService`. Before the vertical slice becomes wider, the project should retire or isolate the remaining legacy combat/training client paths and harden loot claim semantics for boss, chest, and campaign rewards.

## Scope Reviewed

- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/master_game_spec.md`
- `docs/roblox/architecture.md`
- `docs/roblox/visual_direction.md`
- `docs/player_earning_economy_plan.md`
- `docs/project_summary.md`
- `roblox/src`
- `roblox/tests`
- Studio `ReplicatedStorage.ZeroToHeroShared`
- Studio `ServerScriptService.ZeroToHeroServer`
- Studio `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient`
- Studio `Workspace.AscensionGrounds`
- Studio legacy prototype scripts, legacy remotes, and quarantined Creator Store scripts

## What Is Working

- Phase 5 milestones 5.1, 5.2, 5.3, and 5.4 are documented with source files, Studio mirror paths, and observed Studio checks.
- Valuable Phase 5 mutations are server-owned:
  - Hero XP and Gold through `HeroProgressionService` and `PlayerDataService`.
  - item ownership and equipment through `InventoryService`.
  - material storage through `PlayerDataService.AddMaterial`.
  - loot rolls and grants through `LootService`.
- `ItemConfig` remains the shared source of truth for item IDs, slots, rarities, trade policies, and combat-stat bonuses.
- `LootTableConfig` now gives Lesser Slime a reusable table instead of keeping reward rolls inside enemy code.
- Lesser Slime uses `LootTableId = "LesserSlime"` and `EnemyService` routes defeat rewards through `LootService.GrantLoot`.
- `InventoryAction` exposes request/inspect/compare/equip/unequip/remove actions only; there is no client action that creates item instances.
- Runtime `ZeroToHeroShared.Remotes` contains the expected canonical remotes:
  - `CombatAction`
  - `CombatFeedback`
  - `InventoryAction`
  - `InventorySnapshot`
  - `TrainingStationAction`
  - `TrainingStationChallenge`
  - `TrainingStationReward`
- Studio Play mode loaded a profile with inventory and materials tables.
- Runtime Lesser Slime state exists and its loot table validates.
- Console output during the review smoke check showed only the expected unpublished-place DataStore warning.
- Roblox source/docs remain separate from the React/Vite coach demo.

## What Is Fragile

- Published DataStore persistence remains unverified for Hero XP/Gold and inventory/equipment because local Studio is still session-only.
- `LootService.GrantLoot` is not atomic across Hero XP/Gold, material mutation, item creation, and reward-key marking. It is acceptable for the current Lesser Slime path because config was validated and tested, but future boss/chest rewards need stronger claim semantics before valuable or rare rewards depend on it.
- `LootService` duplicate reward keys are session-memory only. That is enough for per-spawn Lesser Slime duplicate protection, but not enough for durable boss, campaign, chest, or mobile claim rewards.
- Reward presentation still uses `TrainingStationReward`, whose name is too narrow for combat, loot, boss, campaign, and future mobile rewards.
- Reward payload construction is duplicated between `HeroProgressionService` and `LootService`. A generic RewardService is becoming the right abstraction, but it should be introduced deliberately rather than inside 6.1 enemy behavior.
- Legacy Studio paths still create runtime surface area:
  - `StarterPlayer.StarterPlayerScripts.AscensionSwordCombatClient` is enabled and creates `AscensionCombatFeedbackGui`.
  - `StarterPlayer.StarterPlayerScripts.AscensionTrainingFeedbackClient` is enabled and creates `AscensionTrainingFeedbackGui`.
  - `ServerScriptService.AscensionTrainingFeedbackServer` remains enabled and `ReplicatedStorage.AscensionRemotes.StatChanged` exists.
  - Old server combat scripts are disabled at runtime by `CombatBootstrap`, but they still exist in Edit mode.
- `ReplicatedStorage.ZeroToHeroAssets.CreatorStoreQuarantine.Sword of Darkness` still contains enabled script/local-script descendants. They are quarantined under ReplicatedStorage and were not moved into live gameplay, but they remain unsafe to clone or approve without stripping.
- Studio-authored layout and shell objects remain outside `roblox/src`.
- Manual checks still include several hands-on phone/desktop readability and combat feel items from earlier milestones.
- No automated Roblox Luau test runner is configured; coverage is still documented examples plus Studio MCP assertions.

## What Should Be Refactored Now

- Retire or disable the legacy client combat feedback path before expanding combat readability work:
  - `AscensionSwordCombatClient`
  - `AscensionCombatFeedbackGui`
  - any dependency on old `AscensionRemotes` combat events
- Decide whether `AscensionTrainingFeedbackServer` and `AscensionTrainingFeedbackClient` still have any needed bridge behavior. If not, archive or disable them and remove the legacy `AscensionRemotes.StatChanged` path.
- Keep `LootService` for Phase 6.1 enemies, but before boss/chest/campaign rewards, harden it with all-or-nothing validation and profile-backed claim records for durable rewards.
- Introduce a generic reward display service/event before richer grouped reward claims or boss victory rewards, replacing the training-named reward remote in a controlled migration.
- Keep the next enemy work config-driven through `EnemyConfig` plus `LootTableConfig`. Do not fork per-enemy reward code into new scripts.

## What Must Not Be Built Yet

- Do not start Phase 6.1 in this review task.
- Do not add Break, Gatekeeper Brakk, boss phases, boss rewards, onboarding, real mobile claims, parties, guilds, PvP, auction house, housing, monetisation, or a large world.
- Do not use the quarantined Sword of Darkness scripts or VFX packs in live gameplay.
- Do not add paid mechanics, cash conversion, withdrawable Gold, or paid permanent Training Stats.
- Do not merge Roblox systems into the React coach demo.

## Verification

- Studio instance `Place1.rbxl` was listed and set active.
- Studio was confirmed in Edit mode before inspection.
- Studio Edit tree confirmed the canonical Phase 5 modules/scripts exist:
  - `LootTableConfig`
  - `ItemConfig`
  - `EnemyConfig`
  - `PlayerProfileModel`
  - `HeroProgressionService`
  - `InventoryService`
  - `LootService`
  - `LootBootstrap`
  - `RewardPopup`
  - `InventoryPanel`
- Studio Edit tree confirmed legacy and quarantine risks:
  - `AscensionSwordCombatClient` is enabled.
  - `AscensionTrainingFeedbackClient` is enabled.
  - `AscensionTrainingFeedbackServer` is enabled.
  - `ReplicatedStorage.AscensionRemotes.StatChanged` exists.
  - Sword of Darkness quarantine contains four script/local-script descendants.
- Studio Play-mode server smoke check confirmed:
  - `LootTableConfig.ValidateAllLootTables()` passed with `TableCount = 1`.
  - `ItemConfig` contains `15` item IDs.
  - Lesser Slime points to `LootTableId = "LesserSlime"`.
  - `EnemyService.GetEnemyState("LesserSlime")` exists.
  - player profile, inventory, and materials tables exist.
  - runtime remotes include combat, inventory, training, and reward events.
  - `LesserSlime` spawned in `Workspace.AscensionGrounds.EnemyArea`.
  - old server combat scripts were disabled at runtime by the canonical bootstrap path.
- Studio Play-mode client smoke check confirmed:
  - `RewardPopupGui` exists.
  - `InventoryPanelGui` exists.
  - `CombatControllerGui` exists.
  - `TrainingStatsHudGui` exists.
  - `AscensionCombatFeedbackGui` also exists from the legacy client path.
  - `AscensionTrainingFeedbackGui` also exists from the legacy client path.
- Console output showed only the expected unpublished-place DataStore warning.
- Studio Play mode was stopped after verification and returned to Edit mode.
- No Phase 6.1 implementation was started.

## Continue Decision

The project may continue to Phase 6.1 - Enemy Set after this review, but with these guardrails:

- Build new enemies through the existing enemy, combat, and loot service architecture.
- Keep the new enemies narrow: Gate Hound, Stone Shell, and Gate Sentinel only.
- Do not add Break, boss behavior, or vertical-slice flow early.
- Prefer a cleanup pass for legacy client feedback scripts before doing hands-on combat readability tests.
- Treat published persistence and mobile/hands-on checks as open risks, not as completed acceptance.
