#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file runs the tst/teststandard/bugfix.tst test from the
##  'tst/teststandard' directory of the GAP distribution. To run it, use this:
##
##  gap> Read( Filename( DirectoriesLibrary( "tst" ), "testbugfix.g" ) );
##

Print( "You should start GAP4 using `gap -A -x 80 -r -m 100m -o 1g -K 2g'.\n\n" );

TestDirectory( [ DirectoriesLibrary( "tst/testbugfix") ] ,
               rec(exitGAP := true, testOptions := rec( width := 80 ) ) );

# Should never get here
FORCE_QUIT_GAP(1);
