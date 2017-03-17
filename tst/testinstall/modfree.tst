#############################################################################
##
#W  modfree.tst                 GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
gap> START_TEST("modfree.tst");
gap> u:= LeftModuleByGenerators( GF(3), [ [ Z(3), 0*Z(3) ] ] );
<vector space over GF(3), with 1 generators>
gap> v:= LeftModuleByGenerators( GF(2), [ [ Z(2), Z(2) ], [ Z(4), Z(4) ] ] );
<vector space over GF(2), with 2 generators>
gap> w:= LeftModuleByGenerators( GF(4), [ [ Z(2), Z(2) ] ] );
<vector space over GF(2^2), with 1 generators>
gap> u = v;
false
gap> v = u;
false
gap> v = w;
true
gap> v1:= LeftModuleByGenerators( GF(2), [ [Z(2),0*Z(2)], [0*Z(2),Z(2)] ] );
<vector space over GF(2), with 2 generators>
gap> v2:= LeftModuleByGenerators( GF(2), [ [Z(2),Z(2)], [Z(2),0*Z(2)] ] );
<vector space over GF(2), with 2 generators>
gap> v1 = v2;
true
gap> v < w;
false
gap> w < v;
false
gap> w < v1;
false
gap> v2 < w;
true
gap> Zero( v ) in v;
true
gap> IsFiniteDimensional( v );
true
gap> IsFiniteDimensional( Integers^3 );
true
gap> IsFinite( v );
true
gap> IsFinite( Integers^3 );
false
gap> IsTrivial( v );
false
gap> IsTrivial( TrivialSubspace( v ) );
true
gap> Size( v );
4
gap> Size( Integers^4 );
infinity
gap> enum:= Enumerator( v );
<enumerator of <vector space of dimension 2 over GF(2)>>
gap> len:= Length( enum );
4
gap> l:= [];;
gap> for i in [ 1 .. len ] do
>   l[i]:= enum[i];
> od;
gap> Print(l,"\n");
[ [ 0*Z(2), 0*Z(2) ], [ Z(2^2), Z(2^2) ], [ Z(2)^0, Z(2)^0 ], 
  [ Z(2^2)^2, Z(2^2)^2 ] ]
gap> ForAll( [ 1 .. len ], i -> i = Position( enum, enum[i], 0 ) );
true
gap> v:= LeftModuleByGenerators( GF(2), [ [ Z(2), Z(2) ], [ Z(4), Z(4) ] ] );
<vector space over GF(2), with 2 generators>
gap> Print(AsList( v ),"\n");
[ [ 0*Z(2), 0*Z(2) ], [ Z(2)^0, Z(2)^0 ], [ Z(2^2), Z(2^2) ], 
  [ Z(2^2)^2, Z(2^2)^2 ] ]
gap> Print(AsSSortedList( v ),"\n");
[ [ 0*Z(2), 0*Z(2) ], [ Z(2)^0, Z(2)^0 ], [ Z(2^2), Z(2^2) ], 
  [ Z(2^2)^2, Z(2^2)^2 ] ]
gap> IsSubset( v, w );
true
gap> IsSubset( w, v );
true
gap> IsSubset( v, v1 );
false
gap> IsSubset( v, v2 );
false
gap> IsSubset( v1, GF(2)^2 );
true
gap> IsSubset( GF(2)^2, v1 );
true
gap> IsSubset( w, GF(2)^2 );
false
gap> IsSubset( GF(2)^2, w );
false
gap> IsSubset( w, GF(4)^2 );
false
gap> IsSubset( GF(4)^2, w );
true
gap> Dimension( v );
2
gap> Dimension( Integers^4 );
4
gap> GeneratorsOfLeftModule( Rationals^2 );
[ [ 1, 0 ], [ 0, 1 ] ]
gap> enum:= Enumerator( v );;
gap> Print(enum,"\n");
[ [ 0*Z(2), 0*Z(2) ], [ Z(2)^0, Z(2)^0 ], [ Z(2^2), Z(2^2) ], 
  [ Z(2^2)^2, Z(2^2)^2 ] ]
