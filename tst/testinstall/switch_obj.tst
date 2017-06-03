gap> START_TEST("mptr.tst");
gap> x := [2];;
gap> x2 := x;;
gap> y := [3];;
gap> y2 := y;;
gap> SWITCH_OBJ(x,y);
gap> x = [3];
true
gap> y = [2];
true
gap> IS_IDENTICAL_OBJ(x2,x);
true
gap> IS_IDENTICAL_OBJ(y2,y);
true
gap> GASMAN("collect");
gap> x[1] := (1,2);;
gap> y[1] := (2,3);;
gap> SWITCH_OBJ(x,y);
gap> x = [(2,3)];
true
gap> y = [(1,2)];
true
gap> IS_IDENTICAL_OBJ(x2,x);
true
gap> IS_IDENTICAL_OBJ(y2,y);
true
gap> STOP_TEST( "mptr.tst", 1);
