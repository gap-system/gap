gap> START_TEST("alg-dsum.tst");
gap> # direct sums of type "basis vectors"
gap> genc5 := [ (5,6,7,8,9) ];;
gap> c5 := Group( genc5 );;
gap> SetName( c5, "c5" );;
gap> A5 := GroupRing( Rationals, c5 );;
gap> SetName( A5, "A5" );;
gap> embc5 := Embedding( c5, A5 );;
gap> BasisVectors( Basis( A5 ) );
[ (1)*(), (1)*(5,6,7,8,9), (1)*(5,7,9,6,8), (1)*(5,8,6,9,7), (1)*(5,9,8,7,6) ]
gap> gens3 := [ (1,2), (2,3) ];;
gap> s3 := Group( gens3 );;
gap> SetName( s3, "s3" );;
gap> A6 := GroupRing( Rationals, s3 );;
gap> SetName( A6, "A6" );;
gap> embs3 := Embedding( s3, A6 );;
gap> BasisVectors( Basis( A6 ) );
[ (1)*(), (1)*(2,3), (1)*(1,2), (1)*(1,2,3), (1)*(1,3,2), (1)*(1,3) ]
gap> A56 := DirectSumOfAlgebras( A5, A6 );;
gap> info56 := DirectSumInfo( A56 );
rec( algebras := [ A5, A6 ], embeddings := [  ], first := [ 0, 5, 11 ], 
  projections := [  ], type := "basis vectors" )
gap> SetName( A56, "A56" );
gap> A656 := DirectSumOfAlgebras( A6, A56 );;
gap> info656 := DirectSumInfo( A656 );
rec( algebras := [ A6, A5, A6 ], embeddings := [  ], 
  first := [ 0, 6, 11, 17 ], projections := [  ], type := "basis vectors" )
gap> A565 := DirectSumOfAlgebras( A56, A5 );;
gap> info565 := DirectSumInfo( A565 );
rec( algebras := [ A5, A6, A5 ], embeddings := [  ], 
  first := [ 0, 5, 11, 16 ], projections := [  ], type := "basis vectors" )
gap> A5656 := DirectSumOfAlgebras( A56, A56 );;
gap> info5656 := DirectSumInfo( A5656 );
rec( algebras := [ A5, A6, A5, A6 ], embeddings := [  ], 
  first := [ 0, 5, 11, 16, 22 ], projections := [  ], type := "basis vectors" )
gap> emb5 := Embedding( A56, 1 );
[ (1)*(), (1)*(5,6,7,8,9), (1)*(5,7,9,6,8), (1)*(5,8,6,9,7), (1)*(5,9,8,7,6) ]
  -> [ v.1, v.2, v.3, v.4, v.5 ]
gap> g := ImageElm( embc5, (5,7,9,6,8) );
(1)*(5,7,9,6,8)
gap> ImageElm( emb5, g );
v.3
gap> pro6 := Projection( A56, 2 );
[ v.1, v.2, v.3, v.4, v.5, v.6, v.7, v.8, v.9, v.10, v.11 ] -> 
[ <zero> of ..., <zero> of ..., <zero> of ..., <zero> of ..., <zero> of ..., 
  (1)*(), (1)*(2,3), (1)*(1,2), (1)*(1,2,3), (1)*(1,3,2), (1)*(1,3) ]
gap> bas56 := BasisVectors( Basis( A56 ) );
[ v.1, v.2, v.3, v.4, v.5, v.6, v.7, v.8, v.9, v.10, v.11 ]
gap> ImageElm( pro6, bas56[9] );
(1)*(1,2,3)
gap> # direct sums of type "generators"
gap> m1 := [ [0,1,0,0], [0,0,1,0], [0,0,0,1], [1,0,0,0] ];;
gap> A1 := Algebra( Rationals, [m1] );;
gap> SetName( A1, "A1" );;
gap> GeneratorsOfAlgebra( A1 );
[ [ [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ 1, 0, 0, 0 ] ] ]
gap> m2 := [ [0,1,1], [0,0,1], [0,0,0] ];;
gap> m3 := [ [-1,0,0], [0,0,0], [0,0,-1] ];;
gap> m4 := [ [0,0,0], [1,0,0], [1,1,0] ];;
gap> A2 := Algebra( Rationals, [m2,m3,m4] );;
gap> SetName( A2, "A2" );;
gap> GeneratorsOfAlgebra( A2 );
[ [ [ 0, 1, 1 ], [ 0, 0, 1 ], [ 0, 0, 0 ] ], 
  [ [ -1, 0, 0 ], [ 0, 0, 0 ], [ 0, 0, -1 ] ], 
  [ [ 0, 0, 0 ], [ 1, 0, 0 ], [ 1, 1, 0 ] ] ]
