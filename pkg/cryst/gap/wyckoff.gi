#############################################################################
##
#A  wyckoff.gi                Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##
##  Routines for the determination of Wyckoff positions
##

#############################################################################
##
#M  WyckoffPositionObject . . . . . . . . . . .make a Wyckoff position object
##
InstallGlobalFunction( WyckoffPositionObject, function( w )
    return Objectify( NewType( FamilyObj( w ), IsWyckoffPosition ), w );
end );

#############################################################################
##
#M  PrintObj . . . . . . . . . . . . . . . . . . . . . Print Wyckoff position
##
InstallMethod( PrintObj,
    "Wyckoff position", true, [ IsWyckoffPosition ], 0,
function( w )
    Print( "< Wyckoff position, point group ", w!.class, 
           ", translation := ", w!.translation, 
           ", \nbasis := ", w!.basis, " >\n" );
end );

#############################################################################
##
#M  ViewObj . . . . . . . . . . . . . . . . . . . . . View a Wyckoff position
##
InstallMethod( ViewObj,
    "Wyckoff position", true, [ IsWyckoffPosition ], 0,
function( w )
    Print( "< Wyckoff position, point group ", w!.class, 
           ", translation := ", w!.translation, 
           ", \nbasis := ", w!.basis, " >\n" );
end );

#############################################################################
##
#M  WyckoffSpaceGroup . . . . . . . . . . . . .space group of WyckoffPosition
##
InstallMethod( WyckoffSpaceGroup,
    true, [ IsWyckoffPosition ], 0, w -> w!.spaceGroup );

#############################################################################
##
#M  WyckoffTranslation . . . . . . . . . .translation of representative space
##
InstallMethod( WyckoffTranslation,
    true, [ IsWyckoffPosition ], 0, w -> w!.translation );

#############################################################################
##
#M  WyckoffBasis . . . . . . . . . . . . . . . .basis of representative space
##
InstallMethod( WyckoffBasis, 
    true, [ IsWyckoffPosition ], 0, w -> w!.basis );

#############################################################################
##
#M  ReduceAffineSubspaceLattice . . . . reduce affine subspace modulo lattice
##
InstallGlobalFunction( ReduceAffineSubspaceLattice, 
function( r )

    local rk, d, T, Ti, M, R, Q, Qi, P, v, j;

    r.basis := ReducedLatticeBasis( r.basis );
    rk := Length( r.basis );
    d  := Length( r.translation );
    T  := TranslationBasis( r.spaceGroup );
    Ti := T^-1;

    if rk = d then
        v := 0 * r.translation;
    elif rk > 0 then
        M := r.basis;
        v := r.translation;
        if not IsStandardAffineCrystGroup( r.spaceGroup ) then
            M := M * Ti;
            v := v * Ti;
        fi;

        # these three lines are faster than the other four
        Q := IdentityMat(d);
        RowEchelonFormT(TransposedMat(M),Q);
        Q := TransposedMat(Q);

        # R := NormalFormIntMat( TransposedMat( M ), 4 );
        # Q := TransposedMat( R.rowtrans );
        # R := NormalFormIntMat( M, 9 );
        # Q := R.coltrans; 

        Qi := Q^-1;
        P := Q{[1..d]}{[rk+1..d]} * Qi{[rk+1..d]};
        v := List( v * P, FractionModOne );
        if not IsStandardAffineCrystGroup( r.spaceGroup ) then
            v := v * T;
        fi;
    else
        v := VectorModL( r.translation, T );
    fi;
    r.translation := v;

end );

#############################################################################
##
#F  ImageAffineSubspaceLattice . . . .image of affine subspace modulo lattice
##
InstallGlobalFunction( ImageAffineSubspaceLattice, function( s, g )
    local d, m, t, b, r;
    d := Length( s.translation );
    m := g{[1..d]}{[1..d]};
    t := g[d+1]{[1..d]};
    b := s.basis;
    if not IsEmpty(b) then b := b * m; fi;
    r := rec( translation := s.translation * m + t,
              basis       := b,
              spaceGroup  := s.spaceGroup );
    ReduceAffineSubspaceLattice( r );
    return r;
end );

