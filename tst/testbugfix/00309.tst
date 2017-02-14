# 2015/01/11 (CJ, reported by TB)
gap> x:= rec( qq:= "unused", r:= rec() );;
gap> y:= x.r;;
gap> y.entries:= rec( parent:= y );;
gap> x;
rec( qq := "unused", r := rec( entries := rec( parent := ~.r ) ) )
