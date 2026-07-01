# Zero to Hero — Five Training Zone Recreation Specification

## Purpose

This document translates five concept images into a build specification that Codex can follow inside Roblox Studio.

The goal is **not** to reproduce the images pixel-for-pixel. The goal is to recreate their:

- Zone identity
- Landmark hierarchy
- General scale
- Color language
- Minigame placement
- Player navigation
- Major silhouettes
- Readability from a distance
- Mobile-safe visual impact

The target is a practical Roblox implementation using the tools Codex is most likely to have:

- Roblox Studio MCP
- Roblox Lua editing
- Studio object creation and property editing
- Primitive Parts, MeshParts already in the project, and approved art-only assets
- SurfaceGui, BillboardGui, TextLabel, ImageLabel
- ParticleEmitter, Beam, Trail, PointLight, SpotLight
- TweenService for limited decorative animation
- Terrain only where it is clearly safer than constructing geometry from Parts

Do not treat the concept images as exact architectural blueprints. They contain AI-generated details, impossible geometry, inconsistent scale, dense props, and decorative text that should be simplified for a real Roblox game.

---

# 1. Source Image Mapping

Before implementation, store the five references at stable project paths.

Suggested paths:

```text
roblox/assets/reference/roblox/training_zones/
  01_power_strength_forge.png
  02_vitality_guardian_grove.png
  03_agility_skyward_tower.png
  04_endurance_heroes_track.png
  05_control_arcane_shrine.png
```

Current uploaded source mapping:

| Stable name | Current uploaded file |
|---|---|
| `01_power_strength_forge.png` | `ChatGPT Image Jun 29, 2026, 10_19_25 AM (1).png` |
| `02_vitality_guardian_grove.png` | `ChatGPT Image Jun 29, 2026, 10_19_25 AM (2).png` |
| `03_agility_skyward_tower.png` | `ChatGPT Image Jun 29, 2026, 10_19_26 AM (3).png` |
| `04_endurance_heroes_track.png` | `ChatGPT Image Jun 29, 2026, 10_19_26 AM (4).png` |
| `05_control_arcane_shrine.png` | `ChatGPT Image Jun 29, 2026, 10_19_27 AM (5).png` |

All five references are 1672 × 941 and use a wide 16:9 composition.

---

# 2. Non-Negotiable Constraints

## 2.1 Preserve Existing Gameplay

This is a visual and spatial implementation specification.

Do not change:

- Profile data
- Stat formulas
- Combat math
- Reward calculations
- Inventory ownership
- Existing RemoteEvents or RemoteFunctions
- Server authority
- Enemy logic
- Existing progression values
- Existing minigame reward payloads

If a minigame already exists, rebuild the environment around its current interaction point rather than replacing the system.

If an interaction point must move:

1. Record its original position.
2. Record its prompt range and attributes.
3. Move the visual shell first.
4. Update the interaction position only if required.
5. Verify it in Play mode.
6. Document the old and new transforms.

## 2.2 Do Not Import Unchecked Models

Use only:

- Existing approved project assets
- Art-only subsets already inspected
- Primitive Parts
- Script-free approved models
- Locally created decorative geometry

Never move an entire Creator Store pack into the live game.

Do not use any asset containing:

- Scripts
- LocalScripts
- ModuleScripts
- RemoteEvents
- RemoteFunctions
- BindableEvents
- BindableFunctions
- Hidden network behavior
- Unverified constraints or executable logic

## 2.3 Build for Roblox, Not for a Render

The concepts are more detailed than the live game should be.

Prioritize:

1. Major landmark
2. Main minigame
3. Two secondary activity areas
4. Broad pathing
5. Strong color identity
6. A few large props
7. Background silhouette
8. Limited VFX

Do not prioritize:

- Tiny masonry details
- Dense clutter
- Hundreds of props
- One-off decorative meshes
- Numerous NPCs
- Excessive particles
- Perfectly curved architecture
- Exact recreation of generated text

## 2.4 Mobile-Safe Requirements

Per training zone, aim for:

- Fewer than 450 new BaseParts where practical
- Fewer than 25 active ParticleEmitters
- Fewer than 20 active dynamic lights
- Fewer than 10 continuously animated decorative objects
- No high-frequency loops running on the server
- No unbounded particle lifetime
- No collision on purely decorative objects
- No tiny loose props that players can snag on
- No transparent layers stacked excessively
- No complex unions unless already tested
- No more than 2–3 major neon effects visible at full intensity from the central hub

Use `StreamingEnabled` compatibility.

Decorative models should have:

```text
Anchored = true
CanCollide = false
CanTouch = false
CanQuery = false
CastShadow = false where shadow contribution is insignificant
```

Structural floors, stairs, rails, and gameplay objects may remain collidable.

---

# 3. Recommended Studio Hierarchy

Adapt this to the existing project tree rather than creating duplicate world roots.

```text
Workspace
  ZeroToHeroWorld
    TrainingZones
      Power_StrengthForge
        Architecture
        Ground
        Paths
        Props
        Signs
        Lighting
        VFX
        Minigames
          ForgeStrike
          TitanLift
          BoulderBreak
        InteractionAnchors
        ScreenshotCameras
      Vitality_GuardianGrove
        Architecture
        Ground
        Paths
        Props
        Signs
        Lighting
        VFX
        Minigames
          GuardianPulse
          HealingBrew
          ResilienceTrial
        InteractionAnchors
        ScreenshotCameras
      Agility_SkywardTower
        Architecture
        Ground
        Paths
        Props
        Signs
        Lighting
        VFX
        Minigames
          SkylineRush
          ReactionDash
          CourierRun
        InteractionAnchors
        ScreenshotCameras
      Endurance_HeroesTrack
        Architecture
        Ground
        Paths
        Props
        Signs
        Lighting
        VFX
        Minigames
          PaceTrial
          HurdleCircuit
          TeamRelay
        InteractionAnchors
        ScreenshotCameras
      Control_ArcaneShrine
        Architecture
        Ground
        Paths
        Props
        Signs
        Lighting
        VFX
        Minigames
          RuneAlignment
          OrbGuidance
          FocusSequence
        InteractionAnchors
        ScreenshotCameras
```

Every new model should receive useful attributes:

```text
ZoneId
MinigameId
Decorative
GameplayCritical
Phase
AssetSource
MobilePriority
```

Example:

```text
ZoneId = "Power"
MinigameId = "ForgeStrike"
Decorative = true
GameplayCritical = false
Phase = "TrainingZoneVisualPass"
AssetSource = "PrimitiveBuilt"
MobilePriority = "High"
```

