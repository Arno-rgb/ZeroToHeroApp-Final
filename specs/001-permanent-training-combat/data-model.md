# Data Model

## Database version

Increment Dexie from version 1 to version 2.

## TrainingEvent

```ts
type VerificationTier =
  | 'self_reported'
  | 'timer_supported'
  | 'sensor_supported'
  | 'camera_verified'
  | 'device_verified';

type TrainingSource =
  | 'manual'
  | 'guided_workout'
  | 'camera'
  | 'wearable'
  | 'migration';

interface TrainingEvent {
  id: string;
  userId: string;
  exerciseId: string;
  movementFamily:
    | 'upper_strength'
    | 'lower_strength'
    | 'core'
    | 'endurance'
    | 'mobility';
  metric: 'reps' | 'seconds' | 'metres';
  rawVolume: number;
  creditedVolume: number;
  performedAt: string;
  localDate: string;
  timezoneOffsetMinutes: number;
  source: TrainingSource;
  verificationTier: VerificationTier;
  formScore?: number;
  creditPolicyVersion: string;
  createdAt: string;
  supersedesEventId?: string;
  notes?: string;
}
```

Indexes:

```text
id,
userId,
exerciseId,
localDate,
performedAt,
[userId+localDate],
[userId+movementFamily]
```

## ProgressionRules

```ts
interface MilestonePoint {
  volume: number;
  score: number;
}

interface AttributeRule {
  attribute:
    | 'strength'
    | 'force'
    | 'endurance'
    | 'agility'
    | 'stability'
    | 'mobility';
  contributions: Array<{
    movementFamily: TrainingEvent['movementFamily'];
    multiplier: number;
  }>;
  milestones: MilestonePoint[];
}

interface ProgressionRules {
  version: string;
  attributes: AttributeRule[];
  unlocks: AbilityUnlockRule[];
}
```

Rules are code/config assets, not user-modifiable database data in V1.

## StatSnapshot

```ts
interface StatSnapshot {
  id: string; // userId
  userId: string;
  rulesVersion: string;
  ledgerRevision: number;
  generatedAt: string;
  attributes: {
    strength: number;
    force: number;
    endurance: number;
    agility: number;
    stability: number;
    mobility: number;
  };
  lifetimeCredited: Record<TrainingEvent['movementFamily'], number>;
  unlockedAbilityIds: string[];
}
```

A snapshot is disposable. It MUST be rebuildable from `TrainingEvent[]`.

## CombatBuildSnapshot

```ts
interface CombatBuildSnapshot {
  userId: string;
  statRulesVersion: string;
  generatedAt: string;
  attributes: StatSnapshot['attributes'];
  abilities: string[];
  derived: {
    maxHealth: number;
    maxStamina: number;
    staminaRegenPerSecond: number;
    moveSpeed: number;
    evadeWindowMs: number;
    lightDamage: number;
    heavyDamage: number;
    armourBreak: number;
    poise: number;
    knockback: number;
  };
}
```

This object is frozen at battle start so a training record added in another tab cannot alter an active battle.

## BattleRecord

```ts
interface BattleRecord {
  id: string;
  userId: string;
  bossId: string;
  startedAt: string;
  endedAt: string;
  result: 'victory' | 'defeat' | 'abandoned';
  durationMs: number;
  damageDealt: number;
  damageTaken: number;
  attacksUsed: Record<string, number>;
  evadesAttempted: number;
  evadesSucceeded: number;
  buildSnapshot: CombatBuildSnapshot;
  combatRulesVersion: string;
  seed: string;
}
```

## UserProfile additions

```ts
interface UserDataV2 {
  id: string;
  name: string;
  level: number;
  tier: number;
  experience: number;
  heroTitle: string;
  energy: number;
  maxEnergy: number;
  ledgerRevision: number;
  avatarCustomization: {
    costume: string;
    color: string;
  };
  createdAt: string;
  lastLogin: string;
}
```

## Dexie v2 stores

```ts
this.version(2).stores({
  users: 'id, name, level, tier, lastLogin',
  exercises: null,
  trainingEvents:
    'id, userId, exerciseId, localDate, performedAt, [userId+localDate], [userId+movementFamily]',
  statSnapshots: 'id, userId, rulesVersion, generatedAt',
  battles: 'id, userId, bossId, endedAt, result'
}).upgrade(async tx => {
  // Convert v1 exercises to TrainingEvent records.
  // Preserve v1 tables until conversion validation completes.
});
```

Do not delete the old exercise table in the same migration that first converts it. Mark it deprecated and remove it only in a later tested schema version.
