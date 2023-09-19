@echo off

@REM Create mylist.txt in the same directory.
@REM backup.txt (ShiftJIS)
@REM    ;source_path,destination_path
@REM    ...,...
@REM    ...,...

call :main
exit /b

:main
    cd /d %~dp0

    for /f "tokens=1,* delims=," %%i in (backup.txt) do (
        call :my_robocopy "%%i" "%%j"
    )

    pause
exit /b

@REM :my_robocopy %source_path% %destination_path%
:my_robocopy
    robocopy "%~1" "%~2" /mir /r:0 /w:0 /xj /xd "*.git" "*.svn" "node_modules"
exit /b
