import React, { useEffect, useMemo, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  Badge,
  Box,
  Button,
  Card,
  CardBody,
  Center,
  HStack,
  Heading,
  Icon,
  Image,
  List,
  ListItem,
  Progress,
  SimpleGrid,
  Spinner,
  Stat,
  StatGroup,
  StatLabel,
  StatNumber,
  Tag,
  Text,
  VStack,
  useToast,
} from '@chakra-ui/react';
import { FaBolt, FaDumbbell, FaRunning, FaShieldAlt } from 'react-icons/fa';
import { GiPotionBall, GiSittingDog } from 'react-icons/gi';
import { RootState, AppDispatch } from '../store';
import { fetchUser } from '../features/user/userSlice';
import { fetchStatSnapshot } from '../features/progression/progressionSlice';
import { addBattleRecord, getBattleHistory } from '../utils/database';
import {
  AttackType,
  BossProfile,
  COMBAT_RULES_VERSION,
  CombatBuildSnapshot,
  calculateAttackDamage,
  calculateBossDamage,
  canUseAttack,
  createCombatBuildSnapshot,
  staminaCosts,
} from '../domain/combat';

interface Boss extends BossProfile {
  tier: number;
  image: string;
  defeated: boolean;
}

interface BattleSession {
  boss: Boss;
  buildSnapshot: CombatBuildSnapshot;
  startedAt: string;
  bossHealth: number;
  playerHealth: number;
  stamina: number;
  damageDealt: number;
  damageTaken: number;
  attacksUsed: Record<AttackType, number>;
  evadesAttempted: number;
  evadesSucceeded: number;
  log: string[];
}

const bossImages: Record<string, string> = {
  'training_dummy.png': '/images/bosses/training_dummy.png',
  'fitness_goblin.png': '/images/bosses/fitness_goblin.png',
  'cardio_crusher.png': '/images/bosses/cardio_crusher.png',
  'tier1_champion.png': '/images/bosses/tier1_champion.png',
  'strength_sentinel.png': '/images/bosses/training_dummy.png',
};

const baseBosses: Omit<Boss, 'health' | 'defeated'>[] = [
  {
    id: 'boss1',
    name: 'Training Dummy',
    tier: 1,
    maxHealth: 100,
    weakness: 'strike',
    image: 'training_dummy.png',
  },
  {
    id: 'boss2',
    name: 'Fitness Goblin',
    tier: 1,
    maxHealth: 200,
    weakness: 'core',
    image: 'fitness_goblin.png',
  },
  {
    id: 'boss3',
    name: 'Cardio Crusher',
    tier: 1,
    maxHealth: 300,
    weakness: 'endurance',
    image: 'cardio_crusher.png',
  },
  {
    id: 'boss4',
    name: 'Tier 1 Champion',
    tier: 1,
    maxHealth: 500,
    weakness: 'balanced',
    image: 'tier1_champion.png',
  },
  {
    id: 'boss5',
    name: 'Strength Sentinel',
    tier: 2,
    maxHealth: 750,
    weakness: 'force',
    resistance: 'endurance',
    image: 'strength_sentinel.png',
  },
];

const emptyAttacksUsed: Record<AttackType, number> = {
  light: 0,
  heavy: 0,
  'titan-impact': 0,
};

