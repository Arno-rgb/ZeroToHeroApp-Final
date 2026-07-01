# Roblox Build From Spec Prompt

Use this prompt inside Codex when you want it to build in Roblox Studio from the project spec.

```text
Use the robloxStudio MCP server.

First read:
- AGENTS.md
- docs/roblox/codex_progression_prompt_system.md
- docs/roblox/master_game_spec.md
- docs/roblox/architecture.md
- docs/roblox/progression_tracker.md
- docs/roblox/decision_log.md
- docs/roblox/known_issues.md
- docs/project_summary.md

If this task touches Roblox visuals, UI, HUD, areas, stations, reward popups, or layout, also read:
- docs/roblox/visual_direction.md
- roblox/assets/reference/roblox

If this task touches rewards, currency, items, monetisation, or economy, also read:
- docs/player_earning_economy_plan.md

Then:
1. List connected Roblox Studio instances.
2. Set Place1 as the active Studio instance.
3. Inspect the current Studio game tree and existing scripts.
4. Compare the current Studio place and repo source against `docs/roblox/progression_tracker.md`.
5. Build only the current milestone or the next smallest missing feature required by that milestone.
6. Keep stat gains, rewards, combat damage, inventory, and progression server-authoritative.
7. Use visual references as direction only; do not copy exact icons, text, layouts, logos, character designs, or brand elements.
8. Update `docs/roblox/progression_tracker.md`.
9. Update `docs/roblox/decision_log.md` for meaningful decisions.
10. Update `docs/roblox/known_issues.md` for unresolved issues.
11. Start play mode, check console output, then stop play mode when Studio work was changed.
12. Summarize exactly what objects/scripts/files were created or changed, what was tested, and what the next smallest task should be.

Do not build guilds, raids, PvP, auction house, housing, monetisation, or a large world yet.
```

## Current Intended Next Feature

After Phase 0 foundation, the next intended milestone is 1.1 - Shared Stat Configuration:

- Create one shared source of truth for Power, Vitality, Agility, Endurance, and Control.
- Add XP formula helpers.
- Keep training stats starting at Level 0 and XP 0, with 0 effective earned stat value.
- Document manual test examples.
- Update the Roblox progression tracker.

This should come before more minigames, combat, loot, classes, enemies, or world areas unless the user explicitly changes direction.