gap> A12 := DirectSumOfAlgebras( A1, A2 );;
gap> info12 := DirectSumInfo( A12 );
rec( algebras := [ A1, A2 ], embeddings := [  ], first := [ 0, 1, 4 ], 
  projections := [  ], type := "generators" )
gap> SetName( A12, "A12" );
gap> A212 := DirectSumOfAlgebras( A2, A12 );;
gap> info212 := DirectSumInfo( A212 );
rec( algebras := [ A2, A1, A2 ], embeddings := [  ], first := [ 0, 3, 4, 7 ], 
  projections := [  ], type := "generators" )
gap> A121 := DirectSumOfAlgebras( A12, A1 );;
gap> info121 := DirectSumInfo( A121 );
rec( algebras := [ A1, A2, A1 ], embeddings := [  ], first := [ 0, 1, 4, 5 ], 
  projections := [  ], type := "generators" )
gap> A1212 := DirectSumOfAlgebras( A12, A12 );;
gap> info1212 := DirectSumInfo( A1212 );
rec( algebras := [ A1, A2, A1, A2 ], embeddings := [  ], 
  first := [ 0, 1, 4, 5, 8 ], projections := [  ], type := "generators" )
gap> emb1 := Embedding( A12, 1 );
[ [ [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ 1, 0, 0, 0 ] ] ] -> 
[ [ [ 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 1, 0, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0, 0 ],
    [ 1, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0 ], 
    [ 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0 ] ] ]
gap> m1^3;
[ [ 0, 0, 0, 1 ], [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ] ]
gap> ImageElm( emb1, m1^3 );
[ [ 0, 0, 0, 1, 0, 0, 0 ], [ 1, 0, 0, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 1, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0 ] ]
gap> pro2 := Projection( A12, 2 );;
gap> m0 := GeneratorsOfAlgebra( A12 )[2];
[ [ 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0, 1, 1 ], [ 0, 0, 0, 0, 0, 0, 1 ], 
  [ 0, 0, 0, 0, 0, 0, 0 ] ]
gap> ImageElm( pro2, m0 );
[ [ 0, 1, 1 ], [ 0, 0, 1 ], [ 0, 0, 0 ] ]
gap> # mix the two types together
gap> A5612 := DirectSumOfAlgebras( A56, A12 );;
gap> info5612 := DirectSumInfo( A5612 );
rec( algebras := [ A5, A6, A1, A2 ], embeddings := [  ], 
  first := [ 0, 5, 11, 15, 24 ], projections := [  ], type := "basis vectors" )
gap> A1256 := DirectSumOfAlgebras( A12, A56 );;
gap> info1256 := DirectSumInfo( A1256 );
rec( algebras := [ A5, A6, A1, A2 ], embeddings := [  ], 
  first := [ 0, 5, 11, 15, 24 ], projections := [  ], type := "basis vectors" )

gap> ## Lie algebra example
gap> L := FullMatrixLieAlgebra( Rationals, 2 );
<Lie algebra over Rationals, with 3 generators>
gap> SetName( L, "L" );
gap> L2 := DirectSumOfAlgebras( L, L );
<Lie algebra over Rationals, with 6 generators>
gap> DirectSumInfo(L2);
rec( algebras := [ L, L ], embeddings := [  ], first := [ 0, 3, 6 ], 
  projections := [  ], type := "generators" )
gap> Embedding( L2, 1 );                       
[ LieObject( [ [ 1, 0 ], [ 0, 0 ] ] ), LieObject( [ [ 0, 1 ], [ 0, 0 ] ] ), 
  LieObject( [ [ 0, 0 ], [ 1, 0 ] ] ) ] -> 
[ LieObject( [ [ 1, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] 
     ] ), 
  LieObject( [ [ 0, 1, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] 
     ] ), 
  LieObject( [ [ 0, 0, 0, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] 
     ] ) ]

gap> STOP_TEST("alg-dsum.tst");
