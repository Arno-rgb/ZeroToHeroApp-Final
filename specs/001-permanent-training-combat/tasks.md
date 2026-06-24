# Tasks: Permanent Training-Driven Action Combat

Tasks are ordered by dependency. `[P]` means parallel after its prerequisite phase is complete.

## Phase 0 — Stabilization

- [ ] T001 Create branch `001-permanent-training-combat`.
- [ ] T002 Export a representative v1 IndexedDB save and add anonymized migration fixture.
- [ ] T003 Fix `RootState` imports in user and exercise slices.
- [ ] T004 Add `energy` and `maxEnergy` to the persisted user interface and initialization path.
- [ ] T005 Introduce `performedAt` and `localDate`; repair today's-exercise query.
- [ ] T006 Remove stale comments and unused battle modal/local state.
- [ ] T007 Install and configure Vitest.
- [ ] T008 Replace failing placeholder `npm test` script.
- [ ] T009 Add build/typecheck CI command.
- [ ] T010 Verify `npm run build` and `npm test` pass.

## Phase 1 — Ledger and persistence

- [ ] T011 Define `TrainingEvent`, verification, source and movement-family types.
- [ ] T012 Create Dexie v2 schema.
- [ ] T013 Implement v1 exercise-to-training-event migration.
- [ ] T014 Add migration count and sample validation.
- [ ] T015 Implement `trainingRepository`.
- [ ] T016 Implement versioned credited-volume policy.
- [ ] T017 Store both raw and credited volume.
- [ ] T018 Increment user ledger revision after training changes.
- [ ] T019 Add local save export/import.
- [ ] T020 Add migration and repository tests.

## Phase 2 — Progression domain

- [ ] T021 [P] Create movement catalog configuration.
- [ ] T022 [P] Create initial milestone curve configuration.
- [ ] T023 Implement milestone interpolation as a pure function.
- [ ] T024 Implement attribute derivation from ledger.
- [ ] T025 Implement ability milestone unlocks.
- [ ] T026 Implement `StatSnapshot` cache and rebuild.
- [ ] T027 Implement typed progression selectors.
- [ ] T028 Replace generic `totalPower` UI with permanent attribute UI.
- [ ] T029 Display raw versus credited progress.
- [ ] T030 Add boundary, monotonicity and determinism tests.
- [ ] T031 Add fixture tests for push-up and running specialists.

## Phase 3 — Combat domain

- [ ] T032 Define combat rules and `CombatBuildSnapshot`.
- [ ] T033 Implement derived health, stamina, speed, evade, damage, poise and knockback.
- [ ] T034 Implement light, heavy and special attack formulas.
- [ ] T035 Implement resistance/weakness modifiers.
- [ ] T036 Add seeded random source for testable boss behaviour.
- [ ] T037 Implement battle-record repository.
- [ ] T038 Add combat calculation tests.
- [ ] T039 Assert that battle reducers cannot mutate training ledger or stat snapshot.

## Phase 4 — Game runtime integration

- [ ] T040 Install npm Three.js dependency and remove CDN import map.
- [ ] T041 Move scene creation into `src/game/BattleGame.ts`.
- [ ] T042 Create React `BattleHost`.
- [ ] T043 Replace popup/query-string stat transport with typed props.
- [ ] T044 Create one authoritative battle-session state.
- [ ] T045 Implement result callback and battle persistence.
- [ ] T046 Record correct boss ID, duration and build snapshot.
- [ ] T047 Handle reload/exit as abandoned battle.
- [ ] T048 Remove wildcard `postMessage` transport or lock it to same origin if temporarily retained.
- [ ] T049 Add integration tests for victory, defeat and abandonment.

## Phase 5 — Action feel

- [ ] T050 [P] Add original player and boss placeholder silhouettes with documented licences.
- [ ] T051 Implement light attack combo.
- [ ] T052 Implement heavy attack with Strength scaling.
- [ ] T053 Implement bounded evade timing and prevent input spam.
- [ ] T054 Implement boss telegraph states.
- [ ] T055 Implement hit stop.
- [ ] T056 Implement camera impulse/shake.
- [ ] T057 Implement impact particles and attack trail.
- [ ] T058 Implement knockback and stagger.
- [ ] T059 Implement Strength-based damage-number presentation.
- [ ] T060 Implement `Titan Impact` unlock and attack.
- [ ] T061 Tune first boss so Titan Impact one-shots at the configured milestone.
- [ ] T062 Implement running specialist attack-speed, stamina and evade advantages.
- [ ] T063 Add reduced-shake and reduced-flash options.
- [ ] T064 Add replay of defeated early boss.

## Phase 6 — App UX

- [ ] T065 Add post-workout stat-change summary.
- [ ] T066 Show next permanent milestone.
- [ ] T067 Add build identity summary: Power / Speed / Tank / Balanced.
- [ ] T068 Explain why some recorded activity was not credited.
- [ ] T069 Add one guided workout flow using the existing exercise list.
- [ ] T070 Replace desktop navigation with mobile-responsive navigation.
- [ ] T071 Remove franchise-derived public terminology and placeholder branding.

## Phase 7 — Offline, performance and QA

- [ ] T072 Add PWA manifest and service worker.
- [ ] T073 Add offline application-shell and battle assets.
- [ ] T074 Add Playwright mobile core-loop test.
- [ ] T075 Add save migration Playwright test.
- [ ] T076 Measure battle FPS on target Android-class device.
- [ ] T077 Add quality settings for particles and shadows.
- [ ] T078 Add error boundary and WebGL fallback message.
- [ ] T079 Run five-person feel test.
- [ ] T080 Record success measures and balance changes.
- [ ] T081 Run `/speckit.analyze`.
- [ ] T082 Resolve consistency findings.
- [ ] T083 Run `/speckit.converge` after implementation.

## Definition of done

- [ ] Current source builds without TypeScript errors.
- [ ] Existing local records migrate without loss.
- [ ] Permanent stats derive from ledger and survive reload.
- [ ] Combat never spends permanent stats.
- [ ] Exercise-specialized builds play differently.
- [ ] 10,000 credited push-ups unlock a first-boss one-shot ability.
- [ ] Battle results persist.
- [ ] Core loop works offline.
- [ ] Automated domain and end-to-end tests pass.
- [ ] Five-user feel test meets the specified threshold.
