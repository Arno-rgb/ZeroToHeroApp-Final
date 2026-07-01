# Roblox Known Issues

## Open

### R3 animation and audio assets need owner approval

R3's implementation pass added client-only target and hit presentation, but the roadmap also calls for owner-approved idle/equip/swing animations and bounded combat audio. No approved `AnimationId` or `SoundId` values were present in repo docs, source, Studio source, or current reference files during the 2026-07-01 pass, so no arbitrary marketplace or built-in audio/animation assets were added.

Impact: attacks now read more clearly through target panel, highlight, damage float, swing trail, impact burst, and local hit recoil, but the full R3 acceptance criteria for animation and sound are not complete.

Next step: owner supplies or approves animation/audio asset IDs, or explicitly accepts the current no-asset visual-only R3 subset. Then rerun the R3 server/client regression and hands-on desktop/mobile combat review.

### R3 combat presentation needs hands-on desktop/mobile review

Studio MCP validation confirmed the R3 target panel, server-approved damage float, impact burst, swing trail, stats-HUD suppression, cooldown rejection, and absence of legacy overlays. MCP checks do not prove final player-camera feel, touch ergonomics, target panel placement, impact readability, or HUD overlap on real desktop/mobile viewports.

Impact: the presentation path is technically verified, but final R3 signoff should wait for hands-on combat review.

Next step: save the place, fight Stone Shell and Lesser Slime from desktop and touch/mobile views, confirm target panel placement is readable, confirm the damage float/impact/trail/recoil feel restrained, and confirm reward popup, combat HUD, inventory button, and stats-HUD suppression do not create confusing overlap.

### Phase 6.2 Break scope requires owner review

Phase 6.2 Break was implemented from the internal milestone prompt system, but the owner did not explicitly request that mechanic and flagged it as scope creep.

Impact: Break should not be extended, used as a dependency for Brakk, or treated as accepted MVP scope. R0 Roadmap and Scope Recovery recorded Break as unapproved / needs owner review. R1 now preserves the code but disables active Break runtime behavior behind `FeatureFlags.BreakSystemEnabled = false`.

Next step: follow `docs/roblox/future_milestone_review_2026-06-30.md` in order. Do not re-enable, extend, redesign, or remove Break unless the owner explicitly approves a future milestone for that.

### R1 no-Break Stone Shell needs hands-on readability review

R1 disabled Break in normal Play mode and Studio MCP checks verified that Stone Shell spawns without Break values, BreakState, Break UI, or Broken/Vulnerable transitions while still moving, attacking, taking damage, dying, and granting rewards. MCP checks do not prove final player-camera readability, touch ergonomics, or HUD/popup overlap during a hands-on fight.

Impact: the server behavior is verified, but player-facing signoff for Stone Shell after Break removal still needs desktop and mobile review.

Next step: save the place, fight Stone Shell from desktop and touch/mobile views, confirm no Break meter or hidden Break UI space appears, and verify combat HUD plus reward popup remain readable.

### Phase 6.2 Break system needs hands-on readability review

Phase 6.2 added a server-owned Break meter, Broken state, temporary vulnerability, recovery, and a Stone Shell billboard Break indicator. R1 disabled this path by default, but the preserved implementation still needs hands-on review before any future re-enable. Studio Edit-mode and Play-mode server checks for the old enabled path passed, including distinct health/Break damage fields, Break meter fill, one Broken transition, vulnerable damage multiplier, and recovery reset. MCP checks cannot prove player-facing timing feel, Break indicator readability during movement, touch ergonomics, or HUD overlap during real combat.

Impact: the preserved Break behavior is not active now, but it must not be accepted or reintroduced without hands-on mouse/keyboard and touch/mobile fights against Stone Shell.

Next step: only if the owner approves re-enabling Break, save the place, fight Stone Shell from a player camera with Break enabled, confirm the Break label/bar is readable, confirm Broken vulnerability feels noticeable without being confusing, confirm recovery timing is understandable, and verify combat HUD/reward UI remain readable on phone and desktop viewports.

### Phase 6.1 enemy set needs hands-on combat readability review

