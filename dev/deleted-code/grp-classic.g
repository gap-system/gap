#
# This code used to be in grp/classic.gi
#

#############################################################################
##
#F  EichlerTransformation( <g>, <u>, <x> )  . .  eichler trans of <u> and <x>
##
BindGlobal( "EichlerTransformation", function( g, u, x )
    local   e,  b,  i;

    # construct matrix of eichler transformation in <e>
    e := [];

    # loop over the standard vectors
    for b  in One( g )  do
        i := b
             + (b*InvariantBilinearForm(g).matrix*x)*u
             - (b*InvariantBilinearForm(g).matrix*u)*x
             - (b*InvariantBilinearForm(g).matrix*u)
	       *((x*InvariantQuadraticForm( g ) )*x)*u;
        Add( e, i );
    od;

    # and return
    return e;
end );


#############################################################################
##
#F  WallForm( <form>, <m> ) . . . . . . . . . . . . . compute the wall of <m>
##
BindGlobal( "WallForm", function( form, m )
    local   id,  w,  b,  p,  i,  x,  j;

    # first argument should really be something useful
    id := One( m );

    # compute a base for Image(id-m), use the most stupid algorithm
    w := id - m;
    b := [];
    p := [];
    for i  in [ 1 .. Length(w) ]  do
        if Length(b) = 0  then
            if w[i] <> 0*w[i]  then
                Add( b, w[i] );
                Add( p, i );
            fi;
        elif RankMat(b) <> RankMat(Concatenation(b,[w[i]]))  then
            Add( b, w[i] );
            Add( p, i );
        fi;
    od;

    # compute the form
    x := List( b, x -> [] );
    for i  in [ 1 .. Length(b) ]  do
        for j  in [ 1 .. Length(b) ]  do
            x[i][j] := id[p[i]] * form * b[j];
        od;
    od;

    # and return
    return rec( base := b, pos := p, form := x );

end );


#############################################################################
##
#F  SpinorNorm( <form>, <m> ) . . . . . . . .  compute the spinor norm of <m>
##
BindGlobal( "SpinorNorm", function( form, m )
    if IsOne(m) then return One(m[1][1]); fi;
    return DeterminantMat( WallForm(form,m).form );
end );


#############################################################################
##
#F  WreathProductOfMatrixGroup( <M>, <P> )  . . . . . . . . .  wreath product
##
BindGlobal( "WreathProductOfMatrixGroup", function( M, P )
    local   m,  d,  id,  gens,  b,  ran,  raN,  mat,  gen,  G;

    m := DimensionOfMatrixGroup( M );
    d := LargestMovedPoint( P );
    id := IdentityMat( m * d, DefaultFieldOfMatrixGroup( M ) );
    gens := [  ];
    for b  in [ 1 .. d ]  do
        ran := ( b - 1 ) * m + [ 1 .. m ];
        for mat  in GeneratorsOfGroup( M )  do
            gen := StructuralCopy( id );
            gen{ ran }{ ran } := mat;
            Add( gens, gen );
        od;
    od;
    for gen  in GeneratorsOfGroup( P )  do
        mat := StructuralCopy( id );
        for b  in [ 1 .. d ]  do
            ran := ( b - 1 ) * m + [ 1 .. m ];
            raN := ( b^gen - 1 ) * m + [ 1 .. m ];
            mat{ ran } := id{ raN };
        od;
        Add( gens, mat );
    od;
    G := GroupWithGenerators( gens );
    if HasName( M )  and  HasName( P )  then
        SetName( G, Concatenation( Name( M ), " wr ", Name( P ) ) );
    fi;
    return G;
end );


#############################################################################
##
#F  TensorWreathProductOfMatrixGroup( <M>, <P> )  . . . tensor wreath product
##
BindGlobal( "TensorWreathProductOfMatrixGroup", function( M, P )
    local   m,  n,  one,  id,  a,  gens,  b,  ran,  mat,  gen,  list,
            p,  q,  adic,  i,  G;

    m := DimensionOfMatrixGroup( M );
    one := One( FieldOfMatrixGroup( M ) );
    a := LargestMovedPoint( P );
    n := m ^ a;
    id := Immutable( IdentityMat( n, one ) );
    gens := [  ];
    for b  in [ 1 .. a ]  do
        for mat  in GeneratorsOfGroup( M )  do
            gen := KroneckerProduct
                   ( IdentityMat( m ^ ( b - 1 ), one ), mat );
            gen := KroneckerProduct
                   ( gen, IdentityMat( m ^ ( a - b ), one ) );
            Add( gens, gen );
        od;
    od;
    for gen  in GeneratorsOfGroup( SymmetricGroup( a ) )  do
        list := [  ];
        for p  in [ 0 .. n - 1 ]  do
            adic := [  ];
            for i  in [ 0 .. a - 1 ]  do
                adic[ ( a - i ) ^ gen ] := p mod m;
                p := QuoInt( p, m );
            od;
            q := 0;
            for i  in adic  do
                q := q * m + i;
            od;
            Add( list, q );
        od;
        Add( gens, id{ list + 1 } );
    od;
    G := GroupWithGenerators( gens );
    if HasName( M )  and  HasName( P )  then
        SetName( G, Concatenation( Name( M ), " twr ", Name( P ) ) );
    fi;
    return G;
end );


#############################################################################
##
#F  CentralProductOfMatrixGroups( <M>, <N> )  . . . . . . . . central product
##
BindGlobal( "CentralProductOfMatrixGroups", function( M, N )
    local   gens,  id,  mat,  G;

    gens := [  ];
    id := One( N );
    for mat  in GeneratorsOfGroup( M )  do
        Add( gens, KroneckerProduct( mat, id ) );
    od;
    id := One( M );
    for mat  in GeneratorsOfGroup( N )  do
        Add( gens, KroneckerProduct( id, mat ) );
    od;
    G := GroupWithGenerators( gens );
    if HasName( M )  and  HasName( N )  then
        SetName( G, Concatenation( Name( M ), " o ", Name( N ) ) );
    fi;
    return G;
end );
