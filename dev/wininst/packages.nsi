#######################################################################
# 
# packages.nsi
#
# $Id: packages.nsi,v 1.48 2009/09/12 20:36:22 alexk Exp $
# 
# To make the GAP packages installer for Windows:
# - create the subdirectory 'pkg' in the directory with packages.nsi 
# - unpack packages archive there (to have pkg/ace, pkg/aclib etc.)
# - compile the script
# - perform test installation and compare it with the content of 'pkg'
#
# TO-DO: 
# - trace dependencies between packages?
# - add info about working under Windows


#######################################################################
#
# The function .onInit find the packages directory in the gap.ini file
#
Function .onInit
   ReadINIStr $INSTDIR $WINDIR\gap.ini Configuration PkgDir
   StrCmp $INSTDIR "" 0 NoAbort
     MessageBox MB_OK "GAP not found. You will be able to select install path manually later."
   NoAbort:
FunctionEnd


#######################################################################
#
# Setup
#
# The name of the installer
Name "GAP 4.4 packages"
# The file to write
OutFile "packages-2009_09_10-09_28_UTC.exe"
# Set compressing method (for test compiling may be commented out)
SetCompressor /SOLID lzma
# In Linux, SOLID lzma may not work - just comment it out

#######################################################################
#
# Pages
#
Page components
Page directory
DirText "Setup will install GAP packages in the following folder. If GAP was not found on your computer, click Browse and select the folder manually. For proper installation this should be gap4r4/pkg folder of your GAP installation. Then click Install to start the installation." "" "" ""

Page instfiles


#######################################################################
# 
# The packages to install
#

#######################################################################
#
# ACE
#
Section "ACE - Advanced Coset Enumerator"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.ace

  SetOutPath $INSTDIR\ace
  File pkg\ace\*.*
  SetOutPath $INSTDIR\ace\doc
  File pkg\ace\doc\*.*
  SetOutPath $INSTDIR\ace\examples
  File pkg\ace\examples\*.*
  SetOutPath $INSTDIR\ace\gap
  File pkg\ace\gap\*.*
  SetOutPath $INSTDIR\ace\htm
  File pkg\ace\htm\*.*
  SetOutPath $INSTDIR\ace\res-examples
  File pkg\ace\res-examples\*.*
  SetOutPath $INSTDIR\ace\src
  File pkg\ace\src\*.*
  SetOutPath $INSTDIR\ace\src\ex
  File pkg\ace\src\ex\*.*
  SetOutPath $INSTDIR\ace\src\test
  File pkg\ace\src\test\*.*
  SetOutPath $INSTDIR\ace\standalone-doc
  File pkg\ace\standalone-doc\*.*
  SetOutPath $INSTDIR\ace\tst
  File pkg\ace\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# AClib
#
Section "AClib - Almost Crystallographic Groups - A Library and Algorithms"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.aclib

  SetOutPath $INSTDIR\aclib
  File pkg\aclib\*.*
  SetOutPath $INSTDIR\aclib\doc
  File pkg\aclib\doc\*.*
  SetOutPath $INSTDIR\aclib\gap
  File pkg\aclib\gap\*.*
  SetOutPath $INSTDIR\aclib\htm
  File pkg\aclib\htm\*.*
  SetOutPath $INSTDIR\aclib\htm
  File pkg\aclib\htm\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Alnuth 
#
Section "Alnuth - Algebraic number theory and an interface to KANT (needs KANT/KASH Computer Algebra System"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.alnuth

  SetOutPath $INSTDIR\alnuth
  File pkg\alnuth\*.*
  SetOutPath $INSTDIR\alnuth\doc
  File pkg\alnuth\doc\*.*
  SetOutPath $INSTDIR\alnuth\exam
  File pkg\alnuth\exam\*.*
  SetOutPath $INSTDIR\alnuth\gap
  File pkg\alnuth\gap\*.*
  SetOutPath $INSTDIR\alnuth\htm
  File pkg\alnuth\htm\*.*
  SetOutPath $INSTDIR\alnuth\lib
  File pkg\alnuth\lib\*.*
  SetOutPath $INSTDIR\alnuth\tst
  File pkg\alnuth\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# ANUPQ 
#
Section "ANUPQ - ANU p-Quotient"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.anupq

  SetOutPath $INSTDIR\anupq
  File pkg\anupq\*.*
  SetOutPath $INSTDIR\anupq\doc
  File pkg\anupq\doc\*.*
  SetOutPath $INSTDIR\anupq\examples
  File pkg\anupq\examples\*.*
  SetOutPath $INSTDIR\anupq\htm
  File pkg\anupq\htm\*.*
  SetOutPath $INSTDIR\anupq\include
  File pkg\anupq\include\*.*
  SetOutPath $INSTDIR\anupq\lib
  File pkg\anupq\lib\*.*
  SetOutPath $INSTDIR\anupq\src
  File pkg\anupq\src\*.*
  SetOutPath $INSTDIR\anupq\standalone\test
  File pkg\anupq\standalone\test\*.*
  SetOutPath $INSTDIR\anupq\standalone-doc
  File pkg\anupq\standalone-doc\*.*
  SetOutPath $INSTDIR\anupq\standalone\examples
  File pkg\anupq\standalone\examples\*.*
  SetOutPath $INSTDIR\anupq\standalone\isom
  File pkg\anupq\standalone\isom\*.*
  SetOutPath $INSTDIR\anupq\tst
  File pkg\anupq\tst\*.*
  SetOutPath $INSTDIR\anupq\tst\out
  File pkg\anupq\tst\out\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# AtlasRep 
#
Section "AtlasRep - A GAP Interface to the Atlas of Group Representations"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.atlasrep

  SetOutPath $INSTDIR\atlasrep
  File pkg\atlasrep\*.*
  SetOutPath $INSTDIR\atlasrep\bibl
  File pkg\atlasrep\bibl\*.*
  SetOutPath $INSTDIR\atlasrep\datagens
  File pkg\atlasrep\datagens\*.*
  SetOutPath $INSTDIR\atlasrep\dataword
  File pkg\atlasrep\dataword\*.*
  SetOutPath $INSTDIR\atlasrep\doc
  File pkg\atlasrep\doc\*.*
  SetOutPath $INSTDIR\atlasrep\etc
  File pkg\atlasrep\etc\*.*
  SetOutPath $INSTDIR\atlasrep\gap
  File pkg\atlasrep\gap\*.*
  SetOutPath $INSTDIR\atlasrep\tst
  File pkg\atlasrep\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Automata
#
Section "Automata - A package on automata"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.automata

  SetOutPath $INSTDIR\automata
  File pkg\automata\*.*
  SetOutPath $INSTDIR\automata\doc
  File pkg\automata\doc\*.*
  SetOutPath $INSTDIR\automata\gap
  File pkg\automata\gap\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# AutomGrp
#
Section "AutomGrp - Automata groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put file there
  File pkg\README.automgrp

  SetOutPath $INSTDIR\automgrp
  File pkg\automgrp\*.*
  SetOutPath $INSTDIR\automgrp\doc
  File pkg\automgrp\doc\*.*
  SetOutPath $INSTDIR\automgrp\gap
  File pkg\automgrp\gap\*.*
  SetOutPath $INSTDIR\automgrp\htm
  File pkg\automgrp\htm\*.*
  SetOutPath $INSTDIR\automgrp\tst
  File pkg\automgrp\tst\*.*
 
  # Restore output path
  SetOutPath $INSTDIR

SectionEnd 


#######################################################################
#
# AutPGrp
#
Section "AutPGrp - Computing the Automorphism Group of a p-Group"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put file there
  File pkg\README.autpgrp

  SetOutPath $INSTDIR\autpgrp
  File pkg\autpgrp\*.*
  SetOutPath $INSTDIR\autpgrp\doc
  File pkg\autpgrp\doc\*.*
  SetOutPath $INSTDIR\autpgrp\gap
  File pkg\autpgrp\gap\*.*
  SetOutPath $INSTDIR\autpgrp\htm
  File pkg\autpgrp\htm\*.*
 
  # Restore output path
  SetOutPath $INSTDIR

