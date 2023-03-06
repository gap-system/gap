#@local t, irr, r, red, y, ll, gram, d, x, dn
######################################################################
# This file contains the code of the examples 2.7.11, 2.8.2, 2.8.12
# in the book.
######################################################################
gap> START_TEST( "example_2.7.11.tst" );

######################################################################
gap>  t := CharacterTable("M12");;
gap> irr := Irr(t){[1,2]};;
gap> Display( t , rec(chars:=irr) );
M12

     2  6  4  6  1  2  5  5  1  2  1  3  3   1   .   .
     3  3  1  1  3  2  .  .  .  1  1  .  .   .   .   .
     5  1  1  .  .  .  .  .  1  .  .  .  .   1   .   .
    11  1  .  .  .  .  .  .  .  .  .  .  .   .   1   1

       1a 2a 2b 3a 3b 4a 4b 5a 6a 6b 8a 8b 10a 11a 11b
    2P 1a 1a 1a 3a 3b 2b 2b 5a 3b 3a 4a 4b  5a 11b 11a
    3P 1a 2a 2b 1a 1a 4a 4b 5a 2a 2b 8a 8b 10a 11a 11b
    5P 1a 2a 2b 3a 3b 4a 4b 1a 6a 6b 8a 8b  2a 11a 11b
   11P 1a 2a 2b 3a 3b 4a 4b 5a 6a 6b 8a 8b 10a  1a  1a

Y.1     1  1  1  1  1  1  1  1  1  1  1  1   1   1   1
Y.2    11 -1  3  2 -1 -1  3  1 -1  . -1  1  -1   .   .

######################################################################
gap> r := Symmetrizations( t, irr{[2]}, 2 );;
gap> red := Reduced( t , irr , r );;
gap> Append( irr, red.irreducibles );
gap> Display( t , rec(chars:=irr,powermap:=false,centralizers:=false) );
M12

       1a 2a 2b 3a 3b 4a 4b 5a 6a 6b 8a 8b 10a 11a 11b

Y.1     1  1  1  1  1  1  1  1  1  1  1  1   1   1   1
Y.2    11 -1  3  2 -1 -1  3  1 -1  . -1  1  -1   .   .
Y.3    54  6  6  .  .  2  2 -1  .  .  .  .   1  -1  -1
Y.4    55 -5 -1  1  1 -1  3  .  1 -1  1 -1   .   .   .

######################################################################
gap> r := Tensored( irr{[2]} , irr{[3,4]} );;
gap> Append( r , Tensored( irr{[3]} , irr{[4]} ) );
gap> Append( r , Symmetrizations( t , irr{[3,4]} , 2 ) );
gap> Append( r , Symmetrizations( t , irr{[2,3,4]} , 3 ) );
gap> red := Reduced( t , irr , r );; r := red.remainders;;
gap> red.irreducibles;
[  ]
gap> SortParallel( List(r , Norm) , r ); List( r , Norm );
[ 2, 2, 2, 4, 4, 22, 25, 26, 26, 87, 6261, 6741, 7500, 8493, 27041, 30265 ]
gap> List( r , x -> x[1] );
[ 154, 165, 320, 474, 485, 1376, 1375, 1257, 1366, 2740, 23425, 24393, 25478, 
  27358, 49017, 51874 ]

######################################################################
gap> Display( MatScalarProducts( t, r{[1..10]} ) );
[ [   2 ],
  [   0,   2 ],
  [   0,   0,   2 ],
  [   2,   0,   2,   4 ],
  [   0,   2,   2,   2,   4 ],
  [   2,   3,   5,   7,   8,  22 ],
  [   1,   4,   5,   6,   9,  22,  25 ],
  [   3,   1,   5,   8,   6,  18,  15,  26 ],
  [   3,   2,   5,   8,   7,  20,  18,  25,  26 ],
  [   5,   5,  10,  15,  15,  43,  44,  35,  39,  87 ] ]
gap> y := r[3] - 1/5*r[7];
ClassFunction( CharacterTable( "M12" ),
 [ 45, 1, 5, -18/5, -18/5, -3/5, 1/5, 0, 2/5, -2/5, 1/5, -1/5, 0, 1, 1 ] )

