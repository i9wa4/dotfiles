@echo off
@REM Run as administrator.

call :main
exit /b

:main
    cd /d %~dp0

    mklink /d "%OneDrive%\home\repo\fragment\md" "C:\work\git\fragment\md"

    pause
exit /b
