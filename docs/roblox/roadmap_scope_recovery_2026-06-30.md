# R0 Roadmap and Scope Recovery - 2026-06-30

## Result

R0 is complete as a documentation-only scope recovery pass.

No gameplay code was changed. No Studio gameplay objects were changed. Roblox Studio MCP was used only for read-only inspection.

## Active Roadmap

Primary roadmap:

- `docs/roblox/future_milestone_review_2026-06-30.md`

Future work must follow the owner-controlled R0-R23 sequence in that document. Older numbered prompts in `docs/roblox/codex_progression_prompt_system.md`, the master spec, and idea/planning documents are reference material only unless the active roadmap or a direct owner task explicitly selects them.

## Required Docs Read

- `AGENTS.md`
- `docs/roblox/future_milestone_review_2026-06-30.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/codex_progression_prompt_system.md`
- `docs/roblox/master_game_spec.md`
- `docs/roblox/architecture.md`
- `docs/project_summary.md`
- `docs/roblox/visual_direction.md`
- `docs/player_earning_economy_plan.md`
- `roblox/assets/reference/roblox`

Additional prompt/planning files inspected for scope-control risk:

- `docs/roblox_build_from_spec_prompt.md`
- `docs/roblox_master_game_blueprint.md`
- `docs/roblox/one_minigame_per_zone_plan.md`
- `docs/roblox/project_health_review_2026-06-29_phase5.md`

## Studio MCP Inspection

Connected Studio instance:

- `Zero` (`daf06854-250b-4b0a-9020-5db184f1c1be`)

Read-only Studio tree inspection covered:

- `ReplicatedStorage`
- `ReplicatedStorage.ZeroToHeroShared`
- `ReplicatedStorage.ZeroToHeroShared.Config`
- `ReplicatedStorage.ZeroToHeroShared.Remotes`
- `ReplicatedStorage.AscensionRemotes`
- `ReplicatedStorage.ZeroToHeroAssets`
- `ServerScriptService`
- `ServerScriptService.ZeroToHeroServer`
- `ServerScriptService.ZeroToHeroServer.Services`
- `StarterPlayer.StarterPlayerScripts`
- `StarterGui`
- `Workspace.AscensionGrounds`
- `Workspace.AscensionGrounds.EnemyArea`
- existing visual layers under `Workspace.AscensionGrounds`

Studio MCP findings:

- `Workspace.AscensionGrounds.EnemyArea` in the inspected tree contains only the legacy `TrainingDummy`, `EnemyAreaBoundary`, and `EnemyAreaFloor` as persistent edit-time objects.
- `GateHound`, `StoneShell`, `GateSentinel`, `LesserSlime`, and their billboards/telegraphs are spawned at runtime by `EnemyService.Start()` from `EnemyConfig`, not stored as persistent edit-time models.
- `StarterGui` has no persistent children in the inspected tree.
- `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI` contains the existing `TrainingStatsHud`, `RewardPopup`, and `InventoryPanel` clients.
- No standalone Break client UI script exists. Break UI is created by `EnemyService` inside enemy billboards when an enemy has a `Break` config.
- `ReplicatedStorage.ZeroToHeroShared.Remotes` currently contains edit-time `TrainingStationChallenge`, `TrainingStationAction`, `InventorySnapshot`, and `InventoryAction`. Combat and reward remotes are created or ensured at runtime by server services.
- `ReplicatedStorage.AscensionRemotes.StatChanged` remains as a legacy remote.
- Legacy clients `AscensionSwordCombatClient` and `AscensionTrainingFeedbackClient` remain enabled in `StarterPlayerScripts`.

No Play mode was started or stopped for R0.

## Source Inspection Summary

Primary affected post-Phase-0.3 source paths:

- `roblox/src/shared/Config/EnemyConfig.luau`
- `roblox/src/shared/Config/LootTableConfig.luau`
- `roblox/src/shared/Config/CombatActionConfig.luau`
- `roblox/src/server/Services/CombatService.luau`
- `roblox/src/server/Services/EnemyService.luau`
- `roblox/src/server/Services/LootService.luau`
- `roblox/tests/Phase61EnemySet.examples.md`
- `roblox/tests/Phase62BreakSystem.examples.md`

Mirrored Studio paths:

- `ReplicatedStorage.ZeroToHeroShared.Config.EnemyConfig`
- `ReplicatedStorage.ZeroToHeroShared.Config.LootTableConfig`
- `ReplicatedStorage.ZeroToHeroShared.Config.CombatActionConfig`
- `ServerScriptService.ZeroToHeroServer.Services.CombatService`
- `ServerScriptService.ZeroToHeroServer.Services.EnemyService`
- `ServerScriptService.ZeroToHeroServer.Services.LootService`

## Classification Rules

- `owner-approved`: explicitly approved by the current owner task or active owner roadmap as accepted live scope.
- `indirectly implied`: appears in older specs/prompts or is implied by existing approved foundations, but has not been directly accepted as current live scope.
- `unapproved`: implemented without direct owner approval and explicitly not accepted by the active roadmap.
- `needs owner review`: should be preserved for inspection, but not expanded or treated as accepted until the owner reviews it.

