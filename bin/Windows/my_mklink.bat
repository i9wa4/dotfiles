@echo off
@REM Run as administrator.

call :main
exit /b

:main
    cd /d %~dp0

    mklink /d "%OneDrive%\home\repo\note\archive" "C:\work\git\note\archive"
    mklink /d "%OneDrive%\home\repo\note\bin" "C:\work\git\note\bin"
    mklink /d "%OneDrive%\home\repo\note\doc" "C:\work\git\note\doc"
    @REM mklink /d "%USERPROFILE%\work" "C:\work"
    @REM mklink "%USERPROFILE%\local.vim" "C:\work\local.vim"
    mklink "C:\work\bookmark.md" "%OneDrive%\home\repo\work\bookmark.md"
    mklink "C:\work\gtd.md" "%OneDrive%\home\repo\work\gtd.md"

    pause
exit /b
