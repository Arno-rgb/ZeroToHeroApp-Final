# Roblox Decision Log

## 2026-07-01 - Keep R3 combat polish client-only and asset-gated

**Decision:**  
Implement the available R3 combat presentation polish only inside the canonical `CombatController` client path, using server-confirmed `CombatFeedback` and replicated enemy health for target panel, highlight, damage float, swing trail, impact burst, and local hit recoil. Replace the stale wrapped Studio `CombatController` source with the clean source-controlled file. Do not add arbitrary animation or audio asset IDs.

**Reason:**  
R3 explicitly allows visual-only polish but requires owner-approved animation IDs. No approved `AnimationId` or `SoundId` values exist in the repo, Studio source, or current docs. Adding random marketplace assets would make acceptance unclear and could introduce licensing, quality, or scope problems. Client-only effects can improve readability now while preserving the server-owned combat contract.

**Impact:**  
Combat damage, cooldowns, Break disabled state, rewards, loot, enemy config, remotes, and mobile control inputs remain unchanged. The client now displays clearer target and hit feedback from already-approved server results. Full R3 acceptance is still blocked until the owner supplies/approves animation and audio assets or explicitly accepts a no-asset visual-only R3.

**Revisit when:**  
Owner-approved idle/equip/swing animation IDs and bounded swing/impact audio assets are provided, or the owner explicitly waives those R3 items and accepts the current visual-only subset.

## 2026-06-30 - Disable legacy feedback paths without deleting them

**Decision:**  
Disable the active top-level legacy training feedback, sword combat, forge prompt, and enemy scripts in Studio, tag each disabled script with its R2 review status and canonical replacement, and keep `ReplicatedStorage.AscensionRemotes.StatChanged` as a labeled compatibility bridge instead of deleting it.

**Reason:**  
R2 needed to reduce future confusion from duplicate clients, duplicate HUDs, duplicate combat remotes, and old `Strength`/`Coins` paths without making irreversible deletions. The canonical systems now cover the active responsibilities: `CombatController` / `CombatService` / `EnemyService` for combat, `TrainingStationService` / `TrainingService` for Strength Forge rewards, `TrainingStatsHud` for stat display, `RewardPopup` for reward display, and `InventoryPanel` / `InventoryService` for inventory snapshots.

**Impact:**  
Play mode should no longer create `AscensionCombatFeedbackGui`, `AscensionTrainingFeedbackGui`, `AscensionRemotes.SwordAttack`, `AscensionRemotes.SwordCombatFeedback`, or `ServerScriptService.AscensionTrainingEvents`. Future work should modify canonical `ZeroToHero` paths only. The retained `AscensionRemotes.StatChanged` bridge is not an active UI path and must not be extended.

**Revisit when:**  
A future cleanup removes the optional legacy `StatChanged` bridge from `TrainingStationService`, a source-controlled Studio cleanup/archive convention exists, or the owner explicitly asks to delete archived legacy scripts/remotes.

## 2026-06-30 - Disable Break through a default-off feature flag

**Decision:**  
Add `ReplicatedStorage.ZeroToHeroShared.Config.FeatureFlags` / `roblox/src/shared/Config/FeatureFlags.luau` and keep `BreakSystemEnabled = false` by default. While this flag is false, `CombatService` reports zero Break damage and `EnemyService` removes Break runtime state/UI from spawned enemies, while the Stone Shell Break config remains preserved in `EnemyConfig` for future owner review.

**Reason:**  
R0 classified Phase 6.2 Break as implemented without direct owner approval. R1 needed to remove Break from the active player experience without deleting recoverable code or destabilising Stone Shell's normal enemy role, loot path, or combat behavior.

**Impact:**  
Normal Play mode no longer creates Stone Shell `Break`, `MaxBreak`, or `BreakState` values, does not show Break billboard UI, and cannot trigger Broken/Vulnerable transitions. Future work must not re-enable Break unless the owner explicitly approves a milestone that changes `BreakSystemEnabled` or replaces this flag strategy.

**Revisit when:**  
The owner explicitly accepts Break as active scope, asks for full Break removal, or a future combat milestone includes a reviewed Break design and hands-on mobile readability requirements.

## 2026-06-30 - Record R0 authority hierarchy and scope gate

**Decision:**  
Use this authority hierarchy for future Roblox work: direct owner instruction in the current task, active owner-approved roadmap, owner-approved milestone specification, current architecture and technical constraints, master game specification, supporting design documents, archived milestone prompts, then idea documents and future concepts. R0 classifies Phase 6.1 enemies as preserved for hands-on review and classifies the Phase 6.2 Break system as unapproved / needs owner review.

**Reason:**  
R0 was requested to stop feature expansion and realign the project before more mechanics are added. The active roadmap says Break was implemented without direct owner approval, while Gate Hound, Stone Shell, and Gate Sentinel should be kept for review rather than expanded.

**Impact:**  
Codex must not infer approval from older prompts, master-spec inclusions, or idea documents. R1 may disable and isolate Break only if the owner explicitly starts R1. Gate Hound, Stone Shell, and Gate Sentinel remain inspectable, but they are not a license to add enemies, Brakk, boss systems, Break extensions, new minigames, roleplay systems, currencies, monetisation, or wider combat depth.

