# One Minigame Per Training Zone Plan

## Purpose

Define the first playable minigame for each training-stat zone and map the user's ideas into the existing Roblox architecture.

This is gameplay planning. It does not replace `docs/roblox/training_zone_recreation_spec.md`, which controls visual and spatial direction for the training districts.

## Existing Document Coverage

The current docs already provide:

- Five training stats and five matching training districts.
- A visual/spatial plan for each zone, including the central activity pad and secondary activity areas.
- A complete server-authoritative Strength Forge timing minigame.
- Clear rules that clients may present training activities but must not grant stats, XP, currency, loot, or final reward multipliers.

The current docs did not yet provide:

- Implementation-ready prompts for Guardian Pulse, Skyline Rush, Pace Trial, or Rune Alignment.
- A shared handler shape for more than one training minigame type.
- MVP acceptance criteria for the four non-Power minigames.

## Current State

- Power already has the canonical Strength Forge timing minigame.
- The other four training zones have visual district shells and activity areas, but not working minigames.
- `TrainingService` owns server-authoritative Training XP.
- `TrainingStationService` owns prompt binding, distance checks, cooldowns, challenge state, server-side timing validation, and approved reward payloads for Strength Forge.
- `StrengthForgeMinigame.client.luau` is presentation/input only.

## Build Rule

Do not build all four missing minigames in one large change.

Build one flagship minigame per zone, one milestone at a time:

1. Vitality - Guardian Pulse
2. Agility - Skyline Rush
3. Endurance - Pace Trial
4. Control - Rune Alignment

Power - Forge Strike already exists as the first working Strength Forge version.

## Shared Architecture Direction

Use the current server-authoritative training pattern:

- ProximityPrompt starts the station challenge.
- Server creates challenge state and sends an approved start payload.
- Client renders the minigame and submits simple input events.
- Server validates timing, distance, checkpoints, sequence, score, and completion.
- Server awards XP through `TrainingService.AwardTrainingXP`.
- Client receives only approved result/reward payloads.

Recommended refactor before adding the second minigame:

- Keep `TrainingStationService` as the station and prompt owner.
- Add typed minigame handlers instead of hardcoding every rule into one timing-bar path.
- Handler IDs: `ForgeStrike`, `GuardianPulse`, `SkylineRush`, `PaceTrial`, `RuneAlignment`.
- Each handler exposes:
  - `CreateChallenge(player, station, now)`
  - `BuildClientStartPayload(challenge)`
  - `HandleClientAction(player, challenge, payload, now)`
  - `IsComplete(challenge)`
  - `CalculateRewardMultiplier(challenge)`

Avoid trusting client-submitted scores, distances, completion state, XP amounts, or reward multipliers.

## Flagship Minigames

### Power - Forge Strike

Status: implemented as the current Strength Forge minigame.

Stat: `Power`

Core mechanic: timing marker, target/perfect zone, 3 reps, server calculates multiplier and awards Power XP.

Near-term improvement: keep validation, present it as `Forge Strike`, and improve visual feedback later.

### Vitality - Guardian Pulse

Stat: `Vitality`

Core fantasy: protect the Heartstone by raising guard against energy waves.

Core mechanic: server creates a directional pulse sequence; client shows the incoming direction around a circular ward; player faces or selects the direction and guards on time; perfect guards strengthen the Heartstone; early, late, or wrong blocks reduce the challenge meter; surviving the sequence completes the activity.

Mobile input: four direction buttons or a rotating shield selector plus a Guard button.

Server-owned validation: pulse sequence and timings, accepted direction, guard window, mistake count, completion, and reward multiplier.

MVP acceptance:

- Starts from the Vitality zone.
- Directional pulses appear clearly.
- Correct timed guards advance progress.
- Wrong or late guards are handled safely.
- Vitality XP is awarded only by server completion.
- Leaving range cancels the challenge.

### Agility - Skyline Rush

Stat: `Agility`

Core fantasy: short tower route with jumps, platforms, and checkpoints.

Core mechanic: server starts a timed route challenge; client shows route/checkpoint UI; player touches checkpoints in order; server validates order, time, timeout, and distance; finish ring completes the activity.

Mobile input: standard movement and jump, with route UI only.

Server-owned validation: start time, checkpoint order, touch ownership, finish time, timeout, and multiplier from time plus missed/fallback checkpoints.

