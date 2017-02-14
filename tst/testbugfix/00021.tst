##  bugs 12 and 14 for fix 4
gap> IsRowVector( [ [ 1 ] ] );
false
gap> IsRowModule( TrivialSubmodule( GF(2)^[2,2] ) );
false
gap> g:=SL(2,5);;c:=Irr(g)[6];;
gap> hom:=IrreducibleRepresentationsDixon(g,c);;
gap> Size(Image(hom));
60
