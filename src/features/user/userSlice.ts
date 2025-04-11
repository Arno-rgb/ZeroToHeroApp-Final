import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { RootState } from '../../store'; // Adjust path if needed

// --- Mock User Data ---
// Simulate fetching/creating user data (replace with actual API/storage later)
const mockGetOrCreateUser = async (): Promise<UserState> => {
    console.log("MOCK_DB: Getting/Creating User...");
    await new Promise(res => setTimeout(res, 500)); // Simulate delay
    // Return a default user structure
    const userId = 'user_' + Date.now().toString(36);
    const mockUser: UserData = {
        id: userId,
        name: 'Hero',
        level: 1,
        tier: 0, // Start at tier 0 (Rank D)
        experience: 0,
        energy: 100, // Initial energy
        maxEnergy: 100, // Initial max energy
        heroTitle: 'Beginner',
        avatarCustomization: { costume: 'basic', color: 'blue' },
        createdAt: new Date().toISOString(),
        lastLogin: new Date().toISOString(),
    };
    console.log("MOCK_DB: Returning user:", mockUser);
    return mockUser as UserState; // Cast or ensure UserData matches UserState
};

// --- Types ---
// Define UserData if not imported from a shared types file
export interface UserData {
  id: string; name: string; level: number; tier: number; experience: number;
  energy?: number; maxEnergy?: number; // Make optional if might be missing initially
  heroTitle: string; avatarCustomization: { costume: string; color: string; };
  createdAt: string; lastLogin: string;
}

interface UserState extends UserData {
    // Ensure energy/maxEnergy are definitely here
    energy: number;
    maxEnergy: number;
    status: 'idle' | 'loading' | 'succeeded' | 'failed';
    error: string | null;
}

const initialState: UserState = {
  id: '', name: 'Hero', level: 1, tier: 0, experience: 0,
  energy: 100, maxEnergy: 100, heroTitle: 'Beginner',
  avatarCustomization: { costume: 'basic', color: 'blue' },
  createdAt: '', lastLogin: '', status: 'idle', error: null,
};

// --- Async Thunk for fetching/initializing user ---
export const fetchUser = createAsyncThunk<UserState, void, { state: RootState }>(
    'user/fetchUser',
    async (_, { rejectWithValue }) => {
        try {
            // Use the mock function for now
            const user = await mockGetOrCreateUser();
            return user;
        } catch (error: any) {
            return rejectWithValue(error.message || 'Failed to fetch user data');
        }
    }
);

// --- Slice Definition ---
export const userSlice = createSlice({
  name: 'user',
  initialState,
  reducers: {
    setUser: (state, action: PayloadAction<Partial<UserState>>) => { Object.assign(state, action.payload); state.energy = Math.min(state.energy, state.maxEnergy); },
    incrementLevel: (state) => { state.level += 1; state.maxEnergy += 10; state.energy = state.maxEnergy; /* Add title logic if needed */ },
    incrementTier: (state) => { state.tier += 1; if (state.tier === 1) state.heroTitle = 'Novice Hero'; else if (state.tier === 2) state.heroTitle = 'Rising Hero'; else if (state.tier === 3) state.heroTitle = 'Elite Hero'; else if (state.tier >= 4) state.heroTitle = 'One Punch Hero'; state.maxEnergy += 50; state.energy = state.maxEnergy; },
    addExperience: (state, action: PayloadAction<number>) => { state.experience += action.payload; /* TODO: Add level up check */ },
    updateAvatar: (state, action: PayloadAction<Partial<UserState['avatarCustomization']>>) => { state.avatarCustomization = { ...state.avatarCustomization, ...action.payload }; },
    updateLastLogin: (state) => { state.lastLogin = new Date().toISOString(); },
    addEnergy: (state, action: PayloadAction<number>) => { state.energy = Math.min(state.maxEnergy, state.energy + action.payload); },
    useEnergy: (state, action: PayloadAction<number>) => { state.energy = Math.max(0, state.energy - action.payload); },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchUser.pending, (state) => { state.status = 'loading'; state.error = null; })
      .addCase(fetchUser.fulfilled, (state, action: PayloadAction<UserState>) => {
        state.status = 'succeeded';
        // Replace state with fetched data
        Object.assign(state, action.payload);
        // Ensure energy/maxEnergy have default values if not present in fetched data
        state.energy = typeof state.energy === 'number' ? Math.min(state.energy, state.maxEnergy) : initialState.energy;
        state.maxEnergy = typeof state.maxEnergy === 'number' ? state.maxEnergy : initialState.maxEnergy;
      })
      .addCase(fetchUser.rejected, (state, action) => { state.status = 'failed'; state.error = action.payload as string || 'Failed to fetch user'; state.id = ''; });
  },
});

export const { setUser, incrementLevel, incrementTier, addExperience, updateAvatar, updateLastLogin, addEnergy, useEnergy } = userSlice.actions;
export default userSlice.reducer;