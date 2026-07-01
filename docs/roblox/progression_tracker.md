# Roblox Development Progress

## Current Phase
Owner-Controlled Future Roadmap

## Current Milestone
R3 - Existing Combat Presentation Polish

## Status
PENDING ACCEPTANCE - client-only combat presentation polish is implemented, synced to Studio, and Play-mode regression passed; full R3 acceptance still needs owner-approved animation/audio assets and hands-on desktop/mobile review. Do not start R4 until R3 is accepted or the owner explicitly changes direction.

## R3 - Existing Combat Presentation Polish - 2026-07-01

**Result:** IMPLEMENTATION PASS COMPLETE / ACCEPTANCE PENDING - visual-only combat feedback improved without changing combat authority, damage, cooldowns, rewards, or enemy mechanics

**Completed**
- [x] Required Roblox docs, active roadmap, architecture, tracker, decision log, known issues, manual checklist, project summary, visual direction, visual references, and player economy boundaries were reviewed before changes.
- [x] Treated the owner's "proceed" direction after R2 as approval to start `R3 - Existing Combat Presentation Polish`.
- [x] Connected Roblox Studio instance `Zero` was listed, set active, and inspected before changes.
- [x] Inspected current sword client and server flow in `CombatController` and `CombatService`.
- [x] Replaced the live Studio `CombatController` source with the clean source-controlled file, resolving the stale wrapper body noted in known issues.
- [x] Added client-only combat presentation to the canonical `CombatController`:
  - target panel with replicated enemy name/range/HP
  - local target highlight
  - server-confirmed damage float
  - restrained local swing trail
  - restrained local impact burst
  - short local enemy hit recoil
  - combat-HUD suppression of the training stats HUD while in range
  - guarded `Heartbeat` HUD update loop with `LastHudError` diagnostics
- [x] Kept all valuable state server-authoritative.
- [x] Did not change damage formulas, cooldowns, rewards, loot, enemy stats, Break feature flags, remotes, guard/dodge mechanics, or mobile control inputs.
- [x] Existing React/Vite coach app files were left untouched.

**Deferred / Blocked**
- Owner-approved animation IDs were not present in repo docs, source, Studio, or reference files. No arbitrary animation assets were added.
- Approved combat audio IDs were not present. No arbitrary `SoundId` assets were added.
- Full R3 acceptance remains pending until the owner supplies/approves animation/audio assets or explicitly accepts a no-asset visual-only R3.

**Acceptance Criteria Status**
- [x] Server remains authoritative.
- [x] Damage numbers are unchanged; client damage float displays the server-approved damage value.
- [x] Attack cooldown is unchanged and duplicate attack still rejects with `Cooldown`.
- [x] Mobile controls remain present and unchanged.
- [x] No new combat mechanics exist.
- [x] No duplicate legacy combat/training overlays appear.
- [x] Current attacks read more clearly through target panel, highlight, trail, impact, damage float, and hit recoil.
- [ ] Existing attacks sound materially better. Blocked by missing approved audio assets.
- [ ] Owner-approved idle/equip/swing animation IDs are added and verified. Blocked by missing approved animation assets.
- [ ] No animation loops remain stuck and equip/unequip state is verified with approved animations. Blocked until animations exist.
- [ ] Hands-on desktop and touch/mobile readability review is complete.

**Files Changed**
- `roblox/src/client/Controllers/CombatController.client.luau`
- `roblox/tests/R3CombatPresentationPolish.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/architecture.md`
- Studio source for `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Controllers.CombatController`

**Tests Run**
- Studio Edit-mode source verification:
  - Confirmed live Studio `CombatController` no longer starts with the stale wrapper body.
  - Confirmed live source contains `R3CombatPresentationPolish`, `TargetPanel`, `DamageFloat`, and `RunService.Heartbeat:Connect(runUpdateHud)`.
  - Confirmed no `SoundId` or arbitrary audio asset was introduced.
- Studio Play-mode server validation:
  - `R3_SERVER_OK Target=StoneShell Before=96 After=88 Damage=8 Break=0 CooldownReject=Cooldown`
  - Confirmed Stone Shell took normal health damage through existing server combat math.
  - Confirmed Break damage remained `0` while disabled.
  - Confirmed duplicate attack still rejected through existing cooldown authority.
- Studio Play-mode client validation:
  - `R3_CLIENT_OK Target=Stone Shell HP=88/96 Damage=8 Floats=1 Impacts=1 Trails=1 StatsHudEnabled=false`
  - Confirmed target panel showed real replicated Stone Shell health after the server-approved hit.
  - Confirmed damage float, impact burst, and swing trail ran once from confirmed feedback.
  - Confirmed combat HUD controls/resources were visible and training stats HUD was suppressed during combat.
  - Confirmed legacy `AscensionCombatFeedbackGui` and `AscensionTrainingFeedbackGui` were absent.
- Log history:
  - Console output showed only expected unpublished-place DataStore/API warnings plus R3 validation prints.
  - Studio Play mode stopped and Studio returned to Edit mode.

**Blockers / Conditions**
- R3 is not fully accepted until animation/audio asset requirements are either satisfied or explicitly waived by the owner.
- Hands-on desktop and touch/mobile checks are still needed for target panel placement, HUD overlap, impact readability, and combat feel.
- The Studio place should be saved after these MCP changes.

**Next Task**
Provide/approve R3 animation and audio assets or explicitly accept the no-asset visual-only R3 subset. Do not start `R4 - Training Minigame Handler Refactor` until R3 acceptance is resolved.

## R2 - Legacy Feedback and Duplicate Path Cleanup - 2026-06-30

**Result:** COMPLETE - duplicate legacy feedback, combat, and training paths disabled without deleting code or renaming remotes

**Completed**
- [x] Required Roblox docs, active roadmap, architecture, tracker, decision log, known issues, manual checklist, and project summary were reviewed before changes.
- [x] Treated the owner's "proceed" direction after R1 as approval to start `R2 - Legacy Feedback and Duplicate Path Cleanup`.
- [x] Connected Roblox Studio instance `Zero` listed and set active.
- [x] Studio tree inspected before changes for `StarterPlayerScripts`, `StarterGui`, `ReplicatedStorage`, `ServerScriptService`, canonical remotes, and legacy remotes.
- [x] Classified canonical paths for sword input, combat HUD, training feedback, reward popup, inventory update, and enemy reward delivery.
- [x] Disabled duplicate legacy client/server scripts in Studio Edit mode.
- [x] Tagged disabled legacy scripts with `R2LegacyStatus`, `R2ReviewedOn`, `CanonicalReplacement`, and `R2DisableReason` attributes.
- [x] Retained `ReplicatedStorage.AscensionRemotes.StatChanged` as a labeled compatibility bridge because `TrainingStationService` still optionally fires it if present.
- [x] Did not delete legacy scripts, remove `AscensionRemotes`, rename canonical remotes, or change gameplay mechanics.
- [x] Existing React/Vite coach app files were left untouched.

**Disabled / Tagged Studio Paths**
- `StarterPlayer.StarterPlayerScripts.AscensionTrainingFeedbackClient`
- `StarterPlayer.StarterPlayerScripts.AscensionSwordCombatClient`
- `ServerScriptService.AscensionTrainingFeedbackServer`
- `ServerScriptService.AscensionSwordCombatServer`
- `ServerScriptService.AscensionStrengthForgeTrainingServer`
- `ServerScriptService.EnemyArea.server`
- Previously disabled and reviewed: `PlayerStats.server`, `StrengthForge.server`, `AscensionPlayerProfileServer`
- Retained bridge: `ReplicatedStorage.AscensionRemotes`
- Retained bridge event: `ReplicatedStorage.AscensionRemotes.StatChanged`

**Acceptance Criteria**
- [x] Canonical `CombatController` remains the only active sword input/combat HUD path.
- [x] Canonical `TrainingStatsHud` and `RewardPopup` remain the only active training feedback/reward UI paths.
- [x] Canonical `InventoryPanel` remains the active inventory update UI path.
- [x] Canonical `CombatService`, `EnemyService`, `TrainingStationService`, `LootService`, and `InventoryService` remain server-authoritative.
- [x] Legacy `AscensionCombatFeedbackGui` and `AscensionTrainingFeedbackGui` no longer appear in Play mode.
- [x] Legacy `SwordAttack`, `SwordCombatFeedback`, and `AscensionTrainingEvents` are not recreated in Play mode.
- [x] Canonical remotes exist exactly once for training, combat, rewards, and inventory.
- [x] Strength Forge starts/completes, Power updates, reward popup displays, combat HUD appears, basic attack damages once, enemy death reward pays once, duplicate death reward is blocked, and inventory updates without equipment mutation.
- [x] No new console errors appeared beyond the expected unpublished-place DataStore/API warning path.

**Files Changed**
- `roblox/tests/R2LegacyCleanup.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/architecture.md`
- Studio attributes/disabled state on the paths listed above

**Tests Run**
- Studio Edit-mode audit:
  - `R2_EDIT_AUDIT` confirmed all targeted legacy scripts exist, are disabled, and carry R2 review attributes.
  - Confirmed `ReplicatedStorage.AscensionRemotes` remains with `R2LegacyStatus = RetainedLegacyBridge`.
- Studio Play-mode server validation:
  - `R2_RUNTIME_SERVER_OK {"TrainingNewLevel":1,"FirstHitOldHealth":42,"EnemyGoldGain":0,"TrainingOldLevel":0,"InventoryAfter":1,"FirstHitDamage":13,"TrainingNewXP":47,"TrainingXPGained":147,"FirstHitNewHealth":29,"EnemyHeroAfter":"1/12","EquipmentWeaponBefore":"false","TrainingOldXP":0,"EnemyHeroBefore":"1/0","EquipmentWeaponAfter":"false","InventoryBefore":0}`
  - Confirmed Strength Forge minigame completed through `TrainingStationService`.
  - Confirmed Power advanced from level 0 to level 1.
  - Confirmed one Lesser Slime basic attack reduced health from 42 to 29.
  - Confirmed defeating Lesser Slime granted Hero XP once.
  - Confirmed duplicate attack after cooldown returned `TargetDefeated` and granted no extra Hero XP, Hero Level, or Gold.
  - Confirmed inventory item count increased by one through `InventoryService.AddItem` and equipped weapon stayed unchanged.
  - Confirmed legacy `SwordAttack`, `SwordCombatFeedback`, and `AscensionTrainingEvents` were not recreated.
- Studio Play-mode client validation:
  - `R2_RUNTIME_CLIENT_OK {"RewardLastTitle":"Slime Defeated","AscensionTrainingFeedbackGui":0,"TrainingStatsHudGui":1,"InventoryPanelGui":1,"InventoryWeapon":"","InventoryCharm":"","InventoryArmour":"","RewardLastPrimary":"Hero XP","PowerLevelText":"Lv 1","RewardQueueDepth":0,"RewardPopupGui":1,"InventoryItemCount":1,"CombatControllerGui":1,"StrengthForgeMinigameGui":1,"AscensionCombatFeedbackGui":0}`
  - Confirmed canonical GUIs exist once.
  - Confirmed legacy feedback GUIs are absent.
  - Confirmed reward popup received the enemy reward.
  - Confirmed stats HUD displayed `Power Lv 1`.
  - Confirmed inventory panel displayed one test item and no equipped item mutation.
- Log history:
  - Server logs contained only the expected Studio DataStore/API disabled warnings from `PlayerDataService`.
  - Client logs were clean.
  - Studio Play mode stopped and Studio returned to Edit mode.

**Blockers / Conditions**
- No code blocker for R2.
- `ReplicatedStorage.AscensionRemotes.StatChanged` is intentionally retained as a compatibility bridge and should be removed only in a future approved cleanup after `TrainingStationService` no longer references it.
- Hands-on desktop and touch/mobile checks are still needed for combat HUD, reward popup, inventory, and Strength Forge flow readability without legacy UI surfaces.
- The Studio place should be saved after these MCP changes.

**Next Task**
Potential next milestone: `R3 - Combat Presentation Polish`, only if the owner explicitly approves starting R3. Otherwise remain on hold under the owner-controlled roadmap.

## R1 - Disable and Isolate Break - 2026-06-30

**Result:** COMPLETE - Break disabled and isolated; Stone Shell remains a normal functioning enemy

**Completed**
- [x] Required Roblox, active roadmap, architecture, tracker, decision log, known issues, manual checklist, project summary, visual direction, and reference folder docs read before changes.
- [x] Treated the owner's "proceed with plan" direction as approval to start `R1 - Disable and Isolate Break`.
- [x] Connected Roblox Studio instance `Zero` listed and set active.
- [x] Studio tree inspected before changes for shared config, server services, and enemy area paths.
- [x] Added shared `FeatureFlags` config with `BreakSystemEnabled = false`.
- [x] Preserved the existing Stone Shell Break config in `EnemyConfig` for future review.
- [x] Gated `CombatService` so `BreakDamage` / `RawBreakDamage` are `0` while Break is disabled.
- [x] Gated `EnemyService` so disabled Break does not create `Break`, `MaxBreak`, or `BreakState` values.
- [x] Gated Stone Shell billboard construction so no `BreakLabel`, `BreakBar`, or reserved Break UI space appears while disabled.
- [x] Confirmed Stone Shell still moves, attacks, takes normal damage, dies, grants Hero XP and Gold, and blocks duplicate rewards.
- [x] Mirrored changed source modules into Studio.
- [x] Existing React/Vite coach app files were left untouched.

**Acceptance Criteria**
- [x] Break is inactive in normal Play mode through `FeatureFlags.BreakSystemEnabled = false`.
- [x] Break UI does not appear; Stone Shell billboard has no Break label/bar and no reserved Break UI space.
- [x] Stone Shell remains fully fightable: spawn, movement, attack, normal damage, death, and reward path verified.
- [x] Stone Shell grants the same intended normal reward path through its existing loot table.
- [x] No new console errors appeared; only the expected unpublished-place DataStore warning was present.
- [x] Feature flag is documented in architecture and decision log.
- [x] Break can be re-enabled only through explicit configuration change.

**Files Changed**
- `roblox/src/shared/Config/FeatureFlags.luau`
- `roblox/src/server/Services/CombatService.luau`
- `roblox/src/server/Services/EnemyService.luau`
- `roblox/tests/R1BreakIsolation.examples.md`
- `tmp-codex/sync_r1_to_studio.py`
- `tmp-codex/r1_edit_validate.lua`
- `tmp-codex/r1_runtime_server_check.lua`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/architecture.md`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.FeatureFlags`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.CombatService`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.EnemyService`

**Tests Run**
- Studio Edit-mode validation:
  - `R1_EDIT_VALIDATE ok BreakSystemEnabled=false preservedBreakConfig=true`
  - Required `FeatureFlags`, `EnemyConfig`, `CombatActionConfig`, `CombatService`, and `EnemyService`.
  - Confirmed `BreakSystemEnabled` defaults to `false`.
  - Confirmed Stone Shell Break config remains preserved in `EnemyConfig`.
  - Confirmed Stone Shell armor multiplier and loot table remain unchanged.
- Studio Play-mode server validation:
  - `R1_RUNTIME_SERVER ok moved=5.83 firstDamage=8 break=0 goldGain=2 heroBefore=1/0 heroAfter=2/0`
  - Confirmed Stone Shell spawned with `BreakEnabled = false`.
  - Confirmed no `Break`, `MaxBreak`, or `BreakState` values were created.
  - Confirmed no `BreakState` attribute existed.
  - Confirmed Stone Shell billboard had no `BreakLabel` or `BreakBar` and no reserved Break UI height.
  - Confirmed Stone Shell moved toward the player and performed an attack.
  - Confirmed player basic attack dealt normal health damage with `BreakDamage = 0`.
  - Confirmed Stone Shell did not become Broken or Vulnerable and retained `DamageTakenMultiplier = 0.65`.
  - Confirmed Stone Shell death granted guaranteed Gold and Hero progression through the existing loot path.
  - Confirmed duplicate attack against defeated Stone Shell did not grant extra Hero XP, Hero Level, or Gold.
  - Console output showed only the expected unpublished-place DataStore warnings plus the R1 validation summary.
  - Studio Play mode stopped and Studio returned to Edit mode.

**Blockers / Conditions**
- No code blocker for R1.
- Hands-on desktop and touch/mobile fights are still needed to confirm Stone Shell's no-Break billboard, combat HUD, reward popup, and camera readability from a real player perspective.
- Existing Phase 6.1 enemy-set hands-on review and legacy cleanup risks remain.
- The Studio place should be saved after these MCP changes.

**Next Task**
Potential next milestone: `R2 - Legacy Feedback and Duplicate Path Cleanup`, only if the owner explicitly approves starting R2. Otherwise remain on hold under the owner-controlled roadmap.