---

# 4. Shared Scale Standard

Roblox characters are approximately 5–6 studs tall.

Use these practical scale targets:

| Element | Recommended size |
|---|---:|
| Main public road | 18–24 studs wide |
| Secondary path | 10–14 studs wide |
| Minigame entry path | 8–12 studs wide |
| Standard doorway | 7–9 studs wide, 10–13 studs tall |
| Main zone sign | 18–28 studs wide |
| Secondary activity sign | 10–16 studs wide |
| Safety rail height | 3.5–4.5 studs |
| Stair tread depth | 1.5–2.5 studs |
| Plaza minigame pad | 24–40 studs diameter |
| Small activity pad | 18–26 studs diameter |
| Major landmark | 35–85 studs tall |
| Background cliff | 45–120 studs tall |

The player should be able to identify each zone from 120–200 studs away.

---

# 5. Shared Visual Language

## 5.1 Overall Style

Target:

- Chunky low-poly fantasy
- Clear Roblox proportions
- Broad readable paths
- Large simple silhouettes
- Bright color coding
- Limited fine detail
- Friendly fantasy rather than grim realism
- One focal landmark per zone
- One dominant color plus neutral stone and wood

Avoid:

- Photorealistic materials
- Thin fragile details
- Overly realistic medieval construction
- Dense gothic ornament
- Excessive darkness
- Large areas of pure Neon material
- Tiny props that cannot be seen from the gameplay camera

## 5.2 Base Materials

Recommended Roblox materials:

| Use | Material |
|---|---|
| Main masonry | Slate, Cobblestone, Concrete |
| Trim blocks | Slate or SmoothPlastic |
| Timber | WoodPlanks |
| Metal | Metal or DiamondPlate sparingly |
| Paths | Cobblestone, Ground, Concrete |
| Grass | Grass or Terrain grass |
| Magic surfaces | SmoothPlastic with limited Neon accents |
| Water | Terrain water or transparent SmoothPlastic |
| Banners | Fabric |
| Crystals | Glass or Neon with transparent shell |

## 5.3 Shared Neutral Palette

Suggested Color3 values can be adjusted to existing project palettes.

```lua
StoneDark      = Color3.fromRGB(54, 58, 66)
StoneMid       = Color3.fromRGB(82, 88, 96)
StoneLight     = Color3.fromRGB(135, 138, 135)
PathStone      = Color3.fromRGB(148, 143, 128)
WoodDark       = Color3.fromRGB(75, 48, 29)
WoodMid        = Color3.fromRGB(114, 75, 43)
MetalDark      = Color3.fromRGB(42, 45, 50)
GrassBase      = Color3.fromRGB(72, 111, 55)
WarmLantern    = Color3.fromRGB(255, 174, 74)
```

## 5.4 Zone Accent Palettes

### Power

```lua
PowerPrimary   = Color3.fromRGB(232, 111, 28)
PowerBright    = Color3.fromRGB(255, 169, 47)
PowerDeep      = Color3.fromRGB(128, 48, 19)
```

### Vitality

```lua
VitalityPrimary = Color3.fromRGB(64, 178, 91)
VitalityBright  = Color3.fromRGB(92, 255, 139)
VitalityDeep    = Color3.fromRGB(35, 91, 51)
```

### Agility

```lua
AgilityPrimary = Color3.fromRGB(134, 71, 224)
AgilityBright  = Color3.fromRGB(195, 101, 255)
AgilityCyan    = Color3.fromRGB(70, 222, 255)
```

### Endurance

```lua
EndurancePrimary = Color3.fromRGB(121, 156, 50)
EnduranceBright  = Color3.fromRGB(190, 220, 77)
TrackEarth       = Color3.fromRGB(145, 98, 55)
```

### Control

```lua
ControlPrimary = Color3.fromRGB(51, 169, 227)
ControlBright  = Color3.fromRGB(86, 224, 255)
ControlDeep    = Color3.fromRGB(23, 76, 118)
```

---

# 6. Shared Reusable Builders

Codex should create reusable helper functions or modules only if that matches the current architecture.

Do not introduce a new framework if the project already has one.

Recommended reusable builders:

```lua
createStonePlatform(config)
createCircularPad(config)
createSegmentedRing(config)
createSegmentedEllipse(config)
createSign(config)
createBanner(config)
createTorch(config)
createLanternPost(config)
createLowPolyPine(config)
createCrateStack(config)
createCrystal(config)
createSimpleBench(config)
createSafetyRail(config)
createGlowMarker(config)
createScreenshotCamera(config)
```

## 6.1 Sign Builder

Use a solid backing Part with a SurfaceGui.

Recommended structure:

```text
ActivitySign
  Backing
  TrimTop
  TrimBottom
  LeftPost
  RightPost
  SurfaceGui
    Title
    Subtitle
    NumberBadge
```

Guidelines:

- Use `TextScaled = true`.
- Set readable `UITextSizeConstraint`.
- Use a bold Roblox-supported font.
- Keep title under 22 characters when possible.
- Use high contrast.
- Avoid large paragraphs.
- Use `AlwaysOnTop = false` for world signs.
- Make the sign readable from 40–80 studs.
- Use a dark backing and accent-colored trim.
- Use the number badge only for minigame ordering.

## 6.2 Circular Pad Builder

Use 12–24 wedge-like or rectangular tangent segments.

If exact curves are not possible:

- Use a 16-sided polygon.
- Keep the outer edge consistent.
- Hide small gaps with a dark base disc.
- Use thin neon segments for the glow line.
- Use `CanCollide = false` on decorative glow.

## 6.3 Segmented Ring Builder

For magical rings:

- Prefer an approved torus MeshPart if one already exists.
- Otherwise create 12–20 thin rectangular segments around a circle.
- Rotate each segment tangentially.
- Group under one Model with a defined PrimaryPart.
- Rotate the model with TweenService or RunService on the client.
- Keep server animation disabled unless required.

## 6.4 Low-Poly Tree Builder

Preferred:

- Approved low-poly tree asset with no scripts.

Fallback:

- Trunk: 2–4 tapered cylinders or block sections.
- Branches: 4–8 cylinders.
- Canopy: 5–9 low-poly spheres or blocky clusters.
- Use two or three greens.
- Avoid more than 20 parts per tree.
- Disable collision on canopy.
- Use one larger tree rather than many small trees.

## 6.5 NPC Placeholders

