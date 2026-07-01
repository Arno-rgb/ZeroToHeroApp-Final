# Zero to Hero Coach Demo - Project Summary

## Overview

Zero to Hero is currently positioned as a mobile-first coach demo for selling a simple trainer-branded fitness app. The current public demo focuses on a client opening the app, choosing a programme, seeing today's workout, following exercise guidance, using a rest timer, completing sets, and contacting the trainer through WhatsApp.

The project still contains older game/RPG code from the original Zero to Hero Fitness Game concept, but the active app entry point now loads the polished coach demo rather than the full Three.js or RPG experience.

## Current Public Demo

- Public URL: `https://zero-to-hero-coach-demo.vercel.app`
- Deployment target: Vercel production
- Demo recording: `demo/coach-demo-phone-demo.webm`
- Active entry screen: `src/components/CoachDemoApp.tsx`
- Active programme configuration: `src/coachConfig.ts`

## Current Product Direction

The project now has two connected layers:

- The trainer-ready workout companion demo.
- The first local prototype of the exercise-powered RPG promise: train in real life, become powerful in the game.

The immediate product goal is still not a full MMO, Roblox world, guild system, or raid platform. The current goal is a smallest playable slice that proves whether completing a workout and immediately becoming stronger in battle feels rewarding.

The Roblox direction is now documented canonically under `docs/roblox/`, with `docs/roblox/master_game_spec.md` as the main game spec and `docs/roblox/progression_tracker.md` as the current milestone tracker. The older `docs/roblox_master_game_blueprint.md` remains for context. VS Code to Roblox Studio MCP setup is documented in `docs/roblox_studio_mcp_vscode_setup.md`.

The coach-demo layer provides:

- Mobile-first layout that looks like a real client app.
- Easy trainer branding through a single configuration file.
- Complete training programmes with exercise targets.
- Exercise instructions, easier options, form standards, and rest timers.
- Install prompt or clear home-screen installation instructions.
- WhatsApp contact button for the trainer.
- Public demo URL that can be shown to trainers.
- 30-second phone-style demo recording.

Dexie, ledgers, combat snapshots, Three.js, raids, guilds, accounts, and multiplayer remain behind the scenes or out of scope for this slice.

The new local RPG layer provides:

- Five hero attributes that start at 0 and grow only from completed exercise types: Power, Vitality, Agility, Endurance, and Control.
- Immediate training reward overlays after exercise completion and full workout completion.
- Hero level and XP progression.
- Gold and material rewards.
- One saved battle attempt earned from full workout completion.
- Phase 1 game economy: Gold, Essence, earned chest fragments, earned chests, item binding, dismantling, and basic item upgrades.
- A Quest Map screen for the first campaign path.
- A one-hero turn-based Battle screen.
- A Hero screen with level, XP, attributes, class path, equipment, inventory, ability unlocks, materials, gold, and reward history.
- A small Chapter 1 enemy ladder ending with Gatekeeper Brakk.
- Weapon, armour, and charm equipment slots.
- Enemy loot drops that can be equipped.
- Account-bound starter gear and bind-on-equip gameplay loot.
- Ability Focus costs, cooldowns, momentum, break, bleed, exhaust, guard, and focus mechanics.
- Behaviour-driven class unlock paths: Adventurer, Vanguard, Berserker, Ranger, Monk, and Juggernaut.

This is intentionally a small prototype, not the final game economy.

## Active User Story

The main coach demo story is:

1. A client opens the trainer's app on a phone.
2. The client sees today's programme and workout list.
3. The client starts the workout.
4. The active exercise screen shows the exercise name, target, visual guide, method, easier option, form standard, rest timer, and action buttons.
5. The client completes sets and watches progress improve.
6. The client can install the app or message the trainer on WhatsApp.

The new game-loop story is:

