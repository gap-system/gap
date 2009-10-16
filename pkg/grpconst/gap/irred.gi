#############################################################################
##
#W  irred.gi                    GrpConst                         Bettina Eick
#W                                                         Hans Ulrich Besche
##
Revision.("grpconst/gap/irred_gi") :=
    "@(#)$Id: irred.gi,v 1.10 2004/11/01 13:21:31 gap Exp $";

#############################################################################
##
#F Check if a module is faithful
##
InstallGlobalFunction( IsFaithfulModule, function( L, m )
    local pcgs, M, iso, s;

    # set up and trivial case
    pcgs := Pcgs(L);
    if Length( pcgs ) = 0 then
        return true;
    fi;

    # otherwise use a zassenhaus-like method
    M := Group( m.generators );
    iso := GroupHomomorphismByImagesNC( L, M, pcgs, m.generators );
    s := Size( KernelOfMultiplicativeGeneralMapping(iso) );
    return s = 1;
end );

#############################################################################
##
#F Check size of Sylow case
##
InstallGlobalFunction( IsMaximalPrimePower, function( a, b )
    local fb, fa;
    fb := Factors(b);
    fa := Factors(a/b);
    return b <> 1 and Length(Set(fb))=1 and not fb[1] in fa;
end );

#############################################################################
##
#F GModuleByGroup( G )
##
InstallGlobalFunction( GModuleByGroup, function( G )
    return GModuleByMats( GeneratorsOfGroup(G),
                          DimensionOfMatrixGroup(G),
                          FieldOfMatrixGroup(G) );
end );
    
#############################################################################
##
#F Check conjugacy of groups 
##
AreConjugateGroups := function( M, G, H )
    local nat, g, iso, aut, a, h, C, i, r;

    Print("    compute images \n");
    nat := IsomorphismPermGroup( M );
    G := Image( nat, G );
    H := Image( nat, H );
    M := Image( nat, M );

    Print("    check equality \n");
    if G = H then return true; fi;

    g := GeneratorsOfGroup(G);
    iso := IsomorphismGroups( G, H );
    aut := AutomorphismGroup( G );
    Print("    automorphism group has size ",Size(aut),"\n");
    for a in Elements(aut) do
        Print("    try next automorphism \n");
        h := List( g, x -> Image( iso, Image(a, x) ) );
        C := M;
        r := ();
        i := 1;
        while i <= Length( g ) and not IsBool(r) do
            Print("      ",i,"th generator \n");
            r := RepresentativeAction( C, g[i], h[i] );
            if not IsBool( r ) then
                C := Centralizer( C, g[i] );
                r := r^-1;
                h := List( h, x -> x^r );
            fi;
            i := i+1;
        od;
        if not IsBool(r) then return true; fi;
    od;
    return false;
end;

InstallGlobalFunction( ReduceToClasses, function( M, list )
    local gens, reps, U, orb, c, g, new;

    # the trivial case
    if Length( list ) = 0 or Length( list ) = 1 then return list; fi;
    if Length( list ) = 2 then 
        if AreConjugateGroups( M, list[1], list[2] ) then
            return [list[1]];
        else
            return list;
        fi;
    fi;
  
    # start to work
    gens := GeneratorsOfGroup( M );
    reps := [];

    while Length( list ) > 0 do
        U := list[Length(list)];
        list := Filtered( list, x -> x <> U );
        Add( reps, U );
        orb := [U];
        c := 1;
        while c <= Length( orb ) and Length(list) > 0 do
            for g in gens do
                new := orb[c]^g;
                if not new in orb then
                    list := Filtered( list, x -> x <> new );
                    Add( orb, new );
                fi;
            od;
            c := c + 1;
        od;
    od;
    return reps;
end );

#############################################################################
##
#F Let L be a soluble group. Find all irreducible embeddings of L into 
## GL(n,p) up to conjugacy.
##
InstallGlobalFunction( IrreducibleEmbeddings, function( n, p, L )
    local M, f, modu, cl, m, U;

    # we don't want to see the trivial case here
    if n = 1 then return false; fi;
    
    # first check the arguments and avoid trivial cases
    if Size( PCore( L, p ) ) > 1 then return []; fi;

    # compute modules
    f := GF(p);
    modu := IrreducibleModules( L, f, n )[2];
    modu := Filtered( modu, x -> x.dimension = n );

    # filter out non-faithful ones
    modu := Filtered( modu, x -> IsFaithfulModule(L,x));

    # reduce to conjugacy classes
    M  := GL(n,p);
    cl := [];
    for m in modu do
        U := SubgroupNC( M, m.generators );
        SetSize(U, Size(L));
        Add( cl, U );
    od;
    cl := ReduceToClasses( M, cl );
    return cl;
end );

