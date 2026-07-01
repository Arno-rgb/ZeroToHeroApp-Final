# Zero to Hero — Owner-Controlled Future Milestone Roadmap

**Date:** 2026-06-30  
**Status:** `ACTIVE OWNER ROADMAP - START AT R0 ONLY`  
**Roadmap type:** Recovery, stabilization, vertical-slice completion, and roleplay-alpha sequencing  
**Primary owner:** Project owner  
**Execution support:** Codex, Roblox Studio MCP, approved designer/build support  

---

# 1. Purpose

This roadmap replaces the previous combat-heavy milestone sequence with a controlled, realistic plan that matches the current product direction for **Zero to Hero**.

The project is no longer being treated as only a training simulator or combat RPG.

The intended product is:

> A fantasy social RPG where players train five hero stats, build an identity inside a living town, and use their progression in adventures beyond the Broken Gate.

The roadmap must therefore develop the game across three connected pillars:

1. **Train**
   - Five distinct training stats.
   - One clear minigame per training district.
   - Visible and permanent progression.
   - Short, repeatable, mobile-friendly activities.

2. **Roleplay**
   - A social town that supports identity, performance, crafting, trade, and public events.
   - Initial roles that interact with one another.
   - Immediate participation without requiring payment or a large grind.

3. **Adventure**
   - A readable route through the Broken Gate.
   - Enemies that demonstrate the value of training.
   - Loot, Hero XP, Gold, equipment, and progression.
   - Combat that feels responsive without unnecessary early complexity.

This roadmap is intentionally sequenced to prevent Codex from adding unapproved mechanics, expanding combat depth before the broad game loop is proven, or building distant features before the first playable experience is understandable.

---

# 2. Product Direction

## 2.1 Core Player Promise

A new player should understand the game as:

> Train your hero, choose how you live in the town, and adventure beyond the gate.

The first meaningful version does not need every profession, political system, dungeon, raid, mount, house, or combat ability.

It needs one complete and understandable loop:

1. Spawn in Ascension Grounds.
2. See the five training districts.
3. Complete a training minigame.
4. Receive stat progression.
5. Understand how the stat affects the character.
6. Explore the town.
7. Select or observe a roleplay activity.
8. Travel through the Broken Gate.
9. Fight enemies.
10. Receive Hero XP, Gold, loot, or equipment.
11. Return to the hub with visible progress.

## 2.2 Current Commercial Vertical Slice

The first commercially testable version should eventually contain:

- One polished fantasy hub.
- Five training zones.
- One minigame per stat.
- One Broken Gate combat route.
- Three reviewed normal enemies.
- One elite encounter or simple boss only after the normal route works.
- Reward popup, stats HUD, inventory, equipment, and loot.
- Basic onboarding.
- Role identity.
- Tavern/social square.
- Bard activity.
- Potion brewing.
- Claimable market stalls.
- One public market festival.
- Analytics.
- Mobile-safe UI and performance.
- A small cosmetic catalogue only after the free loop is proven.

Anything beyond that is future expansion.

---

# 3. Authority Hierarchy

Codex must use the following authority order.

Higher levels override lower levels.

1. **Direct owner instruction in the current task**
2. **Owner-approved active roadmap**
3. **Owner-approved milestone specification**
4. **Current architecture and technical constraints**
5. **Master game specification**
6. **Supporting design documents**
7. **Archived milestone prompts**
8. **Idea documents and future concepts**

Codex must never infer approval for a mechanic merely because it appears in:

- `master_game_spec.md`
- an old prompt
- an archived planning file
- a future feature list
- a concept image
- a previous generated roadmap

If a feature is not in the active approved milestone, it is out of scope.

---

# 4. Current Hold

## Status

`ACTIVE OWNER ROADMAP - START AT R0 ONLY`

This document is the active future sequence Codex must follow. Codex must still wait for an explicit owner task before implementing each milestone. The next milestone in sequence is `R0 - Roadmap and Scope Recovery`.

## Prohibited During Hold

Do not proceed with:

- Break extensions
- Gatekeeper Brakk
- boss phases
- boss-specific rewards
- new training minigames
- stamina
- focus
- resolve
- guard mechanics
- dodge mechanics
- active skills
- ultimate abilities
- classes
- simulated mobile reward claims
- parties
- guilds
- PvP
- housing
- auction house
- raids
- mounts
- companions
- election systems
- monarch systems
- premium systems
- shops involving Robux
- larger world expansion
- new enemy families
- new permanent currencies

## Allowed During Hold

Allowed only when explicitly requested:

- Documentation review
- Scope audit
- Code cleanup proposal
- Visual-only polish
- Animation wiring limited to presentation
- Fixes for verified bugs
- Manual-test updates
- Asset inspection
- Performance profiling
- Before-and-after screenshots
- Regression testing

---

# 5. Current Build State

## 5.1 Intended Foundations Already Built

The following systems are currently considered part of the intended foundation:

- Five training stats and profile model
- Player data service
- Replicated stat snapshots
- Strength Forge server-authoritative minigame
- Training Stats HUD
- Reward popup
- Combat service
- Combat HUD
- Lesser Slime enemy
- Hero XP
- Gold
- Inventory
- Equipment
- Items
- Loot tables
- Large training-town visual pass
- Environmental animation pass

These systems may be cleaned up or visually improved, but their core behavior must not be replaced without explicit owner approval.

## 5.2 Phase 6.1 Enemy Set

Currently implemented:

- Gate Hound
- Stone Shell
- Gate Sentinel
- Config-driven enemy roles
- Config-driven loot tables

Recommended status:

- **Keep for review**
- Do not expand yet
- Do not add new enemies yet
- Verify that each enemy has a clear purpose
- Verify mobile readability
- Verify that they support the intended first adventure route

## 5.3 Phase 6.2 Break System

Currently implemented:

- Stone Shell Break meter
- Broken state
- Temporary vulnerability
- Break UI indicator

Current status:

- Implemented without direct owner approval
- Must not be extended
- Must not become a dependency for future enemies
- Must not become required for Brakk
- Must not remain active by default until reviewed

Recommended status:

> Preserve the code, disable it through a feature flag, and defer it until the normal combat loop has been tested.

Suggested configuration:

```lua
FeatureFlags = {
    BreakSystemEnabled = false,
}
```

Stone Shell must remain functional as a normal enemy while Break is disabled.