SectionEnd 


#######################################################################
#
# Browse
#
Section "Browse - ncurses interface and browsing applications"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put file there
  File pkg\README.browse

  SetOutPath $INSTDIR\Browse
  File pkg\Browse\*.*
  SetOutPath $INSTDIR\Browse\app
  File pkg\Browse\app\*.*
  SetOutPath $INSTDIR\Browse\bibl
  File pkg\Browse\bibl\*.*
  SetOutPath $INSTDIR\Browse\doc
  File pkg\Browse\doc\*.*
  SetOutPath $INSTDIR\Browse\lib
  File pkg\Browse\lib\*.*
  SetOutPath $INSTDIR\Browse\src
  File pkg\Browse\src\*.*
  SetOutPath $INSTDIR\Browse\tst
  File pkg\Browse\tst\*.*
 
  # Restore output path
  SetOutPath $INSTDIR

SectionEnd 


#######################################################################
#
# Carat
#
Section "Carat - Interface to CARAT, a crystallographic groups package"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.carat

  SetOutPath $INSTDIR\carat
  File pkg\carat\*.*
  SetOutPath $INSTDIR\carat\doc
  File pkg\carat\doc\*.*
  SetOutPath $INSTDIR\carat\gap
  File pkg\carat\gap\*.*
  SetOutPath $INSTDIR\carat\htm
  File pkg\carat\htm\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Circle
#
Section "Circle - Adjoint groups of finite rings"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.circle

  SetOutPath $INSTDIR\circle
  File pkg\circle\*.*
  SetOutPath $INSTDIR\circle\doc
  File pkg\circle\doc\*.*
  SetOutPath $INSTDIR\circle\lib
  File pkg\circle\lib\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Cohomolo 
#
Section "Cohomolo - Cohomology groups of finite groups on finite modules"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.cohomolo

  SetOutPath $INSTDIR\cohomolo
  File pkg\cohomolo\*.*
  SetOutPath $INSTDIR\cohomolo\doc
  File pkg\cohomolo\doc\*.*
  SetOutPath $INSTDIR\cohomolo\gap
  File pkg\cohomolo\gap\*.*
  SetOutPath $INSTDIR\cohomolo\standalone
  File pkg\cohomolo\standalone\*.*
  SetOutPath $INSTDIR\cohomolo\standalone\data.d
  File pkg\cohomolo\standalone\data.d\*.*
  SetOutPath $INSTDIR\cohomolo\standalone\info.d
  File pkg\cohomolo\standalone\info.d\*.*
  SetOutPath $INSTDIR\cohomolo\standalone\progs.d
  File pkg\cohomolo\standalone\progs.d\*.*
  SetOutPath $INSTDIR\cohomolo\standalone\progs.d\findpres
  File pkg\cohomolo\standalone\progs.d\findpres\*.*
  SetOutPath $INSTDIR\cohomolo\testdata
  File pkg\cohomolo\testdata\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Crime 
#
Section "Crime - A GAP Package to Calculate Group Cohomology and Massey Products"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.crime

  SetOutPath $INSTDIR\crime
  File pkg\crime\*.*
  SetOutPath $INSTDIR\crime\doc
  File pkg\crime\doc\*.*
  SetOutPath $INSTDIR\crime\gap
  File pkg\crime\gap\*.*
  SetOutPath $INSTDIR\crime\tst
  File pkg\crime\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Crisp 
#
Section "Crisp - Computing with Radicals, Injectors, Schunck classes and Projectors"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.crisp

  SetOutPath $INSTDIR\crisp
  File pkg\crisp\*.*
  SetOutPath $INSTDIR\crisp\doc
  File pkg\crisp\doc\*.*
  SetOutPath $INSTDIR\crisp\htm
  File pkg\crisp\htm\*.*
  SetOutPath $INSTDIR\crisp\lib
  File pkg\crisp\lib\*.*
  SetOutPath $INSTDIR\crisp\tst
  File pkg\crisp\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Cryst 
#
Section "Cryst - Computing with crystallographic groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.cryst

  SetOutPath $INSTDIR\cryst
  File pkg\cryst\*.*
  SetOutPath $INSTDIR\cryst\doc
  File pkg\cryst\doc\*.*
  SetOutPath $INSTDIR\cryst\gap
  File pkg\cryst\gap\*.*
  SetOutPath $INSTDIR\cryst\grp
  File pkg\cryst\grp\*.*
  SetOutPath $INSTDIR\cryst\htm
  File pkg\cryst\htm\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# CrystCat 
#
Section "CrystCat - The crystallographic groups catalog"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.crystcat

  SetOutPath $INSTDIR\crystcat
  File pkg\crystcat\*.*
  SetOutPath $INSTDIR\crystcat\doc
  File pkg\crystcat\doc\*.*
  SetOutPath $INSTDIR\crystcat\grp
  File pkg\crystcat\grp\*.*
  SetOutPath $INSTDIR\crystcat\htm
  File pkg\crystcat\htm\*.*
  SetOutPath $INSTDIR\crystcat\lib
  File pkg\crystcat\lib\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# CTblLib 
#
Section "CTblLib - The GAP Character Table Library"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.ctbllib

  SetOutPath $INSTDIR\ctbllib
  File pkg\ctbllib\*.*
  SetOutPath $INSTDIR\ctbllib\data
  File pkg\ctbllib\data\*.*
  SetOutPath $INSTDIR\ctbllib\doc
  File pkg\ctbllib\doc\*.*
  SetOutPath $INSTDIR\ctbllib\etc
  File pkg\ctbllib\etc\*.*
  SetOutPath $INSTDIR\ctbllib\gap3
  File pkg\ctbllib\gap3\*.*
  SetOutPath $INSTDIR\ctbllib\gap4
  File pkg\ctbllib\gap4\*.*
  SetOutPath $INSTDIR\ctbllib\htm
  File pkg\ctbllib\htm\*.*
  SetOutPath $INSTDIR\ctbllib\tst
  File pkg\ctbllib\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Cubefree
#
Section "Cubefree - Constructing the Groups of a Given Cubefree Order"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.cubefree

  SetOutPath $INSTDIR\cubefree
  File pkg\cubefree\*.*
  SetOutPath $INSTDIR\cubefree\doc
  File pkg\cubefree\doc\*.*
  SetOutPath $INSTDIR\cubefree\gap
  File pkg\cubefree\gap\*.*
  SetOutPath $INSTDIR\cubefree\htm
  File pkg\cubefree\htm\*.*
  SetOutPath $INSTDIR\cubefree\tst
  File pkg\cubefree\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Design 
#
Section "Design - generating, classifying and studying block designs"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.design

  SetOutPath $INSTDIR\design
  File pkg\design\*.*
  SetOutPath $INSTDIR\design\doc
  File pkg\design\doc\*.*
  SetOutPath $INSTDIR\design\htm
  File pkg\design\htm\*.*
  SetOutPath $INSTDIR\design\lib
  File pkg\design\lib\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# EDIM 
#
Section "EDIM - Elementary Divisors of Integer Matrices"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.edim

  SetOutPath $INSTDIR\edim
  File pkg\edim\*.*
  SetOutPath $INSTDIR\edim\lib
  File pkg\edim\lib\*.*
  SetOutPath $INSTDIR\edim\src
  File pkg\edim\src\*.*
  SetOutPath $INSTDIR\edim\tst
  File pkg\edim\tst\*.*
  SetOutPath $INSTDIR\edim\xmldoc
  File pkg\edim\xmldoc\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Example 
#
Section "Example - A Demo for Package Authors"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.example

  SetOutPath $INSTDIR\example
  File pkg\example\*.*
  SetOutPath $INSTDIR\example\doc
  File pkg\example\doc\*.*
  SetOutPath $INSTDIR\example\gap
  File pkg\example\gap\*.*
  SetOutPath $INSTDIR\example\htm
  File pkg\example\htm\*.*
  SetOutPath $INSTDIR\example\src
  File pkg\example\src\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# FactInt 
