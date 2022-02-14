#@local S4,V4,irr,l, tbl, v, g, h, t, chi, t5, irr5
gap> START_TEST("ctblfuns.tst");
gap> S4:= SymmetricGroup( 4 );
Sym( [ 1 .. 4 ] )
gap> V4:= Group( (1,2)(3,4), (1,3)(2,4) );
Group([ (1,2)(3,4), (1,3)(2,4) ])
gap> irr:= Irr( V4 );
[ Character( CharacterTable( Group([ (1,2)(3,4), (1,3)(2,4) ]) ),
  [ 1, 1, 1, 1 ] ), Character( CharacterTable( Group([ (1,2)(3,4), (1,3)(2,4) 
     ]) ), [ 1, -1, -1, 1 ] ), Character( CharacterTable( Group(
    [ (1,2)(3,4), (1,3)(2,4) ]) ), [ 1, -1, 1, -1 ] ), 
  Character( CharacterTable( Group([ (1,2)(3,4), (1,3)(2,4) ]) ),
  [ 1, 1, -1, -1 ] ) ]
gap> List( irr, x -> InertiaSubgroup( S4, x ) );
[ Sym( [ 1 .. 4 ] ), Group([ (1,4), (1,4)(2,3), (1,3)(2,4) ]), 
  Group([ (1,4,3,2), (1,4)(2,3) ]), Group([ (3,4), (1,4)(2,3) ]) ]
gap> List( last, Size );
[ 24, 8, 8, 8 ]
gap> l:=List( AllSmallGroups(12), CharacterTable );;
gap> List( l, ConjugacyClasses );;
gap> List( l, SizesConjugacyClasses );;
gap> List( l, OrdersClassRepresentatives );;
gap> List( l, Irr );;
gap> ForAll( l, IsInternallyConsistent);
true
gap> ForAll(AllSmallGroups(12),g -> IsInternallyConsistent(CharacterTable(g) mod 2));
true
gap> ForAll(AllSmallGroups(12),g -> IsInternallyConsistent(TableOfMarks(g)));
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
gap> STOP_TEST( "ctblfuns.tst", 1);
