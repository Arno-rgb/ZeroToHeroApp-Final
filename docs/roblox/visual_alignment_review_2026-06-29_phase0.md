# Phase 0 Visual Alignment Review - 2026-06-29

## Scope

Visual alignment, asset-backed polish, and perceived world-scale pass only. Gameplay mechanics, rewards, combat math, inventory, progression, enemy logic, profile data, remotes, and server authority were preserved.

## Reference Fit

Already matching:

- Ascension Grounds already had a five-district hub, a central crystal, clear roads, labels, and safe-to-danger direction.
- Strength Forge already used orange/metal/stone language and retained the working training prompt.
- Broken Gate already had a red danger transition and a route toward EnemyArea.
- Stats HUD, reward popup, and combat HUD already used canonical replicated data/remotes.

Visually weak before this pass:

- The world still read like a small test arena from distance.
- The central crystal was present but not dominant enough as the hub focal point.
- Strength Forge lacked a large forge silhouette, warm core frame, chains, and heavier training props.
- Broken Gate and EnemyArea needed larger dark-red background silhouettes and clearer danger-route scale.
- Stats/reward/combat UI hierarchy was functional but flatter than the references.

## Asset Review

Safely used:

- `ReplicatedStorage.ZeroToHeroAssets.CreatorStoreQuarantine.LowPoly Asset Pack` was re-inspected before use: 32 descendants, 26 MeshParts, 0 scripts, 0 remotes.
- A small art-only subset was copied into `ReplicatedStorage.ZeroToHeroAssets.ApprovedVisualAssets.Phase0LowPolyApprovedSubset`.
- Live clones were placed under `Workspace.AscensionGrounds.Phase0VisualScalePolish.ApprovedLowPolyDressing`.

Kept blocked or quarantined:

- `Sword of Darkness` remains blocked because it contains script/local-script descendants.
- `Free VFX Pack #1 By DogmathPan` and `Beam Texture Pack` remain quarantined pending mobile VFX reduction.
- Kenney UI/control/audio packs remain local extracted assets and were used as direction only, not imported into Studio.

## Implemented

- Added `Workspace.AscensionGrounds.Phase0VisualScalePolish` with grouped submodels for central plaza scale, district landmark silhouettes, Strength Forge polish, Broken Gate/EnemyArea polish, and LowPoly dressing.
- Added a taller blue crystal beacon, broader plaza/route read layers, cardinal pylons, and larger district landmarks.
- Added forge arch/wall mass, orange core glow, chains, anvil/barbell props, banners, and warm lights without moving the existing prompt.
- Added dark route surfaces, red torch accents, ruined silhouettes, banners, and a distant danger fortress silhouette.
- Updated canonical stats HUD, reward popup, and combat HUD presentation in source and live Studio scripts.

## Verification

- Before captures: `phase0_before_hub_scale_retry`, `phase0_before_strength_forge_top`, `phase0_before_broken_gate_enemy`.
- After captures: `phase0_after_hub_scale`, `phase0_after_strength_forge_oblique`.
- The after danger-route and runtime HUD screenshot attempts timed out in the Studio capture tool, so runtime UI was verified by client tree/state inspection instead.
- Play mode console output showed only the expected unpublished-place DataStore warning.
- Runtime checks confirmed the visual group has 158 BaseParts, 16 PointLights, 0 collidable parts, 0 unanchored parts, 0 scripts, and 0 remotes.
- Strength Forge minigame start/cancel still worked.
- Reward popup appeared from a server-fired display payload.
- Combat HUD appeared near Lesser Slime.
- Lesser Slime spawned and a server-authoritative basic attack reduced health from 42 to 30.

## Remaining Visual Risks

- The pass is still a primitive/low-poly blockout polish layer, not final art.
- The Studio-authored visual group is not yet represented in a source-controlled scene pipeline.
- Hands-on phone/device-simulator screenshots should still be taken before judging final mobile composition.
