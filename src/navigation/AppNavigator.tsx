import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { NavigationContainer } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/FontAwesome'; // Example icon library

// Import your screen components
import DashboardScreen from '../screens/DashboardScreen'; // Adjust path
// --- Corrected Import Name ---
import ExerciseTrackingScreen from '../screens/ExerciseScreen'; // Assuming the component exported is ExerciseTrackingScreen
// --- End Correction ---
import BattleScreen from '../screens/BattleScreen'; // Adjust path
import ProfileScreen from '../screens/ProfileScreen'; // Adjust path

const Tab = createBottomTabNavigator();

const AppNavigator = () => {
  return (
    <NavigationContainer>
      <Tab.Navigator
        screenOptions={({ route }) => ({
          tabBarIcon: ({ focused, color, size }) => {
            let iconName = 'question-circle'; // Default icon

            if (route.name === 'Dashboard') iconName = 'tachometer';
            else if (route.name === 'Exercises') iconName = 'heartbeat';
            else if (route.name === 'Battle') iconName = 'gamepad';
            else if (route.name === 'Profile') iconName = 'user';

            return <Icon name={iconName} size={size} color={color} />;
          },
          tabBarActiveTintColor: '#6366f1', // Example: Indigo
          tabBarInactiveTintColor: 'gray',
          headerShown: false,
        })}
      >
        <Tab.Screen name="Dashboard" component={DashboardScreen} />
        {/* --- Use Corrected Component Name --- */}
        <Tab.Screen name="Exercises" component={ExerciseTrackingScreen} />
        {/* --- End Correction --- */}
        <Tab.Screen name="Battle" component={BattleScreen} />
        <Tab.Screen name="Profile" component={ProfileScreen} />
      </Tab.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;
