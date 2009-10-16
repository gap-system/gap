#############################################################################
##
#W  union.gi                                                    Karel Dekimpe
#W                                                               Bettina Eick
##

#############################################################################
##
#F GenericDeterminantMat( mat )
##
GenericDeterminantMat := function( mat )
    local d, det, sig, i, sub;
    
    # set up
    d := Length( mat );
    if ForAny( mat, x -> Length(x) <> d ) then return fail; fi;

    # the trivial cases
    if d = 1 then return mat[1][1]; fi;
    if d = 2 then return mat[1][1] * mat[2][2] - mat[1][2] * mat[2][1]; fi;

    # otherwise use first row and recursion
    det := 0;
    sig := 1;
    for i in [1..d] do
        sub := Concatenation( [1..i-1], [i+1..d] );
        sub := mat{[2..d]}{sub};
        det := det + sig * mat[1][i] * GenericDeterminantMat( sub );
        sig := - sig;
    od;

    return det;
end;

#############################################################################
##
#F NullspaceIntMod( base, vec, p )  . . . . . . . . . . . . b * vec = 0 mod p
##
## computes those elements b in <base> with b * vec = 0 mod p. Returns a 
## triangulized basis with respect to <base>.
##
NullspaceIntMod := function( base, vec, p )
    local imgs, d, null;

    # get images
    imgs := List( base, x -> x * vec );
    imgs := List( imgs, x -> x mod p );
    d    := Length( imgs );
    if ForAll( imgs, x -> x = 0 ) then return IdentityMat( d ); fi;

    # compute kernel of imgs vector - must have rank d-1
    Add( imgs, p );
    null := NullspaceIntMat( TransposedMat( [imgs] ) );
    null := List( null, x -> x{[1..d]} );
    null := NormalFormIntMat( null, 0 ).normal;

    # return this images nullspace
    return Filtered( null, x -> PositionNonZero(x) <= d );
end;

#############################################################################
##
#F FindMaximals( sub ) . . . . . . . .subgroups which are maximal within sub
##
FindMaximals := function( sub )
    local new, i, tmp;
    new := [];
    for i in [1..Length(sub)] do
        if Size( sub[i] ) > 1 then
            if Length(new) = 0 then
                Add( new, sub[i] );
            elif not ForAny( new, x -> IsSubset( x, sub[i] ) ) then
                tmp := Filtered( new, x -> not IsSubset( sub[i], x ) );
                Add( new, sub[i] );
            fi;  
        fi;
    od;
    return new;
end;

if not IsBound( SizeOfUnion ) then SizeOfUnion := false; fi;
#############################################################################
##
#F SizeOfUnionRec( sub ) -- recursive version
##
SizeOfUnionRec := function( list )
    local s, i, int, t, n;
    if Length( list ) = 0 then return 1; fi;
    s := Size( list[1] );
    n := Length( list );
    for i in [2..n] do
        int := List( list{[1..i-1]}, x -> Intersection( x, list[i]));
        t := SizeOfUnion( int );
        s := s + Size( list[i] ) - t;
    od;
    return s;
end;

#############################################################################
##
#F SizeOfUnionTriv -- trivial version
##
SizeOfUnionTriv := function( list )
    return Length( Union( List( list, Elements ) ) );
end;

#############################################################################
##
#F SizeOfUnion -- main function 
##
SizeOfUnion := function( sub )
    local list;
    list := FindMaximals( sub );
    if Length(list) = 0 then return 1; fi;
    if Length(list) = 1 then return Size(list[1]); fi;
    if Sum(List(list, Size)) < 2000 then
        return SizeOfUnionTriv(list); 
    fi;
    return SizeOfUnionRec(list);
end;

#############################################################################
##
#F SizeOfUnionMod( subs, e ) . . . . . . . . .size of the union of subs mod e
##
## <subs> is a list of bases containing (eZ)^d. Compute the size of the union
## of <subs> in (Z/eZ)^d. 
##
## This function needs to be profiled.
##
SizeOfUnionMod := function( subs, e )
    local d, F, V, b, news;

    # the trivial case
    if Length( subs ) = 0 then return 1; fi;
    d := Length( subs[1] );

    if IsPrimeInt( e ) then 
        F := GF(e);
        V := F^d;
        b := BasisVectors( Basis( V ) );
        news := List( subs, x -> x * b );
        news := List( news, x -> Subspace( V, x ) );
        if ForAny( news, x -> Size(x) = e^d ) then return e^d; fi;
        # return SizeOfUnion( news );
        return Length( Union( List( news, Elements ) ) );
    fi;

    V := AbelianGroup( List( [1..d], x -> e ) );
    b := GeneratorsOfGroup(V);
    news := List( subs, x -> List( x, y -> MappedVector( y, b ) ) );
    news := List( news, x -> Subgroup( V, x ) );
    if ForAny( news, x -> Size(x) = e^d ) then return e^d; fi;

    # return SizeOfUnion( news );
    return Length( Union( List( news, Elements ) ) );
end;

