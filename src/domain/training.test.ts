import { describe, expect, it } from 'vitest';
import {
  calculateCreditedVolume,
  createTrainingEvent,
  displayVolume,
} from './training';

describe('training credit policy', () => {
  it('keeps raw volume but caps extreme single-entry credit', () => {
    const credit = calculateCreditedVolume('pushup', 300);

    expect(credit.creditedVolume).toBe(250);
    expect(credit.capped).toBe(true);
    expect(credit.explanation).toContain('Credited 250 reps of 300 reps');
  });

  it('normalises running to metres for the immutable ledger', () => {
    const event = createTrainingEvent({
      id: 'event-run',
      userId: 'user-1',
      exerciseId: 'run',
      count: 2.5,
      performedAt: '2026-06-24T08:30:00.000Z',
      source: 'manual',
      verificationTier: 'self_reported',
      formScore: 0.8,
    });

    expect(event.metric).toBe('metres');
    expect(event.rawVolume).toBe(2500);
    expect(event.creditedVolume).toBe(2500);
    expect(event.localDate).toMatch(/^\d{4}-\d{2}-\d{2}$/);
    expect(displayVolume('run', event.creditedVolume)).toBe('2.5 km');
  });
});

