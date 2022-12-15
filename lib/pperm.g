#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

DeclareCategoryKernel("IsPartialPerm", IsMultiplicativeElementWithInverse
and IsMultiplicativeElementWithZero and IsAssociativeElement, IS_PPERM);

DeclareCategoryCollections( "IsPartialPerm" );
DeclareCategoryCollections( "IsPartialPermCollection" );

BIND_GLOBAL("PartialPermFamily", NewFamily("PartialPermFamily",
 IsPartialPerm, CanEasilySortElements, CanEasilySortElements));

DeclareRepresentation( "IsPPerm2Rep", IsInternalRep );
DeclareRepresentation( "IsPPerm4Rep", IsInternalRep );

BIND_GLOBAL("TYPE_PPERM2", NewType(PartialPermFamily,
 IsPartialPerm and IsPPerm2Rep));

BIND_GLOBAL("TYPE_PPERM4", NewType(PartialPermFamily,
 IsPartialPerm and IsPPerm4Rep));