Phase 6.1 added `GateHound`, `StoneShell`, and `GateSentinel` through the canonical enemy framework. Studio Edit-mode and Play-mode server checks passed, including spawn checks, damage reduction, Sentinel guard state, reward-once behavior, and expected console output. MCP checks cannot prove final player feel, touch ergonomics, telegraph readability under real camera motion, or mobile HUD overlap during multi-enemy combat.

Impact: the server-owned enemy behavior is verified, but final acceptance for combat feel should include hands-on mouse/keyboard and touch/mobile fights against each new enemy.

Next step: save the place, fight Gate Hound, Stone Shell, and Gate Sentinel from a player camera, confirm their roles are readable, confirm red attack telegraphs and Sentinel guard telegraph are visible before damage/reduction, and verify reward popups and combat HUD remain readable on phone and desktop viewports.

### Phase 0.3 environmental motion needs mobile hands-on review

The Phase 0.3 pass added `Workspace.AscensionGrounds.Phase03EnvironmentalFeedback` plus the client-only `TrainingWorldVisualAnimator` controller. Edit-mode and Play-mode checks passed, and still captures were saved for spawn, Power, Vitality, Agility, Endurance, and Control, but still images cannot prove final motion comfort, flicker intensity, particle readability, or mobile performance.

Impact: the environmental animation layer is safe by inspection and runtime checks, but final visual signoff should wait for hands-on player-height review on a mobile/device-simulator target.

Next step: save the place, walk through all five districts from a real player camera, trigger Strength Forge prompt/challenge start/cancel, and confirm pulse/flicker/particle motion remains readable and restrained on mobile graphics settings.

### Phase 0.2 visual salvage needs full manual screenshot signoff

The Phase 0.2 salvage pass added `Workspace.AscensionGrounds.Phase02VisualSalvagePass` and hid/de-emphasized the older visual-only layers to reduce the tiny diorama/neon-clutter read. Edit-mode and Play-mode checks passed, and player-height captures were saved for spawn/plaza and Power approach, but Studio MCP `screen_capture` still timed out for several required district views.

Impact: the active town read is much calmer and larger by inspection, but full visual signoff still needs hands-on player-height screenshots for Guardian Grove, Skyward Tower, Heroes' Track, Arcane Shrine, Broken Gate/enemy route, HUD, reward popup, and low/mobile graphics.

Next step: save the place, then capture manual Studio/device-simulator screenshots from spawn, plaza, each road approach, inside each district, Broken Gate, Strength Forge minigame, HUD, and reward popup. Confirm the roadside signs do not block the view and the broad routes feel navigable from an actual player camera.

### Studio scaffold is not yet mirrored into source files

The open Roblox Studio place already has an exploratory Ascension Grounds scaffold created through MCP. The new `roblox/` source foundation is ready, but the Studio place and source tree have not yet been fully reconciled.

