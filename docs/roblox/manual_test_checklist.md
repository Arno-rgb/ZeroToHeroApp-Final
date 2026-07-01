# Roblox Manual Test Checklist

## Phase 0 - Project Foundation

- [x] Existing mobile app files were not moved.
- [x] `docs/roblox/` exists.
- [x] `roblox/default.project.json` exists.
- [x] Client, server, shared, tests, and reference-asset folders exist.
- [x] Visual reference images exist under `roblox/assets/reference/roblox/`.
- [x] Progress tracker, decision log, and known issues files exist.

## Studio MCP Smoke Test

Use this when the next Codex session works in Studio:

- [x] Roblox Studio is open with the intended place.
- [x] Codex can list connected Studio instances.
- [x] Codex sets the intended Studio instance active.
- [x] Codex inspects the current Studio tree before changes.
- [x] Codex starts Play mode after changes.
- [x] Codex checks console output.
- [x] Codex stops Play mode.
- [ ] The user saves the Roblox place in Studio after successful changes.

## Owner-Controlled Future Roadmap

Use this before any future Roblox gameplay mechanic is added:

- [x] `docs/roblox/future_milestone_review_2026-06-30.md` exists.
- [x] `docs/roblox/future_milestone_review_2026-06-30.md` is the active owner-controlled future roadmap.
- [x] `docs/roblox/progression_tracker.md` current status progressed through `R0 - Roadmap and Scope Recovery`, `R1 - Disable and Isolate Break`, and `R2 - Legacy Feedback and Duplicate Path Cleanup`.
- [x] `docs/roblox/codex_progression_prompt_system.md` defers future work to the owner roadmap before old prompts.
- [x] Owner has explicitly started `R0 - Roadmap and Scope Recovery`.
- [x] R0 was completed as a documentation-only read-only recovery pass.
- [x] `docs/roblox/roadmap_scope_recovery_2026-06-30.md` records the post-Phase-0.3 inventory and recommendations.
- [ ] If Phase 6.2 Break is kept, owner has explicitly approved keeping it.
- [x] If Phase 6.2 Break is not kept, disable and isolate it in the R1 dedicated cleanup task; remove only if the owner explicitly asks for removal.
- [x] Owner has explicitly approved starting `R1 - Disable and Isolate Break` before any Break code/config/UI change is made.
- [x] Owner has explicitly approved starting `R2 - Legacy Feedback and Duplicate Path Cleanup` before disabling legacy feedback/combat paths.
- [x] Owner has explicitly approved starting `R3 - Existing Combat Presentation Polish` before changing combat presentation.
- [ ] Do not add Brakk, Break extensions, new minigames, skills, guard/dodge, mobile claims, economy features, or other mechanics until explicitly approved.

## R0 Roadmap and Scope Recovery

Documentation-only review completed on 2026-06-30:

- [x] Required R0 docs were read.
- [x] Roblox Studio instance `Zero` was listed and set active.
- [x] Studio tree was inspected in read-only mode.
- [x] `Workspace.AscensionGrounds.EnemyArea` was inspected for persistent edit-time enemy objects.
- [x] `ReplicatedStorage.ZeroToHeroShared.Config` was inspected for enemy, combat, and loot config paths.
- [x] `ServerScriptService.ZeroToHeroServer.Services` was inspected for combat, enemy, and loot service paths.
- [x] `StarterPlayer.StarterPlayerScripts` and `StarterGui` were inspected for UI/client paths.
- [x] Gate Hound, Stone Shell, and Gate Sentinel were classified as keep for hands-on review.
- [x] Break was classified as unapproved / needs owner review.
- [x] No Play mode was started or stopped for R0.
- [x] No gameplay code was changed.
- [x] No Studio gameplay objects were changed.
- [x] R1 has been explicitly approved by the owner.
- [x] Break has been disabled behind a feature flag.
- [x] Stone Shell has been verified as a normal enemy with Break disabled.

## R1 - Disable and Isolate Break

R1 implementation completed on 2026-06-30:

- [x] Required Roblox, active roadmap, architecture, tracker, decision log, known issues, manual checklist, project summary, visual direction, and reference folder docs were reviewed.
- [x] Roblox Studio instance `Zero` was listed and set active.
- [x] Studio tree was inspected before changes.
- [x] `ReplicatedStorage.ZeroToHeroShared.Config.FeatureFlags` exists.
- [x] `FeatureFlags.BreakSystemEnabled` defaults to `false`.
- [x] Stone Shell Break config remains preserved in `EnemyConfig`.
- [x] `CombatService` returns `BreakDamage = 0` and `RawBreakDamage = 0` while Break is disabled.
- [x] Stone Shell spawns with `BreakEnabled = false`.
- [x] Stone Shell does not create `Break`, `MaxBreak`, or `BreakState` runtime values while disabled.
- [x] Stone Shell does not expose a `BreakState` attribute while disabled.
- [x] Stone Shell billboard does not create `BreakLabel` or `BreakBar`.
- [x] Stone Shell billboard does not reserve Break UI height while disabled.
- [x] Stone Shell moved toward the player during Play-mode server validation.
- [x] Stone Shell performed an attack during Play-mode server validation.
- [x] Stone Shell took normal health damage with its `0.65` armor multiplier.
- [x] Stone Shell did not enter Broken or Vulnerable state.
- [x] Stone Shell died through the normal combat path.
- [x] Stone Shell granted guaranteed Gold and Hero progression through the existing loot path.
- [x] Duplicate attack after death did not grant extra Hero XP, Hero Level, or Gold.
- [x] Console output showed only expected unpublished-place DataStore warnings plus R1 validation output.
- [x] Studio Play mode was stopped after verification.
- [ ] Run a hands-on desktop fight against Stone Shell and confirm no Break meter appears.
- [ ] Run a hands-on touch/mobile fight against Stone Shell and confirm no hidden Break UI space remains.
- [ ] Confirm combat HUD and reward popup remain readable during the no-Break Stone Shell fight.
- [ ] Save the Roblox place in Studio after successful MCP changes.

Example Studio assertions and manual steps are documented in `roblox/tests/R1BreakIsolation.examples.md`.

Observed checks on 2026-06-30:

- [x] Edit-mode validation printed `R1_EDIT_VALIDATE ok BreakSystemEnabled=false preservedBreakConfig=true`.
- [x] Runtime validation printed `R1_RUNTIME_SERVER ok moved=5.83 firstDamage=8 break=0 goldGain=2 heroBefore=1/0 heroAfter=2/0`.

## R2 - Legacy Feedback and Duplicate Path Cleanup

R2 implementation completed on 2026-06-30:

- [x] Required Roblox docs, active roadmap, architecture, tracker, decision log, known issues, manual checklist, and project summary were reviewed.
- [x] Roblox Studio instance `Zero` was listed and set active.
- [x] Studio tree was inspected before changes.
- [x] `StarterPlayer.StarterPlayerScripts.AscensionTrainingFeedbackClient` is disabled and tagged with its canonical replacements.
- [x] `StarterPlayer.StarterPlayerScripts.AscensionSwordCombatClient` is disabled and tagged with its canonical replacement.
- [x] `ServerScriptService.AscensionTrainingFeedbackServer` is disabled and tagged with its canonical replacements.
- [x] `ServerScriptService.AscensionSwordCombatServer` is disabled and tagged with its canonical replacements.
- [x] `ServerScriptService.AscensionStrengthForgeTrainingServer` is disabled and tagged with its canonical replacement.
- [x] `ServerScriptService.EnemyArea.server` is disabled and tagged with its canonical replacement.
- [x] Previously disabled `PlayerStats.server`, `StrengthForge.server`, and `AscensionPlayerProfileServer` were reviewed and tagged.
- [x] `ReplicatedStorage.AscensionRemotes.StatChanged` remains retained and labeled as a compatibility bridge.
- [x] Play mode did not recreate `AscensionRemotes.SwordAttack`.
- [x] Play mode did not recreate `AscensionRemotes.SwordCombatFeedback`.
- [x] Play mode did not recreate `ServerScriptService.AscensionTrainingEvents`.
- [x] Canonical training, combat, reward, and inventory remotes existed exactly once.
- [x] Strength Forge completed through the canonical station/minigame path.
- [x] Power updated from `Lv 0` to `Lv 1`.
- [x] Reward popup displayed the combat reward through the canonical popup.
- [x] Combat HUD appeared through `CombatControllerGui`.
- [x] One Lesser Slime attack reduced health from `42` to `29`.
- [x] Defeating Lesser Slime granted Hero XP once.
- [x] Duplicate attack after death did not grant extra Hero XP, Hero Level, or Gold.
- [x] Inventory panel received one test item snapshot.
- [x] Equipment stayed unchanged during the inventory test.
- [x] Legacy `AscensionTrainingFeedbackGui` did not appear.
- [x] Legacy `AscensionCombatFeedbackGui` did not appear.
- [x] Console output showed only expected unpublished-place DataStore/API warnings on the server and no client warnings/errors.
- [x] Studio Play mode was stopped after verification.
- [ ] Run a hands-on desktop pass through Strength Forge, combat, reward popup, and inventory with the legacy scripts disabled.
- [ ] Run a hands-on touch/mobile pass through Strength Forge, combat, reward popup, and inventory with the legacy scripts disabled.
- [ ] Confirm no old training/combat overlays appear during normal player-driven prompt use and sword input.
- [ ] Save the Roblox place in Studio after successful MCP changes.

Example Studio assertions and manual steps are documented in `roblox/tests/R2LegacyCleanup.examples.md`.

Observed checks on 2026-06-30:

- [x] Edit-mode audit confirmed all R2 target scripts disabled/tagged.
- [x] Runtime server validation printed `R2_RUNTIME_SERVER_OK` with `TrainingXPGained=147`, first hit `42 -> 29`, enemy reward `1/0 -> 1/12`, and inventory `0 -> 1`.
- [x] Runtime client validation printed `R2_RUNTIME_CLIENT_OK` with one canonical RewardPopup, CombatController, TrainingStatsHud, InventoryPanel, zero legacy feedback GUIs, `PowerLevelText = Lv 1`, and `RewardLastTitle = Slime Defeated`.

## R3 - Existing Combat Presentation Polish

