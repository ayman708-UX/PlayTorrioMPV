# PlayTorrioPlayer - PowerShell Launcher
# Usage: .\playtp.ps1 "video_url"

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$VideoUrl
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigDir = Join-Path $ScriptDir "portable_config"

# Find mpv
$MpvPath = $null

# Check common locations
$locations = @(
    (Join-Path $ScriptDir "mpv.exe"),
    "$env:LOCALAPPDATA\Programs\mpv\mpv.exe",
    "C:\Program Files\mpv\mpv.exe",
    "C:\mpv\mpv.exe"
)

foreach ($loc in $locations) {
    if (Test-Path $loc) {
        $MpvPath = $loc
        break
    }
}

# Try PATH
if (-not $MpvPath) {
    $MpvPath = Get-Command mpv -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

if (-not $MpvPath) {
    Write-Error "mpv not found. Please install mpv or place mpv.exe in this folder."
    Write-Host "Download from: https://mpv.io/installation/"
    exit 1
}

# Launch mpv
& $MpvPath --config-dir="$ConfigDir" $VideoUrl
