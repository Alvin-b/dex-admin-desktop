Unicode True
RequestExecutionLevel user
SetCompressor /SOLID lzma

!include "MUI2.nsh"

Name "DEX Admin"
OutFile "..\..\..\outputs\DEX Admin Desktop Setup.exe"
InstallDir "$LOCALAPPDATA\DEX Admin"
InstallDirRegKey HKCU "Software\DEX Logistics\DEX Admin" "InstallDir"
Icon "..\assets\dex-logo.ico"
BrandingText "DEX Logistics · Nairobi Operations"

!define MUI_ABORTWARNING
!define MUI_ICON "..\assets\dex-logo.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

Section "DEX Admin application" SEC_APP
  SetOutPath "$INSTDIR"
  File /r "..\release-current\win-unpacked\*"
  WriteRegStr HKCU "Software\DEX Logistics\DEX Admin" "InstallDir" "$INSTDIR"
  WriteUninstaller "$INSTDIR\Uninstall DEX Admin.exe"
  CreateDirectory "$SMPROGRAMS\DEX Logistics"
  CreateShortcut "$SMPROGRAMS\DEX Logistics\DEX Admin.lnk" "$INSTDIR\DEX Admin Console.exe" "" "$INSTDIR\DEX Admin Console.exe" 0
  CreateShortcut "$DESKTOP\DEX Admin.lnk" "$INSTDIR\DEX Admin Console.exe" "" "$INSTDIR\DEX Admin Console.exe" 0
SectionEnd

Section "Uninstall"
  Delete "$DESKTOP\DEX Admin.lnk"
  Delete "$SMPROGRAMS\DEX Logistics\DEX Admin.lnk"
  RMDir "$SMPROGRAMS\DEX Logistics"
  Delete "$INSTDIR\Uninstall DEX Admin.exe"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKCU "Software\DEX Logistics\DEX Admin"
SectionEnd
