@echo off

@REM Create mylist.txt in the same directory.
@REM mylist.txt
@REM    SSID_HOME=""
@REM    SSID_COMPANY=""
@REM    VPN_NAME=""

@REM You can hide VPN connection dialog.
@REM    %APPDATA%\Roaming\Microsoft\Network\Connections\Pbk\rasphone.pbk
@REM    PreviewUserPw=0

:main
    REM chcp 65001>nul
    cd /d %~dp0

    for /f "tokens=1,* delims==" %%a in (mylist.txt) do (
        set %%a=%%b
    )

    setlocal enabledelayedexpansion
        call :is_connected %SSID_HOME%
        if !ERRORLEVEL! equ 0 (
            @REM Connection to %SSID_HOME% is established.
            call :is_connected %VPN_NAME%
            if not !ERRORLEVEL! equ 0 (
                @REM Connection to %VPN_NAME% is NOT established.
                call :connect_to_vpn %VPN_NAME%
                call :is_connected %VPN_NAME%
            )
        ) else (
            @REM Connection to %SSID_HOME% is NOT established.
            call :is_connected %SSID_COMPANY%
            if not !ERRORLEVEL! equ 0 (
                @REM Connection to %SSID_COMPANY% is NOT established.
                call :connect_to_wifi %SSID_HOME%
                call :is_connected %SSID_HOME%
                if !ERRORLEVEL! equ 0 (
                    @REM Connection to %SSID_HOME% is established.
                    call :connect_to_vpn %VPN_NAME%
                    call :is_connected %VPN_NAME%
                ) else (
                    @REM Connection to %SSID_HOME% is NOT established.
                    call :connect_to_wifi %SSID_COMPANY%
                    call :is_connected %SSID_COMPANY%
                )
            )
        )
    endlocal
exit /b

@REM is_connected %SSID_OR_VPN_NAME%
:is_connected
    @REM Confirm Wi-Fi SSID.
    netsh wlan show interfaces | findstr /c:"%~1" > nul

    @REM Confirm VPN Connection.
    if %ERRORLEVEL% equ 1 (
        ipconfig | findstr /c:"%~1" > nul
    )

    set ret=%ERRORLEVEL%

    if %ret% equ 0 (
        echo Connection to %~1 is established.
    ) else (
        echo Connection to %~1 is NOT established.
    )
exit /b %ret%

@REM connect_to_wifi %SSID%
:connect_to_wifi
    echo Connecting to %~1...
    netsh wlan connect name=%~1 > nul
    timeout /t 5
exit /b

@REM connect_to_vpn %VPN_NAME%
:connect_to_vpn
    echo Connecting to %~1...
    start /min /d "%WINDIR%\System32" rasphone.exe -d %~1
    timeout /t 10
exit /b
