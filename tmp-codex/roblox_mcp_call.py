import json
import base64
import os
import subprocess
import sys
import threading
import time
from queue import Empty, Queue


ROOT = r"D:\Users\arnom\Desktop\Coding\HeroApp-1"
DEFAULT_STUDIO_ID = "daf06854-250b-4b0a-9020-5db184f1c1be"
CMD = [
    "powershell.exe",
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    r".\tools\roblox-studio-mcp.ps1",
    "--stdio",
]


def _reader(stream, queue):
    for line in stream:
        queue.put(line)


def _send(proc, message):
    proc.stdin.write(json.dumps(message, separators=(",", ":")) + "\n")
    proc.stdin.flush()


def _read_json(queue, wanted_id=None, timeout=30):
    deadline = time.time() + timeout
    seen = []
    while time.time() < deadline:
        try:
            line = queue.get(timeout=0.1)
        except Empty:
            continue

        line = line.strip()
        if not line:
            continue
        try:
            message = json.loads(line)
        except json.JSONDecodeError:
            seen.append(line)
            continue
        if wanted_id is None or message.get("id") == wanted_id:
            return message
        seen.append(message)
    raise TimeoutError(f"Timed out waiting for MCP response id={wanted_id}; seen={seen[:5]}")


def call_tool(name, arguments, timeout=60, studio_id=DEFAULT_STUDIO_ID):
    proc = subprocess.Popen(
        CMD,
        cwd=ROOT,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1,
    )
    out_queue = Queue()
    err_queue = Queue()
    threading.Thread(target=_reader, args=(proc.stdout, out_queue), daemon=True).start()
    threading.Thread(target=_reader, args=(proc.stderr, err_queue), daemon=True).start()

    try:
        _send(
            proc,
            {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "protocolVersion": "2024-11-05",
                    "capabilities": {},
                    "clientInfo": {"name": "codex-shell", "version": "0.1"},
                },
            },
        )
        _read_json(out_queue, wanted_id=1, timeout=10)
        _send(proc, {"jsonrpc": "2.0", "method": "notifications/initialized", "params": {}})
        time.sleep(8.0)
        next_id = 2
        if name not in {"list_roblox_studios", "set_active_studio"} and studio_id:
            _send(
                proc,
                {
                    "jsonrpc": "2.0",
                    "id": next_id,
                    "method": "tools/call",
                    "params": {
                        "name": "set_active_studio",
                        "arguments": {"studio_id": studio_id},
                    },
                },
            )
            _read_json(out_queue, wanted_id=next_id, timeout=timeout)
            next_id += 1

        _send(
            proc,
            {
                "jsonrpc": "2.0",
                "id": next_id,
                "method": "tools/call",
                "params": {"name": name, "arguments": arguments},
            },
        )
        return _read_json(out_queue, wanted_id=next_id, timeout=timeout)
    finally:
        try:
            proc.stdin.close()
        except Exception:
            pass
        try:
            proc.terminate()
            proc.wait(timeout=3)
        except Exception:
            proc.kill()


def list_tools(timeout=30):
    proc = subprocess.Popen(
        CMD,
        cwd=ROOT,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1,
    )
    out_queue = Queue()
    err_queue = Queue()
    threading.Thread(target=_reader, args=(proc.stdout, out_queue), daemon=True).start()
    threading.Thread(target=_reader, args=(proc.stderr, err_queue), daemon=True).start()

    try:
        _send(
            proc,
            {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "protocolVersion": "2024-11-05",
                    "capabilities": {},
                    "clientInfo": {"name": "codex-shell", "version": "0.1"},
                },
            },
        )
        _read_json(out_queue, wanted_id=1, timeout=10)
        _send(proc, {"jsonrpc": "2.0", "method": "notifications/initialized", "params": {}})
        time.sleep(8.0)
        _send(proc, {"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}})
        return _read_json(out_queue, wanted_id=2, timeout=timeout)
    finally:
        try:
            proc.stdin.close()
        except Exception:
            pass
        try:
            proc.terminate()
            proc.wait(timeout=3)
        except Exception:
            proc.kill()


def main():
    if len(sys.argv) < 2:
        raise SystemExit("usage: roblox_mcp_call.py TOOL_NAME [JSON_ARGUMENTS] [TIMEOUT_SECONDS]")
    tool_name = sys.argv[1]
    if tool_name == "__list_tools":
        response = list_tools()
        tools = response.get("result", {}).get("tools", [])
        print(json.dumps([tool.get("name") for tool in tools], indent=2))
        return
    if tool_name == "__tool_schema":
        if len(sys.argv) < 3:
            raise SystemExit("usage: roblox_mcp_call.py __tool_schema TOOL_NAME")
        response = list_tools()
        target = sys.argv[2]
        for tool in response.get("result", {}).get("tools", []):
            if tool.get("name") == target:
                print(json.dumps(tool, indent=2))
                return
        raise SystemExit(f"tool not found: {target}")
    timeout = 60
    if len(sys.argv) >= 3 and not sys.argv[2].startswith("b64:") and "=" in sys.argv[2]:
        args = {}
        for raw_pair in sys.argv[2:]:
            if "=" not in raw_pair:
                continue
            key, value = raw_pair.split("=", 1)
            if key == "jsonfile":
                with open(value, "r", encoding="utf-8") as handle:
                    args.update(json.load(handle))
                continue
            if key == "codefile":
                with open(value, "r", encoding="utf-8") as handle:
                    args["code"] = handle.read()
                continue
            if key == "new_string_file":
                with open(value, "r", encoding="utf-8") as handle:
                    args.setdefault("edits", []).append(
                        {
                            "old_string": args.pop("old_string", ""),
                            "new_string": handle.read(),
                        }
                    )
                continue
            lowered = value.lower()
            if lowered == "true":
                args[key] = True
            elif lowered == "false":
                args[key] = False
            elif "," in value:
                pieces = value.split(",")
                parsed = []
                ok = True
                for piece in pieces:
                    try:
                        parsed.append(float(piece))
                    except ValueError:
                        ok = False
                        break
                args[key] = parsed if ok else value
            else:
                try:
                    args[key] = int(value)
                except ValueError:
                    try:
                        args[key] = float(value)
                    except ValueError:
                        args[key] = value
    elif len(sys.argv) >= 3:
        raw_args = sys.argv[2]
        if raw_args.startswith("b64:"):
            raw_args = base64.b64decode(raw_args[4:]).decode("utf-8")
        args = json.loads(raw_args)
    else:
        args = {}
    if len(sys.argv) >= 4 and not sys.argv[-1].startswith("b64:") and "=" not in sys.argv[-1]:
        try:
            timeout = float(sys.argv[-1])
        except ValueError:
            timeout = 60
    response = call_tool(tool_name, args, timeout)
    for item in response.get("result", {}).get("content", []):
        if item.get("type") == "image" and "data" in item:
            capture_id = args.get("capture_id") or tool_name
            extension = ".png"
            mime_type = item.get("mimeType") or item.get("mime_type")
            if mime_type == "image/jpeg":
                extension = ".jpg"
            output_dir = os.path.join(ROOT, "tmp-codex", "screens")
            os.makedirs(output_dir, exist_ok=True)
            output_path = os.path.join(output_dir, f"{capture_id}{extension}")
            with open(output_path, "wb") as handle:
                handle.write(base64.b64decode(item["data"]))
            item["savedPath"] = output_path
            item["dataLength"] = len(item["data"])
            item["data"] = "<image data suppressed>"
    print(json.dumps(response, indent=2))


if __name__ == "__main__":
    main()
