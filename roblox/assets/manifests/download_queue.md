# Ascension Grounds Download Queue

Kenney downloads have been performed where the official page exposed a direct archive URL. Quaternius items remain manual because their official pages did not expose direct shell-safe archive URLs.

## Rules

- Download only from the official source URL listed in `asset_manifest.csv`.
- Do not use paid tiers, unofficial mirrors, reposts, or scraped Creator Store files.
- Keep the original downloaded archive unchanged under `roblox/assets/raw/`.
- Keep licence/readme files beside the raw archive.
- Processed exports, subsets, renamed files, and Roblox-import-prep files go under `roblox/assets/processed/`.
- Creator Store assets are excluded from this queue and handled in `creator_store_insert_plan.md`.

## P0 Download Order

1. `Medieval Village MegaKit` - Quaternius  
   Source: `https://quaternius.com/packs/medievalvillagemegakit.html`  
   Raw target: `roblox/assets/raw/quaternius/medieval_village_megakit/`  
   Processed target: `roblox/assets/processed/quaternius/medieval_village_megakit/`  
   First extraction goal: central plaza shells, stone walls, stairs, small landmark pieces.

2. `Fantasy Props MegaKit` - Quaternius  
   Source: `https://quaternius.com/packs/fantasypropsmegakit.html`  
   Raw target: `roblox/assets/raw/quaternius/fantasy_props_megakit/`  
   Processed target: `roblox/assets/processed/quaternius/fantasy_props_megakit/`  
   First extraction goal: forge, anvil, chest, weapon rack, simple station props.

3. `Stylized Nature MegaKit` - Quaternius  
   Source: `https://quaternius.com/packs/stylizednaturemegakit.html`  
   Raw target: `roblox/assets/raw/quaternius/stylized_nature_megakit/`  
   Processed target: `roblox/assets/processed/quaternius/stylized_nature_megakit/`  
   First extraction goal: 10-20 reusable trees, bushes, rocks, path-border pieces.

4. `Universal Base Characters` - Quaternius  
   Source: `https://quaternius.com/packs/universalbasecharacters.html`  
   Raw target: `roblox/assets/raw/quaternius/universal_base_characters/`  
   Processed target: `roblox/assets/processed/quaternius/universal_base_characters/`  
   First extraction goal: humanoid scale/rig reference and NPC stand-ins.

5. `Modular Character Outfits - Fantasy` - Quaternius  
   Source: `https://quaternius.com/packs/modularcharacteroutfitsfantasy.html`  
   Raw target: `roblox/assets/raw/quaternius/modular_character_outfits_fantasy/`  
   Processed target: `roblox/assets/processed/quaternius/modular_character_outfits_fantasy/`  
   First extraction goal: armour silhouettes for starter gear, guards, Brakk direction.

6. `Ultimate Monsters` - Quaternius  
   Source: `https://quaternius.com/packs/ultimatemonsters.html`  
   Raw target: `roblox/assets/raw/quaternius/ultimate_monsters/`  
   Processed target: `roblox/assets/processed/quaternius/ultimate_monsters/`  
   First extraction goal: one slime-like or simple enemy, one heavier gate enemy, one boss-scale silhouette.

7. `Universal Animation Library` - Quaternius  
   Source: `https://quaternius.com/packs/universalanimationlibrary.html`  
   Raw target: `roblox/assets/raw/quaternius/universal_animation_library/`  
   Processed target: `roblox/assets/processed/quaternius/universal_animation_library/`  
   First extraction goal: idle, walk/run, basic melee, hit reaction, training stance clips.

8. `Fantasy UI Borders` - Kenney  
   Source: `https://kenney.nl/assets/fantasy-ui-borders`  
   Raw target: `roblox/assets/raw/kenney/fantasy_ui_borders/`  
   Processed target: `roblox/assets/processed/kenney/fantasy_ui_borders/`  
   First extraction goal: small set of panel/border sprites for stats HUD and reward popup.

9. `Mobile Controls` - Kenney  
   Source: `https://www.kenney.nl/assets/mobile-controls`  
   Raw target: `roblox/assets/raw/kenney/mobile_controls/`  
   Processed target: `roblox/assets/processed/kenney/mobile_controls/`  
   First extraction goal: attack, guard, dodge, interact button art.

10. `Interface Sounds` - Kenney  
    Source: `https://kenney.nl/assets/interface-sounds`  
    Raw target: `roblox/assets/raw/kenney/interface_sounds/`  
    Processed target: `roblox/assets/processed/kenney/interface_sounds/`  
    First extraction goal: UI click, confirm, reward tick, error/disabled feedback.

## Processing Notes

- Use a small subset first; do not import full megapacks into Studio.
- Prefer glTF or FBX when Roblox Studio Importer supports the asset cleanly.
- Apply transforms and split oversized bundles before Studio import.
- Convert only stable, inspected, cleaned groups into Roblox Packages.
- Record actual downloaded archive filenames, checksums if available, and licence file paths back into `asset_manifest.csv` before import.
- Quaternius manual-download skips are tracked in `manual_downloads.md`.
