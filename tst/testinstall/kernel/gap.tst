#
# Tests for functions defined in src/gap.c
#
gap> START_TEST("kernel/gap.tst");

# stress test the kernel helper `ViewObjHandler`: force an error
# in ViewObj; afterwards everything should still work as before
gap> l := [ ~ ];; r := rec(a:=~);;
gap> cat := NewCategory("IsMockObject", IsObject);;
gap> type := NewType(NewFamily("MockFamily"), cat);;
gap> InstallMethod(ViewObj, [cat], function(s) Error("oops"); end);
gap> InstallMethod(PrintObj, [cat], function(s) Error("uups"); end);
gap> x:=Objectify(type,[]); r; Print(l, "\n");
Error, oops
rec( a := ~ )
[ ~ ]
gap> ViewObj(x); r; Print(l, "\n");
Error, oops
rec( a := ~ )
[ ~ ]
gap> PrintObj(x); r; Print(l, "\n");
Error, uups
rec( a := ~ )
[ ~ ]

#
gap> SHELL();
Error, Function: number of arguments must be 6 (not 0)
gap> SHELL(1,2,3,4,5,6);
Error, SHELL: <context> must be a local variables bag (not the integer 1)
gap> lvars:=GetCurrentLVars();
<lvars bag>
gap> SHELL(lvars,2,3,4,5,6);
Error, SHELL: <canReturnVoid> must be 'true' or 'false' (not the integer 2)
gap> SHELL(lvars,true,3,4,5,6);
Error, SHELL: <canReturnObj> must be 'true' or 'false' (not the integer 3)
gap> SHELL(lvars,true,true,4,5,6);
Error, SHELL: <breakLoop> must be 'true' or 'false' (not the integer 4)
gap> SHELL(lvars,true,true,true,5,6);
Error, SHELL: <prompt> must be a string (not the integer 5)
gap> SHELL(lvars,true,true,true,ListWithIdenticalEntries(81,'x'),6);
Error, SHELL: <prompt> must be a string of length at most 80
gap> SHELL(lvars,true,true,true,"abc",6);
Error, SHELL: <preCommandHook> must be function or false (not the integer 6)

#
gap> RETURN_FIRST();
Error, Function: number of arguments must be at least 1 (not 0)
gap> RETURN_FIRST(1);
1

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
Error, SizeScreen: number of arguments must be 0 or 1 (not 2)
gap> SizeScreen(100);
Error, SizeScreen: <size> must be a list of length at most 2
gap> SizeScreen([fail,fail]);
Error, SizeScreen: <x> must be a small integer (not the value 'fail')
gap> SizeScreen([100,fail]);
Error, SizeScreen: <y> must be a small integer (not the value 'fail')

#
gap> WindowCmd(fail);
Error, WindowCmd: <args> must be a small list (not the value 'fail')
gap> WindowCmd([]);
Error, List Element: <list>[1] must have an assigned value
gap> WindowCmd([fail]);
Error, WindowCmd: <cmd> must be a string (not the value 'fail')
gap> WindowCmd([""]);
Error, WindowCmd: <cmd> must be a string of length 3
gap> WindowCmd(["abc",fail]);
Error, WindowCmd: the argument in position 2 must be a string or integer (not \
a boolean or fail)
gap> WindowCmd(["abc"]);
Error, window system: No Window Handler Present
gap> WindowCmd(["abc",1,"foo"]);
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
gap> CURRENT_STATEMENT_LOCATION(GetCurrentLVars());
fail
gap> PRINT_CURRENT_STATEMENT("*errout*", GetCurrentLVars());
gap> f:=function() PRINT_CURRENT_STATEMENT("*errout*", GetCurrentLVars()); Print("\n"); end;; f();
PRINT_CURRENT_STATEMENT( "*errout*", GetCurrentLVars(  ) ); at stream:1

