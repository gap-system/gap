# 2005/07/20 (TB)
gap> F:= FreeAssociativeAlgebra( Rationals, 2 );;
gap> IsAssociativeElement( F.1 );
true
gap> F:= FreeAlgebra( Rationals, 2 );;
gap> IsAssociativeElement( F.1 );
false