## R0 - Roadmap and Scope Recovery - 2026-06-30

**Result:** COMPLETE - documentation-only scope recovery; no gameplay code or Studio gameplay objects changed

**Completed**
- [x] Required Roblox, roadmap, architecture, tracker, decision, known issue, manual checklist, project summary, visual, and economy docs read.
- [x] Connected Roblox Studio instance `Zero` listed and set active.
- [x] Studio tree inspected in read-only mode.
- [x] Current `Workspace.AscensionGrounds`, `ReplicatedStorage`, `ServerScriptService`, `StarterPlayerScripts`, `StarterGui`, remotes, configs, services, enemy area, and visual layers reviewed.
- [x] Phase 6.1 Enemy Set locations identified for Gate Hound, Stone Shell, Gate Sentinel, config-driven roles, loot tables, reward path, and runtime enemy visuals.
- [x] Phase 6.2 Break locations identified for Break config, Break damage, Broken/Vulnerable state, Break UI, and CombatService/EnemyService changes.
- [x] Break marked as unapproved / needs owner review.
- [x] Keep / disable / remove recommendations recorded.
- [x] Confirmed current docs point future work to the owner-controlled R0-R23 sequence.
- [x] Created `docs/roblox/roadmap_scope_recovery_2026-06-30.md`.

**Acceptance Criteria**
- [x] No gameplay code changed.
- [x] No Studio gameplay objects changed.
- [x] Post-Phase-0.3 mechanics and affected files/Studio paths identified.
- [x] Break clearly marked as unapproved / needs owner review.
- [x] Next milestone remains `R1 - Disable and Isolate Break` only if the owner explicitly approves it.
- [x] Docs clearly state Codex must follow the owner-controlled roadmap sequence.
- [x] Stopped after documentation.

**Files Changed**
- `docs/roblox/roadmap_scope_recovery_2026-06-30.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`

**Studio MCP Inspection**
- `list_roblox_studios` returned connected instance `Zero`.
- `set_active_studio` set `Zero` active.
- Read-only tree inspection covered `ReplicatedStorage`, `ServerScriptService`, `StarterPlayer`, `StarterGui`, and `Workspace.AscensionGrounds`.
- No Play mode was started or stopped for R0.

**Blockers / Conditions**
- Break is still active in source/config because R0 did not implement R1.
- Owner approval is required before adding a Break feature flag, disabling Break, removing Break, or changing Stone Shell behavior.
- Gate Hound, Stone Shell, and Gate Sentinel are preserved for hands-on owner review and must not be expanded before their active roadmap milestone.

**Next Task**
Potential next milestone: `R1 - Disable and Isolate Break`, only if the owner explicitly approves starting R1. Otherwise remain on hold under the owner-controlled roadmap.

## Roadmap Review Hold - 2026-06-30

**Result:** ACTIVE ROADMAP SEQUENCE - no new mechanics until the owner starts the next milestone

**Reason**
- The owner updated `docs/roblox/future_milestone_review_2026-06-30.md` and identified it as the main vision and future sequence for the game.
- The current tracker previously showed Phase 6.2 Break System as complete, but the owner did not explicitly request that mechanic.
- `docs/roblox/codex_progression_prompt_system.md` contains older draft prompts; those are now archived references and do not override the active owner roadmap.

**Active Roadmap Doc**
- `docs/roblox/future_milestone_review_2026-06-30.md`

**Active Sequence**
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

**Rules During Roadmap Sequence**
- [x] Follow the R0-R23 order in the active roadmap.
- [x] Do not skip ahead because a later feature appears in the master spec, old prompt system, or idea docs.
- [x] Do not extend Break, Brakk, boss rewards, mobile claims, new minigames, skills, guard/dodge, parties, guilds, PvP, monetisation, or economy systems outside the active milestone.
- [x] Allow only review, documentation, cleanup proposals, safety checks, and owner-approved corrections until the next roadmap milestone is explicitly started.

**Next Task**
R0 is complete. Do not proceed to `R1 - Disable and Isolate Break` or any later milestone until the owner explicitly approves the next step.

## Phase 6.2 - Break System - 2026-06-30

**Result:** COMPLETE - stop here and do not proceed to Gatekeeper Brakk, boss rewards, or full vertical-slice flow

**Completed**
- [x] Required Roblox docs, visual direction, economy boundaries, tracker, decision log, known issues, manual checklist, project summary, and reference folder were reviewed before changes.
- [x] Connected Studio instance `Zero` listed and set active.
- [x] Studio tree inspected before changes for canonical shared config and server service locations.
- [x] Added Stone Shell `Break` config with `MaxBreak = 16`, `BrokenDurationSeconds = 2`, and `VulnerableDamageTakenMultiplier = 1.35`.
- [x] Added `BreakDamageMultiplier` to `BasicAttack`.
- [x] Extended `CombatService` attack results with `BreakDamage` and `RawBreakDamage`, separate from health `Damage` and `RawDamage`.
- [x] Extended `EnemyService` with server-owned Break values, `Broken` / `Vulnerable` attributes, `BreakState`, temporary vulnerability, recovery, and Break UI indicator parts in the enemy billboard.
- [x] Kept Break meter and vulnerability server-owned; no client-authoritative rewards, stat gains, or economy changes were added.
- [x] Mirrored changed source modules into Studio.
- [x] Existing React/Vite coach app files were left untouched.

**Acceptance Criteria**
- [x] Basic health damage and Break damage are distinct result fields; health damage still uses `DamageTakenMultiplier`, while Break damage fills the Break meter separately.
- [x] Break meter is server-owned on Stone Shell through `Break`, `MaxBreak`, `BreakState`, and model attributes.
- [x] Broken state triggers once per filled meter and sets `State = "Broken"`, `Broken = true`, and `Vulnerable = true`.
- [x] Temporary vulnerability raises `DamageTakenMultiplier` during Broken state.
- [x] Recovery ends correctly, resets Break to `0`, restores `DamageTakenMultiplier = 0.65`, and clears `Broken` / `Vulnerable`.
- [x] Stone Shell billboard includes Break UI indicator parts.

**Files Changed**
- `roblox/src/shared/Config/EnemyConfig.luau`
- `roblox/src/shared/Config/CombatActionConfig.luau`
- `roblox/src/server/Services/CombatService.luau`
- `roblox/src/server/Services/EnemyService.luau`
- `roblox/tests/Phase62BreakSystem.examples.md`
- `tmp-codex/sync_phase62_to_studio.py`
- `tmp-codex/phase62_edit_validate.lua`
- `tmp-codex/phase62_runtime_server_check.lua`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.EnemyConfig`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.CombatActionConfig`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.CombatService`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.EnemyService`

**Tests Run**
- Studio Edit-mode validation:
  - Fresh cloned ModuleScripts required successfully.
  - Stone Shell Break config values asserted.
  - Gate Hound and Gate Sentinel confirmed not Break-enabled in Phase 6.2.
  - `BasicAttack.BreakDamageMultiplier` asserted.
  - `CombatService.TryBasicAttack` and `EnemyService.GetEnemyState` asserted.
- Studio Play-mode server validation:
  - `StoneShell` spawned with `BreakEnabled = true`, `Break`, `MaxBreak`, `BreakState`, `Broken`, and `Vulnerable`.
  - Stone Shell billboard contained `BreakLabel` and `BreakBar`.
  - First attack returned `firstDamage=8`, `raw=12`, `break=8`, and `TargetDamageMultiplier = 0.65`.
  - Break filled after two attacks and entered Broken once.
  - Broken vulnerability raised `DamageTakenMultiplier` to `1.35`.
  - A vulnerable hit used the `1.35` target multiplier without overfilling or retriggering Break.
  - Recovery cleared Broken/Vulnerable, reset Break to `0`, and restored `DamageTakenMultiplier = 0.65`.
  - Console output showed only the expected unpublished-place DataStore warnings plus `PHASE62_RUNTIME_SERVER ok hits=2 firstDamage=8 raw=12 break=8 vulnerableMultiplier=1.35`.
  - Studio Play mode stopped and Studio returned to Edit mode.

**Blockers / Conditions**
- No code blocker for milestone 6.2.
- Hands-on mouse/keyboard and touch/mobile checks are still needed for Break readability, Broken timing feel, and billboard/HUD overlap in live combat.
- Existing Phase 5 and 6.1 conditions remain before later boss/campaign work: legacy feedback cleanup, generic reward-display remote, durable loot claims, published/DataStore rejoin persistence, and enemy-set hands-on readability.
- The Studio place should be saved after these MCP changes.

**Next Task**
Stop after Phase 6.2. Do not proceed to milestone 6.3 - Gatekeeper Brakk unless explicitly requested.

## Phase 6.1 - Enemy Set - 2026-06-30

**Result:** COMPLETE - stop here and do not proceed to Break System, Gatekeeper Brakk, or full vertical-slice flow

**Completed**
- [x] Required Roblox docs, visual direction, economy boundaries, tracker, decision log, known issues, manual checklist, project summary, Phase 5 health review, and reference folder were reviewed before changes.
- [x] Connected Studio instance `Zero` listed and set active.
- [x] Studio Edit tree inspected before changes for Ascension Grounds, EnemyArea, canonical shared configs, server services, client scripts, and legacy feedback paths.
- [x] Added `GateHound`, `StoneShell`, and `GateSentinel` to `EnemyConfig`.
- [x] Kept all new enemies in the reusable `EnemyService` path instead of adding one-off enemy scripts.
- [x] Extended `EnemyService` with config-driven primitive enemy accents, enemy-specific reward titles, damage multipliers, and a timed Sentinel guard state.
- [x] Extended `CombatService` so server-owned enemy `DamageTakenMultiplier` attributes reduce or amplify player attack damage through the canonical damage path.
- [x] Added loot tables and placeholder materials for Gate Hound, Stone Shell, and Gate Sentinel through `LootTableConfig`.
- [x] Kept rewards server-controlled through `LootService`, `HeroProgressionService`, `InventoryService`, and `PlayerDataService`.
- [x] Added documented Phase 6.1 examples in `roblox/tests/Phase61EnemySet.examples.md`.
- [x] Mirrored changed source modules into Studio.
- [x] Existing React/Vite coach app files were left untouched.

**Acceptance Criteria**
- [x] Hound is fast and fragile: `GateHound` has higher move speed and lower health than `LesserSlime`.
- [x] Stone Shell is slow and armoured: `StoneShell` has low move speed and a server-owned `DamageTakenMultiplier` below `1`.
- [x] Sentinel guards or uses a clear defensive pattern: `GateSentinel` enters a timed server-owned `Guard` state with `Guarded = true` and reduced incoming damage.
- [x] All use readable telegraphs: every new enemy spawns an `AttackTelegraph`; Sentinel also spawns `GuardTelegraph`.
- [x] Rewards are server-controlled through the existing loot and progression services.

**Files Changed**
- `roblox/src/shared/Config/EnemyConfig.luau`
- `roblox/src/shared/Config/LootTableConfig.luau`
- `roblox/src/server/Services/CombatService.luau`
- `roblox/src/server/Services/EnemyService.luau`
- `roblox/tests/Phase61EnemySet.examples.md`
- `tmp-codex/phase61_edit_validate.lua`
- `tmp-codex/phase61_runtime_server_check.lua`
- `tmp-codex/roblox_mcp_call.py`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.EnemyConfig`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.LootTableConfig`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.CombatService`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.EnemyService`

**Tests Run**
- Studio Edit-mode validation:
  - `PHASE61_EDIT_VALIDATE ok enemies=4 lootTables=4`
  - `EnemyConfig` required successfully.
  - `LootTableConfig.ValidateAllLootTables()` passed.
  - `CombatService` and `EnemyService` required successfully.
- Studio Play-mode server validation:
  - `GateHound`, `StoneShell`, and `GateSentinel` spawned under `Workspace.AscensionGrounds.EnemyArea`.
  - Each new enemy had `Body`, `Health`, `MaxHealth`, `State`, and `AttackTelegraph`.
  - `GateSentinel` had `GuardTelegraph`.
  - `GateHound` took normal player attack damage: `houndDamage=12`.
  - `StoneShell` reduced player attack damage from `raw=12` to `shellDamage=8`.
  - `GateSentinel` entered `Guard` and reduced player attack damage from `raw=12` to `sentinelDamage=5`.
  - Defeating `GateHound` advanced Hero XP or Hero Level and marked `RewardClaimed = true`.
  - A duplicate attack against the dead `GateHound` did not grant extra Hero XP, Hero Level, or Gold.
  - Console output showed only the expected unpublished-place DataStore warnings plus the validation summary.
  - Studio Play mode stopped and Studio returned to Edit mode.

**Blockers / Conditions**
- No code blocker for milestone 6.1.
- Hands-on mouse/keyboard and touch/mobile combat readability checks are still needed for the new enemy set.
- Existing Phase 5 conditions remain before later Phase 6 work: legacy feedback cleanup, generic reward-display remote, durable loot claims, and published/DataStore rejoin persistence.
- The Studio place should be saved after these MCP changes.

**Next Task**
Stop after Phase 6.1. Do not proceed to milestone 6.2 - Break System unless explicitly requested.

## Phase 0.3 Environmental Animation and Feedback Pass - 2026-06-29

**Result:** COMPLETE - stop here and do not proceed to minigames

**Completed**
- [x] Latest user direction confirmed this is environmental motion/feedback only; no minigames or gameplay systems were added.
- [x] Required AGENTS instructions, master spec, architecture, tracker, visual direction, known issues, decision log, manual checklist, project summary, visual asset setup notes, recreation spec, and reference folders were reviewed.
- [x] Connected Studio instance `Zero` listed and set active.
- [x] Studio Edit tree inspected before changes, including `Phase02VisualSalvagePass`, existing prompts, HUD scripts, reward remotes, enemy/combat objects, approved assets, and quarantined assets.
- [x] Added source-controlled client visual controller `roblox/src/client/Effects/TrainingWorldVisualAnimator.client.luau`.
- [x] Mirrored the controller into Studio as `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Effects.TrainingWorldVisualAnimator`.
- [x] Added replaceable Studio-only visual layer `Workspace.AscensionGrounds.Phase03EnvironmentalFeedback`.
- [x] Existing gameplay systems, profile data, stats, rewards, combat, inventory, economy, remotes, server authority, enemy logic, minigames, and React app files were left unchanged.

**Animation / Feedback Coverage**
- [x] Central plaza: crystal pulse, soft bloom light, slow floating shards, and slow shard-ring motion.
- [x] Power / Strength Forge: furnace flicker, heat light, sparks, pulsing training pad, idle hammer/anvil visual feedback, and challenge/prompt flash hooks for `StrengthForge`.
- [x] Vitality / Guardian Grove: heartstone pulse, shield halo rotation, healing pool shimmer, and soft mote particles.
- [x] Agility / Skyward Tower: beacon pulse, slow halo motion, route marker glows, and gently moving entry banners.
- [x] Endurance / Heroes' Track: lap gate lights, start-line pulse, track flags/banners, and water-station shimmer.
- [x] Control / Arcane Shrine: orb pulse, controlled slow ring rotation, rune-floor shimmer, and low-rate arcane motes.

**Files Changed**
- `roblox/src/client/Effects/TrainingWorldVisualAnimator.client.luau`
- `tmp-codex/phase03_environmental_feedback_build.lua`
- `tmp-codex/phase03_animation_inspect.lua`
- `tmp-codex/phase03_runtime_server_check.lua`
- `tmp-codex/phase03_runtime_client_animator_check.lua`
- `tmp-codex/phase03_runtime_client_motion_probe.lua`
- `tmp-codex/roblox_mcp_call.py`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- Studio: `Workspace.AscensionGrounds.Phase03EnvironmentalFeedback`
- Studio: `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Effects.TrainingWorldVisualAnimator`

**Tests Run**
- Studio Edit-mode inspection confirmed:
  - `Phase03EnvironmentalFeedback` exists with `168` BaseParts, `8` lights, `3` ParticleEmitters, `14` Neon parts, `0` collidable parts, `0` unanchored parts, `0` Scripts, `0` LocalScripts, `0` ModuleScripts, `0` remotes, and `0` bindables.
  - Animation tags exist in the overlay: `27` pulse, `12` float, `16` rotate, `2` flicker, `3` particle, `2` prompt feedback, and `3` challenge feedback objects.
  - `TrainStrengthPrompt` stayed enabled at `(-78, 6.1, -24)`, action text `Train Power +1`, max activation distance `15`; a visual-only `StationId = StrengthForge` attribute was added for prompt/challenge feedback matching.
  - `HitEnemyPrompt` stayed enabled at `(0, 4.5, -104)`, action text `Test Damage`, max activation distance `13`.
  - No Creator Store quarantine model or blocked asset was moved live.
