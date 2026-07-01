import React, { useEffect, useMemo, useState } from 'react';
import {
  FaArrowLeft,
  FaArrowRight,
  FaCalendarAlt,
  FaChartBar,
  FaCheck,
  FaDumbbell,
  FaFire,
  FaHome,
  FaPause,
  FaPlay,
  FaStar,
  FaTrophy,
  FaUser,
  FaWhatsapp,
} from 'react-icons/fa';
import { coachConfig, type CoachProgramme, type ExerciseVisualKind, type ProgrammeExercise } from '../coachConfig';

type View = 'today' | 'workout' | 'quest' | 'battle' | 'hero' | 'progress' | 'coach';
type AttributeKey = 'power' | 'vitality' | 'agility' | 'endurance' | 'control';
type EquipmentSlot = 'weapon' | 'armor' | 'charm';
type EquipmentRarity = 'Common' | 'Rare' | 'Epic';
type ItemTradeStatus = 'Tradable' | 'Bind on equip' | 'Bound' | 'Account-bound';
type HeroClassId = 'adventurer' | 'vanguard' | 'berserker' | 'ranger' | 'monk' | 'juggernaut';

type HeroStats = Record<AttributeKey, number>;
type StatReward = Partial<Record<AttributeKey, number>>;
type LegacyHeroStats = Partial<Record<AttributeKey | 'fortitude' | 'might' | 'discipline' | 'resolve', number>>;

type EquipmentItem = {
  id: string;
  name: string;
  slot: EquipmentSlot;
  rarity: EquipmentRarity;
  description: string;
  bonuses: Partial<HeroStats>;
  origin: string;
  tradeStatus: ItemTradeStatus;
  upgradeLevel: number;
};

type HeroClass = {
  id: HeroClassId;
  name: string;
  role: string;
  description: string;
  requirement: string;
  bonuses: Partial<HeroStats>;
};

type HeroState = {
  level: number;
  xp: number;
  gold: number;
  stats: HeroStats;
  battleEnergy: number;
  trainingEnergy: number;
  materials: number;
  chestFragments: number;
  earnedChests: number;
  openedChests: number;
  currentEnemyIndex: number;
  defeatedEnemyIds: string[];
  unlockedAbilityIds: string[];
  equippedAbilityIds: string[];
  inventory: EquipmentItem[];
  equippedItemIds: Partial<Record<EquipmentSlot, string>>;
  unlockedClassIds: HeroClassId[];
  activeClassId: HeroClassId;
  equipmentName: string;
  rewardLog: string[];
};

type DemoProgress = {
  completedExerciseIds: string[];
  completedDayIds: string[];
  programmeStartedAt: string;
  hero: HeroState;
};

type Ability = {
  id: string;
  name: string;
  tag: string;
  description: string;
  requirement: string;
  energyCost: number;
  cooldown: number;
};

type Enemy = {
  id: string;
  name: string;
  chapter: string;
  hp: number;
  armour: number;
  attack: number;
  rewardMaterials: number;
  rewardText: string;
  boss?: boolean;
};

type BattleState = {
  status: 'idle' | 'active' | 'victory' | 'defeat';
  enemyId: string;
  heroHp: number;
  enemyHp: number;
  enemyArmour: number;
  heroEnergy: number;
  maxHeroEnergy: number;
  resolveCharge: number;
  momentum: number;
  breakTurns: number;
  exhaustTurns: number;
  bleedTurns: number;
  abilityCooldowns: Record<string, number>;
  tonicUsed: boolean;
  log: string[];
};

type StatChange = {
  attribute: AttributeKey;
  before: number;
  after: number;
  delta: number;
};

type TrainingRewardNotice = {
  title: string;
  subtitle?: string;
  statRewards?: StatReward;
  statChanges?: StatChange[];
  effectLines?: string[];
  primaryAction: string;
  nextView?: View;
};

type BeforeInstallPromptEvent = Event & {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed'; platform: string }>;
};

const storageKey = 'coach-demo-progress-v3';
const attributeKeys: AttributeKey[] = ['power', 'vitality', 'agility', 'endurance', 'control'];

const attributeLabels: Record<AttributeKey, string> = {
  power: 'Power',
  vitality: 'Vitality',
  agility: 'Agility',
  endurance: 'Endurance',
  control: 'Control',
};

const abilityDefinitions: Ability[] = [
  {
    id: 'power-strike',
    name: 'Power Strike',
    tag: 'Momentum',
    description: 'A heavy strike that scales with Power and builds momentum.',
    requirement: 'Complete any exercise.',
    energyCost: 2,
    cooldown: 1,
  },
  {
    id: 'shield-crush',
    name: 'Shield Crush',
    tag: 'Break',
    description: 'Damages armour and applies BREAK for two enemy turns.',
    requirement: 'Complete a full workout.',
    energyCost: 3,
    cooldown: 2,
  },
  {
    id: 'execution-strike',
    name: 'Execution Strike',
    tag: 'Combo',
    description: 'Deals double damage to enemies affected by BREAK.',
    requirement: 'Complete three workouts.',
    energyCost: 4,
    cooldown: 2,
  },
  {
    id: 'wind-step',
    name: 'Wind Step',
    tag: 'Exhaust',
    description: 'A fast strike that slows the enemy next turn.',
    requirement: 'Reach Agility 18.',
    energyCost: 3,
    cooldown: 1,
  },
  {
    id: 'unbroken-resolve',
    name: 'Unbroken Guard',
    tag: 'Guard',
    description: 'Guarding stores extra focus after taking damage.',
    requirement: 'Complete seven workouts.',
    energyCost: 2,
    cooldown: 3,
  },
  {
    id: 'titan-breaker',
    name: 'Titan Breaker',
    tag: 'Ultimate',
    description: 'Spend full focus to ignore armour and strike twice.',
    requirement: 'Defeat Gatekeeper Brakk.',
    energyCost: 0,
    cooldown: 0,
  },
];

const classDefinitions: HeroClass[] = [
  {
    id: 'adventurer',
    name: 'Adventurer',
    role: 'Balanced starter',
    description: 'A flexible loadout with no specialisation penalty.',
    requirement: 'Starting class.',
    bonuses: {},
  },
  {
    id: 'vanguard',
    name: 'Vanguard',
    role: 'Armour and counters',
    description: 'Stronger guarding, higher Vitality, and more durable battles.',
    requirement: 'Reach Vitality 18 and complete one workout.',
    bonuses: { vitality: 4, control: 2 },
  },
  {
    id: 'berserker',
    name: 'Berserker',
    role: 'Critical damage',
    description: 'High Power and momentum-focused damage.',
    requirement: 'Reach Power 20.',
    bonuses: { power: 5, vitality: 1 },
  },
  {
    id: 'ranger',
    name: 'Ranger',
    role: 'Speed and bleed',
    description: 'Higher Agility, faster energy recovery, and bleed pressure.',
    requirement: 'Reach Endurance 18 or Agility 18.',
    bonuses: { agility: 4, endurance: 2 },
  },
  {
    id: 'monk',
    name: 'Monk',
    role: 'Control and recovery',
    description: 'Control-focused status resistance and energy control.',
    requirement: 'Reach Control 18 or complete three workouts.',
    bonuses: { control: 4, endurance: 2 },
  },
  {
    id: 'juggernaut',
    name: 'Juggernaut',
    role: 'Health and stuns',
    description: 'Leg-strength path with high health and heavy hits.',
    requirement: 'Reach Vitality 24 and Endurance 18.',
    bonuses: { vitality: 5, endurance: 2 },
  },
];

const starterEquipment: EquipmentItem[] = [
  {
    id: 'training-blade',
    name: 'Training Blade',
    slot: 'weapon',
    rarity: 'Common',
    description: 'A blunt practice blade with no earned training power yet.',
    bonuses: {},
    origin: 'Starter kit',
    tradeStatus: 'Account-bound',
    upgradeLevel: 0,
  },
  {
    id: 'worn-tunic',
    name: 'Worn Tunic',
    slot: 'armor',
    rarity: 'Common',
    description: 'Light starter armour with no earned training bonus yet.',
    bonuses: {},
    origin: 'Starter kit',
    tradeStatus: 'Account-bound',
    upgradeLevel: 0,
  },
  {
    id: 'resolve-thread',
    name: 'Control Thread',
    slot: 'charm',
    rarity: 'Common',
    description: 'A simple charm tied before the first training vow.',
    bonuses: {},
    origin: 'Starter kit',
    tradeStatus: 'Account-bound',
    upgradeLevel: 0,
  },
];

const enemyDrops: Record<string, EquipmentItem> = {
  slime: {
    id: 'slime-core-ring',
    name: 'Slime Core Ring',
    slot: 'charm',
    rarity: 'Common',
    description: 'A soft green ring that improves recovery rhythm.',
    bonuses: { endurance: 2 },
    origin: 'Gate Slime drop',
    tradeStatus: 'Bind on equip',
    upgradeLevel: 0,
  },
  'cave-rat': {
    id: 'fang-knife',
    name: 'Fang Knife',
    slot: 'weapon',
    rarity: 'Common',
    description: 'Quick and light, useful for fast attacks.',
    bonuses: { agility: 2, power: 1 },
    origin: 'Cave Rat drop',
    tradeStatus: 'Bind on equip',
    upgradeLevel: 0,
  },
  'goblin-scout': {
    id: 'scout-wraps',
    name: 'Scout Wraps',
    slot: 'armor',
    rarity: 'Rare',
    description: 'Flexible wraps that favour evasive movement.',
    bonuses: { agility: 3, endurance: 1 },
    origin: 'Goblin Scout drop',
    tradeStatus: 'Bind on equip',
    upgradeLevel: 0,
  },
  'goblin-guard': {
    id: 'guard-plate',
    name: 'Guard Plate',
    slot: 'armor',
    rarity: 'Rare',
    description: 'Heavy cracked plate that improves guarding.',
    bonuses: { vitality: 4, control: 1 },
    origin: 'Goblin Guard drop',
    tradeStatus: 'Bind on equip',
    upgradeLevel: 0,
  },
  'bone-warden': {
    id: 'warden-sigil',
    name: 'Warden Sigil',
    slot: 'charm',
    rarity: 'Rare',
    description: 'A bone-carved sigil that sharpens control.',
    bonuses: { control: 3, power: 1 },
    origin: 'Bone Warden drop',
    tradeStatus: 'Bind on equip',
    upgradeLevel: 0,
  },
  'gatekeeper-brakk': {
    id: 'gatekeeper-pauldron',
    name: 'Gatekeeper Pauldron',
    slot: 'armor',
    rarity: 'Epic',
    description: 'The first boss trophy. Heavy enough to feel earned.',
    bonuses: { vitality: 6, control: 3 },
    origin: 'Gatekeeper Brakk boss drop',
    tradeStatus: 'Bind on equip',
    upgradeLevel: 0,
  },
};

const campaignEnemies: Enemy[] = [
  {
    id: 'slime',
    name: 'Gate Slime',
    chapter: 'Chapter 1: The Broken Gate',
    hp: 46,
    armour: 2,
    attack: 8,
    rewardMaterials: 3,
    rewardText: 'Slime Core',
  },
  {
    id: 'cave-rat',
    name: 'Cave Rat',
    chapter: 'Chapter 1: The Broken Gate',
    hp: 58,
    armour: 3,
    attack: 10,
    rewardMaterials: 4,
    rewardText: 'Fang Scraps',
  },
  {
    id: 'goblin-scout',
    name: 'Goblin Scout',
    chapter: 'Chapter 1: The Broken Gate',
    hp: 72,
    armour: 4,
    attack: 12,
    rewardMaterials: 5,
    rewardText: 'Scout Buckle',
  },
  {
    id: 'goblin-guard',
    name: 'Goblin Guard',
    chapter: 'Chapter 1: The Broken Gate',
    hp: 88,
    armour: 7,
    attack: 13,
    rewardMaterials: 6,
    rewardText: 'Cracked Guard Plate',
  },
  {
    id: 'bone-warden',
    name: 'Bone Warden',
    chapter: 'Chapter 1: The Broken Gate',
    hp: 104,
    armour: 8,
    attack: 15,
    rewardMaterials: 8,
    rewardText: 'Warden Sigil',
  },
  {
    id: 'gatekeeper-brakk',
    name: 'Gatekeeper Brakk',
    chapter: 'Chapter 1 Boss',
    hp: 142,
    armour: 12,
    attack: 18,
    rewardMaterials: 15,
    rewardText: 'Gatekeeper Pauldron',
    boss: true,
  },
];