---

# 6. Roadmap Rules

## 6.1 One Milestone at a Time

Codex must not begin the next milestone until:

- Current milestone acceptance criteria are met
- Play mode has been stopped
- Documentation has been updated
- Known issues are recorded
- Owner approval has been given

## 6.2 No Hidden Scope Expansion

Every milestone must contain:

- Explicit scope
- Explicit exclusions
- Acceptance criteria
- Manual tests
- Documentation updates
- Stop condition

If a required dependency is discovered, Codex must report it instead of silently building it.

## 6.3 Server Authority

Server authority must remain intact for:

- Damage
- Rewards
- Cooldowns
- Minigame completion
- Minigame scores
- Stat progression
- Item ownership
- Gold
- Hero XP
- Loot
- Equipment
- Enemy death
- Role transactions
- Shop transactions
- Festival rewards

Clients may handle:

- Input
- Animation
- Camera feedback
- UI
- Temporary local presentation
- Non-authoritative prediction

## 6.4 Visual Assets

Any Creator Store asset must be inspected before use.

Do not place live:

- Models with scripts
- Models with remotes
- Unverified tools
- Unverified constraints
- Full asset packs
- Blocked assets
- Sword of Darkness unless stripped to approved art-only parts

Use small, named, replaceable, approved subsets.

## 6.5 Documentation Required After Every Milestone

Update as relevant:

- `docs/roblox/progression_tracker.md`
- `docs/roblox/decision_log.md`
- `docs/roblox/known_issues.md`
- `docs/roblox/manual_test_checklist.md`
- `docs/roblox/architecture.md` when architecture changes
- asset manifest or asset approval documentation when assets change

---

# 7. Recommended Owner Decision

The previous decision list did not fully match the new product direction.

Recommended new decision:

## Option F — Approved Direction

> Keep Phase 6.1 enemies for review, disable and defer Break, stabilize existing combat, complete the five-stat training slice, build the first-session journey, polish one Broken Gate adventure route, and then build Roleplay Alpha.

This roadmap assumes Option F.

If the owner does not approve Option F, Codex must remain on hold.

---

# 8. Timeline Assumptions

These are planning estimates, not guarantees.

Assumptions:

- The owner works consistently and makes decisions quickly.
- Codex is used for coding, review, refactoring, testing, and documentation.
- A designer or environment artist supports visual implementation.
- Existing systems are mostly functional.
- No major data architecture rewrite is required.
- No unexpected platform issue blocks progress.
- Scope remains frozen during each milestone.

## Estimated Schedule

| Horizon | Estimated time |
|---|---:|
| Recovery and stabilization | 1–2 weeks |
| Training slice completion | 3–5 weeks |
| First-session and adventure polish | 1–2 weeks |
| Roleplay Alpha | 4–6 weeks |
| Festival, analytics, and release QA | 2–3 weeks |
| Total commercial vertical slice | approximately 11–18 weeks |

A strong focused team may complete it faster.

A solo owner with inconsistent availability may take longer.

The schedule must not be compressed by skipping testing.

---

# 9. Horizon 1 — Recovery and Stabilization

---

# R0 — Roadmap and Scope Recovery

## Goal

Establish a trustworthy source of truth before any further gameplay work.

## Estimated Duration

1–2 focused working days.

## Prerequisites

- None
- Current build must be available
- Current documentation must be accessible

## Scope

Review:

- Phase 0.3 onward
- Phase 6.1 Enemy Set
- Phase 6.2 Break System
- All active milestone prompt files
- Current enabled and disabled scripts
- Current enemy configuration
- Current reward and combat pathways
- Current minigame pathways

## Required Tasks

1. Identify every mechanic added after Phase 0.3.
2. Classify each mechanic as:
   - owner-approved
   - indirectly implied
   - unapproved
   - obsolete
   - duplicate
   - unknown
3. Confirm exact implementation locations for:
   - Gate Hound
   - Stone Shell
   - Gate Sentinel
   - Break meter
   - Broken state
   - Break UI
4. Confirm whether any other system now depends on Break.
5. Confirm whether Stone Shell can function without Break.
6. List old milestone prompt files that should no longer control active work.
7. Add the authority hierarchy to the decision log.
8. Produce a keep/disable/remove recommendation.

## Recommended Decisions

| Feature | Recommendation |
|---|---|
| Gate Hound | Keep for hands-on review |
| Stone Shell | Keep for hands-on review |
| Gate Sentinel | Keep for hands-on review |
| Break meter | Disable and defer |
| Broken state | Disable and defer |
| Break UI | Hide while Break is disabled |
| Gatekeeper Brakk | Defer |
| Boss phases | Defer |
| Boss rewards | Defer |

## Explicit Exclusions

- No new gameplay code
- No new enemy
- No new minigame
- No reward changes
- No damage changes
- No visual redesign
- No new UI

## Acceptance Criteria

- Full post-Phase-0.3 mechanic inventory exists.
- Every Phase 6.1 and 6.2 component is located.
- Break dependencies are documented.
- Keep/disable/remove recommendation is recorded.
- Authority hierarchy is recorded.
- No gameplay behavior changed.

## Documentation Updates

- `progression_tracker.md`
- `decision_log.md`
- `known_issues.md`
- `manual_test_checklist.md`

## Stop Condition

Stop after documentation.

Do not disable or remove code until the owner approves the recommendation.

## Recommended Codex Prompt

```text
Perform R0 Roadmap and Scope Recovery only.

Do not add or change gameplay. Inspect all mechanics added after Phase 0.3. Identify the exact scripts, configs, UI, remotes, and dependencies for Gate Hound, Stone Shell, Gate Sentinel, and the Break system.

Produce a keep/disable/remove recommendation. Add the project authority hierarchy to the decision log. Update progression_tracker.md, decision_log.md, known_issues.md, and manual_test_checklist.md.

Stop after documentation.
```

---

# R1 — Disable and Isolate Unapproved Break Work

## Goal

Remove Break from the active player experience without destroying recoverable code.

## Estimated Duration

1–2 focused working days.

## Prerequisites

- R0 approved
- Owner confirms Break should be disabled and deferred

## Scope

- Add or use an existing feature flag
- Disable Break server behavior
- Hide Break UI
- Ensure Stone Shell still functions normally
- Preserve code for future review
- Add regression tests or manual checks

## Required Tasks

