#@localm11, orb, g, V, comps, 3regclassreps, brauchars, V26, comps26
#@local brauchars26
######################################################################
gap> START_TEST( "example_4.4.18.tst" );

######################################################################
gap> LoadPackage("atlasrep","1.3.1",false);;
gap> m11 := Group(AtlasGenerators("M11",1).generators);
Group([ (2,10)(4,11)(5,7)(8,9), (1,4,3,8)(2,5,6,9) ])

######################################################################
gap> orb :=  Orbit( m11 , [1,2], OnSets );;
gap> g := Image( ActionHomomorphism( m11 , orb, OnSets ) );;
gap> V := PermutationGModule( g, GF(3) );;
gap> comps := Set( MTX.CompositionFactors(V) );;
gap> List(comps, W -> W.dimension);
[ 24, 10, 10, 5, 5, 1 ]
gap> List( comps, W -> MTX.IsAbsolutelyIrreducible(W) );
[ true, true, true, true, true, true ]

######################################################################
gap> 3regclassreps := function( stgens )
> local a,b ; a:=stgens[1]; b:=stgens[2];
> return( [ a^2, a,   b, a*b*a*b^2*a*b^-1,   a*b*a*b^2*a*b^2,
>                      a*b^-1*a*b^2*a*b^2, a*b, a*b^-1 ] ); end;;
gap> brauchars := List( comps,  W ->
>      List( 3regclassreps( W.generators ), BrauerCharacterValue ) );;
gap> brauchars := Set( brauchars );;   List( brauchars, y -> y[1] );
[ 1, 5, 5, 10, 24 ]

######################################################################
gap> V26 := TensorProductGModule( comps[2] , comps[6]);;
gap> comps26 := Set( MTX.CompositionFactors(V26) );;
gap> ForAll( comps26, W -> MTX.IsAbsolutelyIrreducible(W) );
true
gap> brauchars26 := List( comps26,  W ->
>  List( 3regclassreps( W.generators ), BrauerCharacterValue ) );;
gap> brauchars26 := Set( brauchars26 );; List( brauchars26, y -> y[1] );
[ 10 ]

######################################################################
gap> STOP_TEST( "example_4.4.18.tst" );
