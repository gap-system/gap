#############################################################################
##
#W  macfloat.g                        GAP library                Steve Linton
##                                                                Stefan Kohl
##                                                          Laurent Bartholdi
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file deals with settings for the low-level macfloats 
##
Revision.macfloat_g :=

  "@(#)$Id$";

#############################################################################
DeclareRepresentation("IsIEEE754FloatRep", IsFloat and IsInternalRep and IS_MACFLOAT,[]);

BIND_GLOBAL( "TYPE_MACFLOAT", NewType(FloatsFamily, IsIEEE754FloatRep));

#############################################################################
##
#E
