#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the weak pointer type that might have to be known very
##  early in the bootstrap stage (therefore they are not in wpobj.gi)
##

#############################################################################
##
#V  TYPE_WPOBJ  . . . . . . . . . . . . . . . . . . . . type of all wp object
##
TYPE_WPOBJ := NewType( ListsFamily,
    IsWeakPointerObject and IsInternalRep and IsSmallList and IsMutable );
