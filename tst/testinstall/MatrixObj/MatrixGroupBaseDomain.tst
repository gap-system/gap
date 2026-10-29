#@local a, b, F, G, H, L, p, U, z
gap> START_TEST("MatrixGroupBaseDomain.tst");

# 'Group' does not set it for list matrices
gap> a:= [ [ 0, 1 ], [ 1, 0 ] ] * Z(5)^0;;
gap> b:= [ [ 1, 1 ], [ 0, 1 ] ] * Z(5)^0;;
gap> HasBaseDomain( Group( a, b ) );
false
gap> HasBaseDomain( Group( List( [ a, b ],
>                                 m -> ImmutableMatrix( GF(25), m ) ) ) );
false
gap> HasBaseDomain( Group( [ [ 1, 1 ], [ 0, 1 ] ] ) );
false

# matrix objects: the base domain of the generators
gap> p:= List( [ a, b ], m -> Matrix( IsPlistMatrixRep, GF(25), m ) );;
gap> G:= Group( p );;
gap> BaseDomain( G );
GF(5^2)
gap> IsVecOrMatObj( G );
false
gap> BaseDomain( Group( [], One( p[1] ) ) );
GF(5^2)
gap> BaseDomain( Group( Matrix( IsPlistMatrixRep, Integers,
>                                [ [ 1, 1 ], [ 0, 1 ] ] ) ) );
Integers
gap> z:= ZmodnZ( 8 );;
gap> BaseDomain( Group( Matrix( IsZmodnZMatrixRep, z,
>                                [ [ 1, 1 ], [ 0, 1 ] ] * One( z ) ) ) );
(Integers mod 8)
gap> BaseDomain( Subgroup( G, [ p[1] ] ) );
GF(5^2)

# classical groups
gap> List( [ GL( 2, 9 ), SL( 2, 4 ), GL( 2, 2 ), GammaL( 2, 4 ) ], BaseDomain );
[ GF(3^2), GF(2^2), GF(2), GF(2) ]
gap> List( [ Sp( 4, 3 ), Sp( 2, 5 ), CSp( 4, 3 ), CSp( 2, 4 ) ], BaseDomain );
[ GF(3), GF(5), GF(3), GF(2^2) ]
gap> List( [ GU( 2, 3 ), SU( 2, 3 ), SU( 3, 2 ), SigmaL( 2, 9 ) ], BaseDomain );
[ GF(3^2), GF(3^2), GF(2^2), GF(3) ]
gap> List( [ GO( 1, 9 ), GO( 3, 4 ), GO( 1, 4, 3 ), GO( -1, 2, 5 ) ],
>         BaseDomain );
[ GF(3^2), GF(2^2), GF(3), GF(5) ]
gap> List( [ SO( 1, 9 ), SO( 3, 5 ), SO( 1, 4, 3 ), SO( -1, 4, 4 ) ],
>         BaseDomain );
[ GF(3^2), GF(5), GF(3), GF(2^2) ]
gap> List( [ Omega( 3, 5 ), Omega( 1, 4, 5 ), Omega( -1, 2, 5 ) ], BaseDomain );
[ GF(5), GF(5), GF(5) ]
gap> List( [ Sz( 8 ), Ree( 27 ) ], BaseDomain );
[ GF(2^3), GF(3^3) ]
gap> List( [ GL( 2, Integers ), SL( 2, Integers ) ], BaseDomain );
[ Integers, Integers ]
gap> List( [ GL( 2, Integers mod 8 ), SL( 2, Integers mod 8 ),
>            Sp( 2, Integers mod 8 ) ], BaseDomain );
[ (Integers mod 8), (Integers mod 8), (Integers mod 8) ]
gap> List( [ GO( 3, Integers mod 9 ), SO( 3, Integers mod 9 ) ], BaseDomain );
[ (Integers mod 9), (Integers mod 9) ]
gap> List( [ CyclicGroup( IsMatrixGroup, GF(4), 3 ),
>            CyclicGroup( IsMatrixGroup, 3 ),
>            DicyclicGroup( IsMatrixGroup, GF(5), 8 ) ], BaseDomain );
[ GF(2^2), Rationals, GF(5) ]

# 'FieldOfMatrixGroup' is the smallest field containing the entries
gap> G:= GO( 1, 9 );;
gap> [ BaseDomain( G ), FieldOfMatrixGroup( G ) ];
[ GF(3^2), GF(3) ]

# constructors with a representation filter
gap> G:= GL( 2, 9 : ConstructingFilter:= IsPlistMatrixRep );;
gap> BaseDomain( G );
GF(3^2)
gap> G:= Sp( IsPlistMatrixRep, 4, 3 );;
gap> [ IsPlistMatrixRep( One( G ) ), BaseDomain( G ) ];
[ true, GF(3) ]
gap> BaseDomain( TrivialSubgroup( G ) );
GF(3)

# subgroups inherit it
gap> G:= GL( 2, 9 );;
gap> H:= TrivialSubgroup( G );;
gap> [ BaseDomain( H ), FieldOfMatrixGroup( H ) ];
[ GF(3^2), GF(3) ]
gap> List( [ Subgroup( G, [ G.1 ] ), SubgroupNC( G, [ G.2 ] ),
>            DerivedSubgroup( G ), SylowSubgroup( G, 2 ),
>            Centralizer( G, G.1 ), Normalizer( G, H ) ], BaseDomain );
[ GF(3^2), GF(3^2), GF(3^2), GF(3^2), GF(3^2), GF(3^2) ]
gap> HasBaseDomain( Group( G.1 ) );
false
gap> BaseDomain( Group( G.1 ) );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 2nd choice method found for `BaseDomain' on 1 arguments

# results of nice monomorphism methods inherit it from the source;
# 'U' takes the nice monomorphism of 'G', computing one for 'U' needs
# 'DegreeFFE' for matrix objects
gap> F:= GF(9);;
gap> G:= GL( 2, F : ConstructingFilter:= IsPlistMatrixRep );;
gap> a:= G.1;;  b:= G.2;;
gap> NiceMonomorphism( G );;  U:= Subgroup( G, [ a ] );;
gap> HasBaseDomain( ClosureGroup( U, b ) );
true
gap> HasBaseDomain( Intersection( U, Subgroup( G, [ a^2 ] ) ) );
true
gap> HasBaseDomain( NormalClosure( G, U ) );
true
gap> L:= GL( 2, 9 );;
gap> HasBaseDomain( ClosureGroup( Subgroup( L, [ L.1 ] ), L.2 ) );
true

# groups of matrix objects without a stored value
gap> H:= Objectify( NewType( FamilyObj( G ),
>                            IsGroup and IsAttributeStoringRep ), rec() );;
gap> SetOne( H, a^0 );
gap> HasBaseDomain( H );
false
gap> BaseDomain( H );
GF(3^2)

#
gap> STOP_TEST("MatrixGroupBaseDomain.tst");
