# ZERO TO HERO — CODEX BUILD SYSTEM

## Active Roadmap Override

Codex must follow `docs/roblox/future_milestone_review_2026-06-30.md` as the active owner-controlled future roadmap.

That roadmap replaces the previous combat-heavy sequence for future work. The old numbered prompts in this file are archived implementation references only unless the active roadmap or direct owner instruction explicitly selects one.

Current active sequence starts at:

1. `R0 - Roadmap and Scope Recovery`
2. `R1 - Disable and Isolate Break`
3. `R2 - Legacy Cleanup`
4. `R3 - Combat Presentation Polish`
5. `R4 - Training Handler Refactor`

Continue afterward only in the order listed in `future_milestone_review_2026-06-30.md`.

Do not skip ahead to Brakk, Break extensions, new minigames, roleplay systems, mobile claims, or monetisation because they appear in older prompts or the master spec. A feature is in scope only when the direct owner task or active roadmap milestone says it is.

## Purpose

This document turns the Roblox game plan into a controlled sequence of Codex tasks.

The goal is to avoid asking Codex to “build the whole game.” Instead, Codex should complete one verified milestone at a time, update progress files, and stop when acceptance criteria are met.

The existing mobile app remains untouched and is used only as a product baseline.

---

# 1. REPOSITORY STRUCTURE

Use this structure unless the repository already has a better equivalent:

```text
/
  src/                         Existing mobile app
  public/                      Existing mobile assets
  docs/
    roblox/
      master_game_spec.md
      visual_direction.md
      architecture.md
      progression_tracker.md
      decision_log.md
      manual_test_checklist.md
      known_issues.md
  roblox/
    default.project.json
    src/
      client/
        Controllers/
        UI/
        Input/
        Effects/
      server/
        Services/
      shared/
        Config/
        Types/
        Utility/
        Remotes/
    tests/
    assets/
      reference/
        roblox/
          01_ascension_grounds_reference.png
          02_strength_forge_reference.png
          03_stats_ui_reference.png
          04_reward_popup_reference.png
          05_enemy_area_reference.png
          06_mobile_hud_reference.png
```

Do not move the existing mobile app into a new folder unless explicitly instructed.

---

# 2. SOURCE OF TRUTH ORDER

Codex must use this priority order when documents conflict:

1. Current task prompt
2. `docs/roblox/future_milestone_review_2026-06-30.md`
3. `docs/roblox/progression_tracker.md`
4. Owner-approved milestone specification
5. `docs/roblox/master_game_spec.md`
6. `docs/roblox/architecture.md`
7. `docs/roblox/visual_direction.md`
8. Existing implementation
9. Reference images
10. Archived prompts in this file

Reference images control only:

- Mood
- Colour direction
- Composition
- Scale
- Shape language
- UI hierarchy

Written specifications control:

- Mechanics
- Rewards
- Progression
- Security
- Architecture
- Naming
- Acceptance criteria

---

# 3. NON-NEGOTIABLE RULES

Codex must always follow these rules:

- Do not rewrite or destabilise the existing mobile app.
- Keep Roblox work inside `/roblox` and `/docs/roblox`.
- Use server-authoritative progression, rewards, inventory, currency, and damage.
- Never trust client-submitted XP, Gold, item ownership, or workout values.
- Build mobile-first UI and controls.
- Use reusable modules and configuration instead of giant scripts.
- Use placeholders where art is missing.
- Keep placeholders replaceable.
- Do not add systems outside the current milestone.
- Do not begin the next milestone until the current one passes acceptance criteria.
- Update the progress tracker after every completed task.
- Record important implementation decisions in the decision log.
- Record unresolved bugs in the known-issues file.
- Do not claim a system is complete unless it has been tested or a manual test has been documented.

---

# 4. PROGRESS TRACKER FORMAT

Create and maintain:

`docs/roblox/progression_tracker.md`

Use this format:

```markdown
# Roblox Development Progress

## Current Phase
Phase 1 — Project Foundation

## Current Milestone
1.2 — Shared Configuration

## Status
IN PROGRESS

## Completed
- [x] Repository inspected
- [x] Roblox folder created
- [ ] Shared stat configuration created

## Acceptance Criteria
- [ ] Five stats exist in one config module
- [ ] XP formula is centralised
- [ ] No client authority over XP
- [ ] Manual test instructions written

## Files Changed
- `roblox/src/shared/Config/StatConfig.luau`

## Tests Run
- Not run yet

## Blockers
- None

## Next Task
Create PlayerProfile defaults and validation.
```

Allowed statuses:

- NOT STARTED
- IN PROGRESS
- BLOCKED
- READY FOR TEST
- COMPLETE

---

# 5. DECISION LOG FORMAT

Create and maintain:

`docs/roblox/decision_log.md`

Use:

```markdown
## YYYY-MM-DD — Decision title

**Decision:**  
What was decided.

**Reason:**  
Why this direction was chosen.

**Impact:**  
Files, systems, or future work affected.

**Revisit when:**  
Condition that would justify reconsidering the decision.
```

---

# 6. UNIVERSAL CODEX TASK TEMPLATE

Use this template for every task:

```text
You are working on the Zero to Hero Roblox project.

Read first:
- docs/roblox/master_game_spec.md
- docs/roblox/architecture.md
- docs/roblox/visual_direction.md
- docs/roblox/progression_tracker.md
- docs/roblox/decision_log.md
- docs/roblox/known_issues.md

Current task:
[ONE SPECIFIC TASK]

Constraints:
- Do not modify the existing mobile app.
- Do not implement future systems.
- Keep logic modular and server-authoritative.
- Use placeholders where required.
- Follow the source-of-truth order.
- Update progression_tracker.md.
- Update decision_log.md for any meaningful design choice.
- Update known_issues.md for unresolved problems.

Acceptance criteria:
[MEASURABLE CRITERIA]

Before coding:
1. Inspect relevant files.
2. State the implementation approach.
3. List files to create or modify.
4. Identify risks or assumptions.

Then implement.

After coding:
1. Summarise changes.
2. List files changed.
3. State tests run.
4. State manual Studio test steps.
5. Update progression_tracker.md.
6. Stop. Do not begin another milestone.
```

---

# 7. MASTER INITIALISATION PROMPT

Use this first.

```text
You are working on the existing Zero to Hero repository.

The existing React/Vite mobile app is the current training companion baseline. Do not move, rewrite, delete, or destabilise it.

Create a separate Roblox project foundation under `/roblox`.

Read:
- docs/roblox/master_game_spec.md
- docs/roblox/visual_direction.md
- all images under roblox/assets/reference/roblox/

Your first task is project inspection and setup only.

Create or update:
- roblox/default.project.json
- roblox/src/client/
- roblox/src/server/
- roblox/src/shared/
- roblox/tests/
- docs/roblox/architecture.md
- docs/roblox/progression_tracker.md
- docs/roblox/decision_log.md
- docs/roblox/manual_test_checklist.md
- docs/roblox/known_issues.md

Requirements:
- Keep Roblox client, server, and shared logic separated.
- Use Rojo-compatible structure where practical.
- Document how to open the project in Roblox Studio.
- Do not implement gameplay yet.
- Do not alter the existing mobile app.
- Add placeholder folders for Config, Services, Controllers, UI, Input, Effects, Types, Utility, and Remotes.

Acceptance criteria:
- Roblox project foundation exists.
- Existing mobile app remains unchanged.
- Architecture document explains responsibilities.
- Progress tracker shows Phase 0 complete.
- Setup instructions are included.
- No gameplay systems are added.

Inspect first, then implement, then stop.
```

---

# 8. PHASE 1 — FOUNDATION AND PLAYER DATA

## Prompt 1.1 — Shared Stat Configuration

```text
Implement only the shared training-stat configuration.

Create one source of truth for:
- Power
- Vitality
- Agility
- Endurance
- Control

Each stat must define:
- Id
- DisplayName
- Description
- Colour token
- Icon placeholder
- Base XP
- XP exponent
- Maximum test level
- Derived-stat responsibilities

Create helper functions for:
- XP required for a level
- Total XP required to reach a level
- Valid stat-name checks

Use:
RequiredXP = BaseXP × Level^1.35

Keep the formula configurable.

Acceptance criteria:
- All five stats exist in one shared config.
- No duplicated stat definitions.
- XP formula is pure and testable.
- Invalid stat names fail safely.
- Manual test examples are documented.
- Progress tracker updated.
```