1. Add a clear Break feature flag.
2. Default it to `false`.
3. Prevent Break meter creation while disabled.
4. Prevent Broken-state transitions while disabled.
5. Prevent Break vulnerability modifiers while disabled.
6. Hide or disable Break UI while disabled.
7. Verify Stone Shell:
   - spawns
   - moves
   - attacks
   - takes damage
   - dies
   - grants rewards
8. Ensure no error is produced by missing Break state.
9. Record every changed path.
10. Do not delete Break code unless the owner later requests removal.

## Explicit Exclusions

- No rebalancing Stone Shell
- No new enemy behavior
- No new status system
- No Brakk
- No Break redesign
- No new UI
- No damage changes except removing the disabled Break modifier

## Acceptance Criteria

- Break is inactive in normal Play mode.
- Break UI does not appear.
- Stone Shell remains fully fightable.
- Stone Shell grants the same intended normal rewards.
- No new console errors appear.
- Feature flag is documented.
- Break can be re-enabled only through explicit configuration.

## Manual Tests

Desktop:

- Spawn Stone Shell.
- Attack until death.
- Verify no Break meter.
- Verify no Broken state.
- Verify reward.
- Verify inventory or Gold changes.
- Verify no duplicate reward.

Mobile:

- Repeat the same flow.
- Confirm HUD does not overlap.
- Confirm no hidden Break UI space remains.

## Documentation Updates

- `progression_tracker.md`
- `decision_log.md`
- `known_issues.md`
- `manual_test_checklist.md`
- `architecture.md` if feature flags are newly introduced

## Stop Condition

Stop after Break is disabled and Stone Shell is verified.

## Recommended Codex Prompt

```text
Implement R1 only.

Disable the Phase 6.2 Break system behind a documented feature flag that defaults to false. Preserve the implementation for future review. Hide Break UI while disabled. Ensure Stone Shell remains a normal functioning enemy with spawn, movement, attacks, damage, death, loot, Hero XP, Gold, and inventory rewards intact.

Do not rebalance combat. Do not add enemies, bosses, skills, stamina, guard, dodge, or other mechanics.

Run Play mode, verify the full Stone Shell flow, stop Play mode, and update the required docs.
```

---

# R2 — Legacy Feedback and Duplicate Path Cleanup

## Goal

Reduce the chance that future milestones modify obsolete clients, remotes, or UI.

## Estimated Duration

2–4 focused working days.

## Prerequisites

- R1 accepted
- Current canonical systems identified

## Scope

Inspect and classify:

- `AscensionSwordCombatClient`
- `AscensionTrainingFeedbackClient`
- old reward clients
- old training clients
- old combat remotes
- disabled scripts
- duplicate HUDs
- duplicate popup paths
- duplicate input bindings
- abandoned prototype modules

## Required Tasks

1. Identify the canonical implementation for:
   - sword input
   - combat HUD
   - training feedback
   - reward popup
   - inventory update
   - enemy reward delivery
2. Identify duplicate or obsolete paths.
3. Confirm whether each unused path is:
   - safe to disable
   - safe to archive
   - still referenced
   - unknown
4. Disable only paths proven unused.
5. Move archived scripts into a clearly named archival folder if project conventions permit.
6. Do not delete code without owner approval.
7. Verify no duplicate UI or remote firing.
8. Verify all canonical systems still work.

## Explicit Exclusions

- No gameplay redesign
- No new input system
- No new HUD
- No reward changes
- No remote renaming unless necessary and approved
- No large architecture rewrite

## Regression Test

Verify:

- Strength Forge starts
- Strength Forge completes
- Stats update
- Reward popup appears once
- Combat HUD appears
- Sword attack fires once per valid input
- Enemy damage occurs once
- Enemy death reward occurs once
- Inventory updates once
- Equipment remains intact
- No duplicate remote events
- No new console errors except documented DataStore warning

## Acceptance Criteria

- Canonical paths are documented.
- Proven-unused duplicate paths are disabled or archived.
- No duplicate feedback remains.
- Full gameplay regression passes.
- No mechanics were added.

## Documentation Updates

- `architecture.md`
- `progression_tracker.md`
- `decision_log.md`
- `known_issues.md`
- `manual_test_checklist.md`

## Stop Condition

Stop after the regression baseline is stable.

---

# R3 — Existing Combat Presentation Polish

## Goal

Improve feel without adding combat depth.

## Estimated Duration

3–5 focused working days.

## Prerequisites

- R2 accepted
- Owner-provided or owner-approved animations available

## Scope

Visual-only:

- idle
- equip
- swing
- optional block-style pose used only as presentation if no guard mechanic exists
- hit flash
- impact particles
- impact sound
- enemy hit reaction
- limited camera feedback
- weapon trail
- animation priority cleanup

## Required Tasks

1. Inspect current sword client and server flow.
2. Add owner-approved animation IDs.
3. Keep attack timing aligned with server validation.
4. Ensure animation does not determine damage.
5. Add one restrained sword trail.
6. Add one restrained impact effect.
7. Add one enemy hit reaction.
8. Add audio with volume limits.
9. Verify animation cancellation.
10. Verify equip/unequip state.
11. Verify mobile input remains unchanged.
12. Verify attack cooldown remains server-controlled.

## Explicit Exclusions

- No guard mechanic
- No dodge mechanic
- No stamina
- No focus
- No resolve
- No combo damage scaling
- No skill
- No ultimate
- No new weapon class
- No damage change
- No enemy change
- No reward change

## Acceptance Criteria

- Existing attacks look and sound materially better.
- Server remains authoritative.
- Damage numbers are unchanged.
- Attack cooldown is unchanged.
- Mobile controls remain readable.
- No animation loops remain stuck.
- No duplicate swing occurs.
- No new combat mechanics exist.

## Stop Condition

Stop after current sword combat feels clearer and passes regression.

---

# 10. Horizon 2 — Five-Stat Training Slice

---

# R4 — Training Minigame Handler Refactor

## Goal

Create a reusable typed minigame registration path without changing Strength Forge behavior.

## Estimated Duration

2–4 focused working days.

## Prerequisites

- R3 accepted
- Current Strength Forge flow understood

## Scope

Refactor:

- minigame registration
- minigame ID typing
- server validation dispatch
- reward dispatch
- client presentation routing
- minigame-specific configuration

## Required Tasks

