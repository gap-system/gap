#@local cat,cat2,f,fam,l,o,o2,result,swallow,type,type2
gap> START_TEST("callfunc.tst");

#
gap> CallFuncList(1,2);
Error, CallFuncList: <list> must be a small list (not the integer 2)
gap> CallFuncListWrap(1,2);
Error, CallFuncListWrap: <list> must be a small list (not the integer 2)

#
gap> ForAll([0,2..100], x -> [1..x] = CallFuncList(Union, List([1..x], y -> [y]) ) );
true
gap> CallFuncList(Group, [ (1,2) ]) = Group((1,2));
true
gap> ForAll([0,2..100], x -> [[1..x]] = CallFuncListWrap(Union, List([1..x], y -> [y]) ) );
true
gap> CallFuncListWrap(Group, [ (1,2) ]) = [ Group((1,2)) ];
true
gap> CallFuncList(Group, [ (1,2) ]) =  Group((1,2)) ;
true
gap> CallFuncList(Group, [ (1,2) ]) = Group((1,2)) ;
true
gap> l := [];;
gap> CallFuncList(Add, [ l, 2 ] );
gap> CallFuncList(Add, [ l, 3, 4] );
gap> l = [2,,,3];
true
gap> swallow := function(x...) end;;
gap> ForAll([0..100], x -> CallFuncListWrap(swallow, List([1..x], y -> [y]) ) = [] );
true

# test overloading CallFuncList
gap> fam := NewFamily("CustomFunctionFamily");;
gap> cat := NewCategory("IsCustomFunction", IsFunction);;
gap> type := NewType(fam, cat and IsAttributeStoringRep);;
gap> result := fail;;
gap> InstallMethod(CallFuncList,[cat,IsList],function(func,args) result:=args; return args; end);
gap> InstallMethod(NameFunction, [cat], f -> "myName");
gap> InstallMethod(NamesLocalVariablesFunction, [cat], f -> ["arg"]);
gap> InstallMethod(NumberArgumentsFunction, [cat], f -> -1);

#
gap> o := Objectify(type, rec());;
gap> Display(o);
<object>
gap> HasNameFunction(o);
false
gap> NameFunction(o);
"myName"
gap> HasNameFunction(o);
true
gap> NamesLocalVariablesFunction(o);
[ "arg" ]
gap> NumberArgumentsFunction(o);
-1

# test dispatch through interpreter / IntrFuncCallEnd
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

# test dispatch through executor / EvalOrExecCall, as function call
gap> f := function() return o(); end;; f();
[  ]
gap> f := function() return o(1); end;; f();
[ 1 ]
gap> f := function() return o(1,2); end;; f();
[ 1, 2 ]
gap> f := function() return o(1,2,3); end;; f();
[ 1, 2, 3 ]
gap> f := function() return o(1,2,3,4); end;; f();
[ 1, 2, 3, 4 ]
gap> f := function() return o(1,2,3,4,5); end;; f();
[ 1, 2, 3, 4, 5 ]
gap> f := function() return o(1,2,3,4,5,6); end;; f();
[ 1, 2, 3, 4, 5, 6 ]
gap> f := function() return o(1,2,3,4,5,6,7); end;; f();
[ 1, 2, 3, 4, 5, 6, 7 ]

# test dispatch through executor / EvalOrExecCall, as procedure call
gap> f := function() o(); return result; end;; f();
[  ]
gap> f := function() o(1); return result; end;; f();
[ 1 ]
gap> f := function() o(1,2); return result; end;; f();
[ 1, 2 ]
gap> f := function() o(1,2,3); return result; end;; f();
[ 1, 2, 3 ]
gap> f := function() o(1,2,3,4); return result; end;; f();
[ 1, 2, 3, 4 ]
gap> f := function() o(1,2,3,4,5); return result; end;; f();
[ 1, 2, 3, 4, 5 ]
gap> f := function() o(1,2,3,4,5,6); return result; end;; f();
[ 1, 2, 3, 4, 5, 6 ]
gap> f := function() o(1,2,3,4,5,6,7); return result; end;; f();
[ 1, 2, 3, 4, 5, 6, 7 ]

# test dispatch through CallFuncList
gap> CallFuncList(o, []);
[  ]
gap> CallFuncList(o, [1]);
[ 1 ]
gap> CallFuncList(o, [1,2]);
[ 1, 2 ]
gap> CallFuncList(o, [1,2,3]);
[ 1, 2, 3 ]
gap> CallFuncList(o, [1,2,3,4]);
[ 1, 2, 3, 4 ]
gap> CallFuncList(o, [1,2,3,4,5]);
[ 1, 2, 3, 4, 5 ]
gap> CallFuncList(o, [1,2,3,4,5,6]);
[ 1, 2, 3, 4, 5, 6 ]
gap> CallFuncList(o, [1,2,3,4,5,6,7]);
[ 1, 2, 3, 4, 5, 6, 7 ]

# test overloading CallFuncList with a procedure call
gap> cat2 := NewCategory("IsCustomFunction2",IsFunction);;
gap> type2 := NewType(fam, cat2 and IsPositionalObjectRep);;
gap> InstallMethod(CallFuncList,[cat2,IsList],function(func,args) result:=args; end);
gap> o2 := Objectify(type2,[]);;

# test edge case: expecting a func call, but doing a proc call
gap> f := function() return o2(); end;; f();
Error, Function Calls: <func> must return a value
gap> f := function() return o2(1); end;; f();
Error, Function Calls: <func> must return a value
gap> f := function() return o2(1,2); end;; f();
Error, Function Calls: <func> must return a value
gap> f := function() return o2(1,2,3); end;; f();
Error, Function Calls: <func> must return a value
gap> f := function() return o2(1,2,3,4); end;; f();
Error, Function Calls: <func> must return a value
gap> f := function() return o2(1,2,3,4,5); end;; f();
Error, Function Calls: <func> must return a value
gap> f := function() return o2(1,2,3,4,6,7); end;; f();
Error, Function Calls: <func> must return a value
gap> f := function() return o2(1,2,3,4,5,6,7); end;; f();
Error, Function Calls: <func> must return a value
gap> STOP_TEST( "callfunc.tst", 1);
