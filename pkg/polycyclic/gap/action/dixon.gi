#############################################################################
##
#W  dixon.gi                                                     Bettina Eick
##
##  Determine Dixon's Bound for torsion free semisimple matrix groups.
##

#############################################################################
##
#F PadicValue( rat, p )
##
PadicValue := function( rat, p )
    local a1, a2;
    a1 := AbsInt( NumeratorRat(rat) );
    a2 := DenominatorRat(rat);
    a1 := Length( Filtered( FactorsInt(a1), x -> x = p ) );
    a2 := Length( Filtered( FactorsInt(a2), x -> x = p ) );
    return a1 - a2;
end;

#############################################################################
##
#F LogAbsValueBound( rat )
##
LogAbsValueBound := function( rat )
    local a1, a2, a;
    a1 := LogInt( AbsInt( NumeratorRat(rat) ), 2 );
    a2 := LogInt( DenominatorRat(rat), 2 );
    a  := Maximum( AbsInt( a1 - a2 + 1 ), AbsInt( a1 - a2 - 1) );
    return QuoInt( a * 3, 4 );
end;

#############################################################################
##
#F ConsideredPrimes( rats )
##
ConsideredPrimes := function( rats )
    local pr, r, a1, a2, tmp;
    pr := [];
    for r in rats do
        a1 := AbsInt( NumeratorRat(r) );
        a2 := DenominatorRat(r);
        if a1 <> 1 then 
            tmp := FactorsInt( a1: RhoTrials := 1000000 );
            pr := Union( pr, tmp );
        fi;
        if a2 <> 1 then 
            tmp := FactorsInt( a2: RhoTrials := 1000000 );
            pr := Union( pr, tmp );
        fi;
    od;
    return pr;
end;

#############################################################################
##
#F CoefficientsByBase( base, vec )
##
CoefficientsByBase := function( base, vec )
    local sol;
    sol := MemberBySemiEchelonBase( vec, base.vectors );
    if IsBool( sol ) then return fail; fi;
    return sol * base.coeffs;
end;

#############################################################################
##
#F FullDixonBound( gens, prim )
##
FullDixonBound := function( gens, prim )
    local c, f, j, n, d, minp, sub, max, cof, deg, base, cofs, dofs, 
          g, pr, t1, p, s, i, a, b, t2, t;

    # set up
    c := prim.elem;
    f := prim.poly;
    n := Length( gens );
    d := Degree(f);
    cof := CoefficientsOfUnivariatePolynomial( f );
    if cof[1] <> 1 or cof[d+1] <> 1 then return fail; fi; 

    # get prim-basis
    # Print("compute prim-base \n");
    base := List([0..d-1], x -> Flat(c^x));
    base := SemiEchelonMatTransformation( base );

    # get coeffs of gens in prim-base
    Print("compute coefficients \n");
    cofs := [];
    dofs := [];
    for g in gens do
        Add( cofs, CoefficientsByBase( base, Flat( g ) ) );
        Add( dofs, CoefficientsByBase( base, Flat( g^-1 ) ) );
    od;

    Print("compute relevant primes \n");
    pr := ConsideredPrimes( Flat( Concatenation(  cofs, dofs ) ) );

    # first consider p-adic case 
    Print("p-adic valuations \n");
    t1 := 0;
    for p in pr do
        s := 0;
        for i in [1..n] do
            a := AbsInt( Minimum( List( cofs[i], x -> PadicValue(x,p) ) ) );
            b := AbsInt( Minimum( List( dofs[i], x -> PadicValue(x,p) ) ) );
            s := s + Maximum( a, b );
        od;
        t1 := Maximum( t1, s );
    od;
    t1 := d * t1;
    Print("non-archimedian: ", t1,"\n");

    # then the log-value
    Print("logarithmic valuations \n");
    t := Maximum( List( cof, x -> LogAbsValueBound( 1+AbsInt(x) ) ) );
    t2 := 0;
    for i in [1..n] do
        if gens[i] = c then
            t2 := t2 + t;
        else
            a := LogAbsValueBound( Sum( AbsInt( cofs[i] ) ) );
            b := LogAbsValueBound( Sum( AbsInt( dofs[i] ) ) );
            t2 := t2 + (d-1) * t + Maximum( a, b );
        fi;
    od;
    t2 := QuoInt( 3 * 7 * d^2 * t2, 2 * LogInt(d,2) );
    Print("archimedian: ", t2,"\n");
  
    t := Maximum( t1, t2 );
    return QuoInt( t^n + 1, t );
end;

#############################################################################
##
#F LogDixonBound( gens, prim )
##
LogDixonBound := function( gens, prim )
    local c, f, d, base, cofs, dofs, g, t, s, i, a, b;

    # set up
    c := prim.elem;
    f := CoefficientsOfUnivariatePolynomial( prim.poly );
    d := Length( f ) - 1;
    if f[1] <> 1 or f[d+1] <> 1 then return fail; fi;

    # get prim-basis
    # Print("compute prim-base \n");
    base := List([0..d-1], x -> Flat(c^x));
    base := SemiEchelonMatTransformation( base );

    # get coeffs of gens in prim-base
    # Print("compute coefficients \n");
    cofs := [];
    dofs := [];
    for g in gens do
        Add( cofs, CoefficientsByBase( base, Flat( g ) ) ); 
        Add( dofs, CoefficientsByBase( base, Flat( g^-1 ) ) );
    od;

    # get log-value
    # Print("logarithmic valuation \n");
    t := Maximum( List( f, x -> LogAbsValueBound( 1+AbsInt(x) ) ) );
    s := 0;
    for i in [1..Length(gens)] do
        if gens[i] = c then
            s := s + t;
        else
            a := LogAbsValueBound( Sum( AbsInt( cofs[i] ) ) );
            b := LogAbsValueBound( Sum( AbsInt( dofs[i] ) ) );
            s := s + (d-1) * t + Maximum( a, b );
        fi;
    od;

    # now determine final value
    t := 7 * d^2 * s / QuoInt( 2 * LogInt(d,2), 3 );
    return QuoInt( t^Length(gens) + 1, t );
end;
