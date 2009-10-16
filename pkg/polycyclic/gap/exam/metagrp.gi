#############################################################################
##
#W  metagrp.gi             Polycyclic                           Werner Nickel
##

#############################################################################
##
#F  ExampleOfMetabelianPcpGroup   . . . .  a special type of metabelian group
##
##  This function takes the regular matrix representation of two units in the
##  ring of  algebraic integers defined by the  polynomial x(x-a)(x+a)-1.  It
##  forms  the semidirect  product with  the  natural modul  and changes  the
##  cocycle such that the resulting group is non-split.
##
InstallGlobalFunction( ExampleOfMetabelianPcpGroup, function( a, k )
    local   i,
            x,    y,    coeffs,    pol,
            M1,   M2, 
            ext,  ftl;

    if not (IsInt(a) and IsInt(k)) or a < 2 then
        return Error( "arguments should be integers > 1" );
    fi;

    ##  k should be in the range [0..a-1]
    k := k mod a;

    ##
    ##  The ring of algebraic integers defined by the following
    ##  polynomial has the obvious units x, x-a  and x+a.
    ##
    x := Indeterminate( Rationals, "x" : new );
    pol := x * (x-a) * (x+a) - 1;

    ##
    ##  Now we construct the regular matrix representation of x and x+a on
    ##  the algebraic number field with respect to the basis 1,x,x^2.
    ##
    M1 := NullMat( Degree(pol), Degree(pol) );
    for i in [0..Degree(pol)-1] do
        y := QuotientRemainder( x^i * x, pol )[2];
        coeffs := CoefficientsOfUnivariatePolynomial( y );
        M1[i+1]{[1..Length(coeffs)]} := coeffs;
    od;
    M2 := NullMat( Degree(pol), Degree(pol) );
    for i in [0..Degree(pol)-1] do
        y := QuotientRemainder( x^i * (x+a), pol )[2];
        coeffs := CoefficientsOfUnivariatePolynomial( y );
        M2[i+1]{[1..Length(coeffs)]} := coeffs;
    od;

    ##
    ##  a bit clumsy to construct the group first and then recover the
    ##  collector.  There should be a function that constructs the
    ##  collector. 
    ##
    ##  one could also use CRRecordByMats( ) and then ExtensionCR()
    ##  to construct the non-split extension directly.
    ##
    ext := SplitExtensionPcpGroup( AbelianPcpGroup( 2, [] ), [ M1, M2 ] );
    ftl := Collector( One( ext ) );

    ##  The commutator of the two top generators is made non-trivial. 
    SetConjugate( ftl, 2, 1, [2,1,5,k] );

    UpdatePolycyclicCollector( ftl );
    return PcpGroupByCollector( ftl );
end );

