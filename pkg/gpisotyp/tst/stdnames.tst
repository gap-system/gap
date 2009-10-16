#############################################################################
##
#W  stdnames.tst         GAP 4 package `gpisotyp'               Thomas Breuer
##
#H  @(#)$Id: stdnames.tst,v 1.2 2002/07/10 15:41:09 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the tests concerning standard names of groups.
##

gap> START_TEST("$Id: stdnames.tst,v 1.2 2002/07/10 15:41:09 gap Exp $");

# Load the package.
gap> RequirePackage( "gpisotyp" );
true

# Read the data files of admissible names of groups and ...,
# with the consistency checks enabled.
gap> GpIsoTypGlobals.SortNames:= false;;
gap> GpIsoTypGlobals.TestNotificationsOfNames:= true;;
gap> RereadGpIsoTyp( "stdnames.dat" );
gap> RereadGpIsoTyp( "mkupname.dat" );
gap> RereadGpIsoTyp( "schurnam.dat" );

# ...
gap> StandardNameOfGroup( "L2(9)" );
"A6"
gap> StandardNameOfGroup( "A37.2" );
"S37"

gap> STOP_TEST( "gpisotyp.tst", 10000000 );


#############################################################################
##
#E

