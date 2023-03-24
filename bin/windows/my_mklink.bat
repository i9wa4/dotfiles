@echo off
@REM Run as administrator.

call :main
exit /b

:main
    cd /d %~dp0

    mklink /d "%OneDrive%\home\bin" "%MYFRAGMENT%\bin"
    mklink /d "%OneDrive%\home\md"  "%MYFRAGMENT%\md"

    pause
exit /b