#############################################################################
##
#F  ImageAffineSubspaceLatticePointwise . . . . . . image of pointwise affine 
#F                                                    subspace modulo lattice
##
InstallGlobalFunction( ImageAffineSubspaceLatticePointwise, function( s, g )
    local d, m, t, b, L, r;
    d := Length( s.translation );
    m := g{[1..d]}{[1..d]};
    t := g[d+1]{[1..d]};
    b := s.basis;
    if not IsEmpty(b) then b := b * m; fi;
    L := TranslationBasis( s.spaceGroup );
    r := rec( translation := VectorModL( s.translation * m + t, L ),
              basis       := b,
              spaceGroup  := s.spaceGroup );
    return r;
end );

#############################################################################
##
#M  \= . . . . . . . . . . . . . . . . . . . . . . .for two Wyckoff positions 
##
InstallMethod( \=, IsIdenticalObj,
    [ IsWyckoffPosition, IsWyckoffPosition ], 0,
function( w1, w2 )
    local S, r1, r2, d, gens, U, rep;
    S := WyckoffSpaceGroup( w1 );
    if S <> WyckoffSpaceGroup( w2 ) then
        return false;
    fi;
    r1 := rec( translation := WyckoffTranslation( w1 ),
               basis       := WyckoffBasis( w1 ),
               spaceGroup  := WyckoffSpaceGroup( w1 ) );
    r2 := rec( translation := WyckoffTranslation( w2 ),
               basis       := WyckoffBasis( w2 ),
               spaceGroup  := WyckoffSpaceGroup( w2 ) );
    r1 := ImageAffineSubspaceLattice( r1, One(S) );
    r2 := ImageAffineSubspaceLattice( r2, One(S) );
    d := DimensionOfMatrixGroup( S ) - 1;
    gens := Filtered( GeneratorsOfGroup( S ),
                      x -> x{[1..d]}{[1..d]} <> One( PointGroup( S ) ) );
    U := SubgroupNC( S, gens );
    rep := RepresentativeAction( U, r1, r2, ImageAffineSubspaceLattice );
    return rep <> fail;
end );

#############################################################################
##
#M  \< . . . . . . . . . . . . . . . . . . . . . . .for two Wyckoff positions 
##
InstallMethod( \<, IsIdenticalObj,
    [ IsWyckoffPosition, IsWyckoffPosition ], 0,
function( w1, w2 )
    local S, r1, r2, d, gens, U, o1, o2;
    S := WyckoffSpaceGroup( w1 );
    if S <> WyckoffSpaceGroup( w2 ) then
        return S < WyckoffSpaceGroup( w2 );
    fi;
    r1 := rec( translation := WyckoffTranslation( w1 ),
               basis       := WyckoffBasis( w1 ),
               spaceGroup  := WyckoffSpaceGroup( w1 ) );
    r2 := rec( translation := WyckoffTranslation( w2 ),
               basis       := WyckoffBasis( w2 ),
               spaceGroup  := WyckoffSpaceGroup( w2 ) );
    r1 := ImageAffineSubspaceLattice( r1, One(S) );
    r2 := ImageAffineSubspaceLattice( r2, One(S) );
    d := DimensionOfMatrixGroup( S ) - 1;
    gens := Filtered( GeneratorsOfGroup( S ),
                      x -> x{[1..d]}{[1..d]} <> One( PointGroup( S ) ) );
    U := SubgroupNC( S, gens );
    o1 := Orbit( U, r1, ImageAffineSubspaceLattice );
    o2 := Orbit( U, r2, ImageAffineSubspaceLattice );
    o1 := Set( List( o1, x -> rec( t := x.translation, b := x.basis ) ) );
    o2 := Set( List( o2, x -> rec( t := x.translation, b := x.basis ) ) ); 
    return o1[1] < o2[1];
end );

