import React, { useState, useEffect, useRef, useCallback } from 'react';
import {
    SafeAreaView, StyleSheet, View, Text, Button, PermissionsAndroid,
    Platform, AppState, TouchableOpacity, ScrollView, Alert,
    ActivityIndicator, Dimensions
} from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { accelerometer, SensorTypes, setUpdateIntervalForType } from 'react-native-sensors';
import Geolocation from 'react-native-geolocation-service';
import { Subscription } from 'rxjs';
import IconMI from 'react-native-vector-icons/MaterialIcons'; // Used for AddCircle button

// --- Redux Imports ---
// Ensure these paths and the definitions within the slices are correct
import { addExercise, Exercise, ExerciseType } from '../features/exercise/exerciseSlice';
import { addEnergy, addExperience } from '../features/user/userSlice';
import { RootState, AppDispatch } from '../store/store';

// --- Constants and Types ---
const SENSOR_UPDATE_INTERVAL = 100;
const LOCATION_UPDATE_INTERVAL = 2000;
const LOCATION_MAX_AGE = 5000;
const STEP_THRESHOLD = 1.2;
const STEP_DEBOUNCE = 350;
const DISTANCE_FILTER_THRESHOLD = 0.005; // 5 meters

interface LocationPoint {
    latitude: number;
    longitude: number;
    timestamp: number;
}

// --- Helper Functions ---
function haversineDistance(coords1: LocationPoint, coords2: LocationPoint): number {
    function toRad(x: number) { return x * Math.PI / 180; }
    const R = 6371; // km
    const dLat = toRad(coords2.latitude - coords1.latitude);
    const dLon = toRad(coords2.longitude - coords1.longitude);
    const lat1 = toRad(coords1.latitude);
    const lat2 = toRad(coords2.latitude);
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
}

const formatExerciseName = (type: ExerciseType | null): string => {
    if (!type) return '';
    switch (type) {
        case 'pushup': return 'Push-ups';
        case 'situp': return 'Sit-ups';
        case 'squat': return 'Squats';
        case 'run': return 'Run';
        default:
             // Ensure exhaustive check or handle default case appropriately
             const _exhaustiveCheck: never = type;
             return (type as string).charAt(0).toUpperCase() + (type as string).slice(1);
            // return type.charAt(0).toUpperCase() + type.slice(1);
    }
};

