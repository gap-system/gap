#######################################################################
#
# gap.nsi
#
# $Id$
#
# To make the GAP installer for Windows:
# - create the subdirectories 'gap', 'htmie', 'tools', 'xtom' in the 
#   directory with gap.nsi 
# - unpack each of the archives to the corresponding folder 
#   (to have gap/gap4r4/bin, htmie/gap4r4/doc/htmie etc.)
# - remove the executable file for MacOS
# - put gapicon.ico, gaprxvt.ico and GPL.txt files in the folder
#   with gap.nsi script
# - compile the script
# - perform test installation with various components and compare it 
#   with the content of source directories
#
# TO-DO: 
# - detecting Cygwin installation and at least displaying a warning
# - checking user's permissions?
# - welcome and closing screens 
# - suggest user feedback
# - suggest to remove manually GAP root directory after uninstall


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
# GAP version is stored in $GAP_VER - 
# change it here when wrapping the new release
#
Section
StrCpy $GAP_VER "4.4.12"
SectionEnd


#######################################################################
#
# Setup
#
# The name of the installer (we no not add the 3rd number here because
# this name can not be changed during update
Name "GAP 4.4 distribution"

# The file to write (change its name when wrapping new release)
OutFile "gap4r4p12.exe"

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
# Version Information - to be updated when wrappting . 
# Windows shows this information on the Version tab of the File properties.
#
VIProductVersion "4.4.12.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "GAP 4.4.12"
VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "Free, open and extensible system for computational discrete algebra, distributed under the terms of the GNU General Public License"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "The GAP Group, http://www.gap-system.org"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "Copyright (C) (1987-2008) by the GAP Group"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "The GAP Group, http://www.gap-system.org"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "GAP 4.4.12 distribution for Windows"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "4.4.12"


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

Page license
LicenseData gpl.txt

Page components

Page directory
DirText "Setup will install GAP 4.4.12 in the following folder. To install in a different folder, click Browse and select another folder. The name of the folder should be a single word (names with more than 8 letters and underscores are possible). Click Install to start the installation." "" "" ""

Page instfiles

UninstPage uninstConfirm
UninstPage instfiles