#############################################################################
##
#M  WyckoffStabilizer . . . . . . . . . . .stabilizer of representative space
##
InstallMethod( WyckoffStabilizer,
    true, [ IsWyckoffPosition ], 0, 
function( w )
    local S, t, B, d, I, gen, U, r, new, n, g, v;
    S := WyckoffSpaceGroup( w );
    t := WyckoffTranslation( w );
    B := WyckoffBasis( w );
    d := Length( t );
    I := IdentityMat( d );
    gen := GeneratorsOfGroup( S );
    gen := Filtered( gen, g -> g{[1..d]}{[1..d]} <> I );
    if IsAffineCrystGroupOnLeft( S ) then
        gen := List( gen, TransposedMat );
    fi;
    U := AffineCrystGroupOnRight( gen, One( S ) );
    r := rec( translation := t, basis := B, spaceGroup := S );
    U := Stabilizer( U, r, ImageAffineSubspaceLatticePointwise );
    t := ShallowCopy( t );
    Add( t, 1 );
    gen := GeneratorsOfGroup( U );
    new := [];
    for g in gen do
        v := t * g - t;
        n := List( g, ShallowCopy );
        n[d+1] := g[d+1] - v;
        if n <> One( S ) then
            AddSet( new, n );
        fi;
    od;
    if IsAffineCrystGroupOnLeft( S ) then
        new := List( new, TransposedMat );
    fi;
    return SubgroupNC( S, new );
end );

#############################################################################
##
#M  WyckoffOrbit( w )  . . . . . . . . . orbit of pointwise subspace lattices
##
InstallMethod( WyckoffOrbit,
    true, [ IsWyckoffPosition ], 0,
function( w )
    local S, t, B, d, I, gen, U, r, o, s;
    S := WyckoffSpaceGroup( w );
    t := WyckoffTranslation( w );
    B := WyckoffBasis( w );
    d := Length( t );
    I := IdentityMat( d );
    gen := GeneratorsOfGroup( S );
    gen := Filtered( gen, g -> g{[1..d]}{[1..d]} <> I );
    if IsAffineCrystGroupOnLeft( S ) then
        gen := List( gen, TransposedMat );
    fi;
    U := AffineCrystGroupOnRight( gen, One( S ) );
    r := rec( translation := t, basis := B, spaceGroup  := S );
    o := Orbit( U, r, ImageAffineSubspaceLatticePointwise );
    s := List( o, x -> WyckoffPositionObject( 
                              rec( translation := x.translation, 
                                   basis       := x.basis, 
                                   spaceGroup  := w!.spaceGroup,
                                   class       := w!.class ) ) );
    return s;
end );

#############################################################################
##
#F  SolveOneInhomEquationModZ . . . . . . . .  solve one inhom equation mod Z
##
##  Solve the inhomogeneous equation
##
##            a x = b (mod Z).
##
##  The set of solutions is
##                    {0, 1/a, ..., (a-1)/a} + b/a.
##  Note that 0 < b <  1, so 0 < b/a and (a-1)/a + b/a < 1.
##
SolveOneInhomEquationModZ := function( a, b )
    return [0..a-1] / a + b/a;
end;

#############################################################################
##
#F  SolveInhomEquationsModZ . . . . .solve an inhom system of equations mod Z
##
##  If onRight = true, compute the set of solutions of the equation
##
##                           x * M = b  (mod Z).
##
##  If onRight = false, compute the set of solutions of the equation
##
##                           M * x = b  (mod Z).
##
##  RowEchelonFormT() returns a matrix Q such that Q * M is in row echelon
##  form.  This means that (modulo column operations) we have the equation
##         x * Q^-1 * D = b       with D a diagonal matrix.
##  Solving y * D = b we get x = y * Q.
##
SolveInhomEquationsModZ := function( M, b, onRight )

    local   Q,  j,  L,  space,  i,  v;
    
    b := ShallowCopy(b);
    if onRight = true then
        Q := IdentityMat( Length(M) );
        M := TransposedMat(M);
        M := RowEchelonFormVector( M,b );
    else
        Q := IdentityMat( Length(M[1]) );
    fi;

    while not IsDiagonalMat(M) do
        M := TransposedMat(M);
        M := RowEchelonFormT(M,Q);
        if not IsDiagonalMat(M) then
            M := TransposedMat(M);
            M := RowEchelonFormVector(M,b);
        fi;
    od;

    ##  Now we have D * y = b with  y =  Q * x

    ##  Check if we have any solutions modulo Z.
    for j in [Length(M)+1..Length(b)] do
        if not IsInt( b[j] ) then
            return [ [], [] ];
        fi;
    od;

    ##  Solve each line in D * y = b separately.
    L := List( [1..Length(M)], i->SolveOneInhomEquationModZ( M[i][i],b[i] ) );
    
    L := Cartesian( L );
    L := List( L, l->Concatenation( l,  0 * [Length(M)+1..Length(Q)] ) );
    L := List( L, l-> l * Q );

    L := List( L, l->List( l, q->FractionModOne(q) ) );
    
    return [ L, Q{[Length(M)+1..Length(Q)]} ];
