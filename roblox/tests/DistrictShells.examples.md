# District Shell Examples

Milestone 3.2 adds primitive visual shell details to the accepted Ascension Grounds greybox.

These checks are manual/MCP inspection examples until an automated Roblox test runner is available.

## Expected Shell Groups

- `Workspace.AscensionGrounds.StrengthForge.Milestone32ShellDetails`
- `Workspace.AscensionGrounds.ReferenceSpacingBlockout.StationDistricts.GuardianHallBlockout.Milestone32ShellDetails`
- `Workspace.AscensionGrounds.ReferenceSpacingBlockout.StationDistricts.AgilityTowerBlockout.Milestone32ShellDetails`
- `Workspace.AscensionGrounds.ReferenceSpacingBlockout.StationDistricts.EnduranceTrackBlockout.Milestone32ShellDetails`
- `Workspace.AscensionGrounds.ReferenceSpacingBlockout.StationDistricts.ControlShrineBlockout.Milestone32ShellDetails`

## Visual Identity Checks

1. Inspect Strength Forge.
   - Expected: orange forge read, stone/metal shell, and the existing prompt still present.
   - Observed during milestone 3.2: forge arch, ember shelf, and hammer silhouette were added without touching `TrainStrengthPrompt`.

2. Inspect Guardian Hall.
   - Expected: blue, fortified, defensive silhouette.
   - Observed during milestone 3.2: battlements, gate bars, and a blue shield emblem were added.

3. Inspect Agility Tower.
   - Expected: purple, vertical, obstacle-focused silhouette.
   - Observed during milestone 3.2: jump platforms, balance beam, hoop marker, and landing mat were added around the existing tower.

4. Inspect Endurance Track.
   - Expected: green, open, circular route read.
   - Observed during milestone 3.2: start arch and green checkpoint markers were added around the existing track.

5. Inspect Control Shrine.
   - Expected: teal, precise, mystical silhouette.
   - Observed during milestone 3.2: precision ring, focus pillars, and rune lines were added around the existing crystal.

## Navigation and Performance Checks

- Every milestone 3.2 detail part should be anchored.
- Every milestone 3.2 detail part should have `CanCollide = false`.
- Shell details should not sit across the central roads or district road mouths.
- The new shell details add 31 primitive parts total.
- No imported assets, meshes, enemies, rewards, or additional minigames are required.

## Play-Mode Smoke Check

1. Start Play mode.
2. Confirm all five `Milestone32ShellDetails` groups exist at runtime.
3. Confirm the player loads with `Profile`, `Stats`, `TrainingStats`, and `leaderstats`.
4. Move the player into Strength Forge range.
5. Start a Strength Forge challenge through `TrainingStationService.StartStationMinigame(player, "StrengthForge")`.
6. Cancel the challenge through `TrainingStationService.CancelStationMinigame`.
7. Check console output and stop Play mode.

Expected result:

- Strength Forge challenge starts with 3 required successes and 6 maximum attempts.
- Challenge cancels cleanly.
- No shell detail parts are collidable.
- No new console errors appear.
- The unpublished local DataStore warning may appear until the place is published.
