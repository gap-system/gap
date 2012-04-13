#######################################################################
#
# winbin.nsi
#
#
# To make the winbin patch for Windows:
# - unpack the winbin....zip archive in the directory with gap.nsi 
#   to get the subdirectory gap4r4 with bin, pkg and terminfo in it
# - compile the script
# - perform test installation with various components and compare it 
#   with the content of source directories

#######################################################################
#
# include headers
#
!include "WordFunc.nsh"
!insertmacro WordReplace


#######################################################################
#
# User variables
#
var GAP_INI       # to write gap.ini file
var GAP_BAT       # to write gap.bat file
var GAPRXVT_BAT   # to write gaprxvt.bat file
var GAPP_BAT      # to write gapp.bat file
var GAPPRXVT_BAT  # to write gapprxvt.bat file
var RXVT_PATH     # Install path in the form C/GAP4R4
var GAP_VER       # GAP version in format 4.4.12


#######################################################################
#
# The function .onInit find the packages directory in the gap.ini file
#
Function .onInit
   ReadINIStr $INSTDIR $WINDIR\gap.ini Configuration InstallDir
   StrCmp $INSTDIR "" 0 NoAbort
     MessageBox MB_OK "GAP not found. You will be able to select install path manually later."
   NoAbort:
FunctionEnd


#######################################################################
#
# GAP version is stored in $GAP_VER - 
# change it here when wrapping the new release
#
Section
StrCpy $GAP_VER "4.4.10"
SectionEnd


#######################################################################
#
# Setup
#
# The name of the installer (we no not add the 3rd number here because
# this name can not be changed during update
Name "GAP 4.4 Windows binaries with dynamic loading support"

# The file to write (change its name when wrapping new release)
OutFile "winbin4r4p10ED123IO23BR11.exe"

# Language file (required to add version information)
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
# Set compressing method (for test compiling may be commented out)
# and /SOLID can be removed
SetCompressor /SOLID lzma
# SetCompressor lzma
# SetCompressor /SOLID zlib
# SetCompressor bzip2

#######################################################################
#
# Version Information - to be updated when wrapping . 
# Windows shows this information on the Version tab of the File properties.
#
VIProductVersion "4.4.10.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "GAP 4.4.10"
VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "Free, open and extensible system for computational discrete algebra, distributed under the terms of the GNU General Public License"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "The GAP Group, http://www.gap-system.org"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "Copyright (C) (1987-2006) by the GAP Group"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "The GAP Group, http://www.gap-system.org"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "GAP 4.4.10 distribution for Windows with dynamic loading"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "4.4.10"


#######################################################################
#
# Defining installation path 
# The default installation directory is C:\GAP4r4
# (we do not support InstallDir $PROGRAMFILES\GAP4r4
# because GAP can not find the library in this case)
InstallDir C:\GAP4R4

# Registry key to check for directory (so if you install again, it will 
# overwrite the old one automatically)
InstallDirRegKey HKLM "Software\GAP" "Install_Dir"


#######################################################################
#
# Pages
#
Page components
Page directory
Page instfiles

