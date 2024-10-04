@REM @echo off
@echo on
@REM Run as administrator.

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    @REM winget settings --enable InstallerHashOverride

    winget install --ignore-security-hash -e -id Alacritty.Alacritty
    winget install --ignore-security-hash -e -id Amazon.Kindle
    winget install --ignore-security-hash -e -id LINE.LINE
    winget install --ignore-security-hash -e -id Microsoft.VisualStudioCode
    winget install --ignore-security-hash -e -id Mozilla.Firefox
    winget install --ignore-security-hash -e -id Zoom.Zoom.EXE
    winget upgrade --ignore-security-hash --all

    pause
exit /b
