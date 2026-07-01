# Roblox Asset Pipeline

## Purpose

This plan prepares the Ascension Grounds MVP asset intake without downloading or importing anything yet. It separates downloadable CC0 packs from Roblox Creator Store assets and keeps the first asset pass focused on the vertical slice: hub, Strength Forge, enemy route, dummy/enemy placeholders, starter weapon, VFX, mobile UI, and basic UI sounds.

Primary records:

- `roblox/assets/manifests/asset_manifest.csv`
- `roblox/assets/manifests/download_queue.md`
- `roblox/assets/manifests/creator_store_insert_plan.md`

## Source Rules

- Do not download paid assets.
- Do not use unofficial mirrors, reposts, or scraped archives.
- Preserve source URLs and licences for every asset.
- Keep asset work under `roblox/assets/`.
- Keep downloaded ZIPs or archives unchanged under `roblox/assets/raw/`.
- Put cleaned, subsetted, renamed, or Roblox-import-prepared files under `roblox/assets/processed/`.
- Creator Store assets must be inserted through Roblox Studio or listed for manual insert. Do not save scraped Creator Store model files into the repo.
- Any Creator Store asset inserted into Studio must be quarantined and inspected for scripts before use.

## Directory Layout

```text
roblox/assets/
  reference/
    roblox/
      existing visual references
  manifests/
    asset_manifest.csv
    download_queue.md
    creator_store_insert_plan.md
  raw/
    quaternius/
    kenney/
  processed/
    quaternius/
    kenney/
```

The `raw/` and `processed/` roots exist now. Provider subfolders should be created only when the related asset is actually downloaded or processed.

## Asset Lanes

### Downloadable CC0 Packs

Use this lane for Quaternius and Kenney packs.

1. Confirm the official page and licence.
2. Download only the free/CC0 pack from the official URL.
3. Store the untouched archive and licence/readme files under `roblox/assets/raw/<provider>/<asset_slug>/`.
4. Extract or process only the subset needed for the MVP under `roblox/assets/processed/<provider>/<asset_slug>/`.
5. Use Blender or equivalent tooling only to split bundles, apply transforms, reduce clutter, rename assets, and prepare mobile-safe subsets.
6. Import only small reviewed subsets into Roblox Studio.
7. Record actual import status and Studio asset/package names back into the manifest.

### Roblox Creator Store Assets

Use this lane for Creator Store entries.

1. Confirm the asset is free and still available on the official Creator Store page.
2. Insert through Roblox Studio only.
3. Insert into quarantine first, not into the live game hierarchy.
4. Inspect all descendants before use, especially scripts and remotes.
5. Delete/reject scripts and rewrite any needed behaviour in project-owned source.
6. Move only reviewed art-only subsets into live staging or a package.
7. Record final Studio path/package and risk notes in the manifest.

Recommended quarantine path:

```text
ServerStorage.AssetQuarantine.CreatorStore.<AssetName>_<AssetId>
```

## First 15 Vertical-Slice Assets

The first pass uses the report's lean list:

1. Medieval Village MegaKit
2. Fantasy Props MegaKit
3. Stylized Nature MegaKit
4. LowPoly Asset Pack
5. Universal Base Characters
6. Modular Character Outfits - Fantasy
7. Ultimate Monsters
8. R6 Dummy
9. Sword of Darkness
10. Free VFX Pack #1
11. Beam Texture Pack
12. Universal Animation Library
13. Fantasy UI Borders
14. Mobile Controls
15. Interface Sounds

The split is:

- Download queue: Quaternius and Kenney packs.
- Creator Store insert plan: LowPoly Asset Pack, R6 Dummy, Sword of Darkness, Free VFX Pack #1, Beam Texture Pack.

## Import Readiness Checklist

Before importing a downloadable pack into Studio:

- Licence file is present under `raw/`.
- Source URL in manifest matches the official page.
- Asset is free/CC0 and no paid tier content is included.
- Only MVP subset has been processed.
- Names are stable and readable.
- Transforms are applied.
- Scale has been checked against Roblox character size.
- Collision assumptions are simple.
- Particle/audio budgets are mobile-safe where applicable.
- Manifest status is updated from `Queued - not downloaded` to the actual status.

Before moving a Creator Store asset out of quarantine:

- No untrusted scripts remain.
- No hidden remotes or bindables remain unless explicitly required and rewritten.
- Instance count is reasonable.
- Collision and anchoring are checked.
- Particle emitters are reviewed for mobile.
- Sounds are reviewed for volume and looping.
- Asset is renamed with a project-owned placeholder/package name.
- Manifest notes include final Studio path and remaining risks.

## Naming

Use replaceable placeholder names until the loop proves itself:

```text
PLACEHOLDER_AscensionPlaza
PLACEHOLDER_StrengthForge
PLACEHOLDER_BrokenGate
PLACEHOLDER_TrainingDummy
PLACEHOLDER_Brakk
PLACEHOLDER_Sword_Starter
PLACEHOLDER_RewardPopup
```

Use provider prefixes for processed local assets:

```text
QTN_MedievalVillage_*
QTN_FantasyProps_*
QTN_Nature_*
QTN_Characters_*
KEN_UIBorders_*
KEN_MobileControls_*
KEN_InterfaceSounds_*
RBX_Quarantine_*
```

## What Not To Do Yet

- Do not download any assets during this planning task.
- Do not insert Creator Store assets into Studio during this planning task.
- Do not import full megapacks into the live place.
- Do not modify gameplay, rewards, combat, training, profile data, or UI logic.
- Do not build guilds, raids, PvP, auction house, housing, monetisation, or a larger world.

## Next Step

After approval, download only the CC0 Quaternius/Kenney assets in `download_queue.md` and update `asset_manifest.csv` with actual archive names, licence file paths, and checksums if available. Keep Creator Store assets for a separate Studio insertion pass using `creator_store_insert_plan.md`.
