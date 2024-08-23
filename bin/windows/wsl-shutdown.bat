@echo off
@REM Run as user.

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    wsl --shutdown
exit /b
