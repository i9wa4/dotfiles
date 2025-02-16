@echo off
@REM Run as user.

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    cd ..\..

    @REM %USERPROFILE%
    copy /y ".\etc\dot.wslconfig" "%USERPROFILE%\.wslconfig"

    @REM Alacritty
    set ALACRITTY_DIR=%APPDATA%\alacritty
    xcopy /e /i /y ".\dot.config\alacritty" "%ALACRITTY_DIR%"
    echo [general]>                                 "%ALACRITTY_DIR%\alacritty.toml"
    echo import = [>>                               "%ALACRITTY_DIR%\alacritty.toml"
    echo     "%ALACRITTY_DIR:\=/%/common.toml",>>   "%ALACRITTY_DIR%\alacritty.toml"
    echo     "%ALACRITTY_DIR:\=/%/windows.toml", >> "%ALACRITTY_DIR%\alacritty.toml"
    echo ]>>                                        "%ALACRITTY_DIR%\alacritty.toml"

    @REM VS Code
    @REM set CODE_DIR=%APPDATA%\Code\User
    @REM rmdir /q /s "%CODE_DIR%"
    @REM mkdir "%CODE_DIR%\snippets"
    @REM copy /y ".\dot.vscode\settings.json" "%CODE_DIR%\settings.json"
    @REM xcopy /e /i /y ".\dot.config\vim\snippet" "%CODE_DIR%\snippets"

    @REM CorvusSKK
    @REM set CORVUS_SKK_DIR=%APPDATA%\CorvusSKK
    @REM copy /y ".\dot.config\skk\mydict.utf8" "%CORVUS_SKK_DIR%\userdict.txt"
    @REM xcopy /e /i /y ".\skk" "%CORVUS_SKK_DIR%"
exit /b