**Revisit when:**  
The owner approves R1, accepts or rejects Break after review, or revises `docs/roblox/future_milestone_review_2026-06-30.md`.

## 2026-06-30 - Follow the owner-controlled future roadmap sequence

**Decision:**  
Use `docs/roblox/future_milestone_review_2026-06-30.md` as the active owner-controlled future roadmap and follow its R0-R23 milestone sequence in order. Treat older numbered prompts in `docs/roblox/codex_progression_prompt_system.md` as archived references unless the active roadmap or direct owner instruction explicitly selects one.

**Reason:**  
The owner updated the future milestone document and confirmed it is the main vision of the game. The previous prompt system led Codex into a combat-heavy Break milestone that was not directly requested, so future work needs a stronger owner-roadmap gate.

**Impact:**  
Future Codex sessions must start with `R0 - Roadmap and Scope Recovery`, then continue only in the documented sequence after each milestone is accepted. Codex must not infer approval for Break, Gatekeeper Brakk, boss rewards, new minigames, skills, guard/dodge, mobile claims, economy systems, roleplay systems, or other mechanics from older prompts, the master spec, or idea docs alone.

**Revisit when:**  
The owner revises the future milestone roadmap or explicitly approves a different active sequence.

## 2026-06-30 - Keep Break state server-owned on enemies

**Decision:**  
Add the first Break system inside `EnemyConfig`, `CombatService`, and `EnemyService`, with Stone Shell as the only Phase 6.2 Break-enabled enemy.

**Reason:**  
Break affects combat power, vulnerability, and progression feel, so the meter, Broken transition, damage multiplier, and recovery need to be owned by server enemy state. The client only receives normal replicated values and a billboard indicator.

**Impact:**  
Future Break enemies should use the same config-driven meter and recovery path before introducing separate boss state machines. `CombatService` now reports `BreakDamage` separately from health `Damage`, allowing future skills or gear to tune Break pressure without bypassing health damage rules.

**Revisit when:**  
Gatekeeper Brakk, multi-phase enemies, stagger animations, or boss/chest rewards need richer state transitions, stronger telegraphs, or durable reward-claim records.

## 2026-06-30 - Keep Phase 6 enemy roles config-driven

**Decision:**  
Add Gate Hound, Stone Shell, and Gate Sentinel through `EnemyConfig`, `EnemyService`, and `LootTableConfig`, with server-owned `DamageTakenMultiplier` attributes for armour and guard states.

**Reason:**  
Phase 6.1 needs distinct prototype enemies without creating per-enemy scripts or starting the later Break/Boss systems early. A shared damage multiplier lets `CombatService` apply Stone Shell armour and Sentinel guard reduction through the canonical server-authoritative player attack path.

**Impact:**  
Future enemy roles should prefer config fields and shared `EnemyService` behavior before adding new services. Break-specific meters and boss phase rewards remain deferred to milestones 6.2 and 6.3.

**Revisit when:**  
Break damage is implemented, enemies need richer state machines, or boss/chest/campaign rewards require durable claim records and a generic reward display service.

## 2026-06-27 - Adopt milestone-gated Codex workflow

**Decision:**  
Use `docs/roblox/codex_progression_prompt_system.md` as the controlled task system for Roblox development.

**Reason:**  
The Roblox game is large enough that broad prompts would create scope creep and inconsistent architecture. The milestone system keeps each task measurable, testable, and stoppable.

**Impact:**  
Future Roblox tasks should update `docs/roblox/progression_tracker.md`, record meaningful decisions here, and avoid starting later systems before the current milestone passes acceptance criteria.

**Revisit when:**  
The first vertical slice is complete and the team needs a broader production roadmap.

## 2026-06-27 - Keep Roblox separate from the mobile app

**Decision:**  
Roblox source and Roblox-specific documentation live under `roblox/` and `docs/roblox/`. The React/Vite mobile app remains in its existing structure.

**Reason:**  
The mobile app is the current sellable coach demo and should not be destabilised by the Roblox build path.

**Impact:**  
Roblox code, assets, and tests should not be mixed into `src/` unless the user explicitly asks for mobile-app integration.

**Revisit when:**  
Real mobile-to-Roblox account linking is ready to be implemented.

## 2026-06-27 - Training stats start at 0 earned value

**Decision:**  
Players start with 0 earned training stat value.

**Reason:**  
The product promise is that training creates stats. Starting at non-zero stats weakens that first emotional reward.

**Impact:**  
Profile, UI, formulas, and reward displays must communicate that the player earns Power, Vitality, Agility, Endurance, and Control through training.

**Revisit when:**  
Balancing proves that a non-zero hidden baseline is required for combat readability. If that happens, the UI should still show earned training value separately.

## 2026-06-27 - Centralise training stat definitions in StatConfig

**Decision:**  
Use `roblox/src/shared/Config/StatConfig.luau` and the matching Studio ModuleScript at `ReplicatedStorage.ZeroToHeroShared.Config.StatConfig` as the shared source of truth for Power, Vitality, Agility, Endurance, and Control.

**Reason:**  
The same stat IDs, display metadata, XP curve, colour data, placeholders, and derived-stat responsibilities must be reused by server and client code without hardcoded copies.

