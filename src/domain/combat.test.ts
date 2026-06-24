import { describe, expect, it } from 'vitest';
import {
  calculateAttackDamage,
  createCombatBuildSnapshot,
} from './combat';
import { deriveStatSnapshot } from './progression';
import { TrainingEvent, createTrainingEvent } from './training';

function makeEvents(
  exerciseId: 'pushup' | 'run',
  entries: number,
  count: number
): TrainingEvent[] {
  return Array.from({ length: entries }, (_, index) =>
    createTrainingEvent({
      id: `${exerciseId}-${index}`,
      userId: 'user-1',
      exerciseId,
      count,
      performedAt: `2026-05-${String((index % 28) + 1).padStart(2, '0')}T08:00:00.000Z`,
      source: 'manual',
      verificationTier: 'self_reported',
    })
  );
}

describe('combat build snapshots', () => {
  it('makes push-up specialists hit harder than running specialists', () => {
    const pushupSnapshot = deriveStatSnapshot({
      userId: 'user-1',
      events: makeEvents('pushup', 20, 250),
      ledgerRevision: 20,
    });
    const runningSnapshot = deriveStatSnapshot({
      userId: 'user-2',
      events: makeEvents('run', 20, 10),
      ledgerRevision: 20,
    });

    const pushupBuild = createCombatBuildSnapshot(pushupSnapshot);
    const runningBuild = createCombatBuildSnapshot(runningSnapshot);

    expect(pushupBuild.derived.heavyDamage).toBeGreaterThan(
      runningBuild.derived.heavyDamage
    );
    expect(runningBuild.derived.maxStamina).toBeGreaterThan(
      pushupBuild.derived.maxStamina
    );
    expect(runningBuild.derived.evadeWindowMs).toBeGreaterThan(
      pushupBuild.derived.evadeWindowMs
    );
  });

  it('lets Titan Impact defeat the first boss in one hit at the milestone', () => {
    const snapshot = deriveStatSnapshot({
      userId: 'user-1',
      events: makeEvents('pushup', 40, 250),
      ledgerRevision: 40,
    });
    const build = createCombatBuildSnapshot(snapshot);
    const damage = calculateAttackDamage(
      build,
      {
        id: 'boss1',
        name: 'Training Dummy',
        maxHealth: 100,
        weakness: 'strike',
      },
      'titan-impact'
    );

    expect(build.abilities).toContain('titan-impact');
    expect(damage).toBeGreaterThanOrEqual(100);
  });
});

