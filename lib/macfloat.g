#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton, Stefan Kohl, Laurent Bartholdi.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file deals with settings for the low-level macfloats
##

#############################################################################
DeclareRepresentation("IsIEEE754FloatRep", IsRealFloat and IsInternalRep
        #and IS_MACFLOAT
        ,[]);

BIND_GLOBAL("IEEE754FloatsFamily", NewFamily("IEEE754FloatsFamily", IsIEEE754FloatRep));

BIND_GLOBAL( "TYPE_MACFLOAT", NewType(IEEE754FloatsFamily, IsIEEE754FloatRep));
