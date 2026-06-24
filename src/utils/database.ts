import Dexie from 'dexie';
import {
  ExerciseType,
  TrainingEvent,
  TrainingSource,
  VerificationTier,
  calculateCreditedVolume,
  createTrainingEvent,
  displayVolume,
  toLocalDate,
} from '../domain/training';
import { StatSnapshot } from '../domain/progression';
import { BattleRecord } from '../domain/combat';

export interface UserData {
  id: string;
  name: string;
  level: number;
  tier: number;
  experience: number;
  energy: number;
  maxEnergy: number;
  ledgerRevision: number;
  heroTitle: string;
  avatarCustomization: {
    costume: string;
    color: string;
  };
  createdAt: string;
  lastLogin: string;
}

export interface ExerciseData {
  id: string;
  userId: string;
  type: ExerciseType;
  count: number;
  date: string;
  performedAt: string;
  localDate: string;
  rawVolume: number;
  creditedVolume: number;
  creditExplanation?: string;
  powerGenerated: number;
  formQuality: number;
}

export type BattleData = BattleRecord;

interface AddExerciseInput {
  userId: string;
  type: ExerciseType;
  count: number;
  date: string;
  powerGenerated: number;
  formQuality: number;
  source?: TrainingSource;
  verificationTier?: VerificationTier;
}

export interface AddExerciseRecordResult {
  exercise: ExerciseData;
  trainingEvent: TrainingEvent;
  ledgerRevision: number;
}

export interface LocalSaveData {
  exportedAt: string;
  users: UserData[];
  exercises: ExerciseData[];
  trainingEvents: TrainingEvent[];
  statSnapshots: StatSnapshot[];
  battles: BattleRecord[];
}

export class FitnessGameDB extends Dexie {
  users!: Dexie.Table<UserData, string>;
  exercises!: Dexie.Table<ExerciseData, string>;
  trainingEvents!: Dexie.Table<TrainingEvent, string>;
  statSnapshots!: Dexie.Table<StatSnapshot, string>;
  battles!: Dexie.Table<BattleRecord, string>;

  constructor() {
    super('fitnessGameDB');

    this.version(1).stores({
      users: 'id, name, level, tier, lastLogin',
      exercises: 'id, userId, type, date, [userId+date]',
      battles: 'id, userId, bossId, date, result',
    });

    this.version(2)
      .stores({
        users: 'id, name, level, tier, lastLogin',
        exercises: 'id, userId, type, date, localDate, [userId+localDate]',
        trainingEvents:
          'id, userId, exerciseId, localDate, performedAt, [userId+localDate], [userId+movementFamily]',
        statSnapshots: 'id, userId, rulesVersion, generatedAt',
        battles: 'id, userId, bossId, endedAt, result',
      })
      .upgrade(async tx => {
        const users = tx.table('users');
        const exercises = tx.table('exercises');
        const trainingEvents = tx.table('trainingEvents');

        const existingUsers = await users.toArray();
        for (const user of existingUsers) {
          await users.update(user.id, {
            energy: typeof user.energy === 'number' ? user.energy : 100,
            maxEnergy: typeof user.maxEnergy === 'number' ? user.maxEnergy : 100,
            ledgerRevision:
              typeof user.ledgerRevision === 'number' ? user.ledgerRevision : 0,
          });
        }

        const existingExercises = await exercises.toArray();
        let migratedCount = 0;

        for (const exercise of existingExercises) {
          const performedAt = exercise.performedAt || exercise.date || new Date().toISOString();
          const event = createTrainingEvent({
            id: `migration-${exercise.id}`,
            userId: exercise.userId,
            exerciseId: exercise.type,
            count: exercise.count,
            performedAt,
            source: 'migration',
            verificationTier: 'self_reported',
            formScore: exercise.formQuality,
          });
          const credit = calculateCreditedVolume(event.exerciseId, event.rawVolume);

          await exercises.update(exercise.id, {
            performedAt: event.performedAt,
            localDate: event.localDate,
            rawVolume: event.rawVolume,
            creditedVolume: event.creditedVolume,
            creditExplanation: credit.explanation,
          });

          await trainingEvents.put(event);
          migratedCount += 1;
        }

        if (migratedCount > 0) {
          const userIds = new Set(existingExercises.map(exercise => exercise.userId));
          for (const userId of userIds) {
            const user = await users.get(userId);
            await users.update(userId, {
              ledgerRevision: (user?.ledgerRevision || 0) + migratedCount,
            });
          }
        }
      });
  }
}

export const db = new FitnessGameDB();

export async function initializeUserIfNeeded(): Promise<string> {
  const userCount = await db.users.count();

  if (userCount === 0) {
    const userId = generateId();
    const newUser: UserData = {
      id: userId,
      name: 'Hero',
      level: 1,
      tier: 0,
      experience: 0,
      energy: 100,
      maxEnergy: 100,
      ledgerRevision: 0,
      heroTitle: 'Beginner',
      avatarCustomization: {
        costume: 'basic',
        color: 'blue',
      },
      createdAt: new Date().toISOString(),
      lastLogin: new Date().toISOString(),
    };

    await db.users.add(newUser);
    return userId;
  }

  const firstUser = await db.users.toCollection().first();
  if (firstUser) {
    await ensureUserDefaults(firstUser);
  }
  return firstUser?.id || '';
}