#
Section "FactInt - Advanced Methods for Factoring Integers"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.factint

  SetOutPath $INSTDIR\factint
  File pkg\factint\*.*
  SetOutPath $INSTDIR\factint\doc
  File pkg\factint\doc\*.*
  SetOutPath $INSTDIR\factint\gap
  File pkg\factint\gap\*.*
  SetOutPath $INSTDIR\factint\tables
  File pkg\factint\tables\*.*
  SetOutPath $INSTDIR\factint\tables\brent
  File pkg\factint\tables\brent\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# FGA 
#
Section "FGA - Free Group Algorithms"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.fga

  SetOutPath $INSTDIR\fga
  File pkg\fga\*.*
  SetOutPath $INSTDIR\fga\doc
  File pkg\fga\doc\*.*
  SetOutPath $INSTDIR\fga\htm
  File pkg\fga\htm\*.*
  SetOutPath $INSTDIR\fga\lib
  File pkg\fga\lib\*.*
  SetOutPath $INSTDIR\fga\tst
  File pkg\fga\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# FORMAT 
#
Section "FORMAT - Computing with formations of finite solvable groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.format

  SetOutPath $INSTDIR\format-1.1
  File pkg\format-1.1\*.*
  SetOutPath $INSTDIR\format-1.1\doc
  File pkg\format-1.1\doc\*.*
  SetOutPath $INSTDIR\format-1.1\grp
  File pkg\format-1.1\grp\*.*
  SetOutPath $INSTDIR\format-1.1\htm
  File pkg\format-1.1\htm\*.*
  SetOutPath $INSTDIR\format-1.1\lib
  File pkg\format-1.1\lib\*.*
  SetOutPath $INSTDIR\format-1.1\tst
  File pkg\format-1.1\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Forms
#
Section "Forms - Sesquilinear and Quadratic"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.forms

  SetOutPath $INSTDIR\forms
  File pkg\forms\*.*
  SetOutPath $INSTDIR\forms\doc
  File pkg\forms\doc\*.*
  SetOutPath $INSTDIR\forms\examples
  File pkg\forms\examples\*.*
  SetOutPath $INSTDIR\forms\examples\gap
  File pkg\forms\examples\gap\*.*
  SetOutPath $INSTDIR\forms\examples\include
  File pkg\forms\examples\include\*.*
  SetOutPath $INSTDIR\forms\examples\output
  File pkg\forms\examples\output\*.*
  SetOutPath $INSTDIR\forms\lib
  File pkg\forms\lib\*.*
  SetOutPath $INSTDIR\forms\tst
  File pkg\forms\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# FPLSA 
#
Section "FPLSA - Finitely Presented Lie Algebras"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.fplsa

  SetOutPath $INSTDIR\fplsa
  File pkg\fplsa\*.*
  SetOutPath $INSTDIR\fplsa\doc
  File pkg\fplsa\doc\*.*
  SetOutPath $INSTDIR\fplsa\gap
  File pkg\fplsa\gap\*.*
  SetOutPath $INSTDIR\fplsa\htm
  File pkg\fplsa\htm\*.*
  SetOutPath $INSTDIR\fplsa\lib
  File pkg\fplsa\lib\*.*
  SetOutPath $INSTDIR\fplsa\src
  File pkg\fplsa\src\*.*
  SetOutPath $INSTDIR\fplsa\tst
  File pkg\fplsa\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# FR 
#
Section "FR - Computations with functionally recursive groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.fr

  SetOutPath $INSTDIR\fr
  File pkg\fr\*.*
  SetOutPath $INSTDIR\fr\doc
  File pkg\fr\doc\*.*
  SetOutPath $INSTDIR\fr\gap
  File pkg\fr\gap\*.*
  SetOutPath $INSTDIR\fr\java
  File pkg\fr\java\*.*
  SetOutPath $INSTDIR\fr\src
  File pkg\fr\src\*.*
  SetOutPath $INSTDIR\fr\tst
  File pkg\fr\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# fwtree 
#
Section "fwtree - Computing trees related to some pro-p-groups of finite width"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.fwtree

  SetOutPath $INSTDIR\fwtree
  File pkg\fwtree\*.*
  SetOutPath $INSTDIR\fwtree\doc
  File pkg\fwtree\doc\*.*
  SetOutPath $INSTDIR\fwtree\gap
  File pkg\fwtree\gap\*.*
  SetOutPath $INSTDIR\fwtree\htm
  File pkg\fwtree\htm\*.*
  SetOutPath $INSTDIR\fwtree\lib
  File pkg\fwtree\lib\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# GAPDoc
#
Section "GAPDoc - A Meta Package for GAP Documentation"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put file there
  File pkg\README.gapdoc

  SetOutPath $INSTDIR\GAPDoc-1.2
  File pkg\GAPDoc-1.2\*.*
  SetOutPath $INSTDIR\GAPDoc-1.2\3k+1
  File pkg\GAPDoc-1.2\3k+1\*.*
  SetOutPath $INSTDIR\GAPDoc-1.2\doc
  File pkg\GAPDoc-1.2\doc\*.*
  SetOutPath $INSTDIR\GAPDoc-1.2\example
  File pkg\GAPDoc-1.2\example\*.*
  SetOutPath $INSTDIR\GAPDoc-1.2\lib
  File pkg\GAPDoc-1.2\lib\*.*
  SetOutPath $INSTDIR\GAPDoc-1.2\mathml
  File pkg\GAPDoc-1.2\mathml\*.*
 
  # Restore output path
  SetOutPath $INSTDIR

SectionEnd 


#######################################################################
#
# Gpd 
#
Section "Gpd - Groupoids, graphs of groups, and graphs of groupoids"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.gpd

  SetOutPath $INSTDIR\gpd
  File pkg\gpd\*.*
  SetOutPath $INSTDIR\gpd\doc
  File pkg\gpd\doc\*.*
  SetOutPath $INSTDIR\gpd\examples
  File pkg\gpd\examples\*.*
  SetOutPath $INSTDIR\gpd\gap
  File pkg\gpd\gap\*.*
  SetOutPath $INSTDIR\gpd\tst
  File pkg\gpd\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# genss 
#
Section "genss - generic Schreier-Sims"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.genss

  SetOutPath $INSTDIR\genss
  File pkg\genss\*.*
  SetOutPath $INSTDIR\genss\doc
  File pkg\genss\doc\*.*
  SetOutPath $INSTDIR\genss\examples
  File pkg\genss\examples\*.*
  SetOutPath $INSTDIR\genss\gap
  File pkg\genss\gap\*.*
  SetOutPath $INSTDIR\genss\tst
  File pkg\genss\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# GRAPE 
#
Section "GRAPE - Computing with graphs and groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.grape

  SetOutPath $INSTDIR\grape
  File pkg\grape\*.*
  SetOutPath $INSTDIR\grape\doc
  File pkg\grape\doc\*.*
  SetOutPath $INSTDIR\grape\grh
  File pkg\grape\grh\*.*
  SetOutPath $INSTDIR\grape\htm
  File pkg\grape\htm\*.*
  SetOutPath $INSTDIR\grape\lib
  File pkg\grape\lib\*.*
  SetOutPath $INSTDIR\grape\nauty22
  File pkg\grape\nauty22\*.*
  SetOutPath $INSTDIR\grape\prs
  File pkg\grape\prs\*.*
  SetOutPath $INSTDIR\grape\src
  File pkg\grape\src\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# GrpConst 
#
Section "GrpConst - Constructing the Groups of a Given Order"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.grpconst

  SetOutPath $INSTDIR\grpconst
  File pkg\grpconst\*.*
  SetOutPath $INSTDIR\grpconst\doc
  File pkg\grpconst\doc\*.*
  SetOutPath $INSTDIR\grpconst\gap
  File pkg\grpconst\gap\*.*
  SetOutPath $INSTDIR\grpconst\htm
  File pkg\grpconst\htm\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd

