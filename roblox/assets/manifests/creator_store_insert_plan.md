# Creator Store Insert Plan

Creator Store assets are not downloaded into `roblox/assets/raw/` and must not be scraped as local files. Insert them through Roblox Studio only, or list them here for manual insert.

## Quarantine Rule

Every inserted Creator Store asset must first go into a quarantine location, for example:

```text
ServerStorage
  AssetQuarantine
    CreatorStore
      <AssetName>_<AssetId>
```

Before use:

1. Inspect the inserted model tree.
2. Search all descendants for `Script`, `LocalScript`, `ModuleScript`, `RemoteEvent`, `RemoteFunction`, `BindableEvent`, `BindableFunction`, `MeshPart`, `Sound`, `ParticleEmitter`, `Beam`, and unusually large instance counts.
3. Remove or reject scripts. If a script is needed for behaviour, do not trust it; rewrite the behaviour in project-owned source instead.
4. Check model scale, collisions, anchored state, materials, particle count, audio loudness, and mobile performance.
5. Move only inspected art-only subsets out of quarantine.
6. Update `asset_manifest.csv` with the final Studio import status and any package/model path.

## Manual Insert Queue

### 1. LowPoly Asset Pack

- Asset ID: `16267075451`
- Source: `https://create.roblox.com/store/asset/16267075451/LowPoly-Asset-Pack`
- Author: `Uzii_Playz credit noted on report listing`
- Intended use: fast filler props and greybox dressing.
- Quarantine target: `ServerStorage.AssetQuarantine.CreatorStore.LowPolyAssetPack_16267075451`
- Inspection focus: scripts, excessive instance count, inconsistent materials, oversized collision parts.
- First approved subset: rocks, crates, simple signs, path dressing only.

### 2. R6 Dummy

- Asset ID: `8246626421`
- Source: `https://create.roblox.com/store/asset/8246626421/R6-Dummy`
- Author: `@WhosThatQuizmerioBro`
- Intended use: training dummy and immediate combat test target.
- Quarantine target: `ServerStorage.AssetQuarantine.CreatorStore.R6Dummy_8246626421`
- Inspection focus: scripts, humanoid configuration, rig scale, collision, health scripts.
- First approved subset: inert dummy rig only; gameplay logic must stay in project-owned server scripts.

### 3. Sword of Darkness

- Asset ID: `126183412074163`
- Source: `https://create.roblox.com/store/asset/126183412074163/Sword-of-Darkness`
- Author: `@heartyTomato2111`
- Intended use: starter sword placeholder and combat-feel test weapon.
- Quarantine target: `ServerStorage.AssetQuarantine.CreatorStore.SwordOfDarkness_126183412074163`
- Inspection focus: scripts, tool settings, Handle scale, attachments, sounds, particle emitters.
- First approved subset: mesh/model only; attack logic must stay server-authoritative in project scripts.

### 4. Free VFX Pack #1 By DogmathPan

- Asset ID: `8621531267`
- Source: `https://create.roblox.com/store/asset/8621531267/Free-VFX-Pack-1-By-DogmathPan`
- Author: `@DogmathPan`
- Intended use: impact effects, stat gain pulses, reward feedback tests.
- Quarantine target: `ServerStorage.AssetQuarantine.CreatorStore.FreeVFXPack1_8621531267`
- Inspection focus: scripts, particle count, emit rates, lifetime, texture IDs, mobile performance.
- First approved subset: one light impact effect and one reward sparkle effect after particle budget review.

### 5. Beam Texture Pack

- Asset ID: `5313497205`
- Source: `https://create.roblox.com/store/asset/5313497205/Beam-Texture-Pack`
- Author: `@TheXvinn`
- Intended use: forge core beams, Control Shrine energy lines, stat-gain streaks.
- Quarantine target: `ServerStorage.AssetQuarantine.CreatorStore.BeamTexturePack_5313497205`
- Inspection focus: scripts, texture IDs, licensing note in listing, brightness, overdraw risk.
- First approved subset: two beam texture variants for forge/control energy tests.

## Rejection Criteria

- Asset is paid or becomes paid.
- Asset source URL does not match the official Creator Store page.
- Asset includes obfuscated scripts, hidden remotes, or unknown behaviour.
- Asset materially changes game mechanics or valuable state.
- Asset is too heavy for mobile after a quick instance/particle review.
- Asset has unclear ownership or licence status.