gap> iter:= Iterator( v );
<iterator>
gap> l:= [];;
gap> for i in [ 1 .. len ] do
>      l[i]:= NextIterator( iter );
>    od;
gap> IsDoneIterator( iter );
true
gap> enum:= Enumerator( Integers^3 );
<enumerator of ( Integers^3 )>
gap> l:= [];;
gap> for i in [ 1000 .. 1100 ] do
>      Add( l, enum[i] );
>    od;
gap> Print(l{ [ 17 .. 25 ] },"\n");
[ [ -5, 3, 1 ], [ -5, -3, 1 ], [ -5, 4, 1 ], [ -5, -4, 1 ], [ -5, 5, 1 ], 
  [ -5, 0, -1 ], [ -5, 1, -1 ], [ -5, -1, -1 ], [ -5, 2, -1 ] ]
gap> ForAll( [ 1 .. 1000 ], i -> i = Position( enum, enum[i], 0 ) );
true
gap> iter:= Iterator( Integers^3 );
<iterator>
gap> NextIterator( iter );
[ 0, 0, 0 ]
gap> NextIterator( iter );
[ 1, 0, 0 ]
gap> NextIterator( iter );
[ 0, 1, 0 ]
gap> for i in [ 1 .. 1000 ] do
>      NextIterator( iter );
>    od;
gap> l:= [];;
gap> for i in [ 1 .. 10 ] do
>      l[i]:= NextIterator( iter );
>    od;
gap> Print(l,"\n");
[ [ -5, 2, 0 ], [ -5, -2, 0 ], [ -5, 3, 0 ], [ -5, -3, 0 ], [ -5, 4, 0 ], 
  [ -5, -4, 0 ], [ -5, 5, 0 ], [ -5, 0, 1 ], [ -5, 1, 1 ], [ -5, -1, 1 ] ]
gap> IsDoneIterator( iter );
false
gap> v:= LeftModuleByGenerators( GF(2), [ [ Z(2), Z(2) ], [ Z(4), Z(4) ] ] );
<vector space over GF(2), with 2 generators>
gap> c:= ClosureLeftModule( v, [ 0*Z(2), Z(2) ] );
<vector space over GF(2), with 3 generators>
gap> c:= ClosureLeftModule( c, [ Z(4), 0*Z(2) ] );
<vector space over GF(2), with 4 generators>
gap> Dimension( c );
4
gap> FreeLeftModule( Integers, [ [ 1, 0 ], [ 1, 1 ] ] );
<free left module over Integers, with 2 generators>
gap> f:= FreeLeftModule( Integers, [ [ 1, 0 ], [ 1, 1 ] ], "basis" );
<free left module over Integers, with 2 generators>
gap> FreeLeftModule( Integers, [ [ 1, 0 ], [ 1, 1 ] ], [ 0, 0 ] );
<free left module over Integers, with 2 generators>
gap> FreeLeftModule( Integers, [ [ 1, 0 ], [ 1, 1 ] ], [ 0, 0 ], "basis" );
<free left module over Integers, with 2 generators>
gap> IsRowModule( f );
true
gap> IsFullRowModule( f );
true
gap> FullRowModule( Integers, 27 );
( Integers^27 )
gap> f:= FullRowModule( GF(27), 27 );
( GF(3^3)^27 )
gap> GF(27)^27 = f;
true
gap> Dimension( f );
27
gap> v:= Integers^4;
( Integers^4 )
gap> GeneratorsOfLeftModule( v );
[ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ]
gap> [ 1, 2, 3, 4 ] in v;
true
gap> [ 1, 2, 3, 4 ] / 2 in v;
false
gap> [ 1, 2, 3, 4 ] / 2 in Rationals^4;
true
gap> c:= CanonicalBasis( v );
CanonicalBasis( ( Integers^4 ) )
gap> BasisVectors( c );
[ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ]
gap> Coefficients( c, [ 1, 2, 3, 4 ] );
[ 1, 2, 3, 4 ]
gap> Basis( Integers^2 );
CanonicalBasis( ( Integers^2 ) )
gap> STOP_TEST( "modfree.tst", 1);

#############################################################################
##
#E
