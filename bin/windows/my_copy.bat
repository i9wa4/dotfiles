@echo off
@REM Run as user.

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    @REM %USERPROFILE%
    copy /y ".\etc\home\dot.gitignore"      "%USERPROFILE%/.gitignore"
    copy /y ".\WSL\dot.wslconfig"           "%USERPROFILE%/.wslconfig"

    @REM %USERPROFILE% & C:\work
    copy /y ".\etc\home\dot.jupytext"                   "%USERPROFILE%/.jupytext"
    copy /y ".\etc\home\dot.jupytext"                   "C:\work/.jupytext"
    copy /y ".\etc\home\dot.markdownlint-cli2.jsonc"    "%USERPROFILE%/.markdownlint-cli2.jsonc"
    copy /y ".\etc\home\dot.markdownlint-cli2.jsonc"    "C:\work/.markdownlint-cli2.jsonc"

    @REM Vim
    set VIM_DIR="%USERPROFILE%\.vim"
    rmdir /q /s "%VIM_DIR:"=%"
    xcopy /e /i /y ".\dot.vim" "%VIM_DIR:"=%"

    @REM VSCode
    set CODE_DIR="%APPDATA%\Code\User"
    rmdir /q /s "%CODE_DIR:"=%"
    xcopy /e /i /y ".\VSCode\User\*" "%CODE_DIR:"=%"

    @REM Windows Terminal
    set WINTERM_DIR="%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    rmdir /q /s "%WINTERM_DIR:"=%"
    xcopy /e /i /y ".\WindowsTerminal\LocalState" "%WINTERM_DIR:"=%"
exit /b