#######################################################################
#
# The files to install
#
Section "GAP 4.4.10 Windows binaries"

  SectionIn RO

  SetOutPath $INSTDIR\bin
  File gap4r4\bin\*.*
 
  SetOutPath $INSTDIR\bin\i686-pc-cygwin-gcc
  File gap4r4\bin\i686-pc-cygwin-gcc\*.*

  SetOutPath $INSTDIR\pkg\Browse\bin\i686-pc-cygwin-gcc
  File gap4r4\pkg\Browse\bin\i686-pc-cygwin-gcc\*.*
 
  SetOutPath $INSTDIR\pkg\edim\bin\i686-pc-cygwin-gcc
  File gap4r4\pkg\edim\bin\i686-pc-cygwin-gcc\*.*

  SetOutPath $INSTDIR\pkg\io\bin\i686-pc-cygwin-gcc
  File gap4r4\pkg\io\bin\i686-pc-cygwin-gcc\*.*

  SetOutPath $INSTDIR\terminfo\c
  File gap4r4\terminfo\c\*.*

  SetOutPath $INSTDIR\terminfo\r
  File gap4r4\terminfo\r\*.*

  SetOutPath $INSTDIR\terminfo\x
  File gap4r4\terminfo\x\*.*
 
  # restore initial output path
  SetOutPath $INSTDIR 

  # Write the installation path into the registry
  WriteRegStr HKLM "Software\GAP" "Install_Dir" "$INSTDIR"
  
  # Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP" "DisplayName" "GAP $GAP_VER"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP" "NoRepair" 1

  # Write gap.ini file, for example:
  #
  # [configuration]
  # Version = 4.4.10
  # InstallDir = C:\GAP4r4
  # PkgDir = C:\GAP4r4\pkg
  #
  FileOpen $GAP_INI $WINDIR\gap.ini w
    FileWrite $GAP_INI "[configuration]"
      FileWriteByte $GAP_INI "13"
      FileWriteByte $GAP_INI "10"
    FileWrite $GAP_INI "Version = "
    FileWrite $GAP_INI $GAP_VER
      FileWriteByte $GAP_INI "13"
      FileWriteByte $GAP_INI "10"
    FileWrite $GAP_INI "InstallDir = "
    FileWrite $GAP_INI $INSTDIR
      FileWriteByte $GAP_INI "13"
      FileWriteByte $GAP_INI "10"
    FileWrite $GAP_INI "PkgDir = "
    FileWrite $GAP_INI $INSTDIR
    FileWrite $GAP_INI "\pkg"
  FileClose $GAP_INI


  # Write gap.bat file, for example:
  # set TERMINFO=C:\GAP4R4\terminfo
  # C:\GAP4R4\bin\gapw95.exe -m 32m -l C:\GAP4R4\ %1 %2 %3 %4 %5 %6 %7 %8
  FileOpen $GAP_BAT $INSTDIR\bin\gap.bat w
    FileWrite $GAP_BAT "set TERMINFO="
    FileWrite $GAP_BAT $INSTDIR
    FileWrite $GAP_BAT "\terminfo"
      FileWriteByte $GAP_BAT "13"
      FileWriteByte $GAP_BAT "10"
    FileWrite $GAP_BAT $INSTDIR
    FileWrite $GAP_BAT "\bin\gapw95.exe -m 32m -l "
    FileWrite $GAP_BAT $INSTDIR
    FileWrite $GAP_BAT "\ %1 %2 %3 %4 %5 %6 %7 %8"
  FileClose $GAP_BAT


  # Write gapp.bat file, for example:
  # set TERMINFO=C:\GAP4R4\terminfo
  # C:\GAP4R4\bin\gapw95p.exe -m 32m -l C:\GAP4R4\ %1 %2 %3 %4 %5 %6 %7 %8
  FileOpen $GAPP_BAT $INSTDIR\bin\gapp.bat w
    FileWrite $GAPP_BAT "set TERMINFO="
    FileWrite $GAPP_BAT $INSTDIR
    FileWrite $GAPP_BAT "\terminfo"
      FileWriteByte $GAPP_BAT "13"
      FileWriteByte $GAPP_BAT "10"
    FileWrite $GAPP_BAT $INSTDIR
    FileWrite $GAPP_BAT "\bin\gapw95p.exe -m 32m -l "
    FileWrite $GAPP_BAT $INSTDIR
    FileWrite $GAPP_BAT "\ %1 %2 %3 %4 %5 %6 %7 %8"
  FileClose $GAPP_BAT


  # Write gaprxvt.bat file, for example:
  # set TERMINFO=C:\GAP4R4\terminfo
  # c:\gap4r4\bin\rxvt.exe -fn fixedsys -sl 1000 -e /cygdrive/c/GAP4R4/BIN/gapw95.exe -l /cygdrive/c/GAP4R4
  # exit  
  FileOpen $GAPRXVT_BAT $INSTDIR\bin\gaprxvt.bat w
    FileWrite $GAPRXVT_BAT "set TERMINFO="
    FileWrite $GAPRXVT_BAT $INSTDIR
    FileWrite $GAPRXVT_BAT "\terminfo"
      FileWriteByte $GAPRXVT_BAT "13"
      FileWriteByte $GAPRXVT_BAT "10"
    # determine the path in 
    StrCpy $RXVT_PATH $INSTDIR
    ${WordReplace} $RXVT_PATH ":" ""  "+" $RXVT_PATH
    ${WordReplace} $RXVT_PATH "\" "/" "+" $RXVT_PATH
    # writing the command line
    FileWrite $GAPRXVT_BAT $INSTDIR
    FileWrite $GAPRXVT_BAT "\bin\rxvt.exe -fn fixedsys -sl 1000 -e /cygdrive/"
    FileWrite $GAPRXVT_BAT $RXVT_PATH
    FileWrite $GAPRXVT_BAT "/BIN/gapw95.exe -l /cygdrive/"
    FileWrite $GAPRXVT_BAT $RXVT_PATH
      FileWriteByte $GAPRXVT_BAT "13"
      FileWriteByte $GAPRXVT_BAT "10"
    FileWrite $GAPRXVT_BAT "exit"
  FileClose $GAPRXVT_BAT


  # Write gapprxvt.bat file, for example:
  # set TERMINFO=C:\GAP4R4\terminfo
  # c:\gap4r4\bin\rxvt.exe -fn fixedsys -sl 1000 -e /cygdrive/c/GAP4R4/BIN/gapw95p.exe -l /cygdrive/c/GAP4R4
  # exit  
  FileOpen $GAPPRXVT_BAT $INSTDIR\bin\gapprxvt.bat w
    FileWrite $GAPPRXVT_BAT "set TERMINFO="
    FileWrite $GAPPRXVT_BAT $INSTDIR
    FileWrite $GAPPRXVT_BAT "\terminfo"
      FileWriteByte $GAPPRXVT_BAT "13"
      FileWriteByte $GAPPRXVT_BAT "10"
    # determine the path in 
    StrCpy $RXVT_PATH $INSTDIR
    ${WordReplace} $RXVT_PATH ":" ""  "+" $RXVT_PATH
    ${WordReplace} $RXVT_PATH "\" "/" "+" $RXVT_PATH
    # writing the command line
    FileWrite $GAPPRXVT_BAT $INSTDIR
    FileWrite $GAPPRXVT_BAT "\bin\rxvt.exe -fn fixedsys -sl 1000 -e /cygdrive/"
    FileWrite $GAPPRXVT_BAT $RXVT_PATH
    FileWrite $GAPPRXVT_BAT "/BIN/gapw95p.exe -l /cygdrive/"
    FileWrite $GAPPRXVT_BAT $RXVT_PATH
      FileWriteByte $GAPPRXVT_BAT "13"
      FileWriteByte $GAPPRXVT_BAT "10"
    FileWrite $GAPPRXVT_BAT "exit"
  FileClose $GAPPRXVT_BAT

