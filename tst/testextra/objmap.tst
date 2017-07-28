gap> START_TEST("objmap.tst");
gap> x := OBJ_MAP();
OBJ_MAP([  ])
gap> MAPvals := 5000;;
gap> for i in [1..MAPvals] do
> ADD_OBJ_MAP(x, i, i*10);
> if List([1..i], z -> FIND_OBJ_MAP(x,z,-1)) <> [1..i]*10 then
>   Print("Missing Value");
> fi;
> if ForAny([i+1..MAPvals], z -> FIND_OBJ_MAP(x, z, -1) <> -1) then
>   Print("Extra value");
> fi;
> if SortedList(OBJ_MAP_KEYS(x)) <> [1..i] then
>   Print("Invalid OBJ_MAP_KEYS");
> fi;
> if SortedList(OBJ_MAP_VALUES(x)) <> [10,20..i*10] then
>   Print("Invalid OBJ_MAP_VALUES");
> fi;
> od;
gap> for i in [1..MAPvals] do
> REMOVE_OBJ_MAP(x, i);
> if ForAny([1..i], z -> FIND_OBJ_MAP(x, z, -1) <> -1) then
>   Print("Extra Value");
> fi;
> if List([i+1..MAPvals], z -> FIND_OBJ_MAP(x, z,-1)) <> [i+1..MAPvals]*10 then
>   Print("Missing value");
> fi;
> if SortedList(OBJ_MAP_KEYS(x)) <> [i+1..MAPvals] then
>   Print("Invalid OBJ_MAP_KEYS");
> fi;
> if SortedList(OBJ_MAP_VALUES(x)) <> [i+1..MAPvals]*10 then
>   Print("Invalid OBJ_MAP_VALUES");
> fi;
> od;
gap> y := OBJ_MAP([]);
OBJ_MAP([  ])
gap> for i in [1..MAPvals] do
> ADD_OBJ_MAP(y, [i,[i]], [i,[i,i]]);
> od;
gap> GASMAN("collect");
gap> keyresult := List([1..MAPvals], x -> [x,[x]]);;
gap> valresult := List([1..MAPvals], x -> [x,[x,x]]);;
gap> SortedList(OBJ_MAP_KEYS(y)) = keyresult;
true
gap> SortedList(OBJ_MAP_VALUES(y)) = valresult;
true
gap> STOP_TEST( "objmap.tst", 1);