#######################################################################
#
# Guarana 
#
Section "Guarana - Applications of Lie methods for computations with infinite polycyclic groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.guarana

  SetOutPath $INSTDIR\guarana
  File pkg\guarana\*.*
  SetOutPath $INSTDIR\guarana\data
  File pkg\guarana\data\*.*
  SetOutPath $INSTDIR\guarana\doc
  File pkg\guarana\doc\*.*
  SetOutPath $INSTDIR\guarana\exams
  File pkg\guarana\exams\*.*
  SetOutPath $INSTDIR\guarana\gap
  File pkg\guarana\gap\*.*
  SetOutPath $INSTDIR\guarana\gap\collec
  File pkg\guarana\gap\collec\*.*
  SetOutPath $INSTDIR\guarana\gap\malcor
  File pkg\guarana\gap\malcor\*.*
  SetOutPath $INSTDIR\guarana\gap\symbol
  File pkg\guarana\gap\symbol\*.*
  SetOutPath $INSTDIR\guarana\htm
  File pkg\guarana\htm\*.*
  SetOutPath $INSTDIR\guarana\magma
  File pkg\guarana\magma\*.*
  SetOutPath $INSTDIR\guarana\magma\exams
  File pkg\guarana\magma\exams\*.*
  SetOutPath $INSTDIR\guarana\tst
  File pkg\guarana\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# GUAVA 
#
Section "GUAVA - a GAP package for computing with error-correcting codes"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.guava

  SetOutPath $INSTDIR\guava3.10
  File pkg\guava3.10\*.*
  SetOutPath $INSTDIR\guava3.10\doc
  File pkg\guava3.10\doc\*.*
  SetOutPath $INSTDIR\guava3.10\guavapage
  File pkg\guava3.10\guavapage\*.*
  SetOutPath $INSTDIR\guava3.10\htm
  File pkg\guava3.10\htm\*.*
  SetOutPath $INSTDIR\guava3.10\lib
  File pkg\guava3.10\lib\*.*
  SetOutPath $INSTDIR\guava3.10\src
  File pkg\guava3.10\src\*.*
  SetOutPath $INSTDIR\guava3.10\src\ctjhai
  File pkg\guava3.10\src\ctjhai\*.*
  SetOutPath $INSTDIR\guava3.10\src\leon
  File pkg\guava3.10\src\leon\*.*
  SetOutPath $INSTDIR\guava3.10\src\leon\autom4te.cache
  File pkg\guava3.10\src\leon\autom4te.cache\*.*
  SetOutPath $INSTDIR\guava3.10\src\leon\doc
  File pkg\guava3.10\src\leon\doc\*.*
  SetOutPath $INSTDIR\guava3.10\src\leon\src
  File pkg\guava3.10\src\leon\src\*.*
  SetOutPath $INSTDIR\guava3.10\tbl
  File pkg\guava3.10\tbl\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# HAP
#
Section "HAP - Homological Algebra Programming"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.HAP

  SetOutPath $INSTDIR\Hap1.8
  File pkg\Hap1.8\*.*
  SetOutPath $INSTDIR\Hap1.8\doc
  File pkg\Hap1.8\doc\*.*
  SetOutPath $INSTDIR\Hap1.8\lib
  File pkg\Hap1.8\lib\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\ArtinCoxeter
  File pkg\Hap1.8\lib\ArtinCoxeter\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\CategoryTheory
  File pkg\Hap1.8\lib\CategoryTheory\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\CatGroups
  File pkg\Hap1.8\lib\CatGroups\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\CompiledGAP
  File pkg\Hap1.8\lib\CompiledGAP\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\FpGmodules
  File pkg\Hap1.8\lib\FpGmodules\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\FreeGmodules
  File pkg\Hap1.8\lib\FreeGmodules\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\Functors
  File pkg\Hap1.8\lib\Functors\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\GraphsOfGroups
  File pkg\Hap1.8\lib\GraphsOfGroups\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\GOuterGroups
  File pkg\Hap1.8\lib\GOuterGroups\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\Homology
  File pkg\Hap1.8\lib\Homology\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\LieAlgebras
  File pkg\Hap1.8\lib\LieAlgebras\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\ModPRings
  File pkg\Hap1.8\lib\ModPRings\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\NonabelianTensor
  File pkg\Hap1.8\lib\NonabelianTensor\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\Objectifications
  File pkg\Hap1.8\lib\Objectifications\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\Perturbations
  File pkg\Hap1.8\lib\Perturbations\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\Polycyclic
  File pkg\Hap1.8\lib\Polycyclic\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\Polymake
  File pkg\Hap1.8\lib\Polymake\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\Resolutions
  File pkg\Hap1.8\lib\Resolutions\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\ResolutionsModP
  File pkg\Hap1.8\lib\ResolutionsModP\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\Rings
  File pkg\Hap1.8\lib\Rings\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\Streams
  File pkg\Hap1.8\lib\Streams\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\TDA
  File pkg\Hap1.8\lib\TDA\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\TitlePage
  File pkg\Hap1.8\lib\TitlePage\*.*
  SetOutPath $INSTDIR\Hap1.8\lib\TopologicalSpaces
  File pkg\Hap1.8\lib\TopologicalSpaces\*.*
  SetOutPath $INSTDIR\Hap1.8\test
  File pkg\Hap1.8\test\*.*
  SetOutPath $INSTDIR\Hap1.8\www
  File pkg\Hap1.8\www\*.*
  SetOutPath $INSTDIR\Hap1.8\www\contact
  File pkg\Hap1.8\www\contact\*.*
  SetOutPath $INSTDIR\Hap1.8\www\download
  File pkg\Hap1.8\www\download\*.*
  SetOutPath $INSTDIR\Hap1.8\www\copyright
  File pkg\Hap1.8\www\copyright\*.*
  SetOutPath $INSTDIR\Hap1.8\www\home
  File pkg\Hap1.8\www\home\*.*
  SetOutPath $INSTDIR\Hap1.8\www\Sidelinks
  File pkg\Hap1.8\www\Sidelinks\*.*
  SetOutPath $INSTDIR\Hap1.8\www\Sidelinks\About
  File pkg\Hap1.8\www\Sidelinks\About\*.*
  SetOutPath $INSTDIR\Hap1.8\www\Sidelinks\About\table
  File pkg\Hap1.8\www\Sidelinks\About\table\*.*
  SetOutPath $INSTDIR\Hap1.8\www\thanks
  File pkg\Hap1.8\www\thanks\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# HAPcryst
#
Section "HAPcryst - A HAP extension for crytallographic groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.hapcryst

  SetOutPath $INSTDIR\HAPcryst
  File pkg\HAPcryst\*.*
  SetOutPath $INSTDIR\HAPcryst\doc
  File pkg\HAPcryst\doc\*.*
  SetOutPath $INSTDIR\HAPcryst\examples
  File pkg\HAPcryst\examples\*.*
  SetOutPath $INSTDIR\HAPcryst\lib
  File pkg\HAPcryst\lib\*.*
  SetOutPath $INSTDIR\HAPcryst\lib\datatypes
  File pkg\HAPcryst\lib\datatypes\*.*
  SetOutPath $INSTDIR\HAPcryst\lib\datatypes\doc
  File pkg\HAPcryst\lib\datatypes\doc\*.*
  SetOutPath $INSTDIR\HAPcryst\tst
  File pkg\HAPcryst\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# "HAPprime",
#
Section "HAPprime - a HAP extension for small prime power groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.happrime

  SetOutPath $INSTDIR\happrime-0.3.2
  File pkg\happrime-0.3.2\*.*
  SetOutPath $INSTDIR\happrime-0.3.2\doc
  File pkg\happrime-0.3.2\doc\*.*
  SetOutPath $INSTDIR\happrime-0.3.2\doc\datatypes
  File pkg\happrime-0.3.2\doc\datatypes\*.*
  SetOutPath $INSTDIR\happrime-0.3.2\doc\userguide
  File pkg\happrime-0.3.2\doc\userguide\*.*
  SetOutPath $INSTDIR\happrime-0.3.2\lib
  File pkg\happrime-0.3.2\lib\*.*
  SetOutPath $INSTDIR\happrime-0.3.2\tst
  File pkg\happrime-0.3.2\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# IdRel
