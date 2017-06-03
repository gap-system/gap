gap> START_TEST("objmap.tst");
gap> OBJ_MAP([]);
OBJ_MAP([  ])
gap> OBJ_MAP([1]);
Error, OBJ_MAP: Argument must be a list with even length
gap> OBJ_MAP([1,2]);
OBJ_MAP([ 1, 2 ])
gap> a := OBJ_MAP([(1,2), (3,4)]);
OBJ_MAP([ (1,2), (3,4) ])
gap> b := OBJ_MAP([(1,2),(1,2),(1,2),(1,2)]);
OBJ_MAP([ (1,2), (1,2), (1,2), (1,2) ])
gap> c := OBJ_MAP([1,2,1,3,1,4,1,5]);
OBJ_MAP([ 1, 5 ])
gap> OBJ_MAP_KEYS(a);
[ (1,2) ]
gap> OBJ_MAP_VALUES(a);
[ (3,4) ]
gap> OBJ_MAP_KEYS(b);
[ (1,2), (1,2) ]
gap> OBJ_MAP_VALUES(b);
[ (1,2), (1,2) ]
gap> OBJ_MAP_KEYS(c);
[ 1 ]
gap> OBJ_MAP_VALUES(c);
[ 5 ]
gap> p := (1,2);;
gap> FIND_OBJ_MAP(b, p, "cheese");
"cheese"
gap> CONTAINS_OBJ_MAP(b, p);
false
gap> ADD_OBJ_MAP(b, p, (1,2));
gap> b;
OBJ_MAP([ (1,2), (1,2), (1,2), (1,2), (1,2), (1,2) ])
gap> FIND_OBJ_MAP(b, p, "cheese");
(1,2)
gap> CONTAINS_OBJ_MAP(b, p);
true
gap> REMOVE_OBJ_MAP(b, p);
gap> b;
OBJ_MAP([ (1,2), (1,2), (1,2), (1,2) ])
gap> FIND_OBJ_MAP(b, p, "cheese");
"cheese"
gap> CONTAINS_OBJ_MAP(b, p);
false
gap> ADD_OBJ_MAP(b, p, (1,2));
gap> b;
OBJ_MAP([ (1,2), (1,2), (1,2), (1,2), (1,2), (1,2) ])
gap> FIND_OBJ_MAP(b, p, "cheese");
(1,2)
gap> CONTAINS_OBJ_MAP(b, p);
true
gap> CLEAR_OBJ_MAP(b);
gap> b;
OBJ_MAP([  ])
gap> FIND_OBJ_MAP(b, p, "cheese");
"cheese"
gap> CONTAINS_OBJ_MAP(b, p);
false
gap> x := OBJ_MAP();
OBJ_MAP([  ])
gap> MAPvals := 10;;
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
gap> STOP_TEST( "objmap.tst", 1);
