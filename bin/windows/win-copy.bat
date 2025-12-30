@echo off

call :main
exit /b

:main
    chcp 437>nul
    chcp 65001>nul
    cd /d %~dp0

    cd ..\..

    @REM %USERPROFILE%
    copy /y ".\etc\dot.wslconfig" "%USERPROFILE%\.wslconfig"

    @REM VS Code
    set CODE_DIR=%APPDATA%\Code\User
    @REM rmdir /q /s "%CODE_DIR%"
    mkdir "%CODE_DIR%\snippets"
    copy /y ".\dot.vscode\settings.json" "%CODE_DIR%\settings.json"
    xcopy /e /i /y ".\dot.config\vim\snippet" "%CODE_DIR%\snippets"
exit /b
