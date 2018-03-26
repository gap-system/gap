#
gap> SHELL();
Error, SHELL takes 10 arguments
gap> SHELL(1,2,3,4,5,6,7,8,9,10);
Error, SHELL: 1st argument should be a local variables bag
gap> lvars:=GetCurrentLVars();
<lvars bag>
gap> SHELL(lvars,2,3,4,5,6,7,8,9,10);
Error, SHELL: 2nd argument (can return void) should be true or false
gap> SHELL(lvars,true,3,4,5,6,7,8,9,10);
Error, SHELL: 3rd argument (can return object) should be true or false
gap> SHELL(lvars,true,true,fail,5,6,7,8,9,10);
Error, SHELL: 4th argument (last depth) should be a small integer
gap> SHELL(lvars,true,true,0,5,6,7,8,9,10);
Error, SHELL: 5th argument (set time) should be true or false
gap> SHELL(lvars,true,true,0,false,6,7,8,9,10);
Error, SHELL: 6th argument (prompt) must be a string of length at most 80 char\
acters
gap> SHELL(lvars,true,true,0,false,"abc",7,8,9,10);
Error, SHELL: 7th argument (preCommandHook) must be function or false
gap> SHELL(lvars,true,true,0,false,"abc",false,8,9,10);
Error, SHELL: 8th argument (infile) must be a string
gap> SHELL(lvars,true,true,0,false,"abc",false,"",9,10);
Error, SHELL: 9th argument (outfile) must be a string
gap> SHELL(lvars,true,true,0,false,"abc",false,"","",10);
Error, SHELL: 10th argument (catch QUIT) should be true or false
gap> SHELL(lvars,true,true,0,false,"abc",false,"","",false);
Error, SHELL: can't open outfile 

#
gap> l:=RUNTIMES();; List(l,IsInt);
[ true, true, true, true ]

#
gap> RecNames(NanosecondsSinceEpochInfo());
[ "Method", "Monotonic", "Resolution", "Reliable" ]

#
gap> List(SizeScreen(), IsPosInt);
[ true, true ]
gap> SizeScreen(100, 100);
Error, Function: number of arguments must be 0 or 1 (not 2)
gap> SizeScreen(100);
Error, SizeScreen: <size> must be a list of length 2
gap> SizeScreen([fail,fail]);
Error, SizeScreen: <x> must be an integer
gap> SizeScreen([100,fail]);
Error, SizeScreen: <y> must be an integer

#
gap> WindowCmd(fail);
Error, argument list must be a list (not a boolean or fail)
gap> WindowCmd([]);
Error, List Element: <list>[1] must have an assigned value
gap> WindowCmd([fail]);
Error, <cmd> must be a string (not a boolean or fail)
gap> WindowCmd([""]);
Error, <cmd> must be a string of length 3
gap> WindowCmd(["abc",fail]);
Error, 2. argument must be a string or integer (not a boolean or fail)
gap> WindowCmd(["abc"]);
Error, window system: No Window Handler Present

#
gap> DownEnv();
not in any function
gap> DownEnv(1);
not in any function
gap> DownEnv(1,2);
Error, usage: DownEnv( [ <depth> ] )
gap> DownEnv(fail);
Error, usage: DownEnv( [ <depth> ] )

#
gap> UpEnv();
not in any function
gap> UpEnv(1);
not in any function
gap> UpEnv(1,2);
Error, usage: UpEnv( [ <depth> ] )
gap> UpEnv(fail);
Error, usage: UpEnv( [ <depth> ] )

#
gap> CALL_WITH_CATCH(fail,fail);
Error, CALL_WITH_CATCH(<func>, <args>): <func> must be a function
gap> CALL_WITH_CATCH(x->x,fail);
Error, CALL_WITH_CATCH(<func>, <args>): <args> must be a list
gap> CALL_WITH_CATCH(x->x,[1..3]);
Error, Function: number of arguments must be 1 (not 3)
[ false, 0 ]
gap> CALL_WITH_CATCH({x,y,z}->x,[1..3]);
[ true, 1 ]

#
gap> GAP_CRC(fail);
Error, <filename> must be a string (not a boolean or fail)
gap> GAP_CRC("foobar");
0

#
gap> LOAD_DYN(fail, fail);
Error, <filename> must be a string (not a boolean or fail)
gap> LOAD_DYN("foobar", fail);
Error, <crc> must be a small integer or 'false' (not a boolean or fail)

#
gap> LOAD_STAT(fail, fail);
Error, <filename> must be a string (not a boolean or fail)
gap> LOAD_STAT("foobar", fail);
Error, <crc> must be a small integer or 'false' (not a boolean or fail)
gap> LOAD_STAT("foobar", false);
false

#
gap> LoadedModules();;

#
gap> GASMAN();
Error, usage: GASMAN( "display"|"displayshort"|"clear"|"collect"|"message"|"pa\
rtial" )
gap> GASMAN(fail);
Error, GASMAN: <cmd> must be a string (not a boolean or fail)

#
gap> SIZE_OBJ(0);
0
gap> SIZE_OBJ(Z(2));
0

#
gap> OBJ_HANDLE(0);
gap> OBJ_HANDLE(HANDLE_OBJ("test"));
"test"

#
gap> MASTER_POINTER_NUMBER(0);
0
gap> MASTER_POINTER_NUMBER(Z(2));
0

#
gap> FUNC_BODY_SIZE(fail);
fail

#
gap> Sleep(fail);
Error, <secs> must be a small integer
gap> Sleep(0);

#
gap>    MicroSleep(fail);
Error, <usecs> must be a small integer
gap> MicroSleep(0);
gap> MicroSleep(1);

#
gap> GAP_EXIT_CODE("invalid");
Error, GAP_EXIT_CODE: Argument must be boolean or integer
gap> GAP_EXIT_CODE(fail);
gap> GAP_EXIT_CODE(false);
gap> GAP_EXIT_CODE(true);

#
gap> QUIT_GAP("invald");
Error, usage: QUIT_GAP( [ <return value> ] )
gap> QUIT_GAP(1, 2);
Error, usage: QUIT_GAP( [ <return value> ] )

#
gap> FORCE_QUIT_GAP("invald");
Error, usage: FORCE_QUIT_GAP( [ <return value> ] )
gap> FORCE_QUIT_GAP(1, 2);
Error, usage: FORCE_QUIT_GAP( [ <return value> ] )

#
gap> BREAKPOINT(0);