**Impact:**  
New Roblox profile, training, combat, and UI work should require `StatConfig` instead of defining its own five-stat arrays or XP formulas. The current newer Studio profile, training feedback, and stats UI scripts now consume the module.

**Revisit when:**  
Balancing changes the XP curve, Roblox UI receives a formal design-token system, or Rojo sync becomes the only source-of-truth workflow for Studio scripts.

## 2026-06-27 - Define v1 player profile model before data service

**Decision:**  
Use `roblox/src/shared/Types/PlayerProfileModel.luau` and the matching Studio ModuleScript at `ReplicatedStorage.ZeroToHeroShared.Types.PlayerProfileModel` as the canonical v1 profile contract.

**Reason:**  
The project needs one pure default schema before persistence, training rewards, inventory, equipment, and claims mutate valuable state. Keeping the model pure makes it testable without DataStore access.

**Impact:**  
The Player Data Service milestone should create, validate, repair, migrate, cache, load, and save profiles through this model. Training stats are represented as Level, XP, and EffectiveValue fields and still start at zero earned value.

**Revisit when:**  
DataStore persistence, item instances, mobile claim records, or campaign progression require a versioned schema migration.

## 2026-06-27 - Make PlayerDataService the owner of profile state

**Decision:**  
Use `roblox/src/server/Services/PlayerDataService.luau` and the matching Studio module at `ServerScriptService.ZeroToHeroServer.Services.PlayerDataService` as the server-authoritative owner of profile loading, session caching, mutation, replicated profile values, saving, and release.

**Reason:**  
Profile state must not be owned by client UI, replicated IntValues, or one-off gameplay scripts. A single server service reduces duplicate mutation paths and provides one place for DataStore failure handling.

**Impact:**  
Future training, combat, inventory, economy, reward claim, and profile persistence work should mutate player data through `PlayerDataService` APIs. The old `AscensionPlayerProfileServer` Studio script is disabled. Milestone 1.3 temporarily routed the training feedback bridge through `PlayerDataService.AddTrainingStatValue`; milestone 2.1 replaced that bridge with `TrainingService.AwardTrainingXP`.

**Revisit when:**  
The project adopts a profile library, adds cross-server locking, or needs conflict resolution for simultaneous sessions.

## 2026-06-27 - Separate asset intake into downloadable and Creator Store lanes

**Decision:**  
Use `roblox/assets/manifests/download_queue.md` for official downloadable Quaternius/Kenney packs and `roblox/assets/manifests/creator_store_insert_plan.md` for Roblox Creator Store assets that must be inserted through Studio.

**Reason:**  
Downloadable CC0 packs can be preserved as raw archives under `roblox/assets/raw/` and processed locally, while Creator Store assets must not be scraped into the repo and need Studio quarantine plus script inspection before use.

**Impact:**  
The Ascension Grounds MVP asset pass can preserve source URLs, licences, and local paths without mixing trusted local downloads with uninspected Creator Store models. Any imported Creator Store asset must remain quarantined until it is inspected and reduced to approved art-only subsets.

**Revisit when:**  
The first approved asset subset has been imported into Studio and the team decides whether to package assets through Rojo-managed source, Roblox Packages, or another Studio-first workflow.

## 2026-06-27 - Make TrainingService the owner of training XP application

**Decision:**  
Use `ServerScriptService.ZeroToHeroServer.Services.TrainingService` and `roblox/src/server/Services/TrainingService.luau` as the server-side owner for training XP awards, level-up application, diminishing returns, daily training totals, and structured training reward results.

**Reason:**  
Training progression needs one controlled path before station framework and minigames are added. Direct stat-value increments cannot support XP curves, multiple level-ups, deterministic diminishing returns, or reward results.

**Impact:**  
Future training stations and minigames should call `TrainingService.AwardTrainingXP` from server code. Clients may display approved results but must not submit final XP or level values. `PlayerDataService` remains the owner of cached profile mutation and persistence.

**Revisit when:**  
Training rank balancing needs a formal formula, daily reset logic needs timezone/player-local handling, or an automated Luau test runner is added.

## 2026-06-27 - Use configurable server-owned training stations

**Decision:**  
Use `TrainingStationConfig` for station definitions and `TrainingStationService` for ProximityPrompt binding, distance validation, cooldown validation, server reward calls, reward callbacks, and curated client reward events.

**Reason:**  
Training stations need a reusable path before the Strength Forge minigame is built. A station config lets Power, Vitality, Agility, Endurance, and Control stations share the same server validation instead of accumulating one-off scripts.

**Impact:**  
Future station milestones should add config entries and server-owned minigame result validation instead of creating separate award scripts. The old one-off forge award scripts are disabled at runtime by `TrainingStationBootstrap`.

**Revisit when:**  
The Strength Forge minigame needs server-issued challenge state, the other four stations need unique rules, or legacy Studio scripts are fully migrated into source.

## 2026-06-27 - Validate Strength Forge timing on the server

**Decision:**  
Use server-issued Strength Forge challenge IDs, server-synchronized timing, and `TrainingStationAction` submit/cancel requests instead of letting the client report timing accuracy or reward multipliers.

**Reason:**  
Power XP is valuable progression. The client can animate the marker and collect input, but the server must own target zones, timing windows, success counts, accuracy, reward multiplier caps, and cooldowns.