export async function updateUserLogin(userId: string): Promise<void> {
  await db.users.update(userId, {
    lastLogin: new Date().toISOString(),
  });
}

export async function addExerciseRecord(
  exerciseData: AddExerciseInput
): Promise<AddExerciseRecordResult> {
  const id = generateId();
  const event = createTrainingEvent({
    id: `event-${id}`,
    userId: exerciseData.userId,
    exerciseId: exerciseData.type,
    count: exerciseData.count,
    performedAt: exerciseData.date,
    source: exerciseData.source || 'manual',
    verificationTier: exerciseData.verificationTier || 'self_reported',
    formScore: exerciseData.formQuality,
  });
  const credit = calculateCreditedVolume(event.exerciseId, event.rawVolume);

  const exercise: ExerciseData = {
    id,
    userId: exerciseData.userId,
    type: exerciseData.type,
    count: exerciseData.count,
    date: event.performedAt,
    performedAt: event.performedAt,
    localDate: event.localDate,
    rawVolume: event.rawVolume,
    creditedVolume: event.creditedVolume,
    creditExplanation: credit.explanation,
    powerGenerated: exerciseData.powerGenerated,
    formQuality: exerciseData.formQuality,
  };

  const ledgerRevision = await db.transaction(
    'rw',
    db.exercises,
    db.trainingEvents,
    db.users,
    async () => {
      await db.exercises.add(exercise);
      await db.trainingEvents.add(event);
      const user = await db.users.get(exerciseData.userId);
      const nextLedgerRevision = (user?.ledgerRevision || 0) + 1;
      await db.users.update(exerciseData.userId, {
        ledgerRevision: nextLedgerRevision,
      });
      return nextLedgerRevision;
    }
  );

  return {
    exercise,
    trainingEvent: event,
    ledgerRevision,
  };
}

export async function getExercisesByDate(
  userId: string,
  localDate: string
): Promise<ExerciseData[]> {
  const records = await db.exercises
    .where('[userId+localDate]')
    .equals([userId, localDate])
    .toArray();

  if (records.length > 0) {
    return records;
  }

  const legacyRecords = await db.exercises.where('userId').equals(userId).toArray();
  return legacyRecords.filter(record => toLocalDate(record.performedAt || record.date) === localDate);
}

export async function getExercisesByDateRange(
  userId: string,
  startDate: string,
  endDate: string
): Promise<ExerciseData[]> {
  return db.exercises
    .where('userId')
    .equals(userId)
    .and(item => {
      const localDate = item.localDate || toLocalDate(item.performedAt || item.date);
      return localDate >= startDate && localDate <= endDate;
    })
    .toArray();
}

export async function getTrainingEventsForUser(
  userId: string
): Promise<TrainingEvent[]> {
  return db.trainingEvents.where('userId').equals(userId).sortBy('performedAt');
}

export async function saveStatSnapshot(snapshot: StatSnapshot): Promise<void> {
  await db.statSnapshots.put(snapshot);
}

export async function getStatSnapshot(
  userId: string
): Promise<StatSnapshot | undefined> {
  return db.statSnapshots.get(userId);
}

export async function addBattleRecord(
  battleData: Omit<BattleRecord, 'id'>
): Promise<string> {
  const id = generateId();
  await db.battles.add({
    id,
    ...battleData,
  });
  return id;
}

export async function getBattleHistory(userId: string): Promise<BattleRecord[]> {
  return db.battles.where('userId').equals(userId).toArray();
}

export async function exportLocalSave(): Promise<LocalSaveData> {
  return {
    exportedAt: new Date().toISOString(),
    users: await db.users.toArray(),
    exercises: await db.exercises.toArray(),
    trainingEvents: await db.trainingEvents.toArray(),
    statSnapshots: await db.statSnapshots.toArray(),
    battles: await db.battles.toArray(),
  };
}

export async function importLocalSave(saveData: LocalSaveData): Promise<void> {
  await db.transaction(
    'rw',
    db.users,
    db.exercises,
    db.trainingEvents,
    db.statSnapshots,
    db.battles,
    async () => {
      await db.users.clear();
      await db.exercises.clear();
      await db.trainingEvents.clear();
      await db.statSnapshots.clear();
      await db.battles.clear();
      await db.users.bulkPut(saveData.users || []);
      await db.exercises.bulkPut(saveData.exercises || []);
      await db.trainingEvents.bulkPut(saveData.trainingEvents || []);
      await db.statSnapshots.bulkPut(saveData.statSnapshots || []);
      await db.battles.bulkPut(saveData.battles || []);
    }
  );
}

export function getCreditSummary(exercise: ExerciseData): string {
  return exercise.creditExplanation
    ? exercise.creditExplanation
    : `Credited ${displayVolume(exercise.type, exercise.creditedVolume || exercise.rawVolume || 0)}.`;
}

export function generateId(): string {
  return Date.now().toString(36) + Math.random().toString(36).substring(2);
}

async function ensureUserDefaults(user: Partial<UserData> & { id: string }): Promise<void> {
  await db.users.update(user.id, {
    energy: typeof user.energy === 'number' ? user.energy : 100,
    maxEnergy: typeof user.maxEnergy === 'number' ? user.maxEnergy : 100,
    ledgerRevision:
      typeof user.ledgerRevision === 'number' ? user.ledgerRevision : 0,
  });
}

