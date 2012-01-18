#############################################################################
##
#W  factors.gd      Alnuth - ALgebraic NUmber THeory        Andreas Distler
##

#############################################################################
##
#F  FactorsPolynomialPari, function( <poly> )
##
##  Factorizes the polynomial <poly> defined over an algebraic extension of
##  the rationals using PARI/GP
##
##  As a method of 'Factors' ? AD
##
DeclareGlobalFunction("FactorsPolynomialPari");

##  ensure backwards compatibility with formerly documented functionality
DeclareSynonym("FactorsPolynomialKant", FactorsPolynomialPari);

#############################################################################
##
#F  FactorsPolynomialAlgExt, function( <H>, <poly> )
##
##  Factorizes the rational polynomial <poly> over the field <H>, a proper
##  algebraic extension of the rationals, using PARI/GP
##
DeclareGlobalFunction( "FactorsPolynomialAlgExt" );

#############################################################################
##
#M  IrrFacsAlgExtPol(<f>) . . . . . lists of irreducible factors of rational 
##                  polynomial over algebraic extensions, initialize default
##
DeclareAttribute( "IrrFacsAlgExtPol", IsUnivariatePolynomial, "mutable" );

#############################################################################
##
#F  StoreFactorsAlgExtPol( <pring>, <upol>, <factlist> ) . store factors list
##
DeclareGlobalFunction( "StoreFactorsAlgExtPol" );


#############################################################################
##
#E
