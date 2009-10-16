#############################################################################
####
##
#W  Manipulations.gd          RADIROOT package                Andreas Distler
##
##  Declaration file for the functions that do various manipulations
##  to special elements of a splitting field and to the permutations
##  in its Galois-group   
##
#H  $Id: Manipulations.gd,v 1.2 2006/10/30 13:51:30 gap Exp $
##
#Y  2006
##

DeclareAttribute( "GaloisGroupOnRoots", IsUnivariatePolynomial );
DeclareGlobalFunction( "RR_DegreeConclusion" );
DeclareGlobalFunction( "RR_PrimElImg" );
DeclareGlobalFunction( "RR_Produkt" );
DeclareGlobalFunction( "RR_Resolvent" );
DeclareGlobalFunction( "RR_CyclicElements" );
DeclareGlobalFunction( "RR_IsInGalGrp" );
DeclareGlobalFunction( "RR_ConstructGaloisGroup" );
DeclareGlobalFunction( "RR_FindGaloisGroup" );
DeclareGlobalFunction( "RR_Potfree" );
DeclareGlobalFunction( "RR_CompositionSeries" );


#############################################################################
##
#E

