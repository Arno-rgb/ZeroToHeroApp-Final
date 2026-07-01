# Project Health Review - 2026-06-28

## Scope

Review gate after the completed Phase 2 training progression work and before starting milestone 3.1 - Top-Down Layout.

Read before review:

- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- Required Roblox spec, architecture, visual, economy, and project-summary docs

Studio context:

- Connected Studio instance `Place1.rbxl` was listed and set active.
- Studio was inspected in Edit mode before any changes.
- No Studio objects or scripts were changed during this review.
- Play-mode smoke check booted cleanly.

## What Is Working

- Canonical source and Studio both contain the shared stat config, profile model, player data service, training service, station service, Strength Forge minigame, Stats HUD, and Reward Popup.
- Valuable training mutations remain server-authoritative through `TrainingService`, `TrainingStationService`, and `PlayerDataService`.
- Strength Forge uses server-issued challenge IDs and server-timed hit validation; the client only handles presentation and input.
- HUD data is replicated as narrow player-owned snapshots instead of exposing server profile tables.
- Reward popup listens to approved server reward payloads and queues multiple rewards.
- `Place1.rbxl` starts Play mode with only the documented unpublished-place DataStore warning.

## What Is Fragile

- Studio still contains legacy prototype scripts with `Strength` and `Coins` assumptions: `PlayerStats.server`, `EnemyArea.server`, `AscensionSwordCombatServer`, and related client combat scripts. They are not canonical and should not be extended.
- `StrengthForge.server` and `AscensionStrengthForgeTrainingServer` are disabled at runtime by `TrainingStationBootstrap`, but their source still exists in Studio.
- `Workspace.AscensionGrounds.ReferenceSpacingBlockout` already contains plaza, district, and Broken Gate blockout objects that are ahead of the formal tracker. Treat them as pre-existing exploratory Studio state until milestone 3.1 accepts or replaces them.
- Automated Luau tests are still not configured. Current coverage depends on Studio MCP checks and documented examples.
- Several manual viewport checks remain open for phone and desktop readability of the Strength Forge minigame, Stats HUD, and Reward Popup.

## What Should Be Refactored Now

- Do not do a broad refactor before 3.1.
- The next safe cleanup should be limited to documenting or quarantining legacy combat/economy scripts when their canonical replacements are built.
- Keep source-plus-Studio parity checks in every Roblox milestone because the place still contains Studio-only scaffold objects.

## What Must Not Be Built Yet

- Do not build guilds, raids, PvP, auction house, housing, monetisation, a large world, or real mobile integration.
- Do not add new combat, enemies, loot, equipment, or economy systems before the accepted layout milestone sequence calls for them.
- Do not treat the existing `ReferenceSpacingBlockout` as final art or as proof that Phase 3 acceptance criteria are already complete.

## Continue Decision

PASS - the project may continue to milestone 3.1 - Top-Down Layout.

The next task should inspect `Workspace.AscensionGrounds.ReferenceSpacingBlockout`, compare it against the 3.1 acceptance criteria, and either formalise the existing blockout or replace only the smallest missing pieces needed for the top-down layout milestone.

## Verification

- Studio instance listed: `Place1.rbxl`.
- Active Studio set: `Place1.rbxl`.
- Studio hierarchy inspected:
  - `ReplicatedStorage.ZeroToHeroShared`
  - `ServerScriptService.ZeroToHeroServer`
  - `StarterPlayer.StarterPlayerScripts`
  - `Workspace.AscensionGrounds`
- Studio script grep inspected legacy `Strength`, `Coins`, and `TrainingStationReward` paths.
- Play mode started and stopped.
- Console output: only the expected unpublished-place DataStore warning.

## Files Changed

- `docs/roblox/project_health_review_2026-06-28.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
