#############################################################################
##
#W  primitiv.gi                 GAP group library              Heiko Thei"sen
##
#H  @(#)$Id$
##
Revision.primitiv_gi :=
    "@(#)$Id$";

#############################################################################
##
#F  RepOpSuborbits( <G>, <subs>, <a>, <b> ) . . . . . . . . . .  on suborbits
##
RepOpSuborbits := function( G, subs, a, b )
    local   G1,  B1,  B2,  O,  S,  rbase,  Q;

    G1 := Stabilizer( G, Position( subs.blists[ 1 ], true ) );
    B1 := OrbitalPartition( subs, a );
    B2 := OrbitalPartition( subs, b );
    O  := OrbitsPartition( G, subs.domain );
    S  := SymmetricGroup( Length( subs.domain ) );
    rbase := RBaseGroupsBloxPermGroup( [ B1, B2 ], S, subs.domain,
                     G, O );
    Q := CollectedPartition( O, Size( G ) );
    StratMeetPartition( Q, B2 );
    return PartitionBacktrack( S, gen -> ForAll( GeneratorsOfGroup( G ), g ->
                   g ^ gen in G ), true, rbase, [ Q, G, G, O ],
                   Stabilizer( G1, Position( subs.blists[ a ], true ) ),
                   Stabilizer( G1, Position( subs.blists[ b ], true ) ) );
end;

#############################################################################
##
#F  OnSuborbits( <k>, <g>, <subs> ) . . . . . . . . .  operation on suborbits
##
OnSuborbits := function( k, g, subs )
    local   rep,  img,  s;
    
    rep := Position( subs.blists[ k ], true );
    img := rep ^ g;
    for s  in InverseRepresentativeWord( subs.stabChain,
            BasePoint( subs.stabChain ) ^ g )  do
        img := img ^ s;
    od;
    return subs.which[ img ];
end;

#############################################################################
##
#F  ConstructCohort( <N>, <G>, <Omega> )  . . . . . . . . . . . . . . . local
##
ConstructCohort := function( N, G, Omega )
    local   A,  gens,  gen,  coh,  lens,  opr,  i;

    coh := NaturalHomomorphismByNormalSubgroup( N, G );
    coh!.suborbitsSocle := Suborbits( G, [  ], 1, Omega, 1 );

    # Find the operation of <N> on the suborbits.
    lens := List( coh!.suborbitsSocle.blists, SizeBlist );
    coh!.actionOnSuborbits := [  ];
    opr := function( p, g )
        return OnSuborbits( p, g, coh!.suborbitsSocle );
    end;
    for gen  in GeneratorsOfGroup( Range( coh ) )  do
        Add( coh!.actionOnSuborbits,
             Permutation( PreImagesRepresentative( coh, gen ),
                     [ 1 .. Length( lens ) ], opr ) );
    od;
    coh!.subdegrees := List( Orbits( N,
        [ 1 .. Length( coh!.suborbitsSocle.blists ) ], opr ),
        orb -> lens{ orb } );

    return coh;
end;

#############################################################################
##
#F  CohortOfGroup( <G> )  . . . . . . . . . . . . . . . . . . . . . .  cohort
##
CohortOfGroup := function( G )
    local   Omega,  S,  N;
    
    Omega := MovedPoints( G );
    S := SymmetricGroup( Omega );
    if IsBound( G!.normalizer )  then
        N := AsSubgroup( S, G!.normalizer );
    else
        N := Normalizer( S, G );
    fi;
    if IsRegular( G, Omega )  then
        G := ClosureGroup( G, Centralizer( S, G ) );
    fi;
    return ConstructCohort( N, G, Omega );
end;

#############################################################################
##
#F  MakeCohort( <gens>, <out> ) . . . . . . . . . . . . . . . . make a cohort
##
MakeCohort := function( gens, out )
    local   S,  i,  N,  G,  Omega;
    
    G := GroupByGenerators( gens{ [ out + 1 .. Length( gens ) ] } );
    S := StructuralCopy( StabChainAttr( G ) );
    for i  in Reversed( [ 1 .. out ] )  do
        AddNormalizingElementPcgs( S, gens[ i ] );
    od;
    N := GroupStabChain( S );
    Omega := MovedPoints( G );
    return ConstructCohort( N, G, Omega );
end;
    
