Unicode true
ManifestDPIAware true
RequestExecutionLevel user

!include MUI2.nsh

!define APP_NAME "DEX Admin Console"
!define APP_VERSION "1.0.2"
!define APP_EXE "DEX Admin Console.exe"
!define INSTALL_DIR "$LOCALAPPDATA\DEX Admin Console"

Name "${APP_NAME}"
OutFile "dist\DEX-Admin-Console-Setup-${APP_VERSION}-original-runtime-x64.exe"
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

!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchApplication
!define MUI_FINISHPAGE_RUN_TEXT "Launch DEX Admin Console"
!define MUI_FINISHPAGE_RUN_CHECKED

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Function LaunchApplication
  Exec '"$INSTDIR\${APP_EXE}"'
FunctionEnd

Section "Install"
  SetOutPath "${INSTALL_DIR}"
  File /r "dist\original-runtime-minimal\*.*"
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
