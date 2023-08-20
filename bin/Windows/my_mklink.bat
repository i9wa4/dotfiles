@echo off
@REM Run as administrator.

call :main
exit /b

:main
    cd /d %~dp0

    @REM mklink /d "%OneDrive%\home\repo\note" "C:\work\git\note"
    @REM mklink /d "%USERPROFILE%\work" "C:\work"
    @REM mklink "%USERPROFILE%\local.vim" "C:\work\local.vim"
    mklink "%OneDrive%\home\repo\work\bookmark.md" "C:\work\bookmark.md"
    mklink "%OneDrive%\home\repo\work\gtd.md" "C:\work\gtd.md"

    pause
exit /b