function createDefaultHero(): HeroState {
  return {
    level: 1,
    xp: 0,
    gold: 0,
    stats: {
      power: 0,
      vitality: 0,
      agility: 0,
      endurance: 0,
      control: 0,
    },
    battleEnergy: 0,
    trainingEnergy: 0,
    materials: 0,
    chestFragments: 0,
    earnedChests: 0,
    openedChests: 0,
    currentEnemyIndex: 0,
    defeatedEnemyIds: [],
    unlockedAbilityIds: ['power-strike'],
    equippedAbilityIds: ['power-strike', 'shield-crush', 'execution-strike'],
    inventory: starterEquipment,
    equippedItemIds: {
      weapon: 'training-blade',
      armor: 'worn-tunic',
      charm: 'resolve-thread',
    },
    unlockedClassIds: ['adventurer'],
    activeClassId: 'adventurer',
    equipmentName: 'Training Blade',
    rewardLog: ['New hero awakened: Unranked Adventurer'],
  };
}

const defaultProgress: DemoProgress = {
  completedExerciseIds: [],
  completedDayIds: [],
  programmeStartedAt: new Date().toISOString(),
  hero: createDefaultHero(),
};

export function CoachDemoApp(): React.JSX.Element {
  const [activeView, setActiveView] = useState<View>('today');
  const [selectedProgrammeId, setSelectedProgrammeId] = useState(coachConfig.programmes[0].id);
  const [selectedDay, setSelectedDay] = useState(1);
  const [activeExerciseId, setActiveExerciseId] = useState<string | null>(coachConfig.programmes[0].days[0]?.exercises[0]?.id ?? null);
  const [progress, setProgress] = useState<DemoProgress>(() => loadProgress());
  const [installPrompt, setInstallPrompt] = useState<BeforeInstallPromptEvent | null>(null);
  const [remainingSeconds, setRemainingSeconds] = useState(coachConfig.programmes[0].days[0]?.exercises[0]?.restSeconds ?? 0);
  const [timerRunning, setTimerRunning] = useState(false);
  const [battle, setBattle] = useState<BattleState>(() => createIdleBattle(progress.hero));
  const [rewardQueue, setRewardQueue] = useState<TrainingRewardNotice[]>([]);
  const [workoutStartStats, setWorkoutStartStats] = useState<HeroStats | null>(null);

  const selectedProgramme = coachConfig.programmes.find(programme => programme.id === selectedProgrammeId) ?? coachConfig.programmes[0];
  const selectedProgrammeDay = selectedProgramme.days.find(day => day.day === selectedDay) ?? selectedProgramme.days[0];
  const activeExercise = selectedProgrammeDay.exercises.find(exercise => exercise.id === activeExerciseId) ?? selectedProgrammeDay.exercises[0];
  const activeExerciseIndex = selectedProgrammeDay.exercises.findIndex(exercise => exercise.id === activeExercise.id);
  const selectedProgrammeExerciseIds = new Set(selectedProgramme.days.flatMap(day => day.exercises.map(exercise => exercise.id)));
  const totalExerciseCount = selectedProgramme.days.reduce((sum, day) => sum + day.exercises.length, 0);
  const completedExerciseCount = progress.completedExerciseIds.filter(id => selectedProgrammeExerciseIds.has(id)).length;
  const completedDayCount = progress.completedDayIds.filter(dayId => dayId.startsWith(`${selectedProgramme.id}-`)).length;
  const completionPercent = Math.round((completedExerciseCount / totalExerciseCount) * 100);
  const currentEnemy = campaignEnemies[Math.min(progress.hero.currentEnemyIndex, campaignEnemies.length - 1)];
  const campaignComplete = progress.hero.currentEnemyIndex >= campaignEnemies.length;
  const todayPercent = Math.round(
    (selectedProgrammeDay.exercises.filter(exercise => progress.completedExerciseIds.includes(exercise.id)).length /
      selectedProgrammeDay.exercises.length) *
      100
  );
  const whatsappUrl = useMemo(() => {
    const message = encodeURIComponent(coachConfig.whatsappMessage);
    return `https://wa.me/${coachConfig.whatsappNumber}?text=${message}`;
  }, []);
  const activeRewardNotice = rewardQueue[0] ?? null;

  useEffect(() => {
    localStorage.setItem(storageKey, JSON.stringify(progress));
  }, [progress]);

  useEffect(() => {
    const handleBeforeInstallPrompt = (event: Event): void => {
      event.preventDefault();
      setInstallPrompt(event as BeforeInstallPromptEvent);
    };

    window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
    return () => window.removeEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
  }, []);

  useEffect(() => {
    const firstExercise = selectedProgrammeDay.exercises[0];
    if (!firstExercise) {
      return;
    }

    setActiveExerciseId(firstExercise.id);
    setRemainingSeconds(firstExercise.restSeconds);
    setTimerRunning(false);
  }, [selectedProgramme.id, selectedProgrammeDay.day, selectedProgrammeDay.exercises]);

  useEffect(() => {
    if (!activeExercise) {
      return;
    }

    setRemainingSeconds(activeExercise.restSeconds);
    setTimerRunning(false);
  }, [activeExercise?.id]);

  useEffect(() => {
    if (!timerRunning || remainingSeconds <= 0) {
      return;
    }

    const intervalId = window.setInterval(() => {
      setRemainingSeconds(seconds => Math.max(0, seconds - 1));
    }, 1000);

    return () => window.clearInterval(intervalId);
  }, [remainingSeconds, timerRunning]);

  const setExerciseComplete = (exercise: ProgrammeExercise): void => {
    const alreadyCompletedPreview = progress.completedExerciseIds.includes(exercise.id);
    const completedExerciseIdsPreview = alreadyCompletedPreview ? progress.completedExerciseIds : [...progress.completedExerciseIds, exercise.id];
    const dayCompletePreview = selectedProgrammeDay.exercises.every(dayExercise => completedExerciseIdsPreview.includes(dayExercise.id));
    const dayKeyPreview = getDayKey(selectedProgramme.id, selectedProgrammeDay.day);
    const newlyCompletedDayPreview = dayCompletePreview && !progress.completedDayIds.includes(dayKeyPreview);
    const completedDayIdsPreview = newlyCompletedDayPreview ? [...progress.completedDayIds, dayKeyPreview] : progress.completedDayIds;
    const trainedHeroPreview = alreadyCompletedPreview ? progress.hero : awardExerciseTraining(progress.hero, exercise);
    const heroPreview = reconcileHeroUnlocks(
      newlyCompletedDayPreview ? awardWorkoutCompletion(trainedHeroPreview, selectedProgrammeDay.title) : trainedHeroPreview,
      completedExerciseIdsPreview,
      completedDayIdsPreview
    );
    const notices = [
      ...(!alreadyCompletedPreview ? [createExerciseRewardNotice(exercise, getTrainingStatRewards(exercise))] : []),
      ...(newlyCompletedDayPreview
        ? [createWorkoutRewardNotice(selectedProgrammeDay.title, workoutStartStats ?? progress.hero.stats, heroPreview.stats)]
        : []),
    ];

    setProgress(current => {
      const alreadyCompleted = current.completedExerciseIds.includes(exercise.id);
      const completedExerciseIds = alreadyCompleted ? current.completedExerciseIds : [...current.completedExerciseIds, exercise.id];
      const dayComplete = selectedProgrammeDay.exercises.every(dayExercise => completedExerciseIds.includes(dayExercise.id));
      const dayKey = getDayKey(selectedProgramme.id, selectedProgrammeDay.day);
      const newlyCompletedDay = dayComplete && !current.completedDayIds.includes(dayKey);
      const completedDayIds = newlyCompletedDay ? [...current.completedDayIds, dayKey] : current.completedDayIds;
      const trainedHero = alreadyCompleted ? current.hero : awardExerciseTraining(current.hero, exercise);
      const hero = reconcileHeroUnlocks(newlyCompletedDay ? awardWorkoutCompletion(trainedHero, selectedProgrammeDay.title) : trainedHero, completedExerciseIds, completedDayIds);

      return {
        ...current,
        completedExerciseIds,
        completedDayIds,
        hero,
      };
    });

    if (notices.length > 0) {
      setRewardQueue(queue => [...queue, ...notices]);
    }

    if (newlyCompletedDayPreview) {
      setWorkoutStartStats(null);
    }
  };

  const startExercise = (exercise: ProgrammeExercise): void => {
    if (activeView !== 'workout') {
      setWorkoutStartStats(progress.hero.stats);
    }

    setActiveExerciseId(exercise.id);
    setRemainingSeconds(exercise.restSeconds);
    setTimerRunning(false);
    setActiveView('workout');
  };

  const selectProgramme = (programmeId: string): void => {
    const nextProgramme = coachConfig.programmes.find(programme => programme.id === programmeId);
    const firstDay = nextProgramme?.days[0];
    const firstExercise = firstDay?.exercises[0];

    if (!nextProgramme || !firstDay || !firstExercise) {
      return;
    }

    setSelectedProgrammeId(nextProgramme.id);
    setSelectedDay(firstDay.day);
    setActiveExerciseId(firstExercise.id);
    setRemainingSeconds(firstExercise.restSeconds);
    setTimerRunning(false);
    setWorkoutStartStats(null);
    setActiveView('today');
  };

  const completeSet = (): void => {
    setExerciseComplete(activeExercise);
    setRemainingSeconds(activeExercise.restSeconds);
    setTimerRunning(activeExercise.restSeconds > 0);
  };

  const goToNextExercise = (): void => {
    const nextExercise = selectedProgrammeDay.exercises[activeExerciseIndex + 1];
    if (nextExercise) {
      startExercise(nextExercise);
      return;
    }

    markDayComplete();
  };

  const markDayComplete = (): void => {
    const exerciseIdsPreview = selectedProgrammeDay.exercises.map(exercise => exercise.id);
    const newExercisesPreview = selectedProgrammeDay.exercises.filter(exercise => !progress.completedExerciseIds.includes(exercise.id));
    const completedExerciseIdsPreview = Array.from(new Set([...progress.completedExerciseIds, ...exerciseIdsPreview]));
    const dayKeyPreview = getDayKey(selectedProgramme.id, selectedProgrammeDay.day);
    const newlyCompletedDayPreview = !progress.completedDayIds.includes(dayKeyPreview);
    const completedDayIdsPreview = newlyCompletedDayPreview ? [...progress.completedDayIds, dayKeyPreview] : progress.completedDayIds;
    const trainedHeroPreview = newExercisesPreview.reduce((hero, exercise) => awardExerciseTraining(hero, exercise), progress.hero);
    const heroPreview = reconcileHeroUnlocks(
      newlyCompletedDayPreview ? awardWorkoutCompletion(trainedHeroPreview, selectedProgrammeDay.title) : trainedHeroPreview,
      completedExerciseIdsPreview,
      completedDayIdsPreview
    );
    const notices =
      newlyCompletedDayPreview && newExercisesPreview.length > 0
        ? [createWorkoutRewardNotice(selectedProgrammeDay.title, workoutStartStats ?? progress.hero.stats, heroPreview.stats)]
        : [];

    setProgress(current => {
      const exerciseIds = selectedProgrammeDay.exercises.map(exercise => exercise.id);
      const newExercises = selectedProgrammeDay.exercises.filter(exercise => !current.completedExerciseIds.includes(exercise.id));
      const completedExerciseIds = Array.from(new Set([...current.completedExerciseIds, ...exerciseIds]));
      const dayKey = getDayKey(selectedProgramme.id, selectedProgrammeDay.day);
      const newlyCompletedDay = !current.completedDayIds.includes(dayKey);
      const completedDayIds = newlyCompletedDay ? [...current.completedDayIds, dayKey] : current.completedDayIds;
      const trainedHero = newExercises.reduce((hero, exercise) => awardExerciseTraining(hero, exercise), current.hero);
      const hero = reconcileHeroUnlocks(newlyCompletedDay ? awardWorkoutCompletion(trainedHero, selectedProgrammeDay.title) : trainedHero, completedExerciseIds, completedDayIds);

      return {
        ...current,
        completedExerciseIds,
        completedDayIds,
        hero,
      };
    });

    if (notices.length > 0) {
      setRewardQueue(queue => [...queue, ...notices]);
      setWorkoutStartStats(null);
      return;
    }

    setActiveView('quest');
  };

  const resetDemo = (): void => {
    const firstExercise = selectedProgrammeDay.exercises[0];
    setProgress({ ...defaultProgress, programmeStartedAt: new Date().toISOString() });
    setBattle(createIdleBattle(defaultProgress.hero));
    setActiveExerciseId(firstExercise?.id ?? null);
    setRemainingSeconds(firstExercise?.restSeconds ?? 0);
    setTimerRunning(false);
    setRewardQueue([]);
    setWorkoutStartStats(null);
  };

  const equipItem = (itemId: string): void => {
    setProgress(current => {
      const item = current.hero.inventory.find(inventoryItem => inventoryItem.id === itemId);

      if (!item) {
        return current;
      }

      return {
        ...current,
        hero: {
          ...current.hero,
          equippedItemIds: {
            ...current.hero.equippedItemIds,
            [item.slot]: item.id,
          },
          inventory: current.hero.inventory.map(inventoryItem =>
            inventoryItem.id === item.id && inventoryItem.tradeStatus === 'Bind on equip'
              ? { ...inventoryItem, tradeStatus: 'Bound' }
              : inventoryItem
          ),
          equipmentName: item.name,
          rewardLog: [`Equipped ${item.name}.`, ...current.hero.rewardLog].slice(0, 6),
        },
      };
    });
  };

  const openEarnedChest = (): void => {
    setProgress(current => {
      if (current.hero.earnedChests <= 0) {
        return {
          ...current,
          hero: {
            ...current.hero,
            rewardLog: ['No earned chests ready. Defeat enemies to collect fragments.', ...current.hero.rewardLog].slice(0, 6),
          },
        };
      }

      const chestItem = createBrokenGateChestItem(current.hero.openedChests);

      return {
        ...current,
        hero: {
          ...current.hero,
          earnedChests: current.hero.earnedChests - 1,
          openedChests: current.hero.openedChests + 1,
          inventory: [...current.hero.inventory, chestItem],
          rewardLog: [`Broken Gate Chest opened: ${chestItem.name} (${chestItem.rarity}).`, ...current.hero.rewardLog].slice(0, 6),
        },
      };
    });
  };

  const upgradeEquippedItem = (slot: EquipmentSlot): void => {
    setProgress(current => {
      const itemId = current.hero.equippedItemIds[slot];
      const item = current.hero.inventory.find(inventoryItem => inventoryItem.id === itemId);

      if (!item) {
        return current;
      }

      const cost = getUpgradeCost(item);
      if (current.hero.gold < cost.gold || current.hero.materials < cost.essence) {
        return {
          ...current,
          hero: {
            ...current.hero,
            rewardLog: [`Need ${cost.gold} gold and ${cost.essence} Essence to upgrade ${item.name}.`, ...current.hero.rewardLog].slice(0, 6),
          },
        };
      }

      const upgradedItem = upgradeItem(item);

      return {
        ...current,
        hero: {
          ...current.hero,
          gold: current.hero.gold - cost.gold,
          materials: current.hero.materials - cost.essence,
          inventory: current.hero.inventory.map(inventoryItem => (inventoryItem.id === item.id ? upgradedItem : inventoryItem)),
          equipmentName: slot === 'weapon' ? upgradedItem.name : current.hero.equipmentName,
          rewardLog: [`Upgraded ${item.name} to level ${upgradedItem.upgradeLevel}.`, ...current.hero.rewardLog].slice(0, 6),
        },
      };
    });
  };

  const dismantleSpareItem = (): void => {
    setProgress(current => {
      const equippedIds = new Set(Object.values(current.hero.equippedItemIds));
      const spareItem = current.hero.inventory.find(item => !equippedIds.has(item.id) && item.tradeStatus !== 'Account-bound');

      if (!spareItem) {
        return {
          ...current,
          hero: {
            ...current.hero,
            rewardLog: ['No spare tradable loot to dismantle.', ...current.hero.rewardLog].slice(0, 6),
          },
        };
      }

      const essence = getDismantleEssence(spareItem);

      return {
        ...current,
        hero: {
          ...current.hero,
          materials: current.hero.materials + essence,
          inventory: current.hero.inventory.filter(item => item.id !== spareItem.id),
          rewardLog: [`Dismantled ${spareItem.name}: +${essence} Essence.`, ...current.hero.rewardLog].slice(0, 6),
        },
      };
    });
  };

  const selectClass = (classId: HeroClassId): void => {
    setProgress(current => {
      if (!current.hero.unlockedClassIds.includes(classId)) {
        return current;
      }

      const heroClass = classDefinitions.find(item => item.id === classId);

      return {
        ...current,
        hero: {
          ...current.hero,
          activeClassId: classId,
          rewardLog: [`Class equipped: ${heroClass?.name ?? classId}.`, ...current.hero.rewardLog].slice(0, 6),
        },
      };
    });
  };

  const startBattle = (): void => {
    if (campaignComplete || progress.hero.battleEnergy <= 0) {
      setActiveView('battle');
      return;
    }

    setProgress(current => ({
      ...current,
      hero: {
        ...current.hero,
        battleEnergy: Math.max(0, current.hero.battleEnergy - 1),
      },
    }));
    setBattle(createBattle(progress.hero, currentEnemy));
    setActiveView('battle');
  };

  const useBattleAction = (actionId: string): void => {
    setBattle(currentBattle => {
      if (currentBattle.status !== 'active') {
        return currentBattle;
      }

      const result = resolveBattleAction(currentBattle, progress.hero, currentEnemy, actionId);

      const reward = result.reward;

      if (reward) {
        setProgress(current => ({
          ...current,
          hero: reconcileHeroUnlocks(applyBattleReward(current.hero, currentEnemy, reward.materials), current.completedExerciseIds, current.completedDayIds),
        }));
      }

      return result.battle;
    });
  };

  const installApp = async (): Promise<void> => {
    if (!installPrompt) {
      setActiveView('coach');
      return;
    }

    await installPrompt.prompt();
    await installPrompt.userChoice;
    setInstallPrompt(null);
  };

  const closeRewardNotice = (): void => {
    const currentNotice = rewardQueue[0];
    setRewardQueue(queue => queue.slice(1));

    if (rewardQueue.length <= 1 && currentNotice?.nextView) {
      setActiveView(currentNotice.nextView);
    }
  };

  return (
    <main
      className="coach-app"
      style={
        {
          '--coach-primary': coachConfig.colors.primary,
          '--coach-accent': coachConfig.colors.accent,
        } as React.CSSProperties
      }
    >
      <section className="phone-frame" aria-label="Trainer client demo">
        <div className="status-bar" aria-hidden="true">
          <span>9:41</span>
          <span className="phone-indicators">LTE 100</span>
        </div>
        <div className="dynamic-island" aria-hidden="true" />

        {activeView === 'workout' ? (
          <WorkoutView
            day={selectedProgrammeDay}
            exercise={activeExercise}
            exerciseIndex={activeExerciseIndex}
            remainingSeconds={remainingSeconds}
            timerRunning={timerRunning}
            onBack={() => setActiveView('today')}
            onCompleteSet={completeSet}
            onNextExercise={goToNextExercise}
            onToggleTimer={() => setTimerRunning(running => !running)}
          />
        ) : (
          <>
            <AppHeader activeView={activeView} installAvailable={Boolean(installPrompt)} onInstall={installApp} />

            {activeView === 'today' && (
              <TodayView
                programme={selectedProgramme}
                programmes={coachConfig.programmes}
                day={selectedProgrammeDay}
                completionPercent={todayPercent}
                completedExerciseIds={progress.completedExerciseIds}
                selectedProgrammeId={selectedProgramme.id}
                onProgrammeSelect={selectProgramme}
                onDaySelect={setSelectedDay}
                selectedDay={selectedDay}
                onStartExercise={startExercise}
                onStartWorkout={() => startExercise(selectedProgrammeDay.exercises[0])}
              />
            )}

            {activeView === 'quest' && (
              <QuestMapView
                hero={progress.hero}
                currentEnemy={currentEnemy}
                campaignComplete={campaignComplete}
                onTrain={() => setActiveView('today')}
                onBattle={startBattle}
              />
            )}

            {activeView === 'battle' && (
              <BattleView
                hero={progress.hero}
                battle={battle}
                currentEnemy={currentEnemy}
                campaignComplete={campaignComplete}
                onStartBattle={startBattle}
                onAction={useBattleAction}
                onTrain={() => setActiveView('today')}
                onQuest={() => setActiveView('quest')}
              />
            )}

            {activeView === 'hero' && (
              <HeroView
                progress={progress}
                onEquipItem={equipItem}
                onSelectClass={selectClass}
                onOpenChest={openEarnedChest}
                onUpgradeEquippedItem={upgradeEquippedItem}
                onDismantleSpareItem={dismantleSpareItem}
              />
            )}

            {activeView === 'progress' && (
              <ProgressView
                programme={selectedProgramme}
                completionPercent={completionPercent}
                totalExerciseCount={totalExerciseCount}
                completedExerciseCount={completedExerciseCount}
                completedDayCount={completedDayCount}
                onReset={resetDemo}
              />
            )}

            {activeView === 'coach' && (
              <CoachView whatsappUrl={whatsappUrl} installPromptAvailable={Boolean(installPrompt)} onInstall={installApp} />
            )}
          </>
        )}

        <BottomNav activeView={activeView} onChange={setActiveView} />
        {activeRewardNotice && <TrainingRewardOverlay notice={activeRewardNotice} onClose={closeRewardNotice} />}
      </section>
    </main>
  );
}

