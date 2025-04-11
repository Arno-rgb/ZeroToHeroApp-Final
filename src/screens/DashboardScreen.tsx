import React, { useState, useEffect, useMemo } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { fetchTodayExercises, Exercise } from '../features/exercise/exerciseSlice';
import { fetchUser } from '../features/user/userSlice';
import { RootState, AppDispatch } from '../store/store';
import {
    SafeAreaView, ScrollView, View, Text, // Ensure Text is used
    StyleSheet, Image, ActivityIndicator, TouchableOpacity,
} from 'react-native';
import IconFA from 'react-native-vector-icons/FontAwesome';
import IconMCI from 'react-native-vector-icons/MaterialCommunityIcons';
import IconMI from 'react-native-vector-icons/MaterialIcons';

// (Helper functions omitted for brevity - no direct text rendering)
const getRankLetter = (tier: number): string => { if (tier >= 4) return 'S'; if (tier === 3) return 'A'; if (tier === 2) return 'B'; if (tier === 1) return 'C'; return 'D'; };
const calculateExpForNextLevel = (level: number): number => { return Math.floor(100 * Math.pow(1.2, Math.max(1, level) - 1)); };
const getCharacterImage = (avatar: { costume: string; color: string } | undefined): string | null => { /* console.log("Dashboard Avatar Customization:", avatar); */ return null; };

