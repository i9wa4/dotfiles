@echo off
@REM Run as user.

set VENV_MYENV="C:\venv\myenv"

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    rmdir /q /s "%USERPROFILE%\.ipynb_checkpoints"

    xcopy /e /i /y "..\..\.jupyter" "%VENV_MYENV:"=%\share\jupyter"
    cd /d ".."

    call "%VENV_MYENV:"=%\Scripts\activate.bat"
    jupyter-lab^
        --FileCheckpoints.checkpoint_dir="%USERPROFILE%\.ipynb_checkpoints"
exit /b
