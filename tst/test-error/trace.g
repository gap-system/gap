m:=ImmutableMatrix(GF(2),IdentityMat(2,GF(2)));;

InverseMutable(m);
TraceMethods(InverseMutable);
InverseMutable(m);

AdditiveInverseMutable(m);
TraceMethods(AdditiveInverseMutable);
AdditiveInverseMutable(m);

g:= Group( (1,2,3), (1,2) );;  Size( g );
TraceMethods( [ Size ] );
Size(g);
UntraceMethods( [ Size ] );