#
Section "IdRel - Identities among relations"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.idrel

  SetOutPath $INSTDIR\idrel
  File pkg\idrel\*.*
  SetOutPath $INSTDIR\idrel\doc
  File pkg\idrel\doc\*.*
  SetOutPath $INSTDIR\idrel\examples
  File pkg\idrel\examples\*.*
  SetOutPath $INSTDIR\idrel\gap
  File pkg\idrel\gap\*.*
  SetOutPath $INSTDIR\idrel\tst
  File pkg\idrel\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# if
#
Section "if - The GAP InterFaces to other Computer Algebra Systems"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.if

  SetOutPath $INSTDIR\if
  File pkg\if\*.*
  SetOutPath $INSTDIR\if\cases
  File pkg\if\cases\*.*
  SetOutPath $INSTDIR\if\doc
  File pkg\if\doc\*.*
  SetOutPath $INSTDIR\if\ext
  File pkg\if\ext\*.*
  SetOutPath $INSTDIR\if\gap
  File pkg\if\gap\*.*
  SetOutPath $INSTDIR\if\tst
  File pkg\if\tst\*.*
  SetOutPath $INSTDIR\if\txt
  File pkg\if\txt\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# IO
#
Section "IO - Bindings for low level C library IO"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.io

  SetOutPath $INSTDIR\io
  File pkg\io\*.*
  SetOutPath $INSTDIR\io\cnf
  File pkg\io\cnf\*.*
  SetOutPath $INSTDIR\io\doc
  File pkg\io\doc\*.*
  SetOutPath $INSTDIR\io\example
  File pkg\io\example\*.*
  SetOutPath $INSTDIR\io\gap
  File pkg\io\gap\*.*
  SetOutPath $INSTDIR\io\src
  File pkg\io\src\*.*
  SetOutPath $INSTDIR\io\tst
  File pkg\io\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd



#######################################################################
#
# IRREDSOL 
#
Section "IRREDSOL - A Library of irreducible solvable linear groups over finite fields"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.irredsol

  SetOutPath $INSTDIR\irredsol
  File pkg\irredsol\*.*
  SetOutPath $INSTDIR\irredsol\data
  File pkg\irredsol\data\*.*
  SetOutPath $INSTDIR\irredsol\doc
  File pkg\irredsol\doc\*.*
  SetOutPath $INSTDIR\irredsol\fp
  File pkg\irredsol\fp\*.*
  SetOutPath $INSTDIR\irredsol\htm
  File pkg\irredsol\htm\*.*
  SetOutPath $INSTDIR\irredsol\lib
  File pkg\irredsol\lib\*.*
  SetOutPath $INSTDIR\irredsol\tst
  File pkg\irredsol\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# ITC 
#
Section "ITC - Interactive Todd-Coxeter"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.itc

  SetOutPath $INSTDIR\itc
  File pkg\itc\*.*
  SetOutPath $INSTDIR\itc\doc
  File pkg\itc\doc\*.*
  SetOutPath $INSTDIR\itc\examples
  File pkg\itc\examples\*.*
  SetOutPath $INSTDIR\itc\gap
  File pkg\itc\gap\*.*
  SetOutPath $INSTDIR\itc\htm
  File pkg\itc\htm\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# kan 
#
Section "kan - including double coset rewriting systems"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.kan

  SetOutPath $INSTDIR\kan
  File pkg\kan\*.*
  SetOutPath $INSTDIR\kan\doc
  File pkg\kan\doc\*.*
  SetOutPath $INSTDIR\kan\examples
  File pkg\kan\examples\*.*
  SetOutPath $INSTDIR\kan\gap
  File pkg\kan\gap\*.*
  SetOutPath $INSTDIR\kan\tst
  File pkg\kan\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# kbmag 
#
Section "kbmag - Knuth-Bendix on Monoids and Automatic Groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.kbmag

  SetOutPath $INSTDIR\kbmag
  File pkg\kbmag\*.*
  SetOutPath $INSTDIR\kbmag\doc
  File pkg\kbmag\doc\*.*
  SetOutPath $INSTDIR\kbmag\gap
  File pkg\kbmag\gap\*.*
  SetOutPath $INSTDIR\kbmag\standalone
  File pkg\kbmag\standalone\*.*
  SetOutPath $INSTDIR\kbmag\standalone\ag_data
  File pkg\kbmag\standalone\ag_data\*.*
  SetOutPath $INSTDIR\kbmag\standalone\ag_data
  File pkg\kbmag\standalone\ag_data\*.*
  SetOutPath $INSTDIR\kbmag\standalone\doc
  File pkg\kbmag\standalone\doc\*.*
  SetOutPath $INSTDIR\kbmag\standalone\fsa_data
  File pkg\kbmag\standalone\fsa_data\*.*
  SetOutPath $INSTDIR\kbmag\standalone\kb_data
  File pkg\kbmag\standalone\kb_data\*.*
  SetOutPath $INSTDIR\kbmag\standalone\lib
  File pkg\kbmag\standalone\lib\*.*
  SetOutPath $INSTDIR\kbmag\standalone\src
  File pkg\kbmag\standalone\src\*.*
  SetOutPath $INSTDIR\kbmag\standalone\subgp_data
  File pkg\kbmag\standalone\subgp_data\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# LAGUNA
#
Section "LAGUNA - Lie Algebras and UNit groups of group Algebras"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put file there
  File pkg\README.laguna

  SetOutPath $INSTDIR\laguna
  File pkg\laguna\*.*
  SetOutPath $INSTDIR\laguna\lib
  File pkg\laguna\lib\*.*
  SetOutPath $INSTDIR\laguna\doc
  File pkg\laguna\doc\*.*
  SetOutPath $INSTDIR\laguna\tst
  File pkg\laguna\tst\*.*
  
  # Restore output path
  SetOutPath $INSTDIR

SectionEnd 


#######################################################################
#
# liealgdb
#
Section "liealgdb - A database of Lie algebras"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put file there
  File pkg\README.liealgdb

  SetOutPath $INSTDIR\liealgdb
  File pkg\liealgdb\*.*
  SetOutPath $INSTDIR\liealgdb\doc
  File pkg\liealgdb\doc\*.*
  SetOutPath $INSTDIR\liealgdb\gap
  File pkg\liealgdb\gap\*.*
  SetOutPath $INSTDIR\liealgdb\gap\nilpotent
  File pkg\liealgdb\gap\nilpotent\*.*
  SetOutPath $INSTDIR\liealgdb\gap\nonsolv
  File pkg\liealgdb\gap\nonsolv\*.*
  SetOutPath $INSTDIR\liealgdb\gap\slac
  File pkg\liealgdb\gap\slac\*.*
  
  # Restore output path
  SetOutPath $INSTDIR

SectionEnd 


#######################################################################
#
# linboxing
#
Section "linboxing - access to LinBox linear algebra functions from GAP"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put file there
  File pkg\README.linboxing

  SetOutPath $INSTDIR\linboxing-0.5.1
  File pkg\linboxing-0.5.1\*.*
  SetOutPath $INSTDIR\linboxing-0.5.1\doc
  File pkg\linboxing-0.5.1\doc\*.*
  SetOutPath $INSTDIR\linboxing-0.5.1\lib
  File pkg\linboxing-0.5.1\lib\*.*
  SetOutPath $INSTDIR\linboxing-0.5.1\m4
  File pkg\linboxing-0.5.1\m4\*.*
  SetOutPath $INSTDIR\linboxing-0.5.1\src
  File pkg\linboxing-0.5.1\src\*.*  
  # Restore output path
  SetOutPath $INSTDIR

SectionEnd 