**Impact:**  
`TrainingStationService` now blocks direct activation of minigame stations with `MinigameRequired` unless the call comes from a server-validated challenge. The new `StrengthForgeMinigame` LocalScript is presentation/input only.

**Revisit when:**  
Latency compensation needs formal tuning, other station minigames need different validation rules, or a shared minigame challenge service becomes worthwhile.

## 2026-06-27 - Replicate HUD-safe training stat snapshots

**Decision:**  
Expose HUD data through server-generated `player.TrainingStats` folders containing `Level`, `XP`, `XPRequired`, and `EffectiveValue` IntValues, plus `Profile.TrainingRank`, instead of letting the client inspect server profile tables.

**Reason:**  
The Stats HUD needs level and XP details, but profile state remains server-owned. A narrow replicated snapshot gives the UI enough approved display state without creating a client write path for valuable progression.

**Impact:**  
`TrainingStatsHud` reads only replicated values and `StatConfig` display metadata. Future stat UI, reward UI, and combat previews should reuse this replicated snapshot for presentation while keeping mutations inside server services.

**Revisit when:**  
Profile replication needs privacy filtering per player, broader UI state snapshots become necessary, or a dedicated replication service replaces direct PlayerDataService value folders.

## 2026-06-27 - Use a canonical client reward popup queue

**Decision:**  
Use `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.UI.RewardPopup` and `roblox/src/client/UI/RewardPopup.client.luau` as the client-side presentation owner for approved reward payloads from `TrainingStationReward`.

**Reason:**  
Reward feedback now needs to support more than one temporary training toast. A single queued popup keeps Strength Forge, future Hero XP, Gold, item drops, rarity treatment, and level-up emphasis visually consistent while the server remains the only owner of valuable rewards.

**Impact:**  
Future reward-producing server systems should send curated display payloads through a canonical server-owned reward event or a future RewardService event, then let the client popup normalize presentation. The legacy `AscensionTrainingFeedbackClient` reward toast is disabled in Studio to avoid duplicate reward overlays.

**Revisit when:**  
A dedicated server RewardService is introduced, combat/loot rewards need richer grouped payloads, or the legacy exploratory feedback script is fully removed from the place.

## 2026-06-28 - Treat existing layout blockout as exploratory until 3.1

**Decision:**  
`Workspace.AscensionGrounds.ReferenceSpacingBlockout` may be used as a starting point for milestone 3.1, but it is not considered accepted Phase 3 work until it is checked against the 3.1 Top-Down Layout criteria.

**Reason:**  
The Studio place contains plaza, district, road, and Broken Gate blockout objects that are ahead of the current tracker. The milestone workflow requires reviewing and accepting one milestone at a time rather than assuming earlier exploratory objects satisfy the spec.

**Impact:**  
The next Roblox task should inspect the existing blockout before adding objects, preserve useful named models when they fit the spec, and only adjust the smallest missing pieces needed for 3.1. Future docs must record whether that Studio-only layout is formalised, replaced, or migrated into source.

**Revisit when:**  
Milestone 3.1 acceptance criteria pass or the team decides to migrate Studio-created layout objects into a source-controlled representation.

## 2026-06-28 - Formalise ReferenceSpacingBlockout for top-down layout

**Decision:**  
Use the existing `Workspace.AscensionGrounds.ReferenceSpacingBlockout` as the accepted milestone 3.1 greybox layout instead of creating duplicate plaza, road, district, or Broken Gate objects.

**Reason:**  
MCP inspection showed the blockout already satisfies the 3.1 requirements: central plaza, blue crystal, five district paths, the live Strength Forge, four placeholder district models, one Broken Gate route, wide single-floor roads, and modular named models. Rebuilding it would add duplication without improving the milestone.

**Impact:**  
Milestone 3.2 should build district shells on top of this accepted blockout. Future layout work should preserve the named groups unless a later milestone explicitly replaces them. The Studio layout is still not mirrored into source files.

**Revisit when:**  
The project chooses a source-controlled layout pipeline, a viewport playtest shows the hub is not readable from the central plaza, or milestone 3.2 needs structural changes to fit district shells.

## 2026-06-28 - Add grouped primitive district shell details

**Decision:**  
Add a small `Milestone32ShellDetails` model inside each accepted district model instead of replacing the existing 3.1 blockout or importing final art assets.

**Reason:**  
The accepted blockout already established district positions, road mouths, and the live Strength Forge station. Nested primitive detail groups strengthen the five required silhouettes while keeping the layout modular, low-cost, and easy to remove or replace later.

**Impact:**  
Milestone 3.2 visual shell work remains Studio-authored under `Workspace.AscensionGrounds`. All new shell detail parts are anchored and non-collidable so they do not affect navigation or the Strength Forge prompt. Later art passes can replace these groups without touching training progression scripts.

**Revisit when:**  
The project adopts a source-controlled layout pipeline, a hands-on walk test shows a shell detail blocks player movement or readability, or final art assets are approved for import.

## 2026-06-28 - Build Broken Gate transition as grouped primitive overlay

**Decision:**  
Add `Milestone33TransitionDetails` under the existing Broken Gate blockout instead of replacing the accepted 3.1 layout, editing combat scripts, or adding new enemy models.