function AppHeader({
  activeView,
  installAvailable,
  onInstall,
}: {
  activeView: View;
  installAvailable: boolean;
  onInstall: () => void;
}): React.JSX.Element {
  if (activeView !== 'today') {
    const titleByView: Record<View, string> = {
      today: 'Today',
      workout: 'Workout',
      quest: 'Quest Map',
      battle: 'Battle',
      hero: 'Hero',
      progress: 'Progress',
      coach: 'Profile',
    };
    const Icon =
      activeView === 'coach' ? FaWhatsapp : activeView === 'battle' ? FaTrophy : activeView === 'quest' ? FaFire : activeView === 'progress' ? FaChartBar : FaStar;

    return (
      <header className="simple-header">
        <span />
        <h1>{titleByView[activeView]}</h1>
        <Icon aria-hidden="true" />
      </header>
    );
  }

  return (
    <header className="coach-header">
      <div className="coach-brand-row">
        <img src={coachConfig.logoPath} alt={`${coachConfig.brandName} logo`} className="coach-logo" />
        <div>
          <p className="brand-mark">{coachConfig.brandName}</p>
          <p>Welcome back, Sam</p>
        </div>
      </div>
      <button className="avatar-button" type="button" onClick={onInstall} aria-label={installAvailable ? 'Install app' : 'Open install instructions'}>
        <img src={coachConfig.logoPath} alt="" />
      </button>
    </header>
  );
}

function TodayView({
  programme,
  programmes,
  day,
  selectedDay,
  completionPercent,
  completedExerciseIds,
  selectedProgrammeId,
  onProgrammeSelect,
  onDaySelect,
  onStartExercise,
  onStartWorkout,
}: {
  programme: CoachProgramme;
  programmes: CoachProgramme[];
  day: CoachProgramme['days'][number];
  selectedDay: number;
  completionPercent: number;
  completedExerciseIds: string[];
  selectedProgrammeId: string;
  onProgrammeSelect: (programmeId: string) => void;
  onDaySelect: (day: number) => void;
  onStartExercise: (exercise: ProgrammeExercise) => void;
  onStartWorkout: () => void;
}): React.JSX.Element {
  return (
    <section className="screen-section today-screen">
      <p className="screen-subtitle">Ready to crush today?</p>

      <nav className="programme-selector" aria-label="Training programmes">
        {programmes.map(option => (
          <button
            key={option.id}
            type="button"
            className={option.id === selectedProgrammeId ? 'active' : ''}
            onClick={() => onProgrammeSelect(option.id)}
          >
            <strong>{option.level}</strong>
            <span>{option.title}</span>
          </button>
        ))}
      </nav>

      <article className="workout-summary-card">
        <div className="summary-heading">
          <div>
            <h2>Today&apos;s Workout</h2>
            <p>{programme.title}</p>
            <strong className="selected-workout-title">{day.title}</strong>
          </div>
          <span className="date-pill">
            <FaCalendarAlt aria-hidden="true" />
            {programme.durationLabel}
          </span>
        </div>

        <div className="summary-body">
          <div className="summary-exercises">
            {day.exercises.map(exercise => {
              const completed = completedExerciseIds.includes(exercise.id);
              return (
                <button
                  className={`exercise-row ${completed ? 'complete' : ''}`}
                  type="button"
                  key={exercise.id}
                  onClick={() => onStartExercise(exercise)}
                >
                  <span className="exercise-icon">{getExerciseGlyph(exercise.name)}</span>
                  <span>
                    <strong>{exercise.name}</strong>
                    <small>{exercise.target}</small>
                  </span>
                  {completed && <FaCheck aria-label="Completed" />}
                </button>
              );
            })}
          </div>

          <div className="compact-ring" style={{ '--ring-value': `${completionPercent * 3.6}deg` } as React.CSSProperties}>
            <span>{completionPercent}%</span>
            <small>Workout Progress</small>
          </div>
        </div>

        <button type="button" className="primary-action" onClick={onStartWorkout}>
          Start Workout
          <FaArrowRight aria-hidden="true" />
        </button>
      </article>

      <nav className="day-strip" aria-label="Programme days">
        {programme.days.map(programmeDay => (
          <button
            key={programmeDay.day}
            type="button"
            className={programmeDay.day === selectedDay ? 'active' : ''}
            onClick={() => onDaySelect(programmeDay.day)}
          >
            D{programmeDay.day}
          </button>
        ))}
      </nav>

      <article className="daily-tip-card">
        <div>
          <h3>
            <FaFire aria-hidden="true" />
            Daily Tip
          </h3>
          <p>{day.focus}</p>
        </div>
        <div className="mountain-mark" aria-hidden="true">
          <span />
          <span />
          <span />
        </div>
      </article>
    </section>
  );
}

