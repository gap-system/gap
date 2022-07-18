#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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
