@echo off

call :main
exit /b

:main
    chcp 437>nul
    chcp 65001>nul
    cd /d %~dp0

    rmdir /q /s "%APPDATA%\Code\User"
    rmdir /q /s "%USERPROFILE%\.vscode"

    pause
exit /b
