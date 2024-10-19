@REM @echo off
@echo on
@REM Run as administrator.

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    @REM winget settings --enable InstallerHashOverride

    winget install --ignore-security-hash --exact --id Alacritty.Alacritty
    winget install --ignore-security-hash --exact --id Amazon.Kindle
    winget install --ignore-security-hash --exact --id Microsoft.VisualStudioCode
    winget install --ignore-security-hash --exact --id Zoom.Zoom.EXE
    winget upgrade --ignore-security-hash --all

    wsl --update

    pause
exit /b
