@echo off
rem Registers the Phoenix FFXI client with Windows so Windower's loader can start it.
rem Put this file in <Phoenix>\SquareEnix\ and run it as administrator.
net session >nul 2>&1 || (echo Right-click this file and choose "Run as administrator". & pause & exit /b)
set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "KEY=HKLM\SOFTWARE\WOW6432Node\PlayOnlineUS"

if not exist "%ROOT%\FINAL FANTASY XI\FFXiMain.dll" (
    echo This file must be inside the Phoenix SquareEnix folder, next to "FINAL FANTASY XI".
    pause
    exit /b 1
)

reg add "%KEY%\InstallFolder" /v 0001 /d "%ROOT%\FINAL FANTASY XI" /f
reg add "%KEY%\InstallFolder" /v 1000 /d "%ROOT%\PlayOnlineViewer" /f
reg add "%KEY%\Interface" /v 0001 /d "0" /f

regsvr32 /s "%ROOT%\FINAL FANTASY XI\FFXi.dll"
regsvr32 /s "%ROOT%\FINAL FANTASY XI\FFXiMain.dll"
regsvr32 /s "%ROOT%\FINAL FANTASY XI\FFXiVersions.dll"
regsvr32 /s "%ROOT%\PlayOnlineViewer\viewer\com\polcore.dll"
regsvr32 /s "%ROOT%\PlayOnlineViewer\viewer\com\app.dll"
regsvr32 /s "%ROOT%\PlayOnlineViewer\viewer\contents\PolContents.dll"
regsvr32 /s "%ROOT%\PlayOnlineViewer\viewer\contents\polcontentsINT.dll"
regsvr32 /s "%ROOT%\PlayOnlineViewer\viewer\ax\polmvf.dll"
regsvr32 /s "%ROOT%\PlayOnlineViewer\viewer\ax\polmvfINT.dll"

echo Done. The registered FFXI client is now Phoenix.
pause
