@echo off

call :main
exit /b

:main
    taskkill /f /im OneDrive.exe
    timeout /t 1
    start %LOCALAPPDATA%\Microsoft\OneDrive\onedrive.exe
exit /b
