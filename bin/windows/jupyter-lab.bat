@echo off

call :main
exit /b

:main
    cd C:\work
    call C:\work\myenv\Scripts\jupyter-lab.exe
exit /b
