# Roblox Studio MCP Setup for VS Code

## Purpose

This repo includes a VS Code workspace MCP configuration so an AI coding client in VS Code can connect to the built-in Roblox Studio MCP server.

Use this for Roblox prototyping and Studio-side design work. It does not turn the current React coach demo into a Roblox project. The Roblox game remains a separate build path documented in `docs/roblox/master_game_spec.md` and tracked in `docs/roblox/progression_tracker.md`.

## Files Added

- `.vscode/mcp.json` - VS Code workspace MCP server config for Roblox Studio.
- `tools/roblox-studio-mcp.ps1` - Windows launcher that finds the current Roblox Studio MCP executable.
- `docs/roblox_studio_mcp_vscode_setup.md` - this setup guide.

The repo uses Roblox Studio's built-in MCP server. Do not use the older `Roblox/studio-rust-mcp-server`; Roblox archived that repository and now recommends the built-in Studio MCP server.

## Prerequisites

- Latest Roblox Studio.
- VS Code with MCP support enabled.
- A Roblox place open in Studio.

## Enable MCP in Roblox Studio

1. Open Roblox Studio.
2. Open Assistant.
3. Click `...` then `Manage MCP Servers`.
4. Turn on `Enable Studio as MCP server`.
5. Keep Roblox Studio open while working from VS Code.

Roblox Studio should show a green connected-client indicator after VS Code connects.

## VS Code Configuration

The workspace config is:

```json
{
  "servers": {
    "robloxStudio": {
      "type": "stdio",
      "command": "powershell.exe",
      "args": [
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        "${workspaceFolder}\\tools\\roblox-studio-mcp.ps1"
      ]
    }
  }
}
```

This adapts Roblox's Windows MCP setup to VS Code's `.vscode/mcp.json` format, which uses a top-level `servers` object.

The PowerShell launcher finds the newest installed `StudioMCP.exe` under `%LOCALAPPDATA%\Roblox\Versions` first. If that executable is missing, it falls back to Roblox's documented `%LOCALAPPDATA%\Roblox\mcp.bat`.

## Start the Server in VS Code

1. Open this repo in VS Code.
2. Press `Ctrl+Shift+P`.
3. Run `MCP: List Servers`.
4. Select `robloxStudio`.
5. Start or restart the server.
6. In Roblox Studio, confirm the MCP connection indicator is green.

If VS Code asks whether to trust or allow the MCP server, review the request and approve it only when you intend the AI client to read or modify the open Roblox place.

## Local Check

On Windows, the command depends on this file:

```text
%LOCALAPPDATA%\Roblox\mcp.bat
```

This machine currently has `StudioMCP.exe` installed under the Roblox `Versions` folder. The generated `mcp.bat` launcher can be malformed on some installs, so the repo launcher prefers the executable directly and uses the batch file only as a fallback.

If both files are missing, update Roblox Studio, enable the Studio MCP server from Assistant, restart Studio, and check again.

## Useful MCP Capabilities

Once connected, the AI client can help with Studio tasks such as:

- Explore the open Roblox game tree.
- Read and edit Luau scripts.
- Search scripts.
- Execute Luau snippets in Studio.
- Insert Creator Store assets.
- Start and stop playtesting.
- Read console output.
- Capture the playtest viewport.
- Switch between multiple open Studio instances.

## Safety Rules for This Project

- Treat Studio MCP as powerful: it can read and change the open Roblox place.
- Keep valuable game state server-authoritative when building the Roblox game.
- Do not let MCP-generated code decide rewards, purchases, inventory, combat damage, or player data without review.
- Use Studio MCP for design iteration, prototypes, scripts, and testing, not as a replacement for source control or server validation.

## First Roblox Design Task

The first design target should stay narrow:

1. Create a compact Ascension Grounds test place.
2. Add the Strength Forge training station.
3. Add five visible stats starting at 0.
4. Show immediate stat gain feedback.
5. Add one sword, one enemy, and one equipment drop.
6. Confirm earned training stats visibly improve combat.

## Build From The Spec

Codex project instructions are now in `AGENTS.md`. When you start a new Codex session from this repo, Codex should read those instructions before working.

For repeatable Roblox Studio work, use the prompt in:

```text
docs/roblox_build_from_spec_prompt.md
```

That prompt tells Codex to read the game spec, inspect the open Studio place, build only the current milestone or next smallest missing feature, update the Roblox progress files, test in play mode, and summarize what changed.

For Roblox visual, UI, HUD, area, station, or reward-popup work, Codex should also read:

```text
docs/roblox/visual_direction.md
roblox/assets/reference/roblox
```

The reference images are direction only. They should guide mood, layout, color, hierarchy, and readability, not be copied exactly.