**Reason:**  
Milestone 3.3 is a visual transition milestone. A grouped primitive overlay can create a readable safe-to-danger threshold with dark stone, red lighting, ruin shapes, and a bossward route while preserving the hub layout and keeping future combat work separate.

**Impact:**  
The safe hub and central social area remain unchanged. The transition adds three wide collidable route surfaces and keeps decorative details non-collidable. The pre-existing `Workspace.AscensionGrounds.EnemyArea.TrainingDummy` remains legacy placeholder state and was not expanded.

**Revisit when:**  
Combat milestones define the canonical enemy-area layout, a hands-on walk test shows the route feels too narrow or visually noisy, or the project migrates Studio-authored layout objects into source control.

## 2026-06-28 - Start combat foundation with pure formulas, not legacy combat scripts

**Decision:**  
Proceed to milestone 4.1 by adding shared derived-combat-stat formulas in source, while treating the current `EnemyArea.server` and `AscensionSwordCombatServer` scripts as legacy risks that must not become the canonical combat foundation.

**Reason:**  
The Phase 3 health review showed that the greybox layout and training progression can support the next step, but the existing enabled combat scripts still use old `Strength`/`Coins` assumptions. Milestone 4.1 can safely proceed because it is pure formula work and does not need to extend those scripts.

**Impact:**  
Milestone 4.1 should create source-controlled shared formula/config modules and tests. Milestone 4.2 should migrate or disable the legacy combat scripts when the canonical player combat controller is introduced.

**Revisit when:**  
Combat controller work starts, derived-stat formulas need balancing, or the legacy combat scripts are fully replaced by a canonical `CombatService`.

## 2026-06-28 - Keep derived combat stats pure and source-controlled

**Decision:**  
Use `CombatStatConfig` plus `DerivedCombatStats` as shared, pure modules for derived combat values. The calculator accepts training stats, hero level, equipment bonus maps, and class modifiers, then returns final stats with separate base, hero-level, training, equipment, and class contribution tables.

**Reason:**  
Combat, HUD previews, enemies, and equipment comparison will need the same deterministic stat math. Keeping equipment resolution outside the calculator lets future server services aggregate equipped item bonuses without coupling formula math to inventory storage or legacy combat scripts.

**Impact:**  
Future combat code should require `ReplicatedStorage.ZeroToHeroShared.Utility.DerivedCombatStats` instead of duplicating formulas. Server systems remain responsible for validating profile state, equipped items, and damage application. Movement speed and critical chance are capped in the shared formula layer before any controller applies them.

**Revisit when:**  
Milestone 4.2 wires player combat to canonical server-owned damage, equipment items gain their real stat schema, or balance testing shows the MVP coefficients need tuning.

## 2026-06-28 - Introduce CombatService as the canonical player combat path

**Decision:**  
Use `CombatActionConfig`, `CombatService`, `CombatBootstrap`, and the client `CombatController` as the new canonical player combat path for basic attack, guard, dodge, stamina, cooldowns, target validation, and approved hit feedback.

**Reason:**  
Milestone 4.2 needs server-authoritative action validation before enemies, loot, or rewards are added. The existing legacy combat scripts still use old `Strength` and `Coins` assumptions, so they should be runtime-disabled instead of extended.

**Impact:**  
Future combat, enemy, reward, and HUD work should use `CombatService` APIs and `CombatFeedback` payloads instead of adding direct client damage or mutating legacy dummy scripts. The full combat HUD remains deferred to milestone 4.3.

**Revisit when:**  
Milestone 4.3 builds the combat HUD, milestone 4.4 adds the first server enemy, or equipment and stamina systems require broader combat state replication.

## 2026-06-28 - Replicate combat HUD state through CombatState

**Decision:**  
Use a server-generated `player.CombatState` folder for HUD-safe HP, stamina, cooldown, guard, and dodge state instead of letting the client infer authoritative combat resources.

**Reason:**  
The mobile HUD needs fast display state, but combat resources affect survival and action validity. A narrow replicated snapshot lets the client render bars and cooldown overlays while `CombatService` remains the owner of stamina spend, cooldowns, guard, dodge invulnerability, and damage.

**Impact:**  
Future combat HUD and enemy work should read `CombatState` for presentation and call `CombatService` for mutations. Skill placeholders can become real actions later without changing the HUD authority boundary.

**Revisit when:**  
The first enemy applies real damage, a dedicated combat-state replication service is introduced, or stamina/focus/resolve need richer resource timing.

## 2026-06-28 - Add EnemyService as the server owner of enemy lifecycle

**Decision:**  
Use `EnemyConfig`, `EnemyService`, and `EnemyBootstrap` as the canonical server path for Lesser Slime spawn, health, state transitions, attacks, death, reward-once handling, and respawn.

**Reason:**  
Milestone 4.4 needs one real enemy without extending the legacy `EnemyArea.server` or moving health/reward authority to the client. A dedicated enemy service keeps combat target validation in `CombatService` while keeping enemy AI and reward ownership separate.

**Impact:**  
Future enemies should be added through config and server-owned enemy service logic. Client UI may display approved state, but enemy health, damage, death, respawn, Hero XP, and Gold rewards stay server-owned.

