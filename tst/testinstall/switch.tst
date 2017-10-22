#@local x,x2,y,y2
## Test SWITCH_OBJ and FORCE_SWITCH_OBJ
gap> START_TEST("switch.tst");

#
gap> x := [1];;
gap> y := [2];;
gap> x2 := x;;
gap> y2 := y;;
gap> IsIdenticalObj(x,x2) and IsIdenticalObj(y,y2);
true
gap> IsIdenticalObj(x,y2) or IsIdenticalObj(y,x2);
false
gap> SWITCH_OBJ(x,y);
gap> x = [2] and x2 = [2] and y = [1] and y2 = [1];
true
gap> IsIdenticalObj(x,x2) and IsIdenticalObj(y,y2);
true
gap> IsIdenticalObj(x,y2) or IsIdenticalObj(y,x2);
false
gap> FORCE_SWITCH_OBJ(x,y);
gap> x = [1] and x2 = [1] and y = [2] and y2 = [2];
true
gap> IsIdenticalObj(x,x2) and IsIdenticalObj(y,y2);
true
gap> IsIdenticalObj(x,y2) or IsIdenticalObj(y,x2);
false

#
gap> x := 1;;
gap> FORCE_SWITCH_OBJ(x,y);
Error, small integer objects cannot be switched
gap> x = 1 and x2 = [1] and y = [2] and y2 = [2];
true

#
gap> x := Z(2);;
gap> FORCE_SWITCH_OBJ(x,y);
Error, finite field elements cannot be switched
gap> x = Z(2) and x2 = [1] and y = [2] and y2 = [2];
true

#
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

#
gap> STOP_TEST( "switch.tst", 1);
