#############################################################################
##
#W  flag.g                       GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file deals with flags.
##
Revision.flag_g :=
    "@(#)$Id$";


#############################################################################
##

#V  FlagsFamily . . . . . . . . . . . . . . . . . . . . . . . family of flags
##
FlagsFamily := NewFamily( "FlagsFamily", IsObject );



#############################################################################
##
#V  TYPE_FLAGS  . . . . . . . . . . . . . . . . . . . . . . . . type of flags
##
TYPE_FLAGS  := NewType( FlagsFamily,  IsInternalRep );


#############################################################################
##

#E  flag.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