**Revisit when:**  
Multiple enemy types, pooled spawns, server performance profiling, or boss-specific mechanics require a broader enemy manager.

## 2026-06-28 - Temporarily reuse TrainingStationReward for combat reward display

**Decision:**  
Send Lesser Slime Hero XP and Gold presentation payloads through the existing `TrainingStationReward` RemoteEvent because the current `RewardPopup` client already normalizes Hero XP and Gold rows there.

**Reason:**  
Milestone 4.4 should prove the first enemy loop without introducing the full RewardService milestone early. The valuable mutation still happens through `PlayerDataService`; the reused remote is display-only.

**Impact:**  
Combat rewards appear through the existing popup path, but the remote name is semantically too narrow for long-term combat and loot rewards.

**Revisit when:**  
Milestone 5.1 or a dedicated RewardService introduces a generic reward event for training, combat, loot, and campaign rewards.

## 2026-06-28 - Add HeroProgressionService for Hero XP and Gold rewards

**Decision:**  
Use `HeroProgressionConfig` plus `HeroProgressionService` as the canonical server path for Hero XP, Hero Level, Gold reward results, and reward popup payloads. Keep `PlayerDataService` as the owner of cached profile mutation, replicated profile values, and persistence.

**Reason:**  
Milestone 5.1 needs a reward-level service that can be called by enemies, future quest/campaign systems, and future loot systems without duplicating Hero Level math or popup payload construction. Separating reward orchestration from profile storage keeps valuable state server-authoritative while giving gameplay systems a small structured API.

**Impact:**  
Future combat and campaign reward producers should call `HeroProgressionService.AwardRewards`, `AwardHeroXP`, or `AwardGold` instead of mutating Hero XP or Gold directly. Hero XP is stored as carryover XP toward the next Hero Level, and `player.Profile.HeroXPRequired` is replicated for UI display.

**Revisit when:**  
A dedicated RewardService or generic reward event is introduced, Hero Level balance needs a new curve, or equipment drops and mastery rewards need to be grouped with Hero XP and Gold in one reward claim.

## 2026-06-28 - Centralise item definitions and rarity budget validation

**Decision:**  
Use `ReplicatedStorage.ZeroToHeroShared.Config.ItemConfig` and `roblox/src/shared/Config/ItemConfig.luau` as the shared source of truth for the first 15 item definitions, valid slots, valid rarities, trade policies, combat-stat bonuses, and rarity budget validation.

**Reason:**  
Inventory, equipment comparison, loot drops, and reward popups will all need the same item metadata. Defining items before ownership or equip actions keeps milestone 5.2 config-only and prevents future systems from inventing duplicate item IDs, old stat names, or inconsistent rarity budgets.

**Impact:**  
Future inventory, equipment, and loot services should call `ItemConfig` to validate item IDs, slots, rarity, trade policy, and stat bonuses before mutating player-owned inventory. `Strength` and other old permanent stat names are rejected because item bonuses must target combat stat keys from `CombatStatConfig`.

**Revisit when:**  
Milestone 5.3 adds inventory/equipment services, milestone 5.4 adds loot tables, or balance testing shows the first rarity budget caps need adjustment.

## 2026-06-29 - Make InventoryService the owner of item instances and equipment

**Decision:**  
Use `ServerScriptService.ZeroToHeroServer.Services.InventoryService` and `roblox/src/server/Services/InventoryService.luau` as the server-authoritative owner for item instance creation, ownership validation, inspect/compare payloads, equip/unequip actions, equipment bonus aggregation, and inventory snapshots.

**Reason:**  
Owned item instances, equipment slots, and effective stat changes are valuable progression. The client should be able to request presentation actions, but it must not create items, assign slots directly, or choose stat bonuses. Keeping equipment resolution in InventoryService lets CombatService consume a validated bonus map instead of reading raw client state or duplicating inventory rules.

**Impact:**  
Future loot, rewards, and item-drop systems should award items through server code that calls `InventoryService.AddItem`. Future combat and stat previews should use InventoryService snapshots or `GetEquipmentBonusesFromProfile` instead of rebuilding equipment logic. Client inventory UI remains display/input only through `InventoryAction` and `InventorySnapshot`.

**Revisit when:**  
Milestone 5.4 adds loot tables and drops, inventory needs stackable/consumable items, or a broader RewardService needs to group Hero XP, Gold, and item drops in one server-approved claim.

## 2026-06-29 - Route enemy drops through LootService and LootTableConfig

**Decision:**  
Use `ReplicatedStorage.ZeroToHeroShared.Config.LootTableConfig` for reusable drop definitions and `ServerScriptService.ZeroToHeroServer.Services.LootService` as the server-authoritative loot roll/grant path. Lesser Slime now references `LootTableId = "LesserSlime"` instead of carrying ad hoc reward fields.

**Reason:**  
Loot needs weighted item drops, guaranteed Hero XP, optional Gold, placeholder materials, and duplicate reward protection without copying roll logic into every enemy or boss. Keeping item grants routed through `InventoryService` and material/currency/profile mutation routed through `PlayerDataService` preserves the existing valuable-state ownership boundaries.