## Prompt 1.2 — Player Profile Model

```text
Implement only the default player-profile model and validation.

Profile must contain:
- Version
- HeroLevel
- HeroXP
- Gold
- TrainingStats
- Equipment
- Inventory
- Campaign
- MobileLink
- RewardClaims

Use the five stats from StatConfig.

Requirements:
- Default profile factory
- Deep-copy safety
- Validation function
- Version field
- Migration placeholder
- No DataStore persistence yet

Acceptance criteria:
- New profile contains all expected fields.
- Each training stat begins at Level 0 and XP 0, with 0 effective earned stat value.
- Invalid or missing fields can be repaired or rejected safely.
- Default tables are not shared between players.
- Pure tests or documented test cases exist.
```

## Prompt 1.3 — Player Data Service

```text
Implement a server-authoritative PlayerDataService.

Responsibilities:
- Load profile
- Create default profile
- Keep session cache
- Save profile
- Release profile
- Expose safe server-side getters and mutators
- Prevent clients from directly writing profile data

Requirements:
- Safe failure handling
- BindToClose save attempt
- PlayerRemoving save
- Version-aware load path
- Clear warning logging
- Studio-safe development mode if DataStores are unavailable

Do not build gameplay rewards yet.

Acceptance criteria:
- New player receives a valid profile.
- Rejoining preserves data when Studio DataStore access is enabled.
- Failure does not silently erase data.
- Client cannot set profile values directly.
- Manual join/rejoin test documented.
```

---

# 9. PHASE 2 — TRAINING PROGRESSION

## Prompt 2.1 — Training Service

```text
Implement TrainingService only.

Responsibilities:
- Award Training XP on the server
- Validate stat name
- Apply XP
- Handle multiple level-ups
- Return a structured reward result
- Calculate Training Rank placeholder
- Record daily training totals
- Support diminishing-return tiers

Initial diminishing-return schedule:
- First 20 minutes: 100%
- Next 20 minutes: 70%
- Next 30 minutes: 40%
- Beyond 70 minutes: 15%

Do not implement a station yet.

Acceptance criteria:
- XP can only be awarded by server code.
- Multiple level-ups work.
- Invalid rewards fail safely.
- Diminishing-return multiplier is deterministic.
- Reward result includes old level, new level, XP gained, and level-up count.
- Pure tests or documented cases exist.
```

## Prompt 2.2 — Training Station Framework

```text
Create a reusable training-station framework.

The framework must support:
- Station Id
- Stat trained
- Interaction range
- Cooldown
- Duration
- Base XP
- Optional minigame result
- Server validation
- Reward callback
- Client reward display event

Use ProximityPrompt or a similarly mobile-friendly interaction.

Create one placeholder station instance configuration but do not build the final Strength Forge minigame yet.

Acceptance criteria:
- One station can be configured without custom one-off scripts.
- Server validates player distance and cooldown.
- Rapid spam does not award repeated XP.
- Client receives only approved result data.
- Station logic can support all five future stations.
```

## Prompt 2.3 — Strength Forge Minigame

```text
Implement the first complete training activity: Strength Forge.

Visual reference:
- roblox/assets/reference/roblox/02_strength_forge_reference.png

Use the image only for:
- Warm orange lighting
- Stone and metal mood
- Forge-core focal point
- Power-training theme

Mechanic:
- Player enters the station.
- A timing marker moves across a target zone.
- Player activates at the correct moment.
- Three successful repetitions complete one set.
- Accuracy determines reward quality.
- Server validates timing windows using server-issued challenge data.
- Client may animate the bar but cannot choose the final reward.

Reward:
- Power XP only
- Base reward configurable
- Accuracy multiplier capped
- Cooldown after completion

Acceptance criteria:
- Works with mouse, keyboard, and touch.
- Client spoofing cannot directly grant XP.
- Three repetitions complete a set.
- Reward popup appears.
- Power XP persists.
- Station can be reset cleanly after leaving.
```