- Studio screenshots saved:
  - `tmp-codex/screens/phase03_spawn_view.jpg`
  - `tmp-codex/screens/phase03_power_view.jpg`
  - `tmp-codex/screens/phase03_vitality_view.jpg`
  - `tmp-codex/screens/phase03_agility_view.jpg`
  - `tmp-codex/screens/phase03_endurance_view_clear.jpg`
  - `tmp-codex/screens/phase03_control_view_clear.jpg`
- Studio Play-mode verification confirmed:
  - client animator reported ready and saw all expected tags.
  - tagged central ring moved locally over the sample window (`0.349` studs position delta, `0.105` look-vector delta).
  - console output showed only the expected unpublished-place DataStore warnings.
  - player could be moved through spawn road, central plaza, Power prompt yard, Power district, Vitality grove, Agility tower, Endurance track, Control shrine, and enemy route samples.
  - Strength Forge minigame start returned success with `3` required successes and `6` maximum attempts, then cancelled successfully.
  - `CombatService.TryBasicAttack(player, LesserSlime)` returned success and reduced health from `42` to `30`.
  - `RewardPopupGui`, `TrainingStatsHudGui`, `CombatControllerGui`, `InventoryPanelGui`, and `StrengthForgeMinigameGui` existed in the client; a server-fired reward payload reached the popup title as `Visual Check`.
  - Studio Play mode stopped after checks.

**Blockers / Conditions**
- No gameplay blocker for this pass.
- The new Phase 0.3 layer is Studio-authored and should be saved in Studio.
- The still captures verify framing, not motion quality; hands-on player-height/mobile review is still needed for final motion intensity, flicker comfort, and performance signoff.

**Next Task**
Stop after this Phase 0.3 environmental animation pass. Do not proceed to minigames, Guardian Pulse, or gameplay work unless explicitly requested.

## Phase 0.2 Training Zone Visual Salvage Pass - 2026-06-29

**Result:** COMPLETE WITH SCREENSHOT CONDITION - stop here and do not proceed to minigames

**Completed**
- [x] Latest user direction superseded Prompt A minigame refactor; no minigame/gameplay implementation was performed.
- [x] Required AGENTS instructions, master spec, architecture, tracker, visual direction, training-zone recreation spec, Phase 0.1 delta, decision log, known issues, project summary, manual checklist, visual asset setup, and reference folder were reviewed.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Current Studio tree inspected for old visual layers, prompts, source scripts, UI scripts, enemy/combat objects, and approved/quarantined assets.
- [x] Player-height before captures saved for spawn/plaza and Power approach; Guardian Grove capture timed out twice through Studio MCP.
- [x] Short visual audit created at `docs/roblox/training_zone_visual_audit_2026-06-29_phase02.md`.
- [x] Previous visual-only layers were hidden/de-emphasized instead of deleted: `ReferenceSpacingBlockout`, `Phase0VisualScalePolish`, and `Phase0TrainingZoneRecreation` including `Phase01VisualDeltaPass`.
- [x] Added replacement/correction layer `Workspace.AscensionGrounds.Phase02VisualSalvagePass`.
- [x] Existing gameplay-critical Strength Forge prompt and Training Dummy prompt were preserved at their previous transforms.
- [x] Existing gameplay systems, profile data, rewards, stats, combat, inventory, economy, remotes, server authority, enemy logic, and React app files were left unchanged.

**Visual Corrections**
- [x] World scale: new active visual footprint spans about `771.5 x 580` studs with broad central plaza, large grass base, perimeter silhouettes, and 32-34 stud main routes.
- [x] Clutter reduction: the active Phase 0.2 layer uses `306` BaseParts, `26` Neon parts, `0` thin Neon parts, `6` lights, and no particles/beams/trails; the prior visible stack had `451` Neon parts in `Phase0TrainingZoneRecreation` alone.
- [x] Power: added deeper large forge building, massive chimneys, controlled furnace glow, larger anvil yard around the unchanged prompt, and bigger boulder/weight silhouettes.
- [x] Vitality: added giant life-tree grove, large green heart crystal, protective root ring, shelters, and a broader clearing.
- [x] Agility: replaced thin scaffold read with a much taller solid tower mass, large entry arch, readable route platforms, and restrained cyan guide accents.
- [x] Endurance: added large open oval track, broad center field, taller timer gate, spectator stand, and water station.
- [x] Control: added calm large shrine courtyard, central orb, reduced armillary rings, rune curb, and four major pillar/crystal silhouettes.
- [x] Signs were moved to road edges after a player-height check showed the first Vitality sign placement blocked the route view.

**Files Changed**
- `docs/roblox/training_zone_visual_audit_2026-06-29_phase02.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- Studio: `Workspace.AscensionGrounds.Phase02VisualSalvagePass`
- Studio: visual-only hiding attributes/properties on `Workspace.AscensionGrounds.ReferenceSpacingBlockout`, `Phase0VisualScalePolish`, and `Phase0TrainingZoneRecreation`

**Tests Run**
- Studio Edit-mode inspection confirmed:
  - `Phase02VisualSalvagePass` exists with `306` BaseParts, `54` collidable broad floor/road parts, `26` Neon parts, `0` thin Neon parts, `0` unanchored parts, `0` Scripts, `0` LocalScripts, `0` ModuleScripts, `0` remotes, `0` bindables, `0` particles, `0` beams, and `0` trails.
  - Previous visual-only layers remain in the place but have `0` collidable parts after the salvage pass.
  - `TrainStrengthPrompt` stayed enabled at `(-78, 6.1, -24)`, action text `Train Power +1`, max activation distance `15`.
  - `HitEnemyPrompt` stayed enabled at `(0, 4.5, -104)`, action text `Test Damage`, max activation distance `13`.
  - No Creator Store quarantine model was moved live; `Sword of Darkness` remains blocked.
- Studio screenshots:
  - before saved: `tmp-codex/screens/phase02_before_spawn_plaza.jpg`
  - before saved: `tmp-codex/screens/phase02_before_power_approach.jpg`
  - after saved: `tmp-codex/screens/phase02_after_spawn_plaza.jpg`
  - after saved: `tmp-codex/screens/phase02_after_power_approach.jpg`
  - after saved before sign fix: `tmp-codex/screens/phase02_after_vitality_approach.jpg`
  - Guardian before, fixed Vitality after, and final fixed Power recaptures timed out through Studio MCP.
- Studio Play-mode verification confirmed:
  - console output showed only the expected unpublished-place DataStore warning
  - raycasts hit the new Phase 0.2 spawn road, central plaza, Broken Gate road, Power road/district, Vitality road/district, Agility district, Endurance district, and Control district
  - player could be moved through spawn road, central plaza, Power prompt yard, Power district, Vitality grove, Agility tower, Endurance track, Control shrine, and enemy route samples
  - Strength Forge minigame start returned success with `3` required successes and `6` maximum attempts, then cancelled successfully
  - `RewardPopupGui`, `TrainingStatsHudGui`, `CombatControllerGui`, `InventoryPanelGui`, and `StrengthForgeMinigameGui` existed in the client
  - server-fired display payload made `RewardPopupGui.Popup` visible with title `Visual Check`
  - `CombatService.TryBasicAttack(player, LesserSlime)` returned success and reduced health from `42` to `30`
  - Studio Play mode stopped after checks

**Blockers / Conditions**
- No gameplay blocker for this pass.
- Full player-height screenshot coverage remains a manual follow-up because the Studio MCP `screen_capture` tool still times out unpredictably.
- The requested `roblox/assets/reference/roblox/training_zones/` folder is still absent, so this pass used the written recreation spec plus existing root Roblox reference images.
- The new Phase 0.2 layer is Studio-authored and should be saved in Studio.
- Hands-on phone/device-simulator review is still needed for final visual signoff.

**Next Task**
Stop after this Phase 0.2 visual salvage pass. Do not proceed to minigames, Prompt A, Guardian Pulse, or gameplay work unless explicitly requested.

## Planning Task - One Minigame Per Training Zone - 2026-06-29

**Result:** COMPLETE

**Completed**
- [x] User-provided minigame ideas read from Codex attachment.
- [x] Current milestone tracker, master spec, architecture, visual direction, training-zone recreation spec, decision log, known issues, manual checklist, and economy boundaries checked for existing minigame coverage.
- [x] Existing `TrainingStationConfig`, `TrainingStationService`, `TrainingService`, `TrainingStationBootstrap`, and `StrengthForgeMinigame` source inspected.
- [x] Confirmed Power/Strength Forge already has a server-authoritative timing minigame.
- [x] Confirmed remaining four flagship minigames do not yet have implementation-level milestone docs.
- [x] Added a dedicated one-minigame-per-zone implementation plan.
- [x] Recorded decision to build one flagship minigame per stat before secondary activities.
- [x] Existing mobile React app left untouched.

**Files Changed**
- `docs/roblox/one_minigame_per_zone_plan.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/progression_tracker.md`

**Findings**
- Existing docs clearly define the five stat zones and their visual activity areas.
- Existing docs clearly define the server-authoritative Strength Forge pattern.
- Existing docs did not yet provide implementation-ready acceptance criteria for Guardian Pulse, Skyline Rush, Pace Trial, or Rune Alignment.
- The next safe gameplay step is not to build all four at once; first refactor or extend the training challenge path into typed handlers, then add one missing minigame at a time.

**Next Minigame Task**
Use `docs/roblox/one_minigame_per_zone_plan.md` and start with "Prompt A - Training Minigame Handler Refactor" before implementing Guardian Pulse.

## Phase 0.1 Training Zone Visual Delta Pass - 2026-06-29

**Result:** COMPLETE WITH SCREENSHOT CONDITION - stop here and do not proceed to gameplay

**Completed**
- [x] Required visual direction, recreation spec, visual asset setup notes, tracker, known issues, AGENTS instructions, master spec, architecture, decision log, and project summary reviewed before Studio changes.
- [x] Root reference images reviewed; the requested `roblox/assets/reference/roblox/training_zones/` folder is still missing from the repo.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio tree and current `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation` inspected before visual changes.
- [x] Current screenshot captured for Strength Forge as `phase01_current_power`.
- [x] Current screenshot attempts for Guardian Grove and Skyward Tower timed out through Studio MCP `screen_capture`.
- [x] Visual delta list and top-three fixes per zone recorded in `docs/roblox/training_zone_visual_delta_2026-06-29_phase01.md`.
- [x] Added replaceable primitive-only `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation.Phase01VisualDeltaPass`.
- [x] Applied top-three visual corrections per zone only, focused on larger landmarks, stronger color/light identity, clearer activity silhouettes, larger signs, and stronger hub-distance readability.
- [x] Existing gameplay systems, profile data, rewards, combat math, inventory logic, enemy logic, RemoteEvents, and server authority were left unchanged.
- [x] Existing mobile React app left untouched.

**Visual Corrections**
- [x] Strength Forge: larger forge facade/furnace read, taller chimney beacons, bigger anvil pad around the unchanged prompt area, and clearer Titan Lift/Boulder Break side silhouettes.
- [x] Guardian Grove: larger life tree and canopy, brighter life crystal, protective root/shield ring, and larger green hub-facing identity markers.
- [x] Skyward Tower: much taller spire/top crystal, stronger purple/cyan vertical accents, clearer route markers, and stronger Reaction Dash/Courier Run silhouettes.
- [x] Heroes' Track: larger timer gate, stronger oval/lane markers, broader start line, checkpoint flags, bigger spectator stand, and more readable water station.
- [x] Arcane Shrine: larger orb and armillary rings, clearer cyan rune pad/spokes, larger hub-facing sign, and taller crystal pillars.

**Acceptance Criteria**
- [x] Each zone is structurally closer to the written reference spec than before.
- [x] World feels larger through taller landmarks and stronger background silhouettes.
- [x] Landmarks are designed to read from the central hub: Power top ~99.5 studs, Vitality ~91 studs, Agility ~173 studs, Endurance ~40.5 studs, Control ~74.4 studs.
- [x] Paths still support groups because the new correction overlay has 0 collidable parts and does not narrow existing 22-24 stud routes.
- [x] Gameplay still works through Strength Forge, HUD, reward popup, enemy, and combat runtime checks.
- [x] No unsafe assets are live in the new overlay.
- [ ] After screenshots for all zones remain manual follow-up because Studio MCP `screen_capture` timed out after the first successful current screenshot.

**Files Changed**
- `docs/roblox/training_zone_visual_delta_2026-06-29_phase01.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- Studio: `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation.Phase01VisualDeltaPass`

**Tests Run**
- Studio Edit-mode validation confirmed:
  - `Phase01VisualDeltaPass` exists
  - new overlay contains 517 descendants, 468 BaseParts, 4 PointLights, 134 Neon parts, 0 collidable parts, 0 unanchored parts, 0 scripts, 0 LocalScripts, 0 ModuleScripts, 0 remotes, 0 bindables, 0 particles, 0 beams, and 0 trails
  - no blocked workspace assets found
  - Strength Forge prompt stayed enabled at `(-78, 6.1, -24)`, action text `Train Power +1`, max activation distance `15`
- Studio screenshots:
  - current capture succeeded: `phase01_current_power`
  - current captures for Guardian Grove and Skyward Tower timed out
  - after captures `phase01_after_power` and `phase01_after_viewport` timed out
- Studio Play-mode verification confirmed:
  - console output showed only the expected unpublished-place DataStore warning
  - player could spawn and move through central, Power, Vitality, Agility, Endurance, and Control route samples
  - Strength Forge minigame start returned success with 3 required successes and 6 max attempts, then cancelled successfully
  - `TrainingStatsHudGui`, `CombatControllerGui`, `InventoryPanelGui`, `StrengthForgeMinigameGui`, and `RewardPopupGui` existed in the client
  - server-fired display payload made `RewardPopupGui.Popup` visible with title `Visual Check`
  - `LesserSlime` spawned and `CombatService.TryBasicAttack(player, LesserSlime)` returned success, reducing health from 42 to 30
- Studio Play mode stopped after checks.

**Blockers / Conditions**
- No gameplay blocker for this visual correction pass.
- The new Phase 0.1 correction overlay is Studio-authored and should be saved in Studio.
- Manual current/after screenshots remain required for full visual signoff because Studio MCP screenshot capture timed out repeatedly.
- The requested `training_zones` reference image folder is still missing, so this pass used the written spec plus existing root references.

**Next Task**
Stop after this Phase 0.1 visual delta pass. Do not proceed to gameplay or Phase 6 work unless explicitly requested.

## Phase 0 Training Zone Recreation - 2026-06-29

**Result:** COMPLETE - stop here and do not proceed to the next gameplay milestone in this task

**Completed**
- [x] Required Roblox docs, visual direction, visual asset setup notes, asset manifest, economy boundaries, tracker, decision log, known issues, manual checklist, project summary, and `docs/roblox/training_zone_recreation_spec.md` reviewed before Studio changes.
- [x] `D:\Users\arnom\Downloads\training_zone_recreation_spec.md` checked; the spec was already present in the repo as `docs/roblox/training_zone_recreation_spec.md`, so no copy was needed.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio Edit tree inspected for gameplay-critical prompts, anchors, spawns, enemy area, server systems, HUD scripts, reward popup, remotes, quarantined assets, and approved visual assets.
- [x] Gameplay-critical transforms recorded; the live Strength Forge prompt and enemy/dummy anchors were not moved.
- [x] Short visual review recorded in `docs/roblox/training_zone_recreation_visual_review_2026-06-29.md`.
- [x] Re-inspected quarantined asset safety before use; no Creator Store quarantine models were moved live for this pass.
- [x] Added grouped visual-only `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation` with five large public training districts, broad routes, stronger silhouettes, central activity pads, secondary activity/sign clusters, and zone color language from the recreation spec.
- [x] Play mode verification run and stopped.
- [x] Existing gameplay systems, profile data, formulas, rewards, inventory ownership, remotes, server authority, enemy logic, and minigame reward payloads were left unchanged.
- [x] Existing mobile React app left untouched.

**Visual Review Summary**
- [x] Already matching references: central crystal hub, five stat zones, Strength Forge prompt/core, Broken Gate danger route, mobile HUD/reward presentation, approved primitive/LowPoly blockout language.
- [x] Too small: previous district footprints were about 43-55 studs wide and older roads about 10-13 studs wide, well below the public-space scale target.
- [x] Visually weak: Guardian needed a grove/tree landmark, Agility needed vertical tower read, Endurance needed an oval track, Control needed an armillary/orb shrine, and Power needed a larger forge yard without moving the prompt.
- [x] Safe assets: primitives and the existing approved LowPoly subset; quarantined LowPoly was script-free on re-inspection, and R6 Dummy was script-free but still not needed live.
- [x] Blocked/deferred assets: `Sword of Darkness`, full VFX/Beam packs pending mobile reduction, and the five new concept image files named by the spec because they were not present under `roblox/assets/reference/roblox`.