#######################################################################
#
# loops 
#
Section "loops - Computing with quasigroups and loops in GAP"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.loops

  SetOutPath $INSTDIR\loops
  File pkg\loops\*.*
  SetOutPath $INSTDIR\loops\data
  File pkg\loops\data\*.*
  SetOutPath $INSTDIR\loops\doc
  File pkg\loops\doc\*.*
  SetOutPath $INSTDIR\loops\etc
  File pkg\loops\etc\*.*
  SetOutPath $INSTDIR\loops\gap
  File pkg\loops\gap\*.*
  SetOutPath $INSTDIR\loops\htm
  File pkg\loops\htm\*.*
  SetOutPath $INSTDIR\loops\tst
  File pkg\loops\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# MONOID
#
Section "MONOID - Computing with transformation monoids"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.monoid

  SetOutPath $INSTDIR\MONOID
  File pkg\MONOID\*.*
  SetOutPath $INSTDIR\MONOID\doc
  File pkg\MONOID\doc\*.*
  SetOutPath $INSTDIR\MONOID\gap
  File pkg\MONOID\gap\*.*
  SetOutPath $INSTDIR\MONOID\tst
  File pkg\MONOID\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Nilmat 
#
Section "Nilmat - Computing with nilpotent matrix groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.nilmat

  SetOutPath $INSTDIR\nilmat
  File pkg\nilmat\*.*
  SetOutPath $INSTDIR\nilmat\doc
  File pkg\nilmat\doc\*.*
  SetOutPath $INSTDIR\nilmat\etc
  File pkg\nilmat\etc\*.*
  SetOutPath $INSTDIR\nilmat\gap
  File pkg\nilmat\gap\*.*
  SetOutPath $INSTDIR\nilmat\htm
  File pkg\nilmat\htm\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# nq 
#
Section "nq - Nilpotent Quotients of Finitely Presented Groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.nq

  SetOutPath $INSTDIR\nq-2.2
  File pkg\nq-2.2\*.*
  SetOutPath $INSTDIR\nq-2.2\cnf
  File pkg\nq-2.2\cnf\*.*
  SetOutPath $INSTDIR\nq-2.2\doc
  File pkg\nq-2.2\doc\*.*
  SetOutPath $INSTDIR\nq-2.2\doc\test
  File pkg\nq-2.2\doc\test\*.*
  SetOutPath $INSTDIR\nq-2.2\examples
  File pkg\nq-2.2\examples\*.*
  SetOutPath $INSTDIR\nq-2.2\gap
  File pkg\nq-2.2\gap\*.*
  SetOutPath $INSTDIR\nq-2.2\src
  File pkg\nq-2.2\src\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# NQL
#
Section "NQL - Nilpotent Quotients of L-Presented Groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.nql

  SetOutPath $INSTDIR\nql
  File pkg\nql\*.*
  SetOutPath $INSTDIR\nql\doc
  File pkg\nql\doc\*.*
  SetOutPath $INSTDIR\nql\gap
  File pkg\nql\gap\*.*
  SetOutPath $INSTDIR\nql\gap\misc
  File pkg\nql\gap\misc\*.*
  SetOutPath $INSTDIR\nql\gap\pargap
  File pkg\nql\gap\pargap\*.*
  SetOutPath $INSTDIR\nql\gap\schumu
  File pkg\nql\gap\schumu\*.*
  SetOutPath $INSTDIR\nql\htm
  File pkg\nql\htm\*.*
  SetOutPath $INSTDIR\nql\tst
  File pkg\nql\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# NumericalSgps 
#
Section "NumericalSgps - A package for numerical semigroups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.numericalsgps

  SetOutPath $INSTDIR\numericalsgps
  File pkg\numericalsgps\*.*
  SetOutPath $INSTDIR\numericalsgps\doc
  File pkg\numericalsgps\doc\*.*
  SetOutPath $INSTDIR\numericalsgps\gap
  File pkg\numericalsgps\gap\*.*
  SetOutPath $INSTDIR\numericalsgps\src
  File pkg\numericalsgps\src\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# openmath
#
Section "openmath - OpenMath functionality in GAP"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.openmath

  SetOutPath $INSTDIR\openmath
  File pkg\openmath\*.*
  SetOutPath $INSTDIR\openmath\OMCv1.3c
  File pkg\openmath\OMCv1.3c\*.*
  SetOutPath $INSTDIR\openmath\OMCv1.3c\doc
  File pkg\openmath\OMCv1.3c\doc\*.*
  SetOutPath $INSTDIR\openmath\OMCv1.3c\src
  File pkg\openmath\OMCv1.3c\src\*.*
  SetOutPath $INSTDIR\openmath\cds
  File pkg\openmath\cds\*.*
  SetOutPath $INSTDIR\openmath\doc
  File pkg\openmath\doc\*.*
  SetOutPath $INSTDIR\openmath\gap
  File pkg\openmath\gap\*.*
  SetOutPath $INSTDIR\openmath\hasse
  File pkg\openmath\hasse\*.*
  SetOutPath $INSTDIR\openmath\include
  File pkg\openmath\include\*.*
  SetOutPath $INSTDIR\openmath\private
  File pkg\openmath\private\*.*
  SetOutPath $INSTDIR\openmath\src
  File pkg\openmath\src\*.*
  SetOutPath $INSTDIR\openmath\tst
  File pkg\openmath\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# orb
#
Section "orb - Methods to enumerate Orbits"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.orb

  SetOutPath $INSTDIR\orb
  File pkg\orb\*.*
  SetOutPath $INSTDIR\orb\doc
  File pkg\orb\doc\*.*
  SetOutPath $INSTDIR\orb\examples\bmF2d4370
  File pkg\orb\examples\bmF2d4370\*.*
  SetOutPath $INSTDIR\orb\examples\co1F5d24
  File pkg\orb\examples\co1F5d24\*.*
  SetOutPath $INSTDIR\orb\examples\fi23m7
  File pkg\orb\examples\fi23m7\*.*
  SetOutPath $INSTDIR\orb\examples\m11PF3d24
  File pkg\orb\examples\m11PF3d24\*.*
  SetOutPath $INSTDIR\orb\gap
  File pkg\orb\gap\*.*
  SetOutPath $INSTDIR\orb\src
  File pkg\orb\src\*.*
  SetOutPath $INSTDIR\orb\tst
  File pkg\orb\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# ParGAP 
#
Section "ParGAP - Parallel GAP"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.pargap

  SetOutPath $INSTDIR\pargap
  File pkg\pargap\*.*
  SetOutPath $INSTDIR\pargap\bin
  File pkg\pargap\bin\*.*
  SetOutPath $INSTDIR\pargap\doc
  File pkg\pargap\doc\*.*
  SetOutPath $INSTDIR\pargap\etc
  File pkg\pargap\etc\*.*
  SetOutPath $INSTDIR\pargap\examples
  File pkg\pargap\examples\*.*
  SetOutPath $INSTDIR\pargap\htm
  File pkg\pargap\htm\*.*
  SetOutPath $INSTDIR\pargap\lib
  File pkg\pargap\lib\*.*
  SetOutPath $INSTDIR\pargap\mpinu
  File pkg\pargap\mpinu\*.*
  SetOutPath $INSTDIR\pargap\src
  File pkg\pargap\src\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Polenta 
#
Section "Polenta - Polycyclic presentations for matrix groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.polenta

  SetOutPath $INSTDIR\polenta
  File pkg\polenta\*.*
  SetOutPath $INSTDIR\polenta\doc
  File pkg\polenta\doc\*.*
  SetOutPath $INSTDIR\polenta\exam
  File pkg\polenta\exam\*.*
  SetOutPath $INSTDIR\polenta\htm
  File pkg\polenta\htm\*.*
  SetOutPath $INSTDIR\polenta\lib
  File pkg\polenta\lib\*.*
  SetOutPath $INSTDIR\polenta\tst
  File pkg\polenta\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Polycyclic
