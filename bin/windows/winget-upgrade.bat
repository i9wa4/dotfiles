@echo on

call :main
exit /b

:main
    chcp 437>nul
    chcp 65001>nul
    cd /d %~dp0

    wsl --update

    @REM Amazon.Kindle
    @REM Microsoft.VisualStudioCode
    @REM Zoom.Zoom
    @REM wez.wezterm
    winget install --ignore-security-hash --exact ^
        Google.Chrome

    winget upgrade --ignore-security-hash --all

    pause
exit /b
