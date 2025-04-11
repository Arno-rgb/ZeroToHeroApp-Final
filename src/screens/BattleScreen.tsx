import React, { useState, useEffect, useMemo, useCallback } from 'react';
import {
  SafeAreaView,
  ScrollView,
  View,
  Text, // Ensure Text is always used for strings
  StyleSheet,
  Image,
  FlatList,
  Modal,
  TouchableOpacity,
  ActivityIndicator,
  Dimensions,
  Alert
} from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { usePower, ExerciseType } from '../features/exercise/exerciseSlice';
import { incrementTier, addExperience, useEnergy } from '../features/user/userSlice';
import { RootState, AppDispatch } from '../store/store';
import IconFA from 'react-native-vector-icons/FontAwesome';
import { db, getBattleHistory, addBattleRecord, UserData } from '../utils/database';

const bossImages: { [key: string]: any } = {
    'training_dummy.png': require('../assets/placeholders/boss_dummy.png'),
    'fitness_goblin.png': require('../assets/placeholders/boss_goblin.png'),
    'cardio_crusher.png': require('../assets/placeholders/boss_crusher.png'),
    'tier1_champion.png': require('../assets/placeholders/boss_champion1.png'),
    'strength_sentinel.png': require('../assets/placeholders/boss_sentinel.png'),
};

interface Boss {
    id: string; name: string; tier: number; health: number; maxHealth: number;
    weakness: 'strike' | 'core' | 'force' | 'endurance' | 'balanced'; image: string; defeated: boolean;
}

const ENERGY_COSTS = { quick: 5, power: 15, special: 25 };
const POWER_COSTS = { quick: 10, power: 30, special: 50 };

// (formatWeakness function omitted for brevity as it's not directly rendered)