Current state: milestone 1.1 added `StatConfig` to both source and Studio, milestone 1.2 added `PlayerProfileModel` to both source and Studio, milestone 1.3 added `PlayerDataService` to both source and Studio, milestones 2.1 and 2.2 added training services to both source and Studio, milestone 2.3 added the Strength Forge minigame client/server scripts to both source and Studio, milestone 2.4 added the Training Stats HUD plus stat snapshot replication to both source and Studio, milestone 2.5 added the reusable Reward Popup to both source and Studio, milestone 4.1 added `CombatStatConfig` plus `DerivedCombatStats` to both source and Studio, milestone 4.2 added `CombatActionConfig`, `CombatService`, `CombatBootstrap`, and `CombatController` to both source and Studio, milestone 4.3 added `CombatState` replication plus the mobile combat HUD to both source and Studio, milestone 4.4 added `EnemyConfig`, `EnemyService`, `EnemyBootstrap`, and the Lesser Slime reward hooks to both source and Studio, milestone 5.1 added `HeroProgressionConfig`, `HeroProgressionService`, `HeroProgressionBootstrap`, Hero XP carryover leveling, `HeroXPRequired` replication, and Lesser Slime reward routing to both source and Studio, milestone 5.2 added `ItemConfig` to both source and Studio, milestone 5.3 added `InventoryService`, `InventoryBootstrap`, inventory/equipment CombatService integration, and `InventoryPanel` to both source and Studio, milestone 5.4 added `LootTableConfig`, `LootService`, `LootBootstrap`, Lesser Slime loot-table routing, profile material storage, `PlayerDataService.AddMaterial`, and material reward popup rows to both source and Studio, milestone 6.1 updated `EnemyConfig`, `LootTableConfig`, `CombatService`, and `EnemyService` in both source and Studio for Gate Hound, Stone Shell, and Gate Sentinel, milestone 6.2 updated `EnemyConfig`, `CombatActionConfig`, `CombatService`, and `EnemyService` in both source and Studio for Stone Shell Break behavior, and R1 added `FeatureFlags` plus updated `CombatService` and `EnemyService` in both source and Studio to disable Break by default. R2 disabled and tagged Studio-only legacy feedback/combat scripts while retaining `ReplicatedStorage.AscensionRemotes.StatChanged` as a labeled compatibility bridge. Milestone 3.1 formalised the existing Studio-only `Workspace.AscensionGrounds.ReferenceSpacingBlockout` as the accepted top-down greybox layout. Milestone 3.2 added Studio-only `Milestone32ShellDetails` primitive groups under the five district models. Milestone 3.3 added Studio-only `Milestone33TransitionDetails` under the Broken Gate blockout. Phase 0 visual polish added Studio-only `Workspace.AscensionGrounds.Phase0VisualScalePolish` and `ReplicatedStorage.ZeroToHeroAssets.ApprovedVisualAssets.Phase0LowPolyApprovedSubset`; source-controlled UI scripts were also updated and mirrored into the open Studio place. Phase 0 training-zone recreation added Studio-only `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation`. Phase 0.1 visual delta pass added Studio-only `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation.Phase01VisualDeltaPass`. Phase 0.2 visual salvage added Studio-only `Workspace.AscensionGrounds.Phase02VisualSalvagePass` and hid/de-emphasized previous visual-only layers. Phase 0.3 added source-controlled `roblox/src/client/Effects/TrainingWorldVisualAnimator.client.luau`, mirrored it into Studio, and added Studio-only `Workspace.AscensionGrounds.Phase03EnvironmentalFeedback`. Other Studio objects and legacy scripts still exist only in Studio.

Impact: future work should inspect the live Studio tree before changing it and should avoid assuming the source folder fully represents the place.

Next step: complete the milestone 5.1 and 5.3 published rejoin persistence tests plus the remaining 4.2, 4.3, 4.4, 5.1, 5.3, 5.4, 6.1, and 6.2 hands-on combat/HUD/reward/inventory readability checks with the hybrid source-plus-Studio workflow, or explicitly migrate Studio layout/scripts into `roblox/src` if a source-controlled layout pipeline is chosen.

### Phase 0 visual polish needs hands-on mobile screenshot review

The Phase 0 visual pass improved hub scale, Strength Forge, Broken Gate/EnemyArea mood, stats HUD, reward popup, and combat HUD presentation. Studio Play-mode runtime checks passed, but the Studio screenshot tool timed out when capturing the after danger-route view and runtime HUD view.

Impact: runtime tree/state checks show the canonical GUIs still instantiate and the controls have larger touch targets, but final mobile composition should not be considered fully signed off until a hands-on phone or device-simulator screenshot pass is completed.

Next step: run device-simulator or real-device screenshots for the stats HUD, reward popup, combat HUD near Lesser Slime, Strength Forge minigame, and Broken Gate route before finalizing visual composition.

### Training-zone recreation needs manual screenshot coverage

The Phase 0 training-zone recreation pass created large Power, Vitality, Agility, Endurance, and Control districts plus broad routes and landmarks. Phase 0.1 added a targeted visual correction overlay for larger landmarks and stronger reference alignment. Studio Play-mode runtime checks passed, but the Studio `screen_capture` tool remains unreliable: Phase 0 had timeouts after one baseline hub capture, and Phase 0.1 captured only `phase01_current_power` before timing out for Guardian Grove, Skyward Tower, `phase01_after_power`, and `phase01_after_viewport`.

