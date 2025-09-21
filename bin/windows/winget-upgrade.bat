@echo on

call :main
exit /b

:main
    chcp 437>nul
    chcp 65001>nul
    cd /d %~dp0

    wsl --update

    @REM Microsoft.VisualStudioCode
    winget install --ignore-security-hash --exact ^
        Alacritty.Alacritty ^
        Amazon.Kindle ^
        Google.Chrome ^
        Zoom.Zoom

    winget upgrade --ignore-security-hash --all

    pause
exit /b