#############################################################################
##
#F Compute all irreducible soluble subgroups of GL(n,p) of order dividing 
## size up to conjugacy. Consider a number of different cases.
##
#############################################################################
InstallGlobalFunction( IrreducibleGroupsByAbelian, function(n, p, size)
    local P, primes, cl, q, new, M, field, root, iso, i, tmp;

    P := CyclicGroup( IsPermGroup, p - 1 );
    primes := Set(FactorsInt(Size(P)));
    primes := Filtered( primes, x -> x <> 1 );
    cl := [TrivialSubgroup(P)];
    for q in primes do
        new := Pcgs( SylowSubgroup(P, q) );
        new := List(cl, x -> List( new, y -> ClosureGroup( x, y )));
        cl  := Concatenation( cl, Flat( new ) );
        cl  := Filtered( cl, x -> IsInt( size / Size(x) ) );
    od;

    # compute isomorphism
    M     := GL(n,p);
    field := GF( p );
    root  := PrimitiveRoot( field );
    iso   := GroupHomomorphismByImagesNC( P, M, 
                                GeneratorsOfGroup( P ), [[[root]]] );

    # convert
    for i in [1..Length(cl)]  do
        tmp := Image( iso, cl[i] );
        SetSize( tmp, Size( cl[i] ) );
        cl[i] := tmp;
    od;
    return cl;
end );

#############################################################################
InstallGlobalFunction( IrreducibleGroupsByCatalogue, function(n,p,size)
    local k, cl;

    # we don't want to see the trivial case here
    if n = 1 then return false; fi;

    # return list from irredsol
    return AllIrreducibleSolvableMatrixGroups( Degree, [n], Field, [GF(p)], 
           Order, DivisorsInt(size) );

    # get irreducible groups - old version based on primitive groups
    k  := NumberIrreducibleSolvableGroups( n, p );
    cl := List( [1..k], x -> IrreducibleSolvableGroupMS( n, p, x ) );
    cl := Filtered( cl, x -> IsInt( size / Size(x) ) );
    return cl;
end );

#############################################################################
InstallGlobalFunction( IrreducibleGroupsByEmbeddings, function(n,p,size)
    local div, all, cl, L, M, d, q, P, m;

    # we don't want to see the trivial case here
    if n = 1 then return false; fi;

    # create the possible isomorphism types of groups
    M   := GL(n,p);
    div := DivisorsInt( size );
    div := Filtered( div, x -> x <> 1 and IsInt(Size(M)/x) );
    cl  := [];
    for d in div do

        # first the very special case that we have the full size
        if d = Size(M) then
            if n=2 and (p=2 or p=3) then Add( cl, M ); fi;

        # now consider the Sylow case - extend to p-group case?
        elif IsMaximalPrimePower( Size(M), d ) then
            q := Factors(d)[1];
            if q <> p then
                P := SylowSubgroup(M, q );
                m := GModuleByGroup( P );
                if MTX.IsIrreducible( m ) then Add( cl, P ); fi;
            fi;

        # in all other cases loop over all groups
        else
            all := AllGroups( d, IsSolvableGroup );
            for L in all do
                Append( cl, IrreducibleEmbeddings( n, p, L ) );
            od;
        fi;
    od;
    return cl;
end );
        
#############################################################################
InstallGlobalFunction( IrreducibleGroups, function( n, p, size )
    if n = 1 then
        return IrreducibleGroupsByAbelian(n,p,size);
    #elif p^n < 256 and PRIM_AVAILABLE then
    elif IsAvailableIrreducibleSolvableGroupData(n,p) then
        return IrreducibleGroupsByCatalogue(n,p,size);
    elif not IsBool( SMALL_AVAILABLE(size) ) then
        return IrreducibleGroupsByEmbeddings(n,p,size);
    else 
        return fail;
    fi;
end );

#############################################################################
##
#F Test to check embeddings versus catalogue
##
TestIrred := function(limit, start)
    local ppi, q, p, n, max, size, emb, cat;
    ppi := Filtered([start..255], x -> IsPrimePowerInt(x) and not IsPrime(x));
    for q in ppi do
        p := Factors(q)[1];
        n := Length( Factors(q) );
        max := QuoInt( limit, q );
        for size in [1..max] do
            Print("start ", p, "^", n," and size ", size,"\n");
            emb := IrreducibleGroupsByEmbeddings( n, p, size );
            emb := List( emb, IdGroup );
            Sort( emb );
            cat := IrreducibleGroupsByCatalogue( n, p, size );
            cat := List( cat, IdGroup );
            Sort( cat );
            if cat <> emb then
                Error("hier\n");
            fi;
        od;
    od;
end; 
