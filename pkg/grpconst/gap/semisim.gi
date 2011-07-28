#############################################################################
##
#W  semisim.gi                  GrpConst                         Bettina Eick
#W                                                         Hans Ulrich Besche
##
Revision.("grpconst/gap/semisim_gi") :=
    "@(#)$Id: semisim.gi,v 1.7 2011/01/31 12:18:13 gap Exp $";

#############################################################################
##
#F BlockDiagonalMat( blocks, field )
##
InstallGlobalFunction( BlockDiagonalMat, function( blocks, field )
    local c, n, new, mat, i, j;
    c := 0;
    n := Sum( List( blocks, Length ) );
    new := MutableNullMat( n, n, field );
    for mat in blocks do
        for i in [1..Length(mat)] do
            for j in [1..Length(mat)] do
                new[c+i][c+j] := mat[i][j];
            od;
        od;
        c := c + Length( mat );
    od;
    return new;
end );

#############################################################################
##
#F Choices( part, irr ) . . . jeder gegen jeden
##
InstallGlobalFunction( Choices, function( part, irr )
    local col, sub, new, i, tmp, U;

    # catch the trivial case
    if ForAny( Set(part), x -> Length(irr[x]) = 0 ) then
        return [];
    fi;

    # first for each homogeneous sublist of part
    col := Collected( part );
    sub := List( col, c -> UnorderedTuples( irr[c[1]], c[2] ) );

    # now combine
    new := sub[1];
    for i in [2..Length(col)] do
        tmp := [];
        for U in new do
            Append( tmp, List( sub[i], x -> Concatenation(U,x) ) );
        od;
        new := Set( tmp );
    od;
    return new;
end );

#############################################################################
##
#F EmbeddingIntoGL( M, part, list )
##
InstallGlobalFunction( EmbeddingIntoGL, function( M, part, list )
    local new, r, f, i, e, l, gens, U;
    new := [];
    r := Length(list);
    f := FieldOfMatrixGroup(list[1]);
    for i in [1..r] do
        e := Sum(part{[1..i-1]});
        l := Sum(part{[i+1..r]});
        gens := GeneratorsOfGroup( list[i] );
        gens := List( gens, x -> [IdentityMat(e, f), x, IdentityMat(l, f)] );
        gens := List( gens, x -> BlockDiagonalMat( x, f ) ); 
        U := Subgroup( M, gens ); 
        SetSize( U, Size( list[i] ) );
        Add( new, U );
    od;
    return new;
end );

#############################################################################
##
#F ComputeSocleDimensions( iso, U )
##
ComputeSocleDimensions := function( iso, U )
    local gens, mats, modu, comp, dims;
    gens := GeneratorsOfGroup(U);
    mats := List( gens, x -> PreImagesRepresentative(iso, x) );
    modu := GModuleByGroup( Subgroup(Source(iso), mats ) );
    comp := MTX.CompositionFactors( modu );
    dims := List( comp, x -> x.dimension );
    Sort( dims );
    SetSocleDimensions( U, dims );
end;

#############################################################################
##
#F ReduceConjugates( P, all )
##
ReduceConjugates := function( P, all )
    local sub, U, found, j;

    sub := [];
    for U in all do
        found := false;
        j := 1;
        while not found and j <= Length( sub ) do
            if RepresentativeAction( P, U, sub[j] ) <> fail then
                found := true;
            fi;
            j := j + 1;
        od;
        if not found then Add( sub, U ); fi;
    od;
    return sub;
end;

#############################################################################
##
#F MyRationalClassesPElements( P, p )
##
MyRatClassesPElmsReps := function(P,p)
    local o, Q, cl, l, todo, i, j, k, sc;

    # some easy cases
    o := Size(P);
    if o = 1 or not IsInt(o/p) then 
        return []; 
    elif not IsInt(o/p^2) then 
        return [GeneratorsOfGroup(SylowSubgroup(P,p))[1]]; 
    fi;

    # try Sylow
    Q := SylowSubgroup(P,p);
    cl := RationalClasses(Q);
    cl := List(cl, Representative);
    cl := Filtered(cl, x -> Order(x) = p);
    l := Length(cl);

    # fuse
    todo := List([1..l], x -> true);
    for i in [1..l-1] do
        if todo[i] = true then 
            for j in [i+1..l] do
                if todo[j] = true then 
                    for k in [1..p-1] do
                        if IsConjugate(P, cl[i], cl[j]^k) then 
                            todo[j] := false;
                        fi;
                    od;
                fi;
            od;
        fi;
    od;

    cl := cl{Filtered([1..l], x -> todo[x]=true)};

    # check
    #sc := RationalClassesPElements(P,p);
    #sc := List(sc, Representative);
    #sc := Filtered(sc, x -> IsInt(p/Order(x)));
    #if Length(sc) <> Length(cl) then Error("hier"); fi;

    return cl;