#######################################################################
#
# The files to install
#
# Component 1
#
Section "The core GAP system (required)"

  SectionIn RO

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put file there
  File gap\gap4r4\*.*

  SetOutPath $INSTDIR\bin
  File gap\gap4r4\bin\*.*
  File gapicon.ico
  File gaprxvt.ico

  SetOutPath $INSTDIR\cnf
  File gap\gap4r4\cnf\*.*

  SetOutPath $INSTDIR\doc
  File gap\gap4r4\doc\*.*
  SetOutPath $INSTDIR\doc
  File gap\gap4r4\doc\*.*
  SetOutPath $INSTDIR\doc\ext
  File gap\gap4r4\doc\ext\*.*

  SetOutPath $INSTDIR\doc\htm
  File gap\gap4r4\doc\htm\*.*
  SetOutPath $INSTDIR\doc\htm\ext
  File gap\gap4r4\doc\htm\ext\*.*
  SetOutPath $INSTDIR\doc\htm\new
  File gap\gap4r4\doc\htm\new\*.*
  SetOutPath $INSTDIR\doc\htm\prg
  File gap\gap4r4\doc\htm\prg\*.*
  SetOutPath $INSTDIR\doc\htm\ref
  File gap\gap4r4\doc\htm\ref\*.*
  SetOutPath $INSTDIR\doc\htm\tut
  File gap\gap4r4\doc\htm\tut\*.*

  SetOutPath $INSTDIR\doc\new
  File gap\gap4r4\doc\new\*.*
  SetOutPath $INSTDIR\doc\prg
  File gap\gap4r4\doc\prg\*.*
  SetOutPath $INSTDIR\doc\ref
  File gap\gap4r4\doc\ref\*.*
  SetOutPath $INSTDIR\doc\test
  File gap\gap4r4\doc\test\*.*
  SetOutPath $INSTDIR\doc\tut
  File gap\gap4r4\doc\tut\*.*

  SetOutPath $INSTDIR\etc
  File gap\gap4r4\etc\*.*
  SetOutPath $INSTDIR\etc\emacs
  File gap\gap4r4\etc\emacs\*.*

  SetOutPath $INSTDIR\grp
  File gap\gap4r4\grp\*.*
  SetOutPath $INSTDIR\lib
  File gap\gap4r4\lib\*.*

  SetOutPath $INSTDIR\pkg
  File gap\gap4r4\pkg\*.*
  SetOutPath $INSTDIR\pkg\tomlib
  File gap\gap4r4\pkg\tomlib\*.*
  SetOutPath $INSTDIR\pkg\tomlib\data
  File gap\gap4r4\pkg\tomlib\data\*.*
  SetOutPath $INSTDIR\pkg\tomlib\doc
  File gap\gap4r4\pkg\tomlib\doc\*.*
  SetOutPath $INSTDIR\pkg\tomlib\gap
  File gap\gap4r4\pkg\tomlib\gap\*.*
  SetOutPath $INSTDIR\pkg\tomlib\htm
  File gap\gap4r4\pkg\tomlib\htm\*.*
  SetOutPath $INSTDIR\pkg\tomlib\tst
  File gap\gap4r4\pkg\tomlib\tst\*.*

  SetOutPath $INSTDIR\prim
  File gap\gap4r4\prim\*.*
  SetOutPath $INSTDIR\prim\grps
  File gap\gap4r4\prim\grps\*.*

  SetOutPath $INSTDIR\small
  File gap\gap4r4\small\*.*

  SetOutPath $INSTDIR\small\id2
  File gap\gap4r4\small\id2\*.*
  SetOutPath $INSTDIR\small\id3
  File gap\gap4r4\small\id3\*.*
  SetOutPath $INSTDIR\small\id4
  File gap\gap4r4\small\id4\*.*
  SetOutPath $INSTDIR\small\id5
  File gap\gap4r4\small\id5\*.*
  SetOutPath $INSTDIR\small\id6
  File gap\gap4r4\small\id6\*.*
  SetOutPath $INSTDIR\small\id9
  File gap\gap4r4\small\id9\*.*
  SetOutPath $INSTDIR\small\id10
  File gap\gap4r4\small\id10\*.*

  SetOutPath $INSTDIR\small\small2
  File gap\gap4r4\small\small2\*.*
  SetOutPath $INSTDIR\small\small3
  File gap\gap4r4\small\small3\*.*
  SetOutPath $INSTDIR\small\small4
  File gap\gap4r4\small\small4\*.*
  SetOutPath $INSTDIR\small\small5
  File gap\gap4r4\small\small5\*.*
  SetOutPath $INSTDIR\small\small6
  File gap\gap4r4\small\small6\*.*
  SetOutPath $INSTDIR\small\small7
  File gap\gap4r4\small\small7\*.*
  SetOutPath $INSTDIR\small\small8
  File gap\gap4r4\small\small8\*.*
  SetOutPath $INSTDIR\small\small9
  File gap\gap4r4\small\small9\*.*
  SetOutPath $INSTDIR\small\small10
  File gap\gap4r4\small\small10\*.*

  SetOutPath $INSTDIR\src
  File gap\gap4r4\src\*.*

  SetOutPath $INSTDIR\trans
  File gap\gap4r4\trans\*.*

  SetOutPath $INSTDIR\tst
  File gap\gap4r4\tst\*.*

  # needed to support packages with dynamically loaded modules

  SetOutPath $INSTDIR\bin\i686-pc-cygwin-gcc
  File gap\gap4r4\bin\i686-pc-cygwin-gcc\*.*

  SetOutPath $INSTDIR\pkg\Browse\bin\i686-pc-cygwin-gcc
  File gap\gap4r4\pkg\Browse\bin\i686-pc-cygwin-gcc\*.*

  SetOutPath $INSTDIR\pkg\edim\bin\i686-pc-cygwin-gcc
  File gap\gap4r4\pkg\edim\bin\i686-pc-cygwin-gcc\*.*

  SetOutPath $INSTDIR\pkg\io\bin\i686-pc-cygwin-gcc
  File gap\gap4r4\pkg\io\bin\i686-pc-cygwin-gcc\*.*

  SetOutPath $INSTDIR\terminfo\c
  File gap\gap4r4\terminfo\c\*.*

  SetOutPath $INSTDIR\terminfo\r
  File gap\gap4r4\terminfo\r\*.*

  SetOutPath $INSTDIR\terminfo\x
  File gap\gap4r4\terminfo\x\*.*

  # restore initial output path
  SetOutPath $INSTDIR 

  # Write the installation path into the registry
  WriteRegStr HKLM "Software\GAP" "Install_Dir" "$INSTDIR"
  
  # Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP" "DisplayName" "GAP $GAP_VER"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP" "NoRepair" 1
  WriteUninstaller "uninstall.exe"

  # Write gap.ini file, for example:
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


