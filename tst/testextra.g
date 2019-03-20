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

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 1g -K 2g'.\n\n" );

dirs := [
  DirectoriesLibrary( "tst/testextra" )
];
TestDirectory( dirs, rec(exitGAP := true) );
  
# Should never get here
FORCE_QUIT_GAP(1);
