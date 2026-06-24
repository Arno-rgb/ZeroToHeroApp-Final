# Fitness RPG Constitution

## 1. Real training is the source of character power

Character attributes MUST be derived from recorded real-world training events. Combat, purchases, equipment and administrative actions MUST NOT directly increase permanent body-derived attributes.

## 2. Permanent progress is never spent

Lifetime training progress is immutable and non-consumable. Combat may consume temporary resources such as stamina, focus, rage or ability cooldowns, but MUST NOT subtract push-up history, lifetime training units or derived permanent attributes.

## 3. The ledger is the source of truth

Every accepted training activity MUST be stored as an append-only event. Permanent attributes MUST be reproducible from the event ledger plus a versioned ruleset. Cached snapshots are allowed only as rebuildable performance optimizations.

## 4. Builds must feel materially different

Different physical activities MUST create different combat identities:

- Upper-body strength: high single-hit damage, knockback and armour break
- Running/endurance: speed, stamina, recovery and dodge capability
- Lower-body strength: force, poise, launch resistance and movement burst
- Core/stability: defence, control, stagger resistance and recovery
- Mobility: dodge range, animation recovery and status resistance

One build MUST NOT simply be a numerically inferior version of another.

## 5. Power must be visible and tactile

Meaningful stat milestones MUST alter more than text values. They SHOULD change animation, hit stop, camera shake, particles, sound, knockback, damage presentation or enemy reactions. Early bosses MAY become trivial after substantial real training.

## 6. Reward consistency, not dangerous spikes

The system MUST record all user-entered activity but MAY cap the amount credited toward game progression per day. Credit rules MUST be transparent, versioned and designed to reward long-term consistency. The game MUST NOT pressure users to perform extreme repetition in one session.

## 7. Verification is explicit

Each training event MUST declare a verification tier:

- `self_reported`
- `timer_supported`
- `sensor_supported`
- `camera_verified`
- `device_verified`

Single-player progression MAY use self-reported activity. Competitive systems MUST NOT treat all tiers as equivalent.

## 8. Offline-first core

The complete single-player training and battle loop MUST function without an account or active internet connection after initial installation. Local persistence MUST be resilient to refreshes and application updates.

## 9. One source of truth per domain

Training state, derived stats and battle results MUST each have a clear authoritative model. The application MUST NOT maintain unrelated duplicate battle state in Redux, a popup window and IndexedDB.

## 10. Deterministic and testable rules

Stat derivation, credit limits, damage, milestone unlocks and reward calculations MUST be pure functions with automated tests. Random battle behaviour MUST accept a seed or injectable random source in tests.

## 11. Brownfield safety

Existing exercise and battle records MUST be preserved through versioned database migrations. A migration MUST be reversible in development and validated against a copied database before release.

## 12. Original commercial identity

Public names, characters, art, stories, attacks and marketing MUST use original intellectual property. Inspiration may guide mechanics, but the shipped product MUST NOT depend on another franchise's names, costumes or branding.

## Governance

Any implementation that conflicts with these principles requires an explicit written exception in the feature plan. Scope additions such as accounts, PvP, guilds, raids or a marketplace require a separate specification and may not be smuggled into the core vertical slice.