R3 implementation pass completed on 2026-07-01; acceptance remains pending owner-approved animation/audio assets:

- [x] Required Roblox docs, active roadmap, architecture, tracker, decision log, known issues, manual checklist, project summary, visual direction, visual references, and economy boundaries were reviewed.
- [x] Roblox Studio instance `Zero` was listed and set active.
- [x] Studio tree was inspected before changes.
- [x] Current sword client and server combat flow was inspected.
- [x] Live Studio `CombatController` source was replaced with the clean source-controlled file.
- [x] Live Studio `CombatController` source no longer contains the stale wrapper body.
- [x] `CombatControllerGui` exposes `R3CombatPresentationPolish = true`.
- [x] Combat HUD uses a guarded `Heartbeat` update path and exposes `LastHudError` if update fails.
- [x] Target panel shows the nearest replicated enemy name, range state, and HP.
- [x] Local target highlight is display-only.
- [x] Damage float displays server-approved damage from `CombatFeedback`.
- [x] Local swing trail runs only after confirmed `BasicAttack` feedback.
- [x] Local impact burst runs only after confirmed `BasicAttack` feedback.
- [x] Local enemy hit recoil runs only after confirmed `BasicAttack` feedback.
- [x] Training stats HUD is suppressed while combat HUD is active.
- [x] No server damage, cooldown, reward, loot, enemy stat, Break flag, remote, or mobile input behavior was changed.
- [x] Play-mode server validation confirmed Stone Shell health changed from `96` to `88` with `Damage=8`.
- [x] Play-mode server validation confirmed `Break=0` while Break remains disabled.
- [x] Play-mode server validation confirmed duplicate attack rejection with `Cooldown`.
- [x] Play-mode client validation confirmed target panel showed `Stone Shell 88/96`.
- [x] Play-mode client validation confirmed `Damage=8`, `Floats=1`, `Impacts=1`, and `Trails=1`.
- [x] Play-mode client validation confirmed `TrainingStatsHudGui.Enabled=false` while the combat HUD was active.
- [x] Legacy `AscensionCombatFeedbackGui` did not appear.
- [x] Legacy `AscensionTrainingFeedbackGui` did not appear.
- [x] Console output showed only expected unpublished-place DataStore/API warnings plus R3 validation output.
- [x] Studio Play mode was stopped after verification.
- [ ] Owner-approved idle/equip/swing animation IDs are provided and added.
- [ ] Owner-approved bounded swing/impact audio assets are provided and added.
- [ ] Verify animation cancellation and equip/unequip state after approved animations exist.
- [ ] Run a hands-on desktop fight against Lesser Slime and Stone Shell and confirm target panel, hit feedback, reward popup, inventory button, and stats-HUD suppression are readable.
- [ ] Run a hands-on touch/mobile fight against Lesser Slime and Stone Shell and confirm controls remain readable and unchanged.
- [ ] Save the Roblox place in Studio after successful MCP changes.

Example Studio assertions and manual steps are documented in `roblox/tests/R3CombatPresentationPolish.examples.md`.

Observed checks on 2026-07-01:

- [x] Edit-mode source verification confirmed R3 marker, target panel, damage float, and Heartbeat update path exist in live Studio source.
- [x] Runtime server validation printed `R3_SERVER_OK Target=StoneShell Before=96 After=88 Damage=8 Break=0 CooldownReject=Cooldown`.
- [x] Runtime client validation printed `R3_CLIENT_OK Target=Stone Shell HP=88/96 Damage=8 Floats=1 Impacts=1 Trails=1 StatsHudEnabled=false`.

## Milestone 1.1 Manual Checks

Milestone 1.1 - Shared Stat Configuration:

- [x] Power exists in one shared stat config.
- [x] Vitality exists in one shared stat config.
- [x] Agility exists in one shared stat config.
- [x] Endurance exists in one shared stat config.
- [x] Control exists in one shared stat config.
- [x] Required XP examples are documented.
- [x] Invalid stat names fail safely.
- [x] No client-owned XP mutation exists.

Example Studio assertions are documented in `roblox/tests/StatConfig.examples.md`.

Observed checks on 2026-06-27:

- [x] `StatConfig.GetRequiredXPForLevel("Power", 1)` returns `100`.
- [x] `StatConfig.GetRequiredXPForLevel("Power", 2)` returns `255`.
- [x] `StatConfig.GetRequiredXPForLevel("Power", 3)` returns `441`.
- [x] `StatConfig.GetTotalXPRequiredForLevel("Power", 3)` returns `796`.
- [x] `StatConfig.IsValidStatId("Strength")` returns `false`.
- [x] `StatConfig.GetRequiredXPForLevel("Strength", 1)` returns `nil`.
- [x] Play mode loads a player `Stats` folder with Power, Vitality, Agility, Endurance, and Control.

## Milestone 1.2 Manual Checks

Milestone 1.2 - Player Profile Model:

- [x] Default profile contains Version, HeroLevel, HeroXP, Gold, TrainingStats, Equipment, Inventory, Campaign, MobileLink, and RewardClaims.
- [x] Each training stat begins at Level 0 and XP 0.
- [x] Each training stat has 0 effective earned stat value.
- [x] Default profile tables are not shared between players.
- [x] Invalid or missing fields can be repaired safely.
- [x] Invalid or missing fields can be rejected safely through validation.
- [x] Migration placeholder exists.
- [x] No DataStore persistence was added for this milestone.

Example Studio assertions are documented in `roblox/tests/PlayerProfileModel.examples.md`.

Observed checks on 2026-06-27:

- [x] `PlayerProfileModel.CreateDefaultProfile()` returns all required top-level fields.
- [x] Power, Vitality, Agility, Endurance, and Control each start with `Level = 0`, `XP = 0`, and `EffectiveValue = 0`.
- [x] Mutating one default profile does not mutate another default profile.
- [x] `PlayerProfileModel.ValidateProfile(defaultProfile).IsValid` returns `true`.
- [x] `PlayerProfileModel.ValidateProfile({}).IsValid` returns `false`.
- [x] `PlayerProfileModel.RepairProfile(invalidProfile)` returns a repaired profile and reports issues.
- [x] Server-side Play mode can require `ReplicatedStorage.ZeroToHeroShared.Types.PlayerProfileModel`.

## Milestone 1.3 Manual Checks

Milestone 1.3 - Player Data Service:

- [x] New player receives a valid profile from `PlayerProfileModel`.
- [x] Session cache is server-only.
- [x] Clients cannot directly set profile values through any new remote.
- [x] PlayerRemoving attempts save.
- [x] BindToClose attempts save.
- [x] Studio-safe development mode works when DataStores are unavailable.
- [x] Join/rejoin persistence test is documented.
- [x] `GetProfile` returns a copy instead of the cached mutable profile table.
- [x] Server mutator updates cached profile and replicated player values.
- [x] Invalid stat mutation fails safely.

Example Studio assertions are documented in `roblox/tests/PlayerDataService.examples.md`.

Observed checks on 2026-06-27:

- [x] `PlayerDataService.GetSession(player)` returns a loaded session in Play mode.
- [x] Default profile has `Version = 1`, `HeroLevel = 1`, `HeroXP = 0`, and `Gold = 0`.
- [x] Power starts with `Level = 0`, `XP = 0`, and `EffectiveValue = 0`.
- [x] Player receives replicated `Profile` and `Stats` folders.
- [x] Mutating a `GetProfile` snapshot does not mutate the cached profile.
- [x] `PlayerDataService.AddTrainingStatValue(player, "Power", 1, ...)` updates the cached profile and `player.Stats.Power`.
- [x] `PlayerDataService.AddTrainingStatValue(player, "Strength", 1, ...)` fails safely.
- [x] In unpublished local Studio, `SavePlayer(player, true)` returns a session-only status instead of overwriting possible stored data.

Join/rejoin persistence procedure when Studio DataStores are enabled:

1. Publish the Roblox place.
2. Enable Studio API/DataStore access.
3. Start Play mode with one test player.
4. Run `PlayerDataService.AddTrainingStatValue(player, "Power", 1, "Persistence test")` from the server.
5. Stop Play mode, then start Play mode again with the same test account.
6. Confirm `PlayerDataService.GetProfile(player).TrainingStats.Power.EffectiveValue` kept the saved value.

## Milestone 2.1 Manual Checks

Milestone 2.1 - Training Service:

- [x] Training XP can only be awarded by server code.
- [x] Multiple level-ups are handled by `TrainingService`.
- [x] Invalid rewards fail safely.
- [x] Diminishing-return multiplier is deterministic.
- [x] Reward result includes old level, new level, XP gained, and level-up count.
- [x] Pure/manual documented cases exist.

Example Studio assertions are documented in `roblox/tests/TrainingService.examples.md`.

Observed checks on 2026-06-27:

- [x] Studio Play mode started after adding `TrainingService`.
- [x] Console showed no TrainingService compile or require errors.
- [x] The only console message observed was the expected unpublished-place DataStore warning.
- [x] Player received replicated `Profile`, `Stats`, and `leaderstats` folders during Play mode.
- [x] Studio Play mode stopped after verification.
- [ ] Run the full `TrainingService.examples.md` assertion block from the server command context when a Luau test runner or command runner is available.

## Milestone 2.2 Manual Checks

Milestone 2.2 - Training Station Framework:

- [x] One placeholder Strength Forge station is configured in `TrainingStationConfig`.
- [x] The server station framework binds to the existing `TrainStrengthPrompt`.
- [x] The station framework validates player distance before award.
- [x] The station framework applies per-player station cooldown.
- [x] Rapid spam is rejected by the service implementation.
- [x] Client reward data is sent through `TrainingStationReward` as curated server-approved fields.
- [x] Station logic is config-driven and can support future station entries.

Example Studio assertions are documented in `roblox/tests/TrainingStationService.examples.md`.

Observed checks on 2026-06-27:

- [x] Studio Play mode started after adding `TrainingStationService`.
- [x] Console showed no station framework compile or require errors.
- [x] The only console message observed was the expected unpublished-place DataStore warning.
- [x] Runtime tree contained `ReplicatedStorage.ZeroToHeroShared.Remotes.TrainingStationReward`.
- [x] Runtime tree contained `Workspace.AscensionGrounds.StrengthForge.ForgeCore.TrainStrengthPrompt`.
- [x] Studio Play mode stopped after verification.
- [ ] Run the full `TrainingStationService.examples.md` assertion block from the server command context when a Luau test runner or command runner is available.

