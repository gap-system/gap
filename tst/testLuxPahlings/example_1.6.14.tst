#@local cond, G, g1, g2, H, orb, hom, mats, M, compfactors
######################################################################
gap> START_TEST( "example_1.6.14.tst" );

## This is code from Example 1.6.4.
gap> cond := function( H, n , g, q )
> local condmat, orbs;
> orbs := Orbits( H , [1..n] );
> condmat := List( orbs, Oi -> List( orbs, Oj -> 1/(Size(Oi)*Z(q)^0) *
>                 Size( Intersection( List(Oi, x -> x^g), Oj) ) ) );
> return condmat;
> end;;

######################################################################
gap> G := MathieuGroup(11);
Group([ (1,2,3,4,5,6,7,8,9,10,11), (3,7,11,8)(4,10,5,6) ])
gap> g1 := (1,4)(2,10,3)(5,11,8,6,7,9);; g2 := (2,3,7,4,10,8,5,11)(6,9);;
gap> G = Group( g1, g2 );
true
gap> H := SylowSubgroup( G, 3 );;
gap> orb :=  Orbit( G , [1,2], OnSets );;
gap> hom := ActionHomomorphism( G, orb, OnSets );;
gap> g1 := Image( hom, g1 );;  g2 := Image( hom, g2 );;
gap> H := Image( hom, H );;

######################################################################
gap> mats := List( [g1, g2] , g ->  cond( H, 55, g, 2) );;
gap> Display(mats[1]);
 . . 1 . . . .
 . 1 1 . . . 1
 1 1 . . . . 1
 . . . 1 1 1 .
 . . . 1 1 1 .
 . . . 1 1 1 .
 . 1 1 . . . 1
gap> Display(mats[2]);
 . . . . . . 1
 . 1 . . . . .
 . . . . 1 . .
 . . . . . 1 .
 . . . 1 . . .
 . . 1 . . . .
 1 . . . . . .
gap> M := GModuleByMats( List( mats, TransposedMat ), GF(2) );;
gap> compfactors  := MTX.CompositionFactors( M );;
gap> List( compfactors, x -> x.dimension );
[ 2, 4, 1 ]

######################################################################
gap> STOP_TEST( "example_1.6.14.tst" );