NPCs in the concept images are for scale and activity.

Do not spawn many active humanoids purely for decoration.

Use:

- Existing R6 dummy art-only rigs
- Static mannequins
- At most 3–6 decorative NPCs per zone
- No AI loops unless already supported
- No active Humanoid if a static anchored mannequin is sufficient

Real players should provide most of the movement.

---

# 7. Global Lighting and Atmosphere

Use the existing world lighting as the source of truth.

Suggested direction:

```text
Technology: Future or ShadowMap according to project baseline
ClockTime: 13.5–16.5
Brightness: moderate
Ambient: slightly cool
OutdoorAmbient: neutral blue-gray
ColorShift_Top: subtle warm
Atmosphere: low haze
Bloom: restrained
SunRays: subtle
ColorCorrection: mild saturation and contrast
```

Do not create one global Lighting configuration per zone.

Instead, zone identity should come from:

- Local lights
- Material color
- Neon accents
- VFX
- Banners
- Landmark glow

Keep all decorative lights local to their zone.

---

# 8. Zone 1 — Power: Strength Forge

## 8.1 Source Image Summary

The image shows a broad stone training yard facing a single large forge building.

The focal hierarchy is:

1. Large Strength Forge façade
2. Orange furnace opening
3. Central Forge Strike anvil ring
4. Titan Lift area on the left
5. Boulder Break area on the right
6. Broad entrance path in the foreground
7. Mountains and trees as distant backdrop

The image is symmetrical around the central forge.

The left and right activity areas are deliberately different:

- Left is mechanical and organized
- Right is natural and destructive

The zone is warm, energetic, and physically strong without becoming dark or hostile.

## 8.2 Recommended Footprint

```text
Overall zone footprint: 150 × 115 studs
Main entry path: 20 studs wide
Central yard: approximately 95 × 75 studs
Forge façade: 62 studs wide × 26 studs deep × 45 studs high
Forge Strike pad: 30–34 studs diameter
Titan Lift area: 42 × 34 studs
Boulder Break area: 42 × 34 studs
```

Use the central axis as `Z`.

Suggested local origin:

```text
Zone origin = center of Forge Strike pad
Forge building = 0, 0, -43
Entry stairs = 0, 0, 42
Titan Lift = -45, 0, 5
Boulder Break = 45, 0, 5
```

## 8.3 Ground Layout

Create:

- Central packed-earth or stone yard
- Stone border around the entire activity area
- Broad stone entry path
- Three activity pads
- Low retaining wall around the back and sides
- Minimal grass strips outside the zone

The ground should not be perfectly clean.

Add:

- 12–20 large flat stone patches
- A few embedded cracked tiles
- Small rubble groups near walls
- No loose physics objects

## 8.4 Main Forge Building

### Silhouette

The building should read as:

- Heavy
- Wide
- Squared
- Fortified
- Industrial
- Simple enough for Roblox

Build with:

- Large stone base
- Central arched furnace
- Two side towers
- Two taller rear chimneys
- One large sign or emblem above the entry
- Two hanging banners
- Two heavy decorative chains

Do not attempt complex castle geometry.

### Recommended Dimensions

```text
Base wall: 62w × 18d × 24h
Center arch opening: 16w × 6d × 18h
Side tower pair: 11w × 14d × 32h each
Rear chimneys: 7w × 7d × 42h
Top emblem: 14w × 2d × 12h
```

### Furnace Core

The furnace must be visible from the hub.

Use:

- One recessed orange Neon plane
- One transparent Glass layer in front
- 2–3 flame ParticleEmitters
- One PointLight
- One warm SpotLight aimed outward
- Optional animated texture only if already available
- A dark arch around the opening

Avoid filling the entire room with Neon.

### Chains

Use:

- Existing chain MeshPart if approved
- Otherwise use repeated short cylinders or links
- 12–20 links maximum per chain
- Chains should be decorative and non-collidable
- Use two major chains, not many smaller ones

### Banners

Two red-orange vertical banners should flank the furnace.

Each banner:

```text
Width: 5–6 studs
Height: 13–16 studs
Material: Fabric
Accent trim: orange
Symbol: simple dumbbell or fist icon if available
```

If no icon asset exists, use a simple geometric emblem made from Parts.

## 8.5 Minigame 1 — Forge Strike

### Visual Placement

Forge Strike is central and closest to the main path.

Components:

- Circular stone pad
- Orange glowing outer ring
- Raised anvil
- Hammer rack
- One small interaction console or prompt pedestal
- Activity sign facing the entry path

### Pad

```text
Outer diameter: 32 studs
Inner active circle: 22 studs
Height above yard: 0.75–1.25 studs
Outer ring segments: 16
Glow width: 0.35–0.6 studs
```

The anvil should sit at the exact center.

If an approved anvil asset exists, use it.

Fallback anvil:

- Base block
- Narrow waist
- Flat top
- One tapered horn built from WedgeParts

### Visual Feedback

When the existing minigame runs:

- Brief orange flash
- Sparks from anvil
- Small ring pulse
- Hammer impact sound
- No server-heavy continuous effect

Perfect hit:

- Larger spark burst
- Short vertical beam
- Slight camera shake if existing camera system supports it
- Do not create a new camera system only for this

### Sign

```text
Badge: 1
Title: FORGE STRIKE
Subtitle: Time your hammer
```

The reference subtitle is not mandatory.

## 8.6 Minigame 2 — Titan Lift

### Visual Placement

Left side of the yard.

The area should feel organized like an outdoor fantasy gym.

Components:

- Three lifting stations
- Heavy barbell silhouettes
- One rack
- One bench
- One interaction pad
- Activity sign
- Short fence or stone border

### Simplified Prop Set

Use three station types:

1. Standing deadlift bar
2. Bench press silhouette
3. Oversized dumbbell rack

Keep the barbells thick and readable.

Recommended size:

```text
Bar length: 12–16 studs
Plate diameter: 3.5–5 studs
Rack height: 5–7 studs
Station spacing: 8–10 studs
```

Do not use dozens of weight plates.

### Sign

```text
Badge: 2
Title: TITAN LIFT
Subtitle: Raise the weight
```

## 8.7 Minigame 3 — Boulder Break

### Visual Placement

Right side of the yard.

Components:

- Three large boulders
- Cracked glowing seams
- Impact floor marks
- One interaction anchor per active boulder
- Activity sign
- Small rubble around the base

### Boulder Construction

Preferred:

- Approved low-poly rock MeshParts

Fallback:

- 5–8 intersecting blocky rock Parts
- Weld or anchor as one visual cluster
- Use dark gray stone
- Add 3–5 thin orange Neon crack pieces on the front face

Recommended boulder scale:

```text
Small: 8 × 7 × 8
Medium: 10 × 9 × 10
Large: 12 × 11 × 13
```

Only one boulder needs to be gameplay-active at launch.

The others may be decorative progression targets.

### Sign

```text
Badge: 3
Title: BOULDER BREAK
Subtitle: Smash the stone
```

## 8.8 Props and Decoration

Add only:

- 4–6 torches
- 2 banners
- 2 chain runs
- 3–5 crates
- 2 hammer racks
- 4–8 rubble piles
- 4–6 pine trees outside the activity yard
- 2 distant cliff groups

## 8.9 Camera Target

For a reference-style screenshot:

```text
Camera position: approximately 0, 85, 135 relative to zone origin
Camera target: 0, 10, -5
FieldOfView: 58–65
```

The entire façade, central anvil, left weights, and right boulders must fit.

## 8.10 Strength Forge Acceptance Checklist

- Forge is readable from at least 150 studs.
- Orange furnace is the brightest local landmark.
- Forge Strike is central.
- Titan Lift is clearly left.
- Boulder Break is clearly right.
- Entry path is at least 18 studs wide.
- Players cannot get stuck between equipment.
- Decorative rocks do not block minigame prompts.
- Existing Strength Forge gameplay still works.
- VFX remain readable on low graphics settings.
- Zone does not exceed mobile performance budget.

---

# 9. Zone 2 — Vitality: Guardian Grove

## 9.1 Source Image Summary

The image shows a circular healing sanctuary centered on a huge magical life tree.

The focal hierarchy is:

1. Life tree with glowing heart crystal
2. Guardian Pulse shield circle
3. Healing Brew apothecary area on the left
4. Resilience Trial hazard ring on the right
5. Healer’s Shelter in the foreground-right
6. Large entry sign and path in the foreground
7. Ruins, streams, and trees as backdrop

The visual mood is safe, restorative, green, and magical.

The central life tree must be visible above surrounding structures.

## 9.2 Recommended Footprint

```text
Overall footprint: 165 × 125 studs
Main circular plaza: 72 studs diameter
Central tree base: 28–34 studs diameter
Tree height: 42–55 studs
Healing Brew area: 42 × 34 studs
Resilience Trial ring: 38–42 studs diameter
Healer Shelter: 28 × 22 studs
Entry path: 18–20 studs wide
```

Suggested local placements:

```text
Tree center = 0, 0, -10
Healing Brew = -48, 0, 4
Resilience Trial = 48, 0, 4
Healer Shelter = 42, 0, 40
Entry sign = -35, 0, 48
```

## 9.3 Central Life Tree

### Preferred Approach

Use an approved low-poly tree model if available and script-free.

Modify only:

- Scale
- Material colors
- Added heart crystal
- Added local VFX
- Base platform

### Primitive Fallback

Build the tree from:

- 3–5 trunk cylinders or blocky tapered sections
- 6–10 branch cylinders
- 6–9 canopy clusters
- 1 central heart crystal
- 2–4 wrapping vine cylinders

Keep the total tree under approximately 35 parts.

### Heart Crystal

Create a large heart-like or diamond-like crystal embedded in the trunk.

If a heart mesh is unavailable:

- Use one large vertical crystal
- Add two small upper crystal lobes
- Cover part of it with vine pieces
- The result only needs to imply a heart

Recommended size:

```text
Crystal body: 8w × 4d × 13h
Glow color: cyan-green
Transparency: 0.1–0.25
Material: Glass or Neon shell
```

### VFX

Use:

- 1 soft ParticleEmitter for floating motes
- 1 PointLight inside the crystal
- 2 Beam or ring effects maximum
- 4 shield markers around the base
- Optional slow pulse using TweenService

## 9.4 Central Platform and Water

The tree stands on a raised circular platform with stairs from the front.

Recommended:

```text
Platform diameter: 34 studs
Platform height: 3 studs
Front stair width: 12 studs
Water channel width: 2.5–4 studs
```

Use four short water channels or small waterfalls around the platform.

Fallback:

- Transparent blue-cyan Parts with low reflectance
- No active physical water
- Use one soft particle splash at each fall
- Disable collision

## 9.5 Minigame 1 — Guardian Pulse

### Visual Placement

Guardian Pulse wraps around the tree.

Create four shield stations around the central platform at cardinal directions.

Each station:

- 5–6 stud circular marker
- Green shield icon or geometric emblem
- One prompt anchor
- Clear line of sight to the tree

The active play area should be a 46–54 stud circle around the tree.

### Incoming Wave Visuals

If the gameplay supports directional attacks:

- Use short-lived arcs or planes
- Color incoming wave orange-red
- Color successful defense green
- Do not keep all effects active continuously

### Sign

Place front-center facing the entry.

```text
Badge: 1
Title: GUARDIAN PULSE
Subtitle: Shield training
```

## 9.6 Minigame 2 — Healing Brew

### Visual Placement

Left side of the grove.

This area should look like a small outdoor fantasy apothecary, not a large building.

Components:

- One shelter or kiosk
- Two potion worktables
- One cauldron
- Ingredient shelf
- Herb planters
- Colored bottles
- Activity sign

### Shelter

```text
Width: 22–26 studs
Depth: 14–18 studs
Height: 14–18 studs
Roof: green or dark teal
Open front
```

### Tables

Use 2–3 tables with:

- 3–5 bottle silhouettes each
- One mortar or bowl
- One ingredient basket
- Limited particle glow

Do not create individual physics bottles.

### Sign

```text
Badge: 2
Title: HEALING BREW
Subtitle: Potion crafting
```

## 9.7 Minigame 3 — Resilience Trial

### Visual Placement

Right side.

Create a circular floor arena with alternating safe and hazard tiles.

Recommended:

```text
Outer diameter: 40 studs
Tile count: 12–16
Safe tiles: green
Warning tiles: orange
Hazard tiles: red-orange
```

Use a dark stone base disc.

Only active tiles should light up.

Do not leave all tiles Neon at once.

### Layout

Use:

- 3 concentric rings or one segmented ring
- 4 lantern posts
- Low non-blocking perimeter fence
- One interaction anchor at entry

### Sign

```text
Badge: 3
Title: RESILIENCE TRIAL
Subtitle: Avoid and endure
```

## 9.8 Healer’s Shelter

