#@local G, K, KG, o, a, b, V, B, g, dg, c, d, B1, B2, adbas, x, BB
#@local m1, m2
######################################################################
gap> START_TEST( "example_1.1.49.tst" );

######################################################################
gap> G  := Group( (1,2), (1,2,3,4) );;   K := Rationals;;
gap> KG := GroupRing( K, G );;           o := Embedding( G, KG  );;

######################################################################
gap> a := ()^o + (1,2,3)^o + (1,3,2)^o;;
gap> Print( a*(1,2)^o ,",   ", a*(()^o - (1,2,3)^o) ,",   ", a*a = 3*a,
>           "\n" );
(1)*(2,3)+(1)*(1,2)+(1)*(1,3),   <zero> of ...,   true

######################################################################
gap> Set( List( G, g -> Dimension( LeftIdeal (KG, [()^o - g^o]) ) ) );
[ 0, 12, 16, 18 ]
gap> Filtered(G, g -> Dimension( LeftIdeal (KG, [()^o - g^o] ) ) = 12 );
[ (3,4), (2,4), (2,3), (1,4)(2,3), (1,4), (1,2)(3,4), (1,2), (1,3)(2,4), 
  (1,3) ]
gap> a := ()^o - (1,2)^o;;

######################################################################
gap> Set(List(G, g -> Dimension( LeftIdeal (KG, [(() - g^o) * a] ) ) ) );
[ 0, 6, 8, 9, 11, 12 ]
gap> Filtered(G, g -> Dimension( LeftIdeal (KG, [(() - g^o) * a] ) )= 6);
[ (3,4), (1,2)(3,4) ]
gap> b := (()^o - (3,4)^o) * a;;
gap> V := LeftIdeal (KG, [b]);; B := Basis (V);;

######################################################################
gap> g := (1,2,3);;  # for example
gap> dg := TransposedMat(List( B, v -> Coefficients( B, ((g^-1)^o*v) )));;

######################################################################
gap> c:= (()^o - (2,4,3)^o) * b;;    d:= (()^o - (1,4)^o) * c;;
gap> B1 := Basis ( LeftIdeal (KG, [c]) );;
gap> B2 := Basis ( LeftIdeal (KG, [d] ));;

######################################################################
gap> adbas := [];; Append( adbas, BasisVectors(B2) );
gap> for x in BasisVectors(B1) do
>       if not x in Subspace( KG, adbas )  then Add(adbas ,x); fi;
>    od;
gap> for x in BasisVectors(B) do
>       if not x in Subspace( KG, adbas )  then Add(adbas ,x); fi;
>    od;
gap> BB := Basis ( V , adbas );;

######################################################################
gap> m1 := List( BB, x -> Coefficients( BB, (1,2)^o*x) );;
gap> m2 := List( BB, x -> Coefficients( BB, ((1,2,3,4)^-1)^o*x) );;
gap> m1 := TransposedMat(m1);; m2 := TransposedMat(m2);;
gap> PrintArray( m1 );
[ [  -1,   0,   0,   0,   0,   0 ],
  [   1,   1,  -1,   0,   0,   0 ],
  [   0,   0,  -1,   0,   0,   0 ],
  [   0,   0,   0,  -1,   0,   0 ],
  [   0,   0,   0,   1,   1,   0 ],
  [   0,   0,   0,   0,   0,  -1 ] ]
gap> PrintArray( m2 );
[ [   0,   1,  -1,   0,   1,   0 ],
  [   1,   0,   1,   1,   0,   0 ],
  [   2,   0,   1,   1,   0,   0 ],
  [   0,   0,   0,   0,  -1,   1 ],
  [   0,   0,   0,  -1,   0,  -1 ],
  [   0,   0,   0,   0,   0,  -1 ] ]

######################################################################
gap> Size( Group( m1{[1..3]}{[1..3]}, m2{[1..3]}{[1..3]} ) );
24
gap> Size( Group( m1{[4,5]}{[4,5]}, m2{[4,5]}{[4,5]} ) );
6

######################################################################
gap> STOP_TEST( "example_1.1.49.tst" );
