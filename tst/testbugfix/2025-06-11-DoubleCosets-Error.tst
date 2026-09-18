gap> S := SymmetricGroup( 4 );; A := AlternatingGroup( 4 );;
gap> DoubleCosets( A, S, A );
Error, not contained
gap> DoubleCosets( A, A, S );
Error, not contained
gap> DoubleCosets( A, S, S );
Error, not contained
