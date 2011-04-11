#######################################################################
#
# GAP_MINI.NSI
#
# To make the minimal GAP installer for Windows:
# - create the subdirectory gap4r4 in the directory with gap_mini.nsi
# - put into gap4r4 directories 'bin', 'doc/htmie', 'grp' and 'lib'
# - create an empty directory 'gap4r4/pkg' and put PKGDIR file into it
# - put gapicon.ico, gaprxvt.ico and GPL.txt files in the folder
#   with GAP_MINI script
# - compile the script
# - perform test installation with various components and compare it 
#   with the content of source directories
#
# TO-DO: 
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
var GAP_INI       # to write minigap.ini file
var GAP_BAT       # to write gap.bat file
var GAPRXVT_BAT   # to write gaprxvt.bat file
var RXVT_PATH     # Install path in the form C/GAP4R4
var GAP_VER       # GAP version in format 4.4.10


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
Name "GAP 4.4 mini-distribution"

# The file to write (change its name when wrapping new release)
OutFile "mini4410.exe"

# Language file (required to add version information)
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
# Set compressing method (for test compiling may be commented out)
SetCompressor /SOLID lzma


#######################################################################
#
# Version Information - to be updated when wrappting . 
# Windows shows this information on the Version tab of the File properties.
#
VIProductVersion "4.4.10.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "GAP 4.4.10 mini"
VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "Free, open and extensible system for computational discrete algebra, distributed under the terms of the GNU General Public License"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "The GAP Group, http://www.gap-system.org"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "Copyright (C) (1987-2005) by the GAP Group"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "The GAP Group, http://www.gap-system.org"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "GAP 4.4.10 mini distribution for Windows"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "4.4.10"


#######################################################################
#
# Defining installation path 
# The default installation directory is C:\GAP4r4
# (we do not support InstallDir $PROGRAMFILES\GAP4r4
# because GAP can not find the library in this case)
InstallDir C:\GAP4R4_MINI

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
DirText "Setup will install the minimal configuration of GAP 4.4.10 in the following folder. To install in a different folder, click Browse and select another folder. The name of the folder should be a single word (names with more than 8 letters and underscores are possible). Click Install to start the installation." "" "" ""

Page instfiles

UninstPage uninstConfirm
UninstPage instfiles


#######################################################################
#
# The files to install
#
Section "basic GAP components (required)"

  SectionIn RO

  # Set output path to the installation directory.
  SetOutPath $INSTDIR\bin
  # Put file there
  File gap4r4\bin\*.*
  File gapicon.ico
  File gaprxvt.ico

  SetOutPath $INSTDIR\doc\htmie
  File gap4r4\doc\htmie\*.*
  SetOutPath $INSTDIR\doc\htmie\ext
  File gap4r4\doc\htmie\ext\*.*
  SetOutPath $INSTDIR\doc\htmie\new
  File gap4r4\doc\htmie\new\*.*
  SetOutPath $INSTDIR\doc\htmie\prg
  File gap4r4\doc\htmie\prg\*.*
  SetOutPath $INSTDIR\doc\htmie\ref
  File gap4r4\doc\htmie\ref\*.*
  SetOutPath $INSTDIR\doc\htmie\tut
  File gap4r4\doc\htmie\tut\*.*

  SetOutPath $INSTDIR\grp
  File gap4r4\grp\*.*

  SetOutPath $INSTDIR\lib
  File gap4r4\lib\*.*

  SetOutPath $INSTDIR\pkg
  # to create an empty directory 'pkg'
  File gap4r4\pkg\*.*

  # restore initial output path
  SetOutPath $INSTDIR 

  # Write the installation path into the registry
  WriteRegStr HKLM "Software\GAP_MINI" "Install_Dir" "$INSTDIR"
  
  # Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP_MINI" "DisplayName" "GAP $GAP_VER mini"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP_MINI" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP_MINI" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP_MINI" "NoRepair" 1
  WriteUninstaller "uninstall.exe"

  # Write minigap.ini file, for example:
  #
  # [configuration]
  # Version = 4.4.10
  # InstallDir = C:\GAP4r4
  # PkgDir = C:\GAP4r4\pkg
  #
  FileOpen $GAP_INI $WINDIR\minigap.ini w
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
  # C:\GAP4R4\bin\gapw95.exe -m 32m -l C:\GAP4R4\ %1 %2 %3 %4 %5 %6 %7 %8
  FileOpen $GAP_BAT $INSTDIR\bin\gap.bat w
    FileWrite $GAP_BAT $INSTDIR
    FileWrite $GAP_BAT "\bin\gapw95.exe -m 24m -l "
    FileWrite $GAP_BAT $INSTDIR
    FileWrite $GAP_BAT "\ %1 %2 %3 %4 %5 %6 %7 %8"
  FileClose $GAP_BAT

  # Write gaprxvt.bat file, for example:
  # c:\gap4r4\bin\rxvt.exe -fn fixedsys -sl 1000 -e /cygdrive/c/GAP4R4/BIN/gapw95.exe -l /cygdrive/c/GAP4R4
  # exit  
  FileOpen $GAPRXVT_BAT $INSTDIR\bin\gaprxvt.bat w
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
      FileWriteByte $GAP_INI "13"
      FileWriteByte $GAP_INI "10"
    FileWrite $GAPRXVT_BAT "exit"
  FileClose $GAPRXVT_BAT

