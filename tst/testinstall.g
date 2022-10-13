#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file runs all tests from the directory 'tst/testinstall' of the
##  GAP distribution. It is recommended to read it after GAP installation.
##
##  The documentation states the following:
##
##  <#GAPDoc Label="[1]{testinstall.g}">
##  If you want to run a quick test of your &GAP; installation 
##  (though this is not required), you can read in a test script 
##  that exercises some &GAP;'s capabilities.
##  <P/>
##  <Log><![CDATA[
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testinstall.g" ) );
##  ]]></Log>
##  <P/>
##  <#/GAPDoc>
##

dirs := [
  DirectoriesLibrary( "tst/testinstall" ),
];
TestDirectory( dirs, rec(exitGAP := true) );

  
# Should never get here
ForceQuitGap(1);