1. Document current Strength Forge request flow.
2. Identify input, validation, result, and reward stages.
3. Define a minimal handler interface.
4. Register Strength Forge through the new handler path.
5. Preserve all current Strength Forge behavior.
6. Preserve current reward values.
7. Preserve current prompt.
8. Preserve current UI unless routing requires a safe internal change.
9. Add clear errors for unknown minigame IDs.
10. Add tests or manual validation for invalid requests.
11. Document how future minigames register.

## Suggested Handler Shape

Illustrative only:

```lua
type TrainingMinigameHandler = {
    Id: string,
    ValidateStart: (player: Player, payload: any) -> (boolean, string?),
    Start: (player: Player, payload: any) -> any,
    ValidateResult: (player: Player, payload: any) -> (boolean, string?),
    Complete: (player: Player, payload: any) -> any,
}
```

Use project architecture rather than forcing this exact shape.

## Explicit Exclusions

- No Guardian Pulse
- No Skyline Rush
- No Pace Trial
- No Rune Alignment
- No reward rebalance
- No new stat
- No new UI design
- No new currency
- No large framework rewrite

## Acceptance Criteria

- Strength Forge behavior is unchanged.
- Invalid minigame IDs are rejected.
- Server remains authoritative.
- Future minigames can register without modifying core reward logic.
- Regression tests pass.
- Architecture is documented.

## Stop Condition

Stop before adding a second minigame.

---

# R5 — Guardian Pulse

## Goal

Add the first new minigame for Vitality.

## Estimated Duration

4–7 focused working days.

## Prerequisites

- R4 accepted
- Guardian Grove visual area exists or has an approved greybox
- Vitality reward values approved

## Player Experience

- Player enters the Guardian Pulse circle.
- Directional waves approach.
- Player raises a shield at the correct time.
- Correct timing builds a short streak.
- Missed timing reduces the round score.
- The minigame lasts approximately 30–45 seconds.
- Server validates result and awards Vitality progression.

## MVP Mechanics

- Four possible attack directions
- One shield input
- Clear warning telegraph
- Three timing grades:
  - Miss
  - Good
  - Perfect
- Fixed round count
- No health loss
- No PvP
- No combat status effect
- No permanent shield item required

## Server Validation

Server validates:

- player is near the station
- minigame is active
- expected sequence exists
- input timing is within allowed range
- completion count is valid
- result is not replayed
- reward has not already been granted

## Client Responsibilities

Client handles:

- warning direction
- shield animation
- timing feedback
- score display
- local sound
- local particles

## Explicit Exclusions

- No healer profession
- No potions
- No guard mechanic
- No combat shield
- No permanent defence buff
- No multiplayer version
- No secondary Vitality minigames

## Acceptance Criteria

- Minigame starts from the intended prompt.
- One player can complete it reliably on desktop and mobile.
- Server rejects invalid distance.
- Server rejects duplicate completion.
- Vitality updates correctly.
- Reward popup appears once.
- No other stat changes.
- No combat logic changes.
- Average completion time is 30–45 seconds.

## Stop Condition

Stop after Guardian Pulse is accepted.

---

# R6 — Skyline Rush

## Goal

Add the first Agility minigame.

## Estimated Duration

5–8 focused working days.

## Prerequisites

- R5 accepted
- Skyward Tower greybox or final route approved

## Player Experience

- Player enters the start gate.
- Player follows a short tower route.
- Checkpoints preserve progress during the attempt.
- Player reaches the finish ring.
- Server validates the route and completion time.
- Agility reward is granted.

## MVP Route

Use 6–8 readable obstacles:

1. Wide stepping platforms
2. Short beam
3. Ladder or climb
4. Two moving platforms maximum
5. Suspended platform
6. Final ramp
7. Finish ring

Target completion time:

- 35–60 seconds for a new player
- Faster for experienced players

## Mobile Requirements

- Wide platforms
- Forgiving jumps
- Clear camera space
- No edge-perfect jump
- No thin rotating beam
- No high-speed moving obstacle
- Recovery checkpoint
- Fall reset without long delay

## Server Validation

Server validates:

- start position
- checkpoint order
- checkpoint timestamps
- finish position
- minimum plausible completion time
- no duplicate reward
- active minigame state

## Explicit Exclusions

- No courier role
- No Reaction Dash
- No global leaderboard at first
- No multiplayer race
- No paid speed advantage
- No new movement skill

## Acceptance Criteria

- Route is understandable without written tutorial.
- Desktop and mobile completion are practical.
- Checkpoints work.
- Falling does not strand the player.
- Server rejects impossible completion.
- Agility updates once.
- Reward popup appears once.
- No movement exploit is introduced.

## Stop Condition

Stop after one accepted route.

---

# R7 — Pace Trial

## Goal

Add the first Endurance minigame.

## Estimated Duration

4–7 focused working days.

## Prerequisites

- R6 accepted
- Heroes’ Track collision and loop verified

## Player Experience

- Player starts at the track gate.
- Player runs one loop.
- A simple pace indicator rewards controlled movement.
- Checkpoints confirm the route.
- Server validates completion.
- Endurance progression is granted.

## MVP Mechanics

Prefer a simple implementation:

- one lap
- four checkpoints
- target pace zone
- short sprint windows
- no complex stamina simulation

The pace indicator can be presentation-driven while the server validates:

- route order
- completion time
- minimum movement plausibility
- checkpoint order

## Explicit Exclusions

- No full stamina system
- No Team Relay
- No Hurdle Circuit
- No persistent movement-speed advantage
- No multiplayer race
- No mount use
- No complex endurance drain

## Acceptance Criteria

- One full lap takes approximately 35–60 seconds.
- Track collision is smooth.
- Checkpoint order is enforced.
- Server rejects teleport completion.
- Endurance updates once.
- Reward popup appears once.
- Mobile movement is comfortable.

## Stop Condition

Stop after one-lap Pace Trial works.

---

# R8 — Rune Alignment

## Goal

Add the first Control minigame.

## Estimated Duration

4–7 focused working days.

## Prerequisites

- R7 accepted
- Arcane Shrine visual area exists

## Player Experience

- Player activates the central shrine.
- Three rings rotate.
- Player stops each ring when symbols align.
- Difficulty rises slightly each round.
- Server validates sequence and timing.
- Control progression is granted.

## MVP Mechanics

