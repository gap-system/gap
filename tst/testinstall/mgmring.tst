#@local centre,img,m,membrm,r,rembrm,rm,M,rmgens,preimgs,elm,inv,G,H,F,S,FG,emb
#@local QG,aug,pre,map,com
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

# arithmetics (vs. list arithmetics)
gap> M.1 + One( rm );
(1)*[ [ 0, 1 ], [ 1, 0 ] ]+(1)*[ [ 1, 0 ], [ 0, 1 ] ]
gap> M.1 - One( rm );
(1)*[ [ 0, 1 ], [ 1, 0 ] ]+(-1)*[ [ 1, 0 ], [ 0, 1 ] ]
gap> M.1 * One( rm );
(1)*[ [ 0, 1 ], [ 1, 0 ] ]
gap> One( rm ) + M.1;
(1)*[ [ 0, 1 ], [ 1, 0 ] ]+(1)*[ [ 1, 0 ], [ 0, 1 ] ]
gap> One( rm ) - M.1;
(-1)*[ [ 0, 1 ], [ 1, 0 ] ]+(1)*[ [ 1, 0 ], [ 0, 1 ] ]
gap> One( rm ) * M.1;
(1)*[ [ 0, 1 ], [ 1, 0 ] ]

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
gap> elm:= M.1 * One( rm );
(1)*[ [ 0, 1 ], [ 1, 0 ] ]
gap> elm in Range( membrm );
false
gap> PreImagesRepresentative( membrm, elm );
Error, <elm> is not in the range of the mapping <emb>
gap> PreImagesElm( membrm, elm );
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
gap> elm:= E(4) * One( rm );
(E(4))*[ [ 1, 0 ], [ 0, 1 ] ]
gap> elm in Range( rembrm );
false
gap> PreImagesRepresentative( rembrm, elm );
Error, <elm> is not in the range of the mapping <emb>
gap> PreImagesElm( rembrm, elm );
Error, <elm> is not in the range of mapping <emb>
gap> PreImagesElm( rembrm, Zero( rm ) );
[ 0 ]
gap> PreImagesRepresentative( rembrm, Zero( rm ) );
0
gap> PreImagesElmNC( rembrm, Zero( rm ) );
[ 0 ]
gap> PreImagesRepresentativeNC( rembrm, Zero( rm ) );
0
gap> PreImagesSet( rembrm, [ 2 * One( rm ), Zero( rm ), 2 * rmgens[2] ] );
[ 0, 2 ]
gap> PreImagesSet( rembrm, [ elm ] );
Error, <elms> is not a subset of the range of <map>
gap> PreImagesSet( membrm, [ One( rm ), 2 * One( rm ) ] );
[ [ [ 1, 0 ], [ 0, 1 ] ] ]

# the NC variants handle elements of the range outside the image
gap> PreImagesElmNC( membrm, One( rm ) );
[ [ [ 1, 0 ], [ 0, 1 ] ] ]
gap> PreImagesElmNC( membrm, 2 * One( rm ) );
[  ]
gap> inv:= InverseGeneralMapping( rembrm );;
gap> ImagesRepresentative( inv, 2 * One( rm ) );
2
gap> ImagesRepresentative( inv, Zero( rm ) );
0
gap> ImagesRepresentative( inv, 2 * rmgens[2] );
fail
gap> ImagesElm( inv, 2 * rmgens[2] );
[  ]

# proper subgroup and subring as sources; not a subfield, since
# 'Subring( GF(9), [ Z(3) ] )' sets the parent of the cached 'GF(3)'
gap> G:= SymmetricGroup( 3 );;
gap> H:= Subgroup( G, [ (1,2) ] );;
gap> F:= ZmodnZ( 6 );;
gap> S:= Subring( F, [ ZmodnZObj( 2, 6 ) ] );;
gap> FG:= GroupRing( F, G );;
gap> emb:= Embedding( H, FG );;
gap> PreImagesRepresentative( emb, (1,2) * One( FG ) );
(1,2)
gap> PreImagesRepresentative( emb, (1,2,3) * One( FG ) );
fail
gap> PreImagesElm( emb, (1,2,3) * One( FG ) );
[  ]
gap> emb:= Embedding( S, FG );;
gap> PreImagesRepresentative( emb, ZmodnZObj( 2, 6 ) * One( FG ) );
ZmodnZObj( 2, 6 )
gap> PreImagesRepresentative( emb, One( FG ) );
fail
gap> PreImagesElm( emb, One( FG ) );
[  ]
gap> QG:= GroupRing( Rationals, G );;
gap> PreImagesSet( Embedding( G, QG ), QG ) = AsSet( G );
true

# compositions call the NC variants for elements outside the image
gap> F:= GF(3);; G:= Group( (1,2) );; FG:= GroupRing( F, G );;
gap> aug:= x -> Sum( Filtered( CoefficientsAndMagmaElements( x ), IsFFE ), Zero( F ) );;
gap> pre:= c -> 2 * c * ( (1,2) * One( FG ) ) - c * One( FG );;
gap> map:= MappingByFunction( FG, F, aug, false, pre );;
gap> com:= CompositionMapping( map, Embedding( F, FG ) );;
gap> PreImagesRepresentative( com, Z(3) );
Z(3)

#
gap> STOP_TEST("mgmring.tst");