end;

#############################################################################
##
#F  FixedPointsModZ  . . . . . . fixed points up to translational equivalence
##
##  This function takes a space group and computes the fixpoint spaces of
##  this group modulo the translation subgroup.  It is assumed that the
##  translation subgroup has full rank.
##
FixedPointsModZ := function( gens, d )
    local   I,  M,  b,  i,  g,  f,  F;
    
    #  Solve x * M + t = x modulo Z for all pairs (M,t) in the generators.
    #  This leads to the system
    #        x * [ M_1 M_2 ... ] = [ b_1 b_2 ... ]  (mod Z)

    M := List( [1..d], i->[] ); b := []; i := 0;
    I := IdentityMat(d+1);
    for g in gens do
        g := g - I;
        M{[1..d]}{[1..d]+i*d} := g{[1..d]}{[1..d]};
        Append( b, -g[d+1]{[1..d]} );
        i := i+1;
    od;

    # Catch trivial case
    if Length(M[1]) = 0 then M := List( [1..d], x->[0] ); b := [0]; fi;
    
    ##  Compute the spaces of points fixed modulo translations.
    F := SolveInhomEquationsModZ( M, b, true );
    return List( F[1], f -> rec( translation := f, basis := F[2] ) );

end;
    
#############################################################################
##
#F  IntersectionsAffineSubspaceLattice( <U>, <V> )
##
IntersectionsAffineSubspaceLattice := function( U, V )

    local T, m, t, Ti, s, b, lst, x, len, tt;

    T  := TranslationBasis( U.spaceGroup );
    m  := Concatenation( U.basis, -V.basis );
    t  := V.translation - U.translation;
    Ti := T^-1;

    s  := SolveInhomEquationsModZ( m*Ti, t*Ti, true );

    if s[1] = [] then
        return fail;
    fi;

    b := IntersectionModule( U.basis, -V.basis );

    lst := [];
    for x in s[1] do
        tt := x{[1..Length(U.basis)]} * U.basis + U.translation;
        Add( lst, rec( translation := tt, basis := b, 
                       spaceGroup  := U.spaceGroup ) );
    od;

    for x in lst do
        ReduceAffineSubspaceLattice( x );
    od;

    return lst;

end;

#############################################################################
##
#F  IsSubspaceAffineSubspaceLattice( <U>, <V> )  repres. of V contained in U?
##
IsSubspaceAffineSubspaceLattice := function( U, V ) 
    local s;
    s := IntersectionsAffineSubspaceLattice( U, V );
    if s = fail then
        return false;
    else
        return V in s;
    fi;
end;

#############################################################################
##
#F  WyPos( S, stabs, lift ) . . . . . . . . . . . . . . . . Wyckoff positions
##
WyPos := function( S, stabs, lift )

    local d, W, T, i, lst, w, dim, a, s, r, new, orb, I, gen, U, c; 

    # get representative affine subspace lattices
    d := DimensionOfMatrixGroup( S ) - 1;
    W := List( [0..d], i -> [] );
    T := TranslationBasis( S );
    for i in [1..Length(stabs)] do
        lst := List( GeneratorsOfGroup( stabs[i] ), lift );
        if IsAffineCrystGroupOnLeft( S ) then
            lst := List( lst, TransposedMat );
        fi;
        lst := FixedPointsModZ( lst, d ); 
        for w in lst do
            dim := Length( w.basis ) + 1; 
            w.translation := w.translation * T;
            w.basis       := w.basis * T;
            w.spaceGroup  := S;
            w.class       := i;
            ReduceAffineSubspaceLattice( w );
            Add( W[dim], w );
        od;
    od;

    # eliminate multiple copies
    I := IdentityMat( d );
    gen := Filtered( GeneratorsOfGroup( S ), g -> g{[1..d]}{[1..d]} <> I );
    if IsAffineCrystGroupOnLeft( S ) then
        gen := List( gen, TransposedMat );
    fi;
    U := AffineCrystGroupOnRight( gen, One( S ) );
    for i in [1..d+1] do
        lst := ShallowCopy( W[i] );
        new := [];
        while lst <> [] do
            s := lst[1];
            c := s.class;
            Unbind( s.class );
            orb := Orbit( U, Immutable(s), ImageAffineSubspaceLattice );
            lst := Filtered( lst, 
                   x -> not rec( translation := x.translation,
                                 basis       := x.basis,
                                 spaceGroup  := x.spaceGroup   ) in orb );
            s.class := c;
            Add( new, WyckoffPositionObject( s ) );
        od;
        W[i] := new;
    od;
    return Flat( W );

