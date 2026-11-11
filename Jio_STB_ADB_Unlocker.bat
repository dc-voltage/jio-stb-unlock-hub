@echo off
title Jio STB ADB Auto-Unlocker [Developed by DC]
color 0A
setlocal EnableDelayedExpansion

echo ===================================================================
echo   JIO STB (JMSB200Av2) GENIEACS AUTO-UNLOCK ^& ADB CONNECT TOOL
echo                         Developed by DC
echo ===================================================================
echo.

:: Check if PowerShell is available
where powershell >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] PowerShell is required to run this automation tool!
    pause
    exit /b 1
)

:: Run PowerShell script with ExecutionPolicy Bypass
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Jio_STB_ADB_Unlocker.ps1" %*

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] Process finished with warnings or errors.
)

echo.
echo Press any key to exit...
pause >nul