**Acceptance Criteria**
- [x] World feels significantly larger: five district floors now range from 150 x 115 to 195 x 145 studs.
- [x] All five training zones are distinguishable from the central hub by color, signage, and dominant landmarks.
- [x] Strength Forge, Guardian Grove, Skyward Tower, Heroes' Track, and Arcane Shrine each have a strong landmark.
- [x] Main routes are 22-24 studs wide for group movement.
- [x] Existing gameplay loop still works through the canonical Strength Forge, HUD, reward, enemy, and combat paths.
- [x] No unsafe Creator Store asset is live in the new recreation group.
- [x] New objects are grouped, named, anchored where appropriate, and replaceable.
- [x] Mobile readability is supported by large silhouettes and low/no VFX; hands-on phone/device screenshots remain recommended.

**Files Changed**
- `docs/roblox/training_zone_recreation_visual_review_2026-06-29.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- Studio: `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation`

**Tests Run**
- Studio Edit-mode inspection confirmed:
  - `Phase0TrainingZoneRecreation` exists under `Workspace.AscensionGrounds`
  - five named zone groups exist: `Power_StrengthForge`, `Vitality_GuardianGrove`, `Agility_SkywardTower`, `Endurance_HeroesTrack`, and `Control_ArcaneShrine`
  - district floors are 150 x 115, 165 x 125, 160 x 120, 195 x 145, and 165 x 125 studs
  - public roads are 22-24 studs wide
  - the group contains 883 descendants, 758 BaseParts, 38 collidable route/floor parts, 8 lights, 0 scripts, 0 LocalScripts, 0 ModuleScripts, 0 remotes, 0 bindables, 0 particles, 0 beams, 0 trails, and 0 unanchored parts
  - `TrainStrengthPrompt` remains enabled at `(-78, 6.1, -24)` with action text `Train Power +1` and max activation distance `15`
  - blocked workspace assets list was empty
- Studio screenshots:
  - one new baseline capture succeeded for the hub
  - requested comprehensive before/after screenshots for every zone, HUD, and reward popup were blocked by `screen_capture` timeouts after the first baseline; remaining screenshot coverage is tracked for manual follow-up
- Studio Play-mode verification confirmed:
  - console output showed only the expected unpublished-place DataStore warning
  - player spawned and could be moved through central, Power, Vitality, Agility, Endurance, and Control route samples
  - Strength Forge minigame start returned success with 3 required successes and 6 max attempts, then cancelled successfully
  - client `PlayerGui` contained `TrainingStatsHudGui`, `CombatControllerGui`, `InventoryPanelGui`, `StrengthForgeMinigameGui`, and `RewardPopupGui`
  - server-fired display payload made `RewardPopupGui.Popup` visible with title `Visual Check`
  - `LesserSlime` spawned and `CombatService.TryBasicAttack(player, LesserSlime)` returned success, reducing health from 42 to 30
- Studio Play mode stopped after checks.

**Blockers / Conditions**
- No blocker for this Phase 0 pass.
- The new training-zone recreation is Studio-authored and should be saved in Studio.
- Manual phone/device-simulator screenshots remain required for full visual signoff because the Studio screenshot tool timed out for most requested captures.
- The five new concept image files named in the recreation spec are missing from `roblox/assets/reference/roblox`, so this pass used the written spec plus existing references.
- Existing Phase 5 conditions remain: legacy feedback cleanup, generic reward-display remote, durable loot claims, and published/DataStore rejoin persistence are still future work.

**Next Task**
Stop after this Phase 0 visual/world-scale pass. Do not proceed to Phase 6.1 or any new gameplay milestone unless explicitly requested.

## Phase 0 Visual Alignment Review - 2026-06-29

**Result:** COMPLETE - stop here and do not start Phase 6.1 in this task

**Completed**
- [x] Required Roblox docs, visual direction, visual asset setup notes, economy boundaries, asset manifest, known issues, manual checklist, project summary, and reference images reviewed before Studio changes.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio Edit tree inspected for Ascension Grounds, Strength Forge, Broken Gate, EnemyArea, canonical UI scripts, legacy UI scripts, and quarantined/approved visual assets.
- [x] Before screenshots captured for hub scale, Strength Forge, and Broken Gate/EnemyArea.
- [x] Short visual review recorded in `docs/roblox/visual_alignment_review_2026-06-29_phase0.md`.
- [x] Re-inspected LowPoly Asset Pack before live use and copied only a small art-only subset into `ApprovedVisualAssets`.
- [x] Added grouped visual-only `Workspace.AscensionGrounds.Phase0VisualScalePolish` with central-plaza scale, district landmarks, Strength Forge polish, Broken Gate danger silhouettes, and approved LowPoly dressing.
- [x] Updated canonical stats HUD, reward popup, and combat HUD visual presentation without changing replicated data paths, remotes, rewards, combat math, or server authority.
- [x] Play mode verification run and stopped.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] Visual improvement is obvious compared with the previous primitive pass.
- [x] Hub, Strength Forge, Broken Gate/EnemyArea, stats HUD, reward popup, and combat HUD read closer to the six references without copying exact designs.
- [x] Playable loop still works: Strength Forge challenge starts/cancels, reward popup appears, combat HUD appears, Lesser Slime spawns, and a server-authoritative attack damages it.
- [x] No blocked or scripted Creator Store asset is used live.
- [x] New live visual objects are grouped, named, anchored, and replaceable.
- [x] Mobile readability is not worse by runtime UI sizing/state checks; hands-on device screenshots remain recommended.
- [x] Performance does not materially regress for this slice: 158 live visual BaseParts, 16 PointLights, no particles/beams, no scripts/remotes, and no collidable decorative parts.
- [x] Central plaza, routes, Strength Forge, Broken Gate, and district landmarks feel substantially larger from distance.

**Files Changed**
- `roblox/src/client/UI/TrainingStatsHud.client.luau`
- `roblox/src/client/UI/RewardPopup.client.luau`
- `roblox/src/client/Controllers/CombatController.client.luau`
- `docs/roblox/visual_alignment_review_2026-06-29_phase0.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- Studio: `Workspace.AscensionGrounds.Phase0VisualScalePolish`
- Studio: `ReplicatedStorage.ZeroToHeroAssets.ApprovedVisualAssets.Phase0LowPolyApprovedSubset`
- Studio: canonical live UI scripts under `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient`

**Tests Run**
- Studio Edit-mode inspection confirmed:
  - `Phase0VisualScalePolish` exists with five named child groups
  - live visual group contains 158 BaseParts, 16 PointLights, 0 collidable parts, 0 unanchored parts, 0 scripts, and 0 remotes
  - `Phase0LowPolyApprovedSubset` contains five art-only LowPoly templates with 0 scripts and 0 remotes
  - `TrainStrengthPrompt` remains enabled with unchanged interaction distance and action text
  - `StarterSpawn` position was unchanged
- Studio captures:
  - before: `phase0_before_hub_scale_retry`, `phase0_before_strength_forge_top`, `phase0_before_broken_gate_enemy`
  - after: `phase0_after_hub_scale`, `phase0_after_strength_forge_oblique`
  - after danger-route and runtime HUD screenshot attempts timed out; runtime UI was verified by client tree/state inspection
- Studio Play-mode verification confirmed:
  - console output showed only the expected unpublished-place DataStore warning
  - canonical remotes still existed at runtime
  - Strength Forge minigame start returned success with 3 required successes and 6 max attempts, then cancelled successfully
  - server-fired reward display payload made `RewardPopupGui.Popup` visible with `LastRewardTitle = "Visual Check"`
  - combat HUD controls/resources were visible near Lesser Slime
  - `LesserSlime` spawned with `Health = 42`, `State = Idle`
  - `CombatService.TryBasicAttack(player, LesserSlime)` returned success and reduced health from 42 to 30
- Studio Play mode stopped after checks.

**Blockers / Conditions**
- No blocker for the completed visual pass.
- The Phase 0 visual polish remains Studio-authored and should be saved in Studio.
- Hands-on phone/device-simulator screenshots are still recommended before treating mobile composition as final.
- Existing Phase 5 conditions remain: legacy feedback cleanup, generic reward-display remote, durable loot claims, and published/DataStore rejoin persistence are still future work.

**Next Task**
Stop after this Phase 0 visual pass. Do not proceed to Phase 6.1 unless explicitly requested.

## Project Health Review Gate - 2026-06-29 - Phase 5

**Result:** PASS WITH CONDITIONS - do not start Phase 6.1 yet in this task

**Completed**
- [x] Required Roblox project docs, visual direction, economy plan, project summary, progress tracker, decision log, known issues, manual checklist, and reference folder listing read before the review.
- [x] User explicitly requested a project-health review and explicitly said not to start 6.1 yet.
- [x] Source-controlled Roblox modules and documented tests inspected for Phase 5 reward, inventory, equipment, and loot architecture.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio Edit-mode tree inspected for canonical shared/server/client folders, Phase 5 scripts, legacy scripts, legacy remotes, and quarantine risks.
- [x] Studio Play-mode smoke check run without changing Studio objects or scripts.
- [x] Confirmed canonical Phase 5 modules and remotes are present and runtime-require cleanly.
- [x] Confirmed Lesser Slime uses `LootTableId = "LesserSlime"` and runtime enemy state exists.
- [x] Confirmed player profile loads with inventory and materials tables.
- [x] Confirmed `LootTableConfig.ValidateAllLootTables()` passes with `TableCount = 1`.
- [x] Confirmed legacy client feedback GUIs still appear at runtime and recorded that as a known issue.
- [x] Confirmed the only console output during review Play mode was the expected unpublished-place DataStore warning.
- [x] Studio Play mode stopped after verification.
- [x] Existing mobile React app left untouched.

**Review Output**
- Full review recorded in `docs/roblox/project_health_review_2026-06-29_phase5.md`.
- The project may continue to Phase 6.1 after this review, but the next implementation was not started.

**Files Changed**
- `docs/roblox/project_health_review_2026-06-29_phase5.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`

**Verification**
- Studio Edit tree confirmed:
  - canonical `ZeroToHeroShared` configs/types/utilities exist
  - canonical `ZeroToHeroServer` services and bootstraps exist
  - canonical `ZeroToHeroClient` controllers/UI scripts exist
  - `AscensionSwordCombatClient`, `AscensionTrainingFeedbackClient`, and `AscensionTrainingFeedbackServer` remain enabled legacy paths
  - `ReplicatedStorage.AscensionRemotes.StatChanged` exists
  - quarantined Sword of Darkness still contains script/local-script descendants
- Studio Play-mode server smoke check confirmed:
  - runtime remotes include `CombatAction`, `CombatFeedback`, `InventoryAction`, `InventorySnapshot`, `TrainingStationAction`, `TrainingStationChallenge`, and `TrainingStationReward`
  - `ItemConfig` contains 15 item IDs
  - Lesser Slime loot table validates
  - profile, inventory, and materials tables are present
  - old server combat scripts were disabled at runtime by canonical bootstrap logic
- Studio Play-mode client smoke check confirmed:
  - `RewardPopupGui`, `InventoryPanelGui`, `CombatControllerGui`, and `TrainingStatsHudGui` exist
  - legacy `AscensionCombatFeedbackGui` and `AscensionTrainingFeedbackGui` also exist
- Console output showed only the expected unpublished-place DataStore warning.

**Blockers / Conditions**
- Not blocking 6.1: Phase 5 server-authoritative reward/inventory/loot architecture is coherent enough for the next enemy set.
- Before broader combat readability checks: disable or archive the legacy combat feedback client path.
- Before boss/chest/campaign rewards: harden `LootService` with all-or-nothing validation and durable profile-backed reward claims.
- Before richer reward presentation: introduce a generic RewardService or reward display event to replace the training-named remote.
- Published/DataStore-enabled 5.1 and 5.3 rejoin persistence remains unverified.
- Hands-on mobile/desktop readability checks remain open across combat HUD, rewards, inventory, and player-driven slime fights.

**Next Task**
Hold before Phase 6.1 as requested. Recommended next action is a cleanup pass for legacy combat/training feedback scripts and loot-claim hardening, or explicitly proceed to 6.1 later while accepting those tracked risks.

## Milestone 5.4 - Loot Drops

**Result:** COMPLETE

**Completed**
- [x] Required Roblox project docs, economy plan, visual direction, reference folder, project summary, known issues, decision log, manual checklist, and tracker read before loot work.
- [x] User explicitly said to proceed while milestone 5.1 and 5.3 published rejoin persistence and the remaining hands-on combat/HUD/fight-feel checks remain open.
- [x] Existing `EnemyConfig`, `EnemyService`, `HeroProgressionService`, `InventoryService`, `PlayerDataService`, `RewardPopup`, and Studio script tree inspected before changes.
- [x] Added shared `LootTableConfig` with a reusable `LesserSlime` table containing guaranteed Hero XP, weighted Common item drops, optional Gold, and a placeholder material drop.
- [x] Added `LootService` as the server-authoritative loot roll and grant path for Hero XP, Gold, items, and materials.
- [x] Added duplicate reward-key protection in `LootService`.
- [x] Added `LootBootstrap` and started `LootService` from `EnemyService`.
- [x] Updated Lesser Slime config to use `LootTableId = "LesserSlime"` instead of owning ad hoc reward values.
- [x] Routed Lesser Slime defeat rewards through `LootService.GrantLoot`.
- [x] Extended the profile model and `PlayerDataService` with server-owned material storage through `AddMaterial`.
- [x] Extended `RewardPopup` so material rows can display with Hero XP, Gold, and item rows.
- [x] Added documented Studio assertion examples for milestone 5.4.
- [x] Mirrored loot scripts and touched service/UI scripts into the open Roblox Studio place through MCP.
- [x] Removed the old unused reward-event helper code from `EnemyService` after loot routing replaced it.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] Drop rolls occur on the server.
- [x] Loot reward appears in popup.
- [x] Item enters inventory once.
- [x] Drop table can be reused by future enemies and bosses.

**Files Changed**
- `roblox/src/shared/Config/LootTableConfig.luau`
- `roblox/src/server/Services/LootService.luau`
- `roblox/src/server/LootBootstrap.server.luau`
- `roblox/src/shared/Config/EnemyConfig.luau`
- `roblox/src/server/Services/EnemyService.luau`
- `roblox/src/shared/Types/PlayerProfileModel.luau`
- `roblox/src/server/Services/PlayerDataService.luau`
- `roblox/src/client/UI/RewardPopup.client.luau`
- `roblox/tests/LootService.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.LootTableConfig`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.LootService`
- Studio: `ServerScriptService.ZeroToHeroServer.LootBootstrap`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.EnemyConfig`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.EnemyService`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Types.PlayerProfileModel`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.PlayerDataService`
- Studio: `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI.RewardPopup`

**Tests Run**
- Studio Edit-mode source checks confirmed `EnemyConfig.GetEnemy("LesserSlime").LootTableId == "LesserSlime"` and `PlayerDataService.AddMaterial` exists after Edit-mode require cache returned stale module data.
- Studio Play-mode server assertion validated all loot tables, loaded the Lesser Slime loot table, and confirmed `EnemyService` sees `LootTableId = "LesserSlime"`.
- Server forced loot assertion granted `HeroXP +12`, `Gold +3`, `Slime Residue +1`, and one item instance from the Lesser Slime table.
- Server forced loot assertion confirmed the awarded item entered inventory exactly once.
- Server forced loot assertion confirmed material storage and Gold updated in the player profile.
- Server duplicate reward assertion retried the same reward key and returned `DuplicateReward` without adding another item/material/Gold reward.
- Client runtime assertion confirmed `RewardPopupGui` showed `Loot Found` with `Hero XP +12`, `Gold +3`, `Slime Residue +1`, and `Slime-Slick Vest +1`.
- Client runtime assertion confirmed `InventoryPanelGui` received an item count of `1` after the drop.
- `PlayerDataService.SavePlayer(player, true)` returned `false` with `SessionOnly` status in unpublished local Studio because DataStore access is unavailable.
- Console output showed only the expected unpublished-place DataStore warning.
- Fresh Play-mode require check after `EnemyService` cleanup passed.
- Studio Play mode stopped after verification.

**Blockers**
- None for milestone 5.4 acceptance.
- Milestone 5.1 and 5.3 published rejoin persistence remain unverified until the place is published and DataStore access is enabled.
- Hands-on 4.2, 4.3, 4.4, 5.1, 5.3, and 5.4 feel/readability checks remain open.

**Next Task**
Run the required project-health review for the completed Phase 5 reward/equipment/loot work before starting Phase 6.1 - Enemy Set. Also schedule the published/DataStore-enabled 5.1 and 5.3 rejoin persistence tests when the place is published.

## Milestone 5.3 - Inventory and Equipment

**Result:** READY FOR PUBLISHED REJOIN TEST

**Completed**
- [x] Required Roblox project docs, economy plan, visual direction, project summary, known issues, decision log, manual checklist, and tracker read before inventory/equipment work.
- [x] User explicitly said to proceed while milestone 5.1 published rejoin persistence and the remaining 4.2, 4.3, 4.4, and 5.1 hands-on checks remain open.
- [x] Existing `PlayerProfileModel`, `PlayerDataService`, `ItemConfig`, `CombatService`, `DerivedCombatStats`, source UI patterns, and Studio script tree inspected before changes.
- [x] Added server-authoritative `InventoryService` for owned item instances, inspect, compare, equip, unequip, and remove actions.
- [x] Added `InventoryAction` and `InventorySnapshot` remotes, with no remote action that creates client-submitted items.
- [x] Added `InventoryBootstrap` to start the inventory service.
- [x] Updated `CombatService` so player combat snapshots and damage calculations include equipped item stat bonuses.
- [x] Added a compact mobile `InventoryPanel` client UI for viewing equipped slots, item rows, stat deltas, and equip/unequip actions.
- [x] Added documented Studio assertion examples for milestone 5.3.
- [x] Mirrored inventory/equipment scripts into the open Roblox Studio place through MCP.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] Player can receive and equip a test sword.
- [x] Wrong-slot equip fails.
- [x] Effective stats update.
- [ ] Rejoin preserves inventory and equipped items.

**Files Changed**
- `roblox/src/server/Services/InventoryService.luau`
- `roblox/src/server/InventoryBootstrap.server.luau`
- `roblox/src/server/Services/CombatService.luau`
- `roblox/src/client/UI/InventoryPanel.client.luau`
- `roblox/tests/InventoryService.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.InventoryService`
- Studio: `ServerScriptService.ZeroToHeroServer.InventoryBootstrap`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.CombatService`
- Studio: `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI.InventoryPanel`

