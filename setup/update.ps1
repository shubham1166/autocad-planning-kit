# Pull the latest skills and AutoCAD MCP server.
#   powershell -ExecutionPolicy Bypass -File setup\update.ps1

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot

git -C $RepoRoot pull --ff-only
claude plugin marketplace update autocad-planning-kit
claude plugin update uk-planning-cad@autocad-planning-kit

if (Test-Path "C:\autocad-mcp") {
    git -C "C:\autocad-mcp" pull --ff-only
    Push-Location "C:\autocad-mcp"; uv sync --python 3.12; Pop-Location
}
Write-Host "Updated. Restart Claude Code and reload the LISP files in AutoCAD (APPLOAD) if they changed." -ForegroundColor Green
