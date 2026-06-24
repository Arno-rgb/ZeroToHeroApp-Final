import {
  MovementFamily,
  TrainingEvent,
  movementFamilies,
} from './training';

export type AttributeName =
  | 'strength'
  | 'force'
  | 'endurance'
  | 'agility'
  | 'stability'
  | 'mobility';

export interface Attributes {
  strength: number;
  force: number;
  endurance: number;
  agility: number;
  stability: number;
  mobility: number;
}

export interface StatSnapshot {
  id: string;
  userId: string;
  rulesVersion: string;
  ledgerRevision: number;
  generatedAt: string;
  attributes: Attributes;
  lifetimeCredited: Record<MovementFamily, number>;
  unlockedAbilityIds: string[];
}

interface MilestonePoint {
  volume: number;
  score: number;
}

interface AttributeRule {
  attribute: AttributeName;
  contributions: Array<{
    movementFamily: MovementFamily;
    multiplier: number;
  }>;
  milestones: MilestonePoint[];
}

export const PROGRESSION_RULES_VERSION = 'progression-v1';

const defaultMilestones: MilestonePoint[] = [
  { volume: 0, score: 1 },
  { volume: 100, score: 5 },
  { volume: 500, score: 12 },
  { volume: 1000, score: 20 },
  { volume: 5000, score: 55 },
  { volume: 10000, score: 100 },
  { volume: 25000, score: 140 },
];

export const progressionRules: AttributeRule[] = [
  {
    attribute: 'strength',
    contributions: [
      { movementFamily: 'upper_strength', multiplier: 1 },
      { movementFamily: 'core', multiplier: 0.15 },
    ],
    milestones: defaultMilestones,
  },
  {
    attribute: 'force',
    contributions: [
      { movementFamily: 'lower_strength', multiplier: 1 },
      { movementFamily: 'upper_strength', multiplier: 0.2 },
    ],
    milestones: defaultMilestones,
  },
  {
    attribute: 'endurance',
    contributions: [
      { movementFamily: 'endurance', multiplier: 1 },
      { movementFamily: 'lower_strength', multiplier: 0.1 },
    ],
    milestones: defaultMilestones,
  },
  {
    attribute: 'agility',
    contributions: [
      { movementFamily: 'endurance', multiplier: 0.7 },
      { movementFamily: 'mobility', multiplier: 0.4 },
      { movementFamily: 'lower_strength', multiplier: 0.15 },
    ],
    milestones: defaultMilestones,
  },
  {
    attribute: 'stability',
    contributions: [
      { movementFamily: 'core', multiplier: 1 },
      { movementFamily: 'lower_strength', multiplier: 0.25 },
    ],
    milestones: defaultMilestones,
  },
  {
    attribute: 'mobility',
    contributions: [
      { movementFamily: 'mobility', multiplier: 1 },
      { movementFamily: 'endurance', multiplier: 0.15 },
    ],
    milestones: defaultMilestones,
  },
];

export function createEmptyLifetimeCredited(): Record<MovementFamily, number> {
  return movementFamilies.reduce((totals, family) => {
    totals[family] = 0;
    return totals;
  }, {} as Record<MovementFamily, number>);
}

export function interpolateMilestone(
  volume: number,
  milestones: MilestonePoint[] = defaultMilestones
): number {
  const sortedMilestones = [...milestones].sort((a, b) => a.volume - b.volume);

  if (volume <= sortedMilestones[0].volume) {
    return sortedMilestones[0].score;
  }

  for (let index = 1; index < sortedMilestones.length; index += 1) {
    const previous = sortedMilestones[index - 1];
    const next = sortedMilestones[index];

    if (volume <= next.volume) {
      const range = next.volume - previous.volume;
      const progress = range === 0 ? 0 : (volume - previous.volume) / range;
      return roundScore(previous.score + progress * (next.score - previous.score));
    }
  }

  const last = sortedMilestones[sortedMilestones.length - 1];
  const overflow = Math.log10(volume / last.volume + 1) * 16;
  return roundScore(last.score + overflow);
}

export function deriveLifetimeCredited(
  events: TrainingEvent[]
): Record<MovementFamily, number> {
  const totals = createEmptyLifetimeCredited();

  for (const event of events) {
    totals[event.movementFamily] += Math.max(0, event.creditedVolume || 0);
  }

  return totals;
}

export function deriveAttributes(
  lifetimeCredited: Record<MovementFamily, number>
): Attributes {
  return progressionRules.reduce(
    (attributes, rule) => {
      const weightedVolume = rule.contributions.reduce(
        (sum, contribution) =>
          sum +
          (lifetimeCredited[contribution.movementFamily] || 0) *
            contribution.multiplier,
        0
      );
      attributes[rule.attribute] = interpolateMilestone(
        weightedVolume,
        rule.milestones
      );
      return attributes;
    },
    {
      strength: 1,
      force: 1,
      endurance: 1,
      agility: 1,
      stability: 1,
      mobility: 1,
    } as Attributes
  );
}

export function deriveUnlockedAbilityIds(
  lifetimeCredited: Record<MovementFamily, number>
): string[] {
  const abilityIds: string[] = [];

  if ((lifetimeCredited.upper_strength || 0) >= 10000) {
    abilityIds.push('titan-impact');
  }

  if ((lifetimeCredited.endurance || 0) >= 10000) {
    abilityIds.push('second-wind');
  }

  return abilityIds;
}

export function deriveStatSnapshot(input: {
  userId: string;
  events: TrainingEvent[];
  ledgerRevision: number;
}): StatSnapshot {
  const lifetimeCredited = deriveLifetimeCredited(input.events);
  return {
    id: input.userId,
    userId: input.userId,
    rulesVersion: PROGRESSION_RULES_VERSION,
    ledgerRevision: input.ledgerRevision,
    generatedAt: new Date().toISOString(),
    attributes: deriveAttributes(lifetimeCredited),
    lifetimeCredited,
    unlockedAbilityIds: deriveUnlockedAbilityIds(lifetimeCredited),
  };
}

export function createDefaultStatSnapshot(
  userId: string,
  ledgerRevision = 0
): StatSnapshot {
  return deriveStatSnapshot({
    userId,
    events: [],
    ledgerRevision,
  });
}

function roundScore(score: number): number {
  return Math.round(score * 10) / 10;
}

