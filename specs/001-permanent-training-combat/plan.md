# Implementation Plan

## Technical context

Existing stack:

- React 18
- TypeScript
- Vite
- Redux Toolkit
- Chakra UI
- Framer Motion
- Dexie/IndexedDB
- Three.js proof in a standalone public HTML file

New development dependencies:

```bash
npm install three
npm install -D vitest @vitest/coverage-v8 jsdom \
  @testing-library/react @testing-library/jest-dom \
  @testing-library/user-event playwright
```

Optional after vertical-slice validation:

```bash
npm install vite-plugin-pwa
```

## Target architecture

```text
src/
  app/
    store.ts
    hooks.ts
  domain/
    training/
      types.ts
      normalizeEvent.ts
      creditPolicy.ts
      movementCatalog.ts
    progression/
      rules.ts
      interpolateMilestone.ts
      deriveStats.ts
      unlockAbilities.ts
    combat/
      types.ts
      rules.ts
      deriveCombatBuild.ts
      calculateDamage.ts
      resolveHit.ts
  persistence/
    database.ts
    migrations/
      v1-to-v2.ts
    repositories/
      trainingRepository.ts
      battleRepository.ts
      userRepository.ts
  features/
    training/
      trainingSlice.ts
      selectors.ts
    progression/
      progressionSlice.ts
      selectors.ts
    battle/
      battleSlice.ts
      selectors.ts
  game/
    BattleGame.ts
    BattleHost.tsx
    scenes/
      BattleScene.ts
    entities/
      PlayerController.ts
      BossController.ts
    systems/
      InputSystem.ts
      CombatSystem.ts
      FeedbackSystem.ts
    assets/
      assetManifest.ts
  components/
    ...
```

## Phase 0 — Stabilize the brownfield source

Deliverables:

- Correct broken store import paths.
- Align `UserData` with user state.
- Replace date lookup with `localDate`.
- Confirm `npm run build` succeeds from source.
- Add Vitest.
- Add a fixture database containing representative v1 data.
- Update misleading completion checklist.

Exit gate:

```bash
npm run build
npm test
```

Both pass.

## Phase 1 — Training ledger and migration

Deliverables:

- Add `TrainingEvent` model.
- Add Dexie v2 schema.
- Convert v1 exercise records.
- Preserve timestamps and generate local dates.
- Add verification and source fields.
- Add credit policy.
- Increment `ledgerRevision` after accepted training writes.
- Provide save export before migration testing.

Exit gate:

- Existing fixture migrates without record loss.
- Today's training reloads correctly.
- Raw and credited volume are both visible.

## Phase 2 — Permanent attribute engine

Deliverables:

- Movement catalog.
- Versioned milestone curves.
- Pure milestone interpolation.
- Attribute derivation.
- Ability unlock derivation.
- Snapshot repository and invalidation.
- Typed Redux selectors.
- Replace `totalPower` displays with attribute cards.

Exit gate:

- 0, 100, 1,000, 10,000 and 50,000 push-up fixtures return expected Strength.
- Reload preserves the same stats.
- Battle cannot mutate stats.
- Running changes Endurance/Agility without changing Strength.

## Phase 3 — Integrate the battle runtime

Deliverables:

- Move Three.js and TWEEN code into `src/game/`.
- Bundle imports through Vite.
- Render battle within `/battles/:bossId`.
- Remove trusted URL stat parameters.
- Pass a frozen `CombatBuildSnapshot` to the game.
- Use one battle result callback.
- Persist one `BattleRecord`.
- Remove or deprecate disconnected battle state.

Exit gate:

- Victory and defeat persist after reload.
- Correct boss ID is stored.
- Resource use remains temporary.
- Refreshing during combat records an abandoned battle or cleanly resumes according to the chosen rule.

## Phase 4 — Rewarding action vertical slice

Deliverables:

- One original boss.
- Light attack combo.
- Heavy attack.
- Titan Impact milestone ability.
- Boss telegraph and bounded evade window.
- Hit stop.
- Camera shake.
- Impact particles.
- Knockback.
- Ground crack/decal for high Strength.
- Damage-number tiers.
- Reduced-effects accessibility toggle.
- Replay button.

Initial balance target:

| Build | Expected first-boss experience |
|---|---|
| New player | 20–40 successful light hits |
| Running specialist | Many fast hits, generous stamina and evade |
| Moderate strength | 4–8 heavy hits |
| 10,000 push-up Strength milestone | Titan Impact one-shot |

The exact numbers are configuration, not hard-coded component logic.

Exit gate:

- Five-person feel test completed.
- Strength increase is perceived without reading numbers.
- Running build feels capable rather than simply weak.
- Titan Impact produces a reliable, dramatic one-shot against the first boss.

## Phase 5 — Offline and release hardening

Deliverables:

- PWA manifest and service worker.
- Offline core-loop test.
- Save export/import.
- Mobile navigation.
- Performance budget.
- Error boundary around the game canvas.
- Asset licence registry.
- Original product terminology.
- Event instrumentation interface that works locally and can connect to analytics later.

Exit gate:

- Installable.
- Works offline after first load.
- No TypeScript errors.
- Domain rules covered by tests.
- Playwright core flow passes at a mobile viewport.

## Migration strategy

1. Copy the v1 database.
2. Open with version 2 migration in automated fixture.
3. Count users, exercises/training events and battles before and after.
4. Verify sampled records field by field.
5. Rebuild stat snapshots.
6. Leave old table intact for one schema version.
7. Only then remove deprecated code and old table.

## Rollback strategy

- Keep the v1 table during V2.
- Feature-flag the new progression engine.
- Retain old dashboard read-only behind a developer flag.
- Export a save before enabling migration for beta testers.

## Risks

| Risk | Mitigation |
|---|---|
| Players fake exercise | Self-reported label; single-player first; no competitive rewards |
| Extreme repetition incentives | Credited-volume caps and long-term milestones |
| Combat feels cheap | Vertical slice focuses on feedback before content |
| Three.js code becomes unmanageable | Typed modules and engine reassessment gate |
| Balance changes invalidate progress | Rebuild stats from ledger with versioned rules |
| Existing data loss | Fixture migration, export and delayed old-table removal |
| Scope expands to platform features | Constitution and explicit out-of-scope list |