## Prompt 2.4 — Stats HUD

```text
Implement the mobile-first Training Stats HUD.

Visual reference:
- roblox/assets/reference/roblox/03_stats_ui_reference.png

Show:
- Power
- Vitality
- Agility
- Endurance
- Control
- Current level
- Current XP
- XP required
- Training Rank

Requirements:
- Responsive sizing
- Large readable text
- Animated XP changes
- Level-up highlight
- No tiny desktop-only layout
- Data supplied from approved replicated profile state

Acceptance criteria:
- Five stats display correctly.
- XP changes animate after Strength Forge completion.
- UI scales on common phone and desktop aspect ratios.
- UI does not expose server-only data.
```

## Prompt 2.5 — Reward Popup

```text
Implement a reusable reward-popup system.

Visual reference:
- roblox/assets/reference/roblox/04_reward_popup_reference.png

Support:
- Training XP
- Hero XP
- Gold
- Items
- Level-up emphasis
- Reward queue

Requirements:
- Small rewards do not block movement.
- Multiple rewards queue cleanly.
- Popup auto-dismisses.
- Rare rewards use stronger presentation.
- UI remains mobile readable.

Acceptance criteria:
- Strength Forge reward displays correctly.
- Multiple rewards do not overlap incorrectly.
- Level-up version is visually distinct.
- Queue clears without memory leaks.
```

---

# 10. PHASE 3 — ASCENSION GROUNDS GREYBOX

## Prompt 3.1 — Top-Down Layout

```text
Build only the greybox layout of the Ascension Grounds.

Visual reference:
- roblox/assets/reference/roblox/01_ascension_grounds_reference.png

Required layout:
- One large central circular plaza
- One central blue Ascension crystal placeholder
- Five district paths on one main floor
- Strength Forge
- Guardian Hall
- Agility Tower
- Endurance Track
- Control Shrine
- One main Broken Gate route leading out of the hub
- No four-gate layout
- No multi-floor maze
- Wide paths to avoid crowding

Use Roblox primitives and clearly named placeholder models.

Acceptance criteria:
- Player can understand the full hub from the central plaza.
- All five districts are visible or clearly signposted.
- Broken Gate route is obvious.
- Paths support groups of players without bottlenecks.
- No final art assets required.
- Layout is modular and replaceable.
```

## Prompt 3.2 — District Shells

```text
Create visual shells for the five training districts using primitives.

Use:
- Strength Forge: orange, metal, stone
- Guardian Hall: blue, fortified, defensive
- Agility Tower: purple, vertical, obstacle-focused
- Endurance Track: green, open, circular route
- Control Shrine: teal, precise, mystical

Do not implement the remaining minigames.

Acceptance criteria:
- Each district is recognisable by silhouette and colour.
- Strength Forge station remains functional.
- Districts do not obstruct navigation.
- Mobile performance remains acceptable.
- Every shell is grouped and named.
```

## Prompt 3.3 — Broken Gate Transition

```text
Build the transition from the safe Ascension Grounds to the enemy area.

Visual reference:
- roblox/assets/reference/roblox/05_enemy_area_reference.png

Use for:
- Darker mood
- Red lighting accents
- Ruined stone
- Clear danger boundary
- Visible route toward the future boss

Do not add enemies yet.

Acceptance criteria:
- Safe and dangerous areas are visually distinct.
- Transition is readable without UI text.
- Route is wide enough for combat.
- Spawn and social areas remain protected.
```

---

# 11. PHASE 4 — COMBAT FOUNDATION

## Prompt 4.1 — Derived Combat Stats

```text
Implement shared derived-combat-stat formulas.

Initial outputs:
- MaxHP
- PhysicalDamage
- BreakDamage
- MaxStamina
- StaminaRecovery
- MoveSpeedBonus
- CriticalChance
- GuardEffectiveness
- SkillEffectiveness

Inputs:
- Training Stats
- Hero Level
- Equipment bonuses
- Class modifiers

Requirements:
- Centralised config
- Caps on movement speed and critical chance
- No runaway multiplication
- Pure testable functions

Acceptance criteria:
- Same input always returns same output.
- Caps are enforced.
- Equipment and training contributions are visible separately.
- Tests cover low, normal, and high stat cases.
```

