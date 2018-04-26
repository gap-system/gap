#
# Tests for functions defined in src/calls.c
#
gap> START_TEST("kernel/calls.tst");

# test DoWrap0args, DoWrap1args, ...
gap> o:={l...} -> l;;
gap> o();
[  ]
gap> o(1);
[ 1 ]
gap> o(1,2);
[ 1, 2 ]
gap> o(1,2,3);
[ 1, 2, 3 ]
gap> o(1,2,3,4);
[ 1, 2, 3, 4 ]
gap> o(1,2,3,4,5);
[ 1, 2, 3, 4, 5 ]
gap> o(1,2,3,4,5,6);
[ 1, 2, 3, 4, 5, 6 ]
gap> o(1,2,3,4,5,6,7);
[ 1, 2, 3, 4, 5, 6, 7 ]

# test DoFail0args, DoFail1args, ...
gap> f:={}->1;;
gap> f(1);
Error, Function: number of arguments must be 0 (not 1)
gap> f(1,2);
Error, Function: number of arguments must be 0 (not 2)
gap> f(1,2,3);
Error, Function: number of arguments must be 0 (not 3)
gap> f(1,2,3,4);
Error, Function: number of arguments must be 0 (not 4)
gap> f(1,2,3,4,5);
Error, Function: number of arguments must be 0 (not 5)
gap> f(1,2,3,4,5,6);
Error, Function: number of arguments must be 0 (not 6)
gap> f(1,2,3,4,5,6,7);
Error, Function: number of arguments must be 0 (not 7)
gap> f:=x->x;;
gap> f();
Error, Function: number of arguments must be 1 (not 0)
gap> f:={x,y,z...}->x;;
gap> f();
Error, Function: number of arguments must be at least 2 (not 0)
gap> f:={a1,a2,a3,a4,a5,a6,a7,a8}->a1;;
gap> f();
Error, Function: number of arguments must be 8 (not 0)
gap> f:={a1,a2,a3,a4,a5,a6,a7,a8,rest...}->a1;;
gap> f();
Error, Function: number of arguments must be at least 8 (not 0)

# test DoProf0args, DoProf1args, ...
gap> o:={l...} -> l;;
gap> ProfileFunctions([o]);
gap> o();
[  ]
gap> o(1);
[ 1 ]
gap> o(1,2);
[ 1, 2 ]
gap> o(1,2,3);
[ 1, 2, 3 ]
gap> o(1,2,3,4);
[ 1, 2, 3, 4 ]
gap> o(1,2,3,4,5);
[ 1, 2, 3, 4, 5 ]
gap> o(1,2,3,4,5,6);
[ 1, 2, 3, 4, 5, 6 ]
gap> o(1,2,3,4,5,6,7);
[ 1, 2, 3, 4, 5, 6, 7 ]
gap> UnprofileFunctions([o]);

#
gap> PROF_FUNC(1);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `PROF_FUNC' on 1 arguments
gap> PROF_FUNC(x->x);
[ 0, 0, 0, 0, 0 ]
gap> CLEAR_PROFILE_FUNC(fail);
Error, <func> must be a function
gap> PROFILE_FUNC(fail);
Error, <func> must be a function
gap> IS_PROFILED_FUNC(fail);
Error, <func> must be a function
gap> IS_PROFILED_FUNC(x->x);
false

#
gap> f:=x->x;;
gap> FILENAME_FUNC(fail);
Error, <func> must be a function
gap> FILENAME_FUNC(f);
"stream"
gap> FILENAME_FUNC(IS_OBJECT);
fail
gap> STARTLINE_FUNC(fail);
Error, <func> must be a function
gap> STARTLINE_FUNC(f);
1
gap> STARTLINE_FUNC(IS_OBJECT);
fail
gap> ENDLINE_FUNC(fail);
Error, <func> must be a function
gap> ENDLINE_FUNC(f);
1
gap> ENDLINE_FUNC(IS_OBJECT);
fail
gap> LOCATION_FUNC(fail);
Error, <func> must be a function
gap> LOCATION_FUNC(f);
fail
gap> LOCATION_FUNC(IS_OBJECT);
fail

#
gap> UNPROFILE_FUNC(fail);
Error, <func> must be a function
gap> UNPROFILE_FUNC(x->x);

#
gap> STOP_TEST("kernel/calls.tst", 1);