## Milestone 2.3 Manual Checks

Milestone 2.3 - Strength Forge Minigame:

- [x] Strength Forge station config uses `StrengthForge` and trains Power.
- [x] Direct server activation without a validated challenge fails with `MinigameRequired`.
- [x] Prompt activation starts a server-issued challenge.
- [x] Challenge/action/reward RemoteEvents exist at runtime.
- [x] The client receives a challenge and shows `StrengthForgeMinigameGui`.
- [x] The minigame UI contains a timing bar and Strike button.
- [x] Three server-timed successful submissions complete a set.
- [x] Completion awards Power XP through `TrainingService`.
- [x] Immediate repeat activation is blocked by cooldown.
- [x] Active challenge cancellation clears the server challenge state.
- [x] Console showed no minigame compile/runtime errors during Play checks.
- [ ] Run a hands-on viewport check for mouse click, keyboard `Space`/`E`, and touch/button activation timing.
- [ ] Verify the reward popup visually appears after a real prompt-driven completion.
- [ ] Verify walking away from the forge during a hands-on challenge hides the panel and grants no XP.

Example Studio assertions and manual steps are documented in `roblox/tests/StrengthForgeMinigame.examples.md`.

Observed checks on 2026-06-27:

- [x] Edit-mode require check passed for `TrainingStationConfig` and `TrainingStationService`.
- [x] Server-side Play assertion completed three server-timed reps.
- [x] Power advanced from Level 0 to Level 1.
- [x] Power XP carried over from 0 to 48 after the level-up.
- [x] Final tested reward gained 148 Power XP.
- [x] Cooldown rejected immediate restart.
- [x] Client `PlayerGui.StrengthForgeMinigameGui.Panel` became visible after a server-issued challenge.
- [x] The only console output was the expected unpublished-place DataStore warning.

## Milestone 2.4 Manual Checks

Milestone 2.4 - Stats HUD:

- [x] `PlayerDataService` replicates `player.TrainingStats`.
- [x] Power, Vitality, Agility, Endurance, and Control each have replicated `Level`, `XP`, `XPRequired`, and `EffectiveValue`.
- [x] `Profile.TrainingRank` is replicated.
- [x] `TrainingStatsHudGui` appears in `PlayerGui`.
- [x] HUD displays five stat rows.
- [x] HUD displays level and XP text.
- [x] HUD displays XP bars.
- [x] HUD displays Training Rank.
- [x] HUD updates after Strength Forge completion.
- [x] Legacy `AscensionTrainingFeedbackGui.StatsPanel` is hidden to avoid duplicate stat panels.
- [x] Console showed no Stats HUD compile/runtime errors during Play checks.
- [ ] Run a hands-on viewport check at phone and desktop aspect ratios.
- [ ] Confirm the Power row flash and XP bar animation are visually readable after a real prompt-driven Strength Forge completion.

Example Studio assertions and manual steps are documented in `roblox/tests/TrainingStatsHud.examples.md`.

Observed checks on 2026-06-27:

- [x] Edit-mode require check passed for updated `PlayerDataService`.
- [x] Server-side Play assertion confirmed all five replicated stat snapshots.
- [x] Strength Forge completion updated Power to `Lv 1`, `48 / 255 XP`, `EffectiveValue = 1`.
- [x] Client HUD check confirmed all five rows existed.
- [x] Client HUD check confirmed Power displayed `Lv 1` and `48 / 255 XP`.
- [x] Client HUD check confirmed Rank displayed `Rank 0`.
- [x] The only console output was the expected unpublished-place DataStore warning.

## Milestone 2.5 Manual Checks

Milestone 2.5 - Reward Popup:

- [x] `RewardPopup` exists under `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI`.
- [x] `RewardPopupGui` appears in `PlayerGui`.
- [x] Popup listens to `ZeroToHeroShared.Remotes.TrainingStationReward`.
- [x] Strength Forge completion records a `Power XP` reward row.
- [x] Strength Forge completion records the approved XP amount.
- [x] Level-up rewards show `LEVEL UP` emphasis.
- [x] Multiple reward payloads queue instead of replacing each other immediately.
- [x] Queue depth returns to `0` after rewards process.
- [x] Gold reward payloads display.
- [x] Rare item reward payloads display with stronger presentation.
- [x] Legacy `AscensionTrainingFeedbackGui.RewardToast` is hidden to avoid duplicate popups.
- [x] Console showed no RewardPopup compile/runtime errors during clean Play boot.
- [ ] Run a hands-on phone and desktop viewport check for popup placement and text readability.
- [ ] Verify a real prompt-driven Strength Forge completion visually, not only through MCP-triggered server timing.

Example Studio assertions and manual steps are documented in `roblox/tests/RewardPopup.examples.md`.

Observed checks on 2026-06-27:

- [x] Clean Play boot created `RewardPopupGui`, `Popup`, `Header`, and `RewardRows`.
- [x] Runtime tree contained `ReplicatedStorage.ZeroToHeroShared.Remotes.TrainingStationReward`.
- [x] Actual server-timed Strength Forge completion fired `Power +148 XP`, `Lv 0 -> 1`.
- [x] Client popup state recorded `Power XP`, `+148`, `Lv 0 -> 1`, and a visible level-up badge configuration.
- [x] Held Strength Forge-style payload verified the popup can remain visible with `Power XP +148` and `LEVEL UP`.
- [x] Queue test showed `Gold +25` first with a second reward queued.
- [x] Queue test advanced to `Loot Found` / `Training Blade +1` and then cleared.
- [x] Final clean Play boot showed only the expected unpublished-place DataStore warning.

## Milestone 3.1 Manual Checks

Milestone 3.1 - Top-Down Layout:

- [x] `Workspace.AscensionGrounds.ReferenceSpacingBlockout.CentralPlaza` exists.
- [x] `Workspace.AscensionGrounds.ReferenceSpacingBlockout.CentralPlaza.CentralCrystal` exists as a blue crystal placeholder.
- [x] `Workspace.AscensionGrounds.ReferenceSpacingBlockout.RoadGrid` contains five district road parts.
- [x] `Workspace.AscensionGrounds.StrengthForge` remains the Power district landmark and station.
- [x] `GuardianHallBlockout` exists and is signposted.
- [x] `AgilityTowerBlockout` exists and is signposted.
- [x] `EnduranceTrackBlockout` exists and is signposted.
- [x] `ControlShrineBlockout` exists and is signposted.
- [x] `BrokenGateBlockout` exists as the single main route out of the hub.
- [x] No four-gate layout was added.
- [x] No multi-floor maze was added.
- [x] Roads are wide enough for groups in the greybox inspection.
- [x] Layout uses primitives and named placeholder models.
- [x] Studio Play mode starts with no layout errors.
- [ ] Run a hands-on walk from spawn to central plaza, Strength Forge, all district signs, and Broken Gate.

Example Studio assertions and manual steps are documented in `roblox/tests/AscensionGroundsLayout.examples.md`.

Observed checks on 2026-06-28:

- [x] Central crystal is blue/neon and sized `6, 17, 6`.
- [x] Main route is 13 studs wide.
- [x] District roads are 10-12 studs wide.
- [x] Broken Gate road is 20 studs wide.
- [x] `GroundPlate` is collidable and sized `230, 2, 205`.
- [x] District labels read `STRENGTH FORGE`, `GUARDIAN HALL`, `AGILITY TOWER`, `ENDURANCE TRACK`, and `CONTROL SHRINE`.
- [x] Broken Gate label reads `BROKEN GATE`.

## Milestone 3.2 Manual Checks

Milestone 3.2 - District Shells:

- [x] `Workspace.AscensionGrounds.StrengthForge.Milestone32ShellDetails` exists.
- [x] `GuardianHallBlockout.Milestone32ShellDetails` exists.
- [x] `AgilityTowerBlockout.Milestone32ShellDetails` exists.
- [x] `EnduranceTrackBlockout.Milestone32ShellDetails` exists.
- [x] `ControlShrineBlockout.Milestone32ShellDetails` exists.
- [x] Strength Forge reads as orange, metal, and stone.
- [x] Guardian Hall reads as blue, fortified, and defensive.
- [x] Agility Tower reads as purple, vertical, and obstacle-focused.
- [x] Endurance Track reads as green, open, and route-focused.
- [x] Control Shrine reads as teal, precise, and mystical.
- [x] New shell detail parts are anchored.
- [x] New shell detail parts are non-collidable.
- [x] Strength Forge prompt remains present and enabled.
- [x] Strength Forge challenge can still start and cancel.
- [x] No remaining training minigames were implemented.
- [x] Console showed no new district shell runtime errors during Play checks.
- [ ] Run a hands-on walk around each district shell and confirm the details do not block the route from the central plaza.

Example Studio assertions and manual steps are documented in `roblox/tests/DistrictShells.examples.md`.

Observed checks on 2026-06-28:

- [x] Five `Milestone32ShellDetails` models existed in the expected district parents.
- [x] 31 primitive shell detail parts existed at runtime.
- [x] All 31 shell detail parts were anchored.
- [x] All 31 shell detail parts had `CanCollide = false`.
- [x] Strength Forge `TrainStrengthPrompt` remained enabled.
- [x] Strength Forge challenge started with 3 required successes and 6 maximum attempts.
- [x] Strength Forge challenge cancelled cleanly.
- [x] The only console output was the expected unpublished-place DataStore warning.

## Milestone 3.3 Manual Checks

Milestone 3.3 - Broken Gate Transition:

- [x] `Workspace.AscensionGrounds.ReferenceSpacingBlockout.BrokenGateBlockout.Milestone33TransitionDetails` exists.
- [x] Safe side is marked with blue ward/threshold details.
- [x] Danger side is marked with red threshold, dark route, red lights, ruins, and torn banner placeholders.
- [x] The transition is readable without UI text.
- [x] Route surfaces are at least 24 studs wide.
- [x] Decorative transition details are non-collidable.
- [x] Spawn and central social areas were not changed.
- [x] No new enemies were added for this milestone.
- [x] Existing legacy `EnemyArea.TrainingDummy` was not modified or duplicated.
- [x] Console showed no new transition runtime errors during Play checks.
- [ ] Run a hands-on walk from the central plaza through Broken Gate to the danger-side route and confirm the route feels open enough for future combat.

