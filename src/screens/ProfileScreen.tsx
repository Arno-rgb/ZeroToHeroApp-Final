import React, { useState, useMemo, useEffect } from 'react';
import {
    SafeAreaView,
    ScrollView,
    View,
    Text, // Ensure Text is always used for strings
    StyleSheet,
    Image,
    TextInput,
    Button,
    TouchableOpacity,
    ActivityIndicator,
    Platform,
    Alert
} from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { RootState, AppDispatch } from '../store/store';
import { setUser, fetchUser } from '../features/user/userSlice';
import Icon from 'react-native-vector-icons/FontAwesome';

// (Helper functions omitted for brevity - no direct text rendering)
const getRankLetter = (tier: number): string => { if (tier >= 4) return 'S'; if (tier === 3) return 'A'; if (tier === 2) return 'B'; if (tier === 1) return 'C'; return 'D'; };
const calculateExpForNextLevel = (level: number): number => { return Math.floor(100 * Math.pow(1.2, Math.max(1, level) - 1)); };
const getCharacterImage = (avatar: { costume: string; color: string } | undefined): string | null => { /* console.log("Profile Avatar Customization:", avatar); */ return null; };

const ProfileScreen: React.FC<{ navigation: any }> = ({ navigation }) => {
    const dispatch: AppDispatch = useDispatch();

    const userData = useSelector((state: RootState) => state.user);
    const { id: userId, name = 'Hero', level = 1, tier = 0, experience = 0, energy = 0, maxEnergy = 100, heroTitle = 'Rookie', avatarCustomization, status: userStatus = 'idle', error: userError } = userData;
    const { totalPower = 0, currentStreak = 0, longestStreak = 0 } = useSelector((state: RootState) => state.exercise);

    const [isEditingName, setIsEditingName] = useState(false);
    const [editableName, setEditableName] = useState(name);

    useEffect(() => { setEditableName(name); }, [name]);

    const rankLetter = useMemo(() => getRankLetter(tier), [tier]);
    const expForNextLevel = useMemo(() => calculateExpForNextLevel(level), [level]);
    const levelProgressPercent = useMemo(() => expForNextLevel > 0 ? Math.min(100, Math.round((experience / expForNextLevel) * 100)) : 0, [experience, expForNextLevel]);
    const characterImageUri = getCharacterImage(avatarCustomization);
    const rankColors: { [key: string]: string } = { C: '#0d9488', B: '#2563eb', A: '#9333ea', S: '#f97316', D: '#6b7280' };
    const rankColor = useMemo(() => rankColors[rankLetter] || '#6b7280', [rankLetter]);

    const handleEditName = () => { setEditableName(name); setIsEditingName(true); };
    const handleCancelEdit = () => { setIsEditingName(false); setEditableName(name); };
    const handleSaveName = () => { const trimmedName = editableName.trim(); if (trimmedName && trimmedName !== name) { console.log("Dispatching setUser to update name:", trimmedName); dispatch(setUser({ ...userData, name: trimmedName })); } else if (!trimmedName) { Alert.alert("Invalid Name", "Name cannot be empty."); setEditableName(name); } setIsEditingName(false); };

    if ((userStatus === 'loading' || userStatus === 'idle') || !userId) {
        return <View style={styles.centerContainer}><ActivityIndicator size="large" color="#6366f1" /></View>;
    }
    if (userStatus === 'failed') {
        // Ensure error message is wrapped
        return <View style={styles.centerContainer}><Text style={styles.errorText}>Error loading profile: {userError || 'Unknown error'}</Text></View>;
    }

    return (
        <SafeAreaView style={styles.safeArea}>
            <ScrollView contentContainerStyle={styles.container}>
                {/* All text content is inside Text components */}
                <Text style={styles.heading}>Hero Profile</Text>

                <View style={styles.avatarSection}>
                    {characterImageUri ? (
                        <Image source={{ uri: characterImageUri }} style={styles.avatarImage} resizeMode="contain" />
                    ) : (
                        // Emoji is text, so it needs to be in a Text component
                        <View style={styles.avatarPlaceholder}><Text style={{ fontSize: 80 }}>🦸</Text></View>
                    )}
                    {/* Button title is handled internally by RN Button */}
                    <Button title="Customize Avatar" onPress={() => navigation.navigate('Customize')} />
                </View>

                <View style={styles.section}>
                    <Text style={styles.sectionTitle}>Name</Text>
                    {!isEditingName ? (
                        <View style={styles.nameDisplayContainer}>
                            <Text style={styles.nameText}>{name}</Text>
                            <TouchableOpacity onPress={handleEditName} style={styles.editButton}>
                                <Icon name="pencil" size={18} color="#6366f1" />
                            </TouchableOpacity>
                        </View>
                    ) : (
                        <View style={styles.nameEditContainer}>
                            <TextInput
                                value={editableName}
                                onChangeText={setEditableName}
                                style={styles.nameInput}
                                autoFocus={true}
                                maxLength={20}
                                returnKeyType="done"
                                onSubmitEditing={handleSaveName}
                            />
                            <TouchableOpacity onPress={handleSaveName} style={[styles.editButton, styles.saveButton]}>
                                <Icon name="check" size={18} color="green" />
                            </TouchableOpacity>
                            <TouchableOpacity onPress={handleCancelEdit} style={[styles.editButton, styles.cancelButton]}>
                                <Icon name="times" size={18} color="red" />
                            </TouchableOpacity>
                        </View>
                    )}
                </View>

                <View style={styles.section}>
                    <Text style={styles.sectionTitle}>Stats</Text>
                    <View style={styles.statRow}>
                        <Text style={styles.statLabel}>Rank:</Text>
                        <Text style={[styles.statValue, { color: rankColor, fontWeight: 'bold' }]}>{rankLetter}</Text>
                    </View>
                    <View style={styles.statRow}>
                        <Text style={styles.statLabel}>Level:</Text>
                        <Text style={styles.statValue}>{level}</Text>
                    </View>
                    <View style={styles.statRow}>
                        <Text style={styles.statLabel}>Title:</Text>
                        <Text style={styles.statValue}>{heroTitle}</Text>
                    </View>
                    <View style={styles.statRow}>
                        <Text style={styles.statLabel}>Experience:</Text>
                        <Text style={styles.statValue}>{experience} / {expForNextLevel} XP</Text>
                    </View>
                    <View style={styles.xpBarContainer}>
                         <View style={[styles.xpBar, { width: `${levelProgressPercent}%` }]} />
                    </View>
                </View>

                <View style={styles.section}>
                    <Text style={styles.sectionTitle}>Resources</Text>
                    <View style={styles.statRow}>
                        <Text style={styles.statLabel}>⚡ Energy:</Text>
                        <Text style={styles.statValue}>{energy} / {maxEnergy}</Text>
                    </View>
                    <View style={styles.statRow}>
                        <Text style={styles.statLabel}>✊ Power:</Text>
                        <Text style={styles.statValue}>{totalPower}</Text>
                    </View>
                </View>

                <View style={styles.section}>
                    <Text style={styles.sectionTitle}>Streaks</Text>
                     <View style={styles.statRow}>
                        <Text style={styles.statLabel}>Current Workout Streak:</Text>
                        <Text style={styles.statValue}>{currentStreak} days</Text>
                    </View>
                     <View style={styles.statRow}>
                        <Text style={styles.statLabel}>Longest Streak:</Text>
                        <Text style={styles.statValue}>{longestStreak} days</Text>
                    </View>
                </View>

            </ScrollView>
        </SafeAreaView>
    );
};

