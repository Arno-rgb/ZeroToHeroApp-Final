# Project Health Review - 2026-06-27

Scope: required review after milestones 1.1, 1.2, and 1.3 before continuing to milestone 2.1.

## 1. What Is Working

- `StatConfig` is the single shared source of truth for Power, Vitality, Agility, Endurance, and Control.
- `PlayerProfileModel` creates and repairs v1 profiles with zero-earned training stats.
- `PlayerDataService` owns profile loading, caching, mutation, replication, save attempts, release, and Studio-safe session-only fallback.
- Valuable profile mutation currently goes through server-owned modules, not client remotes.
- Manual examples exist for the first three milestones and the tracker records observed Studio checks.
- The React/Vite coach demo remains separate from the Roblox source path.

## 2. What Is Fragile

- Several exploratory Studio scripts still exist outside source control and still refer to legacy `Strength` and `Coins` values.
- The source tree and live Studio place are not fully reconciled; Studio must be inspected before each gameplay change.
- Roblox tests are documented manual examples, not automated Luau test-runner assertions.
- Local unpublished Studio play cannot verify DataStore persistence and uses session-only fallback.

## 3. What Should Be Refactored Now

- Milestone 2.1 should introduce a canonical `TrainingService` and route training XP through it.
- The current direct stat-value award path should be treated as legacy once `TrainingService` can award XP, apply level-ups, and return structured reward results.
- Do not remove unrelated combat/enemy exploratory scripts yet unless they conflict with the current milestone.

## 4. What Must Not Be Built Yet

- Do not build the Strength Forge minigame in milestone 2.1.
- Do not build final station framework, reward popup UI, combat, loot, equipment, Brakk, PvP, guilds, raids, auction house, or real mobile integration.
- Do not import downloaded assets or Creator Store assets during TrainingService work.

## 5. Continue Decision

The project may continue to milestone 2.1 - Training Service.

Condition: keep the milestone narrow. Implement server-owned training XP, deterministic diminishing returns, multiple level-ups, structured reward results, daily training totals, and documented checks. Any legacy Studio route touched during this milestone should call the new service rather than directly mutating training stats.
