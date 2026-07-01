# Training Zone Visual Delta - Phase 0.1 - 2026-06-29

## Reference Inputs

- `docs/roblox/training_zone_recreation_spec.md`
- `roblox/assets/reference/roblox/01_ascension_grounds_reference.png`
- `roblox/assets/reference/roblox/02_strength_forge_reference.png`

The requested `roblox/assets/reference/roblox/training_zones/` folder is not present in the repo, so this pass uses the written zone-specific spec plus the existing root Roblox reference images.

## Screenshot Status

- Current screenshot captured: `phase01_current_power`.
- Current Guardian Grove and Skyward Tower screenshot attempts timed out through Studio MCP `screen_capture`; remaining current screenshots should be captured manually or retried after the pass.
- After screenshot attempts timed out for both `phase01_after_power` and `phase01_after_viewport`; after coverage should be captured manually in Studio or device simulator.

## Power - Strength Forge

**Delta**
- Too small: forge facade and furnace read smaller than the reference; the anvil pad does not dominate the yard enough.
- Weak landmark: orange furnace is present but not broad/bright enough from hub distance.
- Weak side reads: Titan Lift and Boulder Break exist, but they need larger silhouette props to read as left/right activities.
- Shape issue: facade is mostly flat blockout rather than a heavy industrial forge with banners/chains.
- Spacing: central route is workable, but the side pads need stronger boundary framing.

**Top 3 fixes**
- Add a larger orange furnace mouth, facade frame, and facade-facing emblem/banner layer.
- Enlarge the anvil pad with a stronger raised anvil silhouette.
- Add bigger weight-rack and boulder side-area silhouettes.

## Vitality - Guardian Grove

**Delta**
- Too small: life tree exists but needs a larger protective canopy and clearer root/platform spread.
- Weak landmark: the green heart crystal is not dominant enough from 120-200 studs.
- Color identity: green identity exists, but protective/nature glow should be stronger.
- Shape issue: the grove reads as a tree plus shelters, not a guardian/nature landmark.
- Spacing: paths are broad enough, but protective boundary shapes need to define the grove.

**Top 3 fixes**
- Enlarge life-tree canopy/trunk and add a brighter vertical life crystal.
- Add protective root arches and guardian shield stones around the pulse circle.
- Add larger green perimeter banners/lanterns to improve hub-distance identity.

## Agility - Skyward Tower

**Delta**
- Too small: tower top is high enough, but the vertical silhouette is thin and not dominant enough.
- Weak landmark: finish ring exists, but the tower body needs a clearer stacked route and spire read.
- Color identity: purple/cyan accents exist but need stronger contrast and vertical highlights.
- Shape issue: tower reads as platform stacks rather than a tall agility course landmark.
- Spacing: route pads exist, but the readable path up the tower is not obvious from ground level.

**Top 3 fixes**
- Add taller spire/flag silhouette and vertical cyan-purple light strips.
- Add clearer zig-zag route plates and hub-facing arrow markers up the tower.
- Add larger reaction/courier side silhouettes without narrowing the road.

## Endurance - Heroes' Track

**Delta**
- Too small: the track footprint exists, but the timer gate and spectator/water silhouettes are much too low.
- Weak landmark: no tall landmark reads from the central hub; timer gate is only about 18 studs tall.
- Color identity: green/brown reads correctly but needs stronger athletic banners and lane markers.
- Shape issue: oval track can disappear into the floor without a stronger curb/lane contrast.
- Spacing: the open field is good, but side activity areas need clearer separation.

**Top 3 fixes**
- Add a much larger timer gate and finish banner.
- Add stronger outer track curbs/lane markers and broader start-line read.
- Enlarge spectator stand/water station silhouettes as readable side landmarks.

## Control - Arcane Shrine

**Delta**
- Too small: armillary exists but needs larger central orb and rings to match the reference hierarchy.
- Weak landmark: cyan/blue magic identity is present, but the orb should be the dominant read.
- Color identity: cyan is strong in parts, but the shrine base/floor is still too neutral.
- Shape issue: rings are readable close up but need a bigger circular/rune pad at ground level.
- Spacing: activity areas are separated well, but central rune focus needs stronger hierarchy.

**Top 3 fixes**
- Add larger central orb shell and larger outer ring silhouettes.
- Add a clearer cyan rune pad with radial rune spokes.
- Add taller crystal/pillar silhouettes around the shrine for hub-distance read.

## Implementation Result

Created `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation.Phase01VisualDeltaPass` as a replaceable primitive-only overlay.

Per-zone fixes:

- Power: added a wider forge facade layer, larger orange furnace mouth, taller signal chimneys/beacons, bigger anvil pad around the unchanged prompt area, and larger Titan Lift/Boulder Break silhouettes.
- Vitality: added a taller life-tree canopy/trunk, brighter life crystal, protective root spokes, shield stones, and larger hub-facing green sign/banners.
- Agility: added a much taller spire and top crystal, stronger vertical cyan strips, clearer route arrow pads, and larger Reaction Dash/Courier Run side silhouettes.
- Endurance: added a larger timer gate, stronger oval curbs/lane markers, broader start line, checkpoint flags, taller spectator stand, and more readable water station.
- Control: added a larger central orb, bigger armillary ring silhouettes, clearer rune pad/spokes, larger hub-facing sign, and taller crystal pillars.

Safety validation:

- New overlay contains 517 descendants, 468 BaseParts, 4 PointLights, 134 Neon parts, 0 collidable parts, 0 unanchored parts, 0 scripts, 0 LocalScripts, 0 ModuleScripts, 0 remotes, 0 bindables, 0 particles, 0 beams, and 0 trails.
- No Creator Store quarantine model was moved live.
- No blocked workspace asset was found.
- Strength Forge prompt stayed at `(-78, 6.1, -24)` with action text `Train Power +1` and max activation distance `15`.

Runtime verification:

- Play mode started and stopped cleanly.
- Console output showed only the known unpublished-place DataStore warning.
- Navigation samples across central, Power, Vitality, Agility, Endurance, and Control positions succeeded.
- Strength Forge minigame start/cancel still worked.
- `TrainingStatsHudGui`, `CombatControllerGui`, `InventoryPanelGui`, `StrengthForgeMinigameGui`, and `RewardPopupGui` were present in the client.
- Server-fired `Visual Check` reward payload displayed in the reward popup.
- Lesser Slime spawned and a server-authoritative basic attack reduced health from `42` to `30`.
