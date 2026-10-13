Unicode true
!include "MUI2.nsh"

Name "DEX Admin"
OutFile "release-sales-tracking\DEX Admin Desktop Setup.exe"
InstallDir "$LOCALAPPDATA\DEX Admin"
RequestExecutionLevel user
BrandingText "DEX Logistics"

!define MUI_ICON "assets\dex-logo.ico"
!define MUI_UNICON "assets\dex-logo.ico"
!define MUI_ABORTWARNING

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\DEX Admin Console.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch DEX Admin"
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

Function .onInit
  FindWindow $0 "Chrome_WidgetWin_1" "DEX Admin Console"
  StrCmp $0 0 done
  MessageBox MB_ICONEXCLAMATION|MB_OK "DEX Admin is currently running. Close it, then run this installer again."
  Abort
  done:
FunctionEnd

Section "DEX Admin" SEC01
  SetOutPath "$INSTDIR"
  File /r "release-final\win-unpacked\*.*"
  CreateDirectory "$SMPROGRAMS\DEX Logistics"
  CreateShortcut "$SMPROGRAMS\DEX Logistics\DEX Admin.lnk" "$INSTDIR\DEX Admin Console.exe" "" "$INSTDIR\DEX Admin Console.exe" 0
  CreateShortcut "$DESKTOP\DEX Admin.lnk" "$INSTDIR\DEX Admin Console.exe" "" "$INSTDIR\DEX Admin Console.exe" 0
  WriteUninstaller "$INSTDIR\Uninstall DEX Admin.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\DEX Admin" "DisplayName" "DEX Admin"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\DEX Admin" "UninstallString" '"$INSTDIR\Uninstall DEX Admin.exe"'
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\DEX Admin" "DisplayIcon" "$INSTDIR\DEX Admin Console.exe"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\DEX Admin" "NoModify" 1
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\DEX Admin" "NoRepair" 1
SectionEnd

Section "Uninstall"
  Delete "$DESKTOP\DEX Admin.lnk"
  Delete "$SMPROGRAMS\DEX Logistics\DEX Admin.lnk"
  RMDir "$SMPROGRAMS\DEX Logistics"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\DEX Admin"
SectionEnd
