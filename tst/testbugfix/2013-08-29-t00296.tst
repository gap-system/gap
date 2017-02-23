# 2013/08/29 (MH)
gap> record := rec( foo := "bar" );
rec( foo := "bar" )
gap> fooo := "fooo";
"fooo"
gap> Unbind( fooo[4] );
gap> record.(fooo);
"bar"
