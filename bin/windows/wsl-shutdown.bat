@echo off

call :main
exit /b

:main
    chcp 437>nul
    chcp 65001>nul
    cd /d %~dp0

    wsl --shutdown
exit /b