## Prompt 4.2 — Player Combat Controller

```text
Implement the first playable sword-combat controller.

Actions:
- Basic Attack
- Guard
- Dodge

Requirements:
- Mouse, keyboard, and touch support
- Server-authoritative hit approval and final damage
- Attack cooldown validation
- Distance validation
- Stamina cost for dodge
- Guard state
- Client animation placeholders
- Clear hit feedback

Do not add skills yet.

Acceptance criteria:
- Player can attack a test dummy.
- Guard changes incoming damage.
- Dodge consumes stamina and has invulnerability or displacement rules defined.
- Spamming remotes does not bypass cooldowns.
- Mobile buttons work.
```

## Prompt 4.3 — Mobile Combat HUD

```text
Implement the combat HUD.

Visual reference:
- roblox/assets/reference/roblox/06_mobile_hud_reference.png

Show:
- HP
- Stamina
- Basic Attack
- Guard
- Dodge
- Skill 1 placeholder
- Skill 2 placeholder
- Ultimate placeholder
- Interact

Requirements:
- Thumb-friendly placement
- Responsive scaling
- Disabled-state feedback
- Cooldown display
- Combat controls hidden or reduced when not needed

Acceptance criteria:
- Core controls work on touch.
- Buttons do not overlap.
- Cooldowns are readable.
- HP and stamina update correctly.
```

## Prompt 4.4 — First Enemy

```text
Implement one server-controlled enemy: Lesser Slime.

Behaviour:
- Idle
- Detect
- Chase
- Attack
- Take damage
- Die
- Respawn

Requirements:
- Server owns health and rewards.
- Simple state machine.
- Attack telegraph.
- No per-frame expensive global loops.
- Reward only once per death.

Reward:
- Small Hero XP
- Small Gold chance
- No equipment yet

Acceptance criteria:
- Enemy can be defeated.
- Rewards grant once.
- Enemy does not continue attacking after death.
- Respawn works.
- Multiple players cannot duplicate rewards.
```

---

# 12. PHASE 5 — HERO PROGRESSION, LOOT, AND EQUIPMENT

## Prompt 5.1 — Hero XP and Gold

```text
Implement Hero XP, Hero Level, and Gold rewards.

Requirements:
- Separate from Training XP
- Server-authoritative
- Configurable level curve
- Multiple level-ups supported
- Structured reward result
- Reward popup integration

Acceptance criteria:
- Slime kill grants Hero XP.
- Hero Level can increase.
- Gold updates safely.
- Rejoin preserves progression.
```

## Prompt 5.2 — Item Configuration

```text
Create the initial 15-item configuration.

Slots:
- Weapon
- Armour
- Charm

Required fields:
- Id
- Name
- Slot
- Rarity
- StatBonuses
- PassiveId
- TradePolicy
- Source
- Description

Use:
- Common
- Rare
- Epic
- Mythic

Include named starter and Brakk-themed items.

Acceptance criteria:
- All items have unique IDs.
- Stat budgets follow the master spec.
- Invalid items fail validation.
- No old permanent stat names are introduced.
```

## Prompt 5.3 — Inventory and Equipment

```text
Implement server-authoritative inventory and equipment.

Actions:
- Add item
- Remove item
- Inspect item
- Equip item
- Unequip item
- Compare selected with equipped

Requirements:
- Ownership validation
- Slot validation
- Effective stats recalculate
- No client item creation
- Mobile-friendly UI

Acceptance criteria:
- Player can receive and equip a test sword.
- Wrong-slot equip fails.
- Effective stats update.
- Rejoin preserves inventory and equipped items.
```

## Prompt 5.4 — Loot Drops

```text
Implement configurable loot tables.

Support:
- Weighted item drops
- Gold
- Materials placeholder
- Guaranteed drops
- Per-player reward
- Duplicate reward protection

Update Lesser Slime to have a small Common-item chance.

Acceptance criteria:
- Drop rolls occur on the server.
- Loot reward appears in popup.
- Item enters inventory once.
- Drop table can be reused by future enemies and bosses.
```

