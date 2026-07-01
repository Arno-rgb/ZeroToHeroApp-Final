# R1 Break Isolation Examples

## Goal

Verify that the Phase 6.2 Break implementation is preserved but inactive while `FeatureFlags.BreakSystemEnabled` is `false`.

## Edit-Mode Assertions

Run `tmp-codex/r1_edit_validate.lua` through Studio MCP `execute_luau` in Edit mode.

Expected:

- `ReplicatedStorage.ZeroToHeroShared.Config.FeatureFlags` exists.
- `FeatureFlags.GetFlag("BreakSystemEnabled")` returns `false`.
- `EnemyConfig.GetEnemy("StoneShell").Break` still exists for future review.
- `CombatService.TryBasicAttack` and `EnemyService.GetEnemyState` still require successfully.
- Output contains `R1_EDIT_VALIDATE ok BreakSystemEnabled=false preservedBreakConfig=true`.

## Play-Mode Server Assertions

Start Play mode and run `tmp-codex/r1_runtime_server_check.lua` through Studio MCP `execute_luau` against the Server data model.

Expected:

- Stone Shell spawns with `BreakEnabled = false`.
- Stone Shell does not create `Break`, `MaxBreak`, or `BreakState` values.
- Stone Shell does not expose a `BreakState` attribute.
- Stone Shell billboard does not contain `BreakLabel` or `BreakBar`.
- Stone Shell moves, attacks, takes normal health damage, dies, and grants its existing loot-table rewards.
- Player basic attack reports `BreakDamage = 0` and `RawBreakDamage = 0`.
- Stone Shell does not enter `Broken` or `Vulnerable` state.
- Duplicate attack after death does not grant extra Hero XP, Hero Level, or Gold.
- Output contains `R1_RUNTIME_SERVER ok`.

## Hands-On Checks Still Needed

- Fight Stone Shell from desktop player camera and confirm no Break meter appears.
- Repeat from a touch/mobile viewport and confirm no hidden Break UI space crowds the HUD.
- Confirm reward popup and combat HUD remain readable during the no-Break Stone Shell fight.