MVP acceptance:

- Starts from the Agility zone.
- Checkpoints validate in order.
- Skipping ahead fails or is ignored.
- Finish ring completes the challenge.
- Agility XP is awarded only by the server.
- Falling cannot strand the player.

### Endurance - Pace Trial

Stat: `Endurance`

Core fantasy: one-lap or short-loop Heroes' Track with temporary pacing/stamina.

Core mechanic: server starts a track challenge; client displays pace/stamina feedback; player passes checkpoints around the oval in order; server tracks checkpoint timing bands; pacing score is server-derived; completion awards Endurance XP based on consistency.

Mobile input: standard movement, with an optional large Sprint button if needed.

Server-owned validation: checkpoint order, time between checkpoints, total lap time, pace consistency score, timeout, and multiplier.

MVP acceptance:

- Starts from the Endurance zone.
- Checkpoints are obvious.
- One-lap completion works.
- Skipped checkpoints are rejected.
- Endurance XP is awarded only by the server.
- Route remains group-friendly.

### Control - Rune Alignment

Stat: `Control`

Core fantasy: align rotating magical rings around the Arcane Shrine.

Core mechanic: server creates a ring target sequence; client displays rotating rings/windows; player taps to stop each ring at the correct moment; later reps can move faster, opposite direction, or use smaller windows; a successful sequence activates the shrine and awards Control XP.

Mobile input: one large Align button, with an optional ring selector if multiple rings are active.

Server-owned validation: target sequence, speeds/directions, server start time, stop timing, hit/perfect/miss, completion, and reward multiplier.

MVP acceptance:

- Starts from the Control zone.
- Ring UI is readable on mobile.
- Server validates stop timing.
- Successful sequence completes the challenge.
- Control XP is awarded only by the server.
- Client cannot submit final score or multiplier.

## Suggested Milestone Prompts

### Prompt A - Training Minigame Handler Refactor

Refactor the existing Strength Forge challenge path into a typed server-authoritative minigame handler structure without changing Strength Forge behavior.

Acceptance:

- Strength Forge still starts, validates, completes, and awards Power XP.
- No duplicate reward paths are introduced.
- New handler structure supports at least five minigame IDs.
- Tests or manual checks cover old Strength Forge behavior.

### Prompt B - Guardian Pulse

Implement only Guardian Pulse for Vitality using the typed handler structure.

Acceptance:

- Vitality prompt starts Guardian Pulse.
- Server validates direction and timing.
- Client renders mobile-readable direction/guard UI.
- Vitality XP is server-approved.
- Leaving range cancels the challenge.

### Prompt C - Skyline Rush

Implement only Skyline Rush for Agility using route checkpoints.

Acceptance:

- Agility prompt starts the route challenge.
- Checkpoints validate in order on the server.
- Finish ring completes the activity.
- Agility XP is server-approved.
- Falling/reset behavior is documented.

### Prompt D - Pace Trial

Implement only Pace Trial for Endurance using track checkpoints and pacing score.

Acceptance:

- Endurance prompt starts the lap challenge.
- Checkpoints validate in order.
- Pacing score is server-derived.
- Endurance XP is server-approved.
- Track remains group-friendly.

### Prompt E - Rune Alignment

Implement only Rune Alignment for Control using ring timing.

Acceptance:

- Control prompt starts the ring challenge.
- Server validates stop timing.
- Client displays mobile-readable ring UI.
- Control XP is server-approved.
- Client cannot submit final score or multiplier.

## Roleplay Hooks To Preserve

- Strength Forge: blacksmith, weapon preview, armour dye, warrior training yard.
- Guardian Grove: clinic, potion shop, healer/alchemist roleplay.
- Skyward Tower: courier guild, scout HQ, race leaderboard/lookout.
- Heroes' Track: sports, racing, guild competition, event ground.
- Arcane Shrine: mage academy, meditation, aura preview, scholar/library.

These are visual/social hooks only for now. Do not build shops, cosmetics, housing, guilds, monetisation, or larger economy features as part of the first minigame pass.

## Documentation Gaps Closed By This Plan

Existing docs define the five training stats, zones, visual identity, broad minigame concepts, server authority, and Strength Forge pattern.

This plan adds one flagship minigame per stat, implementation order, validation boundaries, MVP acceptance criteria, and a recommended handler architecture.
