# PlayTorrioPlayer Launcher
param([Parameter(ValueFromRemainingArguments=$true)][string[]]$AllArgs)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigDir = Join-Path $ScriptDir "portable_config"
$SubsJson = Join-Path $ConfigDir "playtorrio-subs.json"

if ($AllArgs.Count -eq 0) {
    Write-Host "Usage: playtp.cmd `"video_url`" [provider `"subname`" `"suburl`" ...] [provider2 ...]"
    exit 1
}

$VideoUrl = $AllArgs[0]
$RestArgs = if ($AllArgs.Count -gt 1) { $AllArgs[1..($AllArgs.Count-1)] } else { @() }

# Parse providers and subtitles
$providers = @()
$currentProvider = $null
$i = 0

while ($i -lt $RestArgs.Count) {
    $arg = $RestArgs[$i]
    $nextArg = if ($i + 1 -lt $RestArgs.Count) { $RestArgs[$i + 1] } else { $null }
    
    # Check if next arg is a URL (subtitle URL)
    if ($nextArg -and $nextArg -match '^https?://') {
        # This is a subtitle name, next is URL
        if (-not $currentProvider) {
            $currentProvider = @{ name = "External"; subtitles = @() }
        }
        $currentProvider.subtitles += @{ name = $arg; url = $nextArg }
        $i += 2
    } else {
        # This is a provider name
        if ($currentProvider -and $currentProvider.subtitles.Count -gt 0) {
            $providers += $currentProvider
        }
        $currentProvider = @{ name = $arg; subtitles = @() }
        $i += 1
    }
}

# Add last provider
if ($currentProvider -and $currentProvider.subtitles.Count -gt 0) {
    $providers += $currentProvider
}

# Write JSON
$json = @{ providers = $providers } | ConvertTo-Json -Depth 4 -Compress
$json | Out-File -FilePath $SubsJson -Encoding UTF8 -NoNewline

# Find mpv
$MpvPath = $null
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

if (-not $MpvPath) {
    $MpvPath = (Get-Command mpv -ErrorAction SilentlyContinue).Source
}

if (-not $MpvPath) {
    Write-Error "mpv not found"
    exit 1
}

& $MpvPath --config-dir="$ConfigDir" $VideoUrl
