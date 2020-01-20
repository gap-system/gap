#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file exercises 'tst/testextra' tests, which are very slow. 
##
##  To run it, use this command:
##
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testextra.g" ) );
##

dirs := [
  DirectoriesLibrary( "tst/testextra" )
];
TestDirectory( dirs, rec(exitGAP := true) );
  
# Should never get here
ForceQuitGap(1);