## Post-Phase-0.3 Inventory

| Addition | Location | Classification | Notes |
|---|---|---|---|
| Gate Hound enemy | `EnemyConfig.GateHound`, runtime `Workspace.AscensionGrounds.EnemyArea.GateHound` | indirectly implied, needs owner review | Active roadmap says keep Phase 6.1 enemies for review. It is spawned by `EnemyService.Start()` because all enemy IDs are spawned. |
| Gate Hound runtime visuals | `EnemyService.createEnemyAccentParts`, attack telegraph, billboard | indirectly implied, needs owner review | Primitive runtime enemy parts only; no persistent edit-time Gate Hound model found. |
| Gate Hound loot and material path | `LootTableConfig.GateHound`, `gate_hound_fang`, existing item IDs `gate_hound_fangblade`, `houndstep_charm` | indirectly implied, needs owner review | Uses existing server-owned `LootService`, `HeroProgressionService`, `InventoryService`, and `PlayerDataService`. |
| Stone Shell normal enemy | `EnemyConfig.StoneShell`, runtime `Workspace.AscensionGrounds.EnemyArea.StoneShell` | indirectly implied, needs owner review | Slow armoured enemy with base `DamageTakenMultiplier = 0.65`. Keep as a normal enemy for review. |
| Stone Shell Break config | `EnemyConfig.StoneShell.Break` | unapproved, needs owner review | Active roadmap says Break was implemented without direct owner approval and should not remain active by default until reviewed. |
| Stone Shell runtime visuals | `EnemyService.createEnemyAccentParts`, attack telegraph, billboard | indirectly implied, needs owner review | Normal shell/accent visuals can remain for review; Break billboard elements are classified separately below. |
| Stone Shell loot and material path | `LootTableConfig.StoneShell`, `stone_shell_shard`, existing item ID `stone_shell_guardmail` | indirectly implied, needs owner review | Reward path is server-owned, but this enemy's loot should be reviewed with the enemy set. |
| Gate Sentinel enemy | `EnemyConfig.GateSentinel`, runtime `Workspace.AscensionGrounds.EnemyArea.GateSentinel` | indirectly implied, needs owner review | Defensive enemy from old Phase 6.1 prompt; active roadmap says keep for review. |
| Gate Sentinel defensive pattern | `EnemyConfig.GateSentinel.DefensivePattern`, `EnemyService.updateDefensivePattern`, `EnemyService.setGuardState`, `GuardTelegraph` | indirectly implied, needs owner review | Enemy defensive state, not a player guard feature. Still needs review for readability and scope. |
| Gate Sentinel loot and material path | `LootTableConfig.GateSentinel`, `sentinel_core_chip`, existing item IDs `sentinel_splitter`, `sentinel_plate` | indirectly implied, needs owner review | Uses canonical server-owned loot grant path. Do not expand. |
| Config-driven enemy role extension | `EnemyConfig`, `EnemyService.spawnEnemy`, `EnemyService.Start()` | indirectly implied, needs owner review | `EnemyService.Start()` currently spawns every configured enemy ID, so the Phase 6.1 enemies are active by default when the service starts. |
| Enemy damage multiplier path | `CombatService.readTargetDamageMultiplier`, `EnemyService.setDamageTakenMultiplier` | indirectly implied, needs owner review | Supports Stone Shell armour and Sentinel guard reduction. Also used by Break vulnerability, which is unapproved. |
| Phase 6.1 reward path | `EnemyService.grantDeathReward` to `LootService.GrantLoot` | indirectly implied, needs owner review | Rewards are server-owned. Uses `RewardKey = enemyId:spawnId:userId` for session duplicate protection. |
| Phase 6.1 tests/docs | `roblox/tests/Phase61EnemySet.examples.md` | owner-approved for documentation retention | Keep as evidence and regression reference. Does not approve expanding the enemy set. |
| Break damage field on basic attack | `CombatActionConfig.BasicAttack.BreakDamageMultiplier`, `CombatService.handleBasicAttack` result fields `BreakDamage` and `RawBreakDamage` | unapproved, needs owner review | Added for Phase 6.2. No feature flag exists yet. |
| Break meter values | `EnemyService.createEnemyModel`, runtime `Break`, `MaxBreak`, `BreakState` values | unapproved, needs owner review | Created only when `config.Break` exists. Currently applies to Stone Shell. |
| Broken and vulnerable state | `EnemyService.triggerBrokenState`, `recoverBreak`, `resetBreakState`, `applyBreakDamage` | unapproved, needs owner review | Server-owned state, but active roadmap says to disable and defer if owner approves R1. |
| Break vulnerability multiplier | `EnemyConfig.StoneShell.Break.VulnerableDamageTakenMultiplier`, `EnemyService.setDamageTakenMultiplier` | unapproved, needs owner review | Changes Stone Shell incoming damage while Broken. Should be disabled in R1 if approved. |
| Break UI indicator | `EnemyService.createBillboard`, `BreakLabel`, `BreakBar`, `BreakFill`, `refreshEnemyDisplay` | unapproved, needs owner review | No standalone client script; hide through Break disablement in R1 if approved. |
| Phase 6.2 tests/docs | `roblox/tests/Phase62BreakSystem.examples.md` | documentation retained, mechanic unapproved | Keep as implementation evidence. Do not treat as owner approval. |