# Component 2 (optional)
Section "Additional table of marks"
  SetOutPath $INSTDIR\pkg\tomlib\data
  File xtom\gap4r4\pkg\tomlib\data\*.*
  File xtom\gap4r4\pkg\tomlib\data\tmo8m2.tom
  File xtom\gap4r4\pkg\tomlib\data\tmo8m2m1.tom
  File xtom\gap4r4\pkg\tomlib\data\tmo8p2.tom
  File xtom\gap4r4\pkg\tomlib\data\tmo8p2m4.tom
  SetOutPath $INSTDIR 
SectionEnd


# Component 3 (optional)
Section "Utilities for package authors"
  SetOutPath $INSTDIR\doc
  File tools\gap4r4\doc\*.*
  SetOutPath $INSTDIR\doc\htm
  File tools\gap4r4\doc\htm\*.*
  SetOutPath $INSTDIR\doc\build
  File tools\gap4r4\doc\build\*.*
  SetOutPath $INSTDIR\etc
  File tools\gap4r4\etc\*.*
  SetOutPath $INSTDIR 
SectionEnd


# Component 4 (optional)
Section "HTML documentation optimised for MS Internet Explorer"
  SetOutPath $INSTDIR\doc\htmie
  File htmie\gap4r4\doc\htmie\*.*
  SetOutPath $INSTDIR\doc\htmie\ext
  File htmie\gap4r4\doc\htmie\ext\*.*
  SetOutPath $INSTDIR\doc\htmie\new
  File htmie\gap4r4\doc\htmie\new\*.*
  SetOutPath $INSTDIR\doc\htmie\prg
  File htmie\gap4r4\doc\htmie\prg\*.*
  SetOutPath $INSTDIR\doc\htmie\ref
  File htmie\gap4r4\doc\htmie\ref\*.*
  SetOutPath $INSTDIR\doc\htmie\tut
  File htmie\gap4r4\doc\htmie\tut\*.*
  SetOutPath $INSTDIR 
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


#######################################################################
#
# Uninstaller
Section "Uninstall"

  # we determine the currently installed version of GAP
  # because it may be changed by updates. We need to know
  # it to delete Start menu shortcuts
  ReadINIStr $GAP_VER $WINDIR\gap.ini Configuration Version

  # Remove shortcuts, if any
  Delete "$SMPROGRAMS\GAP $GAP_VER\*.*"
  Delete  $DESKTOP\GAP.lnk
  Delete  $DESKTOP\GAPRXVT.lnk
  Delete "$DESKTOP\GAP (DLL version).lnk"
  Delete "$DESKTOP\GAPRXVT (DLL version).lnk"
  Delete "$DESKTOP\GAP Documentation.lnk"
  Delete  $QUICKLAUNCH\GAP.lnk
  Delete  $QUICKLAUNCH\GAPRXVT.lnk 
  Delete "$QUICKLAUNCH\GAP (DLL version).lnk"
  Delete "$QUICKLAUNCH\GAPRXVT (DLL version).lnk"

  # Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP"
  DeleteRegKey HKLM SOFTWARE\GAP

  # Remove files and uninstaller, if necessary
  SetOutPath $INSTDIR 
  Delete $INSTDIR\*.*
  Delete $WINDIR\gap.ini

  # Remove directories used (the GAP root directory will be not deleted
  # in order to preserve user directories if they were placed there)
  RMDir "$SMPROGRAMS\GAP $GAP_VER"
  RMDir /r $INSTDIR\bin
  RMDir /r $INSTDIR\cnf
  RMDir /r $INSTDIR\doc
  RMDir /r $INSTDIR\etc
  RMDir /r $INSTDIR\grp
  RMDir /r $INSTDIR\lib
  RMDir /r $INSTDIR\pkg
  RMDir /r $INSTDIR\prim
  RMDir /r $INSTDIR\small
  RMDir /r $INSTDIR\src
  RMDir /r $INSTDIR\trans
  RMDir /r $INSTDIR\tst

SectionEnd
