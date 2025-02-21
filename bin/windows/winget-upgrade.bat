@echo on

call :main
exit /b

:main
    chcp 437>nul
    chcp 65001>nul
    cd /d %~dp0

    wsl --update

    @REM winget settings --enable InstallerHashOverride

    winget install --ignore-security-hash --exact --id Alacritty.Alacritty
    winget install --ignore-security-hash --exact --id Amazon.Kindle
    winget install --ignore-security-hash --exact --id Google.Chrome
    winget install --ignore-security-hash --exact --id Microsoft.VisualStudioCode
    winget install --ignore-security-hash --exact --id Zoom.Zoom

    winget upgrade --ignore-security-hash --all

    pause
exit /b