**Tests Run**
- Studio Edit-mode assertion required `InventoryService`, `CombatService`, and `ItemConfig`.
- Edit-mode assertion confirmed `InventoryAction` and `InventorySnapshot` exist under `ReplicatedStorage.ZeroToHeroShared.Remotes`.
- Edit-mode assertion confirmed `starter_training_blade` is a `Weapon` and an empty equipment profile has `0` physical and break damage equipment bonus.
- Studio Play-mode server assertion created server-owned item instance `item_000001` from `starter_training_blade`.
- Server assertion confirmed inspect and compare work for the owned item.
- Server assertion confirmed wrong-slot equip into `Charm` failed with `SlotMismatch`.
- Server assertion equipped `item_000001` into `Weapon`.
- Server assertion confirmed physical damage changed from `12` to `14` and break damage changed from `8` to `9`.
- Server assertion confirmed `CombatService.GetPlayerCombatSnapshot(player)` included the equipped sword bonuses.
- Server assertion confirmed removing an equipped item fails with `ItemEquipped`.
- Server assertion confirmed unequip clears the `Weapon` slot and drops physical damage back to `12`.
- Server assertion re-equipped the test sword for the client UI check.
- Client runtime assertion confirmed `InventoryPanelGui` exists, shows item count `1`, equipped weapon `item_000001`, physical damage `14`, and break damage `9`.
- Console output showed only the expected unpublished-place DataStore warning.
- `PlayerDataService.SavePlayer(player, true)` returned `false` in unpublished local Studio because DataStore access is unavailable.
- Studio Play mode stopped after verification.

**Blockers**
- Rejoin persistence for inventory and equipped items cannot be verified in unpublished local Studio because DataStore access is unavailable.
- Milestone 5.1 published rejoin persistence remains unverified until the place is published and DataStore access is enabled.
- Hands-on 4.2, 4.3, 4.4, and 5.1 feel/readability checks remain open.

**Next Task**
Run the published/DataStore-enabled 5.3 rejoin persistence test. If explicitly continuing without that check, use the progression prompt to select the next gated milestone and keep this persistence gap tracked.

## Milestone 5.2 - Item Configuration

**Result:** COMPLETE

**Completed**
- [x] Required Roblox project docs, economy plan, project summary, known issues, decision log, manual checklist, and tracker read before item/equipment config work.
- [x] User explicitly said to proceed while milestone 5.1 published rejoin persistence remains unverified.
- [x] Existing `PlayerProfileModel`, `CombatStatConfig`, `DerivedCombatStats`, source config style, and Studio shared config tree inspected before changes.
- [x] Added shared `ItemConfig` with exactly 15 initial items.
- [x] Defined the MVP slots: `Weapon`, `Armour`, and `Charm`.
- [x] Defined the MVP rarities: `Common`, `Rare`, `Epic`, and `Mythic`.
- [x] Added required item fields: `Id`, `Name`, `Slot`, `Rarity`, `StatBonuses`, `PassiveId`, `TradePolicy`, `Source`, and `Description`.
- [x] Included starter items and Brakk-themed Mythic items.
- [x] Added rarity stat-budget caps and normalized combat-stat budget weights.
- [x] Added validation helpers for slots, rarities, trade policies, item IDs, individual item definitions, and the full item table.
- [x] Ensured item stat bonuses use combat stat keys from `CombatStatConfig` instead of old permanent stat names like `Strength`.
- [x] Kept milestone 5.2 config-only: no inventory actions, equip actions, loot table rolls, or client item creation paths were added.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] All items have unique IDs.
- [x] Stat budgets follow the configured rarity budget caps.
- [x] Invalid items fail validation.
- [x] No old permanent stat names are introduced.

**Files Changed**
- `roblox/src/shared/Config/ItemConfig.luau`
- `roblox/tests/ItemConfig.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.ItemConfig`

**Tests Run**
- Studio Edit-mode assertion required `ReplicatedStorage.ZeroToHeroShared.Config.ItemConfig`.
- Edit-mode assertion confirmed exactly `15` item IDs.
- Edit-mode assertion confirmed `5` weapons, `5` armour items, and `5` charms.
- Edit-mode assertion confirmed `Common`, `Rare`, `Epic`, and `Mythic` are valid rarities and `Legendary` is invalid.
- Edit-mode assertion confirmed `starter_training_blade` and `brakks_gatebreaker` exist.
- Edit-mode assertion confirmed an invalid item using slot `Ring`, rarity `Legendary`, stat bonus `Strength`, and trade policy `CashTrade` fails validation with `7` issues.
- Edit-mode budget assertion confirmed every item validates and stays under its rarity cap; highest observed budget was `25` under the Mythic cap of `30`.
- Studio Play mode runtime tree confirmed `ReplicatedStorage.ZeroToHeroShared.Config.ItemConfig` exists.
- Server runtime assertion confirmed `ValidateAllItems()` passes, item count is `15`, slot counts are `5/5/5`, and Brakk's Gatebreaker is Mythic.
- Client runtime assertion confirmed the replicated config can be required by a client and returns `5` charm items.
- Console output showed only the expected unpublished-place DataStore warning.
- Studio Play mode stopped after checks.

**Blockers**
- None for milestone 5.2 acceptance.
- Milestone 5.1 published rejoin persistence remains unverified until the place is published and DataStore access is enabled.
- Hands-on 4.2, 4.3, 4.4, and 5.1 feel/readability checks remain open.

**Next Task**
Run the published/DataStore-enabled 5.1 rejoin persistence test when available. If explicitly continuing without that check, the next build milestone is 5.3 - Inventory and Equipment.

## Milestone 5.1 - Hero XP and Gold

**Result:** READY FOR PUBLISHED REJOIN TEST

**Completed**
- [x] Required Roblox project docs, economy plan, project summary, known issues, decision log, manual checklist, and tracker read before Hero progression/economy work.
- [x] User explicitly said to proceed while milestone 4.2, 4.3, and 4.4 hands-on combat/HUD/fight-feel checks remain open.
- [x] Existing `PlayerDataService`, `EnemyService`, `RewardPopup`, profile replication, and Lesser Slime reward flow inspected before changes.
- [x] Added shared `HeroProgressionConfig` with configurable Hero Level XP curve and reward popup remote name.
- [x] Added server `HeroProgressionService` for server-authoritative Hero XP, Hero Level, and Gold reward application.
- [x] Added structured reward results with old/new Hero Level, carryover Hero XP, level-up count, next XP requirement, old/new Gold, and display rows.
- [x] Updated `PlayerDataService.AddHeroXP` to use the Hero progression curve, support multiple level-ups, and store Hero XP as carryover toward the next Hero Level.
- [x] Updated replicated `player.Profile` values to include `HeroXPRequired`.
- [x] Updated `PlayerDataService.AddGold` to return old/new Gold values.
- [x] Added `PlayerDataService.GetHeroProgressSnapshot` for HUD-safe progression reads.
- [x] Routed Lesser Slime death rewards through `HeroProgressionService.AwardRewards`.
- [x] Reused the existing server-approved reward popup event for temporary combat reward display until a dedicated RewardService exists.
- [x] Added `HeroProgressionBootstrap` to start the progression service.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] Slime kill grants Hero XP.
- [x] Hero Level can increase.
- [x] Gold updates safely.
- [ ] Rejoin preserves progression in a published/DataStore-enabled place.

**Files Changed**
- `roblox/src/shared/Config/HeroProgressionConfig.luau`
- `roblox/src/server/Services/HeroProgressionService.luau`
- `roblox/src/server/HeroProgressionBootstrap.server.luau`
- `roblox/src/server/Services/PlayerDataService.luau`
- `roblox/src/server/Services/EnemyService.luau`
- `roblox/tests/HeroProgression.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.HeroProgressionConfig`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.HeroProgressionService`
- Studio: `ServerScriptService.ZeroToHeroServer.HeroProgressionBootstrap`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.PlayerDataService`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.EnemyService`

**Tests Run**
- Studio runtime tree confirmed `player.Profile.HeroLevel`, `HeroXP`, `HeroXPRequired`, and `Gold` exist.
- Studio runtime tree confirmed `ReplicatedStorage.ZeroToHeroShared.Remotes.TrainingStationReward` exists for approved reward presentation.
- Server config assertion confirmed `HeroProgressionConfig.GetRequiredXPForLevel(2) == 24` and level 3 requirement is `46`.
- Server direct award assertion advanced Hero Level, supported carryover Hero XP, granted `Gold +5`, and matched all replicated `Profile` values.
- Server direct award assertion confirmed an empty/zero reward fails with `NoRewards` and does not mutate Hero Level, Hero XP, or Gold.
- Server state-table assertion confirmed the live Lesser Slime reward table grants `HeroXP +12` when routed through `HeroProgressionService`.
- Server combat assertion defeated `LesserSlime` through `CombatService.TryBasicAttack(player, slime)` and confirmed Hero XP increased by `12`.
- Server combat assertion cleared `EnemyService` target ownership immediately before the attack and still confirmed the combat hit callback awarded Hero XP within `0.2` seconds.
- Client popup assertion recorded `LastRewardTitle = "Slime Defeated"`, `LastRewardPrimary = "Hero XP"`, and `LastRewardAmount = "+12"`.
- Local `PlayerDataService.SavePlayer(player, true)` returned `false` because unpublished Studio DataStore access is unavailable.
- Console output showed only the expected unpublished-place DataStore warning.
- Studio Play mode stopped after checks.

**Blockers**
- Published-place rejoin persistence is not verified because local Studio reports DataStore unavailable until the place is published and API/DataStore access is enabled.
- Hands-on 4.2, 4.3, and 4.4 input/HUD/fight-feel checks remain open.
- A hands-on 5.1 reward popup readability check after a player-driven slime defeat is still recommended.

**Next Task**
Run the published/DataStore-enabled 5.1 rejoin persistence test. If explicitly continuing without that check, use the progression prompt to select the next gated milestone and keep this persistence gap tracked.

## Visual Asset Setup - 2026-06-28

**Result:** COMPLETE

**Completed**
- [x] Required Roblox project docs, visual direction, reference images, asset manifests, known issues, decision log, project summary, and tracker read before asset setup.
- [x] Connected Studio instance `Place1.rbxl` inspected and confirmed in Edit mode.
- [x] Confirmed Roblox Studio MCP is already configured through `.vscode/mcp.json`; no extra Codex plugin installation was required.
- [x] Unpacked downloaded Kenney `Fantasy UI Borders`, `Mobile Controls`, and `Interface Sounds` packs into `roblox/assets/processed/kenney/`.
- [x] Added Studio asset folders under `ReplicatedStorage.ZeroToHeroAssets`.
- [x] Added `Workspace.AssetQuarantine` for safe temporary Studio inspection.
- [x] Inserted queued Creator Store assets into `ReplicatedStorage.ZeroToHeroAssets.CreatorStoreQuarantine`.
- [x] Inspected quarantined assets for scripts, remotes, particle/beam/trail counts, and descendant counts.
- [x] Updated `asset_manifest.csv` with current import/quarantine status.
- [x] Documented setup in `docs/roblox/visual_asset_setup_2026-06-28.md`.
- [x] Existing mobile React app left untouched.

**Files Changed**
- `roblox/assets/manifests/asset_manifest.csv`
- `docs/roblox/visual_asset_setup_2026-06-28.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- Studio: `ReplicatedStorage.ZeroToHeroAssets`
- Studio: `ReplicatedStorage.ZeroToHeroAssets.CreatorStoreQuarantine`
- Studio: `ReplicatedStorage.ZeroToHeroAssets.ApprovedVisualAssets`
- Studio: `Workspace.AssetQuarantine`
- Studio: quarantined Creator Store asset models

**Verification**
- Local extraction produced `1,230` PNG files, `463` SVG files, and `100` OGG files under `roblox/assets/processed/kenney/`.
- Studio quarantine scan found:
  - `LowPoly Asset Pack`: 0 scripts, 0 remotes
  - `R6 Dummy`: 0 scripts, 0 remotes
  - `Sword of Darkness`: 5 scripts/local scripts, 0 remotes
  - `Free VFX Pack 1 By DogmathPan`: 0 scripts, 0 remotes, 56 particle/beam/trail objects
  - `Beam Texture Pack`: 0 scripts, 0 remotes, 102 particle/beam/trail objects

**Blockers**
- `Sword of Darkness` is not approved for live use until stripped to art-only parts or replaced.
- VFX and beam packs need mobile particle-count review before live use.
- Quaternius environment, prop, character, monster, and animation packs still require manual download.

**Next Visual Task**
Run a scoped visual iteration pass, recommended first target: Strength Forge and Broken Gate/Enemy Area, using reference mood and the approved/quarantined asset pipeline without changing mechanics.

## Milestone 4.4 - First Enemy

**Result:** COMPLETE

**Completed**
- [x] Required Roblox project docs, economy plan, project summary, known issues, decision log, manual checklist, and tracker read before enemy/reward work.
- [x] User explicitly said to proceed while milestone 4.2 and 4.3 hands-on combat/HUD checks remain open.
- [x] Existing `CombatService`, `PlayerDataService`, reward popup payload shape, and Studio `EnemyArea` inspected before changes.
- [x] Added shared `EnemyConfig` with the single configured MVP enemy, `LesserSlime`.
- [x] Added server `EnemyService` with Idle, Detect, Chase, Attack, Dead, and Respawn states.
- [x] Added runtime-created primitive `Workspace.AscensionGrounds.EnemyArea.LesserSlime` model with `Body`, `Health`, `MaxHealth`, `State`, `AttackTelegraph`, and billboard display.
- [x] Added a ticked per-enemy loop instead of a per-frame global loop.
- [x] Added attack telegraph timing before applying incoming damage through `CombatService.ApplyIncomingDamage`.
- [x] Added `CombatService.RegisterTargetHitCallback` so server enemy systems can react to approved player hits without moving reward logic into the client.
- [x] Added `PlayerDataService.AddHeroXP` and `PlayerDataService.AddGold` server mutators for small combat rewards.
- [x] Granted Lesser Slime rewards only once per spawn/death and reset reward state on respawn.
- [x] Reused the existing server-approved reward popup event for temporary combat reward display until a dedicated RewardService exists.
- [x] Added `EnemyBootstrap` to start the enemy service.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] Enemy can be defeated.
- [x] Rewards grant once.
- [x] Enemy does not continue attacking after death.
- [x] Respawn works.
- [x] Multiple players cannot duplicate rewards for the same death.