// --- Custom Hook for Run Tracking ---
function useRunTracker() {
    const [distance, setDistance] = useState(0);
    const [steps, setSteps] = useState(0);
    const [currentSpeed, setCurrentSpeed] = useState(0); // km/h
    const [status, setStatus] = useState<'idle' | 'requesting_permission' | 'tracking' | 'error'>('idle');
    const [error, setError] = useState<string | null>(null);
    const watchId = useRef<number | null>(null);
    const lastLocation = useRef<LocationPoint | null>(null);
    const sensorSubscription = useRef<Subscription | null>(null);
    const stepDetectionState = useRef<{ timestamp: number; value: number, peakDetected: boolean }>({ timestamp: 0, value: 0, peakDetected: false });

    const requestLocationPermission = useCallback(async (): Promise<boolean> => {
        // ... (permission logic remains the same)
        if (Platform.OS === 'ios') {
            const auth = await Geolocation.requestAuthorization('whenInUse');
            return auth === 'granted';
        }
        if (Platform.OS === 'android') {
            try {
                const granted = await PermissionsAndroid.request(
                    PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
                    {
                        title: 'Location Permission Required',
                        message: 'Zero To Hero needs access to your location to track your runs.',
                        buttonPositive: 'OK',
                        buttonNegative: 'Cancel',
                    },
                );
                return granted === PermissionsAndroid.RESULTS.GRANTED;
            } catch (err) {
                console.warn(err);
                return false;
            }
        }
        return false;
    }, []);

    const processAccelerometerData = useCallback(({ x, y, z, timestamp }: { x: number; y: number; z: number; timestamp: number }) => {
        // ... (accelerometer logic remains the same)
        const magnitude = Math.sqrt(x * x + y * y + z * z);
        const now = Date.now();
        const timeSinceLastStep = now - stepDetectionState.current.timestamp;
        const GRAVITY_APPROX = 9.8;

        if (magnitude > GRAVITY_APPROX + STEP_THRESHOLD && timeSinceLastStep > STEP_DEBOUNCE) {
             if (!stepDetectionState.current.peakDetected) {
                setSteps(s => s + 1);
                stepDetectionState.current = { timestamp: now, value: magnitude, peakDetected: true };
            }
        } else if (magnitude < GRAVITY_APPROX) {
            stepDetectionState.current.peakDetected = false;
        }
        stepDetectionState.current.value = magnitude;
    }, []);

    const startTracking = useCallback(async () => {
        // ... (start tracking logic remains the same)
        setStatus('requesting_permission');
        setError(null);
        const hasPermission = await requestLocationPermission();
        if (!hasPermission) {
            setError('Location permission denied.');
            setStatus('error');
            return;
        }

        setStatus('tracking');
        setDistance(0);
        setSteps(0);
        setCurrentSpeed(0);
        lastLocation.current = null;
        stepDetectionState.current = { timestamp: 0, value: 0, peakDetected: false };

        if (watchId.current !== null) Geolocation.clearWatch(watchId.current);
        sensorSubscription.current?.unsubscribe();

        watchId.current = Geolocation.watchPosition(
            (position) => {
                const { latitude, longitude, speed } = position.coords;
                const timestamp = position.timestamp;
                const currentLocation: LocationPoint = { latitude, longitude, timestamp };

                if (lastLocation.current) {
                    const distanceMoved = haversineDistance(lastLocation.current, currentLocation);
                    if (distanceMoved > DISTANCE_FILTER_THRESHOLD) {
                         setDistance(d => d + distanceMoved);
                    }
                }
                lastLocation.current = currentLocation;
                setCurrentSpeed(speed ? Math.max(0, speed * 3.6) : 0);
                setError(null);
            },
            (locError) => {
                console.error('Geolocation Error:', locError);
                setError(`Location error: ${locError.code} - ${locError.message}`);
            },
            {
                accuracy: { android: 'high', ios: 'best' },
                enableHighAccuracy: true,
                distanceFilter: 5,
                interval: LOCATION_UPDATE_INTERVAL,
                fastestInterval: LOCATION_UPDATE_INTERVAL / 2,
                forceRequestLocation: true,
                showLocationDialog: true,
                useSignificantChanges: false
            }
        );

        setUpdateIntervalForType(SensorTypes.accelerometer, SENSOR_UPDATE_INTERVAL);
        sensorSubscription.current = accelerometer.subscribe(processAccelerometerData);

    }, [requestLocationPermission, processAccelerometerData]);

    const stopTracking = useCallback(() => {
        // ... (stop tracking logic remains the same)
        console.log("Stopping run tracking...");
        if (watchId.current !== null) {
            Geolocation.clearWatch(watchId.current);
            watchId.current = null;
        }
        sensorSubscription.current?.unsubscribe();
        sensorSubscription.current = null;
        setStatus('idle');
        setCurrentSpeed(0);
        return { finalDistance: distance, finalSteps: steps };
    }, [distance, steps]);

    useEffect(() => {
        return () => {
            stopTracking();
        };
    }, [stopTracking]);

    return { distance, steps, currentSpeed, status, error, startTracking, stopTracking };
}


