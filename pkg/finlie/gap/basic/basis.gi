#############################################################################
##
#F basis.gi  .... bases of Lie algebras
##
## Subalgebras of Lie algebras can be represented by a 'CBS'. That is a
## basis in upper triangular form with respect to the parent Lie algebra.
## All elements in a CBS are normed.
##

#############################################################################
##
#M  Depth and Length
##
InstallMethod( DepthLVector, true, [ IsObject], 0,
    x -> PositionNonZero( ExtRepOfObj(x) ) );

InstallMethod( LengthLVector, true, [ IsObject], 0,
    x -> Length( ExtRepOfObj(x) ) );

#############################################################################
##
#M  AddToBasis( <base>, <vec> )
##
AddToBasis := function( base, vec )
    local d;
    while true do
       d := DepthLVector( vec );
       if d > LengthLVector(vec) then return false; fi;
       if IsBool(base[d]) then
           base[d] := vec/vec![1][d];
           return base[d];
       else
           vec := vec - vec![1][d]*base[d];
       fi;
    od;
end;

#############################################################################
##
#M CBSByGens( <gens> )
##
CBSByGens := function( gens )
    local n, b, news, acts, tmps, g, h, k;

    if Length(gens) = 0 then return gens; fi;
    n := LengthLVector(gens[1]);
    b := List( [1..n], x -> true );
    for g in gens do AddToBasis(b,g); od;

    news := Filtered( b, x -> not IsBool(x));
    acts := ShallowCopy(news);
    while Length(news) > 0 do
        tmps := [];
        for g in acts do
            for h in news do
                k := AddToBasis( b, h*g );
                if not IsBool(k) then Add( tmps, k ); fi;
            od;
        od;
        news := tmps;
    od;

    return Filtered( b, x -> not IsBool(x) );
end;

#############################################################################
##
#M CBSByBasis( <basis> )
##
CBSByBasis := function( basis )
    local b, g;
    b := List( [1..LengthLVector(basis[1])], x -> true );
    for g in basis do AddToBasis(b,g); od;
    return Filtered( b, x -> not IsBool(x) );
end;

#############################################################################
##
#M CCSByCBS( <cbs> )
##
CCSByCBS := function( cbs )
    local i, d, j;
    for i in [1..Length(cbs)] do
        d := DepthLVector(cbs[i]);
        for j in [1..i-1] do
            cbs[j] := cbs[j] - cbs[j]![1][d]*cbs[i];
        od;
    od;
    return cbs;
end;

#############################################################################
##
#M CBS( <L> )
##
InstallMethod( CBS, true, [ IsLieAlgebra], 0,
function( L )
    if HasGeneratorsOfLeftOperatorAdditiveGroup(L) then 
        return CBSByBasis(GeneratorsOfLeftOperatorAdditiveGroup(L));
    else
        return CBSByGens(GeneratorsOfAlgebra(L));
    fi;
end );

#############################################################################
##
#F ComplementBasis( <A>, <B> )
##
ComplementBasis := function( A, B )
    return Filtered( A, x -> not DepthLVector(x) in List(B, DepthLVector) );
end;

#############################################################################
##
#F CommutatorBasis( <U>, <H> )
##
CommutatorBasis := function( U, H )
    local BU, BH, B, u, h;

    # get gens
    if IsLieAlgebra(U) then BU := Basis(U); else BU := U; fi;
    if IsLieAlgebra(H) then BH := Basis(H); else BH := H; fi;
    if Length(BU) = 0 or Length(BH) = 0 then return []; fi;

    # set up
    B := [];
    for u in BU do for h in BH do Add( B, u*h ); od; od;

    return CBSByGens(B);
end;

#############################################################################
##
#F FittingBasis( <L> )
##
FittingBasis := function( L )
    return CBS( LieNilRadical(L) );
end;


