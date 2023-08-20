@echo off
@REM Run as administrator.

call :main
exit /b

:main
    cd /d %~dp0

    @REM mklink /d "%OneDrive%\home\repo\note" "C:\work\git\note"
    @REM mklink /d "%USERPROFILE%\work" "C:\work"
    @REM mklink "%USERPROFILE%\local.vim" "C:\work\local.vim"
    mklink "C:\work\bookmark.md" "%OneDrive%\home\repo\work\bookmark.md"
    mklink "C:\work\gtd.md" "%OneDrive%\home\repo\work\gtd.md"

    pause
exit /b
