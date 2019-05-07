#@local S4,V4,irr,l
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
gap> STOP_TEST( "ctblfuns.tst", 1);
