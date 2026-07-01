# Project Health Review - 2026-06-28 - Phase 3 Greybox

## Result

PASS - continue to milestone 4.1 - Derived Combat Stats.

Milestone 4.1 is a pure shared-formula milestone and may proceed. Later combat-controller work must not extend the active legacy combat scripts.

## Scope Reviewed

- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/master_game_spec.md`
- `docs/roblox/architecture.md`
- `docs/roblox/visual_direction.md`
- `docs/project_summary.md`
- `roblox/src`
- `roblox/tests`
- Studio `Workspace.AscensionGrounds`
- Studio canonical shared/server/client script folders
- Studio legacy prototype scripts

## What Is Working

- Phase 3 milestones 3.1, 3.2, and 3.3 are documented as complete with manual/MCP examples.
- `Workspace.AscensionGrounds.ReferenceSpacingBlockout` exists and contains the accepted central plaza, roads, district models, and Broken Gate route.
- `Milestone32ShellDetails` exists for all five districts.
- `Milestone33TransitionDetails` exists under the Broken Gate blockout.
- The live Strength Forge station still uses the canonical `TrainingStationService` path.
- Runtime `ZeroToHeroShared.Remotes` contains `TrainingStationReward`, `TrainingStationChallenge`, and `TrainingStationAction`.
- Play mode loads player `Profile`, `Stats`, `TrainingStats`, and `leaderstats`.
- Console output during the review smoke check showed only the expected unpublished-place DataStore warning.
- Roblox source and docs remain separate from the React/Vite coach demo.

## What Is Fragile

- Phase 3 layout objects are Studio-authored and are not mirrored into `roblox/src`.
- `ServerScriptService.EnemyArea.server` remains enabled and still uses legacy `Strength`/`Coins` assumptions.
- `ServerScriptService.AscensionSwordCombatServer` remains enabled and reads legacy `Strength`.
- `ServerScriptService.AscensionStrengthForgeTrainingServer` is still enabled in Edit mode, although `TrainingStationBootstrap` disables it at runtime.
- The existing `Workspace.AscensionGrounds.EnemyArea.TrainingDummy` is a legacy placeholder and should not be treated as the canonical first enemy.
- Manual hands-on route and mobile viewport checks remain open for Phase 2/3 UI and navigation polish.
- No automated Roblox Luau test runner is configured.

## What Should Be Refactored Now

- No Phase 3 visual refactor is required before 4.1.
- Milestone 4.1 should create pure derived combat formulas in shared source and should not touch legacy combat scripts.
- Before or during 4.2, the active combat implementation should migrate away from `EnemyArea.server` and `AscensionSwordCombatServer` into a canonical server-authoritative combat service.

## What Must Not Be Built Yet

- Do not add enemies before the combat foundation milestones call for them.
- Do not add Hero XP, Gold rewards, loot drops, equipment, inventory, Brakk, parties, guilds, raids, PvP, auction house, or monetisation.
- Do not extend legacy `Strength`/`Coins` combat paths.
- Do not merge Roblox game code into the React coach demo.

## Verification

- Studio instance `Place1.rbxl` was listed and set active.
- Studio Edit mode tree was inspected for Workspace, ServerScriptService, ReplicatedStorage, and StarterPlayerScripts.
- Edit-mode assertion confirmed:
  - Phase 3 blockout and shell/transition groups exist.
  - Canonical shared/server/client Roblox modules exist.
  - `AscensionPlayerProfileServer` remains disabled.
  - `AscensionSwordCombatServer` remains enabled and is a known legacy risk.
- Studio Play mode smoke check confirmed:
  - player profile and stat folders spawn
  - canonical training remotes exist at runtime
  - Phase 3 visual groups exist at runtime
  - `StrengthForge.server`, `PlayerStats.server`, `AscensionPlayerProfileServer`, and `AscensionStrengthForgeTrainingServer` were disabled at runtime
  - `EnemyArea.server` and `AscensionSwordCombatServer` remained enabled at runtime
  - console output only showed the expected unpublished-place DataStore warning
- Studio Play mode was stopped after verification.

## Continue Decision

The project may continue to milestone 4.1 - Derived Combat Stats.

Reason: 4.1 is pure, source-controlled formula work and does not need the legacy combat scripts to be resolved first. The legacy combat risk becomes blocking if 4.2 tries to build on top of the old `Strength`/`Coins` scripts instead of replacing them with canonical server-authoritative combat logic.