end;

MyRatClassesPElmsReps2 := function(P,q)
    local cl;
    cl := RationalClasses(P);
    cl := List(cl, Representative);
    cl := Filtered(cl, x -> Order(x) = q);
    return cl;
end;

#############################################################################
##
#F SemiSimpleGroupsTS( n, p, sizes, iso )
##
## Case for trivial sizes; that is, sizes = [q] for q = 1 or q prime
##
SemiSimpleGroupsTS := function( n, p, sizes, iso )
    local M, P, q, sub, new, i;

    # set up
    M := Source( iso );
    P := Range( iso );
    q := sizes[1];

    # the trivial subgroup is always possible
    sub := [TrivialSubgroup( P )];

    # add coprime subgroups if desired
    if q <> 1 and q <> p then 
        new := MyRatClassesPElmsReps( P, q );
        new := List( new, x -> Subgroup( P, [x] ) );
        Append( sub, new );
    fi;

    # add info
    for i in [1..Length(sub)] do ComputeSocleDimensions( iso, sub[i] ); od;
    return sub;
end;

#############################################################################
##
#F SemiSimpleGroupsGC( n, p, sizes, iso )
##
## General case without restrictions.
##
SemiSimpleGroupsGC := function( n, p, sizes, iso )
    local M, P, irr, d, i, new, subdir, part, cand, list, all, emb, sub;

    M := Source( iso );
    P := Range( iso );

    # compute irreducible groups
    irr := List( [1..n], x -> [] );
    for d in [1..n] do
        for i in [1..Length(sizes)] do
            new := IrreducibleGroups( d, p, sizes[i] );
            new := Filtered( new, x -> UnknownSize(sizes{[1..i-1]}, Size(x)));
            Append( irr[d], new );
        od;
    od;

    subdir := [];
    for part in Partitions(n) do
        Sort( part );

        # construct candidates first
        cand := Choices( part, irr );
    
        # compute subdirect products within P
        all := [];
        for list in cand do
            emb := EmbeddingIntoGL( M, part, list );
            emb := List( emb, x -> Image( iso, x ) );
            new := InnerSubdirectProducts( P, emb );
            new := Filtered( new, x -> KnownSize( sizes, Size(x) ) );
            Append( all, new );
        od;

        # filter conjugates in P
        sub := ReduceConjugates( P, all ); 

        # add some information
        for i in [1..Length(sub)] do SetSocleDimensions( sub[i], part ); od;
        Append( subdir, sub );
    od;
    return subdir; 
end; 

#############################################################################
##
#F SemiSimpleGroupsSS( n, p, sizes, iso )
##
## Supersolvable case: Irreducible constituents are 1-dim.
##
SemiSimpleGroupsSS := function( n, p, sizes, iso )
    local M, P, irr, i, new, part, cand, all, list, emb, sub;

    M := Source( iso );
    P := Range( iso );

    # compute irreducible groups
    irr := [];
    for i in [1..Length(sizes)] do
        new := IrreducibleGroups( 1, p, sizes[i] );
        new := Filtered( new, x -> UnknownSize(sizes{[1..i-1]}, Size(x)));
        Append( irr, new );
    od;

    # construct candidates first
    part := List( [1..n], x -> 1 );
    cand := Choices( part, [irr] );

    # compute subdirect products within P
    all := [];
    for list in cand do
        emb := EmbeddingIntoGL( M, part, list );
        emb := List( emb, x -> Image( iso, x ) );
        new := InnerSubdirectProducts( P, emb );
        new := Filtered( new, x -> KnownSize( sizes, Size(x) ) );
        Append( all, new );
    od;

    # filter conjugates in P
    sub := ReduceConjugates( P, all ); 

    # add some information
    for i in [1..Length(sub)] do SetSocleDimensions( sub[i], part ); od;
    return sub;
