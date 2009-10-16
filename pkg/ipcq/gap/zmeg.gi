#############################################################################
##
#W  zmeg.gi                      ipcq package                    Bettina Eick
## 
##  This is the file containing the functions calling the Gap zme program.
##

#############################################################################
##
#F InvertedRelation( af, aer, e, ring, l )
##
InvertedRelation := function( af, aer, e, ring, l )
    local k;
    for k in Reversed( [1..Length(e)] ) do
        if e[k][1] <= l and e[k][2] > 0 then
            Add( aer, e[k][1]+l );
            Add( aer, e[k][2] );
        elif e[k][1] <= l then
            Add( aer, e[k][1] );
            Add( aer, -e[k][2] );
        fi;
    od;
    aer := [Zero(ring),[aer, -One(ring), [],One(ring)]];
    return ObjByExtRep(af,aer);
end;

#############################################################################
##
#F ExponentList( exp )
##
ExponentList := function( exp )
    local tmp, i;
    tmp := [];
    for i in [1..Length(exp)] do
        if exp[i] <> 0 then Add( tmp, [i, exp[i]] ); fi;
    od;
    return tmp;
end;

#############################################################################
##
#F FpAlgebraByQSystem( Q, ring, l )
##
## Only the first l generators act non-trivially.
##
FpAlgebraByQSystem := function( Q, ring, l )
    local gens, relo, ngens, invmap, names, freealg, agens, af, m, rels, 
          i, j, k, aer, e, r;

    # get generators and catch the trivial case
    gens := Q.pcgens;
    relo := Q.pcords;
    ngens := l;
    if ngens = 0 then return FreeAssociativeAlgebraWithOne(ring,[]); fi;

    # set up generators of algebra and free algebra
    invmap := Concatenation([ngens+1..2*ngens],[1..ngens]);
    names := List( [1..ngens], x -> Concatenation(gens[x]!.name, String(x)));
    Append(names, List(names, n->Concatenation(n,"i")));
    freealg := FreeAssociativeAlgebraWithOne(ring, names);
    agens := GeneratorsOfAlgebraWithOne(freealg);
    af := FamilyObj(agens[1]);
    m := Length( agens );

    # define inverses
    rels := List([1..m], i -> agens[i]*agens[invmap[i]] - One(freealg));

    # compute rels in ZG
    for i in [1..ngens] do
        for j in [1..i] do
            if i = j and relo[i] > 0 then
                # gi^ri = gi+1^ei+1 ... gn^en
                aer := [i, relo[i]];
                e := Q.pcrels[i][i];
                r := InvertedRelation( af, aer, e, ring, ngens );
                Add( rels, r );

                # gi^-ri = gi+1^ei+1 ... gn^en
                aer := [ngens+i,relo[i]];
                e := ExponentList( Exponents( gens[i]^-relo[i] ) );
                r := InvertedRelation( af, aer, e, ring, ngens );
                Add( rels, r );

            elif i <> j then
                # gi^gj = gj+1^ei+1 ... gn^en
                aer := [ngens+j, 1, i, 1, j, 1];
                e := Q.pcrels[i][j];
                r := InvertedRelation( af, aer, e, ring, ngens );
                Add( rels, r );

                # (gi^-1)^gj = gj+1^ei+1 ... gn^en
                aer := [ngens+j, 1, ngens+i, 1, j, 1];
                e := ExponentList( Exponents( (gens[i]^-1)^gens[j] ) );
                r := InvertedRelation( af, aer, e, ring, ngens );
                Add( rels, r );

                # gi^gj^-1 = gj+1^fi+1 ... gn^fn
                aer := [j, 1, i, 1, ngens+j, 1];
                e := Q.pcrels[i][i+j];
                r := InvertedRelation( af, aer, e, ring, ngens );
                Add( rels, r );

                # (gi-1)^gj^-1 = gj+1^fi+1 ... gn^fn
                aer := [j, 1, ngens+i, 1, ngens+j, 1];
                e := ExponentList( Exponents( (gens[i]^-1)^(gens[j]^-1) ) );
                r := InvertedRelation( af, aer, e, ring, ngens );
                Add( rels, r );
            fi;
        od;
    od;
    return FactorFreeAlgebraByRelators(freealg, rels);
