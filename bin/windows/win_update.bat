@echo off
@REM Run as user.

set CODESNIP_DIR="%APPDATA%\Code\User\snippets"
set WINTERM_DIR="%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    @REM %USERPROFILE%
    copy /y "..\etc\.gitignore" "%USERPROFILE%"
    copy /y "..\etc\.wslconfig" "%USERPROFILE%"

    @REM C:\work
    copy /y "..\etc\.markdownlintrc" "C:\work"
    copy /y "..\etc\jupytext.yaml" "C:\work"

    @REM VSCode
    rmdir /q /s "%CODESNIP_DIR:"=%"
    xcopy /e /i /y "..\vsnip\*" "%CODESNIP_DIR:"=%"
    xcopy /e /i /y "..\VSCode\User\*" "%APPDATA%\Code\User"

    @REM Windows Terminal
    rmdir /q /s "%WINTERM_DIR:"=%"
    xcopy /e /i /y "..\WindowsTerminal\LocalState" "%WINTERM_DIR:"=%"
exit /b
