#@local centre,img,m,membrm,r,rembrm,rm,M,rmgens,preimgs
gap> START_TEST("mgmring.tst");

#
gap> r:= GF(3);;
gap> m:= Group( (1,2,3), (1,2) );;
gap> rm:= FreeMagmaRing( r, m );
<algebra-with-one over GF(3), with 2 generators>
gap> ElementOfMagmaRing( ElementsFamily( FamilyObj( rm ) ), 0*Z(3),
>    [ 0, 1, 1, 1, -1, 1, -1 ]*Z(3)^0,
>    [ (), (2,3), (1,2,3), (2,3), (1,2), (1,2), (1,3,2) ] );
(Z(3))*(2,3)+(Z(3)^0)*(1,2,3)+(Z(3))*(1,3,2)
gap> IsGroupRing( rm );
true
gap> centre:= Centre( rm );
<algebra-with-one of dimension 3 over GF(3)>
gap> AsSet( GeneratorsOfAlgebra( centre ) );
[ (Z(3)^0)*(), (Z(3)^0)*(2,3)+(Z(3)^0)*(1,2)+(Z(3)^0)*(1,3), 
  (Z(3)^0)*(1,2,3)+(Z(3)^0)*(1,3,2) ]
gap> membrm:= Embedding( m, rm );;
gap> img:= Image( membrm, (1,2) );
(Z(3)^0)*(1,2)
gap> PreImagesRepresentative( membrm, img );
(1,2)
gap> rembrm:= Embedding( r, rm );;
gap> img:= Image( rembrm, Z(3) );
(Z(3))*()
gap> PreImagesRepresentative( rembrm, img );
Z(3)

# infinite group and ring
gap> r:= Rationals;;
gap> M:= GL( 2, Integers );;
gap> m:= SL( 2, Integers );;
gap> rm:= GroupRing( r, m );;

# embedding of the group
gap> membrm:= Embedding( m, rm );;
gap> rmgens:= GeneratorsOfAlgebra( rm );;
gap> preimgs:= List( rmgens, x -> PreImagesRepresentative( membrm, x ) );;
gap> IsSubset( m, preimgs );
true
gap> Concatenation( List( rmgens, x -> PreImagesElm( membrm, x ) ) ) = preimgs;
true
gap> PreImagesRepresentative( membrm, 2 * One( rm ) );
fail
gap> PreImagesElm( membrm, 2 * One( rm ) );
[  ]
gap> M.1 in m;
false
gap> PreImagesRepresentative( membrm, M.1 * One( rm ) );
Error, <elm> is not in the range of the mapping <emb>
gap> PreImagesElm( membrm, M.1 * One( rm ) );
Error, <elm> is not in the range of mapping <emb>

# embedding of the ring
gap> rembrm:= Embedding( r, rm );;
gap> PreImagesElm( rembrm, 2 * One( rm ) );
[ 2 ]
gap> PreImagesRepresentative( rembrm, 2 * One( rm ) );
2
gap> PreImagesRepresentative( rembrm, 2 * rmgens[2] );
fail
gap> PreImagesElm( rembrm, 2 * rmgens[2] );
[  ]
gap> PreImagesRepresentative( rembrm, E(4) * One( rm ) );
Error, <elm> is not in the range of the mapping <emb>
gap> PreImagesElm( rembrm, E(4) * rmgens[2] );
Error, <elm> is not in the range of mapping <emb>

#
gap> STOP_TEST("mgmring.tst");
