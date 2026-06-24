# Ready-to-use Spec Kit Prompts

## Constitution

```text
/speckit.constitution Establish principles for an offline-first fitness action RPG. Real-world training events are the immutable source of permanent attributes. Combat can consume temporary stamina but can never spend permanent exercise progress. Different exercises must create materially different action-combat builds. Progression must use diminishing returns and safe credited-volume policies. Domain formulas must be deterministic, versioned and tested. Existing Dexie data must migrate without loss. Public characters and branding must be original.
```

## Specify

```text
/speckit.specify Refactor the existing Zero to Hero Fitness browser prototype so recorded real-world exercise permanently changes action combat. Push-up training increases heavy damage, knockback and armour break; running increases stamina, action speed and dodge capability; lower-body training increases force and poise; core work increases defence and stagger resistance. Permanent attributes are derived from an immutable lifetime training ledger and cannot be spent in battle. The first vertical slice contains one original boss, light/heavy attacks, a timed evade, and a 10,000 credited lifetime push-up milestone called Titan Impact that can one-shot the first boss. Preserve existing local user, exercise and battle records through migration. Keep the core offline and account-free.
```

## Clarify

```text
/speckit.clarify Resolve only decisions that block the permanent-training vertical slice. Do not introduce accounts, payments, PvP, guilds, raids, leaderboards, marketplaces or production sensor verification.
```

## Plan

```text
/speckit.plan Use the existing React 18, TypeScript, Vite, Redux Toolkit, Chakra UI, Framer Motion and Dexie stack. Keep Three.js for the first vertical slice, but move the standalone public HTML game into typed Vite modules rendered inside React. Add a Dexie v2 append-only TrainingEvent ledger, versioned progression rules, rebuildable stat snapshots, typed combat build snapshots, Vitest domain tests, React Testing Library integration tests and Playwright mobile/offline tests. Treat current URL parameters and postMessage wildcard flow as temporary defects to remove.
```

## Tasks

```text
/speckit.tasks Generate tasks in strict dependency order: stabilize existing TypeScript and date persistence; add tests; migrate Dexie v1 to a training ledger; implement permanent attribute derivation; integrate the battle runtime; add action feedback; persist battle results; add offline support; then conduct a five-person feel test. Mark parallel tasks only where they do not touch the same files.
```

## Analyze

```text
/speckit.analyze Check that every requirement has one or more tasks, that permanent stats can never be decremented, that migration and rollback are covered, that the first boss one-shot milestone is testable, and that out-of-scope platform features have not entered the plan.
```

## Implement

```text
/speckit.implement Implement the tasks in order. Stop and report any migration data-loss risk, source compilation failure, or requirement conflict. Do not expand scope beyond the single-player vertical slice.
```

## Converge

```text
/speckit.converge Compare the implemented code against the constitution, specification, plan and tasks. Append only concrete remaining work needed for the vertical-slice definition of done.
```
