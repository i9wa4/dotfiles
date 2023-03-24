@echo off

call :main
exit /b

:main
    chcp 65001>nul
    cd /d %~dp0

    @REM code --list-extensions
    for /f %%i in (code_extension.txt) do (
        call :code_install_extension "%%i"
    )

    echo Done.
    pause
exit /b

@REM :code_install_extension %id%
:code_install_extension
    call code --install-extension %~1
    timeout /t 3
exit /b