Example Studio assertions and manual steps are documented in `roblox/tests/BrokenGateTransition.examples.md`.

Observed checks on 2026-06-28:

- [x] `Milestone33TransitionDetails` existed in Edit mode and Play mode.
- [x] 28 primitive transition parts existed.
- [x] 5 red PointLights existed.
- [x] `DangerRouteFloorNear`, `DangerRouteFloorFar`, and `FutureBossRoutePlate` were collidable route surfaces.
- [x] Route surfaces were 26, 30, and 32 studs wide.
- [x] Decorative transition parts were anchored and non-collidable.
- [x] Runtime raycasts hit the expected route surfaces.
- [x] Player could be moved onto `DangerRouteFloorFar`.
- [x] The only console output was the expected unpublished-place DataStore warning.

## Milestone 4.1 Manual Checks

Milestone 4.1 - Derived Combat Stats:

- [x] `ReplicatedStorage.ZeroToHeroShared.Config.CombatStatConfig` exists.
- [x] `ReplicatedStorage.ZeroToHeroShared.Utility.DerivedCombatStats` exists.
- [x] `DerivedCombatStats.Calculate` can be required in Studio Edit mode.
- [x] Low-stat case returns base combat stats.
- [x] Normal-stat case combines training, hero level, equipment, and class contributions deterministically.
- [x] High-stat case enforces the movement-speed cap.
- [x] High-stat case enforces the critical-chance cap.
- [x] High-stat case enforces damage and other defensive caps.
- [x] Result exposes `Contributions.Training` separately from `Contributions.Equipment`.
- [x] Result exposes `Contributions.TrainingByStat`.
- [x] Result exposes cap metadata under `Metadata.Caps`.
- [x] No combat controller, damage, rewards, or loot flow was added.
- [x] Studio Play mode starts after the shared modules are added.
- [x] Console showed no new derived-stat runtime errors during Play checks.

Example Studio assertions and manual steps are documented in `roblox/tests/DerivedCombatStats.examples.md`.

Observed checks on 2026-06-28:

- [x] Low case produced `MaxHP = 100`, `PhysicalDamage = 12`, `BreakDamage = 8`, `MaxStamina = 100`, `StaminaRecovery = 8`, `MoveSpeedBonus = 0`, `CriticalChance = 0.05`, `GuardEffectiveness = 0.1`, and `SkillEffectiveness = 1`.
- [x] Normal case produced `MaxHP = 254`, `PhysicalDamage = 32.4`, `BreakDamage = 20.64`, `MaxStamina = 184`, `StaminaRecovery = 9.29`, `MoveSpeedBonus = 0.018`, `CriticalChance = 0.0845`, `GuardEffectiveness = 0.176`, and `SkillEffectiveness = 1.075`.
- [x] High case capped `MoveSpeedBonus` at `0.25`, `CriticalChance` at `0.35`, and `PhysicalDamage` at `1000`.
- [x] Training and equipment contributions remained separately readable in the result table.

## Milestone 4.2 Manual Checks

Milestone 4.2 - Player Combat Controller:

- [x] `ReplicatedStorage.ZeroToHeroShared.Config.CombatActionConfig` exists.
- [x] `ServerScriptService.ZeroToHeroServer.Services.CombatService` exists.
- [x] `ServerScriptService.ZeroToHeroServer.CombatBootstrap` exists.
- [x] `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Controllers.CombatController` exists.
- [x] Server-owned `CombatAction` and `CombatFeedback` remotes are created by `CombatService`.
- [x] Basic attack validates target, range, facing, health, and cooldown before applying damage.
- [x] Basic attack damage is calculated on the server through derived combat stats.
- [x] Guard state is server-owned.
- [x] `ApplyIncomingDamage` reduces incoming damage while guard is active.
- [x] Dodge consumes server-owned stamina.
- [x] Dodge defines a short invulnerability window and bounded displacement.
- [x] Client combat UI includes large touch buttons for `ATK`, `GUARD`, and `DODGE`.
- [x] Keyboard input supports left mouse attack, `F` guard, and `Q` dodge.
- [x] Legacy `EnemyArea.server` and `AscensionSwordCombatServer` are runtime-disabled by `CombatBootstrap`.
- [ ] Run the server assertion block in `roblox/tests/PlayerCombatController.examples.md`.
- [ ] Run a hands-on mouse/keyboard attack, guard, and dodge test against `TrainingDummy`.
- [ ] Run a hands-on touch/mobile button test against `TrainingDummy`.
- [ ] Confirm combat buttons do not obscure Strength Forge, Stats HUD, or Reward Popup in common phone and desktop viewports.

Example Studio assertions and manual steps are documented in `roblox/tests/PlayerCombatController.examples.md`.

Observed checks on 2026-06-28:

- [x] Runtime tree contained `ReplicatedStorage.ZeroToHeroShared.Remotes.CombatAction`.
- [x] Runtime tree contained `ReplicatedStorage.ZeroToHeroShared.Remotes.CombatFeedback`.
- [x] Runtime tree contained `Players.Kibosabie.PlayerGui.CombatControllerGui.Controls.AttackButton`.
- [x] Runtime tree contained `Players.Kibosabie.PlayerGui.CombatControllerGui.Controls.GuardButton`.
- [x] Runtime tree contained `Players.Kibosabie.PlayerGui.CombatControllerGui.Controls.DodgeButton`.
- [x] Runtime tree contained `Workspace.AscensionGrounds.EnemyArea.TrainingDummy.MaxHealth`.
- [x] Console showed no new combat compile/runtime errors during Play mode.
- [x] Studio Play mode stopped after verification.

## Milestone 4.3 Manual Checks

Milestone 4.3 - Mobile Combat HUD:

- [x] `player.CombatState` exists in Play mode.
- [x] `CombatState.HP` and `CombatState.MaxHP` exist.
- [x] `CombatState.Stamina` and `CombatState.MaxStamina` exist.
- [x] `CombatState.AttackCooldownMs` and `CombatState.DodgeCooldownMs` exist.
- [x] `CombatState.IsGuarding` and `CombatState.DodgeInvulnerable` exist.
- [x] `CombatControllerGui.ResourcePanel` exists.
- [x] `ResourcePanel.HP` and `ResourcePanel.Stamina` exist.
- [x] `AttackButton`, `GuardButton`, and `DodgeButton` exist.
- [x] `Skill1Button`, `Skill2Button`, `UltimateButton`, and `InteractButton` exist as placeholders.
- [x] Attack and Dodge buttons have cooldown overlay labels.
- [x] Console showed no new HUD compile/runtime errors during Play mode.
- [ ] Run a hands-on phone-sized viewport check for HP/stamina readability.
- [ ] Run a hands-on touch test for ATK, GUARD, and DODGE.
- [ ] Confirm cooldown overlays are readable during rapid attack/dodge use.
- [ ] Confirm HP and stamina bars visibly update after damage/dodge.
- [ ] Confirm HUD controls do not overlap Strength Forge, Stats HUD, or Reward Popup in common phone and desktop layouts.

Example Studio assertions and manual steps are documented in `roblox/tests/CombatHud.examples.md`.

Observed checks on 2026-06-28:

- [x] Runtime tree contained `Players.Kibosabie.CombatState`.
- [x] Runtime tree contained all expected `CombatState` values.
- [x] Runtime tree contained `CombatControllerGui.ResourcePanel`.
- [x] Runtime tree contained `CombatControllerGui.Controls`.
- [x] Runtime tree contained all seven combat HUD buttons.
- [x] Character was moved to the dummy area during Play mode.
- [x] Console output showed only the expected unpublished-place DataStore warning.
- [x] Studio Play mode stopped after verification.

## Milestone 4.4 Manual Checks

Milestone 4.4 - First Enemy:

- [x] `ReplicatedStorage.ZeroToHeroShared.Config.EnemyConfig` exists.
- [x] `ServerScriptService.ZeroToHeroServer.Services.EnemyService` exists.
- [x] `ServerScriptService.ZeroToHeroServer.EnemyBootstrap` exists.
- [x] `CombatService.RegisterTargetHitCallback` exists for server-side enemy hit handling.
- [x] `PlayerDataService.AddHeroXP` exists.
- [x] `PlayerDataService.AddGold` exists.
- [x] `Workspace.AscensionGrounds.EnemyArea.LesserSlime` spawns in Play mode.
- [x] `LesserSlime.Body`, `Health`, `MaxHealth`, `State`, and `AttackTelegraph` exist.
- [x] Lesser Slime uses server-owned health.
- [x] Lesser Slime can detect, chase, attack, die, and respawn through server logic.
- [x] Lesser Slime attack telegraph appears before damage.
- [x] Lesser Slime damage applies through `CombatService.ApplyIncomingDamage`.
- [x] Lesser Slime defeat grants Hero XP through `PlayerDataService`.
- [x] Lesser Slime defeat can grant Gold through `PlayerDataService`.
- [x] Rewards grant once per death.
- [x] Duplicate attacks cannot duplicate rewards.
- [x] Enemy does not continue attacking after death.
- [x] Respawn restores health and resets reward state.
- [x] No equipment drop was added.
- [x] Console showed no new enemy compile/runtime errors during Play mode.
- [ ] Run a hands-on mouse/keyboard fight against Lesser Slime.
- [ ] Run a hands-on touch/mobile fight against Lesser Slime.
- [ ] Confirm the reward popup is visually readable after an actual player-driven slime defeat.
- [ ] Confirm fighting the slime feels readable with the current HUD and does not overlap key UI.

Example Studio assertions and manual steps are documented in `roblox/tests/LesserSlimeEnemy.examples.md`.

Observed checks on 2026-06-28:

- [x] Edit-mode require check passed for `EnemyConfig`, `PlayerDataService`, `CombatService`, and `EnemyService`.
- [x] Runtime tree contained `Workspace.AscensionGrounds.EnemyArea.LesserSlime`.
- [x] Runtime tree contained `LesserSlime.Health`, `MaxHealth`, `State`, `Body`, `BaseShadow`, `AttackTelegraph`, and `Body.EnemyBillboard`.
- [x] Runtime tree contained `ReplicatedStorage.ZeroToHeroShared.Remotes.TrainingStationReward`.
- [x] Server assertion defeated the slime through `CombatService.TryBasicAttack`.
- [x] Server assertion increased Hero XP by `12`.
- [x] Server assertion kept Gold within the configured reward range.
- [x] Immediate duplicate attack changed no Hero XP or Gold.
- [x] Post-cooldown duplicate attack failed with `TargetDefeated` and changed no Hero XP or Gold.
- [x] Server assertion confirmed `State = Dead`, `RewardClaimed = true`, and hidden attack telegraph after death.
- [x] Server assertion confirmed respawn restored `Health = 42`, reset `RewardClaimed = false`, changed `SpawnId`, and returned to `Idle`.
- [x] Server AI assertion observed the attack telegraph and reduced player HP from `100` to `91`.
- [x] Console output showed only the expected unpublished-place DataStore warning.
- [x] Studio Play mode stopped after verification.

## Milestone 5.1 Manual Checks

Milestone 5.1 - Hero XP and Gold:

- [x] `ReplicatedStorage.ZeroToHeroShared.Config.HeroProgressionConfig` exists.
- [x] `ServerScriptService.ZeroToHeroServer.Services.HeroProgressionService` exists.
- [x] `ServerScriptService.ZeroToHeroServer.HeroProgressionBootstrap` exists.
- [x] `player.Profile.HeroLevel` exists in Play mode.
- [x] `player.Profile.HeroXP` exists in Play mode.
- [x] `player.Profile.HeroXPRequired` exists in Play mode.
- [x] `player.Profile.Gold` exists in Play mode.
- [x] Hero XP leveling is separate from Training XP.
- [x] Hero XP awards are server-authoritative.
- [x] Gold awards are server-authoritative.
- [x] Multiple Hero Level-ups are supported by `PlayerDataService.AddHeroXP`.
- [x] Hero XP is stored as carryover XP toward the next Hero Level.
- [x] Reward result includes old/new Hero Level, old/new Hero XP, level-up count, next Hero XP requirement, old/new Gold, and reward rows.
- [x] Empty/zero rewards fail safely without mutating Hero Level, Hero XP, or Gold.
- [x] Lesser Slime defeat grants Hero XP through `HeroProgressionService`.
- [x] Lesser Slime reward popup payload reaches the client popup.
- [x] Console showed no new Hero progression compile/runtime errors during Play mode.
- [ ] Run the published-place rejoin test with DataStore access enabled and confirm Hero Level, Hero XP, and Gold persist.
- [ ] Run a hands-on player-driven slime defeat and confirm the reward popup is visually readable.

Example Studio assertions and manual steps are documented in `roblox/tests/HeroProgression.examples.md`.

Observed checks on 2026-06-28:

- [x] Runtime tree contained `Players.Kibosabie.Profile.HeroLevel`.
- [x] Runtime tree contained `Players.Kibosabie.Profile.HeroXP`.
- [x] Runtime tree contained `Players.Kibosabie.Profile.HeroXPRequired`.
- [x] Runtime tree contained `Players.Kibosabie.Profile.Gold`.
- [x] Runtime tree contained `ReplicatedStorage.ZeroToHeroShared.Remotes.TrainingStationReward`.
- [x] Server config assertion confirmed Hero Level 2 requires `24` XP and Hero Level 3 requires `46` XP.
- [x] Direct `HeroProgressionService.AwardRewards` assertion advanced Hero Level and granted `Gold +5`.
- [x] Direct reward assertion confirmed replicated `HeroLevel`, `HeroXP`, `HeroXPRequired`, and `Gold` matched the service result.
- [x] Empty reward assertion returned `NoRewards` and did not mutate progression.
- [x] Live Lesser Slime reward table granted `HeroXP +12` when routed through `HeroProgressionService`.
- [x] Server combat assertion defeated `LesserSlime` through `CombatService.TryBasicAttack(player, slime)`.
- [x] Server combat assertion cleared `EnemyService` target ownership before the attack and still increased Hero XP from `27` to `39`.
- [x] Client popup assertion recorded `Slime Defeated`, `Hero XP`, and `+12`.
- [x] `PlayerDataService.SavePlayer(player, true)` returned `false` in unpublished local Studio because DataStore access is unavailable.
- [x] Console output showed only the expected unpublished-place DataStore warning.
- [x] Studio Play mode stopped after verification.

## Milestone 5.2 Manual Checks

Milestone 5.2 - Item Configuration:

- [x] `ReplicatedStorage.ZeroToHeroShared.Config.ItemConfig` exists.
- [x] Item config contains exactly 15 items.
- [x] All item IDs are unique.
- [x] `Weapon`, `Armour`, and `Charm` are valid slots.
- [x] The config includes at least one item for each MVP slot.
- [x] The config includes starter items.
- [x] The config includes Brakk-themed items.
- [x] `Common`, `Rare`, `Epic`, and `Mythic` are valid rarities.
- [x] Each item has `Id`, `Name`, `Slot`, `Rarity`, `StatBonuses`, `PassiveId`, `TradePolicy`, `Source`, and `Description`.
- [x] Each item stat bonus uses a valid combat stat key.
- [x] Rarity stat-budget validation exists.
- [x] Invalid slot, rarity, trade policy, and old stat names fail validation.
- [x] No inventory ownership, equip/unequip action, loot table, or client item creation path was added.
- [x] Console showed no new item config compile/runtime errors during Play mode.

Example Studio assertions and manual steps are documented in `roblox/tests/ItemConfig.examples.md`.

Observed checks on 2026-06-28:

- [x] Studio Edit-mode assertion required `ItemConfig`.
- [x] Edit-mode assertion confirmed `15` item IDs.
- [x] Edit-mode assertion confirmed `5` weapons, `5` armour items, and `5` charms.
- [x] Edit-mode assertion confirmed `Common`, `Rare`, `Epic`, and `Mythic` are valid rarities.
- [x] Edit-mode assertion confirmed `Legendary` is invalid.
- [x] Edit-mode assertion confirmed `starter_training_blade` and `brakks_gatebreaker` exist.
- [x] Edit-mode invalid-item assertion using `Ring`, `Legendary`, `Strength`, and `CashTrade` failed with `7` validation issues.
- [x] Edit-mode budget assertion confirmed every item stayed under its rarity budget; highest observed budget was `25` under the Mythic cap of `30`.
- [x] Runtime tree contained `ReplicatedStorage.ZeroToHeroShared.Config.ItemConfig`.
- [x] Server runtime assertion confirmed `ValidateAllItems()` passes.
- [x] Client runtime assertion confirmed the replicated config can be required and returns `5` charm items.
- [x] Console output showed only the expected unpublished-place DataStore warning.
- [x] Studio Play mode stopped after verification.

## Milestone 5.3 Manual Checks

Milestone 5.3 - Inventory and Equipment:

- [x] `ServerScriptService.ZeroToHeroServer.Services.InventoryService` exists.
- [x] `ServerScriptService.ZeroToHeroServer.InventoryBootstrap` exists.
- [x] `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI.InventoryPanel` exists.
- [x] `ReplicatedStorage.ZeroToHeroShared.Remotes.InventoryAction` exists.
- [x] `ReplicatedStorage.ZeroToHeroShared.Remotes.InventorySnapshot` exists.
- [x] Server code can add an owned test sword item instance.
- [x] Client remotes do not expose item creation.
- [x] Inspect item returns server-approved item metadata.
- [x] Compare selected item with equipped slot returns stat delta data.
- [x] Equipping validates item ownership.
- [x] Wrong-slot equip fails.
- [x] Equipping recalculates effective stats.
- [x] Combat snapshots include equipped item bonuses.
- [x] Equipped item removal fails safely.
- [x] Unequip clears the slot and removes the item stat bonus.
- [x] Mobile inventory UI receives server snapshots.
- [x] Console showed no new inventory compile/runtime errors during Play mode.
- [ ] Run the published-place rejoin test with DataStore access enabled and confirm inventory items and equipped slots persist.
- [ ] Run a hands-on phone/desktop viewport check for inventory panel readability and overlap with the combat HUD.

Example Studio assertions and manual steps are documented in `roblox/tests/InventoryService.examples.md`.

Observed checks on 2026-06-29:

- [x] Edit-mode require check passed for `InventoryService`, `CombatService`, and `ItemConfig`.
- [x] Edit-mode assertion confirmed `InventoryAction` and `InventorySnapshot` under `ReplicatedStorage.ZeroToHeroShared.Remotes`.
- [x] Edit-mode assertion confirmed `starter_training_blade` is a `Weapon`.
- [x] Edit-mode assertion confirmed an empty equipment profile has `0` physical damage equipment bonus and `0` break damage equipment bonus.
- [x] Server assertion created `item_000001` from `starter_training_blade`.
- [x] Server assertion inspected `item_000001` and confirmed the item ID was `starter_training_blade`.
- [x] Server assertion compared `item_000001` and matched the configured physical damage delta.
- [x] Server assertion rejected equipping `item_000001` into `Charm` with `SlotMismatch`.
- [x] Server assertion equipped `item_000001` into `Weapon`.
- [x] Server assertion increased physical damage from `12` to `14`.
- [x] Server assertion increased break damage from `8` to `9`.
- [x] Server assertion confirmed `CombatService.GetPlayerCombatSnapshot(player).Stats.PhysicalDamage` was `14`.
- [x] Server assertion rejected removing equipped `item_000001` with `ItemEquipped`.
- [x] Server assertion unequipped the sword, confirmed `Weapon = false`, then re-equipped it for the UI check.
- [x] Client assertion confirmed `InventoryPanelGui` exists.
- [x] Client assertion confirmed item count `1`, equipped weapon `item_000001`, physical damage `14`, and break damage `9`.
- [x] `PlayerDataService.SavePlayer(player, true)` returned `false` in unpublished local Studio because DataStore access is unavailable.
- [x] Console output showed only the expected unpublished-place DataStore warning.
- [x] Studio Play mode stopped after verification.

## Milestone 5.4 Manual Checks

Milestone 5.4 - Loot Drops:

- [x] `ReplicatedStorage.ZeroToHeroShared.Config.LootTableConfig` exists.
- [x] `ServerScriptService.ZeroToHeroServer.Services.LootService` exists.
- [x] `ServerScriptService.ZeroToHeroServer.LootBootstrap` exists.
- [x] `EnemyConfig.GetEnemy("LesserSlime").LootTableId` points to `LesserSlime`.
- [x] `LootTableConfig.ValidateAllLootTables()` passes.
- [x] Lesser Slime loot table has guaranteed Hero XP.
- [x] Lesser Slime loot table has optional Gold.
- [x] Lesser Slime loot table has weighted Common item drops.
- [x] Lesser Slime loot table has a placeholder material drop.
- [x] Loot rolls happen through server `LootService`.
- [x] Item drops are awarded through `InventoryService.AddItem`.
- [x] Material drops are awarded through `PlayerDataService.AddMaterial`.
- [x] Duplicate reward keys fail without granting another item/material/Gold reward.
- [x] Loot reward rows reach the popup.
- [x] Loot item drop updates the inventory UI snapshot.
- [x] Console showed no new loot compile/runtime errors during Play mode.
- [ ] Run a hands-on player-driven slime defeat and confirm the popup/inventory feedback is readable on phone and desktop viewports.
- [ ] After the place is published and DataStore access is enabled, include material and loot-item persistence in a broader rejoin test.

Example Studio assertions and manual steps are documented in `roblox/tests/LootService.examples.md`.

Observed checks on 2026-06-29:

- [x] Studio Edit-mode source checks confirmed Lesser Slime points to `LootTableId = "LesserSlime"`.
- [x] Studio Edit-mode source checks confirmed `PlayerDataService.AddMaterial` exists.
- [x] Studio Play-mode server assertion confirmed `ValidateAllLootTables()` passed with `TableCount = 1`.
- [x] Server assertion forced Lesser Slime loot with reward key `Milestone54:1628062333`.
- [x] Server assertion granted `HeroXP +12`.
- [x] Server assertion granted `Gold +3`.
- [x] Server assertion granted `Slime Residue +1`.
- [x] Server assertion granted item `slime_slick_vest` as owned instance `item_000001`.
- [x] Server assertion confirmed inventory count increased to `1`.
- [x] Server assertion confirmed duplicate reward returned `DuplicateReward`.
- [x] Client assertion confirmed popup title `Loot Found`.
- [x] Client assertion confirmed popup rows for `Hero XP +12`, `Gold +3`, `Slime Residue +1`, and `Slime-Slick Vest +1`.
- [x] Client assertion confirmed `InventoryPanelGui` item count `1`.
- [x] `PlayerDataService.SavePlayer(player, true)` returned `false` with `SessionOnly` status in unpublished local Studio because DataStore access is unavailable.
- [x] Fresh Play-mode require check after `EnemyService` cleanup passed.
- [x] Console output showed only the expected unpublished-place DataStore warning.
- [x] Studio Play mode stopped after verification.

## Project Health Review Gate - Phase 5

Phase 5 reward, inventory, equipment, and loot review:

- [x] Required project docs, tracker, decision log, known issues, manual checklist, economy plan, visual direction, and reference folder were read.
- [x] Studio instance `Place1.rbxl` was listed and set active.
- [x] Studio Edit tree was inspected before the review Play check.
- [x] Canonical Phase 5 shared/server/client modules were present in Studio.
- [x] Runtime server smoke check confirmed Phase 5 modules require and start cleanly.
- [x] Runtime client smoke check confirmed canonical reward, inventory, combat, and stats HUD GUIs exist.
- [x] Console output showed only the expected unpublished-place DataStore warning.
- [x] Studio Play mode stopped after verification.
- [x] Full review is documented in `docs/roblox/project_health_review_2026-06-29_phase5.md`.
- [ ] Disable or archive legacy `AscensionSwordCombatClient` before broader combat readability checks.
- [ ] Decide whether the legacy `AscensionTrainingFeedbackClient`, `AscensionTrainingFeedbackServer`, and `AscensionRemotes.StatChanged` bridge can be removed.
- [ ] Harden `LootService` with durable/all-or-nothing claim behavior before boss, chest, campaign, or mobile claim rewards.
- [ ] Replace the training-named reward remote with a generic reward display path before richer grouped reward claims.

Observed checks on 2026-06-29:

- [x] Server runtime remotes included `CombatAction`, `CombatFeedback`, `InventoryAction`, `InventorySnapshot`, `TrainingStationAction`, `TrainingStationChallenge`, and `TrainingStationReward`.
- [x] Server runtime confirmed `ItemConfig` has 15 item IDs.
- [x] Server runtime confirmed Lesser Slime uses `LootTableId = "LesserSlime"`.
- [x] Server runtime confirmed `LootTableConfig.ValidateAllLootTables()` passed.
- [x] Server runtime confirmed profile, inventory, and materials tables exist.
- [x] Server runtime confirmed old server combat scripts were disabled by canonical bootstrap logic.
- [x] Client runtime confirmed `RewardPopupGui`, `InventoryPanelGui`, `CombatControllerGui`, and `TrainingStatsHudGui` exist.
- [x] Client runtime also confirmed legacy `AscensionCombatFeedbackGui` and `AscensionTrainingFeedbackGui` still exist.

## Milestone 6.1 Manual Checks

Milestone 6.1 - Enemy Set:

- [x] `ReplicatedStorage.ZeroToHeroShared.Config.EnemyConfig` contains `GateHound`.
- [x] `ReplicatedStorage.ZeroToHeroShared.Config.EnemyConfig` contains `StoneShell`.
- [x] `ReplicatedStorage.ZeroToHeroShared.Config.EnemyConfig` contains `GateSentinel`.
- [x] `ReplicatedStorage.ZeroToHeroShared.Config.LootTableConfig` contains loot tables for all three new enemies.
- [x] `LootTableConfig.ValidateAllLootTables()` passes with at least four loot tables.
- [x] `Workspace.AscensionGrounds.EnemyArea.GateHound` spawns in Play mode.
- [x] `Workspace.AscensionGrounds.EnemyArea.StoneShell` spawns in Play mode.
- [x] `Workspace.AscensionGrounds.EnemyArea.GateSentinel` spawns in Play mode.
- [x] Each new enemy has server-owned `Health`, `MaxHealth`, `State`, `Body`, and `AttackTelegraph`.
- [x] Gate Hound is configured as fast and fragile.
- [x] Stone Shell is configured as slow and armoured.
- [x] Stone Shell reduces incoming player attack damage through `DamageTakenMultiplier`.
- [x] Gate Sentinel enters a server-owned `Guard` state.
- [x] Gate Sentinel has a visible `GuardTelegraph` part.
- [x] Gate Sentinel guard reduces incoming player attack damage through `DamageTakenMultiplier`.
- [x] Defeating Gate Hound grants server-controlled progression rewards.
- [x] Duplicate attacks against a dead Gate Hound do not grant extra Hero XP, Hero Level, or Gold.
- [x] Console showed no new enemy compile/runtime errors during Play mode.
- [ ] Run a hands-on mouse/keyboard fight against Gate Hound and confirm it feels fast and fragile.
- [ ] Run a hands-on mouse/keyboard fight against Stone Shell and confirm it feels slow and armoured.
- [ ] Run a hands-on mouse/keyboard fight against Gate Sentinel and confirm the guard pattern is readable.
- [ ] Run touch/mobile fights against all three new enemies.
- [ ] Confirm attack telegraphs, Sentinel guard, combat HUD, reward popup, and enemy billboards remain readable on phone and desktop viewports.
- [ ] Save the Roblox place in Studio after successful MCP changes.

Example Studio assertions and manual steps are documented in `roblox/tests/Phase61EnemySet.examples.md`.

Observed checks on 2026-06-30:

- [x] Studio Edit-mode validation returned `PHASE61_EDIT_VALIDATE ok enemies=4 lootTables=4`.
- [x] Studio Play-mode server validation confirmed `GateHound`, `StoneShell`, and `GateSentinel` spawned under `Workspace.AscensionGrounds.EnemyArea`.
- [x] Runtime validation confirmed new enemy runtime parts and values.
- [x] Runtime validation confirmed `GateSentinel.GuardTelegraph` exists.
- [x] Runtime validation confirmed normal Hound attack damage: `houndDamage=12`.
- [x] Runtime validation confirmed Stone Shell reduced player attack damage from `raw=12` to `shellDamage=8`.
- [x] Runtime validation confirmed Sentinel guard reduced player attack damage from `raw=12` to `sentinelDamage=5`.
- [x] Runtime validation confirmed Gate Hound defeat advanced Hero XP or Hero Level.
- [x] Runtime validation confirmed dead-target duplicate attack did not grant additional Hero XP, Hero Level, or Gold.
- [x] Console output showed only the expected unpublished-place DataStore warning plus validation summaries.
- [x] Studio Play mode stopped after verification and returned to Edit mode.

## Milestone 6.2 Manual Checks

Milestone 6.2 - Break System:

- [x] `ReplicatedStorage.ZeroToHeroShared.Config.EnemyConfig.StoneShell` contains Break config.
- [x] `StoneShell.Break.MaxBreak` is `16`.
- [x] `StoneShell.Break.BrokenDurationSeconds` is `2`.
- [x] `StoneShell.Break.VulnerableDamageTakenMultiplier` is `1.35`.
- [x] `CombatActionConfig.BasicAttack` exposes `BreakDamageMultiplier`.
- [x] `CombatService.TryBasicAttack` returns `BreakDamage` and `RawBreakDamage` separately from `Damage` and `RawDamage`.
- [x] `Workspace.AscensionGrounds.EnemyArea.StoneShell` spawns with `Break`, `MaxBreak`, and `BreakState` values.
- [x] `StoneShell` has server-owned `BreakEnabled`, `Broken`, and `Vulnerable` attributes.
- [x] `StoneShell.Body.EnemyBillboard.Panel` contains `BreakLabel` and `BreakBar`.
- [x] Basic health damage still uses Stone Shell armor multiplier.
- [x] Break damage fills the Break meter separately from health damage.
- [x] Filled Break meter triggers `State = "Broken"` once.
- [x] Broken state raises `DamageTakenMultiplier` above `1`.
- [x] Additional hits during Broken state do not overfill or retrigger Break.
- [x] Recovery clears `Broken` / `Vulnerable`, resets Break to `0`, and restores Stone Shell armor multiplier.
- [x] Console showed no new Break compile/runtime errors during Play mode.
- [ ] Run a hands-on mouse/keyboard fight against Stone Shell and confirm the Break label/bar is readable while moving.
- [ ] Confirm the Broken vulnerability feels noticeable and understandable from player feedback.
- [ ] Confirm recovery timing is readable and not confusing.
- [ ] Run a touch/mobile fight against Stone Shell.
- [ ] Confirm combat HUD, reward popup, and enemy billboard remain readable on phone and desktop viewports during Break/Broken/recovery.
- [ ] Save the Roblox place in Studio after successful MCP changes.

