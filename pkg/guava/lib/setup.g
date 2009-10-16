#############################################################################
##
#A  setup.g                 GUAVA library                       Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file sets some startup variables
##
#H  @(#)$Id: setup.g,v 1.7 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/setup_g") :=
    "@(#)$Id: setup.g,v 1.7 2004/12/20 21:26:06 gap Exp $";

if not IsBound( InfoCoveringRadius ) then InfoCoveringRadius := Print; fi;
if not IsBound( InfoMinimumDistance ) then InfoMinimumDistance := Ignore; fi;
if not IsBound( CRMemSize ) then CRMemSize := 2^15; fi;

#############################################################################
##
#V  GUAVA_TEMP_VAR . . . . . . . . variable for interfacing external programs
##
GUAVA_TEMP_VAR := 0;

#############################################################################
##
#V  GUAVA_BOUNDS_TABLE . . . . . . . . .  contains a list of tables of bounds
##
GUAVA_BOUNDS_TABLE := [ [], [] ];

#############################################################################
##
#V  GUAVA_REF_LIST  . . . contains a record of references for bounds on codes
##
GUAVA_REF_LIST := rec();
