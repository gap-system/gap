#############################################################################
##
#W  grppcfp.gd                  GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.grppcfp_gd :=
    "@(#)$Id$"; 

#############################################################################
##
#F  PcGroupFpGroup( <G> )
##
##  creates a PcGroup <P> from an FpGroup (see chapter "Finitely Presented
##  Groups") <G> whose presentation is polycyclic. The resulting group <P>
##  has generators corresponding to the generators of <G>. They are printed
##  in the same way as generators of <G>, but they lie in a different
##  family.
##
#T  should this become a method?
DeclareGlobalFunction( "PcGroupFpGroup" );

#############################################################################
##
#F  SmithNormalFormSQ( mat ) 
##
DeclareGlobalFunction( "SmithNormalFormSQ" );

#############################################################################
##
#F  InitEpimorphismSQ( F )
##
DeclareGlobalFunction( "InitEpimorphismSQ" );

#############################################################################
##
#F  LiftEpimorphismSQ( epi, M, c )
##
DeclareGlobalFunction( "LiftEpimorphismSQ" );

#############################################################################
##
#F  BlowUpCocycleSQ( v, K, F )
##
DeclareGlobalFunction( "BlowUpCocycleSQ" );

#############################################################################
##
#F  TryModuleSQ( epi, M )
##
DeclareGlobalFunction( "TryModuleSQ" );

#############################################################################
##
#F  TryLayerSQ( epi, layer )
##
DeclareGlobalFunction( "TryLayerSQ" );

#############################################################################
##
#F  SQ( <F>, <...> ) / SolvableQuotient( <F>, <...> )
##  should this become a method?
##
DeclareGlobalFunction( "SolvableQuotient" );
DeclareGlobalFunction( "SQ" );
