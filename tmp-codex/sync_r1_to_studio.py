import re
from pathlib import Path

from roblox_mcp_call import call_tool


ROOT = Path(r"D:\Users\arnom\Desktop\Coding\HeroApp-1")

EXISTING_SCRIPTS = [
    (
        "ServerScriptService.ZeroToHeroServer.Services.CombatService",
        ROOT / "roblox" / "src" / "server" / "Services" / "CombatService.luau",
    ),
    (
        "ServerScriptService.ZeroToHeroServer.Services.EnemyService",
        ROOT / "roblox" / "src" / "server" / "Services" / "EnemyService.luau",
    ),
]

NEW_SCRIPTS = [
    (
        "ReplicatedStorage.ZeroToHeroShared.Config.FeatureFlags",
        ROOT / "roblox" / "src" / "shared" / "Config" / "FeatureFlags.luau",
        "ModuleScript",
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
        lines.append(re.sub(r"^\s*\d+(?:→|â†’|Ã¢â€ â€™)", "", line, count=1))
    return "\n".join(lines)


def sync_existing(studio_path, source_path):
    read_response = call_tool("script_read", {"target_file": studio_path}, timeout=60)
    old_source = strip_line_numbers(content_text(read_response))
    new_source = source_path.read_text(encoding="utf-8").replace("\r\n", "\n")
    if old_source == new_source:
        print(f"unchanged {studio_path}")
        return

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


def create_or_replace(studio_path, source_path, class_name):
    new_source = source_path.read_text(encoding="utf-8").replace("\r\n", "\n")
    read_response = call_tool("script_read", {"target_file": studio_path}, timeout=60)
    if read_response.get("result", {}).get("isError") is not True:
        old_source = strip_line_numbers(content_text(read_response))
        if old_source == new_source:
            print(f"unchanged {studio_path}")
            return

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
        return

    response = call_tool(
        "multi_edit",
        {
            "file_path": studio_path,
            "datamodel_type": "Edit",
            "className": class_name,
            "edits": [
                {
                    "old_string": "",
                    "new_string": new_source,
                }
            ],
        },
        timeout=90,
    )
    text = content_text(response)
    if response.get("result", {}).get("isError") is True:
        raise RuntimeError(f"multi_edit failed for {studio_path}: {text}")
    print(f"created/replaced {studio_path}: {text[:220]}")


def main():
    for studio_path, source_path, class_name in NEW_SCRIPTS:
        create_or_replace(studio_path, source_path, class_name)
    for studio_path, source_path in EXISTING_SCRIPTS:
        sync_existing(studio_path, source_path)


if __name__ == "__main__":
    main()
