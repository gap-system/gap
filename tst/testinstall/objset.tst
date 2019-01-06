#@local a,b,c,p,setvals,x,i
gap> START_TEST("objset.tst");

# basic constructor
gap> OBJ_SET([]);
OBJ_SET([  ])
gap> OBJ_SET([1]);
OBJ_SET([ 1 ])
gap> OBJ_SET([1,2]);
OBJ_SET([ 1, 2 ])
gap> a := OBJ_SET([(1,2)]);
OBJ_SET([ (1,2) ])
gap> b := OBJ_SET([(1,2),(1,2),(1,2),(1,2)]);
OBJ_SET([ (1,2), (1,2), (1,2), (1,2) ])
gap> c := OBJ_SET([1,2,1,2,1,2,1]);
OBJ_SET([ 1, 2 ])

#
gap> OBJ_SET_VALUES(a);
[ (1,2) ]
gap> OBJ_SET_VALUES(b);
[ (1,2), (1,2), (1,2), (1,2) ]
gap> OBJ_SET_VALUES(c);
[ 1, 2 ]

#
gap> p := (1,2);;
gap> FIND_OBJ_SET(b, p);
false
gap> ADD_OBJ_SET(b, p);
gap> b;
OBJ_SET([ (1,2), (1,2), (1,2), (1,2), (1,2) ])
gap> FIND_OBJ_SET(b, p);
true
gap> REMOVE_OBJ_SET(b, p);
gap> b;
OBJ_SET([ (1,2), (1,2), (1,2), (1,2) ])
gap> FIND_OBJ_SET(b, p);
false
gap> ADD_OBJ_SET(b, p);
gap> b;
OBJ_SET([ (1,2), (1,2), (1,2), (1,2), (1,2) ])
gap> FIND_OBJ_SET(b, p);
true
gap> CLEAR_OBJ_SET(b);
gap> b;
OBJ_SET([  ])
gap> FIND_OBJ_SET(b, p);
false

#
gap> x := OBJ_SET();
OBJ_SET([  ])
gap> setvals := 1000;;
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

#
gap> ADD_OBJ_SET(fail, fail);
Error, ADD_OBJ_SET: <set> must be a mutable object set (not the value 'fail')
gap> REMOVE_OBJ_SET(fail, fail);
Error, REMOVE_OBJ_SET: <set> must be a mutable object set (not the value 'fail\
')
gap> FIND_OBJ_SET(fail, fail);
Error, FIND_OBJ_SET: <set> must be an object set (not the value 'fail')
gap> CLEAR_OBJ_SET(fail);
Error, CLEAR_OBJ_SET: <set> must be a mutable object set (not the value 'fail'\
)
gap> OBJ_SET_VALUES(fail);
Error, OBJ_SET_VALUES: <set> must be an object set (not the value 'fail')
gap> CLEAR_OBJ_SET(fail);
Error, CLEAR_OBJ_SET: <set> must be a mutable object set (not the value 'fail'\
)

#
gap> STOP_TEST( "objset.tst", 1);