const DashboardScreen: React.FC<{ navigation: any }> = ({ navigation }) => {
    const dispatch: AppDispatch = useDispatch();

    const userId = useSelector((state: RootState) => state.user.id);
    const userTier = useSelector((state: RootState) => state.user.tier ?? 0);
    const userLevel = useSelector((state: RootState) => state.user.level ?? 1);
    const userExperience = useSelector((state: RootState) => state.user.experience ?? 0);
    const userAvatar = useSelector((state: RootState) => state.user.avatarCustomization);
    const currentEnergy = useSelector((state: RootState) => state.user.energy ?? 0);
    const maxEnergy = useSelector((state: RootState) => state.user.maxEnergy ?? 100);
    const userStatus = useSelector((state: RootState) => state.user.status);
    const userError = useSelector((state: RootState) => state.user.error);

    const todayExercises = useSelector((state: RootState) => state.exercise.todayExercises || []);
    const dailyGoals = useSelector((state: RootState) => state.exercise.dailyGoals);
    const totalPower = useSelector((state: RootState) => state.exercise.totalPower ?? 0);
    const exerciseStatus = useSelector((state: RootState) => state.exercise.status);
    const exerciseError = useSelector((state: RootState) => state.exercise.error);

    useEffect(() => { if (userStatus === 'idle' && !userId) { dispatch(fetchUser()); } if (exerciseStatus === 'idle' && userId) { dispatch(fetchTodayExercises(userId)); } }, [userStatus, exerciseStatus, userId, dispatch]);

    const dailyProgress = useMemo(() => { const pushups = todayExercises.filter(ex => ex.type === 'pushup').reduce((sum, ex) => sum + (ex.count || 0), 0); const situps = todayExercises.filter(ex => ex.type === 'situp').reduce((sum, ex) => sum + (ex.count || 0), 0); const squats = todayExercises.filter(ex => ex.type === 'squat').reduce((sum, ex) => sum + (ex.count || 0), 0); const running = todayExercises.filter(ex => ex.type === 'run').reduce((sum, ex) => sum + (ex.count || 0), 0); return { pushups, situps, squats, running }; }, [todayExercises]);
    const quests = useMemo(() => [ dailyGoals?.pushups > 0 ? { name: 'Pushups', goal: dailyGoals.pushups, current: dailyProgress.pushups, icon: 'dumbbell', lib: IconFA } : null, dailyGoals?.situps > 0 ? { name: 'Situps', goal: dailyGoals.situps, current: dailyProgress.situps, icon: 'human-handsdown', lib: IconMCI } : null, dailyGoals?.squats > 0 ? { name: 'Squats', goal: dailyGoals.squats, current: dailyProgress.squats, icon: 'run', lib: IconMCI } : null, dailyGoals?.runDistance > 0 ? { name: 'Run', goal: dailyGoals.runDistance, current: dailyProgress.running, icon: 'run-fast', lib: IconMCI, unit: 'km' } : null, ].filter(q => q !== null) as { name: string, goal: number, current: number, icon: string, lib: any, unit?: string }[], [dailyGoals, dailyProgress]);
    const completedQuests = useMemo(() => quests.filter(q => q.current >= q.goal).length, [quests]);
    const rankLetter = useMemo(() => getRankLetter(userTier), [userTier]);
    const expForNextLevel = useMemo(() => calculateExpForNextLevel(userLevel), [userLevel]);
    const levelProgressPercent = useMemo(() => expForNextLevel > 0 ? Math.min(100, Math.round((userExperience / expForNextLevel) * 100)) : 0, [userExperience, expForNextLevel]);
    const rankColors: { [key: string]: string } = { C: '#0d9488', B: '#2563eb', A: '#9333ea', S: '#f97316', D: '#6b7280' };
    const rankColor = rankColors[rankLetter] || '#6b7280';

    const isLoading = (userStatus === 'loading' || (userStatus === 'idle' && !userId)) || (exerciseStatus === 'loading' && todayExercises.length === 0 && userId);
    const isError = userStatus === 'failed' || exerciseStatus === 'failed';
    const errorMsg = [userError, exerciseError].filter(Boolean).join('; ');

    if (isLoading) { return ( <View style={styles.centerContainer}> <ActivityIndicator size="large" color="#6366f1" /> </View> ); }
    if (isError) { return ( <View style={styles.centerContainer}><Text style={styles.errorText}>Error loading data: {errorMsg || 'Unknown error'}</Text></View> ); } // Wrapped
    if (!userId) { return ( <View style={styles.centerContainer}><Text>User not loaded. Try restarting the app.</Text></View> ); } // Wrapped

    const characterImageUri = getCharacterImage(userAvatar);

    return (
        <SafeAreaView style={styles.safeArea}>
            <ScrollView contentContainerStyle={styles.scrollView}>
                <View style={styles.dashboardLayout}>

                    {/* --- Top Row --- */}
                    <View style={styles.topRow}>
                        <View style={[styles.gridItem, styles.rank]}>
                            {/* All text content is inside Text components */}
                            <Text style={[styles.sectionTitle, { color: rankColor }]}>RANK</Text>
                            <Text style={[styles.rankLetter, { color: rankColor }]}>{rankLetter}</Text>
                            <View style={styles.progressBarContainer}>
                                 <View style={[styles.progressBar, { width: `${levelProgressPercent}%`, backgroundColor: rankColor }]} />
                             </View>
                            <Text style={styles.smallText}>{userExperience} / {expForNextLevel} XP</Text>
                        </View>

                        <View style={[styles.gridItem, styles.character]}>
                            {characterImageUri ? (
                                <Image source={{ uri: characterImageUri }} style={styles.avatarImage} resizeMode="contain" />
                            ) : (
                                <View style={styles.avatarPlaceholder}><Text style={{fontSize: 50}}>🦸</Text></View> // Emoji wrapped
                            )}
                        </View>

                         <View style={[styles.gridItem, styles.resources]}>
                             <Text style={styles.sectionTitle}>POWER</Text>
                             <View style={styles.resourceItem}>
                                 <IconFA name="bolt" size={24} color="#ef4444" />
                                 <Text style={[styles.resourceValue, { color: '#ef4444'}]}>{totalPower}</Text>
                             </View>
                        </View>
                    </View>

                    {/* --- Middle Row --- */}
                    <View style={styles.middleRow}>
                         <View style={[styles.gridItem, styles.quests]}>
                             <Text style={styles.sectionTitle}>DAILY QUESTS</Text>
                             <View style={styles.vstack}>
                                 {quests.length === 0 ? (
                                    <Text style={styles.infoText}>No daily goals set.</Text> // Wrapped
                                 ) : quests.map(quest => {
                                     const isComplete = quest.current >= quest.goal;
                                     const QuestIcon = quest.lib;
                                     return (
                                        <View key={quest.name} style={styles.questItem}>
                                            <View style={styles.questItemLeft}>
                                                <QuestIcon name={quest.icon} size={18} color={isComplete ? '#16a34a' : '#6b7280'} />
                                                {/* Quest name wrapped */}
                                                <Text style={[styles.questText, isComplete && styles.questCompleteText]}>
                                                    {quest.name}
                                                </Text>
                                            </View>
                                            <View style={styles.questItemRight}>
                                                 {/* Quest progress wrapped */}
                                                 <Text style={[styles.questProgress, isComplete && styles.questCompleteProgress]}>
                                                    {quest.current.toFixed(quest.unit === 'km' ? 1: 0)}/{quest.goal}{quest.unit === 'km' ? 'km' : ''}
                                                </Text>
                                                {isComplete && <IconMI name="check-circle" color="#16a34a" size={18}/>}
                                            </View>
                                        </View>
                                     );
                                 })}
                             </View>
                             {/* Quest footer wrapped */}
                             <Text style={[styles.smallText, styles.questFooter]}>
                                 {completedQuests} / {quests.length} QUESTS COMPLETED
                             </Text>
                         </View>

                         <View style={[styles.gridItem, styles.energy]}>
                             <IconMCI name="bottle-tonic-outline" size={40} color="#22d3ee" />
                             {/* Energy value and label wrapped */}
                             <Text style={[styles.energyValue, { color: '#06b6d4'}]}>{currentEnergy}</Text>
                             <Text style={styles.resourceLabel}>ENERGY</Text>
                             <View style={styles.progressBarContainer}>
                                 <View style={[styles.progressBar, { width: `${maxEnergy > 0 ? (currentEnergy/maxEnergy)*100 : 0}%`, backgroundColor: '#22d3ee' }]} />
                             </View>
                         </View>
                    </View>

                     {/* --- Bottom Row --- */}
                     <View style={styles.bottomRow}>
                         <View style={[styles.gridItem, styles.level]}>
                              <IconMCI name="account-star" size={30} color="#f97316" />
                              {/* Level value and label wrapped */}
                              <Text style={[styles.levelValue, { color: '#f97316'}]}>{userLevel}</Text>
                              <Text style={styles.resourceLabel}>LEVEL</Text>
                         </View>

                         <View style={[styles.gridItem, styles.battleButtonContainer]}>
                              <TouchableOpacity style={styles.battleButton} onPress={() => navigation.navigate('Battle')}>
                                  {/* Button text wrapped */}
                                  <Text style={styles.battleButtonText}>BATTLE</Text>
                              </TouchableOpacity>
                         </View>
                     </View>
                </View>
            </ScrollView>
        </SafeAreaView>
    );
};

