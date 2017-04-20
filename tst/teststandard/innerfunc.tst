gap> START_TEST("innerfunc.tst");
gap> len := 100000;;
gap> captureLocal := function(val)
>        local x;
>        x := val;
>        return function() return x; end;
>    end;;
gap> list1 := List([1..len], captureLocal);;
gap> y := List(list1, z -> z());;
gap> y = [1..len];
true
gap> GASMAN("collect");
gap> y := List(list1, z -> z());;
gap> y = [1..len];
true
gap> deepCaptureLocal := function(val)
>        local x;
>        x := val;
>        return function() return function() return x; end; end;
>    end;;
gap> list2 := List([len+1..len*2], deepCaptureLocal);;
gap> y := List(list2, z -> z()());;
gap> y = [len+1..len*2];
true
gap> GASMAN("collect");
gap> y := List(list2, z -> z()());;
gap> y = [len+1..len*2];
true
gap> changeCaptureLocal := function(val)
>        local x;
>        return [
>                   function(newval) x := newval; end,
>                   function() return x; end,
>                   function() return function() return x; end; end
>               ];
>    end;;
gap> list3 := List([len*2+1..len*3], changeCaptureLocal);;
gap> list3[1][2]();
Error, Variable: 'x' must have an assigned value

# Set all the variables
gap> for i in [1..len] do list3[i][1](i+len*2); od;
gap> y := List(list3, z -> z[2]());;
gap> y = [len*2+1..len*3];
true
gap> y := List(list3, z -> z[3]()());;
gap> y = [len*2+1..len*3];
true
gap> GASMAN("collect");
gap> y := List(list3, z -> z[2]());;
gap> y = [len*2+1..len*3];
true
gap> y := List(list3, z -> z[3]()());;
gap> y = [len*2+1..len*3];
true

# Let's test no list got corrupted during our tests
gap> y := List(list1, z -> z());;
gap> y = [1..len];
true
gap> y := List(list2, z -> z()());;
gap> y = [len+1..len*2];
true
gap> STOP_TEST("info.tst", 1);
