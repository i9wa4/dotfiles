@echo off

:main
    taskkill /f /im OneDrive.exe
    timeout /t 1
    start %LOCALAPPDATA%\Microsoft\OneDrive\onedrive.exe
exit /b