// --- Styles --- (Styles remain the same as the previous corrected version)
const styles = StyleSheet.create({ /* ... styles omitted for brevity ... */
    safeArea: { flex: 1, backgroundColor: '#f3f4f6' },
    container: { paddingVertical: 20, paddingHorizontal: 15 },
    heading: { fontSize: 28, fontWeight: 'bold', marginBottom: 25, color: '#111827', textAlign: 'center' },
    section: { backgroundColor: '#ffffff', borderRadius: 12, padding: 18, marginBottom: 20, shadowColor: "#000", shadowOffset: { width: 0, height: 1, }, shadowOpacity: 0.18, shadowRadius: 1.00, elevation: 2, },
    sectionTitle: { fontSize: 18, fontWeight: '600', color: '#4b5563', marginBottom: 12, borderBottomWidth: 1, borderBottomColor: '#e5e7eb', paddingBottom: 6 },
    avatarSection: { alignItems: 'center', marginBottom: 20 },
    avatarImage: { width: 150, height: 150, borderRadius: 75, marginBottom: 15, backgroundColor: '#e0e7ff' },
    avatarPlaceholder: { width: 150, height: 150, borderRadius: 75, backgroundColor: '#e0e7ff', justifyContent: 'center', alignItems: 'center', marginBottom: 15 },
    nameDisplayContainer: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
    nameText: { fontSize: 22, fontWeight: 'bold', color: '#1f2937' },
    editButton: { padding: 5 },
    nameEditContainer: { flexDirection: 'row', alignItems: 'center', },
    nameInput: { flex: 1, borderBottomWidth: 1, borderBottomColor: '#d1d5db', paddingVertical: Platform.OS === 'ios' ? 8 : 4, marginRight: 10, fontSize: 20, color: '#1f2937' },
    saveButton: { marginLeft: 5, marginRight: 5},
    cancelButton: { },
    statRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 4, },
    statLabel: { fontSize: 16, color: '#374151' },
    statValue: { fontSize: 16, fontWeight: '500', color: '#1f2937' },
    xpBarContainer: { height: 8, width: '100%', backgroundColor: '#e5e7eb', borderRadius: 4, overflow: 'hidden', marginTop: 8 },
    xpBar: { height: '100%', backgroundColor: '#8b5cf6', borderRadius: 4 },
    centerContainer: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 20 }, // Added padding
    errorText: { color: 'red', textAlign: 'center' }, // Removed padding here, added to container
});

export default ProfileScreen;