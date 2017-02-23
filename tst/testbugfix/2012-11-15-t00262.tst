# 2012/11/15 (SL)
gap> x := ZmodnZObj(2,10);
ZmodnZObj( 2, 10 )
gap> y := ZmodnZObj(0,10);
ZmodnZObj( 0, 10 )
gap> x/y;
fail
gap> y/x;
fail
gap> x/0;
fail
gap> 3/y;
fail
