Unicode true
ManifestDPIAware true
RequestExecutionLevel user

!define APP_NAME "DEX Admin Console"
!define APP_VERSION "1.0.1"
!define APP_EXE "DEX Admin Console.exe"
!define INSTALL_DIR "$LOCALAPPDATA\DEX Admin Console"

Name "${APP_NAME}"
OutFile "dist\DEX-Admin-Console-Setup-${APP_VERSION}-x64.exe"
InstallDir "${INSTALL_DIR}"
InstallDirRegKey HKCU "Software\DEX Logistics\DEX Admin Console" "InstallDir"
Icon "assets\dex-logo.ico"
UninstallIcon "assets\dex-logo.ico"
BrandingText "DEX Logistics"
VIProductVersion "${APP_VERSION}.0"
VIAddVersionKey /LANG=1033 "ProductName" "${APP_NAME}"
VIAddVersionKey /LANG=1033 "CompanyName" "DEX Logistics"
VIAddVersionKey /LANG=1033 "FileDescription" "DEX Logistics administrative desktop console"
VIAddVersionKey /LANG=1033 "FileVersion" "${APP_VERSION}"
VIAddVersionKey /LANG=1033 "LegalCopyright" "DEX Logistics"

Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

Section "Install"
  SetOutPath "${INSTALL_DIR}"
  File /r "dist\win-unpacked\*.*"
  WriteRegStr HKCU "Software\DEX Logistics\DEX Admin Console" "InstallDir" "${INSTALL_DIR}"
  WriteUninstaller "${INSTALL_DIR}\Uninstall DEX Admin Console.exe"
  CreateDirectory "$DESKTOP"
  CreateShortCut "$DESKTOP\DEX Admin Console.lnk" "${INSTALL_DIR}\${APP_EXE}" "" "${INSTALL_DIR}\${APP_EXE}" 0
  CreateDirectory "$SMPROGRAMS\DEX Admin Console"
  CreateShortCut "$SMPROGRAMS\DEX Admin Console\DEX Admin Console.lnk" "${INSTALL_DIR}\${APP_EXE}" "" "${INSTALL_DIR}\${APP_EXE}" 0
  CreateShortCut "$SMPROGRAMS\DEX Admin Console\Uninstall DEX Admin Console.lnk" "${INSTALL_DIR}\Uninstall DEX Admin Console.exe"
SectionEnd

Section "Uninstall"
  Delete "$DESKTOP\DEX Admin Console.lnk"
  Delete "$SMPROGRAMS\DEX Admin Console\DEX Admin Console.lnk"
  Delete "$SMPROGRAMS\DEX Admin Console\Uninstall DEX Admin Console.lnk"
  RMDir "$SMPROGRAMS\DEX Admin Console"
  RMDir /r "${INSTALL_DIR}"
  DeleteRegKey HKCU "Software\DEX Logistics\DEX Admin Console"
SectionEnd