- Three rounds
- One input button
- One target zone per ring
- Increasing rotation speed
- Good and Perfect grades
- Clear completion pulse
- 30–45 second total session

## Server Validation

Server validates:

- active session
- approved ring sequence
- input count
- plausible timestamps
- result not replayed
- completion state

## Explicit Exclusions

- No Orb Guidance
- No Focus Sequence
- No spell system
- No mana
- No focus resource
- No combat magic
- No player-created patterns

## Acceptance Criteria

- The minigame is readable.
- Input works on mobile.
- Three rounds complete in 30–45 seconds.
- Control updates once.
- Reward popup appears once.
- Server rejects duplicate completion.
- No new combat resource exists.

## Stop Condition

Stop after Rune Alignment is accepted.

---

# R9 — Five-Stat Slice Regression and Balance Review

## Goal

Review the five training minigames as one complete training system.

## Estimated Duration

3–5 focused working days.

## Prerequisites

- R5 through R8 accepted

## Scope

Review:

- Strength Forge
- Guardian Pulse
- Skyline Rush
- Pace Trial
- Rune Alignment

## Required Checks

- Start prompt clarity
- Completion time
- Reward consistency
- Mobile input
- UI readability
- server validation
- duplicate reward protection
- interaction range
- player collision
- reset behavior
- error recovery
- visual hierarchy
- sound volume
- replay speed

## Balance Rules

- Strength Forge may remain the most polished.
- Other minigames should not require equal content depth.
- All five should feel worthwhile.
- No minigame should grant dramatically higher reward per minute without owner approval.
- Reward values should be documented.

## Acceptance Criteria

- All five minigames work in one Play session.
- No stat path is broken.
- No reward duplicates.
- No UI overlaps.
- No new console errors.
- Average completion times are documented.
- Reward rates are documented.
- Known issues are recorded.

## Stop Condition

Do not add secondary minigames.

---

# 11. Horizon 3 — First-Session and Adventure Slice

---

# R10 — First-Session Journey

## Goal

Make the first ten minutes understandable without a long tutorial.

## Estimated Duration

4–7 focused working days.

## Prerequisites

- R9 accepted
- Hub layout stable
- Broken Gate route accessible

## First-Session Sequence

1. Spawn facing the hub.
2. Short welcome card appears.
3. Five district landmarks are visible.
4. One recommended training district is highlighted.
5. Player completes one minigame.
6. Reward popup appears.
7. Stats panel is introduced.
8. Broken Gate becomes the next suggested destination.
9. Player defeats one enemy.
10. Player receives Hero XP, Gold, or loot.
11. Player sees the tavern and market as future social spaces.
12. Tutorial guidance ends.

## Design Rules

- No forced ten-minute quest.
- No unskippable dialogue.
- No more than one active objective at a time.
- No fake reward claim.
- No Robux prompt.
- No forced role selection.
- No long cutscene.
- No text wall.
- Guidance must be dismissible.

## Analytics Events

Add or verify:

- `FirstSpawn`
- `WelcomeShown`
- `TrainingZoneSuggested`
- `TrainingStarted`
- `TrainingCompleted`
- `StatsOpened`
- `BrokenGateReached`
- `FirstEnemyDamaged`
- `FirstEnemyDefeated`
- `FirstLootReceived`
- `FirstSessionTutorialCompleted`

Use the project's analytics architecture.

Do not create a new external analytics dependency without approval.

## Acceptance Criteria

- New player can complete the journey in 8–12 minutes.
- Guidance does not block free exploration.
- Player can skip or dismiss guidance.
- Mobile UI remains readable.
- No purchase prompt appears.
- Analytics fire once where appropriate.
- Existing players are not forced through the tutorial again.

## Stop Condition

Stop after the first-session flow is stable.

---

# R11 — Broken Gate Enemy Review

## Goal

Evaluate whether the Phase 6.1 enemy set belongs in the first adventure slice.

## Estimated Duration

2–4 focused working days.

## Prerequisites

- R10 accepted
- Break disabled

## Review Each Enemy

### Gate Hound

Evaluate:

- movement readability
- attack telegraph
- speed
- hit reaction
- reward
- role in the route

### Stone Shell

Evaluate:

- readability without Break
- health
- damage
- movement
- whether it is frustrating
- whether it needs Break later

### Gate Sentinel

Evaluate:

- silhouette
- attack range
- telegraph
- route placement
- reward
- elite feel

## Decision Options Per Enemy

- Keep unchanged
- Keep with visual adjustment
- Keep with small tuning
- Defer
- Remove from the first route

## Explicit Exclusions

- No Break reactivation
- No Brakk
- No new enemy
- No new status
- No new attack system
- No boss reward

## Acceptance Criteria

- Each enemy has a documented purpose.
- Each enemy is playable on mobile.
- Telegraphs are readable.
- Rewards work.
- Enemy stacking is not unfair.
- Route pacing is documented.
- Owner approves keep/defer decisions.

## Stop Condition

Stop before adding new combat content.

---

# R12 — Broken Gate Adventure Slice Polish

## Goal

Create one complete, readable, replayable route beyond the gate.

## Estimated Duration

4–7 focused working days.

## Prerequisites

- R11 decisions approved

## Route Structure

Recommended:

1. Gate entrance
2. Safe warning area
3. First simple enemy encounter
4. Short travel section
5. Mixed enemy encounter
6. Elite encounter
7. Reward point
8. Return path or shortcut

## Scope

- Enemy placement
- Spawn spacing
- route readability
- checkpoint or safe return behavior
- environmental telegraphs
- loot flow
- reward feedback
- mobile combat readability
- collision cleanup
- respawn timing

## Optional Elite

Gate Sentinel may serve as the elite.

Do not add Brakk unless the owner explicitly replaces this milestone with a boss milestone.

## Acceptance Criteria

- Route takes approximately 5–10 minutes for a new player.
- Training stats visibly matter.
- Enemies do not spawn on top of players.
- Player can understand where to go.
- Reward flow works.
- Player can return to town.
- No Break dependency exists.
- No boss phase exists.
- Mobile controls remain usable.

## Stop Condition

Stop after one adventure route.

---

# R13 — Complete Vertical-Slice Regression Gate

## Goal

Verify the full Train → Adventure loop before roleplay systems are added.

## Estimated Duration

3–5 focused working days.

## Prerequisites

