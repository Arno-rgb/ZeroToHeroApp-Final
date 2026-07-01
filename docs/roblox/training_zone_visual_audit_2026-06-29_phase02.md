# Phase 0.2 Training Zone Visual Audit - 2026-06-29

## Evidence

- Player-height before screenshot saved: `tmp-codex/screens/phase02_before_spawn_plaza.jpg`.
- Player-height Power before screenshot saved: `tmp-codex/screens/phase02_before_power_approach.jpg`.
- Guardian Grove player-height screenshot timed out twice through Studio MCP `screen_capture`.
- Edit-mode inspection found the previous live recreation stack still visible with `1,226` BaseParts, `451` Neon parts, and `361` thin Neon parts under `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation`.
- The Phase 0.1 correction layer alone added `468` BaseParts, `134` Neon parts, and `80` thin Neon parts.
- Older visual layers also remain visible: `ReferenceSpacingBlockout`, `Phase0VisualScalePolish`, `Phase0TrainingZoneRecreation`, and `Phase01VisualDeltaPass`.
- Gameplay-critical prompts remain at their existing transforms:
  - Strength Forge: `Workspace.AscensionGrounds.StrengthForge.ForgeCore.TrainStrengthPrompt`, parent position `(-78, 6.1, -24)`, max distance `15`.
  - Training Dummy: `Workspace.AscensionGrounds.EnemyArea.TrainingDummy.Body.HitEnemyPrompt`, parent position `(0, 4.5, -104)`, max distance `13`.

## Current Visual Problems

The current town reads like a small floating diorama from player height because several visual overlays stack in the same space. The central view is dominated by cyan slabs, thin neon strips, and large close-range signs instead of a believable public plaza with distant districts.

The world technically spans a large footprint, but it does not feel large at ground level. Landmarks are too close to the central view, roads read as flat board markings, and the high part count is spent on outlines, rings, small signs, and thin effects rather than walkable mass, entrances, height, and breathing room.

Neon is overused as structure. The reference direction uses glow as a focal accent, while the current build uses many bright cyan/orange/purple pieces as the main silhouette. This flattens the fantasy-town read and makes the zones compete with each other.

## Zone Delta

## Power - Strength Forge

- Too small: the forge facade has height, but it reads as a thin sign wall, not a deep forge building.
- Weak landmark: the orange furnace glow is present but partly lost behind signs, bars, and foreground clutter.
- Color identity: orange is clear, but it is used as outline strips instead of a strong furnace focal point.
- Shape issue: the visible view is dominated by sign backs and barbells; the forge entrance and anvil yard do not feel like a real place.
- Spacing issue: the existing Strength Forge prompt works and should stay, but the yard around it needs more empty room and a larger building shell.

## Vitality - Guardian Grove

- Too small: the tree landmark exists, but the grove does not feel like a large protected place from the central plaza.
- Weak landmark: the green life crystal should be the dominant read, not one more neon accent among many.
- Color identity: green exists, but protective/nature identity is weakened by nearby cyan/orange clutter from other overlays.
- Shape issue: the grove needs a broad canopy, root ring, and sheltered clearing rather than many small markers.
- Spacing issue: it needs more breathing room and edge planting so it feels like a district, not a prop cluster.

## Agility - Skyward Tower

- Too small: the tower is tall, but it reads as a thin scaffold/ring stack instead of a large climbable tower.
- Weak landmark: the vertical silhouette is present but visually noisy.
- Color identity: purple/cyan accents are too strong and numerous; they should guide the route, not become the structure.
- Shape issue: many small platforms and rings compete with the main tower body.
- Spacing issue: the approach needs a broad entrance and obvious vertical route from ground level.

## Endurance - Heroes' Track

- Too small: the track and timer gate sit low compared with the other landmarks.
- Weak landmark: from the hub, the zone lacks one strong vertical or horizontal read besides signs.
- Color identity: green/brown is correct but not bold enough at player distance.
- Shape issue: the oval needs a broad physical footprint and open center field, not thin lane decorations.
- Spacing issue: the track should provide the clearest breathing room in the town.

## Control - Arcane Shrine

- Too small: the orb/ring idea is right, but too many thin neon segments make it chaotic.
- Weak landmark: the orb should be calm and central; currently the rings and cyan strips compete.
- Color identity: cyan/blue is strong but over-applied.
- Shape issue: the shrine needs a large circular courtyard, heavy pillars, and a single controlled armillary shape.
- Spacing issue: the center should feel clear and ceremonial, not filled with visual spaghetti.

## Asset Safety

- Safe for this pass: primitive Parts and the already-approved `Phase0LowPolyApprovedSubset`, which remains script-free and remote-free.
- Safe but not needed live: quarantined `LowPoly Asset Pack` and `R6 Dummy` were script-free on inspection, but full packs should not be moved live.
- Blocked: `Sword of Darkness` still contains Scripts/LocalScripts/ModuleScript descendants and must not be used live.
- Deferred: VFX and Beam packs are script-free but too heavy/noisy for this salvage pass without mobile reduction.

## Phase 0.2 Correction Direction

- Hide or de-emphasize previous visual-only clutter layers instead of adding another dense detail pass.
- Add one clearly named replacement layer: `Workspace.AscensionGrounds.Phase02VisualSalvagePass`.
- Use fewer, larger shapes: broad roads, large district floors, deep building shells, larger landmarks, and calm local accent lighting.
- Keep the Strength Forge prompt and enemy/combat objects in their current gameplay positions.
- Use collision only on broad roads/floors/ramps; keep decorative parts anchored, non-scripted, and mostly non-collidable.
- Use Neon as accent only: furnace mouth, life crystal, route beacons, timer panel, and shrine orb/runes.