function WorkoutView({
  day,
  exercise,
  exerciseIndex,
  remainingSeconds,
  timerRunning,
  onBack,
  onCompleteSet,
  onNextExercise,
  onToggleTimer,
}: {
  day: CoachProgramme['days'][number];
  exercise: ProgrammeExercise;
  exerciseIndex: number;
  remainingSeconds: number;
  timerRunning: boolean;
  onBack: () => void;
  onCompleteSet: () => void;
  onNextExercise: () => void;
  onToggleTimer: () => void;
}): React.JSX.Element {
  const timerPercent = exercise.restSeconds > 0 ? Math.round(((exercise.restSeconds - remainingSeconds) / exercise.restSeconds) * 100) : 100;

  return (
    <section className="screen-section workout-screen">
      <header className="workout-header">
        <button type="button" className="icon-button" onClick={onBack} aria-label="Back to today">
          <FaArrowLeft aria-hidden="true" />
        </button>
        <h1>Workout</h1>
        <span className="header-dots" aria-hidden="true">
          ...
        </span>
      </header>

      <div className="set-progress">
        <strong>
          {exerciseIndex + 1} of {day.exercises.length}
        </strong>
        <div className="segment-row" aria-hidden="true">
          {day.exercises.map((item, index) => (
            <span className={index <= exerciseIndex ? 'active' : ''} key={item.id} />
          ))}
        </div>
      </div>

      <article className="active-workout-card">
        <div className="active-exercise-heading">
          <span className="large-exercise-icon">{getExerciseGlyph(exercise.name)}</span>
          <div>
            <h2>{exercise.name}</h2>
            <p>{exercise.target}</p>
          </div>
        </div>

        <ExerciseVisual exercise={exercise} />

        <div className="rep-panel">
          <span>
            <small>Set</small>
            <strong>1 of {getSetCount(exercise.target)}</strong>
          </span>
          <span>
            <small>Target</small>
            <strong>{getRepTarget(exercise.target)}</strong>
          </span>
        </div>

        <div className="timer-ring" style={{ '--ring-value': `${timerPercent * 3.6}deg` } as React.CSSProperties}>
          <div>
            <strong>{formatSeconds(remainingSeconds)}</strong>
            <span>{remainingSeconds === 0 ? 'Rest Complete' : 'Rest Time'}</span>
            <button type="button" onClick={onToggleTimer} aria-label={timerRunning ? 'Pause timer' : 'Start timer'}>
              {timerRunning ? <FaPause aria-hidden="true" /> : <FaPlay aria-hidden="true" />}
            </button>
          </div>
        </div>

        <div className="instruction-block">
          <h3>How to perform</h3>
          <ul>
            {exercise.instructions.map(instruction => (
              <li key={instruction}>
                <FaCheck aria-hidden="true" />
                {instruction}
              </li>
            ))}
          </ul>
          <p className="coach-note">{exercise.coachNote}</p>
        </div>

        <button type="button" className="primary-action" onClick={onCompleteSet}>
          <FaCheck aria-hidden="true" />
          Complete Set
        </button>
        <button type="button" className="outline-action" onClick={onNextExercise}>
          {exerciseIndex + 1 === day.exercises.length ? 'Finish Workout' : 'Next Exercise'}
          <FaArrowRight aria-hidden="true" />
        </button>
      </article>
    </section>
  );
}

function TrainingRewardOverlay({ notice, onClose }: { notice: TrainingRewardNotice; onClose: () => void }): React.JSX.Element {
  return (
    <div className="reward-overlay" role="dialog" aria-modal="true" aria-labelledby="training-reward-title">
      <article className="training-reward-card">
        <span className="reward-kicker">{notice.subtitle ?? 'Training reward'}</span>
        <h2 id="training-reward-title">{notice.title}</h2>

        {notice.statRewards && (
          <div className="reward-stat-list">
            {getRewardEntries(notice.statRewards).map(([attribute, value]) => (
              <div key={attribute}>
                <span>{attributeLabels[attribute]}</span>
                <strong>+{value}</strong>
              </div>
            ))}
          </div>
        )}

        {notice.statChanges && notice.statChanges.length > 0 && (
          <div className="reward-change-list">
            {notice.statChanges.map(change => (
              <p key={change.attribute}>
                {attributeLabels[change.attribute]} increased from {change.before} to {change.after}
              </p>
            ))}
          </div>
        )}

        {notice.effectLines && notice.effectLines.length > 0 && (
          <ul className="reward-effect-list">
            {notice.effectLines.map(line => (
              <li key={line}>
                <FaCheck aria-hidden="true" />
                {line}
              </li>
            ))}
          </ul>
        )}

        <button type="button" className="primary-action" onClick={onClose}>
          {notice.primaryAction}
          <FaArrowRight aria-hidden="true" />
        </button>
      </article>
    </div>
  );
}

function ExerciseVisual({ exercise }: { exercise: ProgrammeExercise }): React.JSX.Element {
  const titleId = `${exercise.id}-visual-title`;

  return (
    <figure className={`exercise-visual visual-${exercise.visualKind}`}>
      <svg viewBox="0 0 320 170" role="img" aria-labelledby={titleId}>
        <title id={titleId}>{`${exercise.name} movement guide`}</title>
        <rect className="visual-bg" x="0" y="0" width="320" height="170" rx="18" />
        <path className="visual-floor" d="M35 135H285" />
        {renderExerciseVisual(exercise.visualKind)}
      </svg>
      <figcaption>{exercise.description}</figcaption>
    </figure>
  );
}

function renderExerciseVisual(kind: ExerciseVisualKind): React.ReactNode {
  switch (kind) {
    case 'squat':
      return (
        <>
          <circle className="visual-joint" cx="160" cy="54" r="13" />
          <path className="visual-body" d="M160 69L148 96L128 126" />
          <path className="visual-body" d="M148 96H192L216 128" />
          <path className="visual-body" d="M154 78L118 88" />
          <path className="visual-body" d="M158 78L194 82" />
          <path className="visual-arrow" d="M238 54v48m0 0l-13-13m13 13l13-13" />
        </>
      );
    case 'lunge':
      return (
        <>
          <circle className="visual-joint" cx="154" cy="48" r="13" />
          <path className="visual-body" d="M154 63L150 92L122 126" />
          <path className="visual-body" d="M150 92L196 104L232 130" />
          <path className="visual-body" d="M152 76L118 88" />
          <path className="visual-body" d="M154 76L194 72" />
          <path className="visual-arrow" d="M82 112h52m0 0l-13-11m13 11l-13 11" />
        </>
      );
    case 'push':
      return (
        <>
          <circle className="visual-joint" cx="98" cy="82" r="12" />
          <path className="visual-body" d="M111 86L210 104" />
          <path className="visual-body" d="M128 90L116 128" />
          <path className="visual-body" d="M168 98L162 130" />
          <path className="visual-body" d="M210 104L254 130" />
          <path className="visual-arrow" d="M152 46v36m0 0l-10-10m10 10l10-10" />
        </>
      );
    case 'pull':
      return (
        <>
          <path className="visual-rig" d="M72 34H248" />
          <path className="visual-body" d="M136 34L150 68" />
          <path className="visual-body" d="M184 34L170 68" />
          <circle className="visual-joint" cx="160" cy="78" r="13" />
          <path className="visual-body" d="M160 92v42" />
          <path className="visual-body" d="M160 134l-22 18" />
          <path className="visual-body" d="M160 134l22 18" />
          <path className="visual-arrow" d="M252 120V70m0 0l-12 12m12-12l12 12" />
        </>
      );
    case 'row':
      return (
        <>
          <path className="visual-rig" d="M62 58H260" />
          <circle className="visual-joint" cx="98" cy="92" r="12" />
          <path className="visual-body" d="M112 96L218 122" />
          <path className="visual-body" d="M116 98L154 60" />
          <path className="visual-body" d="M144 104L184 64" />
          <path className="visual-body" d="M218 122L260 133" />
          <path className="visual-arrow" d="M236 80h-44m0 0l12-11m-12 11l12 11" />
        </>
      );
    case 'hinge':
      return (
        <>
          <circle className="visual-joint" cx="112" cy="100" r="12" />
          <path className="visual-body" d="M70 128H224" />
          <path className="visual-body" d="M112 112L160 130L212 106" />
          <path className="visual-body" d="M134 119L118 135" />
          <path className="visual-body" d="M184 119L202 135" />
          <path className="visual-arrow" d="M160 78v34m0 0l-10-10m10 10l10-10" />
        </>
      );
    case 'core':
      return (
        <>
          <circle className="visual-joint" cx="103" cy="102" r="12" />
          <path className="visual-body" d="M116 104L168 120L238 84" />
          <path className="visual-body" d="M132 109L92 78" />
          <path className="visual-body" d="M168 120L224 132" />
          <path className="visual-arrow" d="M220 58c-32-16-70-14-102 5" />
        </>
      );
    case 'jump':
      return (
        <>
          <circle className="visual-joint" cx="160" cy="50" r="12" />
          <path className="visual-body" d="M160 64v42" />
          <path className="visual-body" d="M160 78l-34-18" />
          <path className="visual-body" d="M160 78l34-18" />
          <path className="visual-body" d="M160 106l-28 30" />
          <path className="visual-body" d="M160 106l28 30" />
          <path className="visual-arrow" d="M238 112V50m0 0l-12 13m12-13l12 13" />
        </>
      );
    case 'burpee':
      return (
        <>
          <circle className="visual-joint" cx="78" cy="74" r="10" />
          <path className="visual-body" d="M78 86v40M78 104l-24 20M78 104l24 20" />
          <circle className="visual-joint" cx="164" cy="97" r="10" />
          <path className="visual-body" d="M174 100L242 118M188 104L178 132M216 112L236 134" />
          <path className="visual-arrow" d="M112 118h36m0 0l-10-9m10 9l-10 9" />
        </>
      );
    case 'hang':
      return (
        <>
          <path className="visual-rig" d="M82 34H238" />
          <path className="visual-body" d="M142 34L154 70" />
          <path className="visual-body" d="M178 34L166 70" />
          <circle className="visual-joint" cx="160" cy="83" r="13" />
          <path className="visual-body" d="M160 96v44" />
          <path className="visual-body" d="M160 140l-24 16" />
          <path className="visual-body" d="M160 140l24 16" />
        </>
      );
    case 'handstand':
      return (
        <>
          <path className="visual-rig" d="M244 22v124" />
          <circle className="visual-joint" cx="166" cy="124" r="12" />
          <path className="visual-body" d="M166 112L182 72L196 32" />
          <path className="visual-body" d="M182 72l-28-8" />
          <path className="visual-body" d="M182 72l34-2" />
          <path className="visual-body" d="M166 136l-26 16" />
          <path className="visual-body" d="M166 136l24 16" />
          <path className="visual-arrow" d="M88 124h42m0 0l-10-9m10 9l-10 9" />
        </>
      );
    case 'crawl':
      return (
        <>
          <circle className="visual-joint" cx="98" cy="82" r="12" />
          <path className="visual-body" d="M110 88L178 100L232 82" />
          <path className="visual-body" d="M128 92L104 130" />
          <path className="visual-body" d="M172 99L150 132" />
          <path className="visual-body" d="M206 90L242 130" />
          <path className="visual-arrow" d="M76 54h62m0 0l-12-10m12 10l-12 10" />
        </>
      );
    case 'run':
      return (
        <>
          <circle className="visual-joint" cx="146" cy="52" r="12" />
          <path className="visual-body" d="M146 66L158 98" />
          <path className="visual-body" d="M154 76L118 92" />
          <path className="visual-body" d="M158 78L196 60" />
          <path className="visual-body" d="M158 98L122 130" />
          <path className="visual-body" d="M158 98L206 128" />
          <path className="visual-arrow" d="M224 84h44m0 0l-12-11m12 11l-12 11" />
        </>
      );
    default:
      return (
        <>
          <circle className="visual-joint" cx="160" cy="52" r="13" />
          <path className="visual-body" d="M160 66v52" />
          <path className="visual-body" d="M160 82l-36 20" />
          <path className="visual-body" d="M160 82l36 20" />
          <path className="visual-body" d="M160 118l-30 28" />
          <path className="visual-body" d="M160 118l30 28" />
        </>
      );
  }
}

