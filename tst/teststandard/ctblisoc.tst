#@local g, t, iso, t3, iso3, orders, n, iso2, filt, c
gap> START_TEST( "ctblisoc.tst" );

# one argument
gap> g:= SmallGroup( 48, 29 );;
gap> t:= CharacterTable( g );;
gap> iso:= CharacterTableIsoclinic( t );;
gap> TransformingPermutationsCharacterTables( t, iso );
fail
gap> t3:= t mod 3;;
gap> iso3:= CharacterTableIsoclinic( t3 );;
gap> SourceOfIsoclinicTable( iso );
[ CharacterTable( <pc group of size 48 with 5 generators> ), 
  [ 1, 3, 4, 5, 7 ], [ 5 ], 5 ]

# the cases of inconsistent or insufficient arguments
gap> CharacterTableIsoclinic( t, rec( centralElement:= 1 ) );
Error, <arec>.centralElement must be the pos. of a nonid. central class
gap> CharacterTableIsoclinic( t, rec( normalSubgroup:= [ 1, 2 ] ) );
Error, <arec>.normalSubgroup must describe a normal subgroup of prime index
gap> g:= CyclicGroup( 6 );;
gap> t:= CharacterTable( g );;
gap> CharacterTableIsoclinic( t );
Error, no suitable normal subgroup of prime index found
gap> orders:= OrdersClassRepresentatives( t );;
gap> CharacterTableIsoclinic( t,
>        rec( centralElement:= Position( orders, 6 ) ) );
Error, the element in class <xpos> must have prime order
gap> CharacterTableIsoclinic( t,
>        rec( centralElement:= Position( orders, 2 ),
>             normalSubgroup:= ClassPositionsOfPCore( t, 3 ) ) );
Error, the central class <xpos> does not lie in <nsg>
gap> CharacterTableIsoclinic( t,
>        rec( centralElement:= Position( orders, 2 ),
>             normalSubgroup:= ClassPositionsOfPCore( t, 2 ) ) );
Error, <arec>.normalSubgroup must describe a normal subgroup of index <p>
gap> g:= DihedralGroup( 8 );;
gap> t:= CharacterTable( g );;
gap> iso:= CharacterTableIsoclinic( t );;
Error, the normal subgroup is not uniquely determined,
specify it with <arec>.normalSubgroup
gap> g:= SymmetricGroup( 3 );;
gap> t:= CharacterTable( g );;
gap> CharacterTableIsoclinic( t,
>        rec( normalSubgroup:= ClassPositionsOfDerivedSubgroup( t ) ) );;
Error, no central subgroup of order 2
gap> g:= DirectProduct( SmallGroup( 48, 29 ), CyclicGroup( 2 ) );;
gap> t:= CharacterTable( g );;
gap> n:= ClosureGroup( DerivedSubgroup( g ), Centre( g ) );;
gap> CharacterTableIsoclinic( t,
>        rec( normalSubgroup:= ClassPositionsOfNormalSubgroup( t, n ) ) );
Error, the central subgroup of order 2 is not uniquely determined,
specify it with <arec>.centralElement

# p = 3, three nonisomorphic variants (this example takes several seconds)
gap> g:= GL(3,4);;
gap> t:= CharacterTable( g );;
gap> iso:= CharacterTableIsoclinic( t );;
gap> iso2:= CharacterTableIsoclinic( t, rec( k:= 2 ) );;
gap> TransformingPermutationsCharacterTables( t, iso );
fail
gap> TransformingPermutationsCharacterTables( iso, iso2 );
fail
gap> TransformingPermutationsCharacterTables( t, iso2 );
fail
gap> iso3:= CharacterTableIsoclinic( iso, rec( k:= 2 ) );;
gap> TransformingPermutationsCharacterTables( t, iso3 ) = fail;
false
gap> RecNames( SourceOfIsoclinicTable( iso ) );
[ "p", "k", "table", "centralElement", "outerClasses" ]

# Brauer tables
gap> g:= GL(2,3);;
gap> t:= CharacterTable( g );;
gap> iso:= CharacterTableIsoclinic( t );;
gap> t3:= t mod 3;;
gap> iso3:= CharacterTableIsoclinic( t3, iso );;
gap> TransformingPermutationsCharacterTables( iso3,
>        CharacterTableIsoclinic( t3 ) ) <> fail;
true
gap> TransformingPermutationsCharacterTables( iso3, iso mod 3 ) <> fail;
true
gap> TransformingPermutationsCharacterTables( iso mod 2,
>        CharacterTableIsoclinic( t mod 2 ) ) <> fail;
true

# the case where the central subgroup has order 4
gap> g:= SmallGroup( 48, 5 );;
gap> Size( Centre( g ) );
4
gap> t:= CharacterTable( g );;
gap> n:= First( ClassPositionsOfNormalSubgroups( t ),
>               l -> Length( l ) = 10 );;
gap> iso:= CharacterTableIsoclinic( t, n, ClassPositionsOfCentre( t ) );;
gap> filt:= Filtered(
>               AllSmallGroups( Size, 48, g -> Size( Centre( g ) ), 4 ),
>               g -> TransformingPermutationsCharacterTables( iso,
>                        CharacterTable( g ) ) <> fail );;
gap> Length( filt );
1
gap> IdGroup( filt[1] ) = IdGroup( g );
false

# optional arguments:
# normal subgroup specified, ...
gap> g:= DirectProduct( SmallGroup( 48, 29 ), CyclicGroup( 2 ) );;
gap> n:= Image( Embedding( g, 1 ) );;
gap> t:= CharacterTable( g );;
gap> n:= ClassPositionsOfNormalSubgroup( t, n );;
gap> CharacterTableIsoclinic( t, rec( normalSubgroup:= n ) );;
gap> CharacterTableIsoclinic( t, n );;
gap> CharacterTableIsoclinic( t mod 3, rec( normalSubgroup:= n ) );;
gap> CharacterTableIsoclinic( t mod 3, n );;

# ... central subgroup specified, ...
gap> t:= CharacterTable( SmallGroup( 96, 66 ) );;
gap> c:= ClassPositionsOfCentre( t )[2];;
gap> CharacterTableIsoclinic( t, rec( centralElement:= c ) );;
gap> CharacterTableIsoclinic( t, c );;
gap> CharacterTableIsoclinic( t mod 3, rec( centralElement:= c ) );;
gap> CharacterTableIsoclinic( t mod 3, c );;

# ... both specified
gap> g:= DirectProduct( SmallGroup( 48, 29 ), CyclicGroup( 2 ) );;
gap> t:= CharacterTable( g );;
gap> n:= ClosureGroup( DerivedSubgroup( g ), Centre( g ) );;
gap> n:= ClassPositionsOfNormalSubgroup( t, n );;
gap> c:= ClassPositionsOfCentre( t )[2];;
gap> CharacterTableIsoclinic( t,
>        rec( normalSubgroup:= n, centralElement:= c ) );;
gap> CharacterTableIsoclinic( t, n, c );;
gap> CharacterTableIsoclinic( t mod 3,
>        rec( normalSubgroup:= n, centralElement:= c ) );;
gap> CharacterTableIsoclinic( t mod 3, n, c );;

##
gap> STOP_TEST( "ctblisoc.tst" );