The Healer’s Shelter is a roleplay and recovery structure, not another minigame.

Use:

- Small open-front cabin
- Green cross or heart emblem
- One treatment bed
- One shelf
- One table
- 2–3 potted plants
- One sign

Recommended text:

```text
HEALER'S SHELTER
Rest and restore
```

Do not use a real-world medical red cross mark.

Use an original green plus, heart, leaf, or shield emblem.

## 9.9 Ruins and Environment

Add:

- 5–8 ruined wall sections
- 6–10 pine trees
- 3–5 broad-leaf trees
- 2 small streams
- 2 distant waterfalls if terrain allows
- 5 benches
- Flower clusters
- 4–6 lanterns
- 4 green banners

Keep the central tree clearly visible.

## 9.10 Camera Target

```text
Camera position: 0, 92, 135
Camera target: 0, 8, -5
FieldOfView: 60–68
```

Frame the full tree, potion area, resilience ring, healer shelter, and entry path.

## 9.11 Guardian Grove Acceptance Checklist

- Life tree is visible above the grove from the hub.
- Green crystal is the brightest local focal point.
- Guardian Pulse reads as the central activity.
- Potion area is clearly left.
- Hazard ring is clearly right.
- Healer shelter reads as a small roleplay building.
- Paths are broad enough for groups.
- Tree roots and vines do not trap players.
- Decorative water has no unintended collision.
- Existing Vitality data path remains unchanged.
- Effects remain mobile-safe.

---

# 10. Zone 3 — Agility: Skyward Tower

## 10.1 Source Image Summary

The image shows one tall, simple tower with a spiral obstacle route.

The focal hierarchy is:

1. Tall tower
2. Purple finish ring at the top
3. Skyline Rush platforms wrapping the tower
4. Reaction Dash pad on the left
5. Courier Run start area on the right
6. Broad central entrance path
7. Mountains and pine forest backdrop

This is the most vertical zone.

The tower should be visible from almost anywhere in the safe zone.

## 10.2 Recommended Footprint

```text
Overall footprint: 160 × 120 studs
Tower base: 34 × 34 studs
Tower height: 70–85 studs
Obstacle route maximum width: 70 studs
Reaction Dash pad: 34–38 studs diameter
Courier Run staging area: 42 × 32 studs
Entry plaza: 34 × 28 studs
```

Suggested local placements:

```text
Tower center = 0, 0, -15
Reaction Dash = -48, 0, 22
Courier Run = 48, 0, 22
Entry path = 0, 0, 48
```

## 10.3 Tower Architecture

### Silhouette

Use:

- Cylindrical or octagonal stone tower
- 4 visible levels
- Wood support beams
- Purple windows
- Wraparound platforms
- One finish platform
- One large top ring

Avoid:

- Dozens of tiny platforms
- Extremely thin beams
- Complex rope physics
- Unreadable maze routes

### Dimensions

```text
Base floor: 34w × 34d
Level heights: 15–18 studs
Total roof/platform height: 72–82 studs
Top platform: 26–30 studs diameter
```

An octagonal tower is easier to build than a true cylinder.

Use 8 wall segments or a large cylinder if available.

### Tower Levels

Recommended route:

1. Ground entry
2. Short exterior ramp
3. First wrap platform
4. Moving or timed bridge
5. Second wrap platform
6. Hanging bridge
7. Final climb
8. Finish ring

The reference appears denser than the final game should be.

Build only 6–8 meaningful obstacles.

## 10.4 Minigame 1 — Skyline Rush

### Route Design

Target completion time:

```text
Beginner: 35–55 seconds
```

Recommended obstacle sequence:

1. Wide stepping platforms
2. Low beam crossing
3. Short wall-jump or ladder section
4. Two moving platforms
5. Suspended platform
6. Final ramp
7. Finish ring

All obstacles should support mobile controls.

Minimum platform width:

```text
Normal route: 5–7 studs
Beginner route: 7–10 studs
```

Avoid jumps requiring edge-perfect precision.

### Checkpoints

Use 2–3 checkpoints.

Each checkpoint:

- Bright purple marker
- Spawn recovery point
- Server-authoritative completion
- No reward duplication

### Finish Ring

The finish ring is the top landmark.

Preferred:

- Torus MeshPart

Fallback:

- 20 segmented Neon pieces

Recommended:

```text
Diameter: 32–38 studs
Color: purple-pink
Thickness: 0.7–1.2 studs
```

Use a slow pulse, not a fast rotation.

### Sign

Place on tower front:

```text
Title: SKYLINE RUSH
Subtitle: Reach the top
```

## 10.5 Minigame 2 — Reaction Dash

### Visual Placement

Left of the tower.

Create:

- One circular pad
- Four outer glowing pads
- One center emblem
- Low border
- Activity sign

Recommended:

```text
Arena diameter: 36 studs
Outer pad diameter: 6 studs
Center pad diameter: 8 studs
```

Pads should be positioned at north, south, east, west.

When active:

- Target pad becomes bright cyan or purple
- Other pads dim
- Add a short vertical beam on target
- Do not use constant large particles

### Sign

```text
Title: REACTION DASH
Subtitle: Hit the pads
```

## 10.6 Minigame 3 — Courier Run

### Visual Placement

Right side.

This is primarily a start station.

Components:

- Parcel counter
- 8–12 crates
- Route board
- Start gate
- Arrow markers
- Activity sign

Recommended staging size:

```text
42 × 32 studs
Start gate width: 12 studs
```

The actual courier route should use the existing hub roads rather than creating a separate maze.

### Route Markers

Use:

- Cyan arrows
- Small banner posts
- Destination markers
- Limited Beams only when needed

Do not leave a full route highlighted permanently.

### Sign

```text
Title: COURIER RUN
Subtitle: Grab a parcel
```

## 10.7 Tower Safety

Required:

- Invisible fall-catch volume or recovery teleport
- No death for casual training falls unless current design requires it
- No moving platform network ownership issues
- Server verifies checkpoint progress
- Rails where falling is not part of the challenge
- Broad landing areas
- Mobile jump testing

Decorative suspended platforms should be anchored.

If a moving platform exists:

- Use server-controlled TweenService or a proven platform controller
- Limit count to two
- Use predictable timing
- Avoid physics forces

## 10.8 Props and Decoration

Add:

- 4–6 purple banners
- 6–8 torches
- 6–10 crates in courier area
- 3–5 wooden support beams per level
- 6–8 pine trees around perimeter
- 2–3 distant cliff groups
- 2 small route boards
- No more than 3 hanging decorative platforms