function QuestMapView({
  hero,
  currentEnemy,
  campaignComplete,
  onTrain,
  onBattle,
}: {
  hero: HeroState;
  currentEnemy: Enemy;
  campaignComplete: boolean;
  onTrain: () => void;
  onBattle: () => void;
}): React.JSX.Element {
  return (
    <section className="screen-section quest-screen">
      <article className="quest-hero-card">
        <span>{currentEnemy.chapter}</span>
        <h2>{campaignComplete ? 'Gate Secured' : `Next: ${currentEnemy.name}`}</h2>
        <p>
          {campaignComplete
            ? 'The first gate is cleared. Keep training to prepare for the next chapter.'
            : 'Complete a real workout to earn one battle attempt, then convert that training into a fight.'}
        </p>
        <div className="quest-energy-row">
          <strong>{hero.battleEnergy}</strong>
          <span>attempts saved</span>
          <strong>{hero.trainingEnergy}</strong>
          <span>training energy</span>
        </div>
      </article>

      <article className="quest-map-card">
        <h3>The Broken Gate</h3>
        <div className="enemy-road">
          {campaignEnemies.map((enemy, index) => {
            const defeated = hero.defeatedEnemyIds.includes(enemy.id);
            const current = index === hero.currentEnemyIndex && !campaignComplete;
            return (
              <div className={`${defeated ? 'defeated' : ''} ${current ? 'current' : ''}`} key={enemy.id}>
                <span>{enemy.boss ? 'Boss' : `Stage ${index + 1}`}</span>
                <strong>{enemy.name}</strong>
                <small>{defeated ? 'Defeated' : current ? 'Available' : 'Locked'}</small>
              </div>
            );
          })}
        </div>
      </article>

      <article className="quest-action-card">
        <h3>Daily Quest</h3>
        <p>Finish a workout to earn one battle attempt. Starting a battle spends one attempt.</p>
        <button type="button" className="primary-action" onClick={hero.battleEnergy > 0 && !campaignComplete ? onBattle : onTrain}>
          {hero.battleEnergy > 0 && !campaignComplete ? 'Enter Battle' : 'Train for Attempt'}
          <FaArrowRight aria-hidden="true" />
        </button>
      </article>
    </section>
  );
}

function BattleView({
  hero,
  battle,
  currentEnemy,
  campaignComplete,
  onStartBattle,
  onAction,
  onTrain,
  onQuest,
}: {
  hero: HeroState;
  battle: BattleState;
  currentEnemy: Enemy;
  campaignComplete: boolean;
  onStartBattle: () => void;
  onAction: (actionId: string) => void;
  onTrain: () => void;
  onQuest: () => void;
}): React.JSX.Element {
  const effectiveStats = getEffectiveStats(hero);
  const maxHeroHp = getHeroMaxHp(effectiveStats);
  const enemyHpMax = currentEnemy.hp;
  const unlockedAbilityIds = new Set(hero.unlockedAbilityIds);
  const equippedAbilities = hero.equippedAbilityIds
    .map(id => abilityDefinitions.find(ability => ability.id === id))
    .filter((ability): ability is Ability => Boolean(ability));

  if (campaignComplete) {
    return (
      <section className="screen-section battle-screen">
        <article className="battle-card">
          <h2>Chapter Cleared</h2>
          <p>The Broken Gate is complete. The next chapter can build on this loop.</p>
          <button type="button" className="primary-action" onClick={onQuest}>
            View Quest Map
            <FaArrowRight aria-hidden="true" />
          </button>
        </article>
      </section>
    );
  }

  if (battle.status === 'idle') {
    return (
      <section className="screen-section battle-screen">
        <article className="battle-card">
          <span className="rank-pill">Next Enemy</span>
          <h2>{currentEnemy.name}</h2>
          <p>
            Armour {currentEnemy.armour} / Attack {currentEnemy.attack}. Spend one battle attempt to start the fight.
          </p>
          <button type="button" className="primary-action" onClick={hero.battleEnergy > 0 ? onStartBattle : onTrain}>
            {hero.battleEnergy > 0 ? 'Start Battle' : 'Complete Workout First'}
            <FaArrowRight aria-hidden="true" />
          </button>
        </article>
      </section>
    );
  }

  return (
    <section className="screen-section battle-screen">
      <article className="combat-stage">
        <div className="combatant hero-combatant">
          <span className="pixel-hero" aria-hidden="true" />
          <strong>Hero</strong>
          <small>
            HP {Math.max(0, battle.heroHp)} / {maxHeroHp}
          </small>
          <i>
            <b style={{ width: `${Math.max(0, (battle.heroHp / maxHeroHp) * 100)}%` }} />
          </i>
        </div>

        <div className="combat-versus">VS</div>

        <div className="combatant enemy-combatant">
          <span className="pixel-enemy" aria-hidden="true" />
          <strong>{currentEnemy.name}</strong>
          <small>
            HP {Math.max(0, battle.enemyHp)} / {enemyHpMax}
          </small>
          <i>
            <b style={{ width: `${Math.max(0, (battle.enemyHp / enemyHpMax) * 100)}%` }} />
          </i>
        </div>
      </article>

      <article className="battle-status-card">
        <div>
          <span>Charge</span>
          <strong>{battle.resolveCharge}%</strong>
        </div>
        <div>
          <span>Focus</span>
          <strong>
            {battle.heroEnergy}/{battle.maxHeroEnergy}
          </strong>
        </div>
        <div>
          <span>Momentum</span>
          <strong>{battle.momentum}</strong>
        </div>
        <div>
          <span>Status</span>
          <strong>{battle.breakTurns > 0 ? `Break ${battle.breakTurns}` : battle.bleedTurns > 0 ? `Bleed ${battle.bleedTurns}` : 'Clear'}</strong>
        </div>
      </article>

      <article className="battle-actions-card">
        {battle.status === 'active' ? (
          <>
            <button type="button" onClick={() => onAction('basic')}>
              Basic Strike
            </button>
            {equippedAbilities.map(ability => (
              <button
                type="button"
                key={ability.id}
                disabled={!unlockedAbilityIds.has(ability.id) || battle.heroEnergy < ability.energyCost || (battle.abilityCooldowns[ability.id] ?? 0) > 0}
                onClick={() => onAction(ability.id)}
              >
                {ability.name}
                <small>
                  {unlockedAbilityIds.has(ability.id)
                    ? (battle.abilityCooldowns[ability.id] ?? 0) > 0
                      ? `CD ${battle.abilityCooldowns[ability.id]}`
                      : `${ability.energyCost} Focus`
                    : 'Locked'}
                </small>
              </button>
            ))}
            <button type="button" onClick={() => onAction('guard')}>
              Guard
            </button>
            <button type="button" disabled={battle.tonicUsed} onClick={() => onAction('tonic')}>
              Tonic
            </button>
            <button type="button" disabled={battle.resolveCharge < 100} onClick={() => onAction('ultimate')}>
              Ultimate
            </button>
          </>
        ) : (
          <button type="button" className="primary-action" onClick={battle.status === 'victory' ? onQuest : onTrain}>
            {battle.status === 'victory' ? 'Claim Quest Progress' : 'Train and Retry'}
            <FaArrowRight aria-hidden="true" />
          </button>
        )}
      </article>

      <article className="battle-log-card">
        <h3>Combat Log</h3>
        {battle.log.slice(0, 5).map((entry, index) => (
          <p key={`${index}-${entry}`}>{entry}</p>
        ))}
      </article>
    </section>
  );
}

function HeroView({
  progress,
  onEquipItem,
  onSelectClass,
  onOpenChest,
  onUpgradeEquippedItem,
  onDismantleSpareItem,
}: {
  progress: DemoProgress;
  onEquipItem: (itemId: string) => void;
  onSelectClass: (classId: HeroClassId) => void;
  onOpenChest: () => void;
  onUpgradeEquippedItem: (slot: EquipmentSlot) => void;
  onDismantleSpareItem: () => void;
}): React.JSX.Element {
  const unlockedAbilityIds = new Set(progress.hero.unlockedAbilityIds);
  const unlockedClassIds = new Set(progress.hero.unlockedClassIds);
  const activeClass = classDefinitions.find(heroClass => heroClass.id === progress.hero.activeClassId) ?? classDefinitions[0];
  const effectiveStats = getEffectiveStats(progress.hero);
  const xpNeeded = getXpForNextLevel(progress.hero.level);

  return (
    <section className="screen-section progress-screen">
      <article className="hero-card">
        <div>
          <span className="rank-pill">Level {progress.hero.level} {activeClass.name}</span>
          <h2>Zero to Hero: Ascension</h2>
          <p>Train in real life. Become powerful in the game.</p>
          <div className="xp-track" aria-label={`${progress.hero.xp} of ${xpNeeded} experience`}>
            <i>
              <b style={{ width: `${Math.min(100, (progress.hero.xp / xpNeeded) * 100)}%` }} />
            </i>
            <span>
              {progress.hero.xp}/{xpNeeded} XP
            </span>
          </div>
        </div>
        <div className="hero-energy">
          <strong>{progress.hero.battleEnergy}</strong>
          <span>Battle Attempts</span>
        </div>
      </article>

      <article className="stats-card">
        <h3>Hero Attributes</h3>
        <div className="attribute-grid">
          {attributeKeys.map(attribute => (
            <div key={attribute}>
              <span>{attributeLabels[attribute]}</span>
              <strong>{effectiveStats[attribute]}</strong>
            </div>
          ))}
        </div>
      </article>

      <article className="class-card">
        <h3>Class Path</h3>
        <div className="class-list">
          {classDefinitions.map(heroClass => {
            const unlocked = unlockedClassIds.has(heroClass.id);
            const active = progress.hero.activeClassId === heroClass.id;
            return (
              <button type="button" className={active ? 'active' : ''} disabled={!unlocked} key={heroClass.id} onClick={() => onSelectClass(heroClass.id)}>
                <strong>{heroClass.name}</strong>
                <span>{unlocked ? heroClass.role : heroClass.requirement}</span>
              </button>
            );
          })}
        </div>
      </article>

      <article className="equipment-card">
        <h3>Game Economy</h3>
        <div className="currency-row">
          <span>{progress.hero.gold} gold</span>
          <span>{progress.hero.materials} Essence</span>
          <span>{progress.hero.earnedChests} earned chests</span>
          <span>{progress.hero.chestFragments}/3 chest fragments</span>
        </div>
        <div className="economy-note">
          Gold, Essence and earned chests stay inside the game economy. Training attributes and battle attempts are account-bound.
        </div>
        <div className="economy-actions">
          <button type="button" onClick={onOpenChest}>Open earned chest</button>
          <button type="button" onClick={() => onUpgradeEquippedItem('weapon')}>Upgrade weapon</button>
          <button type="button" onClick={() => onUpgradeEquippedItem('armor')}>Upgrade armour</button>
          <button type="button" onClick={() => onUpgradeEquippedItem('charm')}>Upgrade charm</button>
          <button type="button" onClick={onDismantleSpareItem}>Dismantle spare loot</button>
        </div>
        <div className="equipment-slots">
          {(['weapon', 'armor', 'charm'] as EquipmentSlot[]).map(slot => {
            const item = progress.hero.inventory.find(inventoryItem => inventoryItem.id === progress.hero.equippedItemIds[slot]);
            return (
              <div key={slot}>
                <span>{slot}</span>
                <strong>{item?.name ?? 'Empty'}</strong>
                {item && <small>Level {item.upgradeLevel}</small>}
              </div>
            );
          })}
        </div>
        <div className="inventory-list">
          {progress.hero.inventory.map(item => {
            const equipped = progress.hero.equippedItemIds[item.slot] === item.id;
            const bonusText = formatStatRewards(normalizeStatRewards(item.bonuses as LegacyHeroStats)) || 'No stat bonus';

            return (
              <button type="button" className={equipped ? 'equipped' : ''} key={item.id} onClick={() => onEquipItem(item.id)}>
                <span>{item.rarity} {item.slot} / {item.tradeStatus}</span>
                <strong>{item.name}{item.upgradeLevel > 0 ? ` +${item.upgradeLevel}` : ''}</strong>
                <small>{bonusText}</small>
                <small>{item.origin}</small>
              </button>
            );
          })}
        </div>
      </article>

      <article className="abilities-card">
        <h3>Abilities</h3>
        <div className="ability-list">
          {abilityDefinitions.map(ability => {
            const unlocked = unlockedAbilityIds.has(ability.id);
            return (
              <div className={unlocked ? 'unlocked' : ''} key={ability.id}>
                <span>{ability.tag}</span>
                <strong>{ability.name}</strong>
                <p>{unlocked ? ability.description : ability.requirement}</p>
              </div>
            );
          })}
        </div>
      </article>

      <article className="reward-card">
        <h3>Reward Chest</h3>
        {progress.hero.rewardLog.length > 0 ? (
          progress.hero.rewardLog.slice(0, 3).map((reward, index) => <p key={`${index}-${reward}`}>{reward}</p>)
        ) : (
          <p>Complete a workout and defeat an enemy to fill the chest.</p>
        )}
      </article>
    </section>
  );
}

