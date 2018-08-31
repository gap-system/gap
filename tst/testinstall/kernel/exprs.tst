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
Error, Permutation: <expr> must be a positive integer (not a boolean or fail)
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

#
gap> STOP_TEST("kernel/exprs.tst", 1);
