#@local t, prod, irr, red
######################################################################
gap> START_TEST( "example_2.7.2.tst" );

######################################################################
gap> t := CharacterTable("L2(7)");;
gap> prod := Tensored( Irr(t){[2]} , Irr(t){[2,3,4]} );;
gap> Display( MatScalarProducts( Irr(t) , prod ) );
[ [  0,  0,  1,  1,  0,  0 ],
  [  1,  0,  0,  0,  0,  1 ],
  [  0,  0,  1,  0,  1,  1 ] ]

######################################################################
gap> irr := Irr(t){[1,2,3]};
[ Character( CharacterTable( "L3(2)" ), [ 1, 1, 1, 1, 1, 1 ] ), 
  Character( CharacterTable( "L3(2)" ),
  [ 3, -1, 0, 1, E(7)+E(7)^2+E(7)^4, E(7)^3+E(7)^5+E(7)^6 ] ), 
  Character( CharacterTable( "L3(2)" ),
  [ 3, -1, 0, 1, E(7)^3+E(7)^5+E(7)^6, E(7)+E(7)^2+E(7)^4 ] ) ]
gap> prod := Tensored( irr{[2]}, irr{[2,3]} );;
gap> red := Reduced( irr, prod );;

######################################################################
gap> Append( irr, red.irreducibles );    # now irr contains 5 characters
gap> Append( prod , Tensored( irr{[2]} , irr{[4,5]} ));;
gap> red := Reduced( irr , prod );;
gap> Append( irr, red.irreducibles );
gap> Display( t, rec( chars:=irr , powermap:=false) );
L3(2)

     2  3  3  .  2  .  .
     3  1  .  1  .  .  .
     7  1  .  .  .  1  1

       1a 2a 3a 4a 7a 7b

Y.1     1  1  1  1  1  1
Y.2     3 -1  .  1  A /A
Y.3     3 -1  .  1 /A  A
Y.4     6  2  .  . -1 -1
Y.5     8  . -1  .  1  1
Y.6     7 -1  1 -1  .  .

A = E(7)+E(7)^2+E(7)^4
  = (-1+Sqrt(-7))/2 = b7

######################################################################
gap> STOP_TEST( "example_2.7.2.tst" );