## Remotes And UI

No new persistent remotes were identified as unique Phase 6.1 or Phase 6.2 additions in the inspected Studio edit tree.

Relevant existing runtime/server-created paths:

- `CombatService` ensures `CombatAction` and `CombatFeedback` from `CombatActionConfig`.
- `HeroProgressionService` and `TrainingStationService` use the existing training-named reward remote `TrainingStationReward`.
- `LootService` sends combat/loot display payloads through `HeroProgressionService.GetRewardEvent()`, which currently resolves to `TrainingStationReward`.
- `RewardPopup` is the existing client display surface for training, Hero XP, Gold, materials, items, and level-up rows.

R0 finding: reward display remains server-approved, but the remote name is still too narrow for combat/loot and should be cleaned up in a later approved cleanup milestone, not during R0.

## Visual Layers

No new persistent world visual layer was identified after Phase 0.3.

Existing visual layers inspected:

- `Workspace.AscensionGrounds.ReferenceSpacingBlockout`
- `Workspace.AscensionGrounds.Phase0VisualScalePolish`
- `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation`
- `Workspace.AscensionGrounds.Phase02VisualSalvagePass`
- `Workspace.AscensionGrounds.Phase03EnvironmentalFeedback`

Post-Phase-0.3 enemy visual changes are runtime-generated by `EnemyService`:

- Gate Hound head/ears/fangs
- Stone Shell shell plates/crown
- Gate Sentinel shield/crest/blade marker
- attack telegraphs
- Sentinel guard telegraph
- enemy billboard health text
- Break label/bar/fill when Break config exists

## Break Dependency Review

Break currently depends on:

- `EnemyConfig.StoneShell.Break`
- `CombatActionConfig.BasicAttack.BreakDamageMultiplier`
- `CombatService` returning `BreakDamage` and `RawBreakDamage`
- `EnemyService` creating Break values and applying Break damage
- `EnemyService` billboard Break UI

No other enemy config currently contains `Break`.

No reward, inventory, profile, currency, or loot grant path appears to require Break. Rewards grant on enemy death through `LootService.GrantLoot`, not through Broken state.

Stone Shell should be able to function without Break because its normal enemy behavior comes from:

- `MaxHealth`
- `AttackDamage`
- `AttackRange`
- `MoveSpeed`
- `DamageTakenMultiplier = 0.65`
- `LootTableId = "StoneShell"`
- normal `EnemyService` chase/attack/death/respawn flow

R1 should verify this directly if the owner approves disabling Break.

## Keep / Disable / Remove Recommendation

| Feature | Recommendation | Reason |
|---|---|---|
| Gate Hound | Keep for hands-on review | Fits the intended reviewed enemy set, but should not be expanded or treated as final until R11/enemy review. |
| Stone Shell | Keep as a normal enemy for hands-on review | Slow armoured enemy is useful for route review. Break behavior should be separated from the enemy. |
| Gate Sentinel | Keep for hands-on review | Defensive enemy may help the first route, but the guard pattern needs owner/readability review. |
| Break System | Preserve code, disable and defer in R1 only if the owner explicitly approves R1 | Active roadmap marks Break as implemented without direct owner approval. Do not remove in R0. |

## Old Prompt And Planning Files That Must Not Control Active Work

These files are useful references but must not override the active owner roadmap:

- `docs/roblox/codex_progression_prompt_system.md` old numbered prompts after the active override section
- `docs/roblox_build_from_spec_prompt.md`
- `docs/roblox_master_game_blueprint.md`
- `docs/roblox/one_minigame_per_zone_plan.md`
- older project health reviews and visual review documents

The active future sequence is only:

1. R0 - Roadmap and Scope Recovery
2. R1 - Disable and Isolate Break
3. R2 - Legacy Cleanup
4. R3 - Combat Presentation Polish
5. R4 - Training Handler Refactor
6. R5 - Guardian Pulse
7. R6 - Skyline Rush
8. R7 - Pace Trial
9. R8 - Rune Alignment
10. R9 - Five-Stat Regression
11. R10 - First-Session Journey
12. R11 - Enemy Review
13. R12 - Broken Gate Adventure Polish
14. R13 - Vertical-Slice Regression
15. R14 - Roleplay Foundation
16. R15 - Tavern and Social Square
17. R16 - Bard Alpha
18. R17 - Potion Brewer Alpha
19. R18 - Market Stalls
20. R19 - Roleplay Regression
21. R20 - Fantasy Market Festival
22. R21 - Analytics
23. R22 - Closed Playtest
24. R23 - Small Commercial Beta

## Stop Condition

Stop after documentation.

Do not implement R1. Do not disable Break yet. Do not remove Break yet. Do not add, rebalance, or expand any mechanics until the owner explicitly starts the next milestone.