Example Studio assertions and manual steps are documented in `roblox/tests/Phase62BreakSystem.examples.md`.

Observed checks on 2026-06-30:

- [x] Studio Edit-mode validation required fresh cloned ModuleScripts and completed with no assertion errors.
- [x] Studio Play-mode server validation confirmed Stone Shell spawned with Break values and Break attributes.
- [x] Runtime validation confirmed the Stone Shell billboard includes `BreakLabel` and `BreakBar`.
- [x] Runtime validation confirmed first hit produced `firstDamage=8`, `raw=12`, `break=8`, and `TargetDamageMultiplier = 0.65`.
- [x] Runtime validation confirmed Break filled after `2` hits and entered Broken state.
- [x] Runtime validation confirmed Broken vulnerability raised `DamageTakenMultiplier` to `1.35`.
- [x] Runtime validation confirmed a vulnerable hit used the `1.35` target multiplier and did not overfill or retrigger Break.
- [x] Runtime validation confirmed recovery cleared Broken/Vulnerable, reset Break to `0`, and restored `DamageTakenMultiplier = 0.65`.
- [x] Console output showed only the expected unpublished-place DataStore warning plus `PHASE62_RUNTIME_SERVER ok hits=2 firstDamage=8 raw=12 break=8 vulnerableMultiplier=1.35`.
- [x] Studio Play mode stopped after verification and returned to Edit mode.

## Phase 0 Visual Alignment, Asset-Backed Polish, and World Scale Pass

Visual-only pass completed on 2026-06-29:

- [x] Required Roblox project docs, visual direction, visual asset setup notes, asset manifest, known issues, tracker, decision log, manual checklist, economy plan, project summary, and reference images were reviewed.
- [x] Studio instance `Place1.rbxl` was listed and set active.
- [x] Studio Edit tree was inspected before visual changes.
- [x] Before captures were taken for hub scale, Strength Forge, and Broken Gate/EnemyArea.
- [x] `LowPoly Asset Pack` was re-inspected before live use and confirmed script-free/remote-free.
- [x] `Sword of Darkness` remained blocked and was not used live.
- [x] Free VFX Pack and Beam Texture Pack remained quarantined and were not used live.
- [x] `ReplicatedStorage.ZeroToHeroAssets.ApprovedVisualAssets.Phase0LowPolyApprovedSubset` was created with five art-only LowPoly templates.
- [x] `Workspace.AscensionGrounds.Phase0VisualScalePolish` was created with grouped central-plaza, district, forge, danger-route, and LowPoly dressing models.
- [x] Live visual group contained 158 BaseParts, 16 PointLights, 0 collidable parts, 0 unanchored parts, 0 scripts, and 0 remotes during Play-mode verification.
- [x] Strength Forge prompt remained enabled.
- [x] Strength Forge minigame start/cancel path still worked.
- [x] Reward popup appeared from a server-fired display payload.
- [x] Combat HUD controls/resources appeared near Lesser Slime.
- [x] Lesser Slime spawned and a server-authoritative basic attack reduced health from 42 to 30.
- [x] Stats HUD, reward popup, and combat HUD canonical scripts were visually polished without changing remotes or replicated data paths.
- [x] Console output showed only the expected unpublished-place DataStore warning.
- [x] Studio Play mode stopped after verification.
- [ ] Run hands-on phone/device-simulator screenshots for stats HUD, reward popup, combat HUD, Strength Forge minigame, and Broken Gate route.
- [ ] After saving the place, reopen Studio and confirm `Phase0VisualScalePolish` and `Phase0LowPolyApprovedSubset` persist.

Observed checks on 2026-06-29:

- [x] Before captures: `phase0_before_hub_scale_retry`, `phase0_before_strength_forge_top`, `phase0_before_broken_gate_enemy`.
- [x] After captures: `phase0_after_hub_scale`, `phase0_after_strength_forge_oblique`.
- [x] After danger-route and runtime HUD screenshot attempts timed out in the Studio capture tool; runtime UI was verified by client tree/state inspection instead.

## Phase 0 Training Zone Recreation, Visual Review, and World Scale Pass

Visual/world-scale pass completed on 2026-06-29:

- [x] Required Roblox project docs, visual direction, visual asset setup notes, asset manifest, recreation spec, known issues, tracker, decision log, manual checklist, economy plan, project summary, and reference images were reviewed.
- [x] Studio instance `Place1.rbxl` was listed and set active.
- [x] Studio Edit tree was inspected before visual changes.
- [x] Gameplay-critical Strength Forge prompt, enemy area, training anchors, HUD scripts, reward popup, server services, and remotes were identified before changes.
- [x] `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation` was created as a grouped, replaceable visual overlay.
- [x] Power, Vitality, Agility, Endurance, and Control each received a large district floor and dominant landmark.
- [x] Main routes were widened to 22-24 studs.
- [x] Strength Forge prompt remained enabled and unchanged at the original transform.
- [x] No Creator Store quarantine asset, blocked sword asset, full VFX pack, or beam pack was moved live.
- [x] New recreation group contained 0 scripts, 0 LocalScripts, 0 ModuleScripts, 0 remotes, 0 bindables, 0 particles, 0 beams, 0 trails, and 0 unanchored parts.
- [x] Studio Play mode started after changes.
- [x] Player could spawn and be moved through central, Power, Vitality, Agility, Endurance, and Control route samples.
- [x] Strength Forge minigame start/cancel path still worked.
- [x] Stats HUD, combat HUD, inventory UI, minigame UI, and reward popup existed in `PlayerGui`.
- [x] Reward popup displayed a server-fired `Visual Check` payload.
- [x] Lesser Slime spawned and a server-authoritative basic attack reduced health from 42 to 30.
- [x] Console output showed only the expected unpublished-place DataStore warning.
- [x] Studio Play mode stopped after verification.
- [ ] Save the Roblox place in Studio.
- [ ] After saving and reopening Studio, confirm `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation` persists.
- [ ] Capture manual before/after or current-state screenshots for hub, Strength Forge, Guardian Grove, Skyward Tower, Heroes' Track, Arcane Shrine, Broken Gate, HUD, and reward popup because MCP `screen_capture` timed out.
- [ ] Walk from spawn to the hub and confirm the new district landmarks are readable from roughly 120-200 studs away.
- [ ] Walk the main routes with a humanoid controller and confirm the 22-24 stud roads feel group-friendly and do not snag movement.
- [ ] Trigger the live Strength Forge prompt by hand and complete/cancel a challenge from the enlarged Power district.
- [ ] Fight Lesser Slime by hand from the Broken Gate/enemy side and confirm new visuals do not block combat movement.
- [ ] Review phone/device-simulator screenshots for HUD overlap, reward popup readability, minigame panel readability, and route landmark readability.
- [ ] Confirm performance remains acceptable on a mobile target before adding any VFX or Beam pack subset.

Observed checks on 2026-06-29:

- [x] Edit-mode validation found five zone groups, five dominant landmarks, four activity/sign clusters per zone, and six broad road surfaces.
- [x] District floor sizes validated at 150 x 115, 165 x 125, 160 x 120, 195 x 145, and 165 x 125 studs.
- [x] Strength Forge prompt stayed at `(-78, 6.1, -24)`, action text `Train Power +1`, max activation distance `15`.
- [x] Runtime UI check confirmed `RewardPopupGui`, `TrainingStatsHudGui`, `CombatControllerGui`, `InventoryPanelGui`, and `StrengthForgeMinigameGui`.
- [x] Runtime combat check confirmed `CombatService.TryBasicAttack` reduced Lesser Slime health from `42` to `30`.
- [x] Studio capture tool succeeded for one hub baseline and timed out for the remaining requested coverage.

## Phase 0.1 Training Zone Visual Delta Pass

Visual correction pass completed on 2026-06-29:

- [x] Required visual docs, recreation spec, asset notes, tracker, known issues, AGENTS instructions, master spec, architecture, decision log, and project summary were reviewed.
- [x] Studio instance `Place1.rbxl` was listed and set active.
- [x] Current `Phase0TrainingZoneRecreation` was inspected before changes.
- [x] Current screenshot `phase01_current_power` was captured.
- [x] Visual delta list and top-three fixes per zone were recorded in `docs/roblox/training_zone_visual_delta_2026-06-29_phase01.md`.
- [x] `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation.Phase01VisualDeltaPass` was created as a grouped, replaceable primitive overlay.
- [x] Strength Forge received larger forge/furnace/anvil/side-area silhouettes.
- [x] Guardian Grove received a larger life tree, crystal, protective roots, shield stones, and green identity markers.
- [x] Skyward Tower received a much taller spire/top crystal, vertical accents, route markers, and clearer side activity silhouettes.
- [x] Heroes' Track received a larger timer gate, stronger oval/lane markers, start line, spectator stand, and water station.
- [x] Arcane Shrine received a larger orb/rings, clearer rune pad, larger sign, and taller crystal pillars.
- [x] New correction overlay contains 0 scripts, 0 LocalScripts, 0 ModuleScripts, 0 remotes, 0 bindables, 0 particles, 0 beams, 0 trails, 0 collidable parts, and 0 unanchored parts.
- [x] No Creator Store quarantine asset, blocked sword asset, full VFX pack, or beam pack was moved live.
- [x] Strength Forge prompt remained enabled and unchanged at `(-78, 6.1, -24)`.
- [x] Studio Play mode started after changes.
- [x] Player could spawn and be moved through central, Power, Vitality, Agility, Endurance, and Control route samples.
- [x] Strength Forge minigame start/cancel path still worked.
- [x] Stats HUD, combat HUD, inventory UI, minigame UI, and reward popup existed in `PlayerGui`.
- [x] Reward popup displayed a server-fired `Visual Check` payload.
- [x] Lesser Slime spawned and a server-authoritative basic attack reduced health from 42 to 30.
- [x] Console output showed only the expected unpublished-place DataStore warning.
- [x] Studio Play mode stopped after verification.
- [ ] Save the Roblox place in Studio.
- [ ] Capture manual after screenshots for Strength Forge, Guardian Grove, Skyward Tower, Heroes' Track, Arcane Shrine, HUD, and reward popup because MCP `screen_capture` timed out after `phase01_current_power`.
- [ ] From the central hub, verify that Power chimney beacons, Guardian life tree, Skyward spire, Heroes' Track timer gate, and Arcane orb/rings are readable from roughly 120-200 studs.
- [ ] Walk the main roads and confirm the new overlay does not snag movement or narrow group routes.
- [ ] Review phone/device-simulator screenshots for Neon intensity, landmark readability, and HUD overlap.
- [ ] If the missing `roblox/assets/reference/roblox/training_zones/` images are added, run a focused visual comparison against them.

