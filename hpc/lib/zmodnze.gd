#############################################################################
##
#W  zmodnze.gd                   GAP library              Alexander Konovalov
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