#############################################################################
##
#F  AlternatingCohortOnSets( <n>, <k> ) . . . . . . .  for alternating groups
##
AlternatingCohortOnSets := function( n, k )
    local   A,  orb,  G,  out,  coh;
    
    A := AlternatingGroup( n );
    orb := Combinations( [ 1 .. n ], k );
    G := Operation( A, orb, OnSets );
    out := Permutation( (1,2), orb, OnSets );
    G!.normalizer := ClosureGroup( G, out );
    coh := CohortOfGroup( G );
    SetName( coh, Concatenation( "A", String( n ), " on ", String( k ),
            "-sets" ) );
    return coh;
end;

#############################################################################
##
#F  LinearCohortOnProjectivePoints( <n>, <q> )  . . . . . . . . linear cohort
##
LinearCohortOnProjectivePoints := function( n, q )
    local   fld,  pro,  gens,  M,  coh;
    
    fld := GF( q );
    pro := ProjectiveSpace( fld ^ n );
    gens := GeneratorsOfGroup( Operation( SL( n, q ), pro ) );
    M := MutableIdentityMat( n, fld );
    M[ 1 ][ 1 ] := PrimitiveRoot( fld );
    coh := MakeCohort( Concatenation( [
        Permutation( FrobeniusAutomorphism( fld ), pro, OnTuples ),
        Permutation( M, pro ) ], gens ), 2 );
    SetName( coh, Concatenation( "L", String( n ), ",", String( q ),
            " on projective points" ) );
    return coh;
end;

#############################################################################
##
#F  SymplecticCohortOnProjectivePoints( <n>, <q> )  . . . . symplectic cohort
##
SymplecticCohortOnProjectivePoints := function( n, q )
    local   fld,  pro,  gens,  M,  coh,  i;
    
    fld := GF( q );
    pro := ProjectiveSpace( fld ^ n );
    gens := GeneratorsOfGroup( Operation( Sp( n, q ), pro ) );
    if q mod 2 = 0  then
        M := PrimitiveRoot( fld );
    else
        M := MutableIdentityMat( n, fld );
        for i  in [ 1 .. n / 2 ]  do
            M[ i ][ i ] := PrimitiveRoot( fld );
        od;
    fi;
    coh := MakeCohort( Concatenation( [
        Permutation( FrobeniusAutomorphism( fld ), pro, OnTuples ),
        Permutation( M, pro, OnRight ) ], gens ), 2 );
    SetName( coh, Concatenation( "S", String( n ), ",", String( q ),
            " on projective points" ) );
    return coh;
end;

#############################################################################
##
#F  UnitaryCohortOnProjectivePoints( <n>, <q>, <iso> )  . . .  unitary cohort
##
UnitaryCohortOnProjectivePoints := function( n, q, iso )
    local   G,  id,  fld,  z,    # <z> = fld^*
                           zeta, # zeta + zeta ^ q = 1
                           imag, # imag ^ (q+1) = -1
            X,  facs,  pro,  v,  gens,  M,  P,  i,  coh;

    G := SU( n, q );  id := One( G );
    fld := GF( q ^ 2 );  z := PrimitiveRoot( fld );
    M := List( id, ShallowCopy );
    M[ 1 ][ 1 ] := z ^ ( q - 1 );
    if q mod 2 = 0  then
        X := Indeterminate( fld );
        facs := Factors( PolynomialRing( fld ), X ^ q + X + X ^ 0 );
        Sort( facs, function( f1, f2 )
            return DegreeOfUnivariateLaurentPolynomial( f1 ) <
                   DegreeOfUnivariateLaurentPolynomial( f2 );
        end );
        zeta := Value( facs[ 1 ], Zero( fld ) );
        imag := 1;
    else
        zeta := One( fld ) / 2;
        imag := z ^ ( ( q - 1 ) / 2 );
    fi;
    P := ShallowCopy( id );
    for i  in [ 1 .. QuoInt( n, 2 ) ]  do
        P[ i ] := zeta * id[ i ] + id[ n + 1 - i ];
        P[ n + 1 - i ] := ( zeta ^ q * id[ i ] - id[ n + 1 - i ] ) * imag;
    od;
    M := M ^ P;
    pro := ProjectiveSpace( fld ^ n );
    if iso  then  v := id[ 1 ];
            else  v := P[ 1 ];   fi;
    pro := ExternalOrbit( G, pro, v );
    gens := GeneratorsOfGroup( Operation( G, pro ) );
    coh := MakeCohort( Concatenation( [
        Permutation( FrobeniusAutomorphism( fld ), pro, OnTuples ),
        Permutation( z, pro, OnRight ),
        Permutation( M, pro ) ], gens ), 3 );
    if iso  then  iso := "";
            else  iso := "non-";  fi;
    SetName( coh, Concatenation( "U", String( n ), ",", String( q ),
            " on ", iso, "isotropic projective points" ) );
    return coh;
end;

