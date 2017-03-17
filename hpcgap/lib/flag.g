#############################################################################
##
#W  flag.g                       GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file deals with flags.
##


#############################################################################
##

#V  FlagsFamily . . . . . . . . . . . . . . . . . . . . . . . family of flags
##
BIND_GLOBAL( "FlagsFamily", NewFamily( "FlagsFamily", IsObject ) );



#############################################################################
##
#V  TYPE_FLAGS  . . . . . . . . . . . . . . . . . . . . . . . . type of flags
##
BIND_GLOBAL( "TYPE_FLAGS", NewType( FlagsFamily,  IsInternalRep ) );


#############################################################################
##

#E  flag.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