- R12 accepted

## Full Test

1. New profile
2. Spawn
3. First-session guidance
4. Strength Forge
5. Guardian Pulse
6. Skyline Rush
7. Pace Trial
8. Rune Alignment
9. Stats HUD
10. Reward popup
11. Broken Gate route
12. Enemy fight
13. Loot
14. Inventory
15. Equipment
16. Return to hub
17. Rejoin and verify save

## Acceptance Criteria

- Full loop works without manual repair.
- Data saves and reloads.
- No duplicate rewards.
- No lost inventory.
- No UI overlap.
- No major path blocking.
- No new console errors except documented warning.
- Mobile test passes.
- Performance baseline is recorded.

## Stop Condition

Roleplay Alpha cannot begin until this gate passes.

---

# 12. Horizon 4 — Roleplay Alpha

Roleplay is now a core pillar, but the first implementation must remain small.

Do not begin with:

- elections
- monarchy
- villains
- guards
- housing
- mounts
- guild halls
- auction house
- advanced player economy

Start with three connected roles:

- Bard
- Potion Brewer
- Shopkeeper

---

# R14 — Roleplay Shared Foundation

## Goal

Create the smallest safe role identity framework.

## Estimated Duration

3–5 focused working days.

## Prerequisites

- R13 accepted
- Roleplay Alpha design approved

## Scope

- role definition registry
- role selection UI
- current-role replication
- visible role label
- short preset status
- role toolbelt registration
- role clearing and switching
- basic role analytics

## Initial Roles

- Citizen
- Adventurer
- Bard
- Potion Brewer
- Shopkeeper

Only Bard, Potion Brewer, and Shopkeeper need functional activities during Roleplay Alpha.

## Role Rules

- Free access
- Immediate selection
- No level requirement
- No Robux requirement
- No authority over other players
- Server validates current role
- Switching role has a short anti-spam cooldown
- Leaving resets session claims but not saved identity preferences

## Preset Status Examples

- Looking for a group
- Taking potion orders
- Performing soon
- Shop open
- Exploring the gate
- New to town

Use filtered preset text first.

Custom biographies can wait.

## Explicit Exclusions

- No mayor
- No monarch
- No villain
- No guard
- No healer
- No courier
- No blacksmith customer orders
- No housing
- No custom player-entered role title
- No permanent profession reputation yet

## Acceptance Criteria

- Player can choose a role.
- Role replicates correctly.
- Role appears above or near the player in a readable way.
- Role toolbelt changes safely.
- Role cannot grant unauthorized server actions.
- Role switch works on mobile.
- Analytics record role selection.

## Stop Condition

Stop before implementing Bard activity.

---

# R15 — Tavern and Social Square

## Goal

Create a functional social location for Roleplay Alpha.

## Estimated Duration

3–6 focused working days depending on existing visuals.

## Prerequisites

- R14 accepted
- Tavern location approved

## Scope

- tavern or social square
- small stage
- seating
- dance area
- notice board
- bard start point
- brewer order board location
- nearby market stalls
- clear path from hub

## Required Interactions

- Sit
- Stand
- inspect notice board
- start performance from stage
- gather without collision problems

## Visual Requirements

- readable from the plaza
- warm lighting
- broad entry
- no narrow doors
- no dense interior
- mobile-safe effects
- 8–12 usable seats maximum
- one clear stage

## Explicit Exclusions

- No room renting
- No food system
- No tavern keeper role
- No gambling
- No private guild room
- No housing
- No NPC dialogue tree

## Acceptance Criteria

- Players can gather and sit.
- Stage is clear.
- Paths are unobstructed.
- Tavern does not materially hurt performance.
- Location supports Bard, Brewer, and Shopkeeper flow.
- No role activity is implemented yet beyond basic interaction.

## Stop Condition

Stop after the shared social space is accepted.

---

# R16 — Bard Alpha

## Goal

Add one free, visible, socially useful Bard activity.

## Estimated Duration

5–8 focused working days.

## Prerequisites

- R15 accepted
- One approved instrument asset or primitive placeholder
- Original or licensed audio available

## Player Experience

- Player selects Bard.
- Player equips one free instrument.
- Player stands on the stage.
- Player starts a short performance.
- Nearby players can watch.
- Player receives Town Tokens or Bard activity credit.
- Nearby players may use a dance prompt.

## MVP Modes

### Automatic Performance

Required at launch:

- player chooses one short song
- animation plays
- music plays
- stage effect activates
- performance completes

### Simple Rhythm Interaction

Optional only if automatic mode is already stable:

- 3 lanes
- short 30-second pattern
- no fail state
- score affects presentation, not combat power

## Social Actions

- Invite nearby player to dance
- Place a tip container
- End performance
- Join audience

Tips must use Town Tokens only.

No Robux tipping.

## Server Validation

- player role is Bard
- player is at approved stage
- performance is not already active
- song ID is approved
- reward cooldown is valid
- duplicate reward blocked

## Explicit Exclusions

- No band system
- No custom uploaded music
- No premium instrument requirement
- No major combat buff
- No guild performance
- No stage ownership
- No persistent Bard level yet

## Acceptance Criteria

- Bard can perform for 30–60 seconds.
- Audience hears audio at safe volume.
- Music stops correctly.
- Role reward is server-approved.
- Dance invitation requires consent.
- Performance works on mobile.
- Multiple Bards cannot break audio or stage state.
- No copyrighted unapproved music is used.

## Stop Condition

Stop after one complete Bard activity.

---

# R17 — Potion Brewer Alpha

## Goal

Add one free potion-brewing activity that connects to player use.

## Estimated Duration

6–9 focused working days.

## Prerequisites

- R16 accepted
- Guardian Grove brewing area approved
- Five recipes approved

## MVP Recipes

Recommended:

1. Small Healing Potion
2. Short Movement Potion
3. Sparkle Potion
4. Bubble Hiccup Potion
5. Colour Glow Potion

Combat-useful effects must be modest and temporary.

## Brewing Flow

1. Player selects Potion Brewer.
2. Player claims a free brewing station.
3. Player selects a recipe.
4. Player adds ingredients in order.
5. Player stirs in the shown direction.
6. Player stops heat in the target zone.
7. Server validates result.
8. Potion is created.
9. Player may use it, gift it, or list it at a stall.

## Server Validation

