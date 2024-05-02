@echo off
@REM Run as administrator.

call :main
exit /b

:main
    cd /d %~dp0

    @REM mklink destination source
    mklink "%OneDrive%\home\repo\fragment" "C:\work\git\local\fragment"

    pause
exit /b
