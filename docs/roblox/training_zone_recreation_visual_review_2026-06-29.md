# Training Zone Recreation Visual Review - 2026-06-29

## Scope

Phase 0 visual/world-scale pass only. Existing training, combat, reward, inventory, profile, remote, and enemy systems were preserved.

## What Already Matched The References

- Ascension Grounds already had a readable central crystal hub, five color-coded training districts, and a clear Broken Gate danger route.
- Strength Forge already had the live Power training prompt and a usable forge-core focus.
- The existing HUD, reward popup, and combat UI already matched the mobile-first direction better than the early prototype UI.
- The approved LowPoly subset and primitive blockout language were safe for readable, low-cost environment dressing.

## What Felt Too Small

- Existing district footprints were only about 43-55 studs wide, while the recreation spec calls for public-space districts roughly 150-195 studs wide.
- Most older hub and district roads were about 10-13 studs wide. They read as single-player lanes instead of group-friendly public routes.
- Earlier district landmarks did not hold their silhouette from 120-200 studs away.
- Secondary activity pads and clear approach space were mostly missing outside the Power route.

## What Was Visually Weak

- Guardian/Vitality lacked a large life-tree or grove identity.
- Agility lacked a tall vertical landmark with clear climbing/obstacle silhouettes.
- Endurance lacked a broad oval track landmark.
- Control lacked a strong armillary/orb shrine silhouette.
- Strength Forge needed a larger public forge yard and stronger hammer/furnace read without moving the live prompt.
- Signs and zone color hierarchy were not strong enough from the central hub.

## Safe Assets

- New live recreation geometry uses primitives only.
- `ReplicatedStorage.ZeroToHeroAssets.ApprovedVisualAssets.Phase0LowPolyApprovedSubset` remains the only approved Creator Store-derived subset from the previous polish pass.
- Re-inspection found the quarantined LowPoly pack script-free, but this pass did not need to move the full pack live.
- The R6 Dummy was script-free on inspection, but it still needs anchoring/static setup before live decorative use.

## Blocked Or Deferred Assets

- `Sword of Darkness` remains blocked because the quarantined model contains embedded scripts.
- Full Free VFX and Beam packs remain deferred because they are script-free but too heavy/noisy for direct mobile use.
- The five new training-zone concept image files named by `docs/roblox/training_zone_recreation_spec.md` were not present under `roblox/assets/reference/roblox`; the pass used the written spec plus existing reference images.

## Implementation Result

Created `Workspace.AscensionGrounds.Phase0TrainingZoneRecreation` as a replaceable, Studio-authored visual overlay:

- Power: `Power_StrengthForge`, 150 x 115 district floor.
- Vitality: `Vitality_GuardianGrove`, 165 x 125 district floor.
- Agility: `Agility_SkywardTower`, 160 x 120 district floor.
- Endurance: `Endurance_HeroesTrack`, 195 x 145 district floor.
- Control: `Control_ArcaneShrine`, 165 x 125 district floor.
- Main roads are 22-24 studs wide.
- Each zone has one dominant landmark, central activity area, secondary activity/sign clusters, and distinct color language.
- New group contains 0 scripts, 0 LocalScripts, 0 ModuleScripts, 0 remotes, 0 bindables, 0 particles, 0 beams, 0 trails, and 0 unanchored parts.

## Verification Notes

- Strength Forge prompt stayed at `Workspace.AscensionGrounds.StrengthForge.ForgeCore.TrainStrengthPrompt`, position `(-78, 6.1, -24)`, action text `Train Power +1`, max distance `15`.
- Play mode console output showed only the known unpublished-place DataStore warning.
- Strength Forge minigame start/cancel still worked.
- Existing HUDs and reward popup instantiated in the client; the reward popup showed the test `Visual Check` payload.
- Lesser Slime spawned and a server-authoritative basic attack reduced health from `42` to `30`.
- Studio screenshot capture timed out after the first baseline capture, so full before/after visual coverage should be completed manually in Studio or device simulator.
