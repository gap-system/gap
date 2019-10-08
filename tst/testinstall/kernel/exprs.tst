#
# Tests for functions defined in src/exprs.c
#
gap> START_TEST("kernel/exprs.tst");

# EvalPermExpr
gap> f:={a,b} -> (a,b);;
gap> f(1,2);
(1,2)
gap> f(2,1);
(1,2)
gap> f(2,2);
Error, Permutation: cycles must be disjoint and duplicate-free
gap> f(2,fail);
Error, Permutation: <expr> must be a positive small integer (not the value 'fa\
il')
gap> f:={a,b,c,d} -> (a,b,c,d);;
gap> f(1,2,3,4);
(1,2,3,4)
gap> f(1,2,3,2);
Error, Permutation: cycles must be disjoint and duplicate-free
gap> f:={a,b,c,d} -> (a,b)(c,d);;
gap> f(1,2,3,4);
(1,2)(3,4)
gap> f(1,2,3,2);
Error, Permutation: cycles must be disjoint and duplicate-free
gap> f(1,2,1,2);
Error, Permutation: cycles must be disjoint and duplicate-free

# EvalRangeExpr
gap> f:={a,b,c} -> [a,b..c];;
gap> f(1,2,3);
[ 1 .. 3 ]
gap> f(1,3,5);
[ 1, 3 .. 5 ]
gap> f(1,1,1);
Error, Range: <second> must not be equal to <first> (1)
gap> f(1,3,4);
Error, Range: <last>-<first> (3) must be divisible by <inc> (2)
gap> f(2^100,1,2);
Error, Range: <first> must be a small integer (not a large positive integer)
gap> f(1,2^100,2);
Error, Range: <second> must be a small integer (not a large positive integer)
gap> f(1,2,2^200);
Error, Range: <last> must be a small integer (not a large positive integer)

# EvalRecExpr
gap> f:={a,b} -> rec( (a) := b );;
gap> f(1,2);
rec( 1 := 2 )
gap> f(fail,2);
Error, Record: '<rec>.(<obj>)' <obj> must be a string or a small integer (not \
the value 'fail')

# PrintBinop
gap> Display(x-> (-2)^x);
function ( x )
    return (-2) ^ x;
end
gap> Display( x -> 2 * f( 3 + 4 ));
function ( x )
    return 2 * f( (3 + 4) );
end

# PrintTildeExpr, EvalTildeExpr
gap> l := [x -> ~];;
gap> f := l[1];;
gap> Display(f);
function ( x )
    return ~;
end
gap> f(1);
Error, '~' does not have a value here

#
gap> STOP_TEST("kernel/exprs.tst", 1);
