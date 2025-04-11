import { configureStore } from '@reduxjs/toolkit';
import userReducer from '../features/user/userSlice'; // Adjust path
import exerciseReducer from '../features/exercise/exerciseSlice'; // Adjust path
// import battleReducer from '../features/battle/battleSlice'; // Add later

export const store = configureStore({
  reducer: {
    user: userReducer,
    exercise: exerciseReducer,
    // battle: battleReducer, // Add later
  },
  // Optional: Add middleware like thunk (included by default) or saga
  // middleware: (getDefaultMiddleware) => getDefaultMiddleware().concat(logger),
});

// Infer the `RootState` and `AppDispatch` types from the store itself
export type RootState = ReturnType<typeof store.getState>;
// Inferred type: {user: UserState, exercise: ExerciseState, ...}
export type AppDispatch = typeof store.dispatch;
