@echo off
@REM Run as user.

set WINTERM_DIR="%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    copy /y ".\.gitignore"              "%USERPROFILE%"
    copy /y ".\.wslconfig"              "%USERPROFILE%"
    copy /y ".\.markdownlintrc"         "C:\work"
    copy /y ".\jupytext.yaml"           "C:\work"

    @REM VSCode
    rmdir /q /s "%APPDATA%\Code\User\snippets"
    xcopy /e /i /y ".\.vim\vsnip\*"     "%APPDATA%\Code\User\snippets"
    xcopy /e /i /y ".\VSCode\User\*"    "%APPDATA%\Code\User"

    @REM Windows Terminal
    rmdir /q /s "%WINTERM_DIR:"=%"
    xcopy /e /i /y ".\WindowsTerminal\LocalState" "%WINTERM_DIR:"=%"
exit /b