#
Section "Polycyclic - Computation with polycyclic groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.polycyclic

  SetOutPath $INSTDIR\polycyclic
  File pkg\polycyclic\*.*
  SetOutPath $INSTDIR\polycyclic\doc
  File pkg\polycyclic\doc\*.*
  SetOutPath $INSTDIR\polycyclic\gap
  File pkg\polycyclic\gap\*.*
  SetOutPath $INSTDIR\polycyclic\gap\action
  File pkg\polycyclic\gap\action\*.*
  SetOutPath $INSTDIR\polycyclic\gap\basic
  File pkg\polycyclic\gap\basic\*.*
  SetOutPath $INSTDIR\polycyclic\gap\cohom
  File pkg\polycyclic\gap\cohom\*.*
  SetOutPath $INSTDIR\polycyclic\gap\cover\const
  File pkg\polycyclic\gap\cover\const\*.*
  SetOutPath $INSTDIR\polycyclic\gap\cover\trees
  File pkg\polycyclic\gap\cover\trees\*.*
  SetOutPath $INSTDIR\polycyclic\etc
  File pkg\polycyclic\etc\*.*
  SetOutPath $INSTDIR\polycyclic\gap\exam
  File pkg\polycyclic\gap\exam\*.*
  SetOutPath $INSTDIR\polycyclic\gap\matgrp
  File pkg\polycyclic\gap\matgrp\*.*
  SetOutPath $INSTDIR\polycyclic\gap\matrep
  File pkg\polycyclic\gap\matrep\*.*
  SetOutPath $INSTDIR\polycyclic\gap\matrix
  File pkg\polycyclic\gap\matrix\*.*
  SetOutPath $INSTDIR\polycyclic\gap\pcpgrp
  File pkg\polycyclic\gap\pcpgrp\*.*
  SetOutPath $INSTDIR\polycyclic\htm
  File pkg\polycyclic\htm\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Polymaking
#
Section "Polymaking - Using polymak(e)inG(AP)"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.polymaking

  SetOutPath $INSTDIR\polymaking
  File pkg\polymaking\*.*
  SetOutPath $INSTDIR\polymaking\doc
  File pkg\polymaking\doc\*.*
  SetOutPath $INSTDIR\polymaking\lib
  File pkg\polymaking\lib\*.*
  SetOutPath $INSTDIR\polymaking\tst
  File pkg\polymaking\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# qaos 
#
Section "qaos - Interfacing the QaoS database from GAP"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.qaos

  SetOutPath $INSTDIR\qaos
  File pkg\qaos\*.*
  SetOutPath $INSTDIR\qaos\.arch-ids
  File pkg\qaos\.arch-ids\*.*
  SetOutPath $INSTDIR\qaos\doc
  File pkg\qaos\doc\*.*
  SetOutPath $INSTDIR\qaos\doc\.arch-ids
  File pkg\qaos\doc\.arch-ids\*.*
  SetOutPath $INSTDIR\qaos\gap
  File pkg\qaos\gap\*.*
  SetOutPath $INSTDIR\qaos\gap\.arch-ids
  File pkg\qaos\gap\.arch-ids\*.*
  SetOutPath $INSTDIR\qaos\tst
  File pkg\qaos\tst\*.*
  SetOutPath $INSTDIR\qaos\tst\.arch-ids
  File pkg\qaos\tst\.arch-ids\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# quagroup 
#
Section "quagroup - a package for doing computations with quantum groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.quagroup

  SetOutPath $INSTDIR\quagroup
  File pkg\quagroup\*.*
  SetOutPath $INSTDIR\quagroup\doc
  File pkg\quagroup\doc\*.*
  SetOutPath $INSTDIR\quagroup\doc\gapdoc
  File pkg\quagroup\doc\gapdoc\*.*
  SetOutPath $INSTDIR\quagroup\gap
  File pkg\quagroup\gap\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# RadiRoot 
#
Section "RadiRoot - Roots of a Polynomial as Radicals"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.radiroot

  SetOutPath $INSTDIR\Radiroot
  File pkg\Radiroot\*.*
  SetOutPath $INSTDIR\Radiroot\doc
  File pkg\Radiroot\doc\*.*
  SetOutPath $INSTDIR\Radiroot\htm
  File pkg\Radiroot\htm\*.*
  SetOutPath $INSTDIR\Radiroot\lib
  File pkg\Radiroot\lib\*.*
  SetOutPath $INSTDIR\Radiroot\tst
  File pkg\Radiroot\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# RCWA 
#
Section "RCWA - Residue Class-Wise Affine Groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.rcwa

  SetOutPath $INSTDIR\rcwa
  File pkg\rcwa\*.*
  SetOutPath $INSTDIR\rcwa\doc
  File pkg\rcwa\doc\*.*
  SetOutPath $INSTDIR\rcwa\doc\test
  File pkg\rcwa\doc\test\*.*
  SetOutPath $INSTDIR\rcwa\examples
  File pkg\rcwa\examples\*.*
  SetOutPath $INSTDIR\rcwa\gap
  File pkg\rcwa\gap\*.*
  SetOutPath $INSTDIR\rcwa\thesis
  File pkg\rcwa\thesis\*.*
  SetOutPath $INSTDIR\rcwa\tst
  File pkg\rcwa\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# RDS 
#
Section "RDS - A package for searching relative difference sets"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.rds

  SetOutPath $INSTDIR\rds
  File pkg\rds\*.*
  SetOutPath $INSTDIR\rds\doc
  File pkg\rds\doc\*.*
  SetOutPath $INSTDIR\rds\htm
  File pkg\rds\htm\*.*
  SetOutPath $INSTDIR\rds\lib
  File pkg\rds\lib\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Repsn 
#
Section "Repsn - constructing representations of finite groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.repsn

  SetOutPath $INSTDIR\repsn
  File pkg\repsn\*.*
  SetOutPath $INSTDIR\repsn\doc
  File pkg\repsn\doc\*.*
  SetOutPath $INSTDIR\repsn\gap
  File pkg\repsn\gap\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# ResClasses 
#
Section "ResClasses - Set-Theoretic Computations with Residue Classes"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.resclasses

  SetOutPath $INSTDIR\resclasses
  File pkg\resclasses\*.*
  SetOutPath $INSTDIR\resclasses\doc
  File pkg\resclasses\doc\*.*
  SetOutPath $INSTDIR\resclasses\doc\test
  File pkg\resclasses\doc\test\*.*
  SetOutPath $INSTDIR\resclasses\gap
  File pkg\resclasses\gap\*.*
  SetOutPath $INSTDIR\resclasses\tst
  File pkg\resclasses\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# SCSCP
#
Section "SCSCP - Symbolic Computation Software Composability Protocol in GAP"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.scscp

  SetOutPath $INSTDIR\scscp
  File pkg\scscp\*.*
  SetOutPath $INSTDIR\scscp\demo
  File pkg\scscp\demo\*.*
  SetOutPath $INSTDIR\scscp\doc
  File pkg\scscp\doc\*.*
  SetOutPath $INSTDIR\scscp\doc\img
  File pkg\scscp\doc\img\*.*
  SetOutPath $INSTDIR\scscp\example
  File pkg\scscp\example\*.*
  SetOutPath $INSTDIR\scscp\lib
  File pkg\scscp\lib\*.*
  SetOutPath $INSTDIR\scscp\par
  File pkg\scscp\par\*.*
  SetOutPath $INSTDIR\scscp\tracing
  File pkg\scscp\tracing\*.*
  SetOutPath $INSTDIR\scscp\tst
  File pkg\scscp\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# SgpViz 
#
Section "Sgpviz - A package for semigroup visualization"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.sgpviz

  SetOutPath $INSTDIR\sgpviz
  File pkg\sgpviz\*.*
  SetOutPath $INSTDIR\sgpviz\doc
  File pkg\sgpviz\doc\*.*
  SetOutPath $INSTDIR\sgpviz\doc\images
  File pkg\sgpviz\doc\images\*.*
  SetOutPath $INSTDIR\sgpviz\gap
  File pkg\sgpviz\gap\*.*
  SetOutPath $INSTDIR\sgpviz\src
  File pkg\sgpviz\src\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# singular 
