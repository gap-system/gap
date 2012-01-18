#############################################################################
##
#W  rowbases.gi                                                  Bettina Eick
##
##  Methods to compute with rational vector spaces.
##

#############################################################################
##
#F  VectorspaceBasis( gens )
##
VectorspaceBasis := function( gens )
    local j;
    TriangulizeMat( gens );
    if Length(gens) = 0 then return gens; fi;
    j := Position( gens, 0*gens[1] );
    if not IsBool( j ) then gens := gens{[1..j-1]}; fi;
    return gens;
end;

#############################################################################
##
#F  SemiEchelonFactorBase( V, U )
##
SemiEchelonFactorBase := function( V, U )
    local L1, L2;
    L1 := List( V, PositionNonZero );
    L2 := List( U, PositionNonZero );
    return V{Filtered( [1..Length(V)], i -> not L1[i] in L2 )};
end;

#############################################################################
##
#F  MemberBySemiEchelonBase( v, U )
##
MemberBySemiEchelonBase := function( v, U )
    local d, c, z, l, j;
    v := ShallowCopy(v);
    d := List( U, PositionNonZero );
    c := List( d, x -> 0 );
    z := 0 * v;
    while v <> z do
        l := PositionNonZero(v); 
        j := Position( d, l );
        if IsBool( j ) then return false; fi;
        c[j] := v[l];
        if U[j][l] <> 1 then c[j] := c[j]/U[j][l]; fi;
        AddRowVector( v, U[j], -c[j] );
    od;
    return c;
end;

#############################################################################
##
#F  NaturalHomomorphismBySemiEchelonBases ( V, U )
##
InstallGlobalFunction( NaturalHomomorphismBySemiEchelonBases, function( V, U )
    local F, A;
    F := SemiEchelonFactorBase( V, U );
    A := Concatenation( F, U );
    return rec( source := A, kernel := U, factor := F );
end );

#############################################################################
##
#F  CoefficientsByNHSEB( v, hom )
##
CoefficientsByNHSEB := function( v, hom )
    local df, dk, cf, ck, z, l, j;
    v  := ShallowCopy(v);
    df := List( hom.factor, PositionNonZero );
    dk := List( hom.kernel, PositionNonZero );
    cf := List( df, x -> 0 );
    ck := List( dk, x -> 0 );
    z := 0 * v;
    while v <> z do
        l := PositionNonZero(v);
        j := Position( df, l );
        if not IsBool( j ) then
            cf[j] := v[l];
            if hom.factor[j][l] <> 1 then cf[j] := cf[j]/hom.factor[j][l]; fi;
            AddRowVector( v, hom.factor[j], -cf[j] );
        else
            j := Position( dk, l );
            ck[j] := v[l];
            if hom.kernel[j][l] <> 1 then ck[j] := ck[j]/hom.kernel[j][l]; fi;
            AddRowVector( v, hom.kernel[j], -ck[j] );
        fi;
    od;
    return rec( coeff1 := cf, coeff2 := ck );
end;

#############################################################################
##
#F  ProjectionByNHSEB( vec, hom )
##
ProjectionByNHSEB := function( vec, hom )
    return CoefficientsByNHSEB( vec, hom ).coeff2;
end;

#############################################################################
##
#F  ImageByNHSEB( vec, hom )
##
ImageByNHSEB := function( vec, hom )
    return CoefficientsByNHSEB( vec, hom ).coeff1;
end;

#############################################################################
##
#F  PreimagesRepresentativeByNHSEB( vec, hom )
##
PreimagesRepresentativeByNHSEB := function( vec, hom )
    return vec * hom.factor;
end;

#############################################################################
##
#F  PreimageByNHSEB( base, hom )
##
InstallGlobalFunction( PreimageByNHSEB, function( base, hom )
    local new;
    new := List( base, x -> x * hom.factor );
    Append( new, hom.kernel );
    return new;
end );

#############################################################################
##
#F  InducedActionByNHSEB( mat, hom )
##
InducedActionByNHSEB := function( mat, hom )
    local fac, sub;
    fac := List( hom.factor, x -> CoefficientsByNHSEB( x*mat, hom ).coeff1 );
    sub := List( hom.kernel, x -> CoefficientsByNHSEB( x*mat, hom ).coeff2 );
    return rec( factor := fac, subsp := sub );
end;

#############################################################################
##
#F  InducedActionFactorByNHSEB( mat, hom )
##
InstallGlobalFunction( InducedActionFactorByNHSEB, function( mat, hom )
    return List( hom.factor, x -> CoefficientsByNHSEB( x*mat, hom ).coeff1 );
end );

#############################################################################
##
#F  InducedActionSubspaceByNHSEB( mat, hom )
##
InstallGlobalFunction( InducedActionSubspaceByNHSEB, function( mat, hom )
    return List( hom.kernel, x -> CoefficientsByNHSEB( x*mat, hom ).coeff2 );
end );

#############################################################################
##
#F  AddVectorEchelonBase( base, vec )
##
AddVectorEchelonBase := function( base, vec )
    local d, l, j, i;

    # reduce vec
    d := List( base, PositionNonZero );
    repeat
        l := PositionNonZero( vec );
        j := Position( d, l );
        if not IsBool( j ) then
            AddRowVector( vec, base[j], -vec[l] );
        fi;
    until IsBool( j );

    # if vec is completely reduced
    if l = Length(vec)+1 then return; fi;

    # norm vector
    MultRowVector( vec, vec[l]^-1 );

    # finally add vector to base
    base[Length(base)+1] := vec;
end;

#############################################################################
##
#F  SpinnUpEchelonBase( base, vecs, gens, oper )
##
InstallGlobalFunction( SpinnUpEchelonBase, function( base, vecs, gens, oper )
    local todo, i, v, l;
    todo := ShallowCopy( vecs );
    i := 1;
    l := Length( base );
    while i <= Length( todo ) do
        v := todo[i];
        AddVectorEchelonBase( base, v );
        if Length( base ) > l then
            Append( todo, List( gens, x -> oper( v, x ) ) );
            l := l + 1;
        fi;
        i := i + 1;
    od;
    TriangulizeMat( base );
    return base;
end );
        
#############################################################################
##
#F  OnMatVector( vec, mat ) . . . . . . . .operation by matrix on flat matrix
##
InstallGlobalFunction( OnMatVector, function( vec, mat )
    local new, d, i;
    d := Length( mat );
    new := List( mat, x -> 0 );
    for i in [1..d] do new[i] := vec{[(i-1)*d+1..i*d]} * mat; od;
    return Flat( new );       
end );
   
#############################################################################
##
#F  MatByVector( vec, d ) . . . . . . . . . . . . . . reconstruct flat matrix
##
InstallGlobalFunction( MatByVector, function( vec, d )
    return List( [1..d], x -> vec{[(x-1)*d+1..x*d]} );
end );

#############################################################################
##
#F  IsSemiEchelonBase( base )  
##
IsSemiEchelonBase := function( base )
    return IsSSortedList( List( base, PositionNonZero ) );
end;

#############################################################################
##
#F  IsEchelonBase( base )  
##
IsEchelonBase := function( base )
    local d, i;
    d := List( base, PositionNonZero );
    if not IsSSortedList( List( base, PositionNonZero ) ) then return false; fi;
    for i in [1..Length(d)] do
        if base[i][d[i]] <> 1 then return false; fi;
    od;
    return true;
end;
