gap> START_TEST("callfunc.tst");

# Union([1]) = 1 :(
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
gap> fam := NewFamily("XYZsFamily");;
gap> cat := NewCategory("IsXYZ",IsObject);;
gap> type := NewType(fam, cat and IsPositionalObjectRep);;
gap> result := fail;;
gap> InstallMethod(CallFuncList,[cat,IsList],function(func,args) result:=args; return args; end);
gap> o := Objectify(type,[]);;

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

# test dispatch through executor / DispatchFuncCall, as function call
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

# test dispatch through executor / DispatchFuncCall, as procedure call
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

# test dispatch through CALL_FUNC_LIST
gap> CALL_FUNC_LIST(o, []);
[  ]
gap> CALL_FUNC_LIST(o, [1]);
[ 1 ]
gap> CALL_FUNC_LIST(o, [1,2]);
[ 1, 2 ]
gap> CALL_FUNC_LIST(o, [1,2,3]);
[ 1, 2, 3 ]
gap> CALL_FUNC_LIST(o, [1,2,3,4]);
[ 1, 2, 3, 4 ]
gap> CALL_FUNC_LIST(o, [1,2,3,4,5]);
[ 1, 2, 3, 4, 5 ]
gap> CALL_FUNC_LIST(o, [1,2,3,4,5,6]);
[ 1, 2, 3, 4, 5, 6 ]
gap> CALL_FUNC_LIST(o, [1,2,3,4,5,6,7]);
[ 1, 2, 3, 4, 5, 6, 7 ]

#
gap> STOP_TEST( "callfunc.tst", 1);