#############################################################################
##
#F  CohortProductAction( <coh> )  . . . . . . . . . . . . . . .  product type
##
CohortProductAction := function( coh, n )
    local   S,  N,  G,  prd;
    
    S := SymmetricGroup( n );
    N := WreathProductProductAction( Source( coh ), S );
    G := WreathProductProductAction( KernelOfMultiplicativeGeneralMapping
                 ( coh ), TrivialSubgroup( S ) );
    prd := ConstructCohort( N, G, MovedPoints( G ) );
    SetName( prd, Concatenation( Name( coh ), "^", String( n ) ) );
    return prd;
end;

CohortPowerAlternating := function( m, n )
    return CohortProductAction( AlternatingCohortOnSets( m, 1 ), n );
end;

CohortPowerLinear := function( d, q, n )
    return CohortProductAction( LinearCohortOnProjectivePoints( d, q ), n );
end;

#############################################################################
##
#F  CohortDiagonalAction( <G> ) . . . . . . . . . . . . . . . diagonal action
##
CohortDiagonalAction := function( G )
    local   coh,  T,  T_,  gens,  gen,  imgs,  N,  hom;
    
    hom := OperationHomomorphism( G, G, OnRight );
    SetIsInjective( hom, true );
    coh := CohortOfGroup( Image( hom ) );
    T := GeneratorsOfGroup( Image( hom ) );
    T_ := GeneratorsOfGroup( Operation( G, G, OnLeftInverse ) );
    gens := Concatenation( T, T_ );
    Add( gens, AutomorphismByConjugation( [ 1 .. Size( G ) ],
            Concatenation( T, T_ ), Concatenation( T_, T ) ) );
    for gen  in GeneratorsOfGroup( Image( coh ) )  do
        gen := PreImagesRepresentative( coh, gen );
        imgs := OnTuples( T, gen );
        Add( gens, AutomorphismByConjugation( [ 1 .. Size( G ) ],
                Concatenation( T, T_ ),
                Concatenation( imgs, List( imgs,
                        i -> Permutation( PreImagesRepresentative( hom, i ),
                                G, OnLeftInverse ) ) ) ) );
    od;
    N := GroupByGenerators( gens );
    G := Subgroup( N, Concatenation( T, T_ ) );
    coh := ConstructCohort( N, G, [ 1 .. Size( G ) ] );
    SetName( coh, "<diagonal action>" );
    return coh;
end;

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##

#F  AffinePermGroupByMatrixGroup( <M> ) . . . . . . . . . . affine perm group
##
AffinePermGroupByMatrixGroup := function( M )
    local   V,  G,  E,  A;
    
    # build the vector space
    V := FieldOfMatrixGroup( M ) ^ DimensionOfMatrixGroup( M );
    
    # the linear part
    G := Operation( M, V );
    
    # the translation part
    E := GroupByGenerators( List( Basis( V ), b ->
                 Permutation( b, V, \+ ) ) );
    SetSize( E, Size( V ) );
    
    # construct the affine group
    A := GroupByGenerators( Concatenation
                 ( GeneratorsOfGroup( G ), GeneratorsOfGroup( E ) ) );
    SetSize( A, Size( M ) * Size( V ) );
    Setter( EarnsAttr )( A, E );
    if HasName( M )  then
        SetName( A, Concatenation( String( Size( FieldOfMatrixGroup( M ) ) ),
                "^", String( DimensionOfMatrixGroup( M ) ), ":",
                Name( M ) ) );
    fi;
    A!.matrixGroup := M;
    return A;
end;

#############################################################################
##
#F  PrimitiveAffinePermGroupByMatrixGroup( <M> )  primitive affine perm group
##
PrimitiveAffinePermGroupByMatrixGroup := function( M )
    local   V,  G,  E,  A;
    
    V := FieldOfMatrixGroup( M ) ^ DimensionOfMatrixGroup( M );
    G := Operation( M, V );
    E := GroupByGenerators( List( Basis( V ), b ->
                 Permutation( b, V, \+ ) ) );
    SetSize( E, Size( V ) );
    A := GroupByGenerators( Concatenation
                 ( GeneratorsOfGroup( G ), [ GeneratorsOfGroup( E )[1] ] ) );
    SetSize( A, Size( M ) * Size( V ) );
    Setter( EarnsAttr )( A, E );
    if HasName( M )  then
        SetName( A, Concatenation( String( Size( FieldOfMatrixGroup( M ) ) ),
                "^", String( DimensionOfMatrixGroup( M ) ), ":",
                Name( M ) ) );
    fi;
    A!.matrixGroup := M;
    return A;
