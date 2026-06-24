import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { RootState } from '../../store'; // Adjust path if needed
import { addExerciseRecord, getExercisesByDate, ExerciseData } from '../../utils/database'; // Adjust path if needed
// Import the action from userSlice
import { addEnergy, setLedgerRevision } from '../user/userSlice'; // Adjust path if needed
import { rebuildStatSnapshot } from '../progression/progressionSlice';
import { ExerciseType as DomainExerciseType, toLocalDate } from '../../domain/training';

// --- State and Types ---
export type ExerciseType = DomainExerciseType;
export interface Exercise extends ExerciseData {}

interface ExerciseState {
    todayExercises: Exercise[];
    history: Exercise[];
    dailyGoals: { pushups: number; situps: number; squats: number; runDistance: number; };
    currentStreak: number;
    longestStreak: number;
    lastWorkoutDate: string | null;
    totalPower: number;
    status: 'idle' | 'loading' | 'succeeded' | 'failed';
    error: string | null;
}

const initialState: ExerciseState = {
    todayExercises: [],
    history: [],
    dailyGoals: { pushups: 10, situps: 10, squats: 10, runDistance: 1 }, // Example goals
    currentStreak: 0,
    longestStreak: 0,
    lastWorkoutDate: null,
    totalPower: 0,
    status: 'idle',
    error: null,
};

export const fetchTodayExercises = createAsyncThunk<Exercise[], string, { state: RootState }>(
    'exercise/fetchToday',
    async (userId, { rejectWithValue }) => {
        try {
            const today = toLocalDate(new Date());
            const response = await getExercisesByDate(userId, today);
            return response as Exercise[];
        } catch (error: any) { return rejectWithValue(error.message); }
    }
);

interface AddExercisePayload {
    userId: string;
    exercise: {
        type: ExerciseType;
        count: number;
        date: string;
        powerGenerated: number;
        formQuality: number;
    };
}
export const addExercise = createAsyncThunk<Exercise, AddExercisePayload, { state: RootState }>(
    'exercise/addExercise',
    async (payload, { dispatch, rejectWithValue }) => {
        try {
            const { userId, exercise } = payload;
            const dataToSave = { ...exercise, userId };
            const result = await addExerciseRecord(dataToSave);
            const savedExercise: Exercise = result.exercise;
            dispatch(setLedgerRevision(result.ledgerRevision));
            dispatch(rebuildStatSnapshot(userId));

            if (savedExercise.type === 'run') {
                const energyGained = Math.round(savedExercise.creditedVolume / 1000);
                if (energyGained > 0) { dispatch(addEnergy(energyGained)); }
            }

            return savedExercise;
        } catch (error: any) { return rejectWithValue(error.message); }
    }
);


// --- Slice Definition ---
export const exerciseSlice = createSlice({
    name: 'exercise',
    initialState,
    reducers: {
        updateDailyGoals: (state, action: PayloadAction<Partial<ExerciseState['dailyGoals']>>) => { state.dailyGoals = { ...state.dailyGoals, ...action.payload }; },
        resetStreak: (state) => { state.currentStreak = 0; },
        usePower: (state, action: PayloadAction<number>) => {
            console.warn(`usePower(${action.payload}) ignored: permanent training stats are not spendable.`);
        },
    },
    extraReducers: (builder) => {
        builder
            // Fetch Today Exercises
            .addCase(fetchTodayExercises.pending, (state) => { state.status = 'loading'; state.error = null; })
            .addCase(fetchTodayExercises.fulfilled, (state, action: PayloadAction<Exercise[]>) => { state.status = 'succeeded'; state.todayExercises = action.payload; })
            .addCase(fetchTodayExercises.rejected, (state, action) => { state.status = 'failed'; state.error = action.payload as string || 'Failed to fetch exercises'; })
            // Add Exercise
            .addCase(addExercise.pending, (state) => { state.status = 'loading'; state.error = null; })
            .addCase(addExercise.fulfilled, (state, action: PayloadAction<Exercise>) => {
                state.status = 'succeeded';
                const newExercise = action.payload;
                if (!state.todayExercises.find(ex => ex.id === newExercise.id)) { state.todayExercises.push(newExercise); }
                state.history.push(newExercise);

                // Update streak
                const today = new Date(newExercise.date).toISOString().split('T')[0];
                const lastWorkoutDatePart = state.lastWorkoutDate ? state.lastWorkoutDate.split('T')[0] : null;
                if (lastWorkoutDatePart !== today) { state.currentStreak += 1; state.lastWorkoutDate = today; if (state.currentStreak > state.longestStreak) { state.longestStreak = state.currentStreak; } }
            })
            .addCase(addExercise.rejected, (state, action) => { state.status = 'failed'; state.error = action.payload as string || 'Failed to add exercise'; });
    },
});

// Export synchronous actions (including updated usePower)
export const { updateDailyGoals, resetStreak, usePower } = exerciseSlice.actions;

// Export the reducer
export default exerciseSlice.reducer;