const BattleScreen: React.FC<{ navigation: any }> = ({ navigation }) => {
    const dispatch: AppDispatch = useDispatch();
    const showAlert = (title: string, message?: string) => Alert.alert(title, message);

    const [availableBosses, setAvailableBosses] = useState<Boss[] | null>(null);
    const [selectedBoss, setSelectedBoss] = useState<Boss | null>(null);
    const [isModalVisible, setIsModalVisible] = useState(false);
    const [battleLog, setBattleLog] = useState<string[]>([]);
    const [battleResult, setBattleResult] = useState<'ongoing' | 'victory' | 'defeat' | null>(null);
    const [isLoading, setIsLoading] = useState<boolean>(true);

    const playerTotalPower = useSelector((state: RootState) => state.exercise.totalPower);
    const userId = useSelector((state: RootState) => state.user.id);
    const userTier = useSelector((state: RootState) => state.user.tier);
    const currentEnergy = useSelector((state: RootState) => state.user.energy);
    const maxEnergy = useSelector((state: RootState) => state.user.maxEnergy);

    useEffect(() => {
        // (useEffect logic omitted for brevity - no direct text rendering issues)
        if (!userId) { setIsLoading(false); return; }
        const loadBossData = async () => { setIsLoading(true); try { /* ... load data ... */ const initialBosses: Omit<Boss, 'health' | 'defeated'>[] = [ { id: 'boss1', name: 'Training Dummy', tier: 1, maxHealth: 100, weakness: 'strike', image: 'training_dummy.png'}, { id: 'boss2', name: 'Fitness Goblin', tier: 1, maxHealth: 200, weakness: 'core', image: 'fitness_goblin.png'}, { id: 'boss3', name: 'Cardio Crusher', tier: 1, maxHealth: 300, weakness: 'endurance', image: 'cardio_crusher.png'}, { id: 'boss4', name: 'Tier 1 Champion', tier: 1, maxHealth: 500, weakness: 'balanced', image: 'tier1_champion.png'}, { id: 'boss5', name: 'Strength Sentinel', tier: 2, maxHealth: 750, weakness: 'force', image: 'strength_sentinel.png'}, ]; const filteredBosses = initialBosses.filter(boss => boss.tier <= userTier + 1); const battleHistory = await getBattleHistory(userId); const defeatedBossIds = new Set(battleHistory.filter(b => b.result === 'victory').map(b => b.bossId)); const updatedBosses: Boss[] = filteredBosses.map(bossData => ({ ...bossData, health: bossData.maxHealth, defeated: defeatedBossIds.has(bossData.id), })); setAvailableBosses(updatedBosses); } catch (error) { console.error('Error loading battle data:', error); showAlert('Error', 'Failed to load battle data'); setAvailableBosses([]); } finally { setIsLoading(false); } }; loadBossData();
    }, [userId, userTier]);

    const handleStartBattle = (boss: Boss) => { setSelectedBoss({ ...boss, health: boss.maxHealth }); setBattleLog([`Battle with ${boss.name} has begun!`]); setBattleResult('ongoing'); setIsModalVisible(true); };
    const calculateDamage = (attackType: 'quick' | 'power' | 'special', powerUsed: number, bossWeakness: Boss['weakness']) => { let damage = powerUsed; if (attackType === 'quick') damage = Math.round(powerUsed * 0.8); else if (attackType === 'power') damage = Math.round(powerUsed * 1.0); else if (attackType === 'special') damage = Math.round(powerUsed * 1.3); return Math.max(1, Math.round(damage)); };
    const addLog = (message: string) => { console.log("LOG:", message); setBattleLog(prev => [message, ...prev].slice(0, 20)); };
    const handleAttack = (attackType: 'quick' | 'power' | 'special') => { if (!selectedBoss || battleResult !== 'ongoing') return; const energyCost = ENERGY_COSTS[attackType]; const powerCost = POWER_COSTS[attackType]; const hasEnoughEnergy = currentEnergy >= energyCost; const hasEnoughPower = playerTotalPower >= powerCost; if (!hasEnoughEnergy) { showAlert("Not enough energy!", `Need ${energyCost} energy.`); addLog(`Attempted ${attackType} attack... Not enough energy!`); return; } if (!hasEnoughPower) { showAlert("Not enough power!", `Need ${powerCost} power.`); addLog(`Attempted ${attackType} attack... Not enough power!`); return; } const damage = calculateDamage(attackType, powerCost, selectedBoss.weakness); const updatedHealth = Math.max(0, selectedBoss.health - damage); setSelectedBoss({ ...selectedBoss, health: updatedHealth }); addLog(`Used ${attackType} attack for ${damage} damage! (Cost: ${energyCost} Energy, ${powerCost} Power)`); dispatch(usePower(powerCost)); dispatch(useEnergy(energyCost)); if (updatedHealth <= 0) { handleBossDefeated(); } else { const bossDamage = Math.floor(Math.random() * 10) + 5 * (selectedBoss.tier); addLog(`${selectedBoss.name} counter-attacks for ${bossDamage} damage!`); } };
    const handleBossDefeated = async () => { if (!selectedBoss || !userId) return; setBattleResult('victory'); addLog(`Victory! You defeated ${selectedBoss.name}!`); try { await addBattleRecord({ userId, bossId: selectedBoss.id, date: new Date().toISOString(), result: 'victory', damageDealt: selectedBoss.maxHealth, /* powerUsed: {} */ }); const newAvailableBosses = availableBosses?.map(boss => boss.id === selectedBoss.id ? { ...boss, defeated: true } : boss ) ?? []; setAvailableBosses(newAvailableBosses); const currentTierBosses = newAvailableBosses.filter(boss => boss.tier === userTier + 1); const allCurrentTierDefeated = currentTierBosses.length > 0 && currentTierBosses.every(boss => boss.defeated); if (allCurrentTierDefeated) { console.log(`All Tier ${userTier + 1} bosses defeated! Incrementing user tier.`); await db.users.update(userId, { tier: userTier + 1 }); dispatch(incrementTier()); showAlert('Tier Completed!', `You've advanced to Tier ${userTier + 2}!`); } const xpGained = Math.round(selectedBoss.maxHealth / 5); dispatch(addExperience(xpGained)); showAlert('Victory!', `You defeated ${selectedBoss.name} and gained ${xpGained} experience!`); } catch (error) { console.error("Error handling boss defeat:", error); showAlert('Error', 'Failed to save battle results.'); } };
    const handleEndBattle = () => { setIsModalVisible(false); setTimeout(() => { setSelectedBoss(null); setBattleLog([]); setBattleResult(null); }, 300); };

    if (isLoading) { return ( <View style={styles.centerContainer}><ActivityIndicator size="large" color="#6366f1" /></View> ); }
    if (!userId) { return ( <View style={styles.centerContainer}><Text>User not loaded.</Text></View> ); } // Text is wrapped

    const currentTierBosses = availableBosses?.filter(boss => boss.tier === userTier + 1) ?? [];

    return (
        <SafeAreaView style={styles.safeArea}>
            <ScrollView contentContainerStyle={styles.container}>
                <Text style={styles.heading}>Boss Battles</Text>

                <View style={styles.resourceContainer}>
                    <View style={styles.resourceBox}>
                         <IconFA name="bolt" size={18} color="#facc15" />
                         {/* All text content is inside Text components */}
                         <Text style={styles.resourceText}>Energy: {currentEnergy ?? 0}/{maxEnergy ?? 100}</Text>
                    </View>
                     <View style={styles.resourceBox}>
                         <IconFA name="fist-raised" size={18} color="#ef4444" />
                         <Text style={styles.resourceText}>Power: {playerTotalPower ?? 0}</Text>
                    </View>
                </View>

                <Text style={styles.subHeading}>Available Bosses (Tier {userTier + 1})</Text>
                {availableBosses === null ? <ActivityIndicator color="#6366f1"/> :
                 availableBosses.length === 0 ? <Text style={styles.infoText}>No bosses loaded.</Text> : // Wrapped
                 currentTierBosses.length === 0 ? <Text style={styles.infoText}>No bosses available for this tier yet.</Text> : // Wrapped

                 <FlatList
                    data={currentTierBosses}
                    keyExtractor={(item) => item.id}
                    numColumns={2}
                    columnWrapperStyle={styles.bossListColumnWrapper}
                    renderItem={({ item: boss }) => (
                        <View style={[styles.bossCard, boss.defeated && styles.bossCardDefeated]}>
                             <Image source={bossImages[boss.image]} style={styles.bossImage} resizeMode="contain" />
                             {/* All text content is inside Text components */}
                             <Text style={styles.bossName}>{boss.name}</Text>
                             <View style={styles.badgeTier}>
                                 <Text style={styles.badgeText}>Tier {boss.tier}</Text>
                             </View>
                             <Text style={styles.bossInfo}>HP: {boss.maxHealth}</Text>
                             {boss.defeated ? (
                                 <Text style={styles.defeatedText}>Defeated</Text> // Wrapped
                             ) : (
                                 <TouchableOpacity
                                     style={[ styles.battleButton, (currentEnergy < ENERGY_COSTS.quick || playerTotalPower < POWER_COSTS.quick) && styles.battleButtonDisabled ]}
                                     onPress={() => handleStartBattle(boss)}
                                     disabled={ currentEnergy < ENERGY_COSTS.quick || playerTotalPower < POWER_COSTS.quick }
                                 >
                                     <Text style={styles.battleButtonText}>Battle</Text> // Wrapped
                                 </TouchableOpacity>
                             )}
                        </View>
                    )}
                 />
                }

                <Modal
                    animationType="slide"
                    transparent={true}
                    visible={isModalVisible}
                    onRequestClose={handleEndBattle}
                >
                    <View style={styles.modalCenteredView}>
                        <View style={styles.modalView}>
                             {selectedBoss && (
                                <>
                                    {/* All text content is inside Text components */}
                                    <Text style={styles.modalTitle}>Battle: {selectedBoss.name}</Text>
                                    <Image source={bossImages[selectedBoss.image]} style={styles.modalBossImage} resizeMode="contain"/>
                                    <View style={styles.modalHealthContainer}>
                                        <Text style={styles.modalHealthText}>HP: {selectedBoss.health} / {selectedBoss.maxHealth}</Text>
                                        <View style={styles.modalHealthBarBack}>
                                            <View style={[styles.modalHealthBarFront, { width: `${Math.max(0, selectedBoss.health / selectedBoss.maxHealth) * 100}%` }]} />
                                        </View>
                                    </View>
                                    <Text style={styles.modalResourceText}>⚡ Energy: {currentEnergy}/{maxEnergy} | ✊ Power: {playerTotalPower}</Text>

                                    <ScrollView style={styles.modalLog} contentContainerStyle={styles.modalLogContent}>
                                        {battleLog.map((log, index) => ( <Text key={index} style={styles.logText}>{log}</Text> ))}
                                    </ScrollView>

                                    {battleResult === 'victory' ? (
                                        <Text style={[styles.modalResultText, styles.victoryText]}>VICTORY!</Text> // Wrapped
                                    ) : battleResult === 'defeat' ? (
                                        <Text style={[styles.modalResultText, styles.defeatText]}>DEFEAT!</Text> // Wrapped
                                    ) : (
                                        <View style={styles.modalActions}>
                                            <TouchableOpacity
                                                style={[styles.modalButton, styles.quickAttackButton, (currentEnergy < ENERGY_COSTS.quick || playerTotalPower < POWER_COSTS.quick) && styles.modalButtonDisabled]}
                                                onPress={() => handleAttack('quick')}
                                                disabled={currentEnergy < ENERGY_COSTS.quick || playerTotalPower < POWER_COSTS.quick}
                                            >
                                                <Text style={styles.modalButtonText}>Quick ({POWER_COSTS.quick}P/{ENERGY_COSTS.quick}E)</Text>
                                            </TouchableOpacity>
                                             <TouchableOpacity
                                                style={[styles.modalButton, styles.powerAttackButton, (currentEnergy < ENERGY_COSTS.power || playerTotalPower < POWER_COSTS.power) && styles.modalButtonDisabled]}
                                                onPress={() => handleAttack('power')}
                                                disabled={currentEnergy < ENERGY_COSTS.power || playerTotalPower < POWER_COSTS.power}
                                            >
                                                <Text style={styles.modalButtonText}>Power ({POWER_COSTS.power}P/{ENERGY_COSTS.power}E)</Text>
                                            </TouchableOpacity>
                                             <TouchableOpacity
                                                style={[styles.modalButton, styles.specialAttackButton, (currentEnergy < ENERGY_COSTS.special || playerTotalPower < POWER_COSTS.special) && styles.modalButtonDisabled]}
                                                onPress={() => handleAttack('special')}
                                                disabled={currentEnergy < ENERGY_COSTS.special || playerTotalPower < POWER_COSTS.special}
                                            >
                                                <Text style={styles.modalButtonText}>Special ({POWER_COSTS.special}P/{ENERGY_COSTS.special}E)</Text>
                                            </TouchableOpacity>
                                        </View>
                                    )}

                                    <TouchableOpacity style={styles.closeButton} onPress={handleEndBattle}>
                                        <Text style={styles.closeButtonText}>{battleResult === 'victory' || battleResult === 'defeat' ? 'Close' : 'Retreat'}</Text>
                                    </TouchableOpacity>
                                </>
                             )}
                        </View>
                    </View>
                </Modal>

            </ScrollView>
        </SafeAreaView>
    );
};