end;

#############################################################################
##
#F  GLnbylqtolInGLnq( <M>, <k> )  . . . . . . . . . . .  for field extensions
##
GLnbylqtolInGLnq := function( M, k )
    local   d,  q,  l,  b,  gens,  x,  new,  y,  z,  row,  G;

    # construct a base for GF(q^k) / GF(q)
    d := DimensionOfMatrixGroup( M );
    q := RootInt( Size( FieldOfMatrixGroup( M ) ), k );
    l := GF(GF(q),k);
    b := Basis(l);

    # now blow up the generators
    gens := [];
    for x  in GeneratorsOfGroup( M )  do
        new := [];
        for y  in x  do
            for z  in b  do
                row := List( y*z, t -> Coefficients(b,t) );
                row := Concatenation(row);
                Add( new, row );
            od;
        od;
        Add( gens, new );
    od;

    # and return
    G := GroupByGenerators( gens );
    if HasName( M )  then
        SetName( G, Concatenation( Name( M ), " < GL(", String( d * k ),
                ",", String( q ), ")" ) );
    fi;
    if HasSize( M )  or
       HasIsGeneralLinearGroup( M ) and IsGeneralLinearGroup( M )  then
        SetSize( G, Size( M ) );
    fi;
    return G;

end;

#############################################################################
##
#F  FrobInGLnq( <M>, <k> )  . . . . . . . . . . . . . .  for field extensions
##
FrobInGLnq := function( M, k )
    local   d,  q,  l,  b,  new,  row,  frb,  z,  x;
    
    # construct a base for GF(q^k) / GF(q)
    d := DimensionOfMatrixGroup( M );
    q := RootInt( Size( FieldOfMatrixGroup( M ) ), k );
    l := GF(GF(q),k);
    b := Basis(l);

    # construct the frobenius
    new := List( 0 * IdentityMat( d * k, FieldOfMatrixGroup( M ) ),
                 ShallowCopy );
    frb := [];
    for z  in b  do
        Add( frb, Coefficients( b, z^q ) );
    od;
    for x  in [ 0 .. d-1 ]  do
        new{[x*k+1..x*k+k]}{[x*k+1..x*k+k]} := frb;
    od;
    return new;
end;

#############################################################################
##
#F  StabFldExt( <M>, <k> )  . . . . . . . . . . . . . .  for field extensions
##
StabFldExt := function( M, k )
    local   G;
    
    G := GroupByGenerators( Concatenation
	( GeneratorsOfGroup( GLnbylqtolInGLnq( M, k ) ),
          [ FrobInGLnq( M, k ) ] ) );
    if HasName( M )  then
        SetName( G, Concatenation( Name( M ), ":", String( k ),
                " < GL(", String( DimensionOfMatrixGroup( M ) * k ), ",",
                String( RootInt( Size( FieldOfMatrixGroup( M ) ), k ) ),
                ")" ) );
    fi;
    if HasSize( M )  or
       HasIsGeneralLinearGroup( M ) and IsGeneralLinearGroup( M )  then
        SetSize( G, Size( M ) * k );
    fi;
    return G;
end;

#############################################################################
##

#A  PerfectResiduum( <G> )  . . . . . . . . . . . . . . . .  perfect residuum
##
InstallMethod( PerfectResiduum, true, [ IsGroup ], 0,
    function( G )
    local   P;
    
    P := AsSubgroup( G, DerivedSeriesOfGroup( G )
                 [ Length( DerivedSeriesOfGroup( G ) ) ] );
    if HasName( G )  then
        SetName( P, Concatenation( Name( G ), "^\infty" ) );
    fi;
    return P;
end );

#############################################################################
##
#F  AlmostDerivedSubgroup( <G>, <nr> )  . . . . . . .  between G and G^\infty
##
AlmostDerivedSubgroup := function( G, nr )
    local   hom,  U;
    
    hom := NaturalHomomorphismByNormalSubgroupInParent
           ( PerfectResiduum( G ) );
    U := PreImage( hom, Representative
                 ( ConjugacyClassesSubgroups( Image( hom ) )[ nr ] ) );
    if HasName( G )  then
        SetName( U, Concatenation( Name( G ), "_", String( nr ) ) );
    fi;
    return U;
end;

#############################################################################
##
#F  Rank( <arg> ) . . . . . . . . . . . . . . . . . . . . number of suborbits
##
Rank := function( arg )
    return AttributeOperation( RankOp, RankAttr, false, arg );
end;