// --- Styles --- (Styles remain the same as the previous corrected version)
const styles = StyleSheet.create({ /* ... styles omitted for brevity ... */
    safeArea: { flex: 1, backgroundColor: '#f3f4f6' }, scrollView: { padding: 15 }, dashboardLayout: { }, topRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 15, alignItems: 'flex-end', }, middleRow: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 15, alignItems: 'stretch', }, bottomRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', }, gridItem: { backgroundColor: '#ffffff', padding: 15, borderRadius: 12, borderWidth: 1, borderColor: '#e5e7eb', alignItems: 'center', shadowColor: "#000", shadowOffset: { width: 0, height: 1, }, shadowOpacity: 0.18, shadowRadius: 1.00, elevation: 1, }, rank: { flex: 1, marginRight: 10, paddingBottom: 10 }, character: { flex: 1.2, backgroundColor: 'transparent', borderWidth: 0, elevation: 0, shadowOpacity: 0, justifyContent: 'flex-end'}, resources: { flex: 1, marginLeft: 10, paddingBottom: 10 }, quests: { flex: 2, marginRight: 10, alignItems: 'stretch' }, energy: { flex: 1 }, level: { flex: 1, marginRight: 10 }, battleButtonContainer: { flex: 2, backgroundColor: 'transparent', borderWidth: 0, elevation: 0, shadowOpacity: 0, paddingVertical: 5 }, sectionTitle: { fontSize: 14, fontWeight: '600', color: '#4b5563', marginBottom: 8, textAlign: 'center'}, rankLetter: { fontSize: 48, fontWeight: 'bold', lineHeight: 50 }, progressBarContainer: { height: 8, width: '90%', backgroundColor: '#e5e7eb', borderRadius: 4, overflow: 'hidden', marginTop: 4 }, progressBar: { height: '100%', borderRadius: 4 }, smallText: { fontSize: 10, color: '#6b7280', textAlign: 'center' }, infoText: { color: '#6b7280', textAlign: 'center', marginVertical: 10 }, vstack: { flexDirection: 'column', width: '100%' }, questItem: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', width: '100%', paddingVertical: 4, borderBottomWidth: 1, borderBottomColor: '#f3f4f6', }, questItemLeft: { flexDirection: 'row', alignItems: 'center', flex: 1, marginRight: 5, }, questItemRight: { flexDirection: 'row', alignItems: 'center', }, questText: { fontSize: 13, color: '#374151', marginLeft: 8 }, questProgress: { fontSize: 11, fontWeight: 'bold', color: '#6b7280', marginRight: 5 }, questCompleteText: { color: '#16a34a', }, questCompleteProgress: { color: '#16a34a' }, questFooter: { marginTop: 8 }, avatarImage: { width: '100%', height: 180 }, avatarPlaceholder: { width: '100%', height: 180, backgroundColor: '#e0e7ff', borderRadius: 10, justifyContent: 'center', alignItems: 'center'}, resourceItem: { alignItems: 'center', marginTop: 5, flexDirection: 'row' }, resourceValue: { fontSize: 28, fontWeight: 'bold', marginLeft: 8 }, energyValue: { fontSize: 36, fontWeight: 'bold' }, resourceLabel: { fontSize: 14, fontWeight: 'bold', marginTop: 0 }, levelValue: { fontSize: 36, fontWeight: 'bold' }, battleButton: { backgroundColor: '#facc15', paddingVertical: 15, paddingHorizontal: 30, borderRadius: 30, shadowColor: "#000", shadowOffset: { width: 0, height: 2, }, shadowOpacity: 0.25, shadowRadius: 3.84, elevation: 5, width: '100%', alignItems: 'center', }, battleButtonText: { color: '#78350f', fontSize: 20, fontWeight: 'bold', letterSpacing: 1, }, errorText: { color: 'red', textAlign: 'center', }, centerContainer: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 20, }
});

export default DashboardScreen;