#
Section "singular - The GAP interface to Singular"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.singular

  SetOutPath $INSTDIR\singular
  File pkg\singular\*.*
  SetOutPath $INSTDIR\singular\contrib
  File pkg\singular\contrib\*.*
  SetOutPath $INSTDIR\singular\doc
  File pkg\singular\doc\*.*
  SetOutPath $INSTDIR\singular\gap
  File pkg\singular\gap\*.*
  SetOutPath $INSTDIR\singular\lib
  File pkg\singular\lib\*.*
  SetOutPath $INSTDIR\singular\tst
  File pkg\singular\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# sonata 
#
Section "sonata - System of nearrings and their applications"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.sonata

  SetOutPath $INSTDIR\sonata
  File pkg\sonata\*.*
  SetOutPath $INSTDIR\sonata\doc
  File pkg\sonata\doc\*.*
  SetOutPath $INSTDIR\sonata\doc\ref
  File pkg\sonata\doc\ref\*.*
  SetOutPath $INSTDIR\sonata\doc\tut
  File pkg\sonata\doc\tut\*.*
  SetOutPath $INSTDIR\sonata\grp
  File pkg\sonata\grp\*.*
  SetOutPath $INSTDIR\sonata\htm\ref
  File pkg\sonata\htm\ref\*.*
  SetOutPath $INSTDIR\sonata\htm\tut
  File pkg\sonata\htm\tut\*.*
  SetOutPath $INSTDIR\sonata\lib
  File pkg\sonata\lib\*.*
  SetOutPath $INSTDIR\sonata\nr
  File pkg\sonata\nr\*.*
  SetOutPath $INSTDIR\sonata\nri
  File pkg\sonata\nri\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Sophus
#
Section "Sophus - Computing in nilpotent Lie algebras"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put file there
  File pkg\README.sophus

  SetOutPath $INSTDIR\sophus
  File pkg\sophus\*.*
  SetOutPath $INSTDIR\sophus\doc
  File pkg\sophus\doc\*.*
  SetOutPath $INSTDIR\sophus\gap
  File pkg\sophus\gap\*.*
  
  # Restore output path
  SetOutPath $INSTDIR

SectionEnd


#######################################################################
#
# toric
#
Section "toric - toric varieties and some combinatorial geometry computations"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put file there
  File pkg\README.toric

  SetOutPath $INSTDIR\toric1.4
  File pkg\toric1.4\*.*
  SetOutPath $INSTDIR\toric1.4\doc
  File pkg\toric1.4\doc\*.*
  SetOutPath $INSTDIR\toric1.4\html
  File pkg\toric1.4\html\*.*
  SetOutPath $INSTDIR\toric1.4\lib
  File pkg\toric1.4\lib\*.*
  
  # Restore output path
  SetOutPath $INSTDIR

SectionEnd


#######################################################################
#
# unipot 
#
Section "unipot - Computing with elements of unipotent subgroups of Chevalley groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.unipot

  SetOutPath $INSTDIR\unipot-1.2
  File pkg\unipot-1.2\*.*
  SetOutPath $INSTDIR\unipot-1.2\doc
  File pkg\unipot-1.2\doc\*.*
  SetOutPath $INSTDIR\unipot-1.2\htm
  File pkg\unipot-1.2\htm\*.*
  SetOutPath $INSTDIR\unipot-1.2\lib
  File pkg\unipot-1.2\lib\*.*
  SetOutPath $INSTDIR\unipot-1.2\tst
  File pkg\unipot-1.2\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# UnitLib
#
Section "UnitLib - Library of normalized unit groups of modular group algebras"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.unitlib

  SetOutPath $INSTDIR\unitlib
  File pkg\unitlib\*.*

  SetOutPath $INSTDIR\unitlib\data
  SetOutPath $INSTDIR\unitlib\data\primeord
  File pkg\unitlib\data\primeord\*.*
  SetOutPath $INSTDIR\unitlib\data\4
  File pkg\unitlib\data\4\*.*
  SetOutPath $INSTDIR\unitlib\data\8
  File pkg\unitlib\data\8\*.*
  SetOutPath $INSTDIR\unitlib\data\9
  File pkg\unitlib\data\9\*.*
  SetOutPath $INSTDIR\unitlib\data\16
  File pkg\unitlib\data\16\*.*
  SetOutPath $INSTDIR\unitlib\data\25
  File pkg\unitlib\data\25\*.*
  SetOutPath $INSTDIR\unitlib\data\27
  File pkg\unitlib\data\27\*.*
  SetOutPath $INSTDIR\unitlib\data\32
  File pkg\unitlib\data\32\*.*
  SetOutPath $INSTDIR\unitlib\data\49
  File pkg\unitlib\data\49\*.*
  SetOutPath $INSTDIR\unitlib\data\64
  File pkg\unitlib\data\64\*.*
  SetOutPath $INSTDIR\unitlib\data\81
  File pkg\unitlib\data\81\*.*
  SetOutPath $INSTDIR\unitlib\data\121
  File pkg\unitlib\data\121\*.*
  SetOutPath $INSTDIR\unitlib\data\125
  File pkg\unitlib\data\125\*.*
  SetOutPath $INSTDIR\unitlib\data\128
  File pkg\unitlib\data\128\*.*
  SetOutPath $INSTDIR\unitlib\data\169
  File pkg\unitlib\data\169\*.*
  SetOutPath $INSTDIR\unitlib\data\243
  File pkg\unitlib\data\243\*.*

  SetOutPath $INSTDIR\unitlib\doc
  File pkg\unitlib\doc\*.*
  SetOutPath $INSTDIR\unitlib\lib
  File pkg\unitlib\lib\*.*
  SetOutPath $INSTDIR\unitlib\tst
  File pkg\unitlib\tst\*.*
  SetOutPath $INSTDIR\unitlib\userdata

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# Wedderga
#
Section "Wedderga - central idempotents and simple components of group algebras"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.wedderga

  SetOutPath $INSTDIR\wedderga
  File pkg\wedderga\*.*
  SetOutPath $INSTDIR\wedderga\doc
  File pkg\wedderga\doc\*.*
  SetOutPath $INSTDIR\wedderga\lib
  File pkg\wedderga\lib\*.*
  SetOutPath $INSTDIR\wedderga\tst
  File pkg\wedderga\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# XGAP 
#
Section "XGAP - a graphical user interface for GAP"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.xgap

  SetOutPath $INSTDIR\xgap
  File pkg\xgap\*.*
  SetOutPath $INSTDIR\xgap\cnf
  File pkg\xgap\cnf\*.*
  SetOutPath $INSTDIR\xgap\doc
  File pkg\xgap\doc\*.*
  SetOutPath $INSTDIR\xgap\examples
  File pkg\xgap\examples\*.*
  SetOutPath $INSTDIR\xgap\htm
  File pkg\xgap\htm\*.*
  SetOutPath $INSTDIR\xgap\lib
  File pkg\xgap\lib\*.*
  SetOutPath $INSTDIR\xgap\src.x11
  File pkg\xgap\src.x11\*.*
  SetOutPath $INSTDIR\xgap\src.x11\bitmaps
  File pkg\xgap\src.x11\bitmaps\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#
# XMod 
#
Section "XMod - Crossed Modules and Cat1-Groups"

  # Set output path to the installation directory.
  SetOutPath $INSTDIR
  # Put readme file there
  File pkg\README.xmod

  SetOutPath $INSTDIR\xmod
  File pkg\xmod\*.*
  SetOutPath $INSTDIR\xmod\doc
  File pkg\xmod\doc\*.*
  SetOutPath $INSTDIR\xmod\examples
  File pkg\xmod\examples\*.*
  SetOutPath $INSTDIR\xmod\gap
  File pkg\xmod\gap\*.*
  SetOutPath $INSTDIR\xmod\tst
  File pkg\xmod\tst\*.*

  # Restore output path
  SetOutPath $INSTDIR

  SectionEnd


#######################################################################
#E
