!include WinMessages.nsh

name "Lock Viewer"
SetCompressor lzma

OutFile LVSetup.exe

InstallDir $PROGRAMFILES\LViewer
Page directory
;Page components
Page instfiles
ShowInstDetails show
ShowUninstDetails show


InstType "Full"

Section "!Base"
 SectionIn 1 RO
 SetOutPath $INSTDIR
 File ..\..\EXE\LViewer.exe
 WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "LViewer" $INSTDIR\LViewer.exe
 WriteRegStr HKLM "SOFTWARE\LockViewer" "InstallPath" $INSTDIR
 WriteUninstaller Uninstall.exe
SectionEnd

Section "Uninstall"
 ReadRegStr $INSTDIR HKLM "SOFTWARE\LockViewer" "InstallPath"
 FindWindow $0 "LViewer Class"
 StrCmp $0 0 notRunning
    SendMessage $0 ${WM_CLOSE} 0 0 ;if running then close
 notRunning:
; Delete $INSTDIR\Src\exe\*.*
; Delete $INSTDIR\Src\*.*
 Delete $INSTDIR\*.*
 RMDir  $INSTDIR
 DeleteRegValue HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "LViewer"
 DeleteRegKey   HKLM "SOFTWARE\LockViewer"
 DeleteRegKey   HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\LockViewer 2.0.1"
 DeleteRegKey   HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Management\ARPCache\LockViewer 2.0.1"
SectionEnd

Function .onInit
 ReadRegStr $1 HKLM "SOFTWARE\LockViewer" "InstallPath"
 StrCmp $1 "" Install
  MessageBox MB_YESNO "This will uninstall Lock Viewer. Continue?" IDNO noUninst
   ExecWait $1\Uninstall.exe
   Abort
  noUninst:
   Abort
 Install:
FunctionEnd