Observed checks on 2026-06-29:

- [x] Edit-mode validation found `Phase01VisualDeltaPass` with 517 descendants, 468 BaseParts, 4 PointLights, and 134 Neon parts.
- [x] Tallest new landmark tops: Power ~99.5 studs, Vitality ~91 studs, Agility ~173 studs, Endurance ~40.5 studs, Control ~74.4 studs.
- [x] Runtime route, Strength Forge, HUD, reward popup, and Lesser Slime checks passed.
- [x] Current/after screenshot attempts after `phase01_current_power` timed out through the Studio MCP screenshot tool.

## Phase 0.2 Training Zone Visual Salvage Pass

Visual salvage pass completed on 2026-06-29:

- [x] Required Roblox docs, visual direction, recreation spec, Phase 0.1 delta, tracker, decision log, known issues, manual checklist, asset notes, project summary, and reference folder were reviewed.
- [x] Studio instance `Place1.rbxl` was listed and set active.
- [x] Studio Edit tree was inspected before visual changes.
- [x] Player-height before captures were saved for spawn/plaza and Power approach.
- [x] Visual audit was recorded in `docs/roblox/training_zone_visual_audit_2026-06-29_phase02.md`.
- [x] Previous visual-only layers were hidden/de-emphasized: `ReferenceSpacingBlockout`, `Phase0VisualScalePolish`, and `Phase0TrainingZoneRecreation`.
- [x] `Workspace.AscensionGrounds.Phase02VisualSalvagePass` was created as a grouped, replaceable, primitive-only visual layer.
- [x] New active layer uses broad town-scale routes, larger district spacing, calmer landmarks, and reduced Neon.
- [x] Existing Strength Forge and Training Dummy prompts remained enabled and unchanged.
- [x] No gameplay systems, rewards, stats, combat, inventory, economy, enemy logic, remotes, server authority, minigames, or React files were changed.
- [x] Studio Play mode started after changes.
- [x] Raycasts hit the new Phase 0.2 spawn road, central plaza, Broken Gate road, Power, Vitality, Agility, Endurance, and Control surfaces.
- [x] Player could be moved through spawn road, central plaza, Power prompt yard, Power district, Vitality grove, Agility tower, Endurance track, Control shrine, and enemy route samples.
- [x] Strength Forge minigame start/cancel path still worked.
- [x] Stats HUD, combat HUD, inventory UI, minigame UI, and reward popup existed in `PlayerGui`.
- [x] Reward popup displayed a server-fired `Visual Check` payload.
- [x] Lesser Slime spawned and a server-authoritative basic attack reduced health from 42 to 30.
- [x] Console output showed only the expected unpublished-place DataStore warning.
- [x] Studio Play mode stopped after verification.
- [ ] Save the Roblox place in Studio.
- [ ] After saving and reopening Studio, confirm `Workspace.AscensionGrounds.Phase02VisualSalvagePass` persists and older visual layers remain hidden/de-emphasized.
- [ ] Capture manual player-height screenshots from spawn, central plaza, road approach, and inside each district.
- [ ] Confirm from spawn/plaza that the world feels larger and no longer reads as a tiny floating board.
- [ ] Confirm Strength Forge, Guardian Grove, Skyward Tower, Heroes' Track, and Arcane Shrine are readable from roughly 120-200 studs.
- [ ] Confirm roadside signs do not block the player-height approach view.
- [ ] Walk the 32-34 stud main roads with a humanoid controller and confirm they support groups without snagging.
- [ ] Trigger the live Strength Forge prompt by hand and complete or cancel a challenge.
- [ ] Fight Lesser Slime by hand from the Broken Gate/enemy side and confirm the new visuals do not block combat movement.
- [ ] Review phone/device-simulator screenshots for HUD overlap, reward popup readability, minigame panel readability, neon intensity, and route landmark readability.
- [ ] Confirm performance remains acceptable on a mobile target before adding any VFX or Beam pack subset.

Observed checks on 2026-06-29:

- [x] Edit-mode validation found `Phase02VisualSalvagePass` with 306 BaseParts, 54 collidable floor/road parts, 6 lights, 26 Neon parts, 0 thin Neon parts, 0 unanchored parts, 0 scripts, 0 remotes, 0 particles, 0 beams, and 0 trails.
- [x] Previous visual-only layers had 0 collidable parts after the salvage pass.
- [x] Before captures saved: `phase02_before_spawn_plaza`, `phase02_before_power_approach`.
- [x] After captures saved: `phase02_after_spawn_plaza`, `phase02_after_power_approach`, plus a pre-fix `phase02_after_vitality_approach` showing the sign-placement issue that was corrected.
- [x] Guardian before, fixed Vitality after, and fixed Power recaptures timed out through Studio MCP `screen_capture`.

## Phase 0.3 Environmental Animation and Feedback Pass

Environmental motion pass completed on 2026-06-29:

- [x] Required Roblox docs, visual direction, recreation spec, visual asset setup notes, progression tracker, known issues, decision log, manual checklist, AGENTS instructions, architecture, master spec, project summary, and reference folders were reviewed.
- [x] Studio instance `Zero` was listed and set active.
- [x] Studio Edit tree was inspected before animation changes.
- [x] `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Effects.TrainingWorldVisualAnimator` was added as a reusable client-only visual controller.
- [x] `Workspace.AscensionGrounds.Phase03EnvironmentalFeedback` was created as a grouped, replaceable primitive/light/particle visual layer.
- [x] Central plaza received crystal pulse, soft bloom, floating shards, and slow ring motion.
- [x] Strength Forge received furnace flicker, heat glow, sparks, pulsing training pad, idle hammer motion, and prompt/challenge feedback hooks.
- [x] Guardian Grove received heartstone/tree glow pulse, shield halo motion, healing pool shimmer, and mote particles.
- [x] Skyward Tower received beacon pulse, route marker glow, slow halo motion, and moving banners.
- [x] Heroes' Track received lap gate light pulses, start-line pulse, flag/banner motion, and water-station shimmer.
- [x] Arcane Shrine received orb pulse, controlled slow ring rotation, rune-floor shimmer, and soft arcane motes.
- [x] Existing gameplay systems, stats, rewards, combat, inventory, economy, enemy logic, remotes, server authority, minigames, and React files were not changed.
- [x] No Creator Store quarantine asset, blocked sword asset, full VFX pack, or beam pack was moved live.
- [x] Studio Play mode started after changes.
- [x] Client animator reported ready, saw all expected animation tags, and moved a tagged central ring locally.
- [x] Player could be moved through spawn road, central plaza, Power prompt yard, Power district, Vitality grove, Agility tower, Endurance track, Control shrine, and enemy route samples.
- [x] Strength Forge minigame start/cancel path still worked.
- [x] Stats HUD, combat HUD, inventory UI, minigame UI, and reward popup GUI existed in `PlayerGui`.
- [x] Server-fired reward display payload reached the reward popup title as `Visual Check`.
- [x] Lesser Slime spawned and a server-authoritative basic attack reduced health from 42 to 30.
- [x] Console output showed only the expected unpublished-place DataStore warning.
- [x] Studio Play mode stopped after verification.
- [ ] Save the Roblox place in Studio.
- [ ] After saving and reopening Studio, confirm `Workspace.AscensionGrounds.Phase03EnvironmentalFeedback` and `ZeroToHeroClient.Effects.TrainingWorldVisualAnimator` persist.
- [ ] Walk from spawn through the central plaza and confirm crystal/shard motion is visible but restrained from player height.
- [ ] Trigger the live Strength Forge prompt by hand and confirm the training pad/forge accents pulse on prompt show, challenge start, and challenge cancel without granting client-side rewards.
- [ ] Walk each district and confirm at least two ambient animations are noticeable from player height.
- [ ] Confirm animated decorative parts remain non-collidable and do not block group routes.
- [ ] Confirm particle/flicker intensity is comfortable on low/mobile graphics settings.
- [ ] Confirm no new console errors appear during a 3-5 minute free-roam pass.
- [ ] Confirm no client visual script can grant XP, rewards, currency, loot, stats, profile data, or inventory changes.

Observed checks on 2026-06-29:

- [x] Edit-mode validation found `Phase03EnvironmentalFeedback` with 168 BaseParts, 8 lights, 3 ParticleEmitters, 14 Neon parts, 0 collidable parts, 0 unanchored parts, 0 scripts, 0 LocalScripts, 0 ModuleScripts, 0 remotes, and 0 bindables.
- [x] Animation tags validated: 27 pulse, 12 float, 16 rotate, 2 flicker, 3 particle, 2 prompt feedback, and 3 challenge feedback objects.
- [x] Strength Forge prompt remained enabled at `(-78, 6.1, -24)`, action text `Train Power +1`, max activation distance `15`.
- [x] Client motion probe confirmed central ring motion with `0.349` studs position delta and `0.105` look-vector delta.
- [x] Still captures saved: `phase03_spawn_view`, `phase03_power_view`, `phase03_vitality_view`, `phase03_agility_view`, `phase03_endurance_view_clear`, and `phase03_control_view_clear`.
