export type ExerciseType = 'pushup' | 'situp' | 'squat' | 'run';

export type MovementFamily =
  | 'upper_strength'
  | 'lower_strength'
  | 'core'
  | 'endurance'
  | 'mobility';

export type TrainingMetric = 'reps' | 'seconds' | 'metres';

export type VerificationTier =
  | 'self_reported'
  | 'timer_supported'
  | 'sensor_supported'
  | 'camera_verified'
  | 'device_verified';

export type TrainingSource =
  | 'manual'
  | 'guided_workout'
  | 'camera'
  | 'wearable'
  | 'migration';

export interface TrainingEvent {
  id: string;
  userId: string;
  exerciseId: ExerciseType;
  movementFamily: MovementFamily;
  metric: TrainingMetric;
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

export const CREDIT_POLICY_VERSION = 'credit-v1';

export const movementFamilies: MovementFamily[] = [
  'upper_strength',
  'lower_strength',
  'core',
  'endurance',
  'mobility',
];

export const movementCatalog: Record<
  ExerciseType,
  {
    movementFamily: MovementFamily;
    metric: TrainingMetric;
    dailyCreditCap: number;
    label: string;
  }
> = {
  pushup: {
    movementFamily: 'upper_strength',
    metric: 'reps',
    dailyCreditCap: 250,
    label: 'Push-ups',
  },
  situp: {
    movementFamily: 'core',
    metric: 'reps',
    dailyCreditCap: 250,
    label: 'Sit-ups',
  },
  squat: {
    movementFamily: 'lower_strength',
    metric: 'reps',
    dailyCreditCap: 250,
    label: 'Squats',
  },
  run: {
    movementFamily: 'endurance',
    metric: 'metres',
    dailyCreditCap: 20000,
    label: 'Running',
  },
};

export interface CreditResult {
  creditedVolume: number;
  capped: boolean;
  explanation?: string;
}

export function toLocalDate(performedAt: string | Date): string {
  const date = performedAt instanceof Date ? performedAt : new Date(performedAt);
  if (Number.isNaN(date.getTime())) {
    return new Date().toISOString().split('T')[0];
  }

  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

export function normaliseRawVolume(exerciseId: ExerciseType, count: number): number {
  const safeCount = Math.max(0, Number.isFinite(count) ? count : 0);
  return exerciseId === 'run' ? Math.round(safeCount * 1000) : Math.round(safeCount);
}

export function displayVolume(exerciseId: ExerciseType, volume: number): string {
  if (exerciseId === 'run') {
    return `${(volume / 1000).toFixed(1)} km`;
  }

  return `${Math.round(volume)} reps`;
}

export function calculateCreditedVolume(
  exerciseId: ExerciseType,
  rawVolume: number
): CreditResult {
  const cap = movementCatalog[exerciseId].dailyCreditCap;
  const creditedVolume = Math.min(Math.max(0, rawVolume), cap);

  if (creditedVolume < rawVolume) {
    return {
      creditedVolume,
      capped: true,
      explanation: `Credited ${displayVolume(
        exerciseId,
        creditedVolume
      )} of ${displayVolume(
        exerciseId,
        rawVolume
      )} under ${CREDIT_POLICY_VERSION}. The full workout remains in history.`,
    };
  }

  return {
    creditedVolume,
    capped: false,
  };
}

export function createTrainingEvent(input: {
  id: string;
  userId: string;
  exerciseId: ExerciseType;
  count: number;
  performedAt: string;
  source: TrainingSource;
  verificationTier: VerificationTier;
  formScore?: number;
  notes?: string;
}): TrainingEvent {
  const rawVolume = normaliseRawVolume(input.exerciseId, input.count);
  const credit = calculateCreditedVolume(input.exerciseId, rawVolume);
  const performedAt = new Date(input.performedAt);
  const validPerformedAt = Number.isNaN(performedAt.getTime())
    ? new Date()
    : performedAt;
  const catalogEntry = movementCatalog[input.exerciseId];

  return {
    id: input.id,
    userId: input.userId,
    exerciseId: input.exerciseId,
    movementFamily: catalogEntry.movementFamily,
    metric: catalogEntry.metric,
    rawVolume,
    creditedVolume: credit.creditedVolume,
    performedAt: validPerformedAt.toISOString(),
    localDate: toLocalDate(validPerformedAt),
    timezoneOffsetMinutes: validPerformedAt.getTimezoneOffset(),
    source: input.source,
    verificationTier: input.verificationTier,
    formScore: input.formScore,
    creditPolicyVersion: CREDIT_POLICY_VERSION,
    createdAt: new Date().toISOString(),
    notes: input.notes,
  };
}

