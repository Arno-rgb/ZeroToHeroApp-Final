import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { RootState } from '../../store/store'; // Adjust path if needed
// Import energy action from userSlice
import { addEnergy } from '../user/userSlice'; // Adjust path if needed

// --- Types ---
export type ExerciseType = 'pushup' | 'situp' | 'squat' | 'run';
export interface Exercise {
    id: string;
    type: ExerciseType;
    count: number;
    date: string; // ISO string format
    powerGenerated: number;
    formQuality: number;
    userId?: string;
}

interface ExerciseState {
    todayExercises: Exercise[];
    history: Exercise[];
    dailyGoals: { pushups: number; situps: number; squats: number; runDistance: number; };
    currentStreak: number;
    longestStreak: number;
    lastWorkoutDate: string | null; // Store YYYY-MM-DD
    totalPower: number;
    status: 'idle' | 'loading' | 'succeeded' | 'failed';
    error: string | null;
}

const initialState: ExerciseState = {
    todayExercises: [], history: [],
    dailyGoals: { pushups: 10, situps: 10, squats: 10, runDistance: 1 }, // Example goals
    currentStreak: 0, longestStreak: 0, lastWorkoutDate: null, totalPower: 0,
    status: 'idle', error: null,
};

// --- Mock DB Functions (Defined locally for now) ---
const mockAddExerciseRecord = async (data: Omit<Exercise, 'id'> & { userId: string }): Promise<Exercise> => {
    console.log('SLICE MOCK: Simulating save exercise:', data);
    await new Promise(res => setTimeout(res, 300));
    const savedExercise = { ...data.exercise, id: `ex_${Date.now().toString(36)}`, userId: data.userId };
    return savedExercise;
};
const mockGetExercisesByDate = async (userId: string, date: string): Promise<Exercise[]> => {
    console.log('SLICE MOCK: Simulating fetch exercises:', userId, date);
    await new Promise(res => setTimeout(res, 200));
    // Return empty array initially, will be populated by addExercise
    return [];
};
// --- End Mock DB ---


// --- Async Thunks ---
export const fetchTodayExercises = createAsyncThunk<Exercise[], string, { state: RootState }>(
    'exercise/fetchToday',
    async (userId, { rejectWithValue }) => {
        try {
            const today = new Date().toISOString().split('T')[0];
            const response = await mockGetExercisesByDate(userId, today); // Uses local mock
            return response;
        } catch (error: any) { return rejectWithValue(error.message); }
    }
);

interface AddExercisePayload { userId: string; exercise: Omit<Exercise, 'id'>; }
export const addExercise = createAsyncThunk<Exercise, AddExercisePayload, { state: RootState }>(
    'exercise/addExercise',
    async (payload, { dispatch, rejectWithValue }) => {
        try {
            const savedExercise = await mockAddExerciseRecord(payload); // Uses local mock
            if (savedExercise.type === 'run') {
                const energyGained = Math.round(savedExercise.powerGenerated / 2);
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
        usePower: (state, action: PayloadAction<number>) => { state.totalPower = Math.max(0, state.totalPower - action.payload); },
    },
    extraReducers: (builder) => {
        builder
            .addCase(fetchTodayExercises.pending, (state) => { state.status = 'loading'; state.error = null; })
            .addCase(fetchTodayExercises.fulfilled, (state, action: PayloadAction<Exercise[]>) => { state.status = 'succeeded'; state.todayExercises = action.payload; })
            .addCase(fetchTodayExercises.rejected, (state, action) => { state.status = 'failed'; state.error = action.payload as string || 'Failed'; })
            .addCase(addExercise.pending, (state) => { state.status = 'loading'; state.error = null; })
            .addCase(addExercise.fulfilled, (state, action: PayloadAction<Exercise>) => {
                state.status = 'succeeded';
                const newExercise = action.payload;
                if (!state.todayExercises.find(ex => ex.id === newExercise.id)) { state.todayExercises.push(newExercise); }
                state.history.push(newExercise);
                const { type, powerGenerated } = newExercise;
                if (type === 'pushup' || type === 'situp' || type === 'squat') { state.totalPower += powerGenerated; }
                const today = new Date(newExercise.date).toISOString().split('T')[0];
                const lastWorkoutDatePart = state.lastWorkoutDate ? state.lastWorkoutDate.split('T')[0] : null;
                if (lastWorkoutDatePart !== today) { state.currentStreak += 1; state.lastWorkoutDate = today; if (state.currentStreak > state.longestStreak) { state.longestStreak = state.currentStreak; } }
            })
            .addCase(addExercise.rejected, (state, action) => { state.status = 'failed'; state.error = action.payload as string || 'Failed'; });
    },
});

export const { updateDailyGoals, resetStreak, usePower } = exerciseSlice.actions;
export default exerciseSlice.reducer;