---

# 13. PHASE 6 — BROKEN GATE VERTICAL SLICE

## Prompt 6.1 — Enemy Set

```text
Implement the remaining prototype enemies:
- Gate Hound
- Stone Shell
- Gate Sentinel

Each must use the reusable enemy framework but have distinct behaviour.

Acceptance criteria:
- Hound is fast and fragile.
- Stone Shell is slow and armoured.
- Sentinel guards or uses a clear defensive pattern.
- All use readable telegraphs.
- Rewards are server-controlled.
```

## Prompt 6.2 — Break System

```text
Implement the Break system.

Support:
- Break meter
- Break damage
- Broken state
- Temporary vulnerability
- Recovery
- UI indicator

Use Stone Shell as the first Break-focused enemy.

Acceptance criteria:
- Basic damage and Break damage are distinct.
- Break meter is server-owned.
- Broken state triggers once.
- Vulnerability ends correctly.
```

## Prompt 6.3 — Gatekeeper Brakk

```text
Implement Gatekeeper Brakk as the first boss.

Actions:
- Basic strike
- Heavy telegraphed slam
- Guard or armour phase
- Break meter
- Phase 2 below 50% HP
- Boss HP bar
- Victory reward

Requirements:
- Clear red telegraphs
- Server-owned health, phases, and rewards
- No unavoidable one-shot attacks
- Placeholder model and animations acceptable

Acceptance criteria:
- Boss encounter starts and resets cleanly.
- Phase transition works.
- Boss can be defeated.
- Rewards grant once.
- Death and re-entry behaviour are documented.
```

## Prompt 6.4 — Vertical Slice Flow

```text
Connect the full first loop:

1. Spawn in Ascension Grounds.
2. Complete Strength Forge.
3. See Power XP increase.
4. Enter Broken Gate route.
5. Defeat enemies.
6. Earn Hero XP, Gold, and item drops.
7. Equip an item.
8. Challenge Brakk.
9. Receive victory rewards.

Do not add new systems.

Acceptance criteria:
- Full loop works in one play session.
- Progress persists after rejoin.
- No blocker prevents completion.
- Manual end-to-end test checklist updated.
```

---

# 14. PHASE 7 — SIMULATED MOBILE APP CONNECTION

## Prompt 7.1 — Real Training Portal

```text
Implement the Real Training Portal in the Ascension Grounds.

Display:
Train for real. Power up faster.

Explain:
Verified workouts in the Zero to Hero mobile app can later award up to 10× the Training XP of a short Roblox activity.

Add:
- Simulate Foundation Strength Workout button
- Clear prototype label
- Reward preview

Do not implement HTTP or real authentication.

Acceptance criteria:
- Portal is easy to find.
- Panel is mobile readable.
- It clearly states that the current feature is simulated.
```

## Prompt 7.2 — One-Time Simulated Claim

```text
Implement a server-authoritative simulated mobile reward claim.

Reward:
- Power XP +500
- Vitality XP +300
- Control XP +100
- Hero XP +200
- Verified Trainee badge

Requirements:
- Unique claim ID
- Claim only once per profile unless developer reset
- Stored claim history
- Server validates claim
- Reward popup integration

Acceptance criteria:
- Claim works once.
- Rejoin does not allow duplicate claim.
- Developer reset procedure is documented.
- Architecture allows future replacement with backend claims.
```

---

# 15. PHASE 8 — ALPHA POLISH

## Prompt 8.1 — Onboarding

```text
Create a short onboarding flow.

Teach:
- Move
- Train at Strength Forge
- Open Stats
- Enter Broken Gate
- Attack
- Guard
- Dodge
- Equip item
- Challenge Brakk

Requirements:
- Skippable after first completion
- Mobile readable
- No long dialogue walls
- Progress saved

Acceptance criteria:
- New player can complete the loop without external explanation.
```

## Prompt 8.2 — Performance Review

```text
Audit the Roblox project for mobile performance.

Review:
- Per-frame loops
- remote traffic
- connection cleanup
- particle counts
- enemy AI update rate
- instance count
- UI scaling
- memory risks

Do not redesign gameplay.

Acceptance criteria:
- Findings documented.
- High-risk issues fixed.
- Remaining issues added to known_issues.md.
- Test procedure documented.
```

