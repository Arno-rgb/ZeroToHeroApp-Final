import { createAsyncThunk, createSlice, PayloadAction } from '@reduxjs/toolkit';
import { RootState } from '../../store';
import {
  getStatSnapshot,
  getTrainingEventsForUser,
  saveStatSnapshot,
  db,
} from '../../utils/database';
import {
  StatSnapshot,
  createDefaultStatSnapshot,
  deriveStatSnapshot,
} from '../../domain/progression';

interface ProgressionState {
  snapshot: StatSnapshot | null;
  status: 'idle' | 'loading' | 'succeeded' | 'failed';
  error: string | null;
}

const initialState: ProgressionState = {
  snapshot: null,
  status: 'idle',
  error: null,
};

export const fetchStatSnapshot = createAsyncThunk<
  StatSnapshot,
  string,
  { state: RootState }
>('progression/fetchStatSnapshot', async (userId, { rejectWithValue }) => {
  try {
    const user = await db.users.get(userId);
    const ledgerRevision = user?.ledgerRevision || 0;
    const existingSnapshot = await getStatSnapshot(userId);

    if (existingSnapshot?.ledgerRevision === ledgerRevision) {
      return existingSnapshot;
    }

    const events = await getTrainingEventsForUser(userId);
    const snapshot =
      events.length > 0
        ? deriveStatSnapshot({ userId, events, ledgerRevision })
        : createDefaultStatSnapshot(userId, ledgerRevision);
    await saveStatSnapshot(snapshot);
    return snapshot;
  } catch (error: any) {
    return rejectWithValue(error.message || 'Failed to fetch stat snapshot');
  }
});

export const rebuildStatSnapshot = createAsyncThunk<
  StatSnapshot,
  string,
  { state: RootState }
>('progression/rebuildStatSnapshot', async (userId, { rejectWithValue }) => {
  try {
    const user = await db.users.get(userId);
    const events = await getTrainingEventsForUser(userId);
    const snapshot = deriveStatSnapshot({
      userId,
      events,
      ledgerRevision: user?.ledgerRevision || 0,
    });
    await saveStatSnapshot(snapshot);
    return snapshot;
  } catch (error: any) {
    return rejectWithValue(error.message || 'Failed to rebuild stat snapshot');
  }
});

const progressionSlice = createSlice({
  name: 'progression',
  initialState,
  reducers: {
    setSnapshot: (state, action: PayloadAction<StatSnapshot>) => {
      state.snapshot = action.payload;
      state.status = 'succeeded';
      state.error = null;
    },
  },
  extraReducers: builder => {
    builder
      .addCase(fetchStatSnapshot.pending, state => {
        state.status = 'loading';
        state.error = null;
      })
      .addCase(fetchStatSnapshot.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.snapshot = action.payload;
      })
      .addCase(fetchStatSnapshot.rejected, (state, action) => {
        state.status = 'failed';
        state.error = (action.payload as string) || 'Failed to fetch stats';
      })
      .addCase(rebuildStatSnapshot.pending, state => {
        state.status = 'loading';
        state.error = null;
      })
      .addCase(rebuildStatSnapshot.fulfilled, (state, action) => {
        state.status = 'succeeded';
        state.snapshot = action.payload;
      })
      .addCase(rebuildStatSnapshot.rejected, (state, action) => {
        state.status = 'failed';
        state.error = (action.payload as string) || 'Failed to rebuild stats';
      });
  },
});

export const { setSnapshot } = progressionSlice.actions;

export default progressionSlice.reducer;