end;

#############################################################################
##
#F SemiSimpleGroupsCF( n, p, sizes, iso )
##
## Cubefree case: n = 2 and groups have cubefree order not divisible by p 
##
SemiSimpleGroupsCF := function( n, p, sizes, iso )
    local irr, i, new, a, b, M, C, D, d, K, k, g, act, sub, nat, dia;

    if n <> 2 then Error("need n = 2 for this case"); fi;

    # compute irreducible groups
    irr := [];
    for i in [1..Length(sizes)] do
        new := IrreducibleGroups( 2, p, sizes[i] );
        new := Filtered( new, x -> UnknownSize(sizes{[1..i-1]}, Size(x)));
        Append( irr, new );
    od;
    irr := Filtered( irr, x -> IsCubeFree( Size(x) ) );
    irr := Filtered( irr, x -> not IsInt(Size(x)/p) );

    # translate and add info
    for i in [1..Length(irr)] do
        irr[i] := Image( iso, irr[i] );
        SetSocleDimensions( irr[i], [2] );
    od;

    # compute reducible groups
    if ForAll( sizes, x -> Gcd( x, (p-1)^2 ) = 1 ) then 
        dia := [TrivialSubgroup(Source(iso))];
    else
        a := [[Z(p),0],[0,1]]*One(GF(p));
        b := [[1,0],[0,Z(p)]]*One(GF(p));
        M := Group([a,b]);

        # pc group
        C := CyclicGroup(p-1);
        D := DirectProduct(C,C);
        d := Filtered(GeneratorsOfGroup(D),x->Order(x)=p-1);

        # subgroups of pc group
        sub := SubgroupsSolvableGroup(D);
        sub := Filtered( sub, x -> IsCubeFree(Size(x)));
        sub := Filtered( sub, x -> ForAny(sizes, y -> IsInt(y/Size(x))));

        # orbits in pc group
        K := CyclicGroup(2);
        k := GeneratorsOfGroup(K);
        g := [GroupHomomorphismByImages(D,D,d,[d[2],d[1]])];
        act := function(pt,elm)return Image(elm,pt);end;
        sub := Orbits(K,sub,k,g,act);

        # pull back into matrix group
        nat := GroupHomomorphismByImagesNC(D,M,d,[a,b]);
        dia := List( sub, x -> Image( nat, x[1] ) );
    fi;

    # translate and add info
    for i in [1..Length(dia)] do
        dia[i] := Image( iso, dia[i] );
        SetSocleDimensions( dia[i], [1,1] );
    od;
    
    # return 
    return Concatenation( irr, dia );
end;

#############################################################################
##
#F SemiSimpleGroups( n, p, sizes, flags )
##
## .. up to conjugacy in GL(n,p)
##
InstallGlobalFunction( SemiSimpleGroups, function( n, p, sizes, flags )
    local M, iso, inv, grps, i;

    # set up
    M := GL(n, p);

    # size is a list of possible sizes
    if IsBool( sizes ) then 
        sizes := [Size( M )]; 
    elif IsInt( sizes ) then
        sizes := [sizes];
    elif IsList( sizes ) then
        sizes := MinimizeList( sizes );
    else
        Error("wrong input in SemiSimpleGroups");
    fi;

    # operation isomorphism 
    iso := IsomorphismPermGroup( M );

    # dispatch
    if IsBound( flags.cubefree ) and flags.cubefree and n = 2 then 
        grps := SemiSimpleGroupsCF( n, p, sizes, iso );
    elif IsBound( flags.supersol ) and flags.supersol then 
        grps := SemiSimpleGroupsSS( n, p, sizes, iso );
    elif Length( sizes ) = 1 and Length(Factors(sizes[1])) = 1 then 
        grps := SemiSimpleGroupsTS( n, p, sizes, iso );
    else
        grps := SemiSimpleGroupsGC( n, p, sizes, iso );
    fi;

    inv := InverseGeneralMapping( iso );
    for i in [1..Length(grps)] do SetProjections( grps[i], [inv] ); od;
    return grps;
end );
    