InstallMethod( RankOp, true, OrbitsishReq, 0,
    function( G, D, gens, oprs, opr )
    local   hom;
    
    hom := OperationHomomorphism( G, D, gens, oprs, opr );
    return Rank( Image( hom ), [ 1 .. Length( D ) ] );
end );

InstallMethod( RankOp,
        "G, ints, gens, perms, opr", true,
        [ IsGroup, IsList and IsCyclotomicsCollection,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, gens, oprs, opr )
    if    opr <> OnPoints
       or not IsIdentical( gens, oprs )  then
        TryNextMethod();
    fi;
    return Length( Orbits( Stabilizer( G, D, D[ 1 ], opr ),
                   D, opr ) );
end );

InstallMethod( RankOp,
        "G, [  ], gens, perms, opr", true,
        [ IsGroup, IsList and IsEmpty,
          IsList,
          IsList,
          IsFunction ], SUM_FLAGS,
    function( G, D, gens, oprs, opr )
    return 0;
end );

#############################################################################
##
#V  AFFINE_NON_SOLVABLE_GROUPS  . . . . . . . . . . . . . . . of degree < 256
##
AFFINE_NON_SOLVABLE_GROUPS := [  ];
    
BOOT_AFFINE_NON_SOLVABLE_GROUPS := function()
    local   ASLMaker,  p,  hom,  nr;
    
    AFFINE_NON_SOLVABLE_GROUPS[ 2 ^ 3 ] := [ function() return
      PrimitiveAffinePermGroupByMatrixGroup( GL( 3, 2 ) );
    end ];
    AFFINE_NON_SOLVABLE_GROUPS[ 2 ^ 5 ] := [ function() return
      PrimitiveAffinePermGroupByMatrixGroup( GL( 5, 2 ) );
    end ];
    AFFINE_NON_SOLVABLE_GROUPS[ 2 ^ 7 ] := [ function() return
      PrimitiveAffinePermGroupByMatrixGroup( GL( 7, 2 ) );
    end ];
    
    ASLMaker := function( n, q, nr )
        return function()
            return PrimitiveAffinePermGroupByMatrixGroup
                   ( AlmostDerivedSubgroup( GL( n, q ), nr ) );
        end;
    end;
    
    for p  in [ [3,3], [5,2], [5,3], [7,2], [7,3], [11,2], [13,2] ]  do
        AFFINE_NON_SOLVABLE_GROUPS[ p[1] ^ p[2] ] := [  ];
        hom := NaturalHomomorphismByNormalSubgroup( GL( p[2], p[1] ),
                                                    SL( p[2], p[1] ) );
        for nr  in Reversed
          ( [ 1 .. Length( ConjugacyClassesSubgroups( Range(hom) ) ) ] )  do
            AFFINE_NON_SOLVABLE_GROUPS[p[1]^p[2]][nr] :=
              ASLMaker(p[2],p[1],nr);
        od;
    od;
end;

#############################################################################
##
#F  Cohort( <deg>, <c> )  . . . . . . . . . . . . . . . . . non-affine cohort
##
Cohort := function( deg, c )
    local   bin,  n,  m,  q,  pro;

    if IsEmpty( COHORTS )  then
        ReadPrim( "cohorts.grp" );
    fi;
    if not deg in COHORTS_DONE  then
        AddSet( COHORTS_DONE, deg );
        if not IsBound( COHORTS[ deg ] )  then
            COHORTS[ deg ] := [  ];
        fi;
        
        # Add alternating cohorts on sets.
        for n  in [ 5 .. deg ]  do
            for m  in [ 2 .. QuoInt( n - 1, 2 ) ]  do
                bin := Binomial( n, m );
                if   bin > deg  then  break;
                elif bin = deg  then
                    Add( COHORTS[ deg ],
                         [ AlternatingCohortOnSets, [ n, m ] ] );
                fi;
            od;
        od;
        
        # Add linear cohorts on projective points.
        for n  in [ 2 .. 10 ]  do
            if 2 ^ n - 1 > deg  then  break;
            elif n = 2          then  q := 5;
                                else  q := 2;  fi;
            for q  in [ q .. deg ]  do  if IsPrimePowerInt( q )  then
                pro := ( q ^ n - 1 ) / ( q - 1 );
                if   pro > deg  then  break;
                elif pro = deg  then
                    Add( COHORTS[ deg ],
                         [ LinearCohortOnProjectivePoints, [ n, q ] ] );
                fi;
            fi;  od;
        od;

        # Add product type alternating and linear cohorts.
        for n  in [ 2 .. 4 ]  do
            m := RootInt( deg, n );
            if m ^ n = deg  then
                if m > 5  then  # A_5 = L_2(4)
                    Add( COHORTS[ deg ],
                         [ CohortPowerAlternating, [ m, n ] ] );
                fi;
                if m > 4  and  IsPrimePowerInt( m - 1 )  then
                    Add( COHORTS[ deg ],
                         [ CohortPowerLinear, [ 2, m - 1, n ] ] );
                fi;
            fi;
        od;
        
    fi;
    
    if c > Length( COHORTS[ deg ] )  then
        return Length( COHORTS[ deg ] );
    elif IsString( COHORTS[ deg ][ c ] )  then
        ReadPrim( Concatenation( "cohorts/", COHORTS[ deg ][ c ],
                ".", String( deg ) ) );
        SetName( coh, Concatenation( COHORTS[ deg ][ c ],
                "#", String( deg ) ) );
        COHORTS[ deg ][ c ] := coh;
    elif not IsGeneralMapping( COHORTS[ deg ][ c ] )  then
        if IsString( COHORTS[ deg ][ c ][ 1 ] )  then
            ReadPrim( Concatenation( "cohorts/",
                    COHORTS[ deg ][ c ][1],
                    ".", String( deg ), COHORTS[ deg ][ c ][ 2 ] ) );
            SetName( coh, Concatenation( COHORTS[ deg ][ c ][ 1 ],
                    "#", String( deg ), COHORTS[ deg ][ c ][ 2 ] ) );
            COHORTS[ deg ][ c ] := coh;
        elif IsFunction( COHORTS[ deg ][ c ][ 1 ] )  then
            COHORTS[ deg ][ c ] := CallFuncList( COHORTS[ deg ][ c ][ 1 ],
                                                 COHORTS[ deg ][ c ][ 2 ] );
        fi;
    fi;
    return COHORTS[ deg ][ c ];
