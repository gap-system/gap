# 2013/03/08 (MH)
gap> v:=[ Z(2^4)^3, Z(2^4)^6, Z(2)^0 ];
[ Z(2^4)^3, Z(2^4)^6, Z(2)^0 ]
gap> ConvertToVectorRepNC(v,256);
256
gap> RepresentationsOfObject(v);
[ "IsDataObjectRep", "Is8BitVectorRep" ]
gap> R:=PolynomialRing( GF(2^8) );
GF(2^8)[x_1]
gap> x := Indeterminate(GF(2^8));
x_1
gap> f := x^2+Z(2^4)^6*x+Z(2^4)^3;
x_1^2+Z(2^4)^6*x_1+Z(2^4)^3
gap> Length( FactorsSquarefree( R, f, rec() ) );
2
