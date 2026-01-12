@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "CONFIG_DIR=%SCRIPT_DIR%portable_config"
set "SUBS_JSON=%CONFIG_DIR%\playtorrio-subs.json"

set "VIDEO_URL=%~1"
if "%VIDEO_URL%"=="" (
    echo Usage: playtpm "video_url" [provider "subname" "suburl" ...] [provider2 ...]
    exit /b 1
)

:: Create JSON file with providers
echo {"providers":[> "%SUBS_JSON%"

set "FIRST_PROV=1"
set "FIRST_SUB=1"
set "HAS_PROVIDER=0"

:: Skip first arg (video URL), process rest
shift

:loop
if "%~1"=="" goto :done

set "ARG=%~1"
set "NEXT=%~2"

:: Check if we have two args and NEXT looks like a URL or any value (for subtitle)
if not "%NEXT%"=="" (
    :: Check if ARG could be a provider name (next next arg exists or next is a URL)
    set "NEXTNEXT=%~3"
    
    :: If NEXT starts with http, ARG is subtitle name
    echo.!NEXT!| findstr /i "^http" >nul 2>&1
    if !errorlevel!==0 (
        :: NEXT is URL, ARG is subtitle name
        if "!HAS_PROVIDER!"=="0" (
            echo {"name":"External","subtitles":[>> "%SUBS_JSON%"
            set "FIRST_PROV=0"
            set "HAS_PROVIDER=1"
            set "FIRST_SUB=1"
        )
        if "!FIRST_SUB!"=="0" echo ,>> "%SUBS_JSON%"
        echo {"name":"!ARG!","url":"!NEXT!"}>> "%SUBS_JSON%"
        set "FIRST_SUB=0"
        shift
        shift
        goto :loop
    ) else (
        :: NEXT is not a URL
        :: Check if NEXTNEXT exists - if so, this might be provider + subname + suburl pattern
        if not "!NEXTNEXT!"=="" (
            echo.!NEXTNEXT!| findstr /i "^http" >nul 2>&1
            if !errorlevel!==0 (
                :: NEXTNEXT is URL, so ARG is provider, NEXT is subname
                if "!HAS_PROVIDER!"=="1" (
                    echo ]}>> "%SUBS_JSON%"
                    echo ,>> "%SUBS_JSON%"
                )
                echo {"name":"!ARG!","subtitles":[>> "%SUBS_JSON%"
                set "FIRST_PROV=0"
                set "HAS_PROVIDER=1"
                set "FIRST_SUB=1"
                shift
                goto :loop
            ) else (
                :: NEXTNEXT is also not URL - ARG is provider with non-http subtitle
                if "!HAS_PROVIDER!"=="1" (
                    echo ]}>> "%SUBS_JSON%"
                    echo ,>> "%SUBS_JSON%"
                )
                echo {"name":"!ARG!","subtitles":[>> "%SUBS_JSON%"
                set "FIRST_PROV=0"
                set "HAS_PROVIDER=1"
                set "FIRST_SUB=1"
                :: Add the subtitle with non-http url
                echo {"name":"!NEXT!","url":"!NEXTNEXT!"}>> "%SUBS_JSON%"
                set "FIRST_SUB=0"
                shift
                shift
                shift
                goto :loop
            )
        ) else (
            :: No NEXTNEXT, just two args left - treat as subname + url
            if "!HAS_PROVIDER!"=="0" (
                echo {"name":"External","subtitles":[>> "%SUBS_JSON%"
                set "FIRST_PROV=0"
                set "HAS_PROVIDER=1"
                set "FIRST_SUB=1"
            )
            if "!FIRST_SUB!"=="0" echo ,>> "%SUBS_JSON%"
            echo {"name":"!ARG!","url":"!NEXT!"}>> "%SUBS_JSON%"
            set "FIRST_SUB=0"
            shift
            shift
            goto :loop
        )
    )
) else (
    :: Only one arg left - it's a provider name with no subs
    if "!HAS_PROVIDER!"=="1" (
        echo ]}>> "%SUBS_JSON%"
        echo ,>> "%SUBS_JSON%"
    )
    echo {"name":"!ARG!","subtitles":[]}>> "%SUBS_JSON%"
    set "FIRST_PROV=0"
    set "HAS_PROVIDER=1"
    shift
    goto :loop
)

:done
if "!HAS_PROVIDER!"=="1" (
    echo ]}>> "%SUBS_JSON%"
)
echo ]}>> "%SUBS_JSON%"

:: Find mpv
set "MPV_PATH="
if exist "%SCRIPT_DIR%mpv.exe" set "MPV_PATH=%SCRIPT_DIR%mpv.exe"
if "!MPV_PATH!"=="" if exist "%LOCALAPPDATA%\Programs\mpv\mpv.exe" set "MPV_PATH=%LOCALAPPDATA%\Programs\mpv\mpv.exe"
if "!MPV_PATH!"=="" if exist "C:\Program Files\mpv\mpv.exe" set "MPV_PATH=C:\Program Files\mpv\mpv.exe"
if "!MPV_PATH!"=="" if exist "C:\mpv\mpv.exe" set "MPV_PATH=C:\mpv\mpv.exe"
if "!MPV_PATH!"=="" (
    for /f "delims=" %%i in ('where mpv 2^>nul') do set "MPV_PATH=%%i"
)

if "!MPV_PATH!"=="" (
    echo Error: mpv not found
    exit /b 1
)

"!MPV_PATH!" --config-dir="%CONFIG_DIR%" "%VIDEO_URL%"
endlocal