end;

#############################################################################
##
#F AlgebraElementByWord( A, pcp, w, l )
##
## Only the first l generators of pcp act non-trivially. The algebra A knows
## this already.
##
AlgebraElementByWord := function( A, pcp, w, l )
    local agens, b, v, e, c, i;
    agens := GeneratorsOfAlgebraWithOne( A );
    b := Zero( A );
    for v in w do
        e := ExponentsByPcp( pcp, v[2] );
        c := One(A);
        for i in [1..l] do
            if e[i] > 0 then
                c := c * agens[i]^e[i];
            elif e[i] < 0 then
                c := c * agens[i+l]^(-e[i]);
            fi;
        od;
        b := b + v[1] * c;
    od;
    return b;
end;

#############################################################################
##
#F RunZme( Q, M )
##
RunZme := function( Q, M )
    local n, A, a, t, V, v, r, i, rel, j, new, u, w, s;

    Info( InfoIPCQ, 3,"    set up module presentation in used format");

    # get fp algebra and its free module
    n := Length( Q.pcgens );
    A := FpAlgebraByQSystem( Q, Integers, n );
    a := GeneratorsOfAlgebra( A );
    SetGeneratorsOfAlgebraWithOne( A, a{[2..Length(a)]} );

    # get module relations
    t := M.rows;
    V := A^t;
    v := GeneratorsOfLeftModule( V );
    r := [];
    for i in [1..M.cols] do
        rel := Zero( A );
        for j in [1..t] do
            new := AlgebraElementByWord( A, Q.pcgens, M.tails[j][i], n );
            new := v[j] * new;
            rel := rel + new;
        od;
        Add( r, rel ); 
    od;
    u := ME.create( V, r );
    
    # run zme
    Info( InfoIPCQ, 3, "    run zme");
    ME.run( u );
    w := ME.extract( u );

    # extract result 
    return rec( tails := w.ims, 
                opers := w.mats{[1..Length(Q.pcgens)]}, 
                order := w.lattice );
end;

#############################################################################
##
#F RunMe( Q, M, ring, l ) . . . . . . . . . . . . . . .enumerate M over ring 
##
## Only the first l generators of Q may act non-trivially on M.
##
RunMe := function( Q, M, ring, l )
    local n, A, a, t, V, v, r, i, rel, j, new, u, w, res;

    Info( InfoIPCQ, 3,"    set up module presentation in used format");

    # get fp algebra and its free module
    n := Length( Q.pcgens );
    A := FpAlgebraByQSystem( Q, ring, l );
    a := GeneratorsOfAlgebra( A );
    SetGeneratorsOfAlgebraWithOne( A, a{[2..Length(a)]} );

    # get module relations
    t := M.rows;
    V := A^t;
    v := GeneratorsOfLeftModule( V );
    r := [];
    for i in [1..M.cols] do
        rel := Zero( A );
        for j in [1..t] do
            new := AlgebraElementByWord( A, Q.pcgens, M.tails[j][i], l );
            new := v[j] * new;
            rel := rel + new;
        od;
        Add( r, rel );
    od;
    u := ME.create( V, r );

    # run zme
    Info( InfoIPCQ, 3, "    run zme");
    ME.run( u );
    w := ME.extract( u );

    # extract result
    if Length( w.mats[1] ) = 0 then 
        res :=  rec( tails := w.ims,
                    opers := Concatenation( w.mats{[1..l]},
                             List( [l+1..n], x -> w.mats[1] ) ),
                    istri := true );
    else
        res := rec( tails := w.ims,
                    opers := Concatenation( w.mats{[1..l]},
                             List( [l+1..n], x -> w.mats[1]^0 ) ),
                    istri := false );
    fi;
    if IsBound( w.lattice ) then res.order := w.lattice; fi;
    return res;
end;