- player role
- station claim
- recipe validity
- ingredient order
- timing windows
- one active brew
- inventory capacity
- duplicate completion
- potion ownership
- effect duration

## Consent

For roleplay effects applied to another player:

- receiver must accept
- effect must be harmless
- receiver can cancel where practical
- repeated requests are rate-limited

## Explicit Exclusions

- No rare ingredients
- No frontier gathering requirement
- No paid recipes
- No permanent stat potion
- No player poisoning
- No uncontrolled transformation
- No auction house
- No complex alchemy tree

## Acceptance Criteria

- Five recipes work.
- Brewing completes in approximately 30–60 seconds.
- Potion appears in inventory.
- Potion can be used.
- Gift flow is safe.
- Consent works for another player.
- Duplicate potion grants are blocked.
- Effects expire.
- Mobile input works.

## Stop Condition

Stop after the five-recipe system is stable.

---

# R18 — Claimable Market Stalls

## Goal

Allow Shopkeepers to sell approved items safely.

## Estimated Duration

6–10 focused working days.

## Prerequisites

- R17 accepted
- Server-authoritative item ownership exists
- Town Tokens defined

## MVP Stall System

- 4–8 temporary stalls
- session claim
- claim timeout
- owner display
- open/closed state
- 3–5 display slots
- fixed-price listing
- safe purchase confirmation
- automatic release on leave

## Allowed Initial Goods

- Alpha potions
- basic NPC goods if approved
- cosmetic roleplay props
- simple food props if already existing

## Transaction Flow

1. Shopkeeper claims stall.
2. Shopkeeper selects owned item.
3. Shopkeeper sets price within approved limits.
4. Item appears in a display slot.
5. Customer selects item.
6. Customer sees item and price.
7. Customer confirms.
8. Server verifies:
   - seller owns item
   - item is still listed
   - customer has currency
   - price is allowed
   - inventories have space
9. Server transfers item and Town Tokens.
10. UI confirms transaction.

## Safety Rules

- No Robux player trading
- No arbitrary text prices
- No negative price
- No price change after customer confirmation starts
- No item duplication
- No offline claim
- No permanent prime-location ownership
- No blind trade window
- No seller ability to take customer items

## Explicit Exclusions

- No auction house
- No persistent business ownership
- No employees
- No custom shop names at first
- No player-created assets
- No premium stall advantage
- No tax system
- No merchant level

## Acceptance Criteria

- Stall claims and releases correctly.
- Item listing is server-authoritative.
- Purchase is atomic.
- No duplication.
- No currency loss without item transfer.
- Seller receives Town Tokens.
- Customer receives item.
- Disconnect handling is safe.
- Mobile purchase UI is readable.
- Stall does not remain locked after owner leaves.

## Stop Condition

Stop after secure fixed-price sales work.

---

# R19 — Roleplay Alpha Regression Gate

## Goal

Verify Roleplay Alpha as one connected system.

## Estimated Duration

3–5 focused working days.

## Prerequisites

- R14 through R18 accepted

## Full Test

1. Select Bard
2. Perform
3. Receive Town Tokens
4. Select Potion Brewer
5. Brew potion
6. Place potion in inventory
7. Select Shopkeeper
8. Claim stall
9. List potion
10. Second player buys potion
11. Second player uses potion
12. Verify both balances and inventories
13. Disconnect seller
14. Verify stall releases
15. Rejoin
16. Verify permanent inventory and currency save as designed

## Acceptance Criteria

- All three roles work.
- Role switching works.
- No transaction exploit found in manual tests.
- No duplicate rewards.
- No lost item.
- No lost Town Tokens.
- Consent effects work.
- Mobile flow works.
- Tavern supports social gathering.
- Performance remains stable with multiple players.

## Stop Condition

Do not add more roles before this passes.

---

# 13. Horizon 5 — Public Event, Analytics, and Commercial Test

---

# R20 — Fantasy Market Festival

## Goal

Create one scheduled event that connects training, adventure, and roleplay.

## Estimated Duration

5–8 focused working days.

## Prerequisites

- R19 accepted
- Event timing architecture approved

## Event Frequency

Recommended for testing:

- every 20–30 minutes
- 5–8 minute duration
- clear countdown
- optional participation

## Event Activities

### Bard

- perform on stage
- complete one festival song
- attract audience

### Potion Brewer

- complete a festival recipe order
- deliver to market

### Shopkeeper

- sell approved festival item
- serve a customer

### Adventurer

- collect simple festival supplies
- optionally retrieve one item from near the Broken Gate

### Trainer

- complete any one training minigame during the event

## Event Completion

- public celebration
- Town Token reward
- small cosmetic or title progress if approved
- no Robux requirement
- no forced participation

## Explicit Exclusions

- No mayor
- No monarch
- No villain heist
- No guard chase
- No seasonal premium track
- No limited paid item
- No large cutscene

## Acceptance Criteria

- Event starts and ends correctly.
- Late joiners understand state.
- Rewards are granted once.
- Nonparticipants are unaffected.
- Activities are optional.
- Server reset or shutdown does not duplicate rewards.
- Event remains mobile-safe.
- Performance remains stable.

## Stop Condition

Stop after one festival works.

---

# R21 — Analytics and Player Validation Instrumentation

## Goal

Collect enough information to make evidence-based decisions.

## Estimated Duration

2–4 focused working days.

## Prerequisites

- R20 accepted
- Existing analytics path identified

## Required Events

Training:

- minigame viewed
- minigame started
- minigame completed
- minigame abandoned
- reward received

Adventure:

- Broken Gate reached
- first enemy damaged
- first enemy defeated
- route completed
- player died
- loot received

Roleplay:

- role selected
- Bard performance started
- Bard performance completed
- audience joined
- potion brew started
- potion brew completed
- stall claimed
- item listed
- transaction completed
- festival joined
- festival completed

Session:

- first-session tutorial completed
- session length
- return session
- mobile or desktop category where permitted

## Privacy and Safety

- Do not store chat content.
- Do not store unnecessary personal data.
- Use approved analytics APIs.
- Do not introduce external trackers without approval.

## Acceptance Criteria

- Events fire once at correct points.
- No duplicate analytics flood.
- Event names are documented.
- Analytics do not affect gameplay.
- Analytics failure does not break gameplay.

## Stop Condition

Stop after instrumentation is verified.

---

# R22 — Closed Playtest and Release Readiness