**Files Changed**
- `roblox/src/shared/Config/EnemyConfig.luau`
- `roblox/src/server/Services/EnemyService.luau`
- `roblox/src/server/EnemyBootstrap.server.luau`
- `roblox/src/server/Services/CombatService.luau`
- `roblox/src/server/Services/PlayerDataService.luau`
- `roblox/tests/LesserSlimeEnemy.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.EnemyConfig`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.EnemyService`
- Studio: `ServerScriptService.ZeroToHeroServer.EnemyBootstrap`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.CombatService`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.PlayerDataService`

**Tests Run**
- Studio Edit-mode require check passed for `EnemyConfig`, `PlayerDataService`, `CombatService`, and `EnemyService`.
- Studio Play mode spawned `Workspace.AscensionGrounds.EnemyArea.LesserSlime`.
- Runtime tree confirmed `LesserSlime.Health`, `MaxHealth`, `State`, `Body`, `BaseShadow`, `AttackTelegraph`, and `Body.EnemyBillboard` exist.
- Runtime tree confirmed `ReplicatedStorage.ZeroToHeroShared.Remotes.TrainingStationReward` exists for approved reward presentation.
- Server assertion defeated the slime through `CombatService.TryBasicAttack`.
- Server assertion confirmed Hero XP increased by `12` on death.
- Server assertion confirmed Gold did not decrease and stayed within the configured `0-4` reward range.
- Server assertion confirmed immediate duplicate attack changed no Hero XP or Gold.
- Server assertion confirmed post-cooldown duplicate attack failed with `TargetDefeated` and changed no Hero XP or Gold.
- Server assertion confirmed the slime entered `Dead`, hid its telegraph, and set `RewardClaimed = true`.
- Server assertion confirmed respawn restored full health, reset `RewardClaimed = false`, changed `SpawnId`, and returned to `Idle` when the player was moved away.
- Server AI assertion observed the attack telegraph and confirmed incoming slime damage reduced player HP from `100` to `91`.
- Console output showed only the expected unpublished-place DataStore warning.
- Studio Play mode stopped after checks.

**Blockers**
- None for milestone 4.4 acceptance.
- Hands-on 4.2 and 4.3 input/HUD checks remain open, and a hands-on 4.4 fight-feel check is still recommended before expanding combat.

**Next Task**
Run the hands-on 4.2, 4.3, and 4.4 combat/HUD feel checks. If explicitly continuing without those checks, the next milestone is 5.1 - Hero Level and Rewards.

## Milestone 4.3 - Mobile Combat HUD

**Result:** READY FOR TEST

**Completed**
- [x] Required Roblox project docs, architecture, visual direction, mobile HUD reference listing, project summary, known issues, decision log, manual checklist, and tracker read before HUD work.
- [x] User explicitly said to proceed while milestone 4.2 hands-on input checks remain open.
- [x] Existing `CombatService`, `CombatActionConfig`, and `CombatController` source inspected before changes.
- [x] Added placeholder action metadata for Skill 1, Skill 2, Ultimate, and Interact.
- [x] Added server-generated `player.CombatState` display snapshot with HP, MaxHP, Stamina, MaxStamina, Attack cooldown, Dodge cooldown, guard state, and dodge invulnerability state.
- [x] Added throttled server combat-state sync for HUD-safe state replication.
- [x] Updated combat action handlers to resync `CombatState` after attack, guard, dodge, and incoming damage.
- [x] Replaced the source-controlled minimal combat controller with a mobile combat HUD containing HP bar, stamina bar, ATK, GUARD, DODGE, SK1, SK2, ULT, and USE.
- [x] Added cooldown overlays for Attack and Dodge.
- [x] Added disabled placeholder presentation for Skill 1, Skill 2, Ultimate, and Interact.
- [x] Kept client requests presentation/input only; final damage, stamina, cooldowns, and guard state remain server-owned.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] HP and stamina display paths exist through server-generated `CombatState`.
- [x] Basic Attack, Guard, and Dodge controls exist in the HUD.
- [x] Skill 1, Skill 2, Ultimate, and Interact placeholders exist.
- [x] Cooldown overlay paths exist for Attack and Dodge.
- [x] Combat controls are hidden/reduced away from combat by the client visibility rule.
- [ ] Hands-on touch test confirms core controls work on touch.
- [ ] Hands-on viewport test confirms buttons do not overlap other UI.
- [ ] Hands-on viewport test confirms cooldowns are readable.
- [ ] Hands-on test confirms HP and stamina bars update visibly after damage/dodge.

**Files Changed**
- `roblox/src/shared/Config/CombatActionConfig.luau`
- `roblox/src/server/Services/CombatService.luau`
- `roblox/src/client/Controllers/CombatController.client.luau`
- `roblox/tests/CombatHud.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.CombatActionConfig`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.CombatService`
- Studio: `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Controllers.CombatController`

**Tests Run**
- Studio Play mode smoke check passed after adding the HUD.
- Runtime tree confirmed `Players.Kibosabie.CombatState` exists.
- Runtime tree confirmed `CombatState` contains `HP`, `MaxHP`, `Stamina`, `MaxStamina`, `AttackCooldownMs`, `DodgeCooldownMs`, `IsGuarding`, and `DodgeInvulnerable`.
- Runtime tree confirmed `Players.Kibosabie.PlayerGui.CombatControllerGui.ResourcePanel` exists.
- Runtime tree confirmed `ResourcePanel.HP` and `ResourcePanel.Stamina` exist.
- Runtime tree confirmed `Controls.AttackButton`, `GuardButton`, `DodgeButton`, `Skill1Button`, `Skill2Button`, `UltimateButton`, and `InteractButton` exist.
- Character was moved to the dummy area for a visibility smoke check, but MCP tree inspection does not reliably prove render-step-toggled client frame visibility.
- Console output showed only the expected unpublished-place DataStore warning.
- Studio Play mode stopped after checks.

**Blockers**
- Hands-on touch and viewport layout checks remain required.
- Milestone 4.2 hands-on input checks are still open and must be resolved before treating combat controls as complete.

**Next Task**
Run the hands-on 4.2 and 4.3 combat input/HUD checks in Studio. This hold was later overridden by explicit user instruction to proceed to milestone 4.4.

## Milestone 4.2 - Player Combat Controller

**Result:** READY FOR TEST

**Completed**
- [x] Required Roblox project docs, visual direction, reference folder listing, project summary, known issues, decision log, manual checklist, and tracker read before combat controller work.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio shared/server/client/workspace trees inspected before changes.
- [x] Existing legacy `EnemyArea.server` and `AscensionSwordCombatServer` identified as non-canonical combat risks.
- [x] Added shared `CombatActionConfig` for combat remotes, target root, action ranges, cooldowns, stamina cost, dodge distance, and invulnerability timing.
- [x] Added server `CombatService` that creates `CombatAction` and `CombatFeedback` remotes.
- [x] Added server-authoritative basic attack validation for target ownership, health, range, facing arc, cooldown, and final damage.
- [x] Added server-owned guard state and `ApplyIncomingDamage` so guard mitigation changes incoming damage without trusting the client.
- [x] Added server-owned dodge validation with cooldown, stamina spend, short invulnerability window, and bounded displacement.
- [x] Added server-facing wrapper methods for manual assertions without adding client authority.
- [x] Added `CombatBootstrap` to start the canonical combat service and runtime-disable the remaining legacy combat scripts.
- [x] Added client `CombatController` with mouse, keyboard, and large touch buttons for attack, guard, and dodge.
- [x] Added concise client hit/stamina/guard feedback from approved server payloads.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] Server-authoritative hit approval and final damage path exists.
- [x] Attack cooldown validation prevents remote spam from applying repeated damage.
- [x] Distance and target validation exist before damage is applied.
- [x] Guard changes incoming damage through `CombatService.ApplyIncomingDamage`.
- [x] Dodge consumes server-owned stamina and defines invulnerability plus bounded displacement rules.
- [x] Mouse and keyboard input paths exist.
- [x] Mobile touch buttons exist.
- [x] Legacy combat scripts are runtime-disabled by the canonical combat bootstrap.
- [ ] Hands-on Studio test confirms the player can attack the test dummy through mouse/touch input.
- [ ] Hands-on Studio test confirms mobile buttons feel readable and do not conflict with the training UI.

**Files Changed**
- `roblox/src/shared/Config/CombatActionConfig.luau`
- `roblox/src/server/Services/CombatService.luau`
- `roblox/src/server/CombatBootstrap.server.luau`
- `roblox/src/client/Controllers/CombatController.client.luau`
- `roblox/tests/PlayerCombatController.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.CombatActionConfig`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.CombatService`
- Studio: `ServerScriptService.ZeroToHeroServer.CombatBootstrap`
- Studio: `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Controllers.CombatController`

**Tests Run**
- Studio Play mode smoke check passed after adding the combat controller.
- Runtime tree confirmed `ReplicatedStorage.ZeroToHeroShared.Remotes.CombatAction` exists.
- Runtime tree confirmed `ReplicatedStorage.ZeroToHeroShared.Remotes.CombatFeedback` exists.
- Runtime tree confirmed `Players.Kibosabie.PlayerGui.CombatControllerGui.Controls.AttackButton` exists.
- Runtime tree confirmed `Players.Kibosabie.PlayerGui.CombatControllerGui.Controls.GuardButton` exists.
- Runtime tree confirmed `Players.Kibosabie.PlayerGui.CombatControllerGui.Controls.DodgeButton` exists.
- Runtime tree confirmed `Workspace.AscensionGrounds.EnemyArea.TrainingDummy.MaxHealth` was created by `CombatService`.
- Console output showed only the expected unpublished-place DataStore warning.
- Studio Play mode stopped after checks.
- Full hands-on mouse/touch combat input test remains required.

**Blockers**
- The MCP toolset can start Play mode and inspect the tree, but it cannot press Studio mouse/keyboard/touch controls. Hands-on input verification remains manual.

**Next Task**
Run the milestone 4.2 hands-on combat controller test. This hold was later overridden by explicit user instruction to proceed to milestones 4.3 and 4.4.

## Milestone 4.1 - Derived Combat Stats

**Result:** COMPLETE

**Completed**
- [x] Required Roblox project docs, economy boundary notes, project summary, known issues, decision log, manual checklist, and tracker read before formula work.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio `ReplicatedStorage.ZeroToHeroShared` tree inspected before adding shared modules.
- [x] Existing `StatConfig` and `PlayerProfileModel` source/Studio shapes inspected before choosing inputs.
- [x] Added source-controlled `CombatStatConfig` as the central config for base combat stats, hero-level scaling, training weights, caps, precision, and placeholder class modifiers.
- [x] Added source-controlled `DerivedCombatStats` as a pure shared calculator.
- [x] Added Studio `ReplicatedStorage.ZeroToHeroShared.Config.CombatStatConfig`.
- [x] Added Studio `ReplicatedStorage.ZeroToHeroShared.Utility` folder.
- [x] Added Studio `ReplicatedStorage.ZeroToHeroShared.Utility.DerivedCombatStats`.
- [x] Supported initial outputs: `MaxHP`, `PhysicalDamage`, `BreakDamage`, `MaxStamina`, `StaminaRecovery`, `MoveSpeedBonus`, `CriticalChance`, `GuardEffectiveness`, and `SkillEffectiveness`.
- [x] Supported inputs: training stats, hero level, equipment bonus maps, and class modifiers.
- [x] Kept equipment bonus resolution outside the formula module so future Inventory/Combat services can aggregate real equipped items server-side.
- [x] Kept milestone 4.1 pure; no player combat controller, enemy damage, rewards, loot, or legacy combat script wiring added.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] Same input always returns same output.
- [x] Movement-speed and critical-chance caps are enforced.
- [x] Additional caps are present for HP, damage, stamina, recovery, guard, and skill effectiveness to prevent runaway values.
- [x] Equipment and training contributions are visible separately in the result.
- [x] Class multipliers are clamped before stat caps are applied.
- [x] Tests/documented examples cover low, normal, and high stat cases.

**Files Changed**
- `roblox/src/shared/Config/CombatStatConfig.luau`
- `roblox/src/shared/Utility/DerivedCombatStats.luau`
- `roblox/tests/DerivedCombatStats.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.CombatStatConfig`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Utility`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Utility.DerivedCombatStats`

**Tests Run**
- Studio Edit-mode require/assertion test for `DerivedCombatStats`: passed.
- Low case confirmed default Hero Level 1 and zero training values produce base stats exactly.
- Normal case confirmed hero-level, training, equipment, and Vanguard class contributions combine deterministically:
  - `MaxHP = 254`
  - `PhysicalDamage = 32.4`
  - `BreakDamage = 20.64`
  - `MaxStamina = 184`
  - `StaminaRecovery = 9.29`
  - `MoveSpeedBonus = 0.018`
  - `CriticalChance = 0.0845`
  - `GuardEffectiveness = 0.176`
  - `SkillEffectiveness = 1.075`
- High case confirmed runaway movement, critical chance, physical damage, and other high values are capped.
- Contribution assertions confirmed training and equipment values are exposed separately.
- Studio Play mode smoke check passed after adding the modules.
- Console output showed only the expected unpublished-place DataStore warning.
- Studio Play mode stopped after checks.

**Blockers**
- None for milestone 4.1.

**Next Task**
Milestone 4.2 - Player Combat Controller. Do not extend the legacy `EnemyArea.server` or `AscensionSwordCombatServer` scripts as the canonical combat path.

## Milestone 1.3 - Player Data Service

## Completed
- [x] Required Roblox project docs read before Studio work
- [x] Economy plan read because the service owns Gold, inventory-bearing profile state, and reward-claim storage
- [x] Connected Studio instance `Place1.rbxl` listed and set active
- [x] Current source tree, Studio shared modules, existing profile server, and training feedback script inspected before changes
- [x] Server-authoritative `PlayerDataService` source module created
- [x] Source bootstrap script created
- [x] Default profile creation uses `PlayerProfileModel`
- [x] Session cache added
- [x] Safe profile load path added
- [x] Version-aware profile repair/migration path added
- [x] Legacy simple-stat load path handled without treating it as canonical
- [x] Save path added with `UpdateAsync`
- [x] PlayerRemoving release/save attempt added
- [x] BindToClose save attempt added
- [x] Studio-safe session-only mode added when DataStores are unavailable
- [x] Server-side snapshot and mutator APIs added
- [x] Client write path avoided; no client remote can set profile values
- [x] Replicated `Profile`, `Stats`, and `leaderstats` values generated from cached profile state
- [x] Studio `PlayerDataService` ModuleScript and bootstrap created under `ServerScriptService.ZeroToHeroServer`
- [x] Legacy `ServerScriptService.AscensionPlayerProfileServer` disabled
- [x] Current training feedback award path now uses `PlayerDataService.AddTrainingStatValue`
- [x] Manual PlayerDataService examples and join/rejoin persistence procedure documented
- [x] Existing mobile React app left untouched

## Acceptance Criteria
- [x] New player receives a valid profile
- [x] Session cache is server-owned
- [x] Save profile path exists
- [x] Release profile path exists
- [x] Server-side getters and mutators exist
- [x] Clients cannot directly write profile data through any new remote
- [x] Failure does not silently erase data; failed loads use unsaved session profiles
- [x] Studio-safe development mode works when DataStores are unavailable
- [x] PlayerRemoving save attempt exists
- [x] BindToClose save attempt exists
- [x] Version-aware load path exists
- [x] Clear warning logging exists
- [x] Rejoining persistence is documented for Studio DataStore access
- [x] Progress tracker updated

## Files Changed
- `roblox/src/server/Services/PlayerDataService.luau`
- `roblox/src/server/PlayerDataBootstrap.server.luau`
- `roblox/tests/PlayerDataService.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.PlayerDataService`
- Studio: `ServerScriptService.ZeroToHeroServer.PlayerDataBootstrap`
- Studio: `ServerScriptService.AscensionPlayerProfileServer`
- Studio: `ServerScriptService.AscensionTrainingFeedbackServer`

## Tests Run
- Studio Edit require test for `PlayerDataService`: passed.
- Studio Play mode started successfully after adding the service.
- Server-side Play mode assertions passed:
  - session profile loaded
  - default profile Version, HeroLevel, HeroXP, Gold, and Power training fields validated
  - `Profile` folder replicated to player
  - `Stats` folder replicated to player
  - `GetProfile` returned a copy, not a mutable cached table
  - `AddTrainingStatValue(player, "Power", 1, ...)` updated cached profile and replicated stat
  - invalid `"Strength"` stat mutation failed safely
  - local unpublished Studio save returned session-only status instead of overwriting DataStore data
- Console output showed the expected local Studio DataStore warning for unpublished place access.
- Studio Play mode stopped after the check.

## Blockers
- None.

## Next Task After 1.3
Run the required project-health review after milestones 1.1, 1.2, and 1.3. If it passes, continue to milestone 2.1 - Training Service.

## Project Health Review Gate - 2026-06-27

**Result:** PASS - continue to milestone 2.1

**Completed**
- [x] Reviewed `progression_tracker.md`, `decision_log.md`, `known_issues.md`, and `manual_test_checklist.md`.
- [x] Inspected canonical Roblox source modules and Rojo mapping.
- [x] Confirmed milestones 1.1, 1.2, and 1.3 are documented as complete.
- [x] Confirmed the main risk remains legacy Studio prototype scripts outside canonical source.

**Review Output**
- Full review recorded in `docs/roblox/project_health_review_2026-06-27.md`.
- The project may continue to milestone 2.1 - Training Service.

**Files Changed**
- `docs/roblox/project_health_review_2026-06-27.md`
- `docs/roblox/progression_tracker.md`

## Planning Task: Asset Ingestion Plan - 2026-06-27

**Result:** COMPLETE

**Completed**
- [x] Required Roblox project docs and asset research report read before asset planning.
- [x] First 15 vertical-slice assets prioritised for Ascension Grounds MVP intake.
- [x] Downloadable Quaternius/Kenney assets separated from Roblox Creator Store assets.
- [x] Creator Store assets marked for Studio/manual insert only, with quarantine and script-inspection requirements.
- [x] Local asset work scoped under `roblox/assets/`.
- [x] No gameplay, Studio, or asset download changes made.

**Files Changed**
- `roblox/assets/manifests/asset_manifest.csv`
- `roblox/assets/manifests/download_queue.md`
- `roblox/assets/manifests/creator_store_insert_plan.md`
- `roblox/assets/raw/.gitkeep`
- `roblox/assets/processed/.gitkeep`
- `docs/roblox/asset_pipeline.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`

**Verification**
- `asset_manifest.csv` parsed successfully with 15 asset rows.
- No Roblox Studio MCP changes were made.
- No assets were downloaded or imported.

## Asset Download Task - 2026-06-27

**Result:** COMPLETE

**Completed**
- [x] Official Kenney pages verified as free/CC0 and direct archive URLs identified.
- [x] Downloaded `Fantasy UI Borders`, `Mobile Controls`, and `Interface Sounds` ZIPs into `roblox/assets/raw/kenney/`.
- [x] Source/licence notes saved beside each downloaded ZIP.
- [x] Official Quaternius pages verified as CC0/free but skipped because they did not expose direct shell-safe archive URLs.
- [x] Quaternius manual downloads recorded in `roblox/assets/manifests/manual_downloads.md`.
- [x] `asset_manifest.csv` updated with downloaded/skipped statuses, file sizes, and SHA256 hashes for downloaded archives.
- [x] Roblox Creator Store assets were not downloaded with shell.
- [x] No Roblox Studio import or gameplay changes were made.

**Files Changed**
- `roblox/assets/manifests/asset_manifest.csv`
- `roblox/assets/manifests/download_queue.md`
- `roblox/assets/manifests/manual_downloads.md`
- `roblox/assets/raw/kenney/fantasy_ui_borders/kenney_fantasy-ui-borders.zip`
- `roblox/assets/raw/kenney/fantasy_ui_borders/SOURCE_NOTES.md`
- `roblox/assets/raw/kenney/mobile_controls/mobile-controls-1.zip`
- `roblox/assets/raw/kenney/mobile_controls/SOURCE_NOTES.md`
- `roblox/assets/raw/kenney/interface_sounds/kenney_interface-sounds.zip`
- `roblox/assets/raw/kenney/interface_sounds/SOURCE_NOTES.md`
- `docs/roblox/progression_tracker.md`

**Verification**
- `asset_manifest.csv` parsed successfully.
- Manifest statuses: 3 downloaded, 7 manual-download skips, 5 Creator Store manual inserts unchanged.
- Downloaded archive SHA256 hashes recorded in source notes and manifest.
- No assets were extracted, processed, imported into Studio, or used by gameplay.

## Milestone 2.1 - Training Service

**Result:** COMPLETE

**Completed**
- [x] Required Roblox project docs, project summary, known issues, manual checklist, and economy boundary read before server progression work.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio tree inspected before changes.
- [x] Project-health review after milestones 1.1, 1.2, and 1.3 completed and recorded.
- [x] Source-controlled `TrainingService` created under `roblox/src/server/Services/`.
- [x] Studio `TrainingService` ModuleScript created under `ServerScriptService.ZeroToHeroServer.Services`.
- [x] Training XP award path validates player, stat id, XP amount, and single-award duration.
- [x] XP application supports carry-over XP and multiple level-ups.
- [x] Diminishing-return calculation implemented with the MVP schedule: 100%, 70%, 40%, then 15%.
- [x] Daily training totals added to the profile model and recorded per UTC date key.
- [x] Structured reward result includes old level, new level, XP gained, level-up count, daily seconds, multiplier, and Training Rank placeholder.
- [x] Training Rank placeholder aligned between `TrainingService` and replicated `PlayerDataService` leaderstats.
- [x] Existing Studio training feedback bridge now routes server-side training awards through `TrainingService`.
- [x] No new client remote can directly award XP.
- [x] No station framework or Strength Forge minigame work was added.

**Acceptance Criteria**
- [x] XP can only be awarded by server code.
- [x] Multiple level-ups work in the service implementation and documented manual cases.
- [x] Invalid rewards fail safely.
- [x] Diminishing-return multiplier is deterministic.
- [x] Reward result includes old level, new level, XP gained, and level-up count.
- [x] Documented TrainingService manual cases exist.

**Files Changed**
- `roblox/src/server/Services/TrainingService.luau`
- `roblox/src/server/Services/PlayerDataService.luau`
- `roblox/src/shared/Types/PlayerProfileModel.luau`
- `roblox/tests/TrainingService.examples.md`
- `roblox/tests/PlayerProfileModel.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/project_health_review_2026-06-27.md`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.TrainingService`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.PlayerDataService`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Types.PlayerProfileModel`
- Studio: `ServerScriptService.AscensionTrainingFeedbackServer`