1. A player completes a real workout.
2. Exercises increase relevant hero attributes through weighted reward bundles without changing the exercise or programme list.
3. Each exercise completion shows the exact stat reward immediately.
4. Full workout completion shows the training summary and grants one battle attempt.
5. The player opens the Quest Map.
6. The player spends one saved battle attempt to fight the next enemy.
7. Victory grants XP, gold, materials, loot drops, reward log entries, campaign progress, and later ability unlocks.
8. The player can equip loot and switch unlocked class paths.
9. The player returns to training to become stronger for the next fight.

## Roblox Direction

The Roblox game should not be built inside this React app. It is a separate future product path with its own server-authoritative data, Roblox combat, avatar training, loot, parties, guilds and expansions.

The repo now includes `.vscode/mcp.json` and `tools/roblox-studio-mcp.ps1` for connecting VS Code to Roblox Studio's built-in MCP server. This is for Studio-side design and prototyping only; it does not deploy or package the React app for Roblox.

The first Roblox proof should be narrow:

1. Persistent five-stat profile.
2. Strength Forge training minigame.
3. Immediate reward feedback.
4. Sword combat.
5. One enemy.
6. One equipment drop.
7. Visible combat improvement from earned stats.
8. Simulated mobile reward claim.
9. Gatekeeper Brakk prototype.

Non-negotiable rule: training creates base power, gameplay creates gear and mastery, and money buys identity, content and convenience, not victory.

## Programme Content Source

The active app content now uses the independent legal-compliant bodyweight training system supplied in the markdown review file, not the scanned book/PDF exercise catalogue.

The app intentionally does not crop or reuse source book photographs, diagrams, captions, page layouts, or distinctive visuals. Instead, the app uses original in-app SVG movement guides and rewritten exercise instructions from the independent system.

## Active Programmes

The active programme catalogue is defined in `src/coachConfig.ts`.

### Stage 0 - Seven-Day On-Ramp

Purpose: movement practice for a new or returning trainee.

Includes:

- Day 1 - Squat, Push, and Trunk
- Day 2 - Easy Movement
- Day 3 - Pulling Introduction
- Day 4 - Rest or Gentle Walking
- Day 5 - Full-Body Practice
- Day 6 - Low-Intensity Conditioning
- Day 7 - Readiness Review

### Stage 1 - Foundation Program

Purpose: basic strength, joint control, and work capacity.

Includes:

- Session A - Foundation Strength
- Session B - Foundation Control
- Session C - Controlled Circuit

### Stage 2 - Development Program

Purpose: unilateral strength, stronger pulling and pushing, controlled power, and conditioning.

Includes:

- Day 1 - Lower-Body Strength
- Day 2 - Upper-Body Strength
- Day 4 - Power and Movement
- Day 5 - Conditioning

### Stage 3 - Performance Program

Purpose: advanced relative strength, calisthenics skill, trunk control, and mixed conditioning.

Includes:

- Day 1 - Handstand and Push
- Day 2 - Pulling Strength
- Day 4 - Legs and Power
- Day 5 - Trunk and Mixed Conditioning

### Hybrid Race Prep

Purpose: generic hybrid fitness race preparation without using event-brand affiliation.

Includes:

- Day 1 - Easy Run Plus Strength
- Day 2 - Running Intervals
- Day 4 - Hybrid Station Circuit
- Day 6 - Long Easy Run

## Exercise Guidance

Each active exercise is expanded into client-facing guidance in `src/coachConfig.ts`.

Each exercise can include:

- Exercise name
- Target, such as reps, sets, time, rounds, metres, or minutes
- Short description
- Original visual category
- Rest timer duration
- Method cue
- Easier option
- Key standard
- Coach note or safety caution

Example guidance pattern:

```text
Method: Stand in front of a chair, reach the hips back, touch the chair lightly, and stand by pressing through the whole foot.
Easier: Use a higher seat and push lightly from the thighs.
Key standard: Knees track in the same direction as the toes.
```

## Exercise Visuals

The workout tab displays original SVG movement visuals generated in the React component. These are not cropped from any PDF or book.

