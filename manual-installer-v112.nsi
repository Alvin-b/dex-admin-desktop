Unicode true
ManifestDPIAware true
!define MUI_ICON "assets\dex-original-installer.ico"
!define MUI_UNICON "assets\dex-original-installer.ico"
RequestExecutionLevel user

!include MUI2.nsh
!include LogicLib.nsh
!include StrFunc.nsh
${Using:StrFunc} StrStr

!define APP_NAME "DEX Admin Console"
!define APP_VERSION "1.1.2"
!define APP_EXE "DEX Admin Console.exe"
!define INSTALL_DIR "$LOCALAPPDATA\DEX Admin Console"

Name "${APP_NAME}"
OutFile "dist\DEX-Admin-Console-Setup-${APP_VERSION}-employee-edit-fix-x64.exe"
InstallDir "${INSTALL_DIR}"
InstallDirRegKey HKCU "Software\DEX Logistics\DEX Admin Console" "InstallDir"
Icon "assets\dex-original-installer.ico"
UninstallIcon "assets\dex-original-installer.ico"
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

Function EnsureAppClosed
  ; Check before any files are copied so Windows never reaches a confusing
  ; "Error opening file for writing" dialog for the locked executable.
  nsExec::ExecToStack 'tasklist /FI "IMAGENAME eq ${APP_EXE}" /NH'
  Pop $0
  Pop $1
  ${StrStr} $2 $1 "${APP_EXE}"
  ${If} $2 != ""
    MessageBox MB_ICONEXCLAMATION|MB_YESNO "DEX Admin Console is already running.$\r$\n$\r$\nThe installer needs to close it before updating the application.$\r$\n$\r$\nClick Yes to close DEX Admin Console and continue, or No to cancel the installation." IDYES close_app IDNO cancel_install
    close_app:
      nsExec::ExecToStack 'taskkill /IM "${APP_EXE}" /T /F'
      Pop $0
      Pop $1
      Sleep 1200
      nsExec::ExecToStack 'tasklist /FI "IMAGENAME eq ${APP_EXE}" /NH'
      Pop $0
      Pop $1
      ${StrStr} $2 $1 "${APP_EXE}"
      ${If} $2 != ""
        MessageBox MB_ICONSTOP|MB_OK "DEX Admin Console could not be closed automatically.$\r$\n$\r$\nPlease close the application manually, then run the installer again."
        Abort
      ${EndIf}
      Goto done
    cancel_install:
      MessageBox MB_ICONINFORMATION|MB_OK "Installation cancelled because DEX Admin Console is still running."
      Abort
  ${EndIf}
  done:
FunctionEnd

Function .onInit
  SetShellVarContext current
  Call EnsureAppClosed
FunctionEnd

Function LaunchApplication
  Exec '"$INSTDIR\${APP_EXE}"'
FunctionEnd

Section "Install"
  SetShellVarContext current
  SetOutPath "${INSTALL_DIR}"
  File /r "dist\original-runtime-employee-fix\*.*"
  File "assets\dex-logo.ico"
  WriteRegStr HKCU "Software\DEX Logistics\DEX Admin Console" "InstallDir" "${INSTALL_DIR}"
  WriteUninstaller "${INSTALL_DIR}\Uninstall DEX Admin Console.exe"
  CreateDirectory "$DESKTOP"
  CreateShortCut "$DESKTOP\DEX Admin Console.lnk" "${INSTALL_DIR}\${APP_EXE}" "" "${INSTALL_DIR}\dex-logo.ico" 0
  CreateDirectory "$SMPROGRAMS\DEX Admin Console"
  CreateShortCut "$SMPROGRAMS\DEX Admin Console\DEX Admin Console.lnk" "${INSTALL_DIR}\${APP_EXE}" "" "${INSTALL_DIR}\dex-logo.ico" 0
  CreateShortCut "$SMPROGRAMS\DEX Admin Console\Uninstall DEX Admin Console.lnk" "${INSTALL_DIR}\Uninstall DEX Admin Console.exe"
SectionEnd

Section "Uninstall"
  SetShellVarContext current
  Delete "$DESKTOP\DEX Admin Console.lnk"
  Delete "${INSTALL_DIR}\dex-logo.ico"
  Delete "$SMPROGRAMS\DEX Admin Console\DEX Admin Console.lnk"
  Delete "$SMPROGRAMS\DEX Admin Console\Uninstall DEX Admin Console.lnk"
  RMDir "$SMPROGRAMS\DEX Admin Console"
  RMDir /r "${INSTALL_DIR}"
  DeleteRegKey HKCU "Software\DEX Logistics\DEX Admin Console"
SectionEnd
