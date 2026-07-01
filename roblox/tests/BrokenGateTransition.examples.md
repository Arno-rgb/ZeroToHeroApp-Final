# Broken Gate Transition Examples

Milestone 3.3 adds a primitive visual transition from the safe Ascension Grounds into the existing danger-side area.

These checks are manual/MCP inspection examples until an automated Roblox test runner is available.

## Expected Transition Group

- `Workspace.AscensionGrounds.ReferenceSpacingBlockout.BrokenGateBlockout.Milestone33TransitionDetails`

## Structure Checks

Expected route surfaces:

- `DangerRouteFloorNear`
- `DangerRouteFloorFar`
- `FutureBossRoutePlate`

Expected safe-to-danger markers:

- `SafeHubWardLeft`
- `SafeHubWardRight`
- `SafeHubThresholdLine`
- `DangerThresholdLine`
- `DangerVeil`

Expected danger-side visual details:

- red torch models
- ruined stone edge pieces
- torn red banner placeholders
- a far route marker pointing toward a future boss area

## Acceptance Examples

1. Inspect `Milestone33TransitionDetails`.
   - Expected: one grouped, named primitive model under the existing Broken Gate blockout.
   - Observed during milestone 3.3: 28 primitive parts and 5 PointLights were added.

2. Inspect route surfaces.
   - Expected: the route remains wide enough for future combat.
   - Observed during milestone 3.3: route surfaces were 26, 30, and 32 studs wide.

3. Inspect colliders.
   - Expected: decorative ruin, lights, banners, ward, and veil parts do not block navigation.
   - Observed during milestone 3.3: only the three route floor parts were collidable.

4. Inspect mood and readability.
   - Expected: safe hub side is visually distinct from danger side without needing UI text.
   - Observed during milestone 3.3: blue safe-side markers, red threshold, dark cracked route, red lights, ruins, and a far route glow are visible.

5. Inspect enemy scope.
   - Expected: no new enemies are added by this milestone.
   - Observed during milestone 3.3: no new enemy model was added. The existing `Workspace.AscensionGrounds.EnemyArea.TrainingDummy` predates this milestone and remains a legacy placeholder.

## Play-Mode Smoke Check

1. Start Play mode.
2. Confirm `Milestone33TransitionDetails` exists at runtime.
3. Confirm the player loads with `Profile`, `Stats`, `TrainingStats`, and `leaderstats`.
4. Raycast down onto `DangerRouteFloorNear`, `DangerRouteFloorFar`, and `FutureBossRoutePlate`.
5. Confirm each ray hits the expected route surface and each surface is at least 24 studs wide.
6. Move the player onto `DangerRouteFloorFar`.
7. Check console output and stop Play mode.

Expected result:

- Transition group exists.
- Route surfaces exist and are walkable.
- Decorative details are not collidable.
- No new console errors appear.
- The unpublished local DataStore warning may appear until the place is published.
