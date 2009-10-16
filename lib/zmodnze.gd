#############################################################################
##
#W  zmodnze.gd                   GAP library              Alexander Konovalov
##
#H  @(#)$Id: zmodnze.gd,v 1.3 2004/07/09 21:10:14 alexk Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the design of the rings $ Z / n Z (epsilon) $, where 
##  epsilon is the primitive root of unity of degree m (not depending on n).
##
Revision.zmodnze_gd :=
    "@(#)$Id: zmodnze.gd,v 1.3 2004/07/09 21:10:14 alexk Exp $";

DeclareCategory( "IsZmodnZepsObj", IsScalar );

DeclareCategoryCollections( "IsZmodnZepsObj" );

DeclareRepresentation( "IsZmodnZepsRep", IsPositionalObjectRep, [ 1 ] );

DeclareGlobalFunction( "ZmodnZepsObj");

DeclareGlobalFunction( "ZmodnZeps");

DeclareAttribute("Cyclotomic", IsZmodnZepsObj);

DeclareAttribute("IsRingOfIntegralCyclotomics", IsRingWithOne);

DeclareGlobalFunction("RingOfIntegralCyclotomics");

DeclareSynonym("RingInt", RingOfIntegralCyclotomics);