import { describe, expect, it } from 'vitest';
import { deriveStatSnapshot } from './progression';
import { TrainingEvent, createTrainingEvent } from './training';

function makeEvents(
  exerciseId: 'pushup' | 'run' | 'situp' | 'squat',
  entries: number,
  count: number
): TrainingEvent[] {
  return Array.from({ length: entries }, (_, index) =>
    createTrainingEvent({
      id: `${exerciseId}-${index}`,
      userId: 'user-1',
      exerciseId,
      count,
      performedAt: `2026-06-${String((index % 28) + 1).padStart(2, '0')}T08:00:00.000Z`,
      source: 'manual',
      verificationTier: 'self_reported',
    })
  );
}

describe('permanent progression', () => {
  it('derives deterministic stats from the ledger', () => {
    const events = [
      ...makeEvents('pushup', 4, 100),
      ...makeEvents('situp', 2, 100),
    ];

    const first = deriveStatSnapshot({
      userId: 'user-1',
      events,
      ledgerRevision: 6,
    });
    const second = deriveStatSnapshot({
      userId: 'user-1',
      events,
      ledgerRevision: 6,
    });

    expect(first.attributes).toEqual(second.attributes);
    expect(first.lifetimeCredited.upper_strength).toBe(400);
    expect(first.attributes.strength).toBeGreaterThan(first.attributes.endurance);
  });

  it('unlocks Titan Impact at 10,000 credited lifetime push-ups', () => {
    const events = makeEvents('pushup', 40, 250);
    const snapshot = deriveStatSnapshot({
      userId: 'user-1',
      events,
      ledgerRevision: events.length,
    });

    expect(snapshot.lifetimeCredited.upper_strength).toBe(10000);
    expect(snapshot.attributes.strength).toBe(100);
    expect(snapshot.unlockedAbilityIds).toContain('titan-impact');
  });
});

