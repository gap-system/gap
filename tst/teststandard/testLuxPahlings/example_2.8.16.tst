#@local t, irr, r, l, red, M, oe, x_1, ch
######################################################################
gap> START_TEST( "example_2.8.16.tst" );

######################################################################
gap> t := CharacterTable("S5");; irr := Irr(t){[1,2,5]};;
gap> Display( t, rec(chars:=irr, centralizers:=false, powermap:=false) );
A5.2

       1a 2a 3a 5a 2b 4a 6a

Y.1     1  1  1  1  1  1  1
Y.2     1  1  1  1 -1 -1 -1
Y.3     4  .  1 -1 -2  .  1
gap>  r := Tensored( irr, irr );; Append( r, Tensored(irr,r) );
gap>  red := Reduced( irr, r );; Length( red.irreducibles );
1
gap> Append(irr,red.irreducibles); r := red.remainders;; l:=LLL(t,r);;
gap> r := l.remainders;;
gap> M :=  MatScalarProducts( t, r, r );; Display( M );
[ [  2,  1,  1 ],
  [  1,  2,  1 ],
  [  1,  1,  2 ] ]

######################################################################
gap> oe := OrthogonalEmbeddings( M );
rec( norms := [ 1, 1, 1, 3/4, 3/4, 3/4, 3/4 ], 
  solutions := [ [ 1, 2, 3 ], [ 4, 5, 6, 7 ] ], 
  vectors := [ [ 1, 1, 0 ], [ 1, 0, 1 ], [ 0, 1, 1 ], [ 1, 1, 1 ], 
      [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ] )

######################################################################
gap> x_1 := oe.vectors{ oe.solutions[1] } ;; Display(x_1) ;
[ [  1,  1,  0 ],
  [  1,  0,  1 ],
  [  0,  1,  1 ] ]
gap> ch := TransposedMat( x_1^-1 ) * r;
[ ClassFunction( CharacterTable( "A5.2" ), [ 6, -2, 0, 1, 0, 0, 0 ] ), 
  ClassFunction( CharacterTable( "A5.2" ), [ 5, 1, -1, 0, -1, 1, -1 ] ), 
  ClassFunction( CharacterTable( "A5.2" ), [ 5, 1, -1, 0, 1, -1, 1 ] ) ]

######################################################################
gap> OrthogonalEmbeddingsSpecialDimension ( t, r, M, 3);
rec( irreducibles := [ Character( CharacterTable( "A5.2" ),
      [ 5, 1, -1, 0, -1, 1, -1 ] ), Character( CharacterTable( "A5.2" ),
      [ 5, 1, -1, 0, 1, -1, 1 ] ), Character( CharacterTable( "A5.2" ),
      [ 6, -2, 0, 1, 0, 0, 0 ] ) ], remainders := [  ] )

######################################################################
gap> STOP_TEST( "example_2.8.16.tst" );