SectionEnd


# Optional section (can be disabled by the user)
Section "Start menu shortcuts"
  CreateDirectory "$SMPROGRAMS\MINI GAP $GAP_VER"
  CreateShortCut  "$SMPROGRAMS\MINI GAP $GAP_VER\Uninstall GAP $GAP_VER.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut  "$SMPROGRAMS\MINI GAP $GAP_VER\GAP $GAP_VER.lnk" "$INSTDIR\bin\gap.bat" "" "$INSTDIR\bin\gapicon.ico" 0
  CreateShortCut  "$SMPROGRAMS\MINI GAP $GAP_VER\GAP $GAP_VER RXVT.lnk" "$INSTDIR\bin\gaprxvt.bat" "" "$INSTDIR\bin\gaprxvt.ico" 0
  CreateShortCut  "$SMPROGRAMS\MINI GAP $GAP_VER\GAP Documentation.lnk" "$INSTDIR\doc\htmie\index.htm" "" "$INSTDIR\doc\htmie\index.htm" 0
SectionEnd


# Optional section (can be disabled by the user)
Section "Desktop shortcuts"
  CreateShortCut "$DESKTOP\GAP MINI.lnk" "$INSTDIR\bin\gap.bat" "" "$INSTDIR\bin\gapicon.ico" 0
  CreateShortCut "$DESKTOP\GAPRXVT MINI.lnk" "$INSTDIR\bin\gaprxvt.bat" "" "$INSTDIR\bin\gaprxvt.ico" 0
  CreateShortCut "$DESKTOP\GAP MINI Documentation.lnk" "$INSTDIR\doc\htmie\index.htm" "" "$INSTDIR\doc\htmie\index.htm" 0
SectionEnd


# Optional section (can be disabled by the user)
Section "Quick Launch Shortcuts"
  CreateShortCut "$QUICKLAUNCH\GAP MINI.lnk" "$INSTDIR\bin\gap.bat" "" "$INSTDIR\bin\gapicon.ico" 0
  CreateShortCut "$QUICKLAUNCH\GAPRXVT MINI.lnk" "$INSTDIR\bin\gaprxvt.bat" "" "$INSTDIR\bin\gaprxvt.ico" 0
SectionEnd


#######################################################################
#
# Uninstaller
Section "Uninstall"

  # we determine the currently installed version of GAP
  # because it may be changed by updates. We need to know
  # it to delete Start menu shortcuts
  ReadINIStr $GAP_VER $WINDIR\minigap.ini Configuration Version

  # Remove shortcuts, if any
  Delete "$SMPROGRAMS\MINI GAP $GAP_VER\*.*"
  Delete "$DESKTOP\GAP MINI.lnk"
  Delete "$DESKTOP\GAPRXVT MINI.lnk"
  Delete "$DESKTOP\GAP MINI Documentation.lnk"
  Delete "$QUICKLAUNCH\GAP MINI.lnk"
  Delete "$QUICKLAUNCH\GAPRXVT MINI.lnk" 
  
  # Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GAP MINI"
  DeleteRegKey HKLM "SOFTWARE\GAP MINI"

  # Remove files and uninstaller, if necessary
  SetOutPath $INSTDIR 
  Delete $INSTDIR\*.*
  Delete $WINDIR\minigap.ini

  # Remove directories used (the GAP root directory will be not deleted
  # in order to preserve user directories if they were placed there)
  RMDir "$SMPROGRAMS\GAP $GAP_VER MINI"
  RMDir /r $INSTDIR\bin
  RMDir /r $INSTDIR\doc
  RMDir /r $INSTDIR\grp
  RMDir /r $INSTDIR\lib
  RMDir /r $INSTDIR\pkg

SectionEnd