function ProgressView({
  programme,
  completionPercent,
  totalExerciseCount,
  completedExerciseCount,
  completedDayCount,
  onReset,
}: {
  programme: CoachProgramme;
  completionPercent: number;
  totalExerciseCount: number;
  completedExerciseCount: number;
  completedDayCount: number;
  onReset: () => void;
}): React.JSX.Element {
  const weeklyBars = [60, 80, 70, 90, Math.max(35, completionPercent), 60, 85];

  return (
    <section className="screen-section progress-screen">

      <article className="challenge-card">
        <div className="large-ring" style={{ '--ring-value': `${completionPercent * 3.6}deg` } as React.CSSProperties}>
          <span>{completionPercent}%</span>
        </div>
        <div>
          <h2>Challenge Progress</h2>
          <p>{programme.title}</p>
        </div>
      </article>

      <div className="metric-grid">
        <div>
          <FaFire aria-hidden="true" />
          <strong>{Math.max(1, completedDayCount)}</strong>
          <span>Day Streak</span>
        </div>
        <div>
          <FaCalendarAlt aria-hidden="true" />
          <strong>{completedDayCount}</strong>
          <span>Workouts Completed</span>
        </div>
        <div>
          <FaStar aria-hidden="true" />
          <strong>{completedExerciseCount * 25}</strong>
          <span>Total Points</span>
        </div>
      </div>

      <article className="stats-card">
        <h3>Coach Progress</h3>
        <div className="stats-grid">
          <StatBar label="Strength" value={Math.min(99, 62 + completedExerciseCount * 2)} />
          <StatBar label="Endurance" value={Math.min(99, 58 + completedDayCount * 4)} />
          <StatBar label="Stability" value={Math.min(99, 64 + completedExerciseCount)} />
          <StatBar label="Mobility" value={Math.min(99, 55 + completedExerciseCount * 2)} />
        </div>
      </article>

      <article className="weekly-card">
        <h3>Weekly Progress</h3>
        <div className="bar-chart" aria-label={`${completedExerciseCount} of ${totalExerciseCount} exercises complete`}>
          {weeklyBars.map((value, index) => (
            <span key={index}>
              <strong>{value}%</strong>
              <i style={{ height: `${value}%` }} />
              <small>{['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index]}</small>
            </span>
          ))}
        </div>
        <button type="button" className="primary-action" onClick={onReset}>
          Reset Demo
          <FaArrowRight aria-hidden="true" />
        </button>
      </article>
    </section>
  );
}

function CoachView({
  whatsappUrl,
  installPromptAvailable,
  onInstall,
}: {
  whatsappUrl: string;
  installPromptAvailable: boolean;
  onInstall: () => void;
}): React.JSX.Element {
  return (
    <section className="screen-section coach-screen">
      <article className="profile-card">
        <img src={coachConfig.logoPath} alt={`${coachConfig.brandName} logo`} />
        <div>
          <h2>{coachConfig.trainerName}</h2>
          <p>{coachConfig.headline}</p>
        </div>
      </article>

      <article className="contact-card">
        <h3>Need help?</h3>
        <p>Send your trainer a quick message about form, soreness, or the next session.</p>
        <a href={whatsappUrl} target="_blank" rel="noreferrer" className="primary-action link-action">
          <FaWhatsapp aria-hidden="true" />
          Message on WhatsApp
        </a>
      </article>

      <article className="install-card">
        <h3>Install on phone</h3>
        {installPromptAvailable ? (
          <>
            <p>Tap install to add this demo to the home screen.</p>
            <button type="button" className="primary-action" onClick={onInstall}>
              Install App
            </button>
          </>
        ) : (
          <ol>
            <li>Open this demo in Chrome or Safari on your phone.</li>
            <li>Tap Share or the browser menu.</li>
            <li>Choose Add to Home Screen.</li>
          </ol>
        )}
      </article>
    </section>
  );
}

function BottomNav({ activeView, onChange }: { activeView: View; onChange: (view: View) => void }): React.JSX.Element {
  return (
    <nav className="bottom-nav" aria-label="Main demo navigation">
      <button type="button" className={activeView === 'today' ? 'active' : ''} onClick={() => onChange('today')}>
        <FaHome aria-hidden="true" />
        Train
      </button>
      <button type="button" className={activeView === 'quest' ? 'active' : ''} onClick={() => onChange('quest')}>
        <FaFire aria-hidden="true" />
        Quest
      </button>
      <button type="button" className={activeView === 'battle' ? 'active' : ''} onClick={() => onChange('battle')}>
        <FaTrophy aria-hidden="true" />
        Battle
      </button>
      <button type="button" className={activeView === 'hero' ? 'active' : ''} onClick={() => onChange('hero')}>
        <FaStar aria-hidden="true" />
        Hero
      </button>
      <button type="button" className={activeView === 'progress' ? 'active' : ''} onClick={() => onChange('progress')}>
        <FaChartBar aria-hidden="true" />
        Progress
      </button>
      <button type="button" className={activeView === 'coach' ? 'active' : ''} onClick={() => onChange('coach')}>
        <FaUser aria-hidden="true" />
        Profile
      </button>
    </nav>
  );
}

function StatBar({ label, value }: { label: string; value: number }): React.JSX.Element {
  return (
    <div className="stat-bar">
      <div>
        <strong>{label}</strong>
        <span>{value}</span>
      </div>
      <small>{value >= 72 ? 'Strong' : 'Good'}</small>
      <i>
        <b style={{ width: `${value}%` }} />
      </i>
    </div>
  );
}

function getExerciseGlyph(name: string): React.JSX.Element {
  const lowerName = name.toLowerCase();

  if (lowerName.includes('walk') || lowerName.includes('march') || lowerName.includes('flow')) {
    return <FaFire aria-hidden="true" />;
  }

  if (lowerName.includes('plank') || lowerName.includes('bug') || lowerName.includes('hold')) {
    return <FaStar aria-hidden="true" />;
  }

  return <FaDumbbell aria-hidden="true" />;
}

function getSetCount(target: string): string {
  const match = target.match(/(\d+)\s*sets?/i);
  return match?.[1] ?? '3';
}

function getRepTarget(target: string): string {
  const match = target.match(/x\s*([^,]+)/i);
  return match?.[1]?.trim() ?? target;
}

function formatSeconds(seconds: number): string {
  const minutes = Math.floor(seconds / 60);
  const remaining = seconds % 60;
  return `${minutes}:${String(remaining).padStart(2, '0')}`;
}

function getDayKey(programmeId: string, day: number): string {
  return `${programmeId}-day-${day}`;
}

function createIdleBattle(hero: HeroState): BattleState {
  const enemy = campaignEnemies[Math.min(hero.currentEnemyIndex, campaignEnemies.length - 1)];
  const effectiveStats = getEffectiveStats(hero);
  const maxHeroEnergy = getHeroMaxEnergy(effectiveStats);
  return {
    status: 'idle',
    enemyId: enemy.id,
    heroHp: getHeroMaxHp(effectiveStats),
    enemyHp: enemy.hp,
    enemyArmour: enemy.armour,
    heroEnergy: maxHeroEnergy,
    maxHeroEnergy,
    resolveCharge: 0,
    momentum: 0,
    breakTurns: 0,
    exhaustTurns: 0,
    bleedTurns: 0,
    abilityCooldowns: {},
    tonicUsed: false,
    log: ['Complete a workout, then spend one battle attempt to fight.'],
  };
}

function createBattle(hero: HeroState, enemy: Enemy): BattleState {
  const effectiveStats = getEffectiveStats(hero);
  const maxHeroEnergy = getHeroMaxEnergy(effectiveStats);
  return {
    status: 'active',
    enemyId: enemy.id,
    heroHp: getHeroMaxHp(effectiveStats),
    enemyHp: enemy.hp,
    enemyArmour: enemy.armour,
    heroEnergy: maxHeroEnergy,
    maxHeroEnergy,
    resolveCharge: 20,
    momentum: 0,
    breakTurns: 0,
    exhaustTurns: 0,
    bleedTurns: 0,
    abilityCooldowns: {},
    tonicUsed: false,
    log: [`${enemy.name} blocks the gate.`],
  };
}

function getHeroMaxHp(stats: HeroStats): number {
  return 80 + stats.vitality * 5;
}

function getHeroMaxEnergy(stats: HeroStats): number {
  return 5 + Math.floor(stats.endurance / 5);
}

function getEffectiveStats(hero: HeroState): HeroStats {
  const stats: HeroStats = { ...hero.stats };
  const activeClass = classDefinitions.find(heroClass => heroClass.id === hero.activeClassId);

  hero.inventory.forEach(item => {
    if (hero.equippedItemIds[item.slot] !== item.id) {
      return;
    }

    addBonusesToStats(stats, item.bonuses);
  });

  if (activeClass) {
    addBonusesToStats(stats, activeClass.bonuses);
  }

  return stats;
}

function addBonusesToStats(stats: HeroStats, bonuses: Partial<HeroStats>): void {
  Object.entries(bonuses as LegacyHeroStats).forEach(([attribute, value]) => {
    const mappedAttribute = mapLegacyAttribute(attribute);
    if (!mappedAttribute || typeof value !== 'number') {
      return;
    }

    stats[mappedAttribute] += value;
  });
}

function awardExerciseTraining(hero: HeroState, exercise: ProgrammeExercise): HeroState {
  const statRewards = getTrainingStatRewards(exercise);
  const nextStats = addStatRewards(hero.stats, statRewards);
  const reward = `${exercise.name}: ${formatStatRewards(statRewards)}, +8 training energy`;
  const trainedHero = grantXp(
    {
      ...hero,
      stats: nextStats,
      trainingEnergy: hero.trainingEnergy + 8,
      gold: hero.gold + 1,
      rewardLog: [reward, ...hero.rewardLog].slice(0, 6),
    },
    8
  );

  return trainedHero;
}

function awardWorkoutCompletion(hero: HeroState, workoutTitle: string): HeroState {
  const nextBattleAttempts = Math.min(3, hero.battleEnergy + 1);
  const attemptText = nextBattleAttempts > hero.battleEnergy ? 'battle attempt earned' : 'battle attempts full';

  return grantXp(
    {
      ...hero,
      battleEnergy: nextBattleAttempts,
      trainingEnergy: hero.trainingEnergy + 20,
      rewardLog: [`${workoutTitle} complete: ${attemptText}, +40 XP`, ...hero.rewardLog].slice(0, 6),
    },
    40
  );
}

function reconcileHeroUnlocks(hero: HeroState, completedExerciseIds: string[], completedDayIds: string[]): HeroState {
  const unlocked = new Set(hero.unlockedAbilityIds);
  const unlockedClasses = new Set<HeroClassId>(hero.unlockedClassIds);

  if (completedExerciseIds.length >= 1) unlocked.add('power-strike');
  if (completedDayIds.length >= 1) unlocked.add('shield-crush');
  if (completedDayIds.length >= 3) unlocked.add('execution-strike');
  if (hero.stats.agility >= 18 || hero.stats.endurance >= 20) unlocked.add('wind-step');
  if (completedDayIds.length >= 7 || hero.stats.control >= 18) unlocked.add('unbroken-resolve');
  if (hero.defeatedEnemyIds.includes('gatekeeper-brakk')) unlocked.add('titan-breaker');

  if (hero.stats.vitality >= 18 && completedDayIds.length >= 1) unlockedClasses.add('vanguard');
  if (hero.stats.power >= 20) unlockedClasses.add('berserker');
  if (hero.stats.endurance >= 18 || hero.stats.agility >= 18) unlockedClasses.add('ranger');
  if (hero.stats.control >= 18 || completedDayIds.length >= 3) unlockedClasses.add('monk');
  if (hero.stats.vitality >= 24 && hero.stats.endurance >= 18) unlockedClasses.add('juggernaut');

  const nextUnlockedAbilityIds = Array.from(unlocked);
  const newUnlocks = nextUnlockedAbilityIds.filter(id => !hero.unlockedAbilityIds.includes(id));
  const unlockRewards = newUnlocks
    .map(id => abilityDefinitions.find(ability => ability.id === id)?.name)
    .filter((name): name is string => Boolean(name))
    .map(name => `Ability unlocked: ${name}`);
  const nextUnlockedClassIds = Array.from(unlockedClasses);
  const classRewards = nextUnlockedClassIds
    .filter(id => !hero.unlockedClassIds.includes(id))
    .map(id => classDefinitions.find(heroClass => heroClass.id === id)?.name)
    .filter((name): name is string => Boolean(name))
    .map(name => `Class path unlocked: ${name}`);

  return {
    ...hero,
    unlockedAbilityIds: nextUnlockedAbilityIds,
    unlockedClassIds: nextUnlockedClassIds,
    rewardLog: [...unlockRewards, ...classRewards, ...hero.rewardLog].slice(0, 6),
  };
}

function grantXp(hero: HeroState, amount: number): HeroState {
  let level = hero.level;
  let xp = hero.xp + amount;
  const logs: string[] = [];

  while (xp >= getXpForNextLevel(level)) {
    xp -= getXpForNextLevel(level);
    level += 1;
    logs.push(`Level ${level} reached: new quest access improved.`);
  }

  return {
    ...hero,
    level,
    xp,
    rewardLog: [...logs, ...hero.rewardLog].slice(0, 6),
  };
}

function getXpForNextLevel(level: number): number {
  return 100 + (level - 1) * 55;
}

function applyBattleReward(hero: HeroState, enemy: Enemy, materials: number): HeroState {
  const drop = enemyDrops[enemy.id];
  const alreadyOwned = drop ? hero.inventory.some(item => item.id === drop.id) : true;
  const nextInventory = drop && !alreadyOwned ? [...hero.inventory, drop] : hero.inventory;
  const chestProgress = addChestFragments(hero, enemy.boss ? 2 : 1);
  const nextEquippedItemIds =
    drop && !hero.equippedItemIds[drop.slot]
      ? {
          ...hero.equippedItemIds,
          [drop.slot]: drop.id,
        }
      : hero.equippedItemIds;

  return grantXp(
    {
      ...hero,
      materials: hero.materials + materials,
      gold: hero.gold + 8 + materials,
      chestFragments: chestProgress.chestFragments,
      earnedChests: chestProgress.earnedChests,
      currentEnemyIndex: Math.min(campaignEnemies.length, hero.currentEnemyIndex + 1),
      defeatedEnemyIds: Array.from(new Set([...hero.defeatedEnemyIds, enemy.id])),
      inventory: nextInventory,
      equippedItemIds: nextEquippedItemIds,
      equipmentName: drop ? drop.name : hero.equipmentName,
      rewardLog: [
        `${enemy.name} defeated: +${materials} Essence, +${8 + materials} gold, ${enemy.rewardText}`,
        chestProgress.chestEarned ? 'Earned chest ready: Broken Gate Chest.' : `Chest fragment earned: ${chestProgress.chestFragments}/3.`,
        drop && !alreadyOwned ? `Loot acquired: ${drop.name} (${drop.rarity}).` : '',
        ...hero.rewardLog,
      ]
        .filter(Boolean)
        .slice(0, 6),
    },
    enemy.boss ? 90 : 45
  );
}

function addChestFragments(hero: HeroState, fragments: number): { chestFragments: number; earnedChests: number; chestEarned: boolean } {
  const totalFragments = hero.chestFragments + fragments;
  const earnedChestCount = Math.floor(totalFragments / 3);

  return {
    chestFragments: totalFragments % 3,
    earnedChests: hero.earnedChests + earnedChestCount,
    chestEarned: earnedChestCount > 0,
  };
}

function createBrokenGateChestItem(openedChests: number): EquipmentItem {
  const chestItems: EquipmentItem[] = [
    {
      id: `broken-gate-chest-${openedChests + 1}-charm`,
      name: 'Gate Focus Band',
      slot: 'charm',
      rarity: 'Common',
      description: 'A chest-earned charm that improves guarded ability control.',
      bonuses: { control: 1 },
      origin: 'Broken Gate Chest',
      tradeStatus: 'Bind on equip',
      upgradeLevel: 0,
    },
    {
      id: `broken-gate-chest-${openedChests + 1}-wraps`,
      name: 'Runner Wraps',
      slot: 'armor',
      rarity: 'Common',
      description: 'Light wraps earned from the first gate chest pool.',
      bonuses: { agility: 1, endurance: 1 },
      origin: 'Broken Gate Chest',
      tradeStatus: 'Bind on equip',
      upgradeLevel: 0,
    },
    {
      id: `broken-gate-chest-${openedChests + 1}-edge`,
      name: 'Iron Training Edge',
      slot: 'weapon',
      rarity: 'Rare',
      description: 'A fixed chest reward for early weapon progression.',
      bonuses: { power: 2 },
      origin: 'Broken Gate Chest',
      tradeStatus: 'Bind on equip',
      upgradeLevel: 0,
    },
  ];

  return chestItems[openedChests % chestItems.length];
}

function getUpgradeCost(item: EquipmentItem): { gold: number; essence: number } {
  return {
    gold: 6 + item.upgradeLevel * 4,
    essence: 3 + item.upgradeLevel * 2,
  };
}

function upgradeItem(item: EquipmentItem): EquipmentItem {
  const upgradeAttribute = getUpgradeAttribute(item);
  return {
    ...item,
    upgradeLevel: item.upgradeLevel + 1,
    bonuses: {
      ...item.bonuses,
      [upgradeAttribute]: (item.bonuses[upgradeAttribute] ?? 0) + 1,
    },
    tradeStatus: item.tradeStatus === 'Bind on equip' ? 'Bound' : item.tradeStatus,
  };
}

function getUpgradeAttribute(item: EquipmentItem): AttributeKey {
  const existingAttributes = getRewardEntries(item.bonuses as StatReward);
  if (existingAttributes[0]) {
    return existingAttributes[0][0];
  }

  if (item.slot === 'weapon') {
    return 'power';
  }

  if (item.slot === 'armor') {
    return 'vitality';
  }

  return 'control';
}

function getDismantleEssence(item: EquipmentItem): number {
  const rarityValue: Record<EquipmentRarity, number> = {
    Common: 2,
    Rare: 5,
    Epic: 10,
  };

  return rarityValue[item.rarity] + item.upgradeLevel * 2;
}

function addStatRewards(stats: HeroStats, rewards: StatReward): HeroStats {
  return attributeKeys.reduce(
    (nextStats, attribute) => ({
      ...nextStats,
      [attribute]: Math.min(999, nextStats[attribute] + (rewards[attribute] ?? 0)),
    }),
    { ...stats }
  );
}

function createExerciseRewardNotice(exercise: ProgrammeExercise, rewards: StatReward): TrainingRewardNotice {
  return {
    title: `${exercise.name} complete`,
    statRewards: rewards,
    effectLines: ['+8 XP', '+8 training energy'],
    primaryAction: 'Continue',
  };
}

function createWorkoutRewardNotice(workoutTitle: string, beforeStats: HeroStats, afterStats: HeroStats): TrainingRewardNotice {
  return {
    title: 'Training complete',
    subtitle: workoutTitle,
    statChanges: getStatChanges(beforeStats, afterStats),
    effectLines: [...getTrainingEffectLines(beforeStats, afterStats), 'Battle attempt earned', '+40 workout XP'],
    primaryAction: 'Go to quest map',
    nextView: 'quest',
  };
}

function getStatChanges(beforeStats: HeroStats, afterStats: HeroStats): StatChange[] {
  return attributeKeys
    .map(attribute => ({
      attribute,
      before: beforeStats[attribute],
      after: afterStats[attribute],
      delta: afterStats[attribute] - beforeStats[attribute],
    }))
    .filter(change => change.delta > 0);
}

function getTrainingEffectLines(beforeStats: HeroStats, afterStats: HeroStats): string[] {
  const lines: string[] = [];
  const hpGain = getHeroMaxHp(afterStats) - getHeroMaxHp(beforeStats);
  const focusGain = getHeroMaxEnergy(afterStats) - getHeroMaxEnergy(beforeStats);
  const agilityGain = afterStats.agility - beforeStats.agility;
  const powerGain = afterStats.power - beforeStats.power;
  const controlGain = afterStats.control - beforeStats.control;
  const enduranceGain = afterStats.endurance - beforeStats.endurance;

  if (hpGain > 0) {
    lines.push(`Maximum HP increased by ${hpGain}`);
  }

  if (focusGain > 0) {
    lines.push(`Maximum Focus increased by ${focusGain}`);
  } else if (enduranceGain > 0) {
    lines.push('Focus recovery improved');
  }

  if (agilityGain > 0) {
    lines.push(`Turn speed increased by ${agilityGain}%`);
  }

  if (powerGain > 0) {
    lines.push('Basic attack damage improved');
  }

  if (controlGain > 0) {
    lines.push('Guarding and ability control improved');
  }

  return lines;
}

function getTrainingStatRewards(exercise: ProgrammeExercise): StatReward {
  const name = exercise.name.toLowerCase();
  const rewardSize = getTrainingRewardSize(exercise);
  const reward = (primary: AttributeKey, secondary?: AttributeKey): StatReward => ({
    [primary]: rewardSize.primary,
    ...(secondary ? { [secondary]: rewardSize.secondary } : {}),
  });

  switch (exercise.visualKind) {
    case 'push':
      return reward('power', 'control');
    case 'pull':
    case 'row':
    case 'hang':
      return reward('power', 'control');
    case 'squat':
    case 'lunge':
      return reward('power', 'vitality');
    case 'run':
      return reward('endurance', 'agility');
    case 'burpee':
      return reward('endurance', 'power');
    case 'crawl':
      return reward('agility', 'control');
    case 'jump':
      return reward('agility', 'power');
    case 'hinge':
      return reward('control', 'vitality');
    case 'core':
      return reward('control', 'endurance');
    case 'handstand':
      return reward('control', 'agility');
    case 'default':
      break;
    default:
      break;
  }

  if (name.includes('push') || name.includes('dip')) {
    return reward('power', 'control');
  }

  if (name.includes('pull') || name.includes('chin') || name.includes('row') || name.includes('hang')) {
    return reward('power', 'control');
  }

  if (name.includes('squat') || name.includes('lunge')) {
    return reward('power', 'vitality');
  }

  if (name.includes('run') || name.includes('walk') || name.includes('interval')) {
    return reward('endurance', 'agility');
  }

  if (name.includes('burpee')) {
    return reward('endurance', 'power');
  }

  if (name.includes('crawl') || name.includes('mountain')) {
    return reward('agility', 'control');
  }

  if (name.includes('jump') || name.includes('skater')) {
    return reward('agility', 'power');
  }

  if (name.includes('bridge') || name.includes('hinge') || name.includes('peel')) {
    return reward('control', 'vitality');
  }

  if (name.includes('plank') || name.includes('hold') || name.includes('raise')) {
    return reward('control', 'endurance');
  }

  if (name.includes('handstand')) {
    return reward('control', 'agility');
  }

  return { control: rewardSize.primary };
}

function getTrainingRewardSize(exercise: ProgrammeExercise): { primary: number; secondary: number } {
  const name = exercise.name.toLowerCase();
  const target = exercise.target.toLowerCase();
  const easy =
    name.includes('comfortable') ||
    name.includes('brisk walk') ||
    name.includes('easy run') ||
    name.includes('chair') ||
    name.includes('wall') ||
    name.includes('recovery') ||
    name.includes('rest between');
  const difficult =
    exercise.visualKind === 'handstand' ||
    name.includes('one-arm') ||
    name.includes('pistol') ||
    name.includes('dragon') ||
    name.includes('lever') ||
    name.includes('plyometric') ||
    name.includes('tuck jump') ||
    name.includes('burpee pull-up') ||
    target.includes('5 x');

  if (difficult) {
    return { primary: 5, secondary: 2 };
  }

  if (easy) {
    return { primary: 3, secondary: 1 };
  }

  return { primary: 4, secondary: 1 };
}

function getRewardEntries(rewards: StatReward): Array<[AttributeKey, number]> {
  return attributeKeys
    .filter(attribute => (rewards[attribute] ?? 0) > 0)
    .sort((first, second) => (rewards[second] ?? 0) - (rewards[first] ?? 0))
    .map(attribute => [attribute, rewards[attribute] ?? 0]);
}

function formatStatRewards(rewards: StatReward): string {
  return getRewardEntries(rewards)
    .map(([attribute, value]) => `+${value} ${attributeLabels[attribute]}`)
    .join(', ');
}

function normalizeStatRewards(rewards: LegacyHeroStats): StatReward {
  return Object.entries(rewards).reduce<StatReward>((nextRewards, [attribute, value]) => {
    const mappedAttribute = mapLegacyAttribute(attribute);
    if (!mappedAttribute || typeof value !== 'number') {
      return nextRewards;
    }

    return {
      ...nextRewards,
      [mappedAttribute]: (nextRewards[mappedAttribute] ?? 0) + value,
    };
  }, {});
}

function mapLegacyAttribute(attribute: string): AttributeKey | null {
  if ((attributeKeys as string[]).includes(attribute)) {
    return attribute as AttributeKey;
  }

  if (attribute === 'fortitude') {
    return 'vitality';
  }

  if (attribute === 'might') {
    return 'power';
  }

  if (attribute === 'discipline' || attribute === 'resolve') {
    return 'control';
  }

  return null;
}

function resolveBattleAction(
  battle: BattleState,
  hero: HeroState,
  enemy: Enemy,
  actionId: string
): { battle: BattleState; reward?: { materials: number } } {
  const effectiveStats = getEffectiveStats(hero);
  const maxHeroHp = getHeroMaxHp(effectiveStats);

  if (actionId === 'tonic') {
    const healedBattle = {
      ...battle,
      heroHp: Math.min(maxHeroHp, battle.heroHp + 32),
      tonicUsed: true,
      log: [`Tonic restored 32 HP.`, ...battle.log],
    };
    return {
      battle: resolveEnemyTurn(healedBattle, hero, enemy, false),
    };
  }

  if (actionId === 'guard') {
    const recoveredBattle = {
      ...battle,
      heroEnergy: Math.min(battle.maxHeroEnergy, battle.heroEnergy + 2 + Math.floor(effectiveStats.endurance / 20)),
      abilityCooldowns: tickCooldowns(battle.abilityCooldowns),
    };
    const guardedBattle = resolveEnemyTurn(
      {
        ...recoveredBattle,
        momentum: 0,
        log: ['Guard raised. Focus recovered and incoming damage reduced.', ...battle.log],
      },
      hero,
      enemy,
      true
    );

    return {
      battle: guardedBattle,
      reward: guardedBattle.status === 'victory' ? { materials: enemy.rewardMaterials } : undefined,
    };
  }

  const ability = abilityDefinitions.find(item => item.id === actionId);
  const usingUltimate = actionId === 'ultimate';
  const unlocked = actionId === 'basic' || usingUltimate || (ability ? hero.unlockedAbilityIds.includes(ability.id) : false);
  const ultimateReady = !usingUltimate || battle.resolveCharge >= 100;
  const energyCost = ability?.energyCost ?? 0;
  const cooldown = ability?.cooldown ?? 0;
  const abilityReady = actionId === 'basic' || usingUltimate || ((battle.abilityCooldowns[actionId] ?? 0) <= 0 && battle.heroEnergy >= energyCost);

  if (!unlocked || !ultimateReady || !abilityReady) {
    return {
      battle: {
        ...battle,
        log: ['That action is not ready. Check energy, cooldown, or unlock status.', ...battle.log],
      },
    };
  }

  const titanBreakerUnlocked = hero.unlockedAbilityIds.includes('titan-breaker');
  const rawDamageBase = getActionRawDamage(actionId, effectiveStats, battle);
  const rawDamage = usingUltimate && !titanBreakerUnlocked ? Math.round(rawDamageBase * 0.65) : rawDamageBase;
  const armour = usingUltimate || battle.breakTurns > 0 ? Math.floor(battle.enemyArmour * 0.25) : battle.enemyArmour;
  const bleedDamage = battle.bleedTurns > 0 ? Math.max(1, Math.floor(effectiveStats.control / 5)) : 0;
  const critChance = Math.min(0.25, effectiveStats.agility / 250);
  const critical = !usingUltimate && Math.random() < critChance;
  const damage = Math.round(Math.max(1, rawDamage - armour) * (critical ? 1.5 : 1)) + bleedDamage;
  const enemyHp = Math.max(0, battle.enemyHp - damage);
  const breakTurns = actionId === 'shield-crush' ? 2 : Math.max(0, battle.breakTurns - 1);
  const exhaustTurns = actionId === 'wind-step' ? 2 : Math.max(0, battle.exhaustTurns - 1);
  const bleedTurns = actionId === 'wind-step' ? 3 : Math.max(0, battle.bleedTurns - 1);
  const resolveCharge = usingUltimate ? 0 : Math.min(100, battle.resolveCharge + 12);
  const momentum = actionId === 'basic' || actionId === 'power-strike' || actionId === 'execution-strike' ? battle.momentum + 1 : battle.momentum;
  const actionName = usingUltimate ? (titanBreakerUnlocked ? 'Titan Breaker' : 'Focus Burst') : actionId === 'basic' ? 'Basic Strike' : ability?.name ?? 'Action';
  const actionLogPrefix = critical ? `Critical ${actionName}` : actionName;
  const actionLog = bleedDamage > 0 ? `${actionLogPrefix} dealt ${damage} damage including ${bleedDamage} bleed.` : `${actionLogPrefix} dealt ${damage} damage.`;
  const nextCooldowns = actionId === 'basic' || usingUltimate ? tickCooldowns(battle.abilityCooldowns) : { ...tickCooldowns(battle.abilityCooldowns), [actionId]: cooldown };

  const afterPlayer: BattleState = {
    ...battle,
    enemyHp,
    breakTurns,
    exhaustTurns,
    bleedTurns,
    resolveCharge,
    momentum,
    heroEnergy: usingUltimate ? Math.min(battle.maxHeroEnergy, battle.heroEnergy + 1) : Math.max(0, Math.min(battle.maxHeroEnergy, battle.heroEnergy - energyCost + 1)),
    abilityCooldowns: nextCooldowns,
    log: [actionLog, ...battle.log],
  };

  if (enemyHp <= 0) {
    return {
      battle: {
        ...afterPlayer,
        status: 'victory',
        log: [`Victory! Reward found: ${enemy.rewardText}.`, ...afterPlayer.log],
      },
      reward: {
        materials: enemy.rewardMaterials,
      },
    };
  }

  return {
    battle: resolveEnemyTurn(afterPlayer, hero, enemy, false),
  };
}

function getActionRawDamage(actionId: string, stats: HeroStats, battle: BattleState): number {
  const momentumBonus = battle.momentum * 2;

  if (actionId === 'shield-crush') {
    return Math.round(12 + stats.power * 1.05 + momentumBonus);
  }

  if (actionId === 'execution-strike') {
    const multiplier = battle.breakTurns > 0 ? 2 : 1;
    return Math.round((14 + stats.power * 1.25 + momentumBonus) * multiplier);
  }

  if (actionId === 'wind-step') {
    return Math.round(10 + stats.control * 0.85 + momentumBonus);
  }

  if (actionId === 'ultimate') {
    return Math.round(24 + stats.power * 1.4 + stats.control * 1.05 + momentumBonus);
  }

  if (actionId === 'power-strike') {
    return Math.round(10 + stats.power * 1.35 + momentumBonus);
  }

  return Math.round(8 + stats.power * 0.75 + momentumBonus);
}

function resolveEnemyTurn(battle: BattleState, hero: HeroState, enemy: Enemy, guarded: boolean): BattleState {
  const effectiveStats = getEffectiveStats(hero);
  const maxHeroHp = getHeroMaxHp(effectiveStats);
  const exhaustMultiplier = battle.exhaustTurns > 0 ? 0.72 : 1;
  const guardMultiplier = guarded ? 0.42 : 1;
  const rawDamage = Math.max(1, Math.round(enemy.attack * exhaustMultiplier * guardMultiplier));
  const mitigatedDamage = Math.max(
    1,
    rawDamage - Math.floor(effectiveStats.vitality / 10) - (guarded ? Math.floor(effectiveStats.control / 8) : 0) - (hero.activeClassId === 'vanguard' && guarded ? 2 : 0)
  );
  const heroHp = Math.max(0, battle.heroHp - mitigatedDamage);
  const lowHealthBonus = heroHp < maxHeroHp * 0.35 ? 18 : 0;
  const resolveCharge = Math.min(100, battle.resolveCharge + 10 + lowHealthBonus + (guarded && hero.unlockedAbilityIds.includes('unbroken-resolve') ? 16 : 0));
  const counterDamage = guarded
    ? Math.max(1, Math.round(effectiveStats.control * 0.62 + (hero.activeClassId === 'vanguard' ? effectiveStats.vitality * 0.25 : 0)))
    : 0;
  const enemyHp = Math.max(0, battle.enemyHp - counterDamage);
  const log = [
    guarded ? `Guard countered for ${counterDamage} damage.` : `${enemy.name} hit for ${mitigatedDamage} damage.`,
    ...battle.log,
  ];

  if (enemyHp <= 0) {
    return {
      ...battle,
      status: 'victory',
      heroHp,
      enemyHp,
      resolveCharge,
      log: [`Victory! Guard counter finished ${enemy.name}.`, ...log],
    };
  }

  if (heroHp <= 0) {
    return {
      ...battle,
      status: 'defeat',
      heroHp,
      enemyHp,
      resolveCharge,
      log: ['Defeat. Train, upgrade, and retry.', ...log],
    };
  }

  return {
    ...battle,
    heroHp,
    enemyHp,
    resolveCharge,
    exhaustTurns: Math.max(0, battle.exhaustTurns - 1),
    heroEnergy: Math.min(battle.maxHeroEnergy, battle.heroEnergy + 1 + Math.floor(effectiveStats.endurance / 18) + (hero.activeClassId === 'ranger' ? 1 : 0)),
    log,
  };
}

function tickCooldowns(cooldowns: Record<string, number>): Record<string, number> {
  return Object.fromEntries(Object.entries(cooldowns).map(([id, value]) => [id, Math.max(0, value - 1)]));
}

function loadProgress(): DemoProgress {
  try {
    const raw = localStorage.getItem(storageKey);
    if (!raw) {
      return defaultProgress;
    }
    const parsed = JSON.parse(raw) as DemoProgress;
    const hero = mergeHero(parsed.hero);
    return {
      completedExerciseIds: parsed.completedExerciseIds || [],
      completedDayIds: (parsed.completedDayIds || []).map(dayId => String(dayId)),
      programmeStartedAt: parsed.programmeStartedAt || new Date().toISOString(),
      hero,
    };
  } catch {
    return defaultProgress;
  }
}

function mergeHero(hero?: Partial<HeroState>): HeroState {
  const defaultHero = createDefaultHero();

  if (!hero) {
    return defaultHero;
  }

  return {
    ...defaultHero,
    ...hero,
    stats: normalizeHeroStats(hero.stats as LegacyHeroStats | undefined, defaultHero.stats),
    inventory: hero.inventory ?? defaultHero.inventory,
    equippedItemIds: hero.equippedItemIds ?? defaultHero.equippedItemIds,
    chestFragments: hero.chestFragments ?? defaultHero.chestFragments,
    earnedChests: hero.earnedChests ?? defaultHero.earnedChests,
    openedChests: hero.openedChests ?? defaultHero.openedChests,
    defeatedEnemyIds: hero.defeatedEnemyIds ?? defaultHero.defeatedEnemyIds,
    unlockedAbilityIds: hero.unlockedAbilityIds ?? defaultHero.unlockedAbilityIds,
    equippedAbilityIds: hero.equippedAbilityIds ?? defaultHero.equippedAbilityIds,
    unlockedClassIds: hero.unlockedClassIds ?? defaultHero.unlockedClassIds,
    activeClassId: hero.activeClassId ?? defaultHero.activeClassId,
    rewardLog: hero.rewardLog ?? defaultHero.rewardLog,
  };
}

function normalizeHeroStats(stats: LegacyHeroStats | undefined, defaultStats: HeroStats): HeroStats {
  const raw = stats ?? {};
  const read = (value: number | undefined, fallback: number): number => (typeof value === 'number' && Number.isFinite(value) ? value : fallback);
  const highest = (...values: Array<number | undefined>): number => Math.max(...values.filter((value): value is number => typeof value === 'number' && Number.isFinite(value)), 0);

  return {
    power: clampStat(Math.max(read(raw.power, defaultStats.power), highest(raw.might))),
    vitality: clampStat(read(raw.vitality, read(raw.fortitude, defaultStats.vitality))),
    agility: clampStat(read(raw.agility, defaultStats.agility)),
    endurance: clampStat(read(raw.endurance, defaultStats.endurance)),
    control: clampStat(Math.max(read(raw.control, defaultStats.control), highest(raw.discipline, raw.resolve))),
  };
}

function clampStat(value: number): number {
  return Math.max(0, Math.min(999, Math.round(value)));
}