Visual categories include:

- Squat
- Lunge
- Push
- Pull
- Row
- Hinge
- Core
- Jump
- Burpee
- Hang
- Handstand
- Crawl
- Run
- Default movement

The visual panel is rendered by:

- `ExerciseVisual`
- `renderExerciseVisual`

Both are in `src/components/CoachDemoApp.tsx`.

Visual styling is defined in `src/index.css`.

## Main App Screens

### Today

The Today screen shows:

- Trainer brand header
- Programme selector
- Current workout card
- Exercise list
- Workout progress ring
- Start Workout button
- Day selector
- Daily tip

### Quest Map

The Quest Map screen shows:

- Current chapter
- Next enemy
- Battle energy
- Training energy
- Enemy ladder for The Broken Gate
- Daily quest call to action
- Train or Enter Battle button

### Workout

The Workout screen shows:

- Active exercise name and target
- Original movement visual
- Set and target panel
- Rest timer ring
- How to perform instructions
- Coach note
- Complete Set button
- Next Exercise or Finish Workout button

### Battle

The Battle screen shows:

- Hero and enemy HP
- Pixel-style hero and enemy markers
- Ultimate charge meter
- Action Focus
- Momentum count
- Break, bleed, and status display
- Basic Strike
- Equipped abilities
- Ability Focus costs and cooldown states
- Guard
- Tonic
- Ultimate
- Combat log

### Progress

The Progress screen shows programme completion and training metrics without competing with RPG management.

### Hero

The Hero screen shows:

- Hero identity and saved battle attempts
- Hero level and XP progress
- Five training-driven attributes: Power, Vitality, Agility, Endurance, and Control
- Class path and active class
- Weapon, armour, and charm slots
- Inventory and equippable loot
- Gold
- Materials
- Ability unlock list
- Reward chest history

The Progress screen shows:

- Programme completion percentage
- Streak-style metrics
- Completed workout count
- Points-style progress
- Stat bars
- Weekly progress visualization
- Reset demo progress action

### Profile

The Profile screen shows:

- Trainer identity
- WhatsApp contact button
- Install instructions or install button

## Branding Configuration

Coach branding is centralized in `src/coachConfig.ts`.

Current configurable values include:

- `brandName`
- `trainerName`
- `headline`
- `subheadline`
- `whatsappNumber`
- `whatsappMessage`
- `logoPath`
- Brand colors
- Programme catalogue

This is the intended place to change the app for a specific trainer demo.

## Progress Storage

The coach demo stores lightweight demo progress in browser `localStorage`.

Storage key:

```text
coach-demo-progress-v1
```

Stored progress includes:

- Completed exercise IDs
- Completed day IDs
- Programme start timestamp

This is suitable for a local demo. It is not yet account-based, synced, or trainer-managed.

## PWA and Install Support

The app includes PWA support:

- `index.html` links to `manifest.webmanifest`
- `src/pwa.ts` registers the service worker
- `public/sw.js` handles service worker caching
- The coach screen displays install instructions when the browser install prompt is unavailable

The service worker was updated to avoid stale blank-page caching:

- Current cache name: `coach-demo-v4`
- Navigation uses a network-first strategy
- Old `coach-demo-*` caches are deleted
- The PWA registration no longer forces a reload loop on controller changes

## Deployment

The project is linked to the Vercel project:

```text
zero-to-hero-coach-demo
```

Stable production URL:

```text
https://zero-to-hero-coach-demo.vercel.app
```

Deploy command:

```bash
npx vercel deploy --prod --yes
```

## Technical Stack

Core stack:

- React 18
- TypeScript
- Vite
- React Icons
- Plain CSS in `src/index.css`
- Browser localStorage for coach demo progress
- PWA manifest and service worker
- Vercel deployment

The repository also contains older or future-facing dependencies and modules for:

- Chakra UI
- Redux Toolkit
- Dexie
- MediaPipe
- TensorFlow pose detection
- Three.js
- Framer Motion
- Playwright
- Vitest

These are not all central to the current coach demo experience.

## Important Files

- `src/App.tsx` - active app entry point, currently renders `CoachDemoApp`
- `src/components/CoachDemoApp.tsx` - main mobile coach demo UI
- `src/coachConfig.ts` - branding, programme data, exercise guidance, visual categories
- `src/index.css` - mobile layout, cards, nav, workout visuals, timer styles
- `src/pwa.ts` - service worker registration
- `public/sw.js` - service worker cache logic
- `public/manifest.webmanifest` - PWA metadata
- `index.html` - root HTML document and manifest link
- `demo/coach-demo-phone-demo.webm` - 30-second demo recording
- `docs/project_summary.md` - this summary
- `AGENTS.md` - Codex project instructions, including Roblox spec-first MCP workflow
- `docs/roblox_build_from_spec_prompt.md` - reusable prompt for building Roblox Studio features from the spec
- `docs/roblox/codex_progression_prompt_system.md` - milestone-based Codex task system for Roblox
- `docs/roblox/master_game_spec.md` - canonical Roblox game spec
- `docs/roblox/architecture.md` - Roblox source layout and server/client authority boundaries
- `docs/roblox/progression_tracker.md` - current Roblox phase, milestone, acceptance criteria, and next task
- `docs/roblox/decision_log.md` - lasting Roblox product and architecture decisions
- `docs/roblox/manual_test_checklist.md` - manual Studio test checklist
- `docs/roblox/known_issues.md` - unresolved Roblox issues
- `docs/roblox/visual_direction.md` - canonical Roblox visual direction and usage rules for reference images
- `roblox/default.project.json` - Rojo-compatible Roblox project map
- `roblox/assets/reference/roblox/` - canonical Roblox visual reference images

## Verification Performed

The current deployed version has been checked with:

```bash
npm test
npm run build
```

Browser verification covered:

- Local mobile Chrome rendering
- Public Vercel mobile Chrome rendering
- Programme selector visibility
- Stage 0, Stage 1, Stage 3, and Race Prep content visibility
- Workout tab instructions
- Original exercise visual rendering
- No blank page
- No horizontal overflow
- No console errors
- No failed network requests
- Service worker version check for `coach-demo-v4`
- Vercel error log check

## Current Known Limitations

- The WhatsApp number is still a demo placeholder and should be replaced for each trainer.
- Progress is local to the browser and not synced across devices.
- There is no trainer dashboard yet.
- There is no account system or client management.
- There is no analytics or lead tracking.
- The exercise visuals are simple original SVG guides, not professional commissioned exercise media.
- The legal-compliant markdown review reduces risk but is not a legal opinion.
- Medical, safety, and market-specific compliance language should be reviewed before commercial release.
- The older game/RPG systems still exist in the repository but are not the current sales demo focus.

## Recommended Next Steps

1. Replace demo trainer details with the first real trainer brand.
2. Replace the WhatsApp placeholder number.
3. Add a short safety disclaimer in the app or onboarding screen.
4. Add a trainer-facing one-page sales deck or landing page only if needed for outreach.
5. Test the public URL on a real iPhone and Android phone.
6. Record a human walkthrough video using the public demo.
7. Commission original exercise photos or short videos if a trainer needs higher-trust visuals.
8. Add basic analytics for trainer demo views and WhatsApp clicks.
9. Add a simple client invite flow after the first trainer sale.
10. Keep the RPG/game layer hidden until the coach product is already earning.

## Sales Positioning

Do not sell this as a complex game system yet. Sell the clear client outcome:

```text
Your client opens your branded app, sees today's programme, follows the exercise guidance, completes the workout, and watches their progress improve.
```

Avoid mentioning implementation details such as Dexie, ledgers, combat snapshots, Vitest, service workers, or Three.js during trainer sales conversations unless the trainer specifically asks technical questions.
