#@local S4,V4,irr,l, tbl, v, g, h, t, chi, t5, irr5
gap> START_TEST("ctblfuns.tst");
gap> S4:= SymmetricGroup( 4 );
Sym( [ 1 .. 4 ] )
gap> V4:= Group( (1,2)(3,4), (1,3)(2,4) );
Group([ (1,2)(3,4), (1,3)(2,4) ])
gap> irr:= SortedList( Irr( V4 ) );
[ Character( CharacterTable( Group([ (1,2)(3,4), (1,3)(2,4) ]) ),
  [ 1, -1, -1, 1 ] ), Character( CharacterTable( Group(
    [ (1,2)(3,4), (1,3)(2,4) ]) ), [ 1, -1, 1, -1 ] ), 
  Character( CharacterTable( Group([ (1,2)(3,4), (1,3)(2,4) ]) ),
  [ 1, 1, -1, -1 ] ), Character( CharacterTable( Group(
    [ (1,2)(3,4), (1,3)(2,4) ]) ), [ 1, 1, 1, 1 ] ) ]
gap> List( irr, x -> InertiaSubgroup( S4, x ) );
[ Group([ (1,4), (1,4)(2,3), (1,3)(2,4) ]), Group([ (1,4,3,2), (1,4)(2,3) ]), 
  Group([ (3,4), (1,4)(2,3) ]), Sym( [ 1 .. 4 ] ) ]
gap> List( last, Size );
[ 8, 8, 8, 24 ]

#gap> l:=List( AllSmallGroups(12), CharacterTable );;
gap> l:=List([ 3913, 266, 7012, 321, 1 ],
>            i -> CharacterTable(PcGroupCode(i, 12)));;
gap> List( l, ConjugacyClasses );;
gap> List( l, SizesConjugacyClasses );;
gap> List( l, OrdersClassRepresentatives );;
gap> List( l, Irr );;
gap> ForAll( l, IsInternallyConsistent);
true
gap> l:=List([3913, 266, 7012, 321, 1], i -> PcGroupCode(i, 12));;
gap> ForAll(l,g -> IsInternallyConsistent(CharacterTable(g) mod 2));
true
gap> l:=List([3913, 266, 7012, 321, 1], i -> PcGroupCode(i, 12));;
gap> ForAll(l,g -> IsInternallyConsistent(TableOfMarks(g)));
true

# Up to GAP 4.11.1, the following returned 'fail' results.
gap> if IsPackageMarkedForLoading( "ctbllib", "" ) then
>   tbl:= CharacterTable( "J1" );;
>   if fail in List( Filtered( Irr( tbl ), x -> x[1] = 120 ),
>                    x -> SizeOfFieldOfDefinition( x, 71 ) ) then
>     Error( "SizeOfFieldOfDefinition test failed" );
>   fi;
> fi;

# other situations for 'SizeOfFieldOfDefinition'
gap> SizeOfFieldOfDefinition( 17, 2 );
2
gap> SizeOfFieldOfDefinition( E(7), 2 );
8
gap> SizeOfFieldOfDefinition( [ E(7) ], 2 );
8
gap> SizeOfFieldOfDefinition( E(7) / 2, 2 );
fail
gap> SizeOfFieldOfDefinition( E(8), 2 );
fail
gap> SizeOfFieldOfDefinition( E(4), 5 );
5
gap> SizeOfFieldOfDefinition( EX(63), 2 );
2
gap> SizeOfFieldOfDefinition( GaloisCyc( EX(63), -1 ), 2 );
4
gap> v:= Conjugates( CF(8), E(8) + 4*E(8)^3 );;
gap> SizeOfFieldOfDefinition( v, 3 );
3
gap> v = List( v, x -> GaloisCyc( x, 3 ) );
false
gap> ForAll( ( v - List( v, x -> GaloisCyc( x, 3 ) ) ) / 3, IsCycInt );
true
gap> SizeOfFieldOfDefinition( EC(19), 71 );
#I  the Conway polynomial of degree 18 for p = 71 is not known
fail
gap> SizeOfFieldOfDefinition( Z(25), 5 );
Error, <val> must be a cyclotomic or a list of cyclotomics

#
gap> S4:= SymmetricGroup( 4 );;
gap> V4:= PCore( S4, 2 );;
gap> t:= CharacterTable( V4 );;
gap> irr:= Irr( t );;
gap> List( irr, chi -> Position( irr, chi^S4.1 ) );
[ 1, 3, 2, 4 ]
gap> chi:= irr[2];;
gap> chi = List( ConjugacyClasses( V4 ), x -> Representative(x)^chi );
true
gap> t5:= t mod 5;;
gap> irr5:= Irr( t5 );;
gap> List( irr5, chi -> Position( irr5, chi^S4.1 ) );
[ 1, 3, 2, 4 ]
gap> chi:= irr5[2];;
gap> chi = List( ConjugacyClasses( V4 ), x -> Representative(x)^chi );
true

