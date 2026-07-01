# R2 Legacy Cleanup Examples

These examples document the R2 checks run through Roblox Studio MCP on 2026-06-30. They are not a standalone automated test suite yet.

## Edit-Mode Audit

Confirm these scripts exist, are disabled, and carry R2 review attributes:

- `StarterPlayer.StarterPlayerScripts.AscensionTrainingFeedbackClient`
- `StarterPlayer.StarterPlayerScripts.AscensionSwordCombatClient`
- `ServerScriptService.AscensionTrainingFeedbackServer`
- `ServerScriptService.AscensionSwordCombatServer`
- `ServerScriptService.AscensionStrengthForgeTrainingServer`
- `ServerScriptService.EnemyArea.server`
- `ServerScriptService.PlayerStats.server`
- `ServerScriptService.StrengthForge.server`
- `ServerScriptService.AscensionPlayerProfileServer`

Expected attributes:

- `R2LegacyStatus`
- `R2ReviewedOn`
- `CanonicalReplacement`
- `R2DisableReason`

`ReplicatedStorage.AscensionRemotes` and `ReplicatedStorage.AscensionRemotes.StatChanged` should remain present with `R2LegacyStatus = RetainedLegacyBridge`.

## Server Runtime Checks

In Play mode, from the server command context:

1. Require and start `PlayerDataService`, `TrainingStationService`, `CombatService`, `EnemyService`, `InventoryService`, and `LootService`.
2. Assert all R2 legacy scripts are disabled at runtime.
3. Assert `ReplicatedStorage.AscensionRemotes.StatChanged` exists, but `SwordAttack` and `SwordCombatFeedback` do not.
4. Assert `ServerScriptService.AscensionTrainingEvents` does not exist.
5. Assert exactly one of each canonical RemoteEvent exists under `ReplicatedStorage.ZeroToHeroShared.Remotes`:
   - `TrainingStationReward`
   - `TrainingStationChallenge`
   - `TrainingStationAction`
   - `CombatAction`
   - `CombatFeedback`
   - `InventorySnapshot`
   - `InventoryAction`
6. Move the player into Strength Forge range, start `TrainingStationService.StartStationMinigame(player, "StrengthForge")`, submit three server-timed successful reps, and assert Power advances.
7. Move the player to `LesserSlime`, call `CombatService.TryBasicAttack(player, slime)`, and assert health changes once by the returned `Damage`.
8. Set the slime to 1 HP, wait for cooldown, call `CombatService.TryBasicAttack(player, slime)`, and assert death grants Hero XP once.
9. Wait for cooldown, attack the defeated slime again, and assert `TargetDefeated` with no extra Hero XP, Hero Level, or Gold.
10. Call `InventoryService.AddItem(player, "slime_cleaned_saber", { Display = true })`, assert inventory count increases by one, and assert equipped weapon is unchanged.

Observed R2 server result:

```text
R2_RUNTIME_SERVER_OK TrainingXPGained=147 firstHit=42->29 enemyHero=1/0->1/12 inventory=0->1 equipmentWeapon=false->false
```

## Client Runtime Checks

In Play mode, from the client command context after the server flow:

1. Assert exactly one `RewardPopupGui`, `CombatControllerGui`, `TrainingStatsHudGui`, `InventoryPanelGui`, and `StrengthForgeMinigameGui` exists in `PlayerGui`.
2. Assert zero `AscensionTrainingFeedbackGui` and zero `AscensionCombatFeedbackGui` exist in `PlayerGui`.
3. Assert `RewardPopupGui.LastRewardTitle` is non-empty and the final R2 run records `Slime Defeated`.
4. Assert `TrainingStatsHudGui.Panel.Rows.PowerRow.Level.Text == "Lv 1"`.
5. Assert `InventoryPanelGui.ItemCount == 1`.
6. Assert `InventoryPanelGui.WeaponEquipped == ""`.
7. Recheck canonical RemoteEvents exist exactly once and legacy sword remotes do not exist.

Observed R2 client result:

```text
R2_RUNTIME_CLIENT_OK RewardLastTitle=Slime Defeated PowerLevelText=Lv 1 InventoryItemCount=1 legacyTrainingGui=0 legacyCombatGui=0
```

## Manual Follow-Up

- Run a hands-on desktop Strength Forge completion, combat hit, slime defeat, reward popup, and inventory open/close pass.
- Run the same pass in a touch/mobile viewport.
- Confirm no old training or combat overlay appears during prompt use, reward display, or sword/combat input.
- Save the Roblox place in Studio after the MCP changes.