end;

#############################################################################
##
#F  PrimitiveGroup( <deg>, <nr> ) . . . . . . . . .  primitive group selector
##
MakePrimitiveGroup := function( deg, nr )
    local   G,  p,  n,  div,  nrcs,  c,  cls,  coh,  num,  tmp;

    if   deg = 1  then  num := 1;
    elif deg > 4  then  num := 2;  # for alternating and symmetric group
                  else  num := 0;  fi;
    
    # For prime power degrees < 256, look at the affine groups.
    if deg < 256  and  IsPrimePowerInt( deg )  then
        p := FactorsInt( deg )[ 1 ];
        n := LogInt( deg, p );
        
        # Mark Short does not deal with the one-dimensional case.
        if n = 1  then
            div := DivisorsInt( p - 1 );
            if nr <= Length( div )  then
                G := PrimitiveAffinePermGroupByMatrixGroup
                  ( Group( [ [ PrimitiveRoot( GF( p ) ) ^
                             div[ Length( div ) + 1 - nr ] ] ] ) );
                Setter( IsPrimitiveAffineProp )( G, true );
                return G;
            else
                if nr = infinity  then  num := num + Length( div );
                                  else  nr := nr - Length( div );  fi;
            fi;
            
        else
            if nr <= Length( IrredSolGroupList[ n ][ p ] )  then
                G := PrimitiveAffinePermGroupByMatrixGroup
                     ( IrreducibleSolvableGroup( n, p, nr ) );
                Setter( IsPrimitiveAffineProp )( G, true );
                return G;
            else
                if nr = infinity  then
                    num := num + Length( IrredSolGroupList[ n ][ p ] );
                else
                    nr := nr - Length( IrredSolGroupList[ n ][ p ] );
                fi;
            fi;
        fi;

        # Now look at the non-solvable affine groups.
        if IsEmpty( AFFINE_NON_SOLVABLE_GROUPS )  then
            BOOT_AFFINE_NON_SOLVABLE_GROUPS();
        fi;
        if     not IsBound( AFFINE_NON_SOLVABLE_GROUPS[ deg ] )
           and not READ_GAP_ROOT( Concatenation
                       ( "prim/deg", String( deg ), ".aff" ) )  then
            AFFINE_NON_SOLVABLE_GROUPS[ deg ] := [  ];
        fi;
        if nr <= Length( AFFINE_NON_SOLVABLE_GROUPS[ deg ] )  then
            if IsFunction( AFFINE_NON_SOLVABLE_GROUPS[ deg ][ nr ] )  then
                AFFINE_NON_SOLVABLE_GROUPS[ deg ][ nr ] :=
                  AFFINE_NON_SOLVABLE_GROUPS[ deg ][ nr ]();
            elif not IsGroup( AFFINE_NON_SOLVABLE_GROUPS[ deg ][ nr ] )  then
                tmp := AFFINE_NON_SOLVABLE_GROUPS[ deg ][ nr ];
                AFFINE_NON_SOLVABLE_GROUPS[ deg ][ nr ] := tmp[ 2 ];
                SetName( AFFINE_NON_SOLVABLE_GROUPS[ deg ][ nr ], tmp[ 1 ] );
            fi;
            Setter( IsPrimitiveAffineProp )
              ( AFFINE_NON_SOLVABLE_GROUPS[ deg ][ nr ], true );
            return AFFINE_NON_SOLVABLE_GROUPS[ deg ][ nr ];
        fi;
        if nr = infinity  then
            num := num + Length( AFFINE_NON_SOLVABLE_GROUPS[ deg ] );
        else
            nr := nr - Length( AFFINE_NON_SOLVABLE_GROUPS[ deg ] );
        fi;
        
    fi;

    # Count the number  of groups in each  cohort until the desired number is
    # reached.
    nrcs := Cohort( deg, infinity );
    cls := [  ];
    c := 0;
    while nr > Length( cls )  and  c < nrcs  do
        if nr <> infinity  then
            nr := nr - Length( cls );
        fi;
        c := c + 1;
        coh := Cohort( deg, c );
        cls := List( ConjugacyClassesSubgroups( Image( coh ) ),
                     Representative );
        if Length( cls ) = 1  then
            tmp := 0;
        else
            Sort( cls, function( a, b )  return Size( a ) < Size( b ); end );
            cls[ 1 ] := PreImage( coh, cls[ 1 ] );
            if    not IsTransitive( cls[ 1 ], MovedPoints( cls[ 1 ] ) )
               or not IsPrimitive ( cls[ 1 ], MovedPoints( cls[ 1 ] ) )  then
                cls := List( cls{ [ 2 .. Length( cls ) ] }, U ->
                             PreImage( coh, U ) );
                cls := Filtered( cls, U ->
                               IsTransitive( U, MovedPoints( U ) )
                           and IsPrimitive ( U, MovedPoints( U ) ) );
                tmp := infinity;
            else
                tmp := 1;
            fi;
        fi;
        if nr = infinity  then
            num := num + Length( cls );
        fi;
    od;
    if nr = infinity  then
        return num;
    elif nr <= Length( cls )  then
        if nr > tmp  then
            cls[ nr ] := PreImage( coh, cls[ nr ] );
        fi;
        Setter( IsPrimitiveAffineProp )( cls[ nr ], false );
        SetName( cls[ nr ], Concatenation( Name( coh ), ".", String( nr ) ) );
        return cls[ nr ];
    elif deg > 4  and  nr = Length( cls ) + 1  then
        return AlternatingGroup( deg );
    elif deg > 4  and  nr = Length( cls ) + 2  then
        return SymmetricGroup( deg );
    fi;
    return fail;
