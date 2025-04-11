import AsyncStorage from '@react-native-async-storage/async-storage';
import { Exercise, ExerciseType } from '../features/exercise/exerciseSlice'; // Assuming types are exported from slice
import { UserData } from '../features/user/userSlice'; // Assuming UserData is defined/exported here

// Define keys for AsyncStorage
const USER_KEY = '@ZeroToHero:user';
const EXERCISE_HISTORY_KEY = '@ZeroToHero:exerciseHistory';
const BATTLE_HISTORY_KEY = '@ZeroToHero:battleHistory'; // If needed later

// Define types if not imported (ensure consistency with slices)
// Re-defining here for clarity, but importing from slices is better
/*
export type ExerciseType = 'pushup' | 'situp' | 'squat' | 'run';
export interface Exercise { id: string; userId: string; type: ExerciseType; count: number; date: string; powerGenerated: number; formQuality: number; }
export interface UserData { id: string; name: string; level: number; tier: number; experience: number; energy: number; maxEnergy: number; heroTitle: string; avatarCustomization: { costume: string; color: string; }; createdAt: string; lastLogin: string; }
export interface BattleData { id: string; userId: string; bossId: string; date: string; result: 'victory' | 'defeat'; damageDealt: number; powerUsed: { strike: number; core: number; force: number; endurance: number; }; }
*/

// Helper function to generate unique IDs (simple version)
function generateId(): string {
  return `id_${Date.now().toString(36)}_${Math.random().toString(36).substring(2, 7)}`;
}

// --- User Data Functions ---

export async function getOrCreateUser(): Promise<UserData> {
  console.log('DB: Attempting to get user from AsyncStorage...');
  try {
    const existingUserData = await AsyncStorage.getItem(USER_KEY);
    if (existingUserData !== null) {
      console.log('DB: User found.');
      const user = JSON.parse(existingUserData) as UserData;
      // Ensure essential fields exist from older versions if necessary
      user.energy = typeof user.energy === 'number' ? user.energy : 100;
      user.maxEnergy = typeof user.maxEnergy === 'number' ? user.maxEnergy : 100;
      return user;
    } else {
      console.log('DB: No user found, creating default user...');
      const userId = generateId();
      const newUser: UserData = {
        id: userId,
        name: 'Hero',
        level: 1,
        tier: 0,
        experience: 0,
        energy: 100,
        maxEnergy: 100,
        heroTitle: 'Beginner',
        avatarCustomization: { costume: 'basic', color: 'blue' },
        createdAt: new Date().toISOString(),
        lastLogin: new Date().toISOString(),
      };
      await AsyncStorage.setItem(USER_KEY, JSON.stringify(newUser));
      console.log('DB: Default user created and saved.');
      return newUser;
    }
  } catch (error) {
    console.error('DB Error in getOrCreateUser:', error);
    // Fallback or re-throw depending on desired error handling
    throw new Error('Failed to get or create user data.');
  }
}

export async function saveUserData(userData: UserData): Promise<void> {
  console.log('DB: Saving user data...');
  try {
    await AsyncStorage.setItem(USER_KEY, JSON.stringify(userData));
    console.log('DB: User data saved successfully.');
  } catch (error) {
    console.error('DB Error saving user data:', error);
    throw new Error('Failed to save user data.');
  }
}

// --- Exercise Data Functions ---

export async function addExerciseRecord(exerciseData: Omit<Exercise, 'id'> & { userId: string }): Promise<Exercise> {
  console.log('DB: Adding exercise record...');
  try {
    const historyString = await AsyncStorage.getItem(EXERCISE_HISTORY_KEY);
    const history: Exercise[] = historyString ? JSON.parse(historyString) : [];

    const id = generateId();
    const newRecord: Exercise = {
      ...exerciseData.exercise, // Get data from nested exercise object
      id: id,
      userId: exerciseData.userId, // Add userId
    };

    history.push(newRecord);
    await AsyncStorage.setItem(EXERCISE_HISTORY_KEY, JSON.stringify(history));
    console.log('DB: Exercise record added successfully.');
    return newRecord; // Return the full record with ID
  } catch (error) {
    console.error('DB Error adding exercise record:', error);
    throw new Error('Failed to add exercise record.');
  }
}

export async function getExercisesByDate(userId: string, date: string): Promise<Exercise[]> {
  console.log(`DB: Getting exercises for user ${userId} on date ${date}...`);
  try {
    const historyString = await AsyncStorage.getItem(EXERCISE_HISTORY_KEY);
    const history: Exercise[] = historyString ? JSON.parse(historyString) : [];

    // Filter by userId and the date part of the ISO string
    const datePrefix = date; // Assumes date is already YYYY-MM-DD
    const filtered = history.filter(ex =>
        ex.userId === userId &&
        ex.date.startsWith(datePrefix)
    );
    console.log(`DB: Found ${filtered.length} exercises for ${date}.`);
    return filtered;
  } catch (error) {
    console.error('DB Error getting exercises by date:', error);
    throw new Error('Failed to get exercises by date.');
  }
}

export async function getExercisesByDateRange(userId: string, startDate: string, endDate: string): Promise<Exercise[]> {
    console.log(`DB: Getting exercises for user ${userId} between ${startDate} and ${endDate}...`);
    try {
        const historyString = await AsyncStorage.getItem(EXERCISE_HISTORY_KEY);
        const history: Exercise[] = historyString ? JSON.parse(historyString) : [];

        // Filter by userId and date range (inclusive)
        const start = startDate; // Assumes YYYY-MM-DD
        const end = endDate;     // Assumes YYYY-MM-DD
        const filtered = history.filter(ex =>
            ex.userId === userId &&
            ex.date.split('T')[0] >= start &&
            ex.date.split('T')[0] <= end
        );
        console.log(`DB: Found ${filtered.length} exercises between ${startDate} and ${endDate}.`);
        return filtered;
    } catch (error) {
        console.error('DB Error getting exercises by date range:', error);
        throw new Error('Failed to get exercises by date range.');
    }
}

// --- Battle Data Functions (Example - Implement if needed) ---

// export async function addBattleRecord(battleData: Omit<BattleData, 'id'>): Promise<string> {
//   // Similar logic: get history, add new record, save history
//   // ...
// }

// export async function getBattleHistory(userId: string): Promise<BattleData[]> {
//   // Similar logic: get history, filter by userId
//   // ...
// }

// --- Utility to clear data (for testing) ---
export async function clearAllData() {
    try {
        await AsyncStorage.removeItem(USER_KEY);
        await AsyncStorage.removeItem(EXERCISE_HISTORY_KEY);
        await AsyncStorage.removeItem(BATTLE_HISTORY_KEY);
        console.log('DB: All data cleared.');
    } catch (error) {
        console.error('DB Error clearing data:', error);
    }
}
