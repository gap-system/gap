# AsField with one argument for cyclotomic collections
gap> AsField( CF(4) );
GaussianRationals
gap> AsField( Rationals );
Rationals
gap> F:= AsField( AsField( CF(4), CF(8) ) );
CF(8)
gap> LeftActingDomain( F );
Rationals
gap> AsDivisionRing( Field( [ Sqrt(2) ] ) );
NF(8,[ 1, 7 ])
gap> AsField( Integers );
fail
gap> AsField( GaussianIntegers );
fail
