# Zero to Hero Agent Instructions

## Project Scope

- The active web app is a React/Vite mobile coach demo.
- The Roblox game is a separate Studio project controlled through the `robloxStudio` MCP server.
- Do not merge Roblox game code into the React app unless explicitly asked.
- Do not replace the current workout programmes or exercise list when working on Roblox features.

## Required Reading Before Roblox Studio Work

Before creating or changing Roblox Studio objects, scripts, UI, combat, economy, or training systems, read:

1. `docs/roblox/codex_progression_prompt_system.md`
2. `docs/roblox/master_game_spec.md`
3. `docs/roblox/architecture.md`
4. `docs/roblox/progression_tracker.md`
5. `docs/roblox/decision_log.md`
6. `docs/roblox/known_issues.md`
7. `docs/project_summary.md`

If the task involves Roblox visuals, UI, HUD, areas, stations, reward popups, or layout, also read:

8. `docs/roblox/visual_direction.md`
9. `roblox/assets/reference/roblox`

If the task involves rewards, currencies, monetisation, item drops, player economy, or paid features, also read:

10. `docs/player_earning_economy_plan.md`

## Roblox Source Of Truth

When Roblox documents conflict, use this order:

1. Current user task.
2. `docs/roblox/master_game_spec.md`.
3. `docs/roblox/architecture.md`.
4. `docs/roblox/visual_direction.md`.
5. Existing implementation.
6. Reference images.

Written specifications control mechanics, rewards, progression, security, architecture, naming, and acceptance criteria. Reference images control mood, color direction, composition, scale, shape language, and UI hierarchy only.

## Roblox Progression Workflow

- Build one milestone at a time.
- Do not start the next milestone until the current milestone passes acceptance criteria or the user explicitly changes direction.
- Update `docs/roblox/progression_tracker.md` after every completed Roblox task.
- Update `docs/roblox/decision_log.md` for meaningful architecture, product, or scope choices.
- Update `docs/roblox/known_issues.md` for unresolved problems.
- Update `docs/roblox/manual_test_checklist.md` when a new manual test is needed.
- Do not claim a Roblox system is complete unless it has been tested or a manual test has been documented.

## Roblox MCP Workflow

When using the `robloxStudio` MCP server:

- First list connected Studio instances with `list_roblox_studios`.
- Set the intended Studio instance active with `set_active_studio`.
- Inspect the current Studio tree before adding or replacing objects.
- Prefer small, named, understandable models and scripts.
- Keep valuable state server-authoritative.
- Use server scripts for stat gains, rewards, combat damage, inventory, currency, and progression.
- Use client scripts only for presentation, local input, camera, UI, and feedback.
- After changes, start play mode, check console output, stop play mode, and summarize any errors.
- Remind the user to save the Roblox place in Studio after successful MCP changes.
- Record meaningful Studio MCP changes in `docs/roblox/progression_tracker.md`.

## Roblox Product Rules

- Training creates base power.
- Gameplay creates gear and mastery.
- Money buys identity, content, and convenience, not victory.
- Player training stats start at 0 and are earned.
- The core MVP should stay narrow: Ascension Grounds, five stats, Strength Forge, immediate reward feedback, simple sword combat, one enemy, one equipment drop, and visible combat improvement from earned stats.
- Avoid building guilds, raids, PvP, auction house, housing, full monetisation, or a huge world until the first loop feels good.
- Use visual references only as direction. Do not copy exact layouts, icons, text, logos, character designs, enemy designs, architecture, or brand elements.
- Build Roblox visual work as simple readable blockouts first, then refine after the loop feels good.

## Current Roblox Build Target

The first Roblox proof should answer:

```text
Does training, becoming stronger, fighting, and earning loot feel good enough that a player wants to repeat it tomorrow?
```

Use `docs/roblox/progression_tracker.md` for the current phase and next task. The next task after foundation is milestone 1.1: Shared Stat Configuration.

## React App Rules

- The active trainer demo entry point is `src/components/CoachDemoApp.tsx`.
- Branding and workout data live in `src/coachConfig.ts`.
- Styling lives in `src/index.css`.
- Keep the coach demo sellable and mobile-first.
- Do not expose internal RPG implementation details in trainer-facing screens unless explicitly requested.
