@echo off
@REM Run as administrator.

set PY_VER_MINOR=3.11
set VENV_MYENV="C:\venv\myenv"

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    if exist %VENV_MYENV% (
        py -%PY_VER_MINOR% -m venv %VENV_MYENV% --upgrade
    ) else (
        py -%PY_VER_MINOR% -m venv %VENV_MYENV%
    )

    call "%VENV_MYENV:"=%\Scripts\activate.bat"
    python -m pip config --site set global.trusted-host "pypi.org pypi.python.org files.pythonhosted.org"
    python -m pip install --upgrade pip setuptools wheel
    python -m pip install -r "..\..\etc\py_venv_myenv_requirements.txt"
    python -m pip check
    @REM deactivate

    echo Done.
    pause
exit /b