## Prompt 8.3 — Security Review

```text
Audit all remotes and valuable state changes.

Check:
- XP
- Gold
- inventory
- equipment
- damage
- boss rewards
- training rewards
- mobile simulated claim

Acceptance criteria:
- Every valuable mutation has server validation.
- Spam limits exist.
- Duplicate reward paths are closed.
- Findings and fixes are documented.
```

## Prompt 8.4 — Alpha Readiness Review

```text
Perform a final vertical-slice readiness review.

Verify:
- New player flow
- Save/load
- Strength Forge
- Stats HUD
- Reward popup
- Combat
- Enemy rewards
- Inventory
- Equipment
- Brakk
- Mobile simulation
- Mobile controls
- Error logs

Output:
- PASS / FAIL per system
- Critical blockers
- Non-critical polish issues
- Recommended release decision

Do not add new features.
```

---

# 16. PROMPTS TO AVOID

Do not use prompts like:

- Build the whole game.
- Make it like World of Warcraft.
- Create all classes, raids, and guilds.
- Make the image exactly.
- Finish the game.
- Add whatever you think is missing.

These cause uncontrolled scope, inconsistent architecture, and untestable output.

---

# 17. REVIEW PROMPT AFTER EVERY THREE TASKS

```text
Pause implementation and perform a project-health review.

Read:
- progression_tracker.md
- decision_log.md
- known_issues.md
- manual_test_checklist.md

Review:
- Architecture consistency
- Duplicate logic
- Security boundaries
- Mobile usability
- Test coverage
- Scope creep
- Unresolved blockers

Output:
1. What is working
2. What is fragile
3. What should be refactored now
4. What must not be built yet
5. Whether the project may continue to the next milestone

Do not add features.
```

---

# 18. BUG-FIX PROMPT

```text
Fix only the following verified problem:

[DESCRIBE BUG]

Evidence:
- Expected:
- Actual:
- Reproduction steps:
- Error log:
- Screenshot or file reference:

Requirements:
- Identify root cause.
- Make the smallest safe change.
- Do not redesign unrelated systems.
- Add or update a regression test or manual test.
- Update known_issues.md and progression_tracker.md.
- Stop after the fix.
```

---

# 19. VISUAL ITERATION PROMPT

```text
Improve only the visual presentation of:

[AREA OR UI]

Reference:
[IMAGE PATH]

Use the image for:
- [MOOD]
- [COLOUR]
- [COMPOSITION]
- [SHAPE LANGUAGE]

Do not copy:
- Exact assets
- Exact text
- Logos
- Recognisable characters
- Proprietary design details

Do not change:
- Mechanics
- Rewards
- architecture
- server authority
- player progression

Acceptance criteria:
- Visual improvement is clear.
- Mobile readability remains strong.
- Performance does not materially regress.
- Placeholder assets remain replaceable.
```

---

# 20. HOW TO USE THIS SYSTEM

1. Put the master game blueprint in `docs/roblox/master_game_spec.md`.
2. Put the visual guide in `docs/roblox/visual_direction.md`.
3. Add the reference images using the agreed filenames.
4. Run the Master Initialisation Prompt.
5. Run one numbered prompt at a time.
6. Open Roblox Studio and perform the manual test.
7. Report bugs with the Bug-Fix Prompt.
8. Do not move forward until the tracker says COMPLETE.
9. Run a project-health review after every three tasks.
10. Stop at the vertical slice before adding guilds, auction house, raids, expansions, or real mobile integration.

---

# 21. MVP COMPLETION DEFINITION

The first MVP is complete only when a new player can:

- Join
- Load a profile
- Train at Strength Forge
- Increase Power
- See the Stats HUD update
- Enter Broken Gate
- Fight enemies
- Earn Hero XP and Gold
- Receive an item
- Equip the item
- Defeat Gatekeeper Brakk
- Claim the simulated mobile reward once
- Leave and rejoin without losing valid progress
- Play the entire loop on mobile controls

Nothing beyond this is required to validate the concept.
