gap> START_TEST("alg-dsum.tst");
gap> # direct sums of type "basis vectors"
gap> QA := QuaternionAlgebra( Rationals );;
gap> SetName( QA, "QA" );
gap> basQ := BasisVectors( Basis( QA ) );
[ e, i, j, k ]
gap> OA := OctaveAlgebra( Rationals );;
gap> SetName( OA, "OA" );
gap> basO := BasisVectors( Basis( OA ) );
[ s1, t1, s2, t2, s3, t3, s4, t4 ]
gap> D := DirectSumOfAlgebras( QA, OA );;
gap> basD := BasisVectors( Basis( D ) );
[ v.1, v.2, v.3, v.4, v.5, v.6, v.7, v.8, v.9, v.10, v.11, v.12 ]
gap> infoD := DirectSumInfo( D );
rec( algebras := [ QA, OA ], embeddings := [  ], first := [ 0, 4, 12 ], 
  projections := [  ], type := "basis vectors" )
gap> embQ := Embedding( D, 1 );
CanonicalBasis( QA ) -> [ v.1, v.2, v.3, v.4 ]
gap> ImageElm( embQ, 3*basQ[2]+4*basQ[3] );
(3)*v.2+(4)*v.3
gap> proO := Projection( D, 2 );
CanonicalBasis( <algebra of dimension 12 over Rationals> ) -> 
[ 0*s1, 0*s1, 0*s1, 0*s1, s1, t1, s2, t2, s3, t3, s4, t4 ]
gap> ImageElm( proO, 6*basD[8]+7*basD[9] ); 
(6)*t2+(7)*s3
gap> #---------------------------------
gap> # direct sums of type "generators"
gap> # in these examples the generating set of the direct sum
gap> # is the concatenation of the generators of the summands
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
gap> emb1 := Embedding( A12, 1 );
[ [ [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ 1, 0, 0, 0 ] ] ] -> 
[ 
  [ [ 0, 1, 0, 0, 0, 0, 0 ], [ 0, 0, 1, 0, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0, 0 ], 
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
gap> # D has type "basis vectors" and A12 has type "generators"
gap> # so D4 has type "basis vectors"
gap> D4 := DirectSumOfAlgebras( D, A12 );;
gap> infoD4 := DirectSumInfo( D4 );
rec( algebras := [ <algebra of dimension 12 over Rationals>, A12 ], 
  embeddings := [  ], first := [ 0, 12, 25 ], projections := [  ], 
  type := "basis vectors" )
gap> QAA1 := DirectSumOfAlgebras( QA, A1 );;
gap> infoQAA1 := DirectSumInfo( QAA1 );
rec( algebras := [ QA, A1 ], embeddings := [  ], first := [ 0, 4, 8 ], 
  projections := [  ], type := "basis vectors" )
gap> Embedding( QAA1, 2 );
Basis( A1, 
[ [ [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ 1, 0, 0, 0 ] ], 
  [ [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ] ], 
  [ [ 0, 0, 0, 1 ], [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ] ], 
  [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ] ] ) -> 
[ v.5, v.6, v.7, v.8 ]
gap> Embedding( QAA1, 1 );
CanonicalBasis( QA ) -> [ v.1, v.2, v.3, v.4 ]
gap> Projection( QAA1, 1 );
CanonicalBasis( <algebra of dimension 8 over Rationals> ) -> 
[ e, i, j, k, 0*e, 0*e, 0*e, 0*e ]
gap> Projection( QAA1, 2 );
CanonicalBasis( <algebra of dimension 8 over Rationals> ) -> 
[ [ [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] ], 
  [ [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] ], 
  [ [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ 1, 0, 0, 0 ] ], 
  [ [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ] ], 
  [ [ 0, 0, 0, 1 ], [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ] ], 
  [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ] ]
gap> A2OA := DirectSumOfAlgebras( A2, OA );;
gap> e := Embedding( A2OA, 1 );;  p := Projection( A2OA, 1 );;
gap> ForAll( BasisVectors( Basis( A2 ) ), x -> ( x ^ e ) ^ p = x );
true
gap> ForAll( BasisVectors( Basis( OA ) ), y -> IsZero( ( y ^ Embedding( A2OA, 2 ) ) ^ p ) );
true
gap> # A1 and A2 know their bases by now
gap> A12Q := DirectSumOfAlgebras( [ A1, A2, QA ] );;
gap> Dimension( A12Q );
17
gap> DirectSumInfo( A12Q ).first;
[ 0, 13, 17 ]
gap> e := Embedding( A12Q, 2 );;  p := Projection( A12Q, 2 );;
gap> ForAll( BasisVectors( Basis( QA ) ), x -> ( x ^ e ) ^ p = x );
true
gap> # ---------------------------------
gap> # direct sums of type "group rings"
gap> # here the generators of the summands may be mixed together
gap> gend8 := [ (5,6,7,8), (6,8) ];;
gap> d8 := Group( gend8 );;
gap> SetName( d8, "d8" );;
gap> Ad8 := GroupRing( Rationals, d8 );;
gap> SetName( Ad8, "Ad8" );;
gap> ed8 := Embedding( d8, Ad8 );;
gap> gens3 := [ (1,2), (2,3) ];;
gap> s3 := Group( gens3 );;
gap> SetName( s3, "s3" );;
gap> As3 := GroupRing( Rationals, s3 );;
gap> SetName( As3, "As3" );;
gap> es3 := Embedding( s3, As3 );;
gap> A83 := DirectSumOfAlgebras( Ad8, As3 );;
gap> gen83 := GeneratorsOfAlgebra( A83 );
[ (1)*(), (1)*(1,2,3,4), (1)*(2,4), (1)*(5,6), (1)*(6,7) ]
gap> info83 := DirectSumInfo( A83 );
rec( algebras := [ Ad8, As3 ], embeddings := [  ], first := [ 0, 3, 5 ], 
  projections := [  ], type := "group rings" )
gap> SetName( A83, "A83" );
gap> embd8 := Embedding( A83, 1 );
[ (1)*(), (1)*(5,6,7,8), (1)*(6,8) ] -> [ (1)*(), (1)*(1,2,3,4), (1)*(2,4) ]
gap> g := ImageElm( ed8, (5,8)(6,7) );
(1)*(5,8)(6,7)
gap> ImageElm( embd8, g );
(1)*(1,4)(2,3)
gap> embs3 := Embedding( A83, 2 );
[ (1)*(), (1)*(1,2), (1)*(2,3) ] -> [ (1)*(), (1)*(5,6), (1)*(6,7) ]
gap> prod8 := Projection( A83, 1 );
[ (1)*(), (1)*(1,2,3,4), (1)*(2,4), (1)*(5,6), (1)*(6,7) ] -> 
[ (1)*(), (1)*(5,6,7,8), (1)*(6,8), <zero> of ..., <zero> of ... ]
gap> pros3 := Projection( A83, 2 );
[ (1)*(), (1)*(1,2,3,4), (1)*(2,4), (1)*(5,6), (1)*(6,7) ] -> 
[ (1)*(), <zero> of ..., <zero> of ..., (1)*(1,2), (1)*(2,3) ]
gap> ImageElm( pros3, gen83[4]*gen83[5] );
(1)*(1,3,2)
gap> # with free groups the generators get really mixed up
gap> # so the value [0,5,11] of first is only useful for the 11
gap> f2 := FreeGroup( 2 );;
gap> SetName( f2, "f2" );
gap> Af2 := GroupRing( GF(5), f2 );;
gap> SetName( Af2, "Af2" );
gap> f3 := FreeGroup( 3 );;
gap> SetName( f3, "f3" );
gap> Af3 := GroupRing( GF(5), f3 );;
gap> SetName( Af3, "Af3" );
gap> Af23 := DirectSumOfAlgebras( Af2, Af3 );
<algebra-with-one over GF(5), with 10 generators>
gap> gen23 := GeneratorsOfAlgebra( Af23 );
[ (Z(5)^0)*<identity ...>, (Z(5)^0)*f1, (Z(5)^0)*f2, (Z(5)^0)*f3, 
  (Z(5)^0)*f4, (Z(5)^0)*f5, (Z(5)^0)*f1^-1, (Z(5)^0)*f2^-1, (Z(5)^0)*f3^-1, 
  (Z(5)^0)*f4^-1, (Z(5)^0)*f5^-1 ]
gap> info23 := DirectSumInfo( Af23 );
rec( algebras := [ Af2, Af3 ], embeddings := [  ], first := [ 0, 5, 11 ], 
  projections := [  ], type := "group rings" )
gap> # Embedding & Projection fail for now - waiting for PR6798 to be merged
gap> # ---------------------------------
gap> # Lie algebra example
gap> L := FullMatrixLieAlgebra( Rationals, 2 );
<Lie algebra over Rationals, with 3 generators>
gap> SetName( L, "L" );
gap> L2 := DirectSumOfAlgebras( L, L );
<Lie algebra over Rationals, with 6 generators>
gap> x := GeneratorsOfAlgebra( L2 )[1];;  y := GeneratorsOfAlgebra( L2 )[2];;
gap> x * y = - ( y * x );
true
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
gap> Projection( L2, 2 );
[ LieObject( [ [ 1, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] 
     ] ), 
  LieObject( [ [ 0, 1, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] 
     ] ), 
  LieObject( [ [ 0, 0, 0, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] 
     ] ), 
  LieObject( [ [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 0 ] 
     ] ), 
  LieObject( [ [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 1 ], [ 0, 0, 0, 0 ] 
     ] ), 
  LieObject( [ [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 1, 0 ] 
     ] ) ] -> [ LieObject( [ [ 0, 0 ], [ 0, 0 ] ] ), 
  LieObject( [ [ 0, 0 ], [ 0, 0 ] ] ), LieObject( [ [ 0, 0 ], [ 0, 0 ] ] ), 
  LieObject( [ [ 1, 0 ], [ 0, 0 ] ] ), LieObject( [ [ 0, 1 ], [ 0, 0 ] ] ), 
  LieObject( [ [ 0, 0 ], [ 1, 0 ] ] ) ]
gap> STOP_TEST("alg-dsum.tst");
