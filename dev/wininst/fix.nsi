#######################################################################
#
# fix.nsi
#
#
# TO-DO: 
# - check GAP version, if 4.3 then exit
#

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
var GAP_VER_OLD   # GAP version before update (in format 4.4.11)
var GAP_VER_NEW   # GAP version after update (in format 4.4.12)

#######################################################################
#
# The function .onInit find the packages directory in the gap.ini file
#
Function .onInit
   ReadINIStr $GAP_VER_OLD $WINDIR\gap.ini Configuration Version
   ReadINIStr $INSTDIR $WINDIR\gap.ini Configuration InstallDir
   StrCmp $GAP_VER_OLD "" 0 NoAbort
     MessageBox MB_OK "GAP 4.4 not found. If you actually have GAP 4.4, please select install path manually."
   NoAbort:
FunctionEnd


#######################################################################
#
# GAP version after update is stored in $GAP_VER_NEW - 
# change it here when wrapping the new release
#
Section
StrCpy $GAP_VER_NEW "4.4.12"
SectionEnd


#######################################################################
#
# Setup
#
# The name of the installer
Name "GAP 4.4.12 update"

# The file to write (change its name when wrapping new release)
OutFile "fix4r4p12.exe"
# Language file (required to add version information)
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
# Set compressing method (for test compiling may be commented out)
SetCompressor /SOLID lzma


#######################################################################
#
# Version Information - to be updated when wrappting . 
# Windows shows this information on the Version tab of the File properties.
#
VIProductVersion "4.4.12.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "GAP 4.4.12"
VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "Free, open and extensible system for computational discrete algebra, distributed under the terms of the GNU General Public License"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "The GAP Group, http://www.gap-system.org"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "Copyright (C) (1987-2008) by the GAP Group"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "The GAP Group, http://www.gap-system.org"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "GAP 4.4.12 update for Windows"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "4.4.12"


#######################################################################
#
# Pages
#
Page directory
Page instfiles


