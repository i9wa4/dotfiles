@echo off
@REM Run as user.

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    @REM %USERPROFILE%
    copy /y ".\etc\home\.gitignore"         "%USERPROFILE%"
    copy /y ".\WSL\.wslconfig"              "%USERPROFILE%"

    @REM %USERPROFILE% & C:\work
    copy /y ".\etc\home\.jupytext"          "%USERPROFILE%"
    copy /y ".\etc\home\.jupytext"          "C:\work"
    copy /y ".\etc\home\.markdownlintrc"    "%USERPROFILE%"
    copy /y ".\etc\home\.markdownlintrc"    "C:\work"

    @REM VSCode
    set CODE_DIR="%APPDATA%\Code\User"
    rmdir /q /s "%CODE_DIR:"=%"
    xcopy /e /i /y ".\VSCode\User\*" "%CODE_DIR:"=%"

    @REM Windows Terminal
    set WINTERM_DIR="%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    rmdir /q /s "%WINTERM_DIR:"=%"
    xcopy /e /i /y ".\WindowsTerminal\LocalState" "%WINTERM_DIR:"=%"
exit /b
