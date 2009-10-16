#############################################################################
##
#W   factors.gd           Alnuth - Kant interface             Andreas Distler
##


#############################################################################
##
#F  FactorsPolynomialKant, function( <H>, <poly> )
##
##  Factorizes the polynomial <poly> over the field <H> with KANT
##
DeclareGlobalFunction( "FactorsPolynomialKant" );
DeclareGlobalFunction( "FactorsPolynomialAlgExt" );

DeclareAttribute( "IrrFacsAlgExtPol", IsUnivariatePolynomial, "mutable" );

DeclareGlobalFunction( "StoreFactorsAlgExtPol" );


#############################################################################
##
#E