#
gap> CALL_WITH_CATCH(fail,fail);
Error, CALL_WITH_CATCH: <func> must be a function (not the value 'fail')
gap> CALL_WITH_CATCH(x->x,fail);
Error, CALL_WITH_CATCH: <args> must be a list (not the value 'fail')
gap> CALL_WITH_CATCH(x->x,[1..3]);
Error, Function: number of arguments must be 1 (not 3)
[ false, 0 ]
gap> CALL_WITH_CATCH({x,y,z}->x,[1..3]);
[ true, 1 ]

#
gap> GAP_CRC(fail);
Error, GAP_CRC: <filename> must be a string (not the value 'fail')
gap> GAP_CRC("foobar");
0

#
gap> GASMAN();
Error, usage: GASMAN( "display"|"displayshort"|"clear"|"collect"|"message"|"pa\
rtial" )
gap> GASMAN(fail);
Error, GASMAN: <cmd> must be a string (not the value 'fail')

#
gap> IsList(GASMAN_LIMITS());
true

#
gap> IsInt(TOTAL_GC_TIME());
true

#
gap> IsInt(TotalMemoryAllocated());
true

#
gap> SIZE_OBJ(0);
0
gap> SIZE_OBJ(Z(2));
0

#
gap> TNUM_OBJ(0);
0
gap> TNUM_OBJ(2^100);
1
gap> TNUM_OBJ(-2^100);
2
gap> TNUM_OBJ(1/2);
3
gap> TNUM_OBJ(Z(2));
5
gap> TNUM_OBJ(rec());
20
gap> TNUM_OBJ([]);
34

#
gap> TNAM_OBJ(0);
"integer"
gap> TNAM_OBJ(2^100);
"large positive integer"
gap> TNAM_OBJ(-2^100);
"large negative integer"
gap> TNAM_OBJ(1/2);
"rational"
gap> TNAM_OBJ(Z(2));
"ffe"
gap> TNAM_OBJ(rec());
"record (plain)"
gap> TNAM_OBJ([]);
"empty plain list"

#
gap> OBJ_HANDLE(-1);
Error, OBJ_HANDLE: <handle> must be a non-negative integer (not the integer -1\
)
gap> OBJ_HANDLE(false);
Error, OBJ_HANDLE: <handle> must be a non-negative integer (not the value 'fal\
se')
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
Error, FUNC_BODY_SIZE: <func> must be a function (not the value 'fail')
gap> FUNC_BODY_SIZE(SHELL) / GAPInfo.BytesPerVariable;
4

#
gap> Sleep(fail);
Error, Sleep: <secs> must be a small integer (not the value 'fail')
gap> Sleep(0);
gap> Sleep(1);

#
gap> MicroSleep(fail);
Error, MicroSleep: <msecs> must be a small integer (not the value 'fail')
gap> MicroSleep(0);
gap> MicroSleep(1);

#
gap> exitCode := GapExitCode();;
gap> GapExitCode(0);;
gap> GapExitCode();
0
gap> GapExitCode("invalid");
Error, GapExitCode: <code> Argument must be boolean or integer (not a list (st\
ring))
gap> GapExitCode(fail);
0
gap> GapExitCode(false);
1
gap> GapExitCode(true);
1
gap> GapExitCode(6);
0
gap> GapExitCode();
6
gap> GapExitCode(exitCode);
6
gap> GapExitCode(fail, fail);
Error, usage: GapExitCode( [ <return value> ] )

#
gap> QuitGap("invalid");
Error, usage: QuitGap( [ <return value> ] )
gap> QuitGap(1, 2);
Error, usage: QuitGap( [ <return value> ] )

#
gap> ForceQuitGap("invalid");
Error, usage: ForceQuitGap( [ <return value> ] )
gap> ForceQuitGap(1, 2);
Error, usage: ForceQuitGap( [ <return value> ] )

#
gap> BREAKPOINT(0);

#
gap> UPDATE_STAT(fail, fail);
Error, UPDATE_STAT: <name> must be a string (not the value 'fail')
gap> UPDATE_STAT("foobar", fail);
Error, UPDATE_STAT: unsupported <name> value 'foobar'

#
gap> STOP_TEST("kernel/gap.tst", 1);