SectionEnd


# Component 5 (optional)
Section "Start menu shortcuts"
  Delete "$SMPROGRAMS\GAP $GAP_VER\*.*"
  RMDir "$SMPROGRAMS\GAP $GAP_VER"
  CreateDirectory "$SMPROGRAMS\GAP $GAP_VER"
  CreateShortCut  "$SMPROGRAMS\GAP $GAP_VER\Uninstall GAP $GAP_VER.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut  "$SMPROGRAMS\GAP $GAP_VER\GAP $GAP_VER.lnk" "$INSTDIR\bin\gap.bat" "" "$INSTDIR\bin\gapicon.ico" 0
  CreateShortCut  "$SMPROGRAMS\GAP $GAP_VER\GAP $GAP_VER RXVT.lnk" "$INSTDIR\bin\gaprxvt.bat" "" "$INSTDIR\bin\gaprxvt.ico" 0
  CreateShortCut  "$SMPROGRAMS\GAP $GAP_VER\GAP $GAP_VER (DLL version).lnk" "$INSTDIR\bin\gapp.bat" "" "$INSTDIR\bin\gapicon.ico" 0
  CreateShortCut  "$SMPROGRAMS\GAP $GAP_VER\GAP $GAP_VER RXVT (DLL version).lnk" "$INSTDIR\bin\gapprxvt.bat" "" "$INSTDIR\bin\gaprxvt.ico" 0
  CreateShortCut  "$SMPROGRAMS\GAP $GAP_VER\GAP Documentation.lnk" "$INSTDIR\doc\htmie\index.htm" "" "$INSTDIR\doc\htmie\index.htm" 0
SectionEnd


# Component 6 (optional)
Section "Desktop shortcuts"
  CreateShortCut "$DESKTOP\GAP.lnk" "$INSTDIR\bin\gap.bat" "" "$INSTDIR\bin\gapicon.ico" 0
  CreateShortCut "$DESKTOP\GAPRXVT.lnk" "$INSTDIR\bin\gaprxvt.bat" "" "$INSTDIR\bin\gaprxvt.ico" 0
  CreateShortCut "$DESKTOP\GAP (DLL version).lnk" "$INSTDIR\bin\gapp.bat" "" "$INSTDIR\bin\gapicon.ico" 0
  CreateShortCut "$DESKTOP\GAPRXVT (DLL version).lnk" "$INSTDIR\bin\gapprxvt.bat" "" "$INSTDIR\bin\gaprxvt.ico" 0
  CreateShortCut "$DESKTOP\GAP Documentation.lnk" "$INSTDIR\doc\htmie\index.htm" "" "$INSTDIR\doc\htmie\index.htm" 0
SectionEnd


# Component 7 (optional)
Section "Quick Launch Shortcuts"
  CreateShortCut "$QUICKLAUNCH\GAP.lnk" "$INSTDIR\bin\gap.bat" "" "$INSTDIR\bin\gapicon.ico" 0
  CreateShortCut "$QUICKLAUNCH\GAPRXVT.lnk" "$INSTDIR\bin\gaprxvt.bat" "" "$INSTDIR\bin\gaprxvt.ico" 0
  CreateShortCut "$QUICKLAUNCH\GAP (DLL version).lnk" "$INSTDIR\bin\gapp.bat" "" "$INSTDIR\bin\gapicon.ico" 0
  CreateShortCut "$QUICKLAUNCH\GAPRXVT (DLL version).lnk" "$INSTDIR\bin\gapprxvt.bat" "" "$INSTDIR\bin\gaprxvt.ico" 0
SectionEnd