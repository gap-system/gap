#############################################################################
####
##
#W  Radicals.gd               RADIROOT package                Andreas Distler
##
##  Declaration file for main function of the RADIROOT package
##
#H  @(#)$Id: Radicals.gd,v 1.2 2006/10/30 13:51:30 gap Exp $
##
#Y  2006
##


DeclareGlobalFunction( "RR_SplittField" );
DeclareGlobalFunction( "RR_SimplifiedPolynomial" );
DeclareGlobalFunction( "RR_RootOfUnity" );
DeclareGlobalFunction( "RR_Roots" );
DeclareGlobalFunction( "RootsOfPolynomialAsRadicals" );
DeclareGlobalFunction( "RootsOfPolynomialAsRadicalsNC" );
DeclareAttribute( "RootsAsMatrices", IsUnivariatePolynomial );
DeclareProperty( "IsSolvablePolynomial", IsUnivariatePolynomial );
DeclareProperty( "IsSeparablePolynomial", IsUnivariatePolynomial );


#############################################################################
##
#E









