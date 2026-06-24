import { Attributes, StatSnapshot } from './progression';

export type AttackType = 'light' | 'heavy' | 'titan-impact';

export interface BossProfile {
  id: string;
  name: string;
  maxHealth: number;
  weakness: 'strike' | 'core' | 'force' | 'endurance' | 'balanced';
  resistance?: 'strike' | 'core' | 'force' | 'endurance';
}

export interface CombatBuildSnapshot {
  userId: string;
  statRulesVersion: string;
  generatedAt: string;
  attributes: Attributes;
  abilities: string[];
  derived: {
    maxHealth: number;
    maxStamina: number;
    staminaRegenPerSecond: number;
    moveSpeed: number;
    evadeWindowMs: number;
    lightDamage: number;
    heavyDamage: number;
    armourBreak: number;
    poise: number;
    knockback: number;
    titanImpactDamage: number;
  };
}

export interface BattleRecord {
  id: string;
  userId: string;
  bossId: string;
  startedAt: string;
  endedAt: string;
  result: 'victory' | 'defeat' | 'abandoned';
  durationMs: number;
  damageDealt: number;
  damageTaken: number;
  attacksUsed: Record<AttackType, number>;
  evadesAttempted: number;
  evadesSucceeded: number;
  buildSnapshot: CombatBuildSnapshot;
  combatRulesVersion: string;
  seed: string;
}

export const COMBAT_RULES_VERSION = 'combat-v1';

export const staminaCosts: Record<AttackType, number> = {
  light: 8,
  heavy: 18,
  'titan-impact': 60,
};

export function createCombatBuildSnapshot(
  snapshot: StatSnapshot
): CombatBuildSnapshot {
  const { attributes } = snapshot;
  const hasTitanImpact = snapshot.unlockedAbilityIds.includes('titan-impact');

  return {
    userId: snapshot.userId,
    statRulesVersion: snapshot.rulesVersion,
    generatedAt: new Date().toISOString(),
    attributes,
    abilities: [...snapshot.unlockedAbilityIds],
    derived: {
      maxHealth: Math.round(100 + attributes.stability * 4 + attributes.force * 2),
      maxStamina: Math.round(
        100 + attributes.endurance * 5 + attributes.agility * 2
      ),
      staminaRegenPerSecond: round(8 + attributes.endurance * 0.12),
      moveSpeed: round(1 + attributes.agility * 0.012),
      evadeWindowMs: Math.round(180 + attributes.agility * 3.5),
      lightDamage: Math.round(8 + attributes.strength * 0.35 + attributes.agility * 0.1),
      heavyDamage: Math.round(16 + attributes.strength * 0.85 + attributes.force * 0.2),
      armourBreak: round(attributes.strength * 0.35 + attributes.force * 0.25),
      poise: round(10 + attributes.force * 0.45 + attributes.stability * 0.35),
      knockback: round(1 + attributes.strength * 0.025 + attributes.force * 0.015),
      titanImpactDamage: hasTitanImpact
        ? Math.round(140 + attributes.strength * 2 + attributes.force * 0.5)
        : 0,
    },
  };
}

export function canUseAttack(
  build: CombatBuildSnapshot,
  attackType: AttackType,
  stamina: number
): boolean {
  if (attackType === 'titan-impact' && !build.abilities.includes('titan-impact')) {
    return false;
  }

  return stamina >= staminaCosts[attackType];
}

export function calculateAttackDamage(
  build: CombatBuildSnapshot,
  boss: BossProfile,
  attackType: AttackType
): number {
  const baseDamage =
    attackType === 'light'
      ? build.derived.lightDamage
      : attackType === 'heavy'
        ? build.derived.heavyDamage
        : build.derived.titanImpactDamage;

  const attackFamily =
    attackType === 'light'
      ? 'endurance'
      : attackType === 'heavy'
        ? 'strike'
        : 'strike';

  const weaknessMultiplier =
    boss.weakness === 'balanced' || boss.weakness === attackFamily ? 1.2 : 1;
  const resistanceMultiplier = boss.resistance === attackFamily ? 0.75 : 1;

  return Math.max(1, Math.round(baseDamage * weaknessMultiplier * resistanceMultiplier));
}

export function calculateBossDamage(build: CombatBuildSnapshot, baseDamage: number): number {
  const mitigation = Math.min(0.6, build.attributes.stability / 250);
  return Math.max(1, Math.round(baseDamage * (1 - mitigation)));
}

function round(value: number): number {
  return Math.round(value * 10) / 10;
}

