@echo off
@REM Run as user.

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    @REM %USERPROFILE%
    copy /y ".\etc\windows\dot.wslconfig" "%USERPROFILE%\.wslconfig"

    @REM VSCode
    set CODE_DIR="%APPDATA%\Code\User"
    rmdir /q /s "%CODE_DIR:"=%"
    mkdir "%CODE_DIR:"=%\snippets"
    copy /y ".\dot.vscode/settings.json" "%CODE_DIR:"=%\settings.json"
    xcopy /e /i /y ".\dot.vim\snippet" "%CODE_DIR:"=%\snippets"

    @REM Alacritty
    set CODE_DIR="%APPDATA%\alacritty"
    rmdir /q /s "%CODE_DIR:"=%"
    xcopy /e /i /y ".\dot.config\alacritty" "%CODE_DIR:"=%"
    echo %APPDATA% >> "%CODE_DIR:"=%\alacritty.toml"
    echo import = [ > "%CODE_DIR:"=%\alacritty.toml"
    echo "%APPDATA%\alacritty\common.toml", >> "%CODE_DIR:"=%\alacritty.toml"
    echo "%APPDATA%\alacritty\win.toml", >> "%CODE_DIR:"=%\alacritty.toml"
    echo ] >> "%CODE_DIR:"=%\alacritty.toml"
exit /b