**Tests Run**
- Studio Play mode boot after adding `TrainingService`: passed.
- Studio console check after Play boot: only expected unpublished-place DataStore warning appeared.
- Player tree inspection in Play mode confirmed `Profile`, `Stats`, and `leaderstats` folders were created.
- Studio Play mode boot after aligning Training Rank placeholder: passed.
- ZIP/asset work was not touched.
- Full TrainingService assertion cases are documented in `roblox/tests/TrainingService.examples.md` but were not executed through an automated Luau test runner.

**Blockers**
- None for milestone 2.1.

**Next Task**
Milestone 2.2 - Training Station Framework.

## Milestone 2.2 - Training Station Framework

**Result:** COMPLETE

**Completed**
- [x] Required Roblox docs, visual direction, reference folder listing, project summary, known issues, and economy boundary read before station work.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio tree inspected before changes.
- [x] Existing Strength Forge prompt reused instead of creating a duplicate station object.
- [x] Shared `TrainingStationConfig` created with one placeholder Strength Forge station.
- [x] Server `TrainingStationService` created with station lookup, prompt binding, distance validation, cooldown validation, optional server minigame-result multiplier support, reward callback registration, and curated client reward event.
- [x] `TrainingStationBootstrap` created to start the station framework and disable old one-off forge award scripts at runtime.
- [x] Canonical client reward RemoteEvent created at runtime under `ReplicatedStorage.ZeroToHeroShared.Remotes.TrainingStationReward`.
- [x] Existing temporary training feedback UI can still receive approved reward payloads through the legacy `StatChanged` bridge.
- [x] No final Strength Forge minigame was built.
- [x] No Roblox assets were imported or processed.

**Acceptance Criteria**
- [x] One station can be configured without custom one-off scripts.
- [x] Server validates player distance and cooldown.
- [x] Rapid spam does not award repeated XP in the service implementation and documented manual cases.
- [x] Client receives only approved result data.
- [x] Station logic can support all five future stations through config entries.

**Files Changed**
- `roblox/src/shared/Config/TrainingStationConfig.luau`
- `roblox/src/server/Services/TrainingStationService.luau`
- `roblox/src/server/TrainingStationBootstrap.server.luau`
- `roblox/tests/TrainingStationService.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.TrainingStationConfig`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.TrainingStationService`
- Studio: `ServerScriptService.ZeroToHeroServer.TrainingStationBootstrap`

**Tests Run**
- Studio Play mode started successfully after adding the station framework.
- Console output showed only the expected unpublished-place DataStore warning.
- Runtime tree confirmed `ReplicatedStorage.ZeroToHeroShared.Remotes.TrainingStationReward` exists.
- Runtime tree confirmed `Workspace.AscensionGrounds.StrengthForge.ForgeCore.TrainStrengthPrompt` remains the configured ProximityPrompt.
- Edit-mode tree confirmed `TrainingStationConfig`, `TrainingStationService`, and `TrainingStationBootstrap` were created.
- Full activation, cooldown, out-of-range, and invalid-station assertion cases are documented in `roblox/tests/TrainingStationService.examples.md` but were not executed through an automated Luau test runner.

**Blockers**
- None for milestone 2.2.

**Next Task**
Milestone 2.3 - Strength Forge Minigame.

## Milestone 2.3 - Strength Forge Minigame

**Result:** COMPLETE

**Completed**
- [x] Required Roblox docs, visual direction, reference folder listing, project summary, known issues, manual checklist, and economy boundary read before reward-bearing station work.
- [x] Connected Studio instance `Place1.rbxl` listed and confirmed active.
- [x] Studio tree, existing server scripts, existing client feedback script, and source-controlled Roblox modules inspected before changes.
- [x] `TrainingStationConfig` updated from placeholder Strength Forge station to final `StrengthForge` station config for this milestone.
- [x] Strength Forge minigame config added with three required successful reps, six maximum attempts, server-timed marker settings, target zones, timeout, and capped accuracy multiplier.
- [x] `TrainingStationService` updated to create `TrainingStationChallenge`, `TrainingStationAction`, and `TrainingStationReward` RemoteEvents.
- [x] Prompt activation now starts a server-issued Strength Forge challenge instead of directly awarding XP.
- [x] Client action remote accepts only challenge submit/cancel requests; the client cannot submit XP, stat values, or final multipliers.
- [x] Server validates player range, challenge ID, challenge timeout, attempts, marker position, target zone, completion count, reward multiplier, and completion cooldown.
- [x] Three server-validated successful reps complete one set and award Power XP through `TrainingService`.
- [x] Existing training reward popup path remains connected through the legacy `StatChanged` bridge.
- [x] `StrengthForgeMinigame` LocalScript added under source and Studio `StarterPlayerScripts.ZeroToHeroClient.Controllers`.
- [x] Client minigame panel includes timing bar, target zone, marker, rep count, strike button, keyboard input, mouse/touch button activation, and leave-range cancellation.
- [x] Manual/server examples documented in `roblox/tests/StrengthForgeMinigame.examples.md`.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] Player entering the Strength Forge prompt starts the minigame challenge.
- [x] Timing marker moves across a target zone on the client.
- [x] Player can activate through the Strike button and keyboard input.
- [x] Three successful server-validated reps complete one set.
- [x] Accuracy determines capped reward quality.
- [x] Server validates timing windows using server-issued challenge data.
- [x] Client cannot directly choose the final reward or submit XP.
- [x] Reward is Power XP only.
- [x] Base reward and accuracy multipliers are configurable.
- [x] Completion cooldown blocks immediate repeat awards.
- [x] Reward popup path fires after the approved reward.
- [x] Station can be cancelled/reset cleanly when leaving range.

**Files Changed**
- `roblox/src/shared/Config/TrainingStationConfig.luau`
- `roblox/src/server/Services/TrainingStationService.luau`
- `roblox/src/client/Controllers/StrengthForgeMinigame.client.luau`
- `roblox/tests/TrainingStationService.examples.md`
- `roblox/tests/StrengthForgeMinigame.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `ReplicatedStorage.ZeroToHeroShared.Config.TrainingStationConfig`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.TrainingStationService`
- Studio: `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Controllers.StrengthForgeMinigame`

**Tests Run**
- Studio Edit-mode require check passed for `TrainingStationConfig` and `TrainingStationService`.
- Studio Edit-mode check confirmed `StrengthForge` exists, minigame is enabled, required successes are three, and challenge/action RemoteEvents can be created.
- Studio Play mode server assertion passed:
  - direct `TryActivateStation(player, "StrengthForge")` failed with `MinigameRequired`
  - `StartStationMinigame` created a server challenge
  - three server-timed submissions completed the challenge
  - Power advanced from Level 0 to Level 1
  - Power XP advanced from 0 to 48 carried-over XP
  - final XP reward was 148
  - immediate restart was blocked by `Cooldown`
  - `TrainingStationChallenge`, `TrainingStationAction`, and `TrainingStationReward` existed at runtime
- Studio Play mode client UI check passed:
  - server-issued challenge reached the client
  - `PlayerGui.StrengthForgeMinigameGui.Panel` became visible
  - `TimingBar` and `StrikeButton` existed
  - active challenge was cancelled cleanly after the UI check
- Console output showed only the expected unpublished-place DataStore warning.
- Studio Play mode stopped after both checks.

**Blockers**
- None for milestone 2.3.

**Next Task**
Milestone 2.4 - Stats HUD.

## Milestone 2.4 - Stats HUD

**Result:** COMPLETE

**Completed**
- [x] Required Roblox docs, visual direction, stats UI reference, project summary, known issues, and manual checklist read before HUD work.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio tree, existing legacy HUD/reward script, source client scripts, and profile replication path inspected before changes.
- [x] `PlayerDataService` now replicates approved training-stat display state under `player.TrainingStats`.
- [x] Each replicated stat snapshot includes `Level`, `XP`, `XPRequired`, and `EffectiveValue`.
- [x] `Profile.TrainingRank` is replicated for HUD display.
- [x] Existing `Stats` folder and `leaderstats` compatibility values remain in place.
- [x] `TrainingStatsHud` LocalScript added under source and Studio `StarterPlayerScripts.ZeroToHeroClient.UI`.
- [x] HUD displays Power, Vitality, Agility, Endurance, and Control with level labels, XP text, XP bars, stat colors, and Training Rank.
- [x] HUD listens to replicated IntValue changes and animates XP bar changes plus level-up/highlight pulses.
- [x] Legacy `AscensionTrainingFeedbackGui.StatsPanel` is hidden by the new HUD script so the screen does not show duplicate stat panels.
- [x] Legacy reward toast behavior remains available until milestone 2.5 replaces it with a reusable reward-popup system.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] Five stats display correctly.
- [x] Current level displays for each stat.
- [x] Current XP displays for each stat.
- [x] XP required displays for each stat.
- [x] Training Rank displays.
- [x] XP changes animate after Strength Forge completion.
- [x] Level-up/highlight state is implemented.
- [x] UI uses responsive constraints for phone and desktop viewports.
- [x] UI reads from approved replicated profile state instead of server-only tables.
- [x] UI does not expose client mutation of XP or levels.

**Files Changed**
- `roblox/src/server/Services/PlayerDataService.luau`
- `roblox/src/client/UI/TrainingStatsHud.client.luau`
- `roblox/tests/TrainingStatsHud.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `ServerScriptService.ZeroToHeroServer.Services.PlayerDataService`
- Studio: `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI.TrainingStatsHud`

**Tests Run**
- Studio Edit-mode require check passed for updated `PlayerDataService`.
- Studio Play mode server assertion passed:
  - `TrainingStats` folder replicated to player
  - all five stat folders existed
  - each stat had `Level`, `XP`, `XPRequired`, and `EffectiveValue`
  - every stat started at Level 0, XP 0, EffectiveValue 0, and XPRequired 100
  - `Profile.TrainingRank` existed
  - completing one server-timed Strength Forge set updated Power to Level 1, XP 48, XPRequired 255, EffectiveValue 1
- Studio Play mode client assertion passed:
  - `TrainingStatsHudGui.Panel` existed and was visible
  - rows existed for Power, Vitality, Agility, Endurance, and Control
  - Power row displayed `Lv 1`
  - Power row displayed `48 / 255 XP`
  - Rank displayed `Rank 0`
  - legacy `AscensionTrainingFeedbackGui.StatsPanel` was hidden
- Console output showed only the expected unpublished-place DataStore warning.
- Studio Play mode stopped after checks.

**Blockers**
- None for milestone 2.4.

**Next Task**
Milestone 2.5 - Reward Popup.

