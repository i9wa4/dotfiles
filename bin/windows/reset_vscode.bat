@echo off

call :main
exit /b

:main
    cd /d %~dp0

    rmdir /q /s "%APPDATA%\Code\User"
    rmdir /q /s "%USERPROFILE%\.vscode"

    pause
exit /b