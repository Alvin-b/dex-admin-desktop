@echo off
setlocal EnableExtensions
set "APP_DIR=%LOCALAPPDATA%\Programs\DEX Admin Console"
if not exist "%APP_DIR%" mkdir "%APP_DIR%"
xcopy /E /I /Y "%~dp0win-unpacked\*" "%APP_DIR%\" >nul
set "APP_EXE=%APP_DIR%\DEX Admin Console.exe"
if not exist "%APP_EXE%" exit /b 1
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws=New-Object -ComObject WScript.Shell; $desktop=[Environment]::GetFolderPath('Desktop'); $start=[Environment]::GetFolderPath('StartMenu'); $programs=Join-Path $start 'Programs'; New-Item -ItemType Directory -Force -Path $programs | Out-Null; foreach($p in @((Join-Path $desktop 'DEX Admin Console.lnk'),(Join-Path $programs 'DEX Admin Console.lnk'))){$s=$ws.CreateShortcut($p);$s.TargetPath='%APP_DIR%\DEX Admin Console.exe';$s.WorkingDirectory='%APP_DIR%';$s.Description='DEX Admin Console hosted desktop app';$s.Save()}"
start "" "%APP_EXE%"
exit /b 0
