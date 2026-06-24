# Existing Repository Audit

Repository audited: `Arno-rgb/zero-to-hero-fitness`

## Executive finding

This is not an empty idea. The repository already contains a usable fitness-app shell and a basic combat proof of concept. The central product thesis is present, but the current implementation treats exercise power as a consumable currency. That conflicts with the new requirement that physical training permanently changes the character.

The next build should be a brownfield refactor, not a rewrite.

## What already exists

### Application shell

- React 18, TypeScript and Vite
- Redux Toolkit state
- Chakra UI application pages
- React Router routes for dashboard, exercises, battles, profile, customization and testing
- Framer Motion
- Dexie/IndexedDB local persistence
- A production build committed in `dist/`

Relevant files:

- `src/main.tsx`
- `src/App.tsx`
- `src/store.ts`
- `src/utils/database.ts`

### Fitness systems

- Manual logging for push-ups, sit-ups, squats and running
- Repetition/distance input
- Self-selected form quality
- Daily goals and progress
- Experience rewards
- Streak fields
- A partial/mock MediaPipe exercise-counter implementation
- Local exercise history

Relevant files:

- `src/components/ExerciseTracker.tsx`
- `src/features/exercise/exerciseSlice.ts`
- `src/utils/database.ts`

### RPG systems

- User level, tier, title, energy and avatar customization
- Boss list
- Battle history table
- Defeated boss concept
- Tier progression concept
- Existing game-design and mobile-strategy documents

Relevant files:

- `src/features/user/userSlice.ts`
- `src/features/battle/battleSlice.ts`
- `src/components/BattleSystem.tsx`
- `game_design.md`
- `mobile_adaptation_strategy.md`

### Action-combat proof

`public/battle-game-3d.html` already contains:

- Three.js scene
- Player and boss objects
- Attack input
- Timed boss telegraph
- Left/right evade input
- Health, energy and power UI
- Hit and lunge tweens
- Victory/defeat result
- `postMessage()` result transmission

This is a mechanics proof. It is not yet a production game runtime.

## Critical gaps and defects

### P0 — Source stability

1. `src/features/user/userSlice.ts` and `src/features/exercise/exerciseSlice.ts` import `RootState` from `../store`, but the actual store is `src/store.ts`. From those folders the expected path is `../../store`.
2. `UserData` in `src/utils/database.ts` does not define `energy` or `maxEnergy`, while `userSlice.ts` creates and reads both properties.
3. The package test script intentionally exits with an error:
   `echo "Error: no test specified" && exit 1`.
4. The checklist marks testing complete even though there is no real automated test runner.
5. The committed `dist/` can hide a broken current source tree because it may have been generated before later source edits.

### P0 — Exercise retrieval

Exercise records are saved with a full ISO timestamp. `getExercisesByDate()` performs an exact compound-index lookup using a date-only value. Those values do not match, so today's records can fail to reload.

Required fix:

- Store `performedAt` as ISO timestamp.
- Store a separate indexed `localDate` as `YYYY-MM-DD`.
- Query `[userId+localDate]`.

### P0 — Battle persistence

`BattleSystem.tsx` opens the battle in a new browser tab. The battle page sends a result through `postMessage()`, but the React component shown in the repository does not install a corresponding message listener.

Consequences:

- Used power and energy are not committed back to Redux or Dexie.
- Victory is not reliably written to battle history.
- A defeated boss may return after reload.
- The result sends `bossName` in a field named `bossId`.
- `postMessage(..., '*')` has no origin restriction.

### P0 — Wrong progression model

The current exercise slice has one `totalPower` value. Push-ups, sit-ups and squats all add to it, running does not. Battle attacks subtract from it.

The new game requires:

- An immutable lifetime activity ledger
- Separate attributes by training type
- Permanent stats that combat cannot reduce
- Temporary combat resources separated from training progress

### P1 — Combat logic gaps

- Boss weakness is passed into the damage function but not used.
- The Redux `battleSlice` and standalone Three.js battle use separate sources of truth.
- The React battle page contains unused modal and local battle state.
- Player attacks are one fixed action despite quick/power/special concepts elsewhere.
- The current scene uses primitive cubes and minimal feedback.
- Boss attacks can be evaded repeatedly by spamming input during the telegraph.
- Damage and resource values come from editable URL parameters.
- There is no deterministic seeded simulation for testing.

### P1 — Progression and safety gaps

- Raw exercise volume maps almost linearly to power.
- There are no diminishing returns.
- No credited-volume policy separates recorded work from game progression.
- No per-exercise recovery or anomaly rules exist.
- Streak increments on any new date and does not verify consecutive days.
- Manual form quality can be set by the player and is treated as a multiplier.
- No verification tier distinguishes self-reported from sensor-supported activity.

### P1 — Data model gaps

- Exercise records do not preserve source, verification, credited volume or rule version.
- Permanent stats are not derived from the exercise ledger.
- No stat snapshot or migration version exists.
- User state is duplicated between Redux and Dexie without a consistent persistence strategy.
- Battle records cannot reproduce the combat calculation used.

### P2 — Product and presentation gaps

- Placeholder images remain.
- The app and code use commercial references to another entertainment property.
- There is no original visual identity.
- No installable PWA configuration is visible.
- Mobile navigation is desktop-oriented.
- There are no analytics events for the core loop.

## Keep, refactor or remove

| Existing area | Decision |
|---|---|
| React/Vite application shell | Keep |
| Redux Toolkit | Keep, but use typed selectors and domain reducers |
| Chakra UI menus and forms | Keep for the fitness shell |
| Dexie | Keep and migrate to version 2 |
| Exercise logger | Refactor into immutable training events |
| MediaPipe mock | Keep behind a feature flag; do not call it verification |
| `totalPower` | Remove after migration |
| User energy | Keep only as temporary combat stamina/energy |
| Redux battle slice | Replace with one typed battle session model |
| Standalone battle HTML | Refactor into app-controlled TypeScript modules |
| Three.js | Keep for the first vertical slice because it already works |
| Placeholder art | Replace before public marketing |
| Existing test page | Retain only as a developer diagnostics screen |
| Current TODO checklist | Replace with Spec Kit tasks |

## Recommended first milestone

A player logs push-ups, receives a permanent Strength increase, reloads the app, enters combat, and deals visibly more damage than before. At the 10,000-lifetime-push-up milestone, the player unlocks a high-impact attack capable of one-shotting the first boss. Running instead improves attack cadence, stamina and dodge performance but does not grant the same raw hit damage.

That single vertical slice proves or disproves the product.