#######################################################################
#
# The stuff to install
Section "GAP 4.4.12 update"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put file there
  File fix\*.*

  SetOutPath $INSTDIR\bin
  File fix\bin\*.*
  SetOutPath $INSTDIR\cnf
  File fix\cnf\*.*
  SetOutPath $INSTDIR\doc
  File fix\doc\*.*
  SetOutPath $INSTDIR\doc\ext
  File fix\doc\ext\*.*
  SetOutPath $INSTDIR\doc\htm
  File fix\doc\htm\*.*
  SetOutPath $INSTDIR\doc\htm\ext
  File fix\doc\htm\ext\*.*
  SetOutPath $INSTDIR\doc\htm\new
  File fix\doc\htm\new\*.*
  SetOutPath $INSTDIR\doc\htm\prg
  File fix\doc\htm\prg\*.*
  SetOutPath $INSTDIR\doc\htm\ref
  File fix\doc\htm\ref\*.*
  SetOutPath $INSTDIR\doc\htm\tut
  File fix\doc\htm\tut\*.*
  SetOutPath $INSTDIR\doc\new
  File fix\doc\new\*.*
  SetOutPath $INSTDIR\doc\prg
  File fix\doc\prg\*.*
  SetOutPath $INSTDIR\doc\ref
  File fix\doc\ref\*.*
  SetOutPath $INSTDIR\doc\test
  File fix\doc\test\*.*
  SetOutPath $INSTDIR\doc\tut
  File fix\doc\tut\*.*
  SetOutPath $INSTDIR\etc\emacs
  File fix\etc\emacs\*.*
  SetOutPath $INSTDIR\grp
  File fix\grp\*.*
  SetOutPath $INSTDIR\lib
  File fix\lib\*.*
  SetOutPath $INSTDIR\pkg\tomlib
  File fix\pkg\tomlib\*.*
  SetOutPath $INSTDIR\pkg\tomlib\data
  File fix\pkg\tomlib\data\*.*
  SetOutPath $INSTDIR\pkg\tomlib\doc
  File fix\pkg\tomlib\doc\*.*
  SetOutPath $INSTDIR\pkg\tomlib\htm
  File fix\pkg\tomlib\htm\*.*
  SetOutPath $INSTDIR\prim
  File fix\prim\*.*
  SetOutPath $INSTDIR\prim\grps
  File fix\prim\grps\*.*
  SetOutPath $INSTDIR\small
  File fix\small\*.*
  SetOutPath $INSTDIR\small\id10
  File fix\small\id10\*.*
  SetOutPath $INSTDIR\small\id2
  File fix\small\id2\*.*
  SetOutPath $INSTDIR\small\id9
  File fix\small\id9\*.*
  SetOutPath $INSTDIR\small\small10
  File fix\small\small10\*.*
  SetOutPath $INSTDIR\small\small2
  File fix\small\small2\*.*
  SetOutPath $INSTDIR\small\small3
  File fix\small\small3\*.*
  SetOutPath $INSTDIR\small\small7
  File fix\small\small7\*.*
  SetOutPath $INSTDIR\small\small8
  File fix\small\small8\*.*
  SetOutPath $INSTDIR\small\small9
  File fix\small\small9\*.*
  SetOutPath $INSTDIR\src
  File fix\src\*.*
  SetOutPath $INSTDIR\tst
  File fix\tst\*.*

  # needed to support packages with dynamically loaded modules

  SetOutPath $INSTDIR\bin\i686-pc-cygwin-gcc
  File fix\bin\i686-pc-cygwin-gcc\*.*

  SetOutPath $INSTDIR\pkg\Browse\bin\i686-pc-cygwin-gcc
  File fix\pkg\Browse\bin\i686-pc-cygwin-gcc\*.*

  SetOutPath $INSTDIR\pkg\edim\bin\i686-pc-cygwin-gcc
  File fix\pkg\edim\bin\i686-pc-cygwin-gcc\*.*

  SetOutPath $INSTDIR\pkg\io\bin\i686-pc-cygwin-gcc
  File fix\pkg\io\bin\i686-pc-cygwin-gcc\*.*

  SetOutPath $INSTDIR\terminfo\c
  File fix\terminfo\c\*.*

  SetOutPath $INSTDIR\terminfo\r
  File fix\terminfo\r\*.*

  SetOutPath $INSTDIR\terminfo\x
  File fix\terminfo\x\*.*

  # restore initial output path
  SetOutPath $INSTDIR 

  # Update the uninstall key for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP" "DisplayName" "GAP 4.4.12"

  # (Re)write gap.ini file, for example:
  #
  # [configuration]
  # Version = 4.4.12
  # InstallDir = C:\GAP4r4
  # PkgDir = C:\GAP4r4\pkg
  #
  FileOpen $GAP_INI $WINDIR\gap.ini w
    FileWrite $GAP_INI "[configuration]"
      FileWriteByte $GAP_INI "13"
      FileWriteByte $GAP_INI "10"
    FileWrite $GAP_INI "Version = "
    FileWrite $GAP_INI $GAP_VER_NEW
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


# Updating start menu shortcuts
  Delete "$SMPROGRAMS\GAP $GAP_VER_OLD\*.*"
  RMDir "$SMPROGRAMS\GAP $GAP_VER_OLD"
  CreateDirectory "$SMPROGRAMS\GAP $GAP_VER_NEW"
  CreateShortCut  "$SMPROGRAMS\GAP $GAP_VER_NEW\Uninstall GAP $GAP_VER_NEW.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut  "$SMPROGRAMS\GAP $GAP_VER_NEW\GAP $GAP_VER_NEW.lnk" "$INSTDIR\bin\gap.bat" "" "$INSTDIR\bin\gapicon.ico" 0
  CreateShortCut  "$SMPROGRAMS\GAP $GAP_VER_NEW\GAP $GAP_VER_NEW RXVT.lnk" "$INSTDIR\bin\gaprxvt.bat" "" "$INSTDIR\bin\gaprxvt.ico" 0
  CreateShortCut  "$SMPROGRAMS\GAP $GAP_VER_NEW\GAP $GAP_VER_NEW (DLL version).lnk" "$INSTDIR\bin\gapp.bat" "" "$INSTDIR\bin\gapicon.ico" 0
  CreateShortCut  "$SMPROGRAMS\GAP $GAP_VER_NEW\GAP $GAP_VER_NEW RXVT (DLL version).lnk" "$INSTDIR\bin\gapprxvt.bat" "" "$INSTDIR\bin\gaprxvt.ico" 0
  CreateShortCut  "$SMPROGRAMS\GAP $GAP_VER_NEW\GAP Documentation.lnk" "$INSTDIR\doc\htmie\index.htm" "" "$INSTDIR\doc\htmie\index.htm" 0

SectionEnd