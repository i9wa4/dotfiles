@REM @echo off
@echo on
@REM Run as administrator.

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    @REM winget settings --enable InstallerHashOverride

    winget install --ignore-security-hash --extract --id Alacritty.Alacritty
    winget install --ignore-security-hash --extract --id Amazon.Kindle
    winget install --ignore-security-hash --extract --id LINE.LINE
    winget install --ignore-security-hash --extract --id Microsoft.VisualStudioCode
    winget install --ignore-security-hash --extract --id Mozilla.Firefox
    winget install --ignore-security-hash --extract --id Zoom.Zoom.EXE
    winget upgrade --ignore-security-hash --all

    pause
exit /b
