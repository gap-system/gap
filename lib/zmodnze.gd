#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Konovalov.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the design of the rings $ Z / n Z (epsilon) $, where
##  epsilon is the primitive root of unity of degree m (not depending on n).
##

DeclareCategory( "IsZmodnZepsObj", IsScalar );

DeclareCategoryCollections( "IsZmodnZepsObj" );

DeclareRepresentation( "IsZmodnZepsRep", IsPositionalObjectRep, [ 1 ] );

DeclareGlobalFunction( "ZmodnZepsObj");

DeclareGlobalFunction( "ZmodnZeps");

DeclareAttribute("Cyclotomic", IsZmodnZepsObj);

DeclareAttribute("IsRingOfIntegralCyclotomics", IsRingWithOne);

DeclareGlobalFunction("RingOfIntegralCyclotomics");

DeclareSynonym("RingInt", RingOfIntegralCyclotomics);