// --- Main Screen Component ---
const ExerciseScreen: React.FC<{ navigation: any }> = ({ navigation }) => {
    const dispatch: AppDispatch = useDispatch();
    const userId = useSelector((state: RootState) => state.user.id); // Type: string | null

    const [selectedExercise, setSelectedExercise] = useState<ExerciseType | null>(null);
    const { distance, steps, currentSpeed, status: runStatus, error: runError, startTracking: startRunTracking, stopTracking: stopRunTracking } = useRunTracker();
    const [manualRepCount, setManualRepCount] = useState(0);
    const [isTrackingBodyweight, setIsTrackingBodyweight] = useState(false);

    // --- Handlers ---
    const handleSelectExercise = (type: ExerciseType) => {
        // ... (selection logic remains the same)
        if ((runStatus === 'tracking' && type !== 'run') || (isTrackingBodyweight && type === 'run')) {
            Alert.alert("Tracking Active", "Stop the current workout before switching types.");
            return;
        }
        if (type !== 'run' && runStatus === 'tracking') stopRunTracking();
        if (type === 'run' && isTrackingBodyweight) {
             setIsTrackingBodyweight(false);
             setManualRepCount(0);
        }
        setSelectedExercise(type);
        if (type !== 'run' && !isTrackingBodyweight) setManualRepCount(0);
    };

    const handleStartStop = async () => {
        if (!selectedExercise) return;

        const isStopping = (selectedExercise === 'run' && runStatus === 'tracking') || (selectedExercise !== 'run' && isTrackingBodyweight);

        // --- Check for userId ONLY when STOPPING and saving data ---
        if (isStopping && !userId) {
            Alert.alert("Error", "User not identified. Cannot save workout.");
            // Allow stopping the UI/sensors even without saving
            if (selectedExercise === 'run' && runStatus === 'tracking') {
                stopRunTracking();
            }
            if (selectedExercise !== 'run' && isTrackingBodyweight) {
                setIsTrackingBodyweight(false);
                setManualRepCount(0);
            }
            return; // Prevent saving attempt
        }
        // --- End of userId check ---


        if (selectedExercise === 'run') {
            // --- Run Start/Stop ---
            if (runStatus === 'tracking') {
                // --- Stopping Run ---
                const { finalDistance, finalSteps } = stopRunTracking();

                // userId is guaranteed to be a string here because of the check above
                if (userId && (finalDistance > 0 || finalSteps > 0)) {
                    const powerPerKm = 10;
                    const powerGenerated = Math.round(finalDistance * powerPerKm);
                    const energyGained = Math.round(powerGenerated / 2);

                    // Create the PAYLOAD object expected by addExercise action creator
                    const exercisePayload: Omit<Exercise, "id"> = {
                        type: 'run', // Use the specific literal type
                        count: parseFloat(finalDistance.toFixed(2)),
                        date: new Date().toISOString(),
                        powerGenerated: powerGenerated,
                        formQuality: null,
                        metadata: { steps: finalSteps }
                    };

                    // Dispatch the action by CALLING the action creator with the payload object
                    dispatch(addExercise({ userId, exercise: exercisePayload }));

                    // Dispatch other actions by CALLING the action creators with their payloads
                    if (energyGained > 0) {
                        dispatch(addEnergy(energyGained));
                    }
                    dispatch(addExperience(finalSteps));

                    Alert.alert("Run Saved!", `Distance: ${finalDistance.toFixed(2)}km, Steps: ${finalSteps}, Energy: +${energyGained}`);

                } else if (finalDistance <= 0 && finalSteps <= 0) {
                    Alert.alert("Run Stopped", "No significant distance/steps recorded.");
                }
            } else {
                // --- Starting Run ---
                startRunTracking();
            }
        } else {
            // --- Manual Bodyweight Start/Stop ---
            if (isTrackingBodyweight) {
                // --- Stopping Bodyweight ---
                const finalRepCount = manualRepCount;
                setIsTrackingBodyweight(false);
                setManualRepCount(0);

                // userId is guaranteed string, selectedExercise is guaranteed non-run ExerciseType
                if (userId && finalRepCount > 0 && selectedExercise && selectedExercise !== 'run') {
                    const powerPerRep = selectedExercise === 'pushup' ? 7 : selectedExercise === 'situp' ? 4 : 5;
                    const energyPerRep = 0.5;
                    const xpPerRep = 2;
                    const totalPowerGenerated = Math.round(finalRepCount * powerPerRep);
                    const totalEnergyGained = Math.round(finalRepCount * energyPerRep);
                    const totalXpGained = Math.round(finalRepCount * xpPerRep);

                    // Create the PAYLOAD object
                     const exercisePayload: Omit<Exercise, "id"> = {
                        type: selectedExercise, // selectedExercise is narrowed to 'pushup'|'situp'|'squat' here
                        count: finalRepCount,
                        date: new Date().toISOString(),
                        powerGenerated: totalPowerGenerated,
                        formQuality: null, // Manual count doesn't track form
                        metadata: {}
                     };

                     // Dispatch the action by CALLING the action creator
                     dispatch(addExercise({ userId, exercise: exercisePayload }));

                     // Dispatch other actions by CALLING the action creators
                     if (totalEnergyGained > 0) {
                        dispatch(addEnergy(totalEnergyGained));
                     }
                     if (totalXpGained > 0) {
                        dispatch(addExperience(totalXpGained));
                     }

                    Alert.alert("Workout Saved!", `Exercise: ${formatExerciseName(selectedExercise)}\nReps: ${finalRepCount}\nPower: +${totalPowerGenerated}\nEnergy: +${totalEnergyGained}\nXP: +${totalXpGained}`);

                } else if (finalRepCount <= 0) {
                    Alert.alert("Workout Stopped", "No reps recorded.");
                }
            } else {
                // --- Starting Bodyweight ---
                setManualRepCount(0);
                setIsTrackingBodyweight(true);
            }
        }
    };

    // --- Render UI ---
    const renderTrackingUI = () => {
        if (!selectedExercise) {
            return ( /* ... Placeholder UI ... */
                 <View style={styles.placeholderContainer}>
                    <Text style={styles.placeholderText}>Select an exercise above to begin.</Text>
                 </View>
            );
        }

        if (selectedExercise === 'run') {
             return ( /* ... Run UI ... */
                 <View style={styles.trackerContainer}>
                    <View style={styles.trackerBox}>
                        <Text style={styles.metricLabel}>Distance</Text>
                        <Text style={styles.metricValue}>{distance.toFixed(2)} <Text style={styles.metricUnit}>km</Text></Text>
                        <Text style={styles.metricLabel}>Steps</Text>
                        <Text style={styles.metricValue}>{steps}</Text>
                        <Text style={styles.metricLabel}>Current Speed</Text>
                        <Text style={styles.metricValue}>{currentSpeed.toFixed(1)} <Text style={styles.metricUnit}>km/h</Text></Text>
                        {runError && <Text style={styles.errorText}>Error: {runError}</Text>}
                        <TouchableOpacity
                            style={[styles.button, runStatus === 'tracking' ? styles.stopButton : styles.startButton, runStatus === 'requesting_permission' && styles.disabledButton]}
                            onPress={handleStartStop}
                            disabled={runStatus === 'requesting_permission'}
                        >
                            <Text style={styles.buttonText}>
                                {runStatus === 'tracking' ? 'Stop Run' : runStatus === 'requesting_permission' ? 'Starting...' : 'Start Run'}
                            </Text>
                        </TouchableOpacity>
                        {runStatus === 'tracking' && <Text style={styles.statusText}>Tracking run...</Text>}
                        {runStatus === 'requesting_permission' && <ActivityIndicator style={{ marginTop: 10 }} />}
                    </View>
                </View>
             );
        }

        // --- Render Manual Bodyweight Exercise UI ---
        return ( /* ... Manual Count UI ... */
             <View style={styles.trackerContainer}>
                <Text style={styles.exerciseTitle}>{formatExerciseName(selectedExercise)}</Text>
                <View style={styles.manualCounterArea}>
                    <Text style={styles.repCountText}>{manualRepCount}</Text>
                    <TouchableOpacity
                        style={[styles.button, styles.recordRepButton, !isTrackingBodyweight && styles.disabledButton]}
                        onPress={() => setManualRepCount(c => c + 1)}
                        disabled={!isTrackingBodyweight}
                    >
                        <IconMI name="add-circle-outline" size={24} color="#ffffff" style={{ marginRight: 8 }} />
                        <Text style={styles.buttonText}>Record Rep</Text>
                    </TouchableOpacity>
                </View>
                <TouchableOpacity
                    style={[styles.button, isTrackingBodyweight ? styles.stopButton : styles.startButton]}
                    onPress={handleStartStop}
                >
                    <Text style={styles.buttonText}>
                        {isTrackingBodyweight ? 'Stop Workout' : 'Start Workout'}
                    </Text>
                </TouchableOpacity>
                {isTrackingBodyweight && <Text style={styles.statusText}>Workout active. Tap 'Record Rep'.</Text>}
                {!isTrackingBodyweight && manualRepCount === 0 && <Text style={styles.statusText}>Ready to start.</Text>}
            </View>
        );
    };

    // Main Return
    return ( /* ... Main JSX structure ... */
        <SafeAreaView style={styles.safeArea}>
            <ScrollView contentContainerStyle={styles.container}>
                <Text style={styles.heading}>Track Workout</Text>
                <View style={styles.selectionContainer}>
                    {(['pushup', 'situp', 'squat', 'run'] as ExerciseType[]).map((type) => (
                        <TouchableOpacity
                            key={type}
                            style={[
                                styles.selectionButton,
                                selectedExercise === type && styles.selectionButtonActive,
                                (runStatus === 'tracking' && type !== 'run') && styles.selectionButtonDisabled,
                                (isTrackingBodyweight && type === 'run') && styles.selectionButtonDisabled,
                            ]}
                            onPress={() => handleSelectExercise(type)}
                            disabled={(runStatus === 'tracking' && type !== 'run') || (isTrackingBodyweight && type === 'run')}
                        >
                            <Text style={[
                                styles.selectionButtonText,
                                selectedExercise === type && styles.selectionButtonTextActive,
                                ((runStatus === 'tracking' && type !== 'run') || (isTrackingBodyweight && type === 'run')) && styles.selectionButtonTextDisabled,
                            ]}>
                                {formatExerciseName(type)}
                            </Text>
                        </TouchableOpacity>
                    ))}
                </View>
                {renderTrackingUI()}
            </ScrollView>
        </SafeAreaView>
    );
};