Impact: the world-scale and gameplay checks are verified by Studio inspection and runtime assertions, but full visual signoff should wait for hands-on screenshots from the hub, Strength Forge, Guardian Grove, Skyward Tower, Heroes' Track, Arcane Shrine, Broken Gate/enemy route, HUD, and reward popup.

Next step: capture the remaining views manually in Studio or a device simulator, then compare them against `docs/roblox/training_zone_recreation_spec.md`, `docs/roblox/training_zone_recreation_visual_review_2026-06-29.md`, and `docs/roblox/training_zone_visual_delta_2026-06-29_phase01.md`.

### Training-zone recreation reference images are missing

`docs/roblox/training_zone_recreation_spec.md` names five new training-zone concept image files, but those files were not present under `roblox/assets/reference/roblox` during the pass.

Impact: this pass followed the written scale, layout, color, and acceptance targets plus the existing Roblox reference images, but it could not directly compare against the missing new concept images.

Next step: add the five referenced training-zone concept image files to the repo under the expected reference folder, then run a focused visual comparison pass.

### Quarantined Sword of Darkness contains embedded scripts

`ReplicatedStorage.ZeroToHeroAssets.CreatorStoreQuarantine.Sword of Darkness` was inserted for visual review and contains script/local-script descendants. The Phase 5 health review observed four script/local-script descendants still enabled inside the quarantined asset.

Impact: the asset should not be moved into live gameplay or equipped by players as-is.

Next step: strip it to art-only parts in quarantine, disable/remove its scripts before any further inspection clones, replace it with a safer art-only weapon, or keep using the current primitive sword placeholder.

### Quarantined VFX packs need mobile review

`Free VFX Pack 1 By DogmathPan` and `Beam Texture Pack` are inserted in quarantine and contain many particle, beam, or trail objects.

Impact: they are script-free, but using them directly could hurt mobile performance or create visual noise.

Next step: approve only a small reduced subset for forge glow, stat gain pulses, combat hits, or shrine beams after viewport and Play-mode checks.

### Quaternius art packs still require manual download

The highest-value environment, prop, character, monster, and animation packs from Quaternius remain queued in the manifest because no direct shell-safe download URL was available.

Impact: Codex can use existing primitives, quarantined Creator Store models, and extracted Kenney UI/control/audio packs now, but not those Quaternius assets yet.

Next step: manually download the queued Quaternius packs into the paths listed in `roblox/assets/manifests/manual_downloads.md`, then extract/process them for Studio import.

### R2 retained legacy StatChanged bridge

R2 disabled the active legacy feedback clients and legacy feedback/combat servers, but intentionally retained `ReplicatedStorage.AscensionRemotes.StatChanged` as a labeled compatibility bridge. `TrainingStationService` still contains an optional legacy fire path when this remote exists.

Impact: no active legacy UI consumes the bridge after R2, and Play-mode validation confirmed the legacy training/combat GUIs do not appear. The non-canonical remote name still exists and should not become a foundation for new rewards, combat feedback, or UI.

Next step: when a future approved cleanup removes the optional bridge behavior from `TrainingStationService`, remove or archive `ReplicatedStorage.AscensionRemotes.StatChanged` after a smoke check.

### Combat and loot rewards temporarily use a training-named RemoteEvent

Milestones 4.4, 5.1, and 5.4 send Lesser Slime Hero XP, Gold, item, and material display payloads through `ReplicatedStorage.ZeroToHeroShared.Remotes.TrainingStationReward` because the current `RewardPopup` client listens there and already supports grouped reward rows.

Impact: runtime behavior is server-authoritative and display-only, but the remote name is too narrow for future combat, loot, and campaign rewards.

Next step: introduce a dedicated RewardService or generic reward display RemoteEvent before expanding campaign completion rewards, boss rewards, paid reward presentation, or richer grouped reward claims.

### Loot grants are not yet atomic or durable across reward types

Milestone 5.4 `LootService.GrantLoot` rolls one table and then applies Hero XP/Gold, materials, item creation, reward-key marking, and popup display through multiple service calls. Duplicate reward keys are held in server memory.

