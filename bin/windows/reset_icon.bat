@echo off

call :main
exit /b

:main
    cd /d %~dp0

    taskkill /f /im explorer.exe
    timeout /t 1
    del /f /s /q /a %LOCALAPPDATA%\IconCache.db
    del /f /s /q /a %LOCALAPPDATA%\microsoft\Windows\Explorer\thumbcache*.db
    del /f /s /q /a %LOCALAPPDATA%\microsoft\Windows\Explorer\iconcache*.db
    start explorer.exe

    pause
exit /b
