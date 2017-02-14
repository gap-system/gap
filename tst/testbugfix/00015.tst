##  bugs 2, 3, 6, 7, 20 for fix 2.
gap> x:= Sum( GeneratorsOfAlgebra( QuaternionAlgebra( Rationals, -2, -2 ) ) );;
gap> x * Inverse( x ) = One( x );
true
gap> LargestMovedPoint(ProjectiveSymplecticGroup(6,2)) = 63;
true
gap> t1:= CharacterTable( CyclicGroup( 2 ) );;  SetIdentifier( t1, "C2" );
gap> t2:= CharacterTable( CyclicGroup( 3 ) );;  SetIdentifier( t2, "C3" );
gap> t1 * t1;  ( t1 mod 2 ) * ( t1 mod 2 );
CharacterTable( "C2xC2" )
BrauerTable( "C2xC2", 2 )
gap> ( t1 mod 2 ) * t2;  t2 * ( t1 mod 2 );
BrauerTable( "C2xC3", 2 )
BrauerTable( "C3xC2", 2 )
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> chi:= TrivialCharacter( t );;
gap> IntScalarProducts( t, [ chi ], chi );
true
gap> NonnegIntScalarProducts( t, [ chi ], chi );
true
gap> Representative( TrivialSubgroup( Group( (1,2) ) ) );
()
gap> Representative( TrivialSubspace( GF(2)^2 ) );
[ 0*Z(2), 0*Z(2) ]
gap> g:=SmallGroup(70,3);;
gap> g:=GroupByPcgs(Pcgs(g));;
gap> IdGroup(g);
[ 70, 3 ]
gap> G := Group(());;F := FreeGroup( 1, "f" );;
gap> hom := GroupHomomorphismByImages(F,G,GeneratorsOfGroup(F),
> GeneratorsOfGroup(G));;
gap> PreImagesRepresentative(hom,());
<identity ...>
