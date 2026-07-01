# Ascension Grounds Layout Examples

Milestone 3.1 formalises the existing Studio greybox at:

`Workspace.AscensionGrounds.ReferenceSpacingBlockout`

These checks are manual/MCP inspection examples until an automated Roblox test runner is available.

## Edit-Mode Structure Checks

Expected hierarchy:

- `Workspace.AscensionGrounds.ReferenceSpacingBlockout.CentralPlaza`
- `Workspace.AscensionGrounds.ReferenceSpacingBlockout.CentralPlaza.CentralCrystal`
- `Workspace.AscensionGrounds.ReferenceSpacingBlockout.RoadGrid`
- `Workspace.AscensionGrounds.ReferenceSpacingBlockout.StationDistricts`
- `Workspace.AscensionGrounds.ReferenceSpacingBlockout.BrokenGateBlockout`
- `Workspace.AscensionGrounds.StrengthForge`

Expected roads:

- `MainRoadSouthToNorth`
- `ForgeRoad`
- `GuardianRoad`
- `AgilityRoad`
- `EnduranceRoad`
- `ControlRoad`
- `BrokenGateBlockout.GateRoad`

Expected district labels:

- `STRENGTH FORGE`
- `GUARDIAN HALL`
- `AGILITY TOWER`
- `ENDURANCE TRACK`
- `CONTROL SHRINE`
- `BROKEN GATE`

## Acceptance Examples

1. Inspect `CentralCrystal`.
   - Expected: blue/neon placeholder crystal.
   - Observed during milestone 3.1: `Size = 6, 17, 6`, material `Neon`, blue color.

2. Inspect `RoadGrid`.
   - Expected: five district paths on one main floor.
   - Observed during milestone 3.1: five district road parts plus main south/north road.

3. Inspect path widths.
   - Expected: wide enough for groups, not a cramped maze.
   - Observed during milestone 3.1: district roads are 10-12 studs wide; main route is 13 studs wide; Broken Gate road is 20 studs wide.

4. Inspect `BrokenGateBlockout`.
   - Expected: one obvious main route leading away from the hub.
   - Observed during milestone 3.1: one `BrokenGateBlockout` model with one `GateRoad`, two tower placeholders, header, and sign.

5. Inspect `GroundPlate`.
   - Expected: one traversable floor under the hub.
   - Observed during milestone 3.1: `GroundPlate` is collidable and sized `230, 2, 205`.

## Hands-On Studio Check

1. Start Play mode.
2. Spawn at `StarterSpawn`.
3. Walk from spawn toward the central crystal.
4. Confirm the five district directions are readable from the plaza.
5. Walk toward Strength Forge and confirm the station remains reachable.
6. Walk toward the Broken Gate route and confirm it is the single obvious exit from the hub.
7. Stop Play mode and check the console.

Expected console output:

- No layout errors.
- The unpublished local DataStore warning may appear until the place is published.
