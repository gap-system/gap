#############################################################################
##
#W  polfield.gi     Alnuth - ALgebraic NUmber THeory           Bettina Eick
#W                                                           Bjoern Assmann
##

#############################################################################
##
#F FieldByPolynomial( f )
##
InstallGlobalFunction( FieldByPolynomialNC, function( f )
    return AlgebraicExtension( Rationals, f );
end );

InstallGlobalFunction( FieldByPolynomial, function( f )
    if DegreeOfUnivariateLaurentPolynomial(f) <= 0 then 
        Print("polynomial must have degree at least 1\n");
        return fail;
    fi;
    if not IsIrreducible( f ) then 
        Print("polynomial must be irreducible\n");
        return fail;
    fi;
    if not ForAll( CoefficientsOfUnivariatePolynomial( f ), IsRat ) then
        Print("polynomial must be defined over Q \n");
        return fail; 
    fi;
    return FieldByPolynomialNC(f);
end );

#############################################################################
##
#M IntegerPrimitiveElement( F )
##
InstallMethod( IntegerPrimitiveElement, "for algebraic extension", true,
[IsNumberField and IsAlgebraicExtension], 0, 
function( F )
    local coeff;

    coeff := CoefficientsOfUnivariatePolynomial( DefiningPolynomial( F ));

    # AD improvement possible, e.g. x^5 - 1/32  
    return Lcm( List( coeff, DenominatorRat ) ) * PrimitiveElement( F );    
end );

#############################################################################
##
#M IntegerDefiningPolynomial( F )
##
InstallMethod( IntegerDefiningPolynomial, "for algebraic extension", true,
[IsNumberField and IsAlgebraicExtension], 0, 
function( F )
    local f, c, k, n;
    c := CoefficientsOfUnivariatePolynomial(DefiningPolynomial(F));
    k := ExtRepOfObj( IntegerPrimitiveElement(F)/PrimitiveElement(F) )[1];
    n := Degree( DefiningPolynomial(F) ); 
    c := List( [0..n], i -> c[i+1] * k^(n-i) );
    return UnivariatePolynomial( Rationals, c );
end );





