# One-time setup for Windows 10 (1809+) / Windows 11.
# Run from the repo folder in Command Prompt:
#   setup\setup.cmd
#
# Installs: Windows Terminal, Git, uv (Python manager), Claude Code,
# the AutoCAD MCP server, and this repo's skills as a Claude Code plugin.
# Safe to run again; it skips anything already installed.

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$McpDir = "C:\autocad-mcp"
$McpRepo = "https://github.com/beiming183-cloud/AutoCAD-MCP.git"

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [Environment]::GetEnvironmentVariable("Path", "User") + ";" +
                "$env:USERPROFILE\.local\bin"
}
function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

Step "Checking Windows version"
$build = [Environment]::OSVersion.Version.Build
if ($build -lt 17763) {
    throw "Windows build $build is too old. Claude Code needs Windows 10 version 1809 (build 17763) or newer. Run Windows Update first."
}
Write-Host "Windows build $build - OK"

if (-not (Have "winget")) {
    throw "winget is missing. Install 'App Installer' from the Microsoft Store, then run this script again."
}

Step "Installing Windows Terminal, Git and uv"
foreach ($id in @("Microsoft.WindowsTerminal", "Git.Git", "astral-sh.uv")) {
    winget install --id $id -e --accept-source-agreements --accept-package-agreements --silent
}
Refresh-Path

Step "Installing Claude Code"
if (-not (Have "claude")) {
    Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
    Refresh-Path
}

# Make sure %USERPROFILE%\.local\bin (where claude.exe lives) is on the user PATH permanently
$bin = "$env:USERPROFILE\.local\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not $userPath) { $userPath = "" }
if (($userPath -split ";") -notcontains $bin) {
    [Environment]::SetEnvironmentVariable("Path", ($userPath.TrimEnd(";") + ";" + $bin).TrimStart(";"), "User")
    Write-Host "Added $bin to your PATH"
}
claude --version

Step "Installing the AutoCAD MCP server into $McpDir"
if (-not (Test-Path $McpDir)) {
    git clone $McpRepo $McpDir
} else {
    git -C $McpDir pull --ff-only
}
Push-Location $McpDir
uv sync
Pop-Location

# Folder the MCP server and the AutoCAD-side LISP use to talk to each other
New-Item -ItemType Directory -Force -Path "C:\temp" | Out-Null

Step "Registering the AutoCAD MCP server with Claude Code"
$py = Join-Path $McpDir ".venv\Scripts\python.exe"
try { claude mcp remove autocad --scope user 2>&1 | Out-Null } catch { }
claude mcp add autocad --scope user -e AUTOCAD_MCP_BACKEND=file_ipc -- $py -m autocad_mcp

Step "Installing the planning skills plugin"
claude plugin marketplace add $RepoRoot
claude plugin install uk-planning-cad@autocad-planning-kit

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Last step, inside AutoCAD (once):"
Write-Host "  1. Type APPLOAD"
Write-Host "  2. Load  $McpDir\lisp-code\mcp_dispatch.lsp"
Write-Host "  3. Load  $RepoRoot\plugins\uk-planning-cad\skills\autolisp-tools\lisp\planning-tools.lsp"
Write-Host "  4. Click 'Contents...' under Startup Suite and add both files so they load every time"
Write-Host ""
Write-Host "Then CLOSE this window, open a new Command Prompt tab in Windows Terminal, and type:  claude"
