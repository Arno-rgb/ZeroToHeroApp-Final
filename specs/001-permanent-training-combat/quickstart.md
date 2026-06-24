# Quickstart

## 1. Back up and branch

```bash
git checkout main
git pull
git checkout -b 001-permanent-training-combat
```

Export the existing IndexedDB save before enabling migrations.

## 2. Initialize Spec Kit

Choose the integration you use:

```bash
specify init . --force --integration codex --integration-options="--skills"
```

or:

```bash
specify init . --force --integration copilot
```

## 3. Install testing and game dependencies

```bash
npm install three
npm install -D vitest @vitest/coverage-v8 jsdom \
  @testing-library/react @testing-library/jest-dom \
  @testing-library/user-event playwright
```

Update scripts:

```json
{
  "scripts": {
    "dev": "vite",
    "typecheck": "tsc --noEmit",
    "build": "tsc && vite build",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "test:e2e": "playwright test",
    "preview": "vite preview"
  }
}
```

## 4. Run Spec Kit refinement

```text
/speckit.constitution
/speckit.specify
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.analyze
```

Clarification questions should focus only on unresolved product choices:

1. Should walking contribute to both Endurance and Agility?
2. Should Titan Impact be once per battle or require a temporary rage meter?
3. Should unverified manual volume unlock all single-player abilities?
4. Is the first public visual direction low-poly 3D or stylized silhouette 3D?
5. What Android device is the minimum performance target?

## 5. Implement only through the vertical-slice gate

```text
/speckit.implement
```

Stop after one boss and conduct the five-person feel test. Do not add guilds, raids, accounts or a marketplace before the result is known.

## 6. Validate

```bash
npm run typecheck
npm test
npm run build
npm run test:e2e
```

Manual proof:

1. Start with a clean profile.
2. Record 100 credited push-ups.
3. Confirm Strength changes.
4. Reload.
5. Confirm Strength remains.
6. Fight the first boss and record damage.
7. Load a 10,000-push-up fixture.
8. Confirm Titan Impact unlocks.
9. One-shot the first boss.
10. Load a running-specialist fixture.
11. Confirm faster action and better evasion without the Strength one-shot.
12. Go offline and repeat the core loop.
