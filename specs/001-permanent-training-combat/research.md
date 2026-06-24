# Research and Technical Decisions

## Decision 1: Keep the current web stack

Use React, TypeScript, Vite, Redux Toolkit, Chakra UI, Framer Motion and Dexie.

Reason:

- The prototype already uses them.
- The fitness shell is more valuable than a rewrite.
- The core feature can remain free to host and offline-first.

## Decision 2: Keep Three.js for the first vertical slice

The existing standalone battle proves attack, telegraph and evade mechanics. Refactor it into typed modules rather than replacing the engine during this feature.

Conditions:

- Move game code out of `public/battle-game-3d.html`.
- Bundle Three.js through npm instead of CDN import maps.
- Host the canvas inside the application.
- Use one shared result contract.
- Do not pass trusted stats through URL parameters.
- Reassess the engine before creating multiple worlds.

Reason:

Changing game engines before proving the core reward loop would discard working mechanics and expand scope. If the first polished battle cannot meet feel or performance requirements, run a separate Phaser or engine spike before content production.

## Decision 3: Append-only training ledger

Permanent stats are derived from training events rather than manually incremented counters.

Reason:

- Stats can be rebuilt after balance changes.
- Migrations are safer.
- Cheating/anomaly rules can be applied consistently.
- Future cloud sync becomes possible.
- Combat cannot accidentally spend physical history.

## Decision 4: Separate raw, credited and verified volume

Each event stores:

- `rawVolume`: what the user reports or sensor records
- `creditedVolume`: what progression rules accept
- `verificationTier`: confidence source

Reason:

The user should retain a complete training history while the game prevents unsafe one-day farming and future competitive abuse.

## Decision 5: Diminishing-return milestone curve

Use configurable milestone interpolation rather than one stat point per repetition.

Initial upper-body milestone table:

| Credited lifetime push-ups | Strength |
|---:|---:|
| 0 | 0 |
| 100 | 8 |
| 500 | 18 |
| 1,000 | 28 |
| 2,500 | 42 |
| 5,000 | 58 |
| 10,000 | 75 |
| 25,000 | 90 |
| 50,000 | 100 |

Interpolate linearly between milestones. Values above the maximum progress very slowly through prestige levels and do not create unlimited combat damage.

Reason:

- Early progress feels frequent.
- Long-term achievements remain meaningful.
- Extreme repetition does not scale damage without limit.
- Designers can understand and tune the system without changing code.

## Decision 6: Milestone abilities create the dramatic power fantasy

Base stats improve continuously. Large visual and mechanical jumps come from traits.

Initial Strength traits:

| Requirement | Unlock |
|---:|---|
| 100 credited push-ups | Heavy Strike |
| 1,000 | Shockwave |
| 5,000 | Armour Break |
| 10,000 | Titan Impact |
| 25,000 | Colossus Trait |
| 50,000 | Mythic Strength I |

`Titan Impact` is deliberately tuned to one-shot the first boss under default rules.

Reason:

A safe diminishing-return curve and an extreme power fantasy can coexist when milestones unlock authored abilities rather than allowing raw linear damage growth.

## Decision 7: Different activities change action economy

Initial mapping:

- Push-ups/dips/pull-ups → Strength
- Squats/lunges/step-ups → Force
- Running/walking/cycling → Endurance and Agility
- Planks/sit-ups/core work → Stability
- Mobility sessions → Mobility

Derived combat effects:

- Strength: heavy damage, knockback, armour break
- Force: poise, launch resistance, dash impact
- Endurance: maximum stamina and regeneration
- Agility: attack recovery, movement speed and evade window
- Stability: maximum health, guard and stagger resistance
- Mobility: dodge distance and status recovery

Reason:

A runner may require many hits against an armoured early boss, but can attack more often and avoid attacks. A strength specialist can one-shot the same boss but may have worse mobility and recovery.

## Decision 8: Credit caps are progression controls, not exercise prescriptions

MVP default:

- Record all positive activity.
- Credit at most the greater of:
  - the configured beginner daily cap, or
  - 125% of the player's trailing 28-day daily average plus a small buffer.
- Apply caps per movement family.
- Display uncapped history separately from credited progress.
- Do not apply competitive rankings in V1.

Exact caps remain content configuration and require review before launch.

## Decision 9: Automated tests replace the browser “test page”

Use:

- Vitest for domain and store tests
- React Testing Library for integration components
- Playwright for the primary offline and battle-result flow

Keep `/test` only as an optional diagnostics interface.

## Decision 10: Original identity before public release

Rename franchise-derived terms and replace placeholder assets before marketing. The mechanic can remain, but the commercial product needs original names, characters, attacks and visual identity.
