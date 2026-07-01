import re
from pathlib import Path

from roblox_mcp_call import call_tool


ROOT = Path(r"D:\Users\arnom\Desktop\Coding\HeroApp-1")

SCRIPTS = [
    (
        "ReplicatedStorage.ZeroToHeroShared.Config.EnemyConfig",
        ROOT / "roblox" / "src" / "shared" / "Config" / "EnemyConfig.luau",
    ),
    (
        "ReplicatedStorage.ZeroToHeroShared.Config.CombatActionConfig",
        ROOT / "roblox" / "src" / "shared" / "Config" / "CombatActionConfig.luau",
    ),
    (
        "ServerScriptService.ZeroToHeroServer.Services.CombatService",
        ROOT / "roblox" / "src" / "server" / "Services" / "CombatService.luau",
    ),
    (
        "ServerScriptService.ZeroToHeroServer.Services.EnemyService",
        ROOT / "roblox" / "src" / "server" / "Services" / "EnemyService.luau",
    ),
]


def content_text(response):
    for item in response.get("result", {}).get("content", []):
        if item.get("type") == "text":
            return item.get("text", "")
    return ""


def strip_line_numbers(text):
    lines = []
    for line in text.splitlines():
        lines.append(re.sub(r"^\s*\d+(?:â†’|→)", "", line, count=1))
    return "\n".join(lines)


def main():
    for studio_path, source_path in SCRIPTS:
        read_response = call_tool("script_read", {"target_file": studio_path}, timeout=60)
        old_source = strip_line_numbers(content_text(read_response))
        new_source = source_path.read_text(encoding="utf-8").replace("\r\n", "\n")
        if old_source == new_source:
            print(f"unchanged {studio_path}")
            continue

        response = call_tool(
            "multi_edit",
            {
                "file_path": studio_path,
                "datamodel_type": "Edit",
                "edits": [
                    {
                        "old_string": old_source,
                        "new_string": new_source,
                    }
                ],
            },
            timeout=90,
        )
        text = content_text(response)
        if response.get("result", {}).get("isError") is True:
            raise RuntimeError(f"multi_edit failed for {studio_path}: {text}")
        print(f"synced {studio_path}: {text[:220]}")


if __name__ == "__main__":
    main()
