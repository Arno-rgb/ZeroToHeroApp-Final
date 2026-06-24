import { configureStore } from '@reduxjs/toolkit';
import userReducer from './features/user/userSlice';
import exerciseReducer from './features/exercise/exerciseSlice';
import battleReducer from './features/battle/battleSlice';
import progressionReducer from './features/progression/progressionSlice';

export const store = configureStore({
  reducer: {
    user: userReducer,
    exercise: exerciseReducer,
    battle: battleReducer,
    progression: progressionReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
