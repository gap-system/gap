# Converting an empty GF(2) vector to a larger field raised an error, and
# with it products with FFEs and arithmetic with empty 8-bit vectors.
# See https://github.com/gap-system/gap/issues/2121
gap> e2 := function()
>   local v;
>   v := [ Z(2) ];;  ConvertToVectorRep( v, 2 );;
>   return v{ [ 1 .. 0 ] };
> end;;
gap> u := [ Z(4) ];;  ConvertToVectorRep( u, 4 );;  e4 := u{ [ 1 .. 0 ] };;

#
gap> w := e2();;  ConvertToVectorRep( w, 4 );  w;
4
< mutable compressed vector length 0 over GF(4) >
gap> w := Immutable( e2() );;  ConvertToVectorRepNC( w, GF(16) );  w;
16
< immutable compressed vector length 0 over GF(16) >
gap> w := e2();;  ConvertToVectorRep( w, 3 );
Error, ConvertToVectorRepNC: Vector cannot be written over GF(3)

#
gap> Z(4) * e2();
< mutable compressed vector length 0 over GF(4) >
gap> e2() + e4;
< mutable compressed vector length 0 over GF(4) >
gap> e4 - e2();
< mutable compressed vector length 0 over GF(4) >
gap> e2() * e4;
0*Z(2)
