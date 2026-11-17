# Sublists of an 8-bit vector reused the type of the source vector, and so
# inherited its stored properties, its immutability, and the lock that pins
# a matrix row to its field.
gap> v := [ Z(4), 0*Z(4), 0*Z(4) ];;
gap> ConvertToVectorRep( v, 4 );
4
gap> MakeImmutable( v );;
gap> IsZero( v );
false
gap> IsZero( v{ [ 2, 3 ] } );
true
gap> IsZero( v{ [ 2 .. 3 ] } );
true
gap> IsMutable( v{ [ 2, 3 ] } );
true
gap> IsMutable( v{ [ 2 .. 3 ] } );
true

#
gap> m := [ [ Z(4), 0*Z(4), 0*Z(4) ] ];;
gap> ConvertToMatrixRep( m, 4 );
4
gap> ConvertToVectorRep( m[1]{ [ 1, 2 ] }, 16 );
16
gap> ConvertToVectorRep( m[1]{ [ 1 .. 2 ] }, 16 );
16