end;

PrimitiveGroup := function( deg, nr )
    local   G;
    
    G := MakePrimitiveGroup( deg, nr );
    if IsGroup( G )  then
        Setter( IsPrimitiveProp )( G, true );
        if deg <= 50  then
            if IsEmpty( SIMS_NUMBERS )  then
                ReadPrim( "simsnums.gi" );
            fi;
            Setter( SimsNo )( G, SIMS_NUMBERS[ deg ][ nr ] );
            Setter( SimsName )( G, SIMS_NAMES[ deg ][ SimsNo( G ) ] );
        fi;
    fi;
    return G;
end;

#############################################################################
##

#F  NrPrimitiveGroups( <deg> )  . . . . . . . . . . . . . . counting function
##
NrPrimitiveGroups := function( deg )
    return PrimitiveGroup( deg, infinity );
end;

#############################################################################
##
#F  NrSolvableAffinePrimitiveGroups( <deg> )  . . . . . . . counting function
##
NrSolvableAffinePrimitiveGroups := function( deg )
    local   p,  n;
    
    if not IsPrimePowerInt( deg )  then
        return 0;
    elif deg > 255  then
        Error( "affine primitive groups: degree must be < 256" );
    else
        p := FactorsInt( deg )[ 1 ];
        n := LogInt( deg, p );
        if n = 1  then
            return Length( DivisorsInt( p - 1 ) );
        else
            return Length( IrredSolGroupList[ n ][ p ] );
        fi;
    fi;
end;