######################################################################
gap> ll := LLL( t , r );;
gap> ll.irreducibles;
[  ]
gap> ll.norms;
[ 2, 2, 2, 3, 2, 2, 2, 2, 2, 3 ]

######################################################################
gap> r := Filtered( ll.remainders, x-> Norm(x) = 2 );;
gap> gram := MatScalarProducts( t, r, r ) ;; Display (gram) ;
[ [  2,  0,  0,  0,  0,  1,  0,  0 ],
  [  0,  2,  0,  1,  1,  0,  0,  1 ],
  [  0,  0,  2,  0,  0,  1,  1,  0 ],
  [  0,  1,  0,  2,  0,  0,  0,  1 ],
  [  0,  1,  0,  0,  2,  0,  0,  1 ],
  [  1,  0,  1,  0,  0,  2,  1,  0 ],
  [  0,  0,  1,  0,  0,  1,  2,  0 ],
  [  0,  1,  0,  1,  1,  0,  0,  2 ] ]

######################################################################
gap> d := [ r[4]-r[2], r[2], r[5]-r[2], -r[8] ];;
gap> Display( MatScalarProducts( t, d, d ));
[ [   2,  -1,   0,   0 ],
  [  -1,   2,  -1,  -1 ],
  [   0,  -1,   2,   0 ],
  [   0,  -1,   0,   2 ] ]

######################################################################
gap> for x in [ [1,3] , [1,4] , [3,4] ] do
> Print( (d[x[1]][1] + d[x[2]][1]) / 2, " , ");
> od;  Print( "\n" );
-45 , -121/2 , -99/2 , 

######################################################################
gap> dn := DnLattice( t , gram , r );;
gap> dn.irreducibles;
[ Character( CharacterTable( "M12" ),
  [ 120, 0, -8, 3, 0, 0, 0, 0, 0, 1, 0, 0, 0, -1, -1 ] ), 
  Character( CharacterTable( "M12" ),
  [ 11, -1, 3, 2, -1, 3, -1, 1, -1, 0, 1, -1, -1, 0, 0 ] ), 
  Character( CharacterTable( "M12" ),
  [ 45, 5, -3, 0, 3, 1, 1, 0, -1, 0, -1, -1, 0, 1, 1 ] ), 
  Character( CharacterTable( "M12" ),
  [ 55, -5, -1, 1, 1, 3, -1, 0, 1, -1, -1, 1, 0, 0, 0 ] ) ]

######################################################################
gap> Append( irr, dn.irreducibles );
gap> red := Reduced( t, irr, ll.remainders );;
gap> ll := LLL( t , red.remainders );; ll.norms;
[ 2, 2, 2, 2, 2, 2 ]
gap> r := ll.remainders;;
gap> dn := DnLattice( t , MatScalarProducts(t,r,r), r);
rec( gram := [ [ 2 ] ], irreducibles := [ Character( CharacterTable( "M12" ),
      [ 99, -1, 3, 0, 3, -1, -1, -1, -1, 0, 1, 1, -1, 0, 0 ] ), 
      Character( CharacterTable( "M12" ),
      [ 55, -5, 7, 1, 1, -1, -1, 0, 1, 1, -1, -1, 0, 0, 0 ] ), 
      Character( CharacterTable( "M12" ),
      [ 66, 6, 2, 3, 0, -2, -2, 1, 0, -1, 0, 0, 1, 0, 0 ] ), 
      Character( CharacterTable( "M12" ),
      [ 144, 4, 0, 0, -3, 0, 0, -1, 1, 0, 0, 0, -1, 1, 1 ] ), 
      Character( CharacterTable( "M12" ),
      [ 176, -4, 0, -4, -1, 0, 0, 1, -1, 0, 0, 0, 1, 0, 0 ] ) ], 
  remainders := [ [ 32, 8, 0, -4, 2, 0, 0, 2, 2, 0, 0, 0, -2, -1, -1 ] ] )

######################################################################
gap> STOP_TEST( "example_2.7.11.tst" );