## 10.9 Camera Target

```text
Camera position: 0, 70, 145
Camera target: 0, 27, -10
FieldOfView: 60–68
```

The top finish ring must remain in frame.

## 10.10 Skyward Tower Acceptance Checklist

- Tower is visible from 200 studs.
- Finish ring is readable from ground level.
- Route is understandable without a tutorial.
- Platforms are wide enough for mobile.
- Reaction Dash reads as a separate left-side activity.
- Courier Run reads as a right-side staging area.
- Falling does not strand the player.
- Tower does not block the main hub skyline excessively.
- Moving parts do not cause server performance issues.
- Existing Agility stat logic remains unchanged.

---

# 11. Zone 4 — Endurance: Heroes’ Track

## 11.1 Source Image Summary

The image shows a broad oval running track in an open valley.

The focal hierarchy is:

1. Oval running track
2. Timer gate at the far end
3. Pace Trial start sign in the foreground
4. Hurdle Circuit on the left
5. Team Relay lane on the right
6. Small spectator stand
7. Water station
8. Open mountains and trees beyond

This zone should feel spacious and active.

It is the least architectural zone.

## 11.2 Recommended Footprint

```text
Overall footprint: 195 × 145 studs
Outer track length footprint: 150 × 100 studs
Track width: 18–24 studs
Center field: 100 × 55 studs
Hurdle lane: 20 × 70 studs
Relay lane: 18 × 65 studs
Spectator stand: 38 × 20 studs
Water station: 18 × 12 studs
```

The track should support groups.

## 11.3 Oval Track Construction

Roblox does not provide an easy native curved road Part.

Recommended method:

- Create 32 or 40 tangent-aligned track segments around an ellipse.
- Each segment is a flat rectangular Part.
- Use a dark base under all segments to hide small gaps.
- Add white lane markers as thin non-collidable segments.
- Use one or two lanes visually rather than four fully physical lanes.

### Ellipse Formula

For each segment index:

```lua
theta = (index / segmentCount) * math.pi * 2
x = radiusX * math.cos(theta)
z = radiusZ * math.sin(theta)
```

The segment should face the tangent direction.

Use:

```lua
tangentAngle = math.atan2(radiusZ * math.cos(theta), -radiusX * math.sin(theta))
```

Exact implementation may vary based on axis conventions.

Recommended:

```text
segmentCount: 32
radiusX: 65 studs
radiusZ: 40 studs
track segment width: 10–12 studs
```

Create a second adjacent lane only if performance remains acceptable.

### Track Surface

Use:

- Ground or SmoothPlastic
- Earth brown
- White lane lines
- Stone curb
- Green grass center

## 11.4 Minigame 1 — Pace Trial

### Visual Placement

The whole oval track is the main minigame.

Components:

- Start line in foreground
- Timer gate at far end
- 4–6 checkpoint markers
- Optional pace-zone UI
- Start sign
- Finish flags

### Start Sign

```text
Badge: 1
Title: PACE TRIAL
Subtitle: Run the loop
```

### Timer Gate

Use:

- Two timber posts
- Crossbeam
- Green banners
- Digital timer SurfaceGui
- Small clock emblem

Recommended width:

```text
18–24 studs
```

The timer should be readable from the near side of the track.

### Timing Markers

Use 4–6 green checkered flags or glow posts.

Do not place one every few studs.

## 11.5 Minigame 2 — Hurdle Circuit

### Visual Placement

Left side of the track.

Create a parallel obstacle lane with:

- 3 hurdles
- 2 low log vaults
- 1 low wall
- 1 short mud or slow zone if mechanics support it
- Start and finish marker

Minimum lane width:

```text
10–12 studs
```

Obstacle dimensions:

```text
Hurdle height: 3–4 studs
Log height: 2.5–3.5 studs
Wall height: 5–6 studs
Landing distance: at least 8 studs
```

### Sign

```text
Badge: 2
Title: HURDLE CIRCUIT
Subtitle: Jump and vault
```

## 11.6 Minigame 3 — Team Relay

### Visual Placement

Right side.

Create:

- Straight relay lane
- 3 handoff zones
- Glowing baton posts
- Start and finish lines
- Activity sign
- Optional small waiting area

Recommended:

```text
Lane length: 55–70 studs
Lane width: 12–16 studs
Handoff zone length: 8–10 studs
```

Use three colored glow posts:

- Blue
- Purple
- Yellow-green

Do not make the relay dependent on having four players at launch.

Support:

- Solo practice
- Two-player relay
- Group relay later

### Sign

```text
Badge: 3
Title: TEAM RELAY
Subtitle: Pass and run
```

## 11.7 Center Field

The center should remain mostly open.

Add only:

- One small brazier or endurance monument
- Low grass variation
- 3–5 rocks
- Small flowers
- Optional stretching area

Do not fill the center with buildings.

It acts as visual breathing room.

## 11.8 Spectator Stand

Right-back side.

Recommended:

```text
Width: 34–40 studs
Depth: 15–20 studs
Height: 14–18 studs
Rows: 3
```

Use simple timber and green canvas roof.

Keep seating decorative.

Only use actual Seat objects if players are expected to sit there.

## 11.9 Water Station

Front-left.

Components:

- Small awning
- Table
- Barrel silhouettes
- Water bottle props
- Sign
- Optional interaction prompt

Text:

```text
WATER STATION
Refill and refresh
```

Avoid making water a mandatory monetized resource.

## 11.10 Environment

Add:

- 12–18 pine trees around outer perimeter
- 4 green banners
- 6–8 torches
- 2 tents
- 2 rocky outcrop groups
- Distant cliff silhouettes
- Low wooden perimeter fence
- Small entrance arch

Keep the skyline open.

## 11.11 Camera Target

```text
Camera position: 0, 105, 145
Camera target: 0, 0, 0
FieldOfView: 62–70
```

The entire oval should fit in frame.

## 11.12 Heroes’ Track Acceptance Checklist

- The entire track is readable from the zone entrance.
- Track is wide enough for 8–12 players.
- Pace Trial start and timer gate are visible simultaneously.
- Hurdle lane is clearly left.
- Relay lane is clearly right.
- Center field remains open.
- Track segments do not create collision bumps.
- Lane markers do not collide.
- Timer updates efficiently.
- Endurance gameplay works on mobile.
- Zone remains performant despite segmented curves.

---

# 12. Zone 5 — Control: Arcane Shrine

## 12.1 Source Image Summary

The image shows a clean circular magical courtyard centered on a large rotating armillary structure.

The focal hierarchy is:

1. Central floating orb
2. Large rotating rune rings
3. Rune Alignment platform
4. Orb Guidance course on the left
5. Focus Sequence rune circle on the right
6. Shrine Scholar kiosk
7. Water, pillars, and crystals around the edges

This zone should feel calm, precise, intelligent, and magical.

It should be less cluttered than the concept image.

## 12.2 Recommended Footprint

```text
Overall footprint: 165 × 125 studs
Main shrine plaza: 72 studs diameter
Central armillary base: 26–30 studs diameter
Armillary height: 32–40 studs
Orb Guidance course: 45 × 32 studs
Focus Sequence pad: 34–38 studs diameter
Scholar kiosk: 27 × 20 studs
Entry path: 18 studs wide
```

Suggested placements:

```text
Central shrine = 0, 0, -8
Orb Guidance = -48, 0, 10
Focus Sequence = 46, 0, 18
Scholar kiosk = 47, 0, -35
Entry path = 0, 0, 48
```

## 12.3 Central Armillary Structure

### Preferred Method

Use approved ring MeshParts if available.

Structure:

- Raised circular base
- Central glowing orb
- Three large crossing rings
- Four crystal pillars
- Rune details
- Soft vertical beams

### Primitive Fallback

Each ring:

- 16 segmented rectangular Parts
- 18–24 stud radius
- 0.5–0.8 stud thickness
- Dark stone or metal body
- Thin blue Neon rune strip

Use three ring Models:

```text
RingHorizontal
RingTiltA
RingTiltB
```

Set one stable PrimaryPart per ring.

Animate locally with slow rotation.

Recommended speed:

```text
12–30 seconds per revolution
```

Do not rotate all rings rapidly.

### Central Orb

Use:

- Glass sphere or faceted crystal
- Blue-cyan glow
- One PointLight
- One low-rate ParticleEmitter
- Optional small Beam to base

Recommended size:

```text
5–7 studs diameter
```

## 12.4 Rune Alignment Platform

This is the central minigame.

Components:

- Circular base
- 3 or 4 player consoles
- Ring structure
- Central orb
- Activity sign
- Small rune pillars

Recommended:

```text
Outer platform diameter: 38–44 studs
Console distance from center: 17–20 studs
```

Each console:

- 3 × 3 stud pedestal
- Small screen or rune plate
- Existing interaction prompt anchor
- No individual continuous light if avoidable

### Sign

```text
Badge: 1
Title: RUNE ALIGNMENT
Subtitle: Match the rings
```

## 12.5 Minigame 2 — Orb Guidance

### Visual Placement

Left side, partially over shallow water.

Create:

- 5 or 6 guidance rings
- One visible orb path
- Start pedestal
- End pedestal
- Short water channel
- Activity sign

Recommended ring sizes:

```text
Diameter: 7–10 studs
Spacing: 8–12 studs
```

The route should curve gently.

Do not create a long precision course.

### Orb

Use a small glowing orb:

```text
Diameter: 1.5–2.5 studs
```

Movement should be client-responsive but server-validated if rewards depend on completion.

### Sign

```text
Badge: 2
Title: ORB GUIDANCE
Subtitle: Guide the orb
```

## 12.6 Minigame 3 — Focus Sequence

### Visual Placement

Right-front side.

Create:

- One circular rune pad
- 8 outer symbols
- One center emblem
- 4 standing positions
- Activity sign

Recommended:

```text
Pad diameter: 36 studs
Rune count: 8
Rune tile size: 4–5 studs
```

Only the currently active rune should glow strongly.

Use:

- Blue for inactive outline
- Cyan-white for active
- Brief gold flash for correct input
- Red flash for mistake

Do not use many particles.

### Sign

```text
Badge: 3
Title: FOCUS SEQUENCE
Subtitle: Repeat the runes
```

## 12.7 Shrine Scholar Kiosk

Right-back side.

Purpose:

- Training information
- Daily tasks
- Control roleplay identity
- Visual balance

Recommended:

```text
Width: 26–30 studs
Depth: 16–20 studs
Height: 16–20 studs
```

Use:

- Blue roof
- Timber frame
- Open counter
- Books or scroll props
- One NPC or static mannequin
- One sign

Text:

```text
SHRINE SCHOLAR
Training and daily tasks
```

## 12.8 Crystals and Pillars

Use four major pillars around the central shrine.

Each pillar:

```text
Height: 16–20 studs
Base width: 4–5 studs
Top crystal: 3–5 studs
Banner: 3–4 studs wide
```

Use no more than six total large crystals in the zone.

## 12.9 Water and Garden Edges

Add:

- 2 shallow pools
- 1 short waterfall
- 5–8 pine trees
- 4 flower clusters
- 3 benches
- 6 lanterns
- 2 ruined stone wall groups

The central plaza should remain uncluttered.

## 12.10 Camera Target

```text
Camera position: 0, 92, 140
Camera target: 0, 10, -4
FieldOfView: 60–68
```

Ensure the central rings, left course, right sequence pad, and scholar kiosk all fit.

## 12.11 Arcane Shrine Acceptance Checklist

- Central orb and rings are readable from 150 studs.
- Ring motion is slow and calm.
- Rune Alignment is clearly central.
- Orb Guidance is clearly left.
- Focus Sequence is clearly right.
- Scholar kiosk does not compete with the shrine.
- No fast server-side animation loop.
- Neon usage is controlled.
- Effects remain visible on low graphics.
- Control stat logic and rewards remain unchanged.

---

# 13. Integration Into Ascension Grounds

The five zones should feel like districts of one safe town.

Recommended high-level arrangement around the central plaza:

```text
North-West: Strength Forge
West/South-West: Heroes' Track
North-East: Skyward Tower
East/South-East: Arcane Shrine
South or quieter garden edge: Guardian Grove
North/Far Route: Broken Gate
```

Exact placement must respect the existing game.

## Landmark Visibility

From the central crystal, the player should see:

- Orange furnace of Strength Forge
- Top ring of Skyward Tower
- Green life crystal of Guardian Grove
- Open banners and timer arch of Heroes’ Track
- Blue armillary rings of Arcane Shrine
- Dark route to Broken Gate

## Road Width

Use:

- Main radial roads: 20–24 studs
- Branch roads: 12–16 studs
- Zone entries: 16–20 studs

Do not hide zone entrances behind vegetation or props.

## Navigation

Every zone should have:

- One large zone sign
- One dominant accent color
- One visible landmark
- One clear entry route
- One unobstructed return path to the central plaza

---

# 14. Recommended Implementation Sequence

Codex should not attempt to build all detail in one large change.

## Pass 1 — Inspection

1. List Roblox Studio instances.
2. Set the correct active Studio.
3. Inspect `Workspace`, `ReplicatedStorage`, `StarterGui`, `ServerScriptService`, and relevant existing zone folders.
4. Identify gameplay-critical prompts and minigame anchors.
5. Record current transforms.
6. Inspect approved art-only assets.
7. Capture before screenshots.

## Pass 2 — Greybox

For all five zones:

- Create footprint floors
- Create main paths
- Create central landmark blockouts
- Create minigame pad blockouts
- Verify scale in Play mode
- Verify no prompt range issues
- Do not add detailed props yet

## Pass 3 — Landmark Build

Build only:

- Strength Forge façade
- Guardian life tree
- Skyward Tower
- Heroes’ Track oval
- Arcane armillary shrine

Verify all five are readable from the central hub.

## Pass 4 — Minigame Visual Areas

Build:

- Forge Strike
- Guardian Pulse
- Skyline Rush
- Pace Trial
- Rune Alignment

Then build secondary areas.

## Pass 5 — Signs and Color Identity

Add:

- Zone signs
- Activity signs
- Banners
- Local lights
- Minimal VFX

## Pass 6 — Props and Background

Add:

- Trees
- Ruins
- Crates
- Benches
- Fences
- Spectator props
- Kiosks

Stop adding detail when navigation becomes less clear.

## Pass 7 — Gameplay Verification

Test:

- Every prompt
- Every existing minigame
- Reward popup
- Stats updates
- Mobile HUD
- Enemy route
- Spawn points
- Character movement
- Fall recovery
- No blocked paths
- No unexpected collision
- No new console errors

## Pass 8 — Optimization

- Disable unnecessary collisions
- Disable unnecessary shadows
- Reduce particles
- Reduce lights
- Merge repeated static details only if safe
- Remove hidden parts
- Verify streaming behavior
- Test low graphics settings

## Pass 9 — Documentation

Update:

- Progression tracker
- Decision log
- Known issues
- Manual test checklist
- Asset approval records
- Moved gameplay-critical object list

---

# 15. Codex-Specific Execution Guidance

Codex should work in small, auditable steps.

## 15.1 Avoid One Giant Script

Do not generate one script that constructs the entire world at runtime.

Prefer:

- Studio-created static instances
- Small editor scripts used once, if supported
- Reusable helper modules for repeated construction
- Static anchored geometry saved in the place

Runtime generation should be used only if the project architecture already relies on it.

## 15.2 Do Not Guess Unknown Paths

Before editing:

- Inspect the current Studio tree.
- Find the exact script or model.
- Confirm names.
- Do not assume `Workspace.Map` exists.
- Do not create duplicate RemoteEvents.
- Do not create a second player data service.

## 15.3 Use Fallback Tiers

For every complex asset:

### Tier A

Use existing approved asset.

### Tier B

Use a small approved subset.

### Tier C

Build a primitive approximation.

### Tier D

Use a clean placeholder silhouette and document the gap.

Examples:

- Tree unavailable → primitive tree
- Torus unavailable → segmented ring
- Chain unavailable → repeated cylinders
- Anvil unavailable → WedgePart approximation
- Curved track unavailable → tangent segments
- Complex roof unavailable → simple wedge roof

## 15.4 Prefer Clear Shapes Over Visual Noise

When uncertain:

- Make the object larger.
- Use fewer parts.
- Use clearer color.
- Increase spacing.
- Preserve the road.
- Keep the landmark visible.

## 15.5 Record Important Decisions

Add a short implementation note for:

- Any moved prompt
- Any blocked asset
- Any replaced reference element
- Any performance-driven simplification
- Any missing texture
- Any use of placeholder geometry
- Any minigame visual that was deferred

---

# 16. Suggested Screenshot Validation Set

Capture these after implementation.

## Strength Forge

- Hub-distance view
- Entry view
- Forge Strike close view
- Titan Lift side view
- Boulder Break side view

## Guardian Grove

- Hub-distance tree view
- Entry view
- Guardian Pulse
- Healing Brew
- Resilience Trial
- Healer’s Shelter

## Skyward Tower

- Hub-distance tower view
- Ground entry
- Reaction Dash
- Courier Run
- Mid-route Skyline Rush
- Top finish ring

## Heroes’ Track

- Full elevated overview
- Pace Trial start
- Timer gate
- Hurdle lane
- Relay lane
- Spectator stand

## Arcane Shrine

- Hub-distance shrine view
- Entry view
- Rune Alignment
- Orb Guidance
- Focus Sequence
- Scholar kiosk

Use consistent screenshot settings:

```text
Resolution: 1920 × 1080 if available
FieldOfView: 60–70
Graphics quality: high for review
Also test low graphics separately
No debug UI
No Studio selection outlines
```

---

# 17. Final Cross-Zone Acceptance Criteria

The build is acceptable when:

- All five zones are immediately distinguishable.
- Each zone has one dominant landmark.
- Each zone has one central minigame and two secondary activity areas.
- Main paths are wide and unobstructed.
- The world feels larger without feeling empty.
- The images are used as visual guidance, not copied literally.
- The game remains recognizably Roblox.
- Mobile readability is preserved.
- No blocked Creator Store assets are used.
- No scripted or remote-containing imported asset is used.
- Existing progression and combat systems still work.
- New objects are grouped and named clearly.
- New geometry is anchored where appropriate.
- Decorative objects are replaceable.
- No material performance regression occurs.
- All unresolved differences from the references are documented.

---

# 18. Priority Summary

If time is limited, implement in this order:

1. Strength Forge landmark and Forge Strike pad
2. Guardian Grove tree and Guardian Pulse circle
3. Skyward Tower silhouette and one playable route
4. Heroes’ Track oval and Pace Trial
5. Arcane Shrine armillary and Rune Alignment
6. Secondary minigame areas
7. Signs
8. Local VFX
9. Props
10. Background decoration

The project should never delay a playable build because a decorative prop is missing.

The correct result is not a perfect render recreation.

The correct result is:

> Five large, readable, fantasy training districts that feel exciting from a Roblox player camera, clearly communicate their stat and minigames, support groups of players, preserve the existing gameplay loop, and remain practical for Codex to build and maintain.
