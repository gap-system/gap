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
gap> STOP_TEST( "callfunc.tst", 1);
