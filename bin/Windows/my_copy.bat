@echo off
@REM Run as user.

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    @REM %USERPROFILE%
    @REM copy /y ".\etc\home\dot.gitignore" "%USERPROFILE%/.gitignore"
    copy /y ".\WSL\dot.wslconfig" "%USERPROFILE%/.wslconfig"

    @REM %USERPROFILE% & C:\work
    @REM copy /y ".\etc\home\dot.jupytext" "%USERPROFILE%/.jupytext"
    @REM copy /y ".\etc\home\dot.jupytext" "C:\work/.jupytext"

    @REM Vim
    @REM set VIM_DIR="%USERPROFILE%\.vim"
    @REM rmdir /q /s "%VIM_DIR:"=%"
    @REM xcopy /e /i /y ".\dot.vim" "%VIM_DIR:"=%"

    @REM VSCode
    set CODE_DIR="%APPDATA%\Code\User"
    rmdir /q /s "%CODE_DIR:"=%"
    xcopy /e /i /y ".\VSCode\User\*" "%CODE_DIR:"=%"

    @REM Windows Terminal
    @REM set WINTERM_DIR="%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    @REM rmdir /q /s "%WINTERM_DIR:"=%"
    @REM xcopy /e /i /y ".\WindowsTerminal\LocalState" "%WINTERM_DIR:"=%"
exit /b