end; 

#############################################################################
##
#F  WyPosSGL( S ) . . . Wyckoff positions via subgroup lattice of point group 
##
WyPosSGL := function( S )

    local P, N, lift, stabs, W;

    # get point group P, and its nice representation N
    P := PointGroup( S );
    N := NiceObject( P );

    # set up lift from nice rep to std rep
    lift  := x -> NiceToCrystStdRep( P, x );
    stabs := List( ConjugacyClassesSubgroups( N ), Representative );
    Sort( stabs, function(x,y) return Size(x) > Size(y); end );

    # now get the Wyckoff positions
    return WyPos( S, stabs, lift );

end;

#############################################################################
##
#F  WyPosStep . . . . . . . . . . . . . . . . . . .induction step for WyPosAT 
##
WyPosStep := function( idx, G, M, b, lst )

    local g, G2, M2, b2, F, c, added, stop, f, d, w, O;

    g := lst.z[idx];
    if not g in G then
        G2 := ClosureGroup( G, g );
        M2 := Concatenation( M, lst.mat[idx] );
        b2 := Concatenation( b, lst.vec[idx] );
        if M <> [] then
            M2 := RowEchelonFormVector( M2, b2 );
        fi;
        if ForAll( b2{[Length(M2)+1..Length(b2)]}, IsInt ) then
            b2 := b2{[1..Length(M2)]};
            F := SolveInhomEquationsModZ( M2, b2, false );
            F := List( F[1], f -> rec( translation := f, basis := F[2] ) );
        else
            F := [];
        fi;
        c := lst.c + 1;
        added := false;
        for f in F do
            d := Length( f.basis ) + 1; 
            stop := d=lst.dim+1;
            f.translation := f.translation * lst.T;
            if not IsEmpty( f.basis ) then
                f.basis   := f.basis * lst.T;
            fi;
            f.spaceGroup  := lst.S;
            ReduceAffineSubspaceLattice( f );
            if not f in lst.sp[d] then
                O := Orbit( lst.S2, Immutable(f), ImageAffineSubspaceLattice );
                w := ShallowCopy( f );
                w.class := c;
                UniteSet( lst.sp[d], O );
                Add( lst.W[d], WyckoffPositionObject(w) );
                added := true;
            fi;
        od;
        if added and not stop then
            lst.c := lst.c+1;
            if idx < Length(lst.z) then
                WyPosStep( idx+1, G2, M2, b2, lst );
            fi;
        fi;
    fi;
    if idx < Length(lst.z) then
        WyPosStep( idx+1, G, M, b, lst );
    fi;

end;

