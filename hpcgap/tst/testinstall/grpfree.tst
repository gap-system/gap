#############################################################################
##
#W  grpfree.tst                GAP-4 library                    Thomas Breuer
##
##
#Y  Copyright 1997,    Lehrstuhl D für Mathematik,   RWTH Aachen,    Germany
##
gap> START_TEST("grpfree.tst");
gap> g:= FreeGroup( "a", "b" );
<free group on the generators [ a, b ]>
gap> IsWholeFamily( g );
true
gap> IsFinite( g );
false
gap> Size( g );
infinity
gap> Order( g.1 );
infinity
gap> Order( One(g) );
1
gap> gens:= GeneratorsOfGroup( g );
[ a, b ]
gap> a:= gens[1];; b:= gens[2];;
gap> firstfifty:=[];;
gap> iter:= Iterator( g );;
gap> for i in [ 1 .. 50 ] do
>   Add( firstfifty, NextIterator( iter ) );
> od;
gap> Collected(List(firstfifty,Length));
[ [ 0, 1 ], [ 1, 4 ], [ 2, 12 ], [ 3, 33 ] ]
gap> IsDoneIterator( iter );
false
gap> enum:= Enumerator( g );;
gap> first50:=List( [ 1 .. 50 ], x -> enum[x] );;
gap> Print(first50,"\n");
[ <identity ...>, a, a^-1, b, b^-1, a^2, a^-2, b*a, b^-1*a, a*b, a^-1*b, 
  b*a^-1, b^-1*a^-1, a*b^-1, a^-1*b^-1, b^2, b^-2, a^3, a^-3, b*a^2, 
  b^-1*a^2, a*b*a, a^-1*b*a, b*a^-2, b^-1*a^-2, a*b^-1*a, a^-1*b^-1*a, b^2*a, 
  b^-2*a, a^2*b, a^-2*b, b*a*b, b^-1*a*b, a*b*a^-1, a^-1*b*a^-1, b*a^-1*b, 
  b^-1*a^-1*b, a*b^-1*a^-1, a^-1*b^-1*a^-1, b^2*a^-1, b^-2*a^-1, a^2*b^-1, 
  a^-2*b^-1, b*a*b^-1, b^-1*a*b^-1, a*b^2, a^-1*b^2, b*a^-1*b^-1, 
  b^-1*a^-1*b^-1, a*b^-2 ]
gap> List( first50, x -> Position( enum, x ) ) = [ 1 .. 50 ];
true
gap> STOP_TEST( "grpfree.tst", 1);

#############################################################################
##
#E