Impact: this is acceptable for the current local Lesser Slime path because the table was validated and tested, but a failure after an earlier mutation could leave a partial grant. Session-memory reward keys are also not enough for durable boss, chest, campaign, or mobile claim rewards.

Next step: before boss/chest/campaign rewards rely on this path, add all-or-nothing validation and profile-backed reward claim records for durable rewards.

### Legacy exploratory combat scripts remain in the place

Several Studio scripts still contain older `Strength`/`Coins` assumptions from an exploratory prototype.

Impact: these scripts may confuse future debugging and should not be treated as canonical player-data, training, combat, or economy architecture.

Current state: milestone 2.1 added canonical `TrainingService` and routed `ServerScriptService.AscensionTrainingFeedbackServer` through it. Milestone 2.2 added `TrainingStationBootstrap`, which disables `StrengthForge.server` and `AscensionStrengthForgeTrainingServer` at runtime so the configured station framework owns the forge prompt. Milestone 2.3 changed the canonical Strength Forge path to a server-validated timing minigame. Milestone 2.4 hides the old `AscensionTrainingFeedbackGui.StatsPanel` at runtime. Milestone 2.5 added the canonical `RewardPopup` client script and disabled the legacy reward toast body in Studio. R2 disabled and tagged `AscensionTrainingFeedbackClient`, `AscensionSwordCombatClient`, `AscensionTrainingFeedbackServer`, `AscensionSwordCombatServer`, `AscensionStrengthForgeTrainingServer`, and `EnemyArea.server` in Edit mode with canonical replacement attributes. Milestone 3.3 did not add enemies, but the pre-existing `Workspace.AscensionGrounds.EnemyArea.TrainingDummy` and its prompt still remain as legacy exploratory combat state.

Milestone 4.1 added canonical pure derived-stat formulas but did not wire them into active combat. Milestone 4.2 added canonical `CombatService` and `CombatBootstrap`; the bootstrap runtime-disables `EnemyArea.server` and `AscensionSwordCombatServer` before starting the new combat remotes. Milestone 4.4 added canonical `EnemyService` for Lesser Slime. R2 then made the duplicate script state explicit in Edit mode, but the pre-existing `TrainingDummy` and old script objects still remain in the Studio place because they have not been deleted or source-migrated.

Observed during the Phase 3 health review:

- `PlayerStats.server` is disabled in Edit mode and runtime.
- `StrengthForge.server` is disabled in Edit mode and runtime.
- `AscensionPlayerProfileServer` is disabled in Edit mode and runtime.
- `AscensionStrengthForgeTrainingServer` was enabled in Edit mode but disabled at runtime by `TrainingStationBootstrap`; R2 now disables and tags it in Edit mode.
- `EnemyArea.server` remained enabled during the Phase 3 review and used legacy `Strength`/`Coins`; R2 now disables and tags it in Edit mode.
- `AscensionSwordCombatServer` remained enabled during the Phase 3 review and read legacy `Strength`; R2 now disables and tags it in Edit mode.
- `AscensionTrainingFeedbackClient`, `AscensionSwordCombatClient`, and `AscensionTrainingFeedbackServer` are now disabled and tagged in Edit mode by R2.

Next step: after R2 hands-on desktop and touch/mobile checks pass, either leave the disabled reference scripts in place with attributes or explicitly archive/delete them once the owner approves irreversible cleanup.

### Studio DataStore warning appears in unpublished local play

Play mode currently logs through `PlayerDataService`: `You must publish this place to the web to access DataStore.`

Impact: local Studio play uses session-only stats. This is acceptable for early local testing, but persistence cannot be verified until the place is published and Studio DataStore access is enabled. Milestone 5.1 local checks verified Hero XP, Hero Level, Gold mutation, and reward popups, but `PlayerDataService.SavePlayer(player, true)` returned `false` in the unpublished session. Milestone 5.3 local checks verified item creation, equip, wrong-slot rejection, effective stat updates, and inventory UI snapshots, but inventory/equipment rejoin persistence also remains unverified because the same save call returned `false`. Milestone 5.4 local checks verified loot grants, material storage, item inventory insertion, duplicate reward protection, and popup rows, but loot/material persistence across rejoin is not proven in unpublished Studio.