// --- Styles ---
// Styles remain the same as the previous version
const styles = StyleSheet.create({
    safeArea: { flex: 1, backgroundColor: '#F8F8F8', },
    container: { flexGrow: 1, padding: 20, alignItems: 'center', },
    heading: { fontSize: 28, fontWeight: 'bold', marginBottom: 20, color: '#111827', textAlign: 'center', },
    selectionContainer: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'center', marginBottom: 25, width: '100%', },
    selectionButton: { paddingVertical: 10, paddingHorizontal: 18, backgroundColor: '#e5e7eb', borderRadius: 20, margin: 5, },
    selectionButtonActive: { backgroundColor: '#6366f1', },
    selectionButtonDisabled: { backgroundColor: '#d1d5db', opacity: 0.7, },
    selectionButtonText: { color: '#374151', fontWeight: '600', textAlign: 'center', },
    selectionButtonTextActive: { color: '#ffffff', },
    selectionButtonTextDisabled: { color: '#6b7280', },
    trackerContainer: { width: '100%', maxWidth: 500, padding: 20, backgroundColor: '#ffffff', borderRadius: 15, shadowColor: "#000", shadowOffset: { width: 0, height: 2, }, shadowOpacity: 0.1, shadowRadius: 5, elevation: 5, alignItems: 'center', minHeight: 350, justifyContent: 'space-between', paddingBottom: 30, },
    trackerBox: { alignItems: 'center', width: '100%', },
    metricLabel: { fontSize: 16, color: '#6b7280', marginTop: 10, },
    metricValue: { fontSize: 32, fontWeight: 'bold', color: '#1f2937', marginBottom: 3, },
    metricUnit: { fontSize: 14, fontWeight: 'normal', color: '#4b5563', },
    statusText: { fontSize: 14, fontStyle: 'italic', color: '#6b7280', marginTop: 15, textAlign: 'center' },
    errorText: { fontSize: 14, color: '#dc2626', marginTop: 10, textAlign: 'center', fontWeight: '500', },
    button: { flexDirection: 'row', marginTop: 15, paddingVertical: 12, paddingHorizontal: 30, borderRadius: 25, alignItems: 'center', justifyContent: 'center', minWidth: 180, alignSelf: 'center', },
    startButton: { backgroundColor: '#10b981', },
    stopButton: { backgroundColor: '#ef4444', },
    disabledButton: { backgroundColor: '#9ca3af', opacity: 0.8, },
    buttonText: { color: '#ffffff', fontSize: 18, fontWeight: 'bold', textAlign: 'center' },
    placeholderContainer: { alignItems: 'center', justifyContent: 'center', paddingVertical: 40, width: '100%', marginTop: 20, backgroundColor: '#ffffff', borderRadius: 15, minHeight: 300, },
    placeholderText: { fontSize: 18, color: '#6b7280', textAlign: 'center', marginBottom: 5, },
    exerciseTitle: { fontSize: 24, fontWeight: 'bold', color: '#1f2937', marginBottom: 25, textAlign: 'center' },
    manualCounterArea: { alignItems: 'center', marginBottom: 30, width: '100%', },
    repCountText: { fontSize: 80, fontWeight: 'bold', color: '#111827', textShadowColor: 'rgba(0, 0, 0, 0.1)', textShadowOffset: { width: 0, height: 1 }, textShadowRadius: 2, marginBottom: 20, textAlign: 'center', },
    recordRepButton: { backgroundColor: '#3b82f6', paddingHorizontal: 25, minWidth: 200, marginBottom: 20, },
});


export default ExerciseScreen;