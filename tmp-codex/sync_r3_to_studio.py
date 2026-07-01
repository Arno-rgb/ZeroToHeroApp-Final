import re
from pathlib import Path

from roblox_mcp_call import call_tool


ROOT = Path(r"D:\Users\arnom\Desktop\Coding\HeroApp-1")
SCRIPT_PATH = "StarterPlayer.StarterPlayerScripts.ZeroToHeroClient.Controllers.CombatController"
SOURCE_PATH = ROOT / "roblox" / "src" / "client" / "Controllers" / "CombatController.client.luau"


def content_text(response):
    for item in response.get("result", {}).get("content", []):
        if item.get("type") == "text":
            return item.get("text", "")
    return ""


def strip_line_numbers(text):
    lines = []
    for line in text.splitlines():
        lines.append(re.sub(r"^\s*\d+(?:->|â†’|Ã¢â€ â€™|ÃƒÂ¢Ã¢â‚¬Â Ã¢â‚¬â„¢)", "", line, count=1))
    return "\n".join(lines)


def main():
    read_response = call_tool("script_read", {"target_file": SCRIPT_PATH}, timeout=60)
    old_source = strip_line_numbers(content_text(read_response))
    new_source = SOURCE_PATH.read_text(encoding="utf-8").replace("\r\n", "\n")
    if old_source == new_source:
        print(f"unchanged {SCRIPT_PATH}")
        return

    response = call_tool(
        "multi_edit",
        {
            "file_path": SCRIPT_PATH,
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
        raise RuntimeError(f"multi_edit failed for {SCRIPT_PATH}: {text}")
    print(f"synced {SCRIPT_PATH}: {text[:220]}")


if __name__ == "__main__":
    main()