Next step: run the documented Hero progression and inventory/equipment join/rejoin persistence tests after the place is published and Studio DataStore access is enabled. Add loot/material rejoin coverage when the material system becomes part of a persistence-gated milestone.

### No automated Roblox test runner is configured

The repo has a `roblox/tests/` folder, but no Luau test runner is configured yet.

Impact: early milestones must use pure documented examples and Studio manual tests.

Current state: milestone 4.1 added `roblox/tests/DerivedCombatStats.examples.md` with low, normal, and high stat cases for the pure derived-stat calculator. Milestone 4.2 added `roblox/tests/PlayerCombatController.examples.md` with server assertions and hands-on input checks. Milestone 4.3 added `roblox/tests/CombatHud.examples.md` with runtime tree checks and hands-on HUD checks. Milestone 4.4 added `roblox/tests/LesserSlimeEnemy.examples.md` with runtime tree, reward mutation, duplicate reward, and hands-on checks. Milestone 5.1 added `roblox/tests/HeroProgression.examples.md` with config, direct award, popup, and published rejoin checks. Milestone 5.2 added `roblox/tests/ItemConfig.examples.md` with item count, field, budget, and invalid-item checks. Milestone 5.3 added `roblox/tests/InventoryService.examples.md` with inventory/equipment server assertions, client UI checks, and published rejoin steps. Milestone 5.4 added `roblox/tests/LootService.examples.md` with loot table validation, forced server grant, duplicate reward, popup, and inventory checks. R3 added `roblox/tests/R3CombatPresentationPolish.examples.md` with edit-mode source checks, server combat regression, client presentation regression, and hands-on review steps.

Next step: keep using documented examples for early milestones, then add a lightweight Luau test runner when profile and training modules make automated coverage more valuable.

## Resolved

### Studio CombatController contained an inert legacy body

Resolved in R3. The 2026-07-01 Studio sync replaced `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Controllers.CombatController` with the clean source-controlled `roblox/src/client/Controllers/CombatController.client.luau`. Edit-mode verification confirmed the live source no longer starts with the stale wrapper body and contains the R3 presentation marker.

### Legacy combat feedback client still ran

Resolved in R2. `StarterPlayer.StarterPlayerScripts.AscensionSwordCombatClient` and `ServerScriptService.AscensionSwordCombatServer` are disabled and tagged in Edit mode. Play-mode validation confirmed `AscensionCombatFeedbackGui`, `AscensionRemotes.SwordAttack`, and `AscensionRemotes.SwordCombatFeedback` were not created, while canonical `CombatControllerGui`, `CombatAction`, and `CombatFeedback` remained active.

### Legacy training feedback UI/server still ran

Resolved in R2. `StarterPlayer.StarterPlayerScripts.AscensionTrainingFeedbackClient`, `ServerScriptService.AscensionTrainingFeedbackServer`, and `ServerScriptService.AscensionStrengthForgeTrainingServer` are disabled and tagged in Edit mode. Play-mode validation confirmed `AscensionTrainingFeedbackGui` and `ServerScriptService.AscensionTrainingEvents` were not created, while canonical `TrainingStatsHudGui`, `RewardPopupGui`, and `TrainingStationReward` remained active.

### Break remained active after R0

Resolved in R1. `roblox/src/shared/Config/FeatureFlags.luau` now defaults `BreakSystemEnabled` to `false`; `CombatService` returns zero Break damage while disabled; and `EnemyService` does not create Stone Shell Break values, BreakState, Broken/Vulnerable transitions, or Break billboard UI in normal Play mode. Studio Play-mode validation confirmed Stone Shell still moves, attacks, takes damage, dies, grants rewards, and blocks duplicate rewards with Break disabled.

### Existing profile server was not canonical

Resolved in milestone 1.3. `ServerScriptService.AscensionPlayerProfileServer` is disabled, and `ServerScriptService.ZeroToHeroServer.Services.PlayerDataService` now owns profile loading, session cache, saving, release, and replicated profile values.