#############################################################################
##
#F  NrAffinePrimitiveGroups( <deg> )  . . . . . . . . . . . counting function
##
NrAffinePrimitiveGroups := function( deg )
    if not IsPrimePowerInt( deg )  then
        return 0;
    elif deg > 255  then
        Error( "affine primitive groups: degree must be < 256" );
    else
        if IsEmpty( AFFINE_NON_SOLVABLE_GROUPS )  then
            BOOT_AFFINE_NON_SOLVABLE_GROUPS();
        fi;
        if     not IsBound( AFFINE_NON_SOLVABLE_GROUPS[ deg ] )
           and not READ_GAP_ROOT( Concatenation
                       ( "prim/deg", String( deg ), ".aff" ) )  then
            AFFINE_NON_SOLVABLE_GROUPS[ deg ] := [  ];
        fi;
        return Length( AFFINE_NON_SOLVABLE_GROUPS[ deg ] ) +
               NrSolvableAffinePrimitiveGroups( deg );
    fi;
end;

#############################################################################
##

#F  SelectionFunctionValue( <arglis>, <func> )  . . . . . . . . . . . . local
##
SelectionFunctionValue := function( arglis, func, rest )
    local   p,  r,  warn;
    
    warn := false;
    p := Position( arglis, func );
    if p <> fail  then
        r := arglis[ p + 1 ];
        RemoveElmList( arglis, p );
        RemoveElmList( arglis, p );
        if not IsList( r )  then
            r := [ r ];
        fi;
        if rest <> true  and  not IsSubset( rest, r )  then
            r := Intersection( r, rest );
            warn := true;
        fi;
    elif rest <> true  then
        r := rest;
        warn := true;
    else
        r := fail;
    fi;
    if warn  then
        Info( InfoWarning, 1, "primitive permutation groups: ",
               NameFunction( func ), " restricted to ", rest );
    fi;
    return r;
end;

IsSolvable := "2b defined";

#############################################################################
##
#F  SelectPrimitiveGroups( <arglis>, <alle> ) . . . . . . . . . . . . . local
##
SelectPrimitiveGroups := function( arglis, alle )
    local   deg,  aff,  sol,  dim,  chr,  fr,  to,
            res,  d,  i,  p,  G;
    
    deg := SelectionFunctionValue( arglis, NrMovedPoints, [ 1 .. 999 ] );
    aff := SelectionFunctionValue( arglis, IsPrimitiveAffine, true );
    sol := SelectionFunctionValue( arglis, IsSolvable, true );
    fr := x -> 0;
    to := NrPrimitiveGroups;
    if   aff = [ true ]   then  to := NrAffinePrimitiveGroups;  fi;
    if   sol = [ true ]   then  to := NrSolvableAffinePrimitiveGroups;
    elif sol = [ false ]  then  fr := NrSolvableAffinePrimitiveGroups;  fi;
    if   aff = [ false ]  then  fr := NrAffinePrimitiveGroups;  fi;
    if aff = [ true ]  then
        dim := SelectionFunctionValue( arglis, Dimension, [ 1 .. 7 ] );
        chr := SelectionFunctionValue( arglis, Characteristic,
                       Intersection( Primes, [ 2 .. 255 ] ) );
        deg := Intersection( deg, Flat( List
                       ( dim, d -> List( chr, p -> p^d ) ) ) );
    fi;
    
    res := [  ];
    for d  in deg  do
        if aff = [ true ]  and  sol = [ true ]  and  not IsPrime( d )  then
            chr := FactorsInt( d )[ 1 ];
            dim := LogInt( d, chr );
            Append( res, List( CallFuncList
                    ( AllIrreducibleSolvableGroups, Concatenation
                    ( [ Dimension, dim, Characteristic, chr ], arglis ) ),
                    PrimitiveAffinePermGroupByMatrixGroup ) );
        else
            for i  in  [ fr( d ) + 1 .. to( d ) ]  do
                G := PrimitiveGroup( d, i );
                for p  in [ 1, 3 .. Length( arglis ) - 1 ]  do
                    if arglis[ p ]( G ) <> arglis[ p + 1 ]  then
                        G := fail;
                        break;
                    fi;
                od;
                if G <> fail  then
                    Add( res, G );
                    if not alle  then
                        return res;
                    fi;
                fi;
            od;
        fi;
    od;
    return res;
end;

#############################################################################
##
#F  AllPrimitiveGroups( <fun>, <res>, ... ) . . . . . . .  selection function
##
AllPrimitiveGroups := function ( arg )
  return SelectPrimitiveGroups(arg,true);
end;

#############################################################################
##
#F  OnePrimitiveGroup( <fun>, <res>, ... )  . . . . . . .  selection function
##
OnePrimitiveGroup := function ( arg )
local sel;
  sel:=SelectPrimitiveGroups(arg,false);
  if sel=[] then
    return fail;
  else
    return sel;
  fi;
end;

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  primitiv.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