## Milestone 2.5 - Reward Popup

**Result:** COMPLETE

**Completed**
- [x] Required Roblox docs, visual direction, reward popup reference, project summary, known issues, manual checklist, and economy boundary read before reward UI work.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio tree, canonical reward RemoteEvent path, existing legacy reward toast, and source client UI scripts inspected before changes.
- [x] `RewardPopup` LocalScript added under source and Studio `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI`.
- [x] Popup listens only to server-approved `ReplicatedStorage.ZeroToHeroShared.Remotes.TrainingStationReward` payloads.
- [x] Strength Forge training rewards normalize into a `Training Complete` popup with a stat-colored `Power XP` row.
- [x] Level-up rewards show a distinct `LEVEL UP` badge and `Lv old -> new` subtitle.
- [x] Popup supports grouped reward rows for Training XP, Hero XP, Gold, Items, and LevelUp payloads.
- [x] Rare item rewards use rarity-colored row/stroke presentation.
- [x] Reward queue added with capped queue length, token-based display scheduling, auto-dismiss, and queue-depth state attributes for verification.
- [x] Presentation-only `DisplaySeconds` override added for server/test payloads; normal rewards keep brief default timing.
- [x] Legacy `AscensionTrainingFeedbackClient` reward toast disabled in Studio so it does not overlap the new popup.
- [x] New manual examples documented in `roblox/tests/RewardPopup.examples.md`.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] Strength Forge reward displays through the reusable popup path.
- [x] Multiple rewards queue instead of overlapping.
- [x] Level-up version is visually distinct.
- [x] Queue clears to depth 0 after processing.
- [x] Small default rewards auto-dismiss quickly and do not create client-side progression authority.
- [x] UI supports future Hero XP, Gold, item, and rarity payloads without implementing those reward systems yet.

**Files Changed**
- `roblox/src/client/UI/RewardPopup.client.luau`
- `roblox/tests/RewardPopup.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI.RewardPopup`
- Studio: `StarterPlayer.StarterPlayerScripts.AscensionTrainingFeedbackClient`

**Tests Run**
- Studio tree inspection confirmed `RewardPopup` exists under `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI`.
- Clean Studio Play boot after adding the script showed only the expected unpublished-place DataStore warning.
- Client boot assertion passed:
  - `RewardPopupGui` exists
  - `Popup`, `Header`, and `RewardRows` exist
  - legacy `AscensionTrainingFeedbackGui.RewardToast` starts hidden
- Server reward remote assertion passed:
  - `ReplicatedStorage.ZeroToHeroShared.Remotes.TrainingStationReward` exists at runtime
- Actual Strength Forge server path passed:
  - player moved into Strength Forge range
  - server-issued challenge started
  - three server-timed submissions completed the set
  - approved result fired `Power +148 XP`
  - result levelled Power from `Lv 0` to `Lv 1`
  - client popup state recorded `Power XP`, `+148`, `Lv 0 -> 1`, and default display duration `1.71`
- Held test payload passed:
  - popup stayed visible with `Training Complete`
  - first row showed `Power XP +148`
  - `LEVEL UP` badge was visible
  - legacy reward toast stayed hidden
- Queue test passed:
  - first held reward showed `Gold +25`
  - second reward was queued with queue depth `1`
  - queued rare item advanced to `Loot Found` / `Training Blade +1`
  - queue cleared to depth `0` after processing
- Final clean Play boot showed only the expected unpublished-place DataStore warning.
- Studio Play mode stopped after checks.

**Blockers**
- None for milestone 2.5.

**Next Task**
Run the required project-health review for the completed training progression work before starting milestone 3.1 - Top-Down Layout.

## Project Health Review Gate - 2026-06-28

**Result:** PASS - continue to milestone 3.1

**Completed**
- [x] Required Roblox project docs, visual direction, economy boundary, project summary, known issues, decision log, manual checklist, and tracker read before the review.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio Edit-mode tree inspected for canonical shared, server, client, workspace, and legacy script state.
- [x] Source-controlled Roblox modules and documented tests inspected.
- [x] Confirmed Phase 2 canonical training progression modules exist in both source and Studio.
- [x] Confirmed training XP, Strength Forge timing, profile mutation, and reward payloads remain server-authoritative.
- [x] Confirmed legacy `Strength`/`Coins` scripts remain a known risk and should not be extended.
- [x] Confirmed `Workspace.AscensionGrounds.ReferenceSpacingBlockout` exists in Studio ahead of formal Phase 3 acceptance and must be reviewed during 3.1.

**Review Output**
- Full review recorded in `docs/roblox/project_health_review_2026-06-28.md`.
- The project may continue to milestone 3.1 - Top-Down Layout.

**Verification**
- Studio Play mode started and stopped for a smoke check.
- Console output showed only the expected unpublished-place DataStore warning.
- No Studio objects or scripts were changed during this review.

**Files Changed**
- `docs/roblox/project_health_review_2026-06-28.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`

**Next Task**
Milestone 3.1 - Top-Down Layout. Inspect the existing `Workspace.AscensionGrounds.ReferenceSpacingBlockout` first, then formalise or minimally adjust it against the milestone acceptance criteria.

## Milestone 3.1 - Top-Down Layout

**Result:** COMPLETE

**Completed**
- [x] Required Roblox project docs, visual direction, Ascension Grounds reference image, project summary, known issues, decision log, manual checklist, and tracker read before layout work.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio Edit-mode tree inspected before accepting the layout.
- [x] Existing `Workspace.AscensionGrounds.ReferenceSpacingBlockout` inspected and formalised as the 3.1 greybox layout.
- [x] Central plaza model confirmed.
- [x] Central blue Ascension crystal placeholder confirmed.
- [x] Five district road parts confirmed on one main floor.
- [x] Existing live `Workspace.AscensionGrounds.StrengthForge` preserved as the Power district landmark and functional station.
- [x] Guardian Hall, Agility Tower, Endurance Track, and Control Shrine placeholder models confirmed.
- [x] District and Broken Gate signs confirmed.
- [x] One main Broken Gate route confirmed.
- [x] No four-gate layout was added.
- [x] No multi-floor maze was added.
- [x] Road widths inspected for group readability.
- [x] Layout remains primitive-based, modular, and replaceable.
- [x] Manual layout examples documented.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] Player can understand the full hub from the central plaza.
- [x] All five districts are visible or clearly signposted.
- [x] Broken Gate route is obvious.
- [x] Paths support groups of players without bottlenecks in the greybox inspection.
- [x] No final art assets required or added.
- [x] Layout is modular and replaceable.

**Files Changed**
- `roblox/tests/AscensionGroundsLayout.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio formalised without creating new objects: `Workspace.AscensionGrounds.ReferenceSpacingBlockout`

**Tests Run**
- Studio Edit-mode inspection confirmed:
  - `CentralPlaza` and `CentralCrystal` exist
  - `CentralCrystal` is blue/neon and sized `6, 17, 6`
  - `RoadGrid` contains `MainRoadSouthToNorth`, `ForgeRoad`, `GuardianRoad`, `AgilityRoad`, `EnduranceRoad`, and `ControlRoad`
  - road widths are 10-13 studs for hub/district roads
  - `BrokenGateBlockout.GateRoad` is 20 studs wide
  - `GroundPlate` is collidable and sized `230, 2, 205`
  - district signs are present for Strength Forge, Guardian Hall, Agility Tower, Endurance Track, and Control Shrine
  - one `BrokenGateBlockout` route is present
- Studio Play mode smoke check passed:
  - `ReferenceSpacingBlockout` existed at runtime
  - player loaded with `Profile`, `Stats`, `TrainingStats`, and `leaderstats`
  - console output showed only the expected unpublished-place DataStore warning
- Studio Play mode stopped after checks.

**Blockers**
- None for milestone 3.1.

**Next Task**
Milestone 3.2 - District Shells.

## Milestone 3.2 - District Shells

**Result:** COMPLETE

**Completed**
- [x] Required Roblox project docs, visual direction, Ascension Grounds reference folder, project summary, known issues, decision log, manual checklist, and tracker read before shell work.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio Edit-mode tree inspected before adding shell details.
- [x] Existing `Workspace.AscensionGrounds.ReferenceSpacingBlockout` kept as the accepted 3.1 layout foundation.
- [x] Existing live `Workspace.AscensionGrounds.StrengthForge` preserved as the functional Power station.
- [x] Added primitive `Milestone32ShellDetails` group under Strength Forge with stone, metal, orange forge, and hammer silhouette details.
- [x] Added primitive `Milestone32ShellDetails` group under Guardian Hall with blue fortified battlements, gate bars, and shield emblem.
- [x] Added primitive `Milestone32ShellDetails` group under Agility Tower with purple obstacle platforms, balance beam, hoop marker, and landing mat.
- [x] Added primitive `Milestone32ShellDetails` group under Endurance Track with green start arch and checkpoint markers around the open route.
- [x] Added primitive `Milestone32ShellDetails` group under Control Shrine with teal precision ring, rune lines, and focus pillars.
- [x] Confirmed all new shell detail parts are anchored and non-collidable.
- [x] Confirmed no remaining minigames were implemented.
- [x] Manual district shell examples documented.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] Each district is recognisable by silhouette and colour.
- [x] Strength Forge station remains functional.
- [x] Districts do not obstruct navigation.
- [x] Mobile performance remains acceptable for the greybox scope.
- [x] Every shell is grouped and named.

**Files Changed**
- `roblox/tests/DistrictShells.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `Workspace.AscensionGrounds.StrengthForge.Milestone32ShellDetails`
- Studio: `Workspace.AscensionGrounds.ReferenceSpacingBlockout.StationDistricts.GuardianHallBlockout.Milestone32ShellDetails`
- Studio: `Workspace.AscensionGrounds.ReferenceSpacingBlockout.StationDistricts.AgilityTowerBlockout.Milestone32ShellDetails`
- Studio: `Workspace.AscensionGrounds.ReferenceSpacingBlockout.StationDistricts.EnduranceTrackBlockout.Milestone32ShellDetails`
- Studio: `Workspace.AscensionGrounds.ReferenceSpacingBlockout.StationDistricts.ControlShrineBlockout.Milestone32ShellDetails`

**Tests Run**
- Studio Edit-mode inspection confirmed:
  - five `Milestone32ShellDetails` models exist under the expected district parents
  - Strength Forge, Guardian Hall, Agility Tower, and Endurance Track each received 6 primitive shell detail parts
  - Control Shrine received 7 primitive shell detail parts
  - all 31 new shell detail parts are anchored
  - all 31 new shell detail parts have `CanCollide = false`
  - `Workspace.AscensionGrounds.StrengthForge.ForgeCore.TrainStrengthPrompt` remained enabled
- Studio viewport capture from above confirmed distinct district reads:
  - orange forge
  - blue defensive hall
  - purple obstacle tower
  - green track
  - teal shrine
- Studio Play mode smoke check passed:
  - shell detail groups existed at runtime
  - player loaded with `Profile`, `Stats`, `TrainingStats`, and `leaderstats`
  - all shell detail parts remained anchored and non-collidable
  - Strength Forge challenge started through `TrainingStationService.StartStationMinigame`
  - Strength Forge challenge returned 3 required successes and 6 maximum attempts
  - Strength Forge challenge cancelled cleanly
  - console output showed only the expected unpublished-place DataStore warning
- Studio Play mode stopped after checks.

**Blockers**
- None for milestone 3.2.

**Next Task**
Milestone 3.3 - Broken Gate Transition.

## Milestone 3.3 - Broken Gate Transition

**Result:** COMPLETE

**Completed**
- [x] Required Roblox project docs, visual direction, enemy-area reference image, project summary, known issues, decision log, manual checklist, and tracker read before transition work.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio Edit-mode tree inspected before adding transition details.
- [x] Existing `Workspace.AscensionGrounds.ReferenceSpacingBlockout.BrokenGateBlockout` used as the accepted 3.1 Broken Gate foundation.
- [x] Existing `Workspace.AscensionGrounds.EnemyArea` inspected and left as pre-existing legacy placeholder state.
- [x] Added primitive `Milestone33TransitionDetails` group under Broken Gate with dark route surfaces, red danger threshold, blue safe-side markers, ruined stone edges, red torches, banner placeholders, and a future boss route marker.
- [x] Added three wide route floor pieces from the gate into the danger-side area.
- [x] Kept decorative transition details non-collidable.
- [x] Did not add enemies, combat rewards, loot, or combat systems.
- [x] Manual Broken Gate transition examples documented.
- [x] Existing mobile React app left untouched.

**Acceptance Criteria**
- [x] Safe and dangerous areas are visually distinct.
- [x] Transition is readable without UI text.
- [x] Route is wide enough for combat.
- [x] Spawn and social areas remain protected.

**Files Changed**
- `roblox/tests/BrokenGateTransition.examples.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/known_issues.md`
- Studio: `Workspace.AscensionGrounds.ReferenceSpacingBlockout.BrokenGateBlockout.Milestone33TransitionDetails`

**Tests Run**
- Studio Edit-mode inspection confirmed:
  - `Milestone33TransitionDetails` exists under the Broken Gate blockout
  - 28 primitive parts were added
  - 5 PointLights were added
  - `DangerRouteFloorNear`, `DangerRouteFloorFar`, and `FutureBossRoutePlate` are collidable route surfaces
  - route surfaces are 26, 30, and 32 studs wide
  - decorative transition parts are anchored and non-collidable
  - the existing `EnemyArea` still contains only `EnemyAreaFloor`, `EnemyAreaBoundary`, and the pre-existing `TrainingDummy`
- Studio viewport capture confirmed:
  - blue safe-side markers remain on the hub side
  - red danger threshold, dark route, ruins, red lights, and far route marker are visible beyond Broken Gate
- Studio Play mode smoke check passed:
  - transition group existed at runtime
  - player loaded with `Profile`, `Stats`, `TrainingStats`, and `leaderstats`
  - raycasts hit `DangerRouteFloorNear`, `DangerRouteFloorFar`, and `FutureBossRoutePlate`
  - player could be moved onto `DangerRouteFloorFar`
  - console output showed only the expected unpublished-place DataStore warning
- Studio Play mode stopped after checks.

**Blockers**
- None for milestone 3.3.

**Next Task**
Run the required project-health review for the completed Phase 3 greybox work before starting milestone 4.1 - Derived Combat Stats.

## Project Health Review Gate - 2026-06-28 - Phase 3

**Result:** PASS - continue to milestone 4.1

**Completed**
- [x] Required Roblox project docs, visual direction, project summary, known issues, decision log, manual checklist, and tracker read before the review.
- [x] Connected Studio instance `Place1.rbxl` listed and set active.
- [x] Studio Edit-mode tree inspected for Phase 3 layout objects, canonical shared/server/client scripts, and legacy prototype scripts.
- [x] Source-controlled Roblox modules and documented tests inspected.
- [x] Confirmed milestones 3.1, 3.2, and 3.3 are documented as complete.
- [x] Confirmed Phase 3 Studio objects exist in the live place.
- [x] Confirmed canonical training progression remains server-authoritative.
- [x] Confirmed the next milestone, 4.1 - Derived Combat Stats, can proceed as pure shared formula work.
- [x] Confirmed active legacy combat scripts remain a risk for milestone 4.2 and later combat implementation.

**Review Output**
- Full review recorded in `docs/roblox/project_health_review_2026-06-28_phase3.md`.
- The project may continue to milestone 4.1 - Derived Combat Stats.

**Verification**
- Studio Edit-mode assertion confirmed:
  - `ReferenceSpacingBlockout`, district shell details, and Broken Gate transition details exist
  - canonical `ZeroToHeroShared`, `ZeroToHeroServer`, and `ZeroToHeroClient` modules/scripts exist
  - `AscensionPlayerProfileServer` remains disabled
  - `AscensionSwordCombatServer` remains enabled and is a known legacy risk
- Studio Play mode smoke check confirmed:
  - `TrainingStationReward`, `TrainingStationChallenge`, and `TrainingStationAction` exist at runtime
  - player `Profile`, `Stats`, `TrainingStats`, and `leaderstats` folders spawned
  - Phase 3 visual groups existed at runtime
  - `PlayerStats.server`, `StrengthForge.server`, `AscensionPlayerProfileServer`, and `AscensionStrengthForgeTrainingServer` were disabled at runtime
  - `EnemyArea.server` and `AscensionSwordCombatServer` remained enabled at runtime
  - console output showed only the expected unpublished-place DataStore warning
- Studio Play mode stopped after checks.
- No Studio objects or scripts were changed during this review.

**Files Changed**
- `docs/roblox/project_health_review_2026-06-28_phase3.md`
- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`

**Next Task**
Milestone 4.1 - Derived Combat Stats.
