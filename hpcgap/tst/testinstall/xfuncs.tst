gap> START_TEST("xfuncs.tst");
gap> testXfuncs := function(list, args...)
>      local set, sum, prod;
>      list := CallFuncList(ListX, args);
>      set := Set(list);
>      if IsEmpty(list) then
>        sum := fail; prod := fail;
>      else
>        sum := Sum(list); prod := Product(list);
>      fi;
>      return list = CallFuncList(ListX, args) and
>        set = CallFuncList(SetX, args) and
>        prod = CallFuncList(ProductX, args) and
>        sum = CallFuncList(SumX, args);
> end;;
gap> testXfuncs([3], function() return 3; end);
true
gap> testXfuncs([2], [2], x -> x);
true
gap> testXfuncs([2,3], [2,3], x -> x);
true
gap> testXfuncs([2,3,2], [2,3,2], x -> x);
true
gap> testXfuncs([ [1,1], [1,2], [1,3], [2,1], [2,2], [2,3] ],
>   [1,2], [1,2,3], function(x,y) return [x,y]; end);
true
gap> testXfuncs([ [ 1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ], [ 2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] ], [1..2],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10], function(x...) return x; end);
true
gap> sumlim := function(x...) return Sum(x) < 5; end;;
gap> testXfuncs([ [ 1, 1, 1, 1 ] ], [1..5], sumlim, [1..5], sumlim, sumlim, [1..5], [1..5], sumlim, function(x...) return x; end);
true
gap> testXfuncs([ [ 1 ], [ 2 ] ],[1..2], ReturnTrue, function(x...) return x; end);
true
gap> testXfuncs([], [1..2], ReturnFalse, function(x...) return x; end);
true
gap> testXfuncs([ [1],[2] ],function() return true; end, [1..2], function(x...) return x; end);
true
gap> testXfuncs([], function() return false; end, [1..2], function(x...) return x; end);
true
gap> testXfuncs([1,3,5],[1..5], x -> (x mod 2 = 1), x -> x);
true
gap> testXfuncs([ [1,3] ],[1..5], x -> (x mod 2 = 1), [3..5], function(x,y) return x + y < 5; end, function(x...) return x; end);
true
gap> testXfuncs([], [], function(x,y) return [x,y]; end);
true
gap> testXfuncs([], [1,2,3], [], x -> x);
true
gap> ListX([1, "abc", "abc"], x -> x);
[ 1, "abc", "abc" ]
gap> SetX([1, "abc", "abc"], x -> x);
[ 1, "abc" ]
gap> SumX([1, 2, 2.0], x -> x);
5.
gap> ProductX([1, 2, 2.0], x -> x);
4.

# gap> ListX( (1,2), x -> x);
# Error, gens[1] must be a collection, a list, a boolean, or a function
# gap> SetX( (1,2), x -> x);
# Error, gens[1] must be a collection, a list, a boolean, or a function
# gap> SumX( (1,2), x -> x);
# Error, gens[1] must be a collection, a list, a boolean, or a function
# gap> ProductX( (1,2), x -> x);
# Error, gens[1] must be a collection, a list, a boolean, or a function
# gap> ListX([1,2], (1,2), x -> x);
# Error, gens[2] must be a collection, a list, a boolean, or a function
# gap> SetX([1,2], (1,2), x -> x);
# Error, gens[2] must be a collection, a list, a boolean, or a function
# gap> SumX([1,2], (1,2), x -> x);
# Error, gens[2] must be a collection, a list, a boolean, or a function
# gap> ProductX([1,2], (1,2), x -> x);
# Error, gens[2] must be a collection, a list, a boolean, or a function
# gap> ListX([1,2],[1,2], (1,2), x -> x);
# Error, gens[3] must be a collection, a list, a boolean, or a function
# gap> SetX([1,2],[1,2], (1,2), x -> x);
# Error, gens[3] must be a collection, a list, a boolean, or a function
# gap> SumX([1,2],[1,2], (1,2), x -> x);
# Error, gens[3] must be a collection, a list, a boolean, or a function
# gap> ProductX([1,2],[1,2], (1,2), x -> x);
# Error, gens[3] must be a collection, a list, a boolean, or a function
# gap> ListX([1,2],[1,2],[1,2], (1,2), x -> x);
# Error, gens[4] must be a collection, a list, a boolean, or a function
# gap> SetX([1,2],[1,2],[1,2], (1,2), x -> x);
# Error, gens[4] must be a collection, a list, a boolean, or a function
# gap> SumX([1,2],[1,2],[1,2], (1,2), x -> x);
# Error, gens[4] must be a collection, a list, a boolean, or a function
# gap> ProductX([1,2],[1,2],[1,2], (1,2), x -> x);
# Error, gens[4] must be a collection, a list, a boolean, or a function
gap> STOP_TEST("xfuncs.tst", 1);
