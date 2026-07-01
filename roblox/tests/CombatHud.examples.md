# Combat HUD Manual Examples

Run these checks in Roblox Studio after milestone 4.3 is installed.

## Runtime Tree Checks

Start Play mode with one player, then confirm:

```luau
local Players = game:GetService("Players")
local player = Players:GetPlayers()[1]

assert(player.CombatState)
assert(player.CombatState.HP)
assert(player.CombatState.MaxHP)
assert(player.CombatState.Stamina)
assert(player.CombatState.MaxStamina)
assert(player.CombatState.AttackCooldownMs)
assert(player.CombatState.DodgeCooldownMs)
assert(player.CombatState.IsGuarding)

local gui = player.PlayerGui.CombatControllerGui
assert(gui.ResourcePanel.HP)
assert(gui.ResourcePanel.Stamina)
assert(gui.Controls.AttackButton)
assert(gui.Controls.GuardButton)
assert(gui.Controls.DodgeButton)
assert(gui.Controls.Skill1Button)
assert(gui.Controls.Skill2Button)
assert(gui.Controls.UltimateButton)
assert(gui.Controls.InteractButton)
```

## Hands-On Viewport Checks

1. Start Play mode.
2. Walk from spawn toward `Workspace.AscensionGrounds.EnemyArea.TrainingDummy`.
3. Confirm the combat HUD appears near the enemy area and stays hidden or reduced away from combat.
4. Confirm HP and stamina bars are readable on a phone-sized viewport.
5. Tap `ATK`, `GUARD`, and `DODGE`; the same server-approved actions from milestone 4.2 should fire.
6. Confirm `SK1`, `SK2`, `ULT`, and `USE` are visible placeholders and do not trigger valuable state changes.
7. Rapidly attack and dodge; cooldown overlays should show readable countdowns.
8. Confirm buttons do not overlap the Strength Forge minigame panel, Training Stats HUD, or Reward Popup in common phone and desktop layouts.

Expected result: the HUD provides mobile-readable HP, stamina, core combat controls, placeholder skill slots, and cooldown feedback while server systems remain authoritative.