#############################################################################
##
#F  WyPosAT( S ) . . . . Wyckoff positions with recursive method by Ad Thiers 
##
WyPosAT := function( S )

    local d, P, gen, S2, lst, zz, mat, vec, g, m, M, b, s, w;

    d := DimensionOfMatrixGroup(S)-1;
    P := PointGroup( S );
    gen := Filtered( GeneratorsOfGroup(S), x -> x{[1..d]}{[1..d]} <> One(P) );
    S2 := Subgroup( S, gen );
    if IsAffineCrystGroupOnLeft( S ) then
        S2 := TransposedMatrixGroup( S2 );
    fi;
    
    lst := rec( dim := d, T := TranslationBasis(S), S := S, c := 1,
                S2 := S2 );

    zz := []; mat := []; vec := [];
    for g in Zuppos( NiceObject( P ) ) do
        if g <> () then
            m := NiceToCrystStdRep(P,g);
            if IsAffineCrystGroupOnRight( S ) then
                m := TransposedMat(m);
            fi;
            M := m{[1..d]}{[1..d]}-IdentityMat(d);
            b := m{[1..d]}[d+1];
            M := RowEchelonFormVector(M,b);
            if ForAll( b{[Length(M)+1..Length(b)]}, IsInt ) then
                Add( zz,  g );
                Add( mat, M );
                Add( vec, -b{[1..Length(M)]} );
            fi;
        fi;
    od;
    lst.z   := zz;
    lst.mat := mat;
    lst.vec := vec;

    s := rec( translation := ListWithIdenticalEntries(d,0),
              basis       := TranslationBasis(S),
              spaceGroup  := S );
    ReduceAffineSubspaceLattice(s);
    lst.sp := List( [1..d+1], x-> [] ); Add( lst.sp[d+1], s );

    w := ShallowCopy( s );
    w.class := 1;
    w := WyckoffPositionObject( w );
    lst.W := List( [1..d+1], x -> [] ); Add( lst.W[d+1], w );

    if 1 <= Length(lst.z) then
        WyPosStep(1,TrivialGroup(IsPermGroup),[],[],lst);
    fi;

    return Flat(lst.W);

end;

#############################################################################
##
#M  WyckoffPositions( S ) . . . . . . . . . . . . . . . . . Wyckoff positions 
##
InstallMethod( WyckoffPositions, "for AffineCrystGroupOnLeftOrRight", 
    true, [ IsAffineCrystGroupOnLeftOrRight ], 0,
function( S )

    # check if we indeed have a space group
    if not IsSpaceGroup( S ) then
        Error("S must be a space group");
    fi;

    # for small dimensions, the recursive method is faster
    if DimensionOfMatrixGroup( S ) < 6 then
        return WyPosAT( S );
    else
        return WyPosSGL( S );
    fi;

end );

#############################################################################
##
#M  WyckoffPositionsByStabilizer( S, stabs ) . . Wyckoff pos. for given stabs 
##
InstallGlobalFunction( WyckoffPositionsByStabilizer, function( S, stb )

    local stabs, P, lift;

    # check the arguments
    if not IsSpaceGroup( S ) then
        Error( "S must be a space group" );
    fi;
    if IsGroup( stb ) then
        stabs := [ stb ];
    else
        stabs := stb;
    fi;

    # get point group P
    P := PointGroup( S );

    # set up lift from nice rep to std rep
    lift  := x -> NiceToCrystStdRep( P, x );
    stabs := List( stabs, x -> Image( NiceMonomorphism( P ), x ) );
    Sort( stabs, function(x,y) return Size(x) > Size(y); end );

    # now get the Wyckoff positions
    return WyPos( S, stabs, lift );

end );

#############################################################################
##
#M  WyckoffGraphFun( S, def ) . . . . . . . . . . . . display a Wyckoff graph 
##
InstallMethod( WyckoffGraph, true, 
    [ IsAffineCrystGroupOnLeftOrRight, IsRecord ], 0,
function( S, def )
    return WyckoffGraphFun( WyckoffPositions( S ), def );
end );

InstallOtherMethod( WyckoffGraph, true, 
    [ IsAffineCrystGroupOnLeftOrRight ], 0,
function( S )
    return WyckoffGraphFun( WyckoffPositions( S ), rec() );
end );

InstallOtherMethod( WyckoffGraph, true, 
    [ IsList, IsRecord ], 0,
function( L, def )
    if not ForAll( L, IsWyckoffPosition ) then
       Error("L must be a list of Wyckoff positions of the same space group");
    fi;
    return WyckoffGraphFun( L, def );
end );

InstallOtherMethod( WyckoffGraph, true, 
    [ IsList ], 0,
function( L )
    if not ForAll( L, IsWyckoffPosition ) then
       Error("L must be a list of Wyckoff positions of the same space group");
    fi;
    return WyckoffGraphFun( L, rec() );
end );