## Goal

Determine whether the vertical slice is ready for wider testing.

## Estimated Duration

1–2 weeks including fixes.

## Prerequisites

- R21 accepted
- Test group available

## Required Test Groups

Where practical:

- owner
- designer
- experienced Roblox player
- new Roblox player
- younger target player with appropriate supervision
- mobile player
- lower-performance device
- desktop player

## Test Scenarios

### First Session

- Can the player understand where to go?
- Can they complete training?
- Can they find the gate?
- Can they fight?
- Do they notice the social area?

### Training

- Which minigame is chosen first?
- Which is abandoned?
- Which feels unfair?
- Which is replayed?

### Roleplay

- Do players select roles without instruction?
- Do they gather around the Bard?
- Do they understand brewing?
- Do they understand stalls?
- Do they interact with other players?

### Adventure

- Does training feel meaningful?
- Are enemies readable?
- Is the route too easy or too difficult?
- Is the reward satisfying?

### Mobile

- Are buttons readable?
- Are camera and movement comfortable?
- Are jump sections practical?
- Is UI crowded?
- Is frame rate stable?

## Release Gate Metrics

These are internal targets, not guarantees.

Suggested initial goals:

- 70% complete first training
- 50% reach Broken Gate
- 35% defeat first enemy
- 25% select a role
- 15% complete a role activity
- median first session above 15 minutes
- no critical save-loss bug
- no known duplication exploit
- stable mobile performance

## Acceptance Criteria

- Critical bugs resolved.
- High-risk exploits resolved.
- Main loop understandable.
- At least one roleplay interaction occurs naturally in group tests.
- Performance baseline acceptable.
- Owner approves public test.

---

# R23 — Small Commercial Beta

## Goal

Launch a narrow, honest, testable public version.

## Estimated Duration

3–5 focused working days after R22 acceptance.

## Launch Content

- five training zones
- five minigames
- Broken Gate route
- reviewed enemy set
- stats
- rewards
- inventory
- equipment
- Bard
- Potion Brewer
- Shopkeeper
- Tavern/social square
- Market Festival
- onboarding
- analytics

## Launch Monetization

Keep small.

Recommended initial products only after free systems work:

- one Bard cosmetic pack
- one Brewer cosmetic pack
- one Forge cosmetic pack
- one emote pack
- optional private server

No pay-to-win.

No paid role.

No paid authority.

No election.

No premium stat boost.

## Launch Requirements

- accurate description
- real gameplay screenshots
- concept art clearly labelled
- mobile support stated honestly
- known limitations documented internally
- no exaggerated feature claims
- no unfinished feature listed as live

---

# 14. Future Features Requiring New Approval

The following remain outside the active roadmap.

They require separate owner approval after player validation.

## Combat Depth

- Break reactivation
- boss phases
- Brakk
- stamina
- focus
- resolve
- guard
- dodge
- skills
- ultimates
- classes
- weapon trees

## Roleplay Expansion

- Villain role
- Guard role
- Healer role
- Courier role
- Blacksmith customer orders
- Tavern Keeper
- Mayor election
- Monarch
- royal court
- housing
- roommates
- mounts
- companions
- guild halls
- large player economy
- auction house

## Adventure Expansion

- dungeons
- raids
- PvP
- new regions
- world bosses
- larger enemy families
- large quest chains

## Monetization Expansion

- subscription
- seasonal premium track
- large cosmetic catalogue
- premium houses
- premium mounts
- companion store
- UGC
- gifted products

---

# 15. Feature Selection After Public Validation

After R23, the next feature must be selected from player evidence.

Possible decisions:

## If Training Is Strongest

Prioritize:

- secondary minigame for the most popular zone
- personal bests
- training competition
- better progression visibility

## If Roleplay Is Strongest

Prioritize:

- second Bard instrument
- more potion recipes
- better stalls
- Tavern Keeper
- Healer
- simple homes

## If Adventure Is Strongest

Prioritize:

- simple boss
- second route
- better loot variety
- party support
- dungeon prototype

## If Social Conflict Is Requested

Consider:

- Villain Alpha
- Guard investigation
- one structured heist

Do not add elections merely because they are exciting on paper.

Elections require healthy server population.

---

# 16. Final Recommended Sequence

The active sequence should be:

1. **R0 — Roadmap and Scope Recovery**
2. **R1 — Disable and Isolate Break**
3. **R2 — Legacy Cleanup**
4. **R3 — Combat Presentation Polish**
5. **R4 — Training Handler Refactor**
6. **R5 — Guardian Pulse**
7. **R6 — Skyline Rush**
8. **R7 — Pace Trial**
9. **R8 — Rune Alignment**
10. **R9 — Five-Stat Regression**
11. **R10 — First-Session Journey**
12. **R11 — Enemy Review**
13. **R12 — Broken Gate Adventure Polish**
14. **R13 — Vertical-Slice Regression**
15. **R14 — Roleplay Foundation**
16. **R15 — Tavern and Social Square**
17. **R16 — Bard Alpha**
18. **R17 — Potion Brewer Alpha**
19. **R18 — Market Stalls**
20. **R19 — Roleplay Regression**
21. **R20 — Fantasy Market Festival**
22. **R21 — Analytics**
23. **R22 — Closed Playtest**
24. **R23 — Small Commercial Beta**

No milestone should be skipped because a later feature appears more exciting.

---

# 17. Final Roadmap Decision

Recommended owner approval statement:

```text
I approve Option F and the milestone sequence in this roadmap.

Keep Phase 6.1 enemies for review.
Disable and defer Phase 6.2 Break.
Do not add Brakk, boss phases, advanced combat systems, secondary minigames, elections, housing, parties, guilds, raids, PvP, auction house, or expanded monetization unless I explicitly approve a future milestone.

Begin with R0 only and stop after its documentation deliverables are complete.
```

---

# 18. Final Product Standard

The roadmap succeeds when Zero to Hero becomes a small but complete game rather than a collection of disconnected systems.

The required final loop is:

> Spawn → Train → Improve → Socialize → Adventure → Earn → Return → Repeat

The game should feel:

- immediately understandable
- visually readable
- socially inviting
- technically stable
- mobile-safe
- expandable
- commercially testable

The project does not need every idea before launch.

It needs one strong, connected, polished promise:

> Train like a hero. Live your fantasy. Build your legend.
