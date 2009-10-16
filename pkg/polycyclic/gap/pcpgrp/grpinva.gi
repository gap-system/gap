#############################################################################
##
#W  grpinva.gi                   Polycyc                         Bettina Eick
##
## Functions to compute all invariant subgroups in an elementary abelian
## subgroup or in a free abelian group up to a certain index
##

##
## First we consider the elementary abelian situation
##

#############################################################################
##
#F AllSubspaces( dim, p ) . . . . . . . . . . . . list all subspaces of p^dim
##
AllSubspaces := function( dim, p )
    local idm, exp, i, t, e, j, f, c, k;

    # create all normed bases in p^dim
    idm := IdentityMat( dim );
    exp := [[]];
    for i in [1..dim] do

        t := [];
        for e in exp do

            # create subspaces of same dimension
            for j in [1..p^Length(e)-1] do
                f := StructuralCopy( e );
                c := CoefficientsQadic( j, p );
                for k in [1..Length(c)] do
                    f[k][i] := c[k];
                od;
                Add( t, f );
            od;

            # add higher dimensional one
            f := StructuralCopy( e );
            Add( f, idm[i] );
            Add( t, f );

        od;
        Append( exp, t );
    od;
    Unbind( exp[Length(exp)] );
    return exp * One(GF(p));
end;

#############################################################################
##
#F OnBasesCase( base, mat )
##
OnBasesCase := function( base, mat )
    local new;
    if Length(base) = 0 then return base; fi;
    new := base * mat;
    if IsFFE( new[1][1] ) then
        TriangulizeMat( new );
    else
        new := TriangulizedIntegerMat( new );
    fi;
    return new;
end;

#############################################################################
##
#F InvariantSubspaces( C, d )
##
InvariantSubspaces := function( C, d )
    local p, l, invs, modu;

    # set up
    p := C.char;
    l := C.dim;

    # distinguish two cases
    if IsBound( C.spaces ) then
        invs := Filtered( C.spaces, x -> l - Length(x) <= d );
        if not IsBound( C.central ) or not C.central then
            invs := FixedPoints( invs, C.mats, OnBasesCase );
        fi;
    else
        modu := GModuleByMats( C.mats, C.dim, C.field );
        invs := MTX.BasesSubmodules( modu );
        invs := Filtered( invs, x -> Length( x ) < l );
        invs := Filtered( invs, x -> l - Length( x ) <= d );
    fi;
    return invs;
end;
    
#############################################################################
##
#F OrbitsInvariantSubspaces( C, d )
##
OrbitsInvariantSubspaces := function( C, d )
    local invs;
    invs := InvariantSubspaces( C, d );
    if ForAny( C.smats, x -> x <> C.one ) then
        return PcpOrbitsStabilizers( invs, C.super, C.smats, OnBasesCase );
    else
        return List( invs, x -> rec( repr := x, stab := C.super ) );
    fi;
end;

##
## Now we deal with the free abelian case
##

#############################################################################
##
#F InsertZeros( d, exp, n )
##
InsertZeros := function( d, exp, n )
    local new, b;
    new := n * IdentityMat( d );
    for b in exp do
        new[PositionNonZero(b)] := b;
    od;
    return new;
end;

#############################################################################
##
#F PcpsBySpaces( A, B, dim, p, bases )
##
PcpsBySpaces := function( A, B, dim, p, bases )
    local tmp, base, new, b, i, C, gen, pcp;
    tmp := [];
    gen := Igs( B );
    for base in bases do
        new := InsertZeros( dim, base, p );
        for i in [1..Length( new )] do
            new[i] := MappedVector( IntVector( new[i] ), gen );
        od;
        new := Filtered( new, x -> x <> One(A) );
        C := SubgroupByIgs( A, new );
        pcp := Pcp( B, C );
        pcp!.index := IndexNC( B, C );
        Add( tmp, pcp );
    od;
    return tmp;
end;

#############################################################################
##
#F AllSubgroupsAbelian( dim, l )
##
## The subgroups of the free abelian group of rank dim up to index l given 
## as exponent vectors.
##
AllSubgroupsAbelian := function( dim, l )
    local A, gens, fac, sub, i, p, r, sp, j, q, B, pcps, tmp, L, pcpL,
          pcpsS, C, grps, U, V, pcpS, new; 

    # create the abelian group
    A := AbelianPcpGroup( dim, List( [1..dim], x -> l ) );
    gens := Cgs(A);

    # first separate the primes
    fac := Collected( Factors( l ) );
    sub := List( fac, x -> [A] );
    for i in [1..Length(fac)] do
        p := fac[i][1];
        r := fac[i][2];
        sp := AllSubspaces( dim, p );
        for j in [1..r] do

            # set up
            q := p^(j-1);
            B := SubgroupByIgs( A, List( gens, x -> x^q ) );
            pcps := PcpsBySpaces( A, B, dim, p, sp );

            # loop over all subgroups and spaces
            tmp := [];
            for L in sub[i] do
                pcpL := Pcp( L, B );
                for pcpS in pcps do
                    if IndexNC( A, L ) * pcpS!.index <= l then
                        
                        # compute complements in L to R / S 
                        C := rec();
                        C.group := L;
                        C.factor := pcpL;
                        C.normal := pcpS;
                        AddFieldCR( C );
                        AddRelatorsCR( C );
                        AddOperationCR( C );
                        AddInversesCR( C );
                        Append( tmp, ComplementsCR( C ) );
                    fi;
                od;
            od;
            Append( sub[i], tmp );
        od;
        sub[i] := List( sub[i], x -> List( Igs(x), Exponents ) );
    od;

    # intersect `jeder gegen jeden'
    grps := sub[1];
    for i in [2..Length(fac)] do
        tmp := [];
        for U in grps do
            for V in sub[i] do
                new := AbelianIntersection( U, V );
                Append( tmp, new );
            od;
        od;
        grps := ShallowCopy( tmp );
    od;
    grps := List( grps, x -> InsertZeros( dim, x, l ) );
    return grps{[2..Length(grps)]};
end;
    
AllSubgroupsAbelian2 := function( dim, n )
    local A, cl;
    A := AbelianPcpGroup( dim, List( [1..dim], x -> n ) );
    cl := FiniteSubgroupClasses( A );
    cl := List( cl, Representative );
    cl := Filtered( cl,  x -> IndexNC(A,x) <= n );
    cl := List( cl, x -> List( Cgs(x), Exponents ) );
    cl := List( cl, x -> InsertZeros( dim, x, n ) );
    return cl{[2..Length(cl)]};
end;

