#############################################################################
##
#W  rationals.gi    Alnuth - ALgebraic NUmber THeory        Andreas Distler
##

#############################################################################
##
#M IntegerPrimitiveElement( Rationals )
##
InstallMethod( IntegerPrimitiveElement, "for the rationals", true,
[IsRationals], 0, One );

#############################################################################
##
#M EquationOrderBasis( Rationals )
#M MaximalOrderBasis( Rationals )
##
InstallMethod( EquationOrderBasis, "for the rationals", true,
[IsRationals], 15, CanonicalBasis );

InstallMethod( MaximalOrderBasis, "for the rationals", true,
[IsRationals], 15, CanonicalBasis );


