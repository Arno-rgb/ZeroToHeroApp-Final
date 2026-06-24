# Feature Specification: Permanent Training-Driven Action Combat

**Feature Branch**: `001-permanent-training-combat`  
**Status**: Draft for implementation  
**Feature Type**: Brownfield vertical slice

## Problem

The prototype records exercises and allows basic boss battles, but exercise produces a spendable generic power currency. That does not fulfil the product promise that real training permanently changes the player's in-game body and combat performance.

## Product promise

> Your body is the character build. What you train in real life permanently changes how you fight.

## Primary user story

As a player, I want my accumulated real-world exercise to permanently improve specific combat abilities so that months of training create a dramatic, visible difference when I fight enemies.

## User scenarios and acceptance criteria

### US1 — Permanent strength progression

Given a player with recorded push-ups, when the application derives the player's attributes, then the player's Strength score reflects credited lifetime push-up training.

Acceptance:

- Strength persists after refresh and device restart.
- Entering and leaving combat does not reduce Strength.
- Deleting a temporary battle session does not affect Strength.
- Rebuilding stats from the ledger produces the same result.

### US2 — Exercise-specific builds

Given two players with equal total training volume but different activities, when they enter the same battle, then their play styles differ.

Acceptance:

- Push-up-focused player has greater single-hit damage and knockback.
- Running-focused player has greater stamina, attack cadence and dodge capability.
- Core-focused player has greater defence and stagger resistance.
- Lower-body-focused player has greater poise and burst movement.
- No generic total-power score replaces these distinctions.

### US3 — Visible combat consequence

Given a player crosses a meaningful Strength milestone, when the player uses the associated attack, then the combat presentation visibly changes.

Acceptance:

- Milestone attacks have distinct animation and VFX.
- Damage numbers and boss reaction reflect the higher impact.
- The 10,000 credited lifetime push-up milestone unlocks `Titan Impact`.
- `Titan Impact` can defeat the first boss in one hit under default balance.
- The first boss remains replayable so the player can experience becoming overpowered.

### US4 — Action-style battle

Given the player starts a battle, when combat begins, then the player directly controls attacks and evasion rather than watching an automatic calculation.

Acceptance:

- Player can perform light attack, heavy attack and milestone ability.
- Boss telegraphs attacks.
- Player can evade during a bounded timing window.
- Combat includes hit stop, camera impulse, knockback and particles.
- Battle runs acceptably on a mid-range Android-class device.

### US5 — Safe credited progression

Given the player records an extreme volume in one day, when rewards are calculated, then the full activity remains in history but only the allowed amount is credited toward permanent game progression.

Acceptance:

- Recorded volume and credited volume are both visible.
- Credit policy is deterministic and versioned.
- User receives a clear explanation when volume is partially credited.
- The application never recommends completing extreme volume to unlock an immediate reward.

### US6 — Existing-user migration

Given an existing local database, when version 2 opens, then the existing user, exercise records and battle history remain accessible.

Acceptance:

- Existing exercises are converted into training events.
- Full timestamps are preserved.
- A date-only indexed field is generated.
- Old generic power is not silently treated as permanent Strength.
- Migration can be rerun safely in development fixtures.

### US7 — Persistent battle result

Given the player defeats a boss, when the app reloads, then the battle record and boss defeat remain.

Acceptance:

- Result stores the actual boss ID.
- Damage, duration, build snapshot and rule version are stored.
- Temporary stamina use does not modify permanent attributes.
- A failed or abandoned battle is also recorded correctly.

## Functional requirements

### Training ledger

- FR-001: Store every training activity as an immutable `TrainingEvent`.
- FR-002: A training event contains performed time, local date, exercise ID, raw volume, credited volume, source and verification tier.
- FR-003: Corrections create an adjustment event rather than silently rewriting history after sync features exist. For local MVP, edits may update the source record but MUST trigger a full stat rebuild and audit entry.
- FR-004: Existing exercises migrate into training events.

### Progression

- FR-010: Derive attributes through versioned diminishing-return curves.
- FR-011: Attribute derivation is a pure function.
- FR-012: Milestones unlock traits and abilities.
- FR-013: Permanent attributes are never decremented by combat.
- FR-014: A stat snapshot caches derived values and records the ledger revision and rules version.

### Combat

- FR-020: Combat reads a read-only `CombatBuildSnapshot` at battle start.
- FR-021: Light, heavy and special attacks scale differently.
- FR-022: Running-related attributes affect stamina, recovery, action speed and evade window.
- FR-023: Strength affects heavy damage, knockback and armour break.
- FR-024: Stability affects defence and stagger resistance.
- FR-025: Lower-body force affects poise, dash force and launch resistance.
- FR-026: Boss weaknesses and resistances affect results.
- FR-027: Combat writes one `BattleRecord` on completion.
- FR-028: Battle input values MUST NOT be trusted from URL query parameters.

### Presentation

- FR-030: Strength milestone attacks produce escalating feedback tiers.
- FR-031: Feedback tiers include at least hit stop, camera shake, particles, knockback and damage-number treatment.
- FR-032: Accessibility settings allow camera shake reduction and flash reduction.
- FR-033: The first vertical slice has one original hero silhouette and one original boss.

### Offline and persistence

- FR-040: Training and single-player combat work offline.
- FR-041: All schema changes use Dexie version migration.
- FR-042: Core progress survives page refresh and browser restart.
- FR-043: Export and import of local save JSON is available before public beta.

## Non-functional requirements

- NFR-001: Pure domain calculations have at least 90% branch coverage.
- NFR-002: No unresolved TypeScript errors.
- NFR-003: Battle maintains a target of 60 FPS and a minimum acceptable 30 FPS on the defined test device.
- NFR-004: First battle load after application shell is below 3 seconds on a normal mobile connection; offline repeat load below 1 second.
- NFR-005: Core controls are usable at 360 × 800 CSS pixels.
- NFR-006: All VFX respect reduced-motion or application accessibility settings.
- NFR-007: No core single-player feature requires a backend.

## Success measures

The vertical slice succeeds when:

1. At least 70% of five test users correctly explain how their real exercise changed combat.
2. At least four of five say the post-training hit feels materially stronger.
3. At least three of five voluntarily replay the first boss after receiving a milestone.
4. No tester confuses permanent attributes with spendable battle energy.
5. The complete loop works after going offline.

## Out of scope

Accounts, cloud sync, payments, PvP, guilds, raids, leaderboards, creator tools, marketplace, GPS validation, production camera verification, nutrition, AI coaching and multiple campaigns.
