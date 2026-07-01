# Visual Asset Setup - 2026-06-28

## Purpose

Prepare Codex and Roblox Studio to use the available visual assets without destabilising the current playable loop.

## Plugin / Tooling Status

- Roblox Studio MCP is configured through `.vscode/mcp.json`.
- The connected Studio instance is `Place1.rbxl`.
- No extra Codex plugin installation was required for this session.
- Studio-side asset insertion is available through the Roblox Studio MCP asset tools.

## Local Assets Prepared

Downloaded Kenney packs were extracted into `roblox/assets/processed/kenney/`:

- `fantasy_ui_borders`
- `mobile_controls`
- `interface_sounds`

Extraction summary:

- `1,230` PNG files
- `463` SVG files
- `100` OGG files

These assets are local and ready for selection/upload/import work.

## Studio Asset Folders Added

The following folders now exist in Studio:

- `ReplicatedStorage.ZeroToHeroAssets`
- `ReplicatedStorage.ZeroToHeroAssets.CreatorStoreQuarantine`
- `ReplicatedStorage.ZeroToHeroAssets.ApprovedVisualAssets`
- `Workspace.AssetQuarantine`

Creator Store assets should be inserted into quarantine first, inspected, and only then copied into live game areas.

## Creator Store Assets Inserted To Quarantine

| Asset | Status | Inspection |
| --- | --- | --- |
| LowPoly Asset Pack | Pending approval | 32 descendants, 26 MeshParts, 0 scripts, 0 remotes |
| R6 Dummy | Pending approval | 17 descendants, 7 Parts, 0 scripts, 0 remotes |
| Sword of Darkness | Blocked | 20 descendants, 5 scripts/local scripts, 0 remotes |
| Free VFX Pack #1 By DogmathPan | Pending mobile VFX review | 261 descendants, 56 particle/beam/trail objects, 0 scripts, 0 remotes |
| Beam Texture Pack | Pending mobile VFX review | 523 descendants, 102 particle/beam/trail objects, 0 scripts, 0 remotes |

## Recommended First Visual Pass

Use the references in this order:

1. Strength Forge: stronger orange glow, stone/metal arch silhouette, chains, anvil/weight props, and a clearer interaction focal point.
2. Enemy Area / Broken Gate: darker stone route, red torches, banners, and a stronger distant danger silhouette.
3. Reward Popup: use Kenney fantasy borders or a matching dark/gold Roblox UI frame if uploaded.
4. Combat HUD: use Kenney mobile controls as button art or as layout reference after upload/import.
5. Stats HUD: use dark panels, stat-colored rows, and stronger hierarchy while keeping current replicated data paths.

## Rules For The Next Pass

- Do not copy exact reference layouts, icons, logos, or text.
- Do not insert quarantined assets into live gameplay until approved.
- Strip scripted assets down to art-only parts before approval.
- Reduce particle counts from VFX packs before mobile use.
- Do not change mechanics, rewards, combat authority, or progression during the visual pass.