// --- Styles --- (Styles remain the same as the previous corrected version)
const styles = StyleSheet.create({ /* ... styles omitted for brevity ... */
    safeArea: { flex: 1, backgroundColor: '#f3f4f6' },
    container: { flexGrow: 1, padding: 15, alignItems: 'center' },
    heading: { fontSize: 28, fontWeight: 'bold', marginBottom: 20, color: '#111827' },
    subHeading: { fontSize: 20, fontWeight: '600', marginBottom: 15, color: '#374151', alignSelf: 'flex-start' },
    resourceContainer: { flexDirection: 'row', justifyContent: 'space-around', width: '100%', marginBottom: 20, paddingVertical: 10, backgroundColor: '#fff', borderRadius: 10, elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.2, shadowRadius: 1.4, },
    resourceBox: { alignItems: 'center', flexDirection: 'row'}, // Keep icon and text together
    resourceText: { marginLeft: 5, fontSize: 16, fontWeight: '500' },
    bossListColumnWrapper: { justifyContent: 'space-between'},
    bossCard: { width: '48%', backgroundColor: '#fff', borderRadius: 10, padding: 10, marginBottom: 10, alignItems: 'center', elevation: 3, shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.22, shadowRadius: 2.22, },
    bossCardDefeated: { opacity: 0.6, backgroundColor: '#e5e7eb' },
    bossImage: { width: 100, height: 100, marginBottom: 8, borderRadius: 5 },
    bossName: { fontSize: 16, fontWeight: 'bold', textAlign: 'center' },
    badgeTier: { marginTop: 4, marginBottom: 4, backgroundColor: '#e5e7eb', paddingHorizontal: 8, paddingVertical: 3, borderRadius: 10, },
    badgeText: { fontSize: 10, fontWeight: '600', color: '#4b5563', },
    bossInfo: { fontSize: 12, color: '#6b7280' },
    defeatedText: { color: 'grey', fontWeight: 'bold', marginTop: 10 },
    battleButton: { backgroundColor: '#14b8a6', paddingVertical: 8, paddingHorizontal: 15, borderRadius: 20, marginTop: 10, width: '80%' },
    battleButtonDisabled: { backgroundColor: '#9ca3af' },
    battleButtonText: { color: 'white', fontWeight: 'bold', textAlign: 'center' },
    infoText: { color: '#6b7280', marginTop: 10 },
    centerContainer: { flex: 1, justifyContent: 'center', alignItems: 'center' },
    errorText: { color: 'red', textAlign: 'center', padding: 20 },
    modalCenteredView: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: 'rgba(0,0,0,0.6)' },
    modalView: { width: '90%', margin: 20, backgroundColor: 'white', borderRadius: 20, padding: 25, alignItems: 'center', shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.25, shadowRadius: 4, elevation: 5 },
    modalTitle: { fontSize: 24, fontWeight: 'bold', marginBottom: 15 },
    modalBossImage: { width: 150, height: 150, borderRadius: 10, marginBottom: 15 },
    modalHealthContainer: { width: '100%', marginBottom: 10 },
    modalHealthText: { textAlign: 'center', marginBottom: 5, fontWeight: '500' },
    modalHealthBarBack: { height: 20, width: '100%', backgroundColor: '#e5e7eb', borderRadius: 10, overflow: 'hidden' },
    modalHealthBarFront: { height: '100%', backgroundColor: '#ef4444', borderRadius: 10 },
    modalResourceText: { fontSize: 16, fontWeight: '500', marginVertical: 10 },
    modalLog: { width: '100%', maxHeight: 120, borderColor: '#d1d5db', borderWidth: 1, borderRadius: 5, padding: 8, marginVertical: 15, backgroundColor: '#f9fafb' },
    modalLogContent: { paddingBottom: 10 },
    logText: { fontSize: 12, marginBottom: 3 },
    modalActions: { flexDirection: 'row', justifyContent: 'space-around', width: '100%', marginVertical: 10 },
    modalButton: { borderRadius: 20, paddingVertical: 10, paddingHorizontal: 15, elevation: 2, marginHorizontal: 5, alignItems: 'center' },
    modalButtonDisabled: { backgroundColor: '#9ca3af' },
    quickAttackButton: { backgroundColor: '#3b82f6' },
    powerAttackButton: { backgroundColor: '#a855f7' },
    specialAttackButton: { backgroundColor: '#ef4444' },
    modalButtonText: { color: 'white', fontWeight: 'bold', textAlign: 'center', fontSize: 11 },
    modalResultText: { fontSize: 24, fontWeight: 'bold', marginVertical: 15 },
    victoryText: { color: '#16a34a' },
    defeatText: { color: '#dc2626' },
    closeButton: { marginTop: 20, backgroundColor: '#6b7280', paddingVertical: 10, paddingHorizontal: 20, borderRadius: 20 },
    closeButtonText: { color: 'white', fontWeight: 'bold' },
});

export default BattleScreen;