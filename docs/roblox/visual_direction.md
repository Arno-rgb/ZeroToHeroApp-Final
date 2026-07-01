# Roblox Visual Direction

These images are reference direction for the Roblox version of Zero to Hero. Use them to guide mood, hierarchy, spacing, color, and player feedback. Do not copy exact layouts, icons, text, logos, character designs, enemy designs, architecture, or brand elements.

The source collage is stored at:

- [zero_to_hero_visual_reference_collage.png](../../roblox/assets/reference/roblox/zero_to_hero_visual_reference_collage.png)

Individual reference panels are stored in:

- [roblox/assets/reference/roblox](../../roblox/assets/reference/roblox)

## Visual Rules

- Treat the written game spec as the source of truth for mechanics.
- Treat these images as art direction, not implementation requirements.
- Build simple Roblox blockouts first with Parts, Materials, Lighting, SurfaceGuis, BillboardGuis, ScreenGuis, and ProximityPrompts.
- Keep the first playable loop readable on mobile before adding decorative detail.
- Use distinct colors for the five training stats: Power, Vitality, Agility, Endurance, and Control.
- Avoid spending time on exact models, custom meshes, complex VFX, or final UI polish until the training-to-combat loop works.

## 01 Ascension Grounds Reference

Image:

- [01_ascension_grounds_reference.png](../../roblox/assets/reference/roblox/01_ascension_grounds_reference.png)

Use for:

- Overall hub layout
- District placement
- Stone, blue, and gold palette
- Scale and atmosphere
- Landmarks and navigation

Do not copy:

- Exact building designs
- Exact layout measurements
- Existing logos or banners
- UI text or brand elements
- Character designs

Roblox MVP translation:

- Create a central plaza with a visible crystal or marker.
- Put training stations around the hub as readable landmarks.
- Keep the first route simple: spawn, Strength Forge, enemy area.

## 02 Strength Forge Reference

Image:

- [02_strength_forge_reference.png](../../roblox/assets/reference/roblox/02_strength_forge_reference.png)

Use for:

- Glowing forge core
- Stone and metal training station
- Warm orange lighting
- Training equipment style
- Power and strength theme

Do not copy:

- Exact logo
- Exact props or models
- Exact architecture
- Exact layout
- Character designs

Roblox MVP translation:

- Strength Forge should feel clearly interactive from spawn.
- Use orange emissive materials, warm lights, an anvil or weight prop, and a ProximityPrompt.
- The first feedback should be immediate: `Power +1` or similar.

## 03 Stats UI Reference

Image:

- [03_stats_ui_reference.png](../../roblox/assets/reference/roblox/03_stats_ui_reference.png)

Use for:

- Five Training Stats
- Levels and XP bars
- Clean, mobile-readable layout
- Icon style and colors
- Hierarchy and grouping

Do not copy:

- Exact icons
- Exact UI layout
- Exact text
- Exact numbers
- Brand elements

Roblox MVP translation:

- Keep the first UI small and readable.
- Show current values for Power, Vitality, Agility, Endurance, and Control.
- Start all player training stats at `0`.
- Do not overload the first HUD with inventory, quests, materials, or shop systems.

## 04 Reward Popup Reference

Image:

- [04_reward_popup_reference.png](../../roblox/assets/reference/roblox/04_reward_popup_reference.png)

Use for:

- Immediate reward feedback
- Stat-specific colors
- Clear XP and reward values
- Short animation feel
- Mobile readable reward sequence

Do not copy:

- Exact layout
- Exact icons
- Exact text
- Exact colors
- Brand elements

Roblox MVP translation:

- After training, show a short reward popup near the center or lower center of the screen.
- The popup should say what happened in plain language: `Training complete`, `Power +1`.
- Keep the animation brief so the player can continue quickly.

## 05 Enemy Area Reference

Image:

- [05_enemy_area_reference.png](../../roblox/assets/reference/roblox/05_enemy_area_reference.png)

Use for:

- Transition from safe hub to danger
- Dark tones and red lighting
- Ruined structures and banners
- Enemy silhouettes and mood
- Path toward a boss area

Do not copy:

- Exact gate design
- Exact banners
- Exact enemy designs
- Brand elements
- Exact layout

Roblox MVP translation:

- Make the enemy area visually distinct from the safe hub.
- Use a simple path from Strength Forge to a training dummy or starter enemy.
- Show that combat is the result of training, not a separate unrelated activity.

## 06 Mobile HUD Reference

Image:

- [06_mobile_hud_reference.png](../../roblox/assets/reference/roblox/06_mobile_hud_reference.png)

Use for:

- Mobile control placement
- Button sizes and spacing
- Essential actions visible
- Health and level display style
- Minimal and clean HUD

Do not copy:

- Exact icons
- Exact layout
- Exact colors
- Exact text
- Brand elements

Roblox MVP translation:

- Keep buttons large enough for touch.
- Show only essential actions at first: attack, guard or dodge, interact, and reward feedback.
- Avoid full RPG UI complexity until combat improvement from training is clear.

## Current Visual Priority

For the first Roblox MVP, prioritize:

1. Strength Forge readability.
2. Immediate reward popup.
3. Five-stat UI.
4. Clear path from safe hub to enemy area.
5. Mobile-friendly button scale.

Do not build a large finished world yet. The first visual goal is to make the core loop understandable: train, gain a stat, fight better.