**Impact:**  
Future enemies and bosses should add or reference loot table IDs rather than implementing their own reward roll code. Reward display can stay grouped through the current popup path for now, but the underlying grant stays server-owned and reusable.

**Revisit when:**  
A dedicated generic RewardService exists, materials become craftable/stackable with richer metadata, or boss/chest loot needs deterministic pity, account-level claims, or multi-player reward distribution.

## 2026-06-29 - Gate Phase 6 behind Phase 5 health review conditions

**Decision:**  
Allow Phase 6.1 to proceed later on the existing `CombatService`, `EnemyService`, `InventoryService`, `HeroProgressionService`, and `LootService` foundations, but do not start Phase 6.1 during the Phase 5 health review. Track legacy client feedback cleanup and durable loot-claim hardening as conditions before the vertical slice grows into boss, chest, campaign, or richer reward flows.

**Reason:**  
The Phase 5 review showed the current server-authoritative path is coherent for adding the next configured enemies, but also surfaced active legacy client UI paths and session-only/non-atomic loot claim behavior that should not quietly become the foundation for boss or campaign rewards.

**Impact:**  
Future enemy work should stay config-driven through the canonical services. Cleanup work should retire `AscensionSwordCombatClient`, evaluate the old training feedback bridge, and harden reward claims before high-value or durable reward systems depend on them.

**Revisit when:**  
The legacy feedback scripts are archived/disabled, a generic RewardService replaces the training-named reward remote, or boss/chest/campaign rewards require profile-backed durable claims.

## 2026-06-28 - Quarantine Creator Store assets before live use

**Decision:**  
Insert Creator Store assets first into `ReplicatedStorage.ZeroToHeroAssets.CreatorStoreQuarantine`, inspect them for scripts, remotes, descendant counts, and VFX cost, and only then move approved art-only subsets into `ApprovedVisualAssets` or live scene models.

**Reason:**  
The visual pass needs richer models and effects, but Creator Store models can include scripts, unexpected behavior, or heavy particle systems. Quarantine keeps the current playable loop safe while still letting Codex inspect and reuse suitable art.

**Impact:**  
LowPoly Asset Pack, R6 Dummy, Free VFX Pack #1, and Beam Texture Pack are available for review. Sword of Darkness remains blocked because it contains embedded scripts/local scripts. Future visual work should prefer local CC0 assets or inspected art-only subsets.

**Revisit when:**  
The approved asset subset is copied into live scene models, a source-controlled asset pipeline is chosen, or a Studio package workflow replaces quarantine-based intake.

## 2026-06-29 - Keep Phase 0 polish as a replaceable visual overlay

**Decision:**  
Add the visual scale pass as `Workspace.AscensionGrounds.Phase0VisualScalePolish` and keep the new environment geometry grouped, anchored, non-collidable, script-free, and replaceable. Copy only five inspected LowPoly art templates into `ReplicatedStorage.ZeroToHeroAssets.ApprovedVisualAssets.Phase0LowPolyApprovedSubset` before placing live clones.

**Reason:**  
The current task is visual alignment and perceived scale, not a gameplay milestone. A named overlay can make the hub, forge, and danger route feel larger while preserving all existing prompts, spawns, enemy logic, combat services, reward services, inventory services, and profile data paths. Using a small approved subset avoids moving whole Creator Store packs or any blocked/scripted asset into live gameplay.

**Impact:**  
Ascension Grounds now has a larger crystal focal point, broader route reads, bigger district silhouettes, a stronger forge silhouette, red danger-route ruins, and LowPoly tree/rock/fence dressing. The LowPoly subset is approved for this visual pass only; Sword of Darkness and the VFX/beam packs remain blocked or quarantined.

**Revisit when:**  
A source-controlled scene/layout pipeline is chosen, mobile screenshots show the overlay is too visually heavy, or final art packs replace the primitive/LowPoly blockout layer.

## 2026-06-29 - Rebuild training districts as a large primitive recreation overlay

**Decision:**  
Add `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation` as a second replaceable Studio-authored visual overlay that rebuilds the five training districts at public-space scale using primitives only. Preserve existing gameplay-critical prompts, anchors, spawns, server services, remotes, HUD scripts, reward paths, enemy logic, combat math, profile data, and minigame reward payloads.

**Reason:**  
The training-zone recreation task is a visual/world-scale pass, not a gameplay milestone. The written recreation spec calls for much larger zone footprints, 22-24 stud routes, dominant zone landmarks, and stronger 120-200 stud readability. A script-free primitive overlay can achieve those scale/readability goals without moving valuable gameplay authority or importing untrusted Creator Store assets.

**Impact:**  
Power, Vitality, Agility, Endurance, and Control now each have a large named district group, dominant landmark, central activity area, secondary activity/sign clusters, broad routes, and distinct color language. The live Strength Forge prompt remains in its old position, the Lesser Slime/enemy path still works, and no blocked or scripted Creator Store asset was moved live for this pass.

**Revisit when:**  
The project chooses a source-controlled scene/layout pipeline, final approved art packs replace the primitive recreation layer, manual mobile screenshots show readability/performance problems, or gameplay design decides to relocate live station anchors into the enlarged districts.

## 2026-06-29 - Keep Phase 0.1 zone corrections as a primitive overlay

