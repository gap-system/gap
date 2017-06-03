gap> START_TEST("objset.tst");
gap> x := OBJ_SET();
OBJ_SET([  ])
gap> setvals := 5000;;
gap> for i in [1..setvals] do
> ADD_OBJ_SET(x, i);
> if not ForAll([1..i], z -> FIND_OBJ_SET(x, z)) then
>   Print("Missing Value");
> fi;
> if ForAny([i+1..setvals], z -> FIND_OBJ_SET(x, z)) then
>   Print("Extra value");
> fi;
> if SortedList(OBJ_SET_VALUES(x)) <> [1..i] then
>   Print("Invalid OBJ_SET_VALUES");
> fi;
> od;
gap> for i in [1..setvals] do
> REMOVE_OBJ_SET(x, i);
> if ForAny([1..i], z -> FIND_OBJ_SET(x, z)) then
>   Print("Extra Value");
> fi;
> if not ForAll([i+1..setvals], z -> FIND_OBJ_SET(x, z)) then
>   Print("Missing value");
> fi;
> if SortedList(OBJ_SET_VALUES(x)) <> [i+1..setvals] then
>   Print("Invalid OBJ_SET_VALUES");
> fi;
> od;
gap> y := OBJ_SET([]);
OBJ_SET([  ])
gap> for i in [1..setvals] do
> ADD_OBJ_SET(y, [i,[i]]);
> od;
gap> GASMAN("collect");
gap> result := List([1..setvals], x -> [x,[x]]);;
gap> SortedList(OBJ_SET_VALUES(y)) = result;
true
gap> STOP_TEST( "objset.tst", 1);
