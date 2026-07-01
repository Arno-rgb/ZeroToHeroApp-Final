$ErrorActionPreference = "Stop"

$robloxRoot = Join-Path $env:LOCALAPPDATA "Roblox"
$versionsPath = Join-Path $robloxRoot "Versions"

$mcpExecutable = $null
if (Test-Path -LiteralPath $versionsPath) {
    $mcpExecutable = Get-ChildItem -LiteralPath $versionsPath -Recurse -Filter "StudioMCP.exe" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}

if ($mcpExecutable) {
    & $mcpExecutable.FullName @args
    exit $LASTEXITCODE
}

$officialLauncher = Join-Path $robloxRoot "mcp.bat"
if (Test-Path -LiteralPath $officialLauncher) {
    & cmd.exe /d /c "`"$officialLauncher`"" @args
    exit $LASTEXITCODE
}

if (Test-Path -LiteralPath $versionsPath) {
    [Console]::Error.WriteLine("StudioMCP.exe was not found under $versionsPath. Update Roblox Studio and enable Assistant > Manage MCP Servers.")
} else {
    [Console]::Error.WriteLine("Roblox Studio MCP launcher not found. Install the latest Roblox Studio, enable Assistant > Manage MCP Servers, then restart VS Code.")
    exit 1
}
exit 1
