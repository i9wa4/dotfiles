@echo off
@REM Run as user.

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    @REM %USERPROFILE%
    copy /y ".\etc\home\dot.gitignore" "%USERPROFILE%\.gitignore"
    @REM copy /y ".\etc\home\dot.jupytext" "%USERPROFILE%\.jupytext"
    copy /y ".\etc\windows\dot.wslconfig" "%USERPROFILE%\.wslconfig"

    @REM Vim
    set VIM_DIR="%USERPROFILE%\.vim"
    rmdir /q /s "%VIM_DIR:"=%"
    xcopy /e /i /y ".\dot.vim" "%VIM_DIR:"=%"

    @REM VSCode
    set CODE_DIR="%APPDATA%\Code\User"
    rmdir /q /s "%CODE_DIR:"=%"
    mkdir "%CODE_DIR:"=%\snippets"
    copy /y ".\etc\windows\code.settings.json" "%CODE_DIR:"=%\settings.json"
    xcopy /e /i /y ".\dot.vim\vsnip" "%CODE_DIR:"=%\snippets"

    @REM Windows Terminal
    set WINTERM_DIR="%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    rmdir /q /s "%WINTERM_DIR:"=%"
    mkdir "%WINTERM_DIR:"=%"
    copy /y ".\etc\windows\wt.settings.json" "%WINTERM_DIR:"=%\settings.json"
exit /b