#
gap> chi:= TrivialCharacter( SymmetricGroup(1) );;
gap> chi = chi^0;
true

#
gap> tbl:= CharacterTable( SymmetricGroup( 4 ) );;
gap> chi:= ClassFunction( tbl, 0 * Irr( tbl )[1] );
ClassFunction( CharacterTable( Sym( [ 1 .. 4 ] ) ), [ 0, 0, 0, 0, 0 ] )
gap> AntiSymmetricParts( tbl, [ chi ], 2 );
[ VirtualCharacter( CharacterTable( Sym( [ 1 .. 4 ] ) ), [ 0, 0, 0, 0, 0 ] ) ]

# SymmetricParts and AntiSymmetricParts agree with Symmetrizations,
# also for reducible and virtual characters
gap> t:= CharacterTable( AlternatingGroup( 5 ) );;
gap> l:= Concatenation( Irr( t ),
>            [ Sum( Irr( t ) ), Irr( t )[2] - Irr( t )[1] ] );;
gap> ForAll( [ 1 .. 6 ], n ->
>      SymmetricParts( t, l, n ) = List( l, c -> Symmetrizations( [ c ], n )
>                                    [ Position( Partitions( n ), [ n ] ) ] )
>      and AntiSymmetricParts( t, l, n ) =
>          List( l, c -> Symmetrizations( [ c ], n )[1] ) );
true
gap> SymmetricParts( t, l, 0 ) = List( l, c -> TrivialCharacter( t ) );
true
gap> chi:= First( Irr( t ), x -> x[1] = 3 );;
gap> SymmetricPower( chi, 60 )[1] = Binomial( 62, 60 );
true
gap> ExteriorPower( Sum( Irr( t ) ), 8 )[1] = Binomial( 16, 8 );
true

# SchurPower agrees with Symmetrizations for partitions,
# also for reducible and virtual characters
gap> ForAll( l, c -> ForAll( [ 1 .. 6 ], k ->
>        Symmetrizations( [ c ], k ) =
>        List( Partitions( k ), p -> SchurPower( c, p ) ) ) );
true

#
gap> chi:= First( Irr( t ), x -> x[1] = 3 );;
gap> IsCharacter( SchurPower( chi, [ 2, 1 ] ) );
true
gap> SchurPower( chi, [ 1, 1, 1, 1 ] );
VirtualCharacter( CharacterTable( Alt( [ 1 .. 5 ] ) ), [ 0, 0, 0, 0, 0 ] )
gap> ForAll( [ [ ], [ 0 ], [ 0, 0, 0 ] ],
>            p -> SchurPower( chi, p ) = TrivialCharacter( t ) );
true
gap> ForAll( [ [ 1 ], [ 1, 0, 0 ], [ 1, 0, 0, 0, 0 ] ],
>            p -> SchurPower( chi, p ) = chi );
true

# weights with more than a few boxes; degrees by the Weyl dimension formula
gap> SchurPower( chi, [ 30, 20, 10 ] )[1];
1331
gap> SchurPower( chi, [ 200, 100 ] )[1];
1030301

# negative weights, for a character that is not real
gap> t:= CharacterTable( CyclicGroup( 3 ) );;
gap> chi:= Irr( t )[1] + First( Irr( t ), x -> x <> ComplexConjugate( x ) );;
gap> SchurPower( chi, [ 0, -1 ] ) = ComplexConjugate( chi );
true
gap> SchurPower( chi, [ -1, -1 ] ) = ComplexConjugate( DeterminantOfCharacter( chi ) );
true
gap> SchurPower( chi, [ 1, -1 ] ) = chi * ComplexConjugate( chi ) - TrivialCharacter( t );
true
gap> SchurPower( chi, [ 2, 1 ] ) = chi * DeterminantOfCharacter( chi );
true
gap> IsCharacter( SchurPower( chi, [ 1, -1 ] ) );
true

#
gap> SchurPower( chi, [ 1, 2 ] );
Error, <lambda> must be a weakly decreasing list of integers
gap> SchurPower( chi, [ 1/2 ] );
Error, <lambda> must be a weakly decreasing list of integers
gap> SchurPower( chi, [ 0, 0, -1 ] );
Error, <lambda> with a negative entry must have length 2
gap> SchurPower( chi, [ -1 ] );
Error, <lambda> with a negative entry must have length 2

#
gap> STOP_TEST("ctblfuns.tst");
