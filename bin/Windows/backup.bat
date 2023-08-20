@echo off

@REM Create mylist.txt in the same directory.
@REM mylist.txt
@REM    ;source_path,destination_path
@REM    ...,...
@REM    ...,...

call :main
exit /b

:main
    @REM chcp 65001>nul
    cd /d %~dp0

    for /f "tokens=1,* delims=," %%i in (mylist.txt) do (
        call :my_robocopy "%%i" "%%j"
    )
exit /b

@REM :my_robocopy %source_path% %destination_path%
:my_robocopy
    robocopy "%~1" "%~2" /e /r:0 /w:0 /xj /xd ".git" ".svn"
exit /b