function BattleSystem(): React.JSX.Element {
  const dispatch: AppDispatch = useDispatch();
  const toast = useToast();
  const userId = useSelector((state: RootState) => state.user.id);
  const userTier = useSelector((state: RootState) => state.user.tier);
  const userStatus = useSelector((state: RootState) => state.user.status);
  const statSnapshot = useSelector((state: RootState) => state.progression.snapshot);
  const progressionStatus = useSelector((state: RootState) => state.progression.status);
  const [availableBosses, setAvailableBosses] = useState<Boss[]>([]);
  const [isLoadingBosses, setIsLoadingBosses] = useState(true);
  const [session, setSession] = useState<BattleSession | null>(null);

  const buildSnapshot = useMemo(
    () => (statSnapshot ? createCombatBuildSnapshot(statSnapshot) : null),
    [statSnapshot]
  );

  useEffect(() => {
    if (userStatus === 'idle') {
      dispatch(fetchUser());
    }
  }, [dispatch, userStatus]);

  useEffect(() => {
    if (userId && progressionStatus === 'idle') {
      dispatch(fetchStatSnapshot(userId));
    }
  }, [dispatch, progressionStatus, userId]);

  useEffect(() => {
    if (!userId) {
      setIsLoadingBosses(false);
      return;
    }

    let cancelled = false;

    async function loadBossData(): Promise<void> {
      setIsLoadingBosses(true);
      try {
        const battleHistory = await getBattleHistory(userId);
        const defeatedBossIds = new Set(
          battleHistory
            .filter(record => record.result === 'victory')
            .map(record => record.bossId)
        );
        const bosses = baseBosses
          .filter(boss => boss.tier <= userTier + 1)
          .map(boss => ({
            ...boss,
            health: boss.maxHealth,
            defeated: defeatedBossIds.has(boss.id),
          }));

        if (!cancelled) {
          setAvailableBosses(bosses);
        }
      } catch (error) {
        console.error('Error loading battle data:', error);
        toast({
          title: 'Error',
          description: 'Failed to load battle data',
          status: 'error',
          duration: 3000,
          isClosable: true,
        });
      } finally {
        if (!cancelled) {
          setIsLoadingBosses(false);
        }
      }
    }

    loadBossData();

    return () => {
      cancelled = true;
    };
  }, [toast, userId, userTier]);

  const startBattle = (boss: Boss): void => {
    if (!buildSnapshot) {
      toast({
        title: 'Build not ready',
        description: 'Permanent stats are still loading.',
        status: 'warning',
        duration: 3000,
        isClosable: true,
      });
      return;
    }

    setSession({
      boss,
      buildSnapshot,
      startedAt: new Date().toISOString(),
      bossHealth: boss.maxHealth,
      playerHealth: buildSnapshot.derived.maxHealth,
      stamina: buildSnapshot.derived.maxStamina,
      damageDealt: 0,
      damageTaken: 0,
      attacksUsed: { ...emptyAttacksUsed },
      evadesAttempted: 0,
      evadesSucceeded: 0,
      log: [`Battle with ${boss.name} started.`],
    });
  };

  const performAttack = async (attackType: AttackType): Promise<void> => {
    if (!session) {
      return;
    }

    if (!canUseAttack(session.buildSnapshot, attackType, session.stamina)) {
      toast({
        title: 'Attack unavailable',
        description:
          attackType === 'titan-impact'
            ? 'Titan Impact unlocks at 10,000 credited push-ups.'
            : 'Not enough stamina.',
        status: 'warning',
        duration: 3000,
        isClosable: true,
      });
      return;
    }

    const damage = calculateAttackDamage(
      session.buildSnapshot,
      session.boss,
      attackType
    );
    const nextBossHealth = Math.max(0, session.bossHealth - damage);
    const nextAttacksUsed = {
      ...session.attacksUsed,
      [attackType]: session.attacksUsed[attackType] + 1,
    };
    const staminaAfterAttack = Math.max(
      0,
      session.stamina - staminaCosts[attackType]
    );
    const nextDamageDealt = session.damageDealt + damage;

    if (nextBossHealth <= 0) {
      const finalSession = {
        ...session,
        bossHealth: 0,
        stamina: staminaAfterAttack,
        damageDealt: nextDamageDealt,
        attacksUsed: nextAttacksUsed,
        log: [
          `${formatAttackName(attackType)} dealt ${damage} damage.`,
          `${session.boss.name} defeated.`,
        ],
      };
      setSession(finalSession);
      await recordBattleResult(finalSession, 'victory');
      return;
    }

    const bossDamage = calculateBossDamage(
      session.buildSnapshot,
      12 + session.boss.tier * 6
    );
    const nextPlayerHealth = Math.max(0, session.playerHealth - bossDamage);
    const staminaAfterRecovery = Math.min(
      session.buildSnapshot.derived.maxStamina,
      staminaAfterAttack + session.buildSnapshot.derived.staminaRegenPerSecond
    );
    const nextSession = {
      ...session,
      bossHealth: nextBossHealth,
      playerHealth: nextPlayerHealth,
      stamina: staminaAfterRecovery,
      damageDealt: nextDamageDealt,
      damageTaken: session.damageTaken + bossDamage,
      attacksUsed: nextAttacksUsed,
      log: [
        `${formatAttackName(attackType)} dealt ${damage} damage.`,
        `${session.boss.name} countered for ${bossDamage} damage.`,
        ...session.log,
      ].slice(0, 8),
    };

    setSession(nextSession);

    if (nextPlayerHealth <= 0) {
      await recordBattleResult(nextSession, 'defeat');
    }
  };

  const evade = (): void => {
    if (!session) {
      return;
    }

    const staminaCost = 10;
    const success = session.stamina >= staminaCost;
    setSession({
      ...session,
      stamina: success ? session.stamina - staminaCost : session.stamina,
      evadesAttempted: session.evadesAttempted + 1,
      evadesSucceeded: session.evadesSucceeded + (success ? 1 : 0),
      log: [
        success
          ? `Evaded during a ${session.buildSnapshot.derived.evadeWindowMs}ms window.`
          : 'Evade failed: not enough stamina.',
        ...session.log,
      ].slice(0, 8),
    });
  };

  const abandonBattle = async (): Promise<void> => {
    if (session) {
      await recordBattleResult(session, 'abandoned');
    }
  };

  const recordBattleResult = async (
    completedSession: BattleSession,
    result: 'victory' | 'defeat' | 'abandoned'
  ): Promise<void> => {
    const endedAt = new Date().toISOString();
    await addBattleRecord({
      userId: completedSession.buildSnapshot.userId,
      bossId: completedSession.boss.id,
      startedAt: completedSession.startedAt,
      endedAt,
      result,
      durationMs:
        new Date(endedAt).getTime() - new Date(completedSession.startedAt).getTime(),
      damageDealt: completedSession.damageDealt,
      damageTaken: completedSession.damageTaken,
      attacksUsed: completedSession.attacksUsed,
      evadesAttempted: completedSession.evadesAttempted,
      evadesSucceeded: completedSession.evadesSucceeded,
      buildSnapshot: completedSession.buildSnapshot,
      combatRulesVersion: COMBAT_RULES_VERSION,
      seed: completedSession.startedAt,
    });

    setSession(null);
    setAvailableBosses(currentBosses =>
      currentBosses.map(boss =>
        boss.id === completedSession.boss.id
          ? { ...boss, defeated: result === 'victory' || boss.defeated }
          : boss
      )
    );
    toast({
      title:
        result === 'victory'
          ? 'Victory recorded'
          : result === 'defeat'
            ? 'Defeat recorded'
            : 'Battle abandoned',
      description: `${completedSession.boss.name} result persisted locally.`,
      status: result === 'victory' ? 'success' : 'info',
      duration: 3000,
      isClosable: true,
    });
  };

  if (userStatus === 'loading' || progressionStatus === 'loading' || isLoadingBosses) {
    return (
      <Center h="400px">
        <Spinner size="xl" color="purple.500" />
      </Center>
    );
  }

  if (!userId) {
    return (
      <Center h="300px">
        <Tag colorScheme="orange">Loading user profile...</Tag>
      </Center>
    );
  }

  return (
    <Box p={5}>
      <Heading mb={6}>Boss Battles</Heading>
      <VStack spacing={6} align="stretch">
        <Box borderWidth={1} borderRadius="lg" p={4} borderColor="gray.200">
          <Heading size="md" mb={4}>
            Combat Build Snapshot
          </Heading>
          {buildSnapshot ? (
            <StatGroup>
              <Stat>
                <StatLabel>
                  <Icon as={FaDumbbell} mr={1} color="red.400" />
                  Heavy
                </StatLabel>
                <StatNumber>{buildSnapshot.derived.heavyDamage}</StatNumber>
              </Stat>
              <Stat>
                <StatLabel>
                  <Icon as={FaRunning} mr={1} color="orange.400" />
                  Stamina
                </StatLabel>
                <StatNumber>{buildSnapshot.derived.maxStamina}</StatNumber>
              </Stat>
              <Stat>
                <StatLabel>
                  <Icon as={FaShieldAlt} mr={1} color="blue.400" />
                  Health
                </StatLabel>
                <StatNumber>{buildSnapshot.derived.maxHealth}</StatNumber>
              </Stat>
              <Stat>
                <StatLabel>
                  <Icon as={GiPotionBall} mr={1} color="cyan.400" />
                  Evade
                </StatLabel>
                <StatNumber>{buildSnapshot.derived.evadeWindowMs}ms</StatNumber>
              </Stat>
            </StatGroup>
          ) : (
            <Text color="gray.500">No stat snapshot yet.</Text>
          )}
        </Box>

        {session && (
          <Card borderColor="yellow.400" borderWidth={2}>
            <CardBody>
              <VStack spacing={4} align="stretch">
                <HStack justify="space-between" align="start">
                  <Box>
                    <Heading size="md">{session.boss.name}</Heading>
                    <Text fontSize="sm" color="gray.500">
                      Weakness: {session.boss.weakness}
                    </Text>
                  </Box>
                  <Button size="sm" variant="outline" onClick={abandonBattle}>
                    Abandon
                  </Button>
                </HStack>
                <Box>
                  <HStack justify="space-between">
                    <Text>Boss health</Text>
                    <Text>
                      {session.bossHealth}/{session.boss.maxHealth}
                    </Text>
                  </HStack>
                  <Progress
                    value={(session.bossHealth / session.boss.maxHealth) * 100}
                    colorScheme="red"
                  />
                </Box>
                <Box>
                  <HStack justify="space-between">
                    <Text>Hero health</Text>
                    <Text>
                      {session.playerHealth}/{session.buildSnapshot.derived.maxHealth}
                    </Text>
                  </HStack>
                  <Progress
                    value={
                      (session.playerHealth / session.buildSnapshot.derived.maxHealth) *
                      100
                    }
                    colorScheme="green"
                  />
                </Box>
                <Box>
                  <HStack justify="space-between">
                    <Text>Stamina</Text>
                    <Text>
                      {Math.round(session.stamina)}/
                      {session.buildSnapshot.derived.maxStamina}
                    </Text>
                  </HStack>
                  <Progress
                    value={
                      (session.stamina / session.buildSnapshot.derived.maxStamina) * 100
                    }
                    colorScheme="cyan"
                  />
                </Box>
                <HStack wrap="wrap">
                  <Button onClick={() => performAttack('light')}>Light Attack</Button>
                  <Button colorScheme="orange" onClick={() => performAttack('heavy')}>
                    Heavy Attack
                  </Button>
                  <Button
                    colorScheme="yellow"
                    onClick={() => performAttack('titan-impact')}
                    isDisabled={!session.buildSnapshot.abilities.includes('titan-impact')}
                  >
                    Titan Impact
                  </Button>
                  <Button variant="outline" onClick={evade}>
                    Evade
                  </Button>
                </HStack>
                <List spacing={1}>
                  {session.log.map((entry, index) => (
                    <ListItem key={`${entry}-${index}`} fontSize="sm" color="gray.600">
                      {entry}
                    </ListItem>
                  ))}
                </List>
              </VStack>
            </CardBody>
          </Card>
        )}

        <Box>
          <Heading size="md" mb={4}>
            Available Bosses (Tier {userTier + 1})
          </Heading>
          <SimpleGrid columns={{ base: 1, md: 2, lg: 4 }} spacing={4}>
            {availableBosses
              .filter(boss => boss.tier === userTier + 1)
              .map(boss => (
                <Card key={boss.id} variant="outline" opacity={boss.defeated ? 0.75 : 1}>
                  <CardBody>
                    <VStack spacing={2}>
                      <Image
                        src={bossImages[boss.image]}
                        alt={boss.name}
                        borderRadius="md"
                        boxSize="150px"
                        objectFit="cover"
                        mb={2}
                      />
                      <Heading size="sm">{boss.name}</Heading>
                      <Badge colorScheme={boss.tier === 1 ? 'green' : 'blue'}>
                        Tier {boss.tier}
                      </Badge>
                      {renderWeakness(boss.weakness)}
                      <Text fontSize="sm">Health: {boss.maxHealth}</Text>
                      {boss.defeated && <Badge colorScheme="gray">Defeated</Badge>}
                      <Button
                        colorScheme="teal"
                        size="sm"
                        width="full"
                        mt={2}
                        onClick={() => startBattle(boss)}
                        isDisabled={!buildSnapshot || !!session}
                      >
                        {boss.defeated && boss.id === 'boss1' ? 'Replay' : 'Battle'}
                      </Button>
                    </VStack>
                  </CardBody>
                </Card>
              ))}
          </SimpleGrid>
        </Box>
      </VStack>
    </Box>
  );
}

function renderWeakness(weakness: Boss['weakness']): React.JSX.Element {
  if (weakness === 'strike') {
    return (
      <HStack spacing={1}>
        <Icon as={FaDumbbell} color="gray.500" boxSize={4} />
        <Text fontSize="sm">Strike</Text>
      </HStack>
    );
  }

  if (weakness === 'core') {
    return (
      <HStack spacing={1}>
        <Icon as={GiSittingDog} color="gray.500" boxSize={4} />
        <Text fontSize="sm">Core</Text>
      </HStack>
    );
  }

  if (weakness === 'endurance') {
    return (
      <HStack spacing={1}>
        <Icon as={FaBolt} color="gray.500" boxSize={4} />
        <Text fontSize="sm">Endurance</Text>
      </HStack>
    );
  }

  return <Text fontSize="sm">Balanced</Text>;
}

function formatAttackName(attackType: AttackType): string {
  if (attackType === 'titan-impact') {
    return 'Titan Impact';
  }

  return attackType === 'heavy' ? 'Heavy attack' : 'Light attack';
}

export default BattleSystem;