**Decision:**  
Add `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation.Phase01VisualDeltaPass` as a focused correction layer instead of editing gameplay objects, importing full Creator Store packs, or replacing the previous recreation build.

**Reason:**  
The Phase 0.1 task asked for visual deltas only: bigger landmarks, stronger color identity, clearer silhouettes, broader readability, and closer adherence to the training-zone spec. A child overlay keeps the correction reversible and inspectable while preserving the unchanged Strength Forge prompt, enemy route, HUD scripts, reward remotes, combat services, profile data, inventory logic, and enemy logic.

**Impact:**  
Each zone now has three targeted corrections: Power has a stronger forge/furnace/anvil/side-area read; Vitality has a larger life-tree/guardian ring; Agility has a much taller tower/spire and route accents; Endurance has a larger track/timer/spectator read; Control has a stronger orb/ring/rune/pillar identity. The overlay uses only primitives, contains no collisions or executable instances, and leaves all existing gameplay systems untouched.

**Revisit when:**  
The missing `training_zones` reference image folder is added, manual screenshots show a remaining visual mismatch, mobile performance review flags the added Neon/part count, or the project migrates Studio-authored visual layers into a source-controlled scene pipeline.

## 2026-06-29 - Build one flagship minigame per training stat first

**Decision:**  
Use one flagship minigame per training zone before adding secondary activities: Forge Strike for Power, Guardian Pulse for Vitality, Skyline Rush for Agility, Pace Trial for Endurance, and Rune Alignment for Control.

**Reason:**  
The five-zone visual pass now provides large readable activity spaces, but building fifteen minigames would spread the project too thin. One flagship per stat gives each district a distinct gameplay identity while reusing server-authoritative training, challenge, and reward patterns.

**Impact:**  
Future training gameplay should extend the current Strength Forge pattern through typed minigame handlers, not through separate one-off reward scripts. Secondary ideas like Titan Lift, Healing Brew, Reaction Dash, Hurdle Circuit, and Orb Guidance remain deferred visual/social hooks until the five flagship minigames work.

**Revisit when:**  
All five flagship minigames are playable, mobile-readable, server-validated, and covered by manual tests.

## 2026-06-29 - Salvage training town by hiding the noisy visual stack

**Decision:**  
Treat Phase 0.2 as a visual-only salvage pass that hides/de-emphasizes `ReferenceSpacingBlockout`, `Phase0VisualScalePolish`, and `Phase0TrainingZoneRecreation`, then adds `Workspace.AscensionGrounds.Phase02VisualSalvagePass` as the active replaceable town-scale layer. Preserve live gameplay prompts, enemy objects, HUD scripts, reward remotes, server services, stats, combat, inventory, economy, and React app files.

**Reason:**  
The current player-height view read as a tiny floating diorama because multiple overlays stacked hundreds of thin Neon parts, signs, rings, and small props in the same camera space. Continuing to decorate that stack would make visual noise worse. A calmer layer with fewer, larger masses, 32-34 stud roads, broader district spacing, and one dominant landmark per zone better matches the reference scale/readability target while keeping gameplay stable.

**Impact:**  
The active visual read now comes from a primitive, script-free Phase 0.2 layer with 306 BaseParts, 26 Neon parts, no particles/beams/trails, no scripts/remotes, and 54 broad collidable floor/road parts. Earlier visual layers remain in Studio for rollback/reference but have no active collision after the pass.

**Revisit when:**  
Dedicated `training_zones` reference images are added, manual phone/player-height screenshots show a remaining scale problem, a source-controlled scene pipeline replaces Studio-authored overlays, or gameplay design deliberately relocates station anchors into the larger visual districts.

## 2026-06-29 - Drive training-town ambience with a tagged client visual controller

**Decision:**  
Add `StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Effects.TrainingWorldVisualAnimator` and source file `roblox/src/client/Effects/TrainingWorldVisualAnimator.client.luau` as a reusable client-only controller for lightweight environmental animation. Add the actual animated primitives, lights, and low-rate emitters as `Workspace.AscensionGrounds.Phase03EnvironmentalFeedback`, using CollectionService tags such as `ZTH_AmbientPulse`, `ZTH_AmbientFloat`, `ZTH_AmbientRotate`, `ZTH_AmbientFlicker`, `ZTH_AmbientParticle`, `ZTH_PromptFeedback`, and `ZTH_ChallengeFeedback`.

**Reason:**  
The Phase 0.3 task is ambience and feedback only. A tagged client controller lets future decorative objects opt into pulse, float, rotation, flicker, particle, prompt, and challenge-start/cancel feedback without adding one-off scripts throughout Workspace or allowing clients to grant XP, rewards, loot, currency, stats, or progression.

**Impact:**  
The five districts and central plaza now have noticeable but restrained client-side motion while all gameplay-affecting behavior remains server-authoritative. The live overlay contains no scripts, remotes, bindables, collidable parts, or unanchored parts; the only prompt mutation is a visual-only `StationId = StrengthForge` attribute used to match existing challenge/prompt events to nearby decorative feedback.

**Revisit when:**  
Motion needs per-device quality settings, final art replaces the primitive Phase 0.3 overlay, new training minigames need station-specific visual feedback hooks, or mobile review finds the particle/light/flicker budget too high.
