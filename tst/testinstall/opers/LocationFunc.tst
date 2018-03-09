gap> START_TEST("LocationFunc.tst");

# regular GAP function
gap> f:=x->x;;
gap> LocationFunc(f);
"stream:1"

# GAP function which was compiled to C code by gac
gap> LocationFunc(METHOD_0ARGS);
"GAPROOT/lib/methsel1.g:19"

# proper kernel function
gap> LocationFunc(APPEND_LIST_INTR);
"src/listfunc.c:APPEND_LIST_INTR"

#
gap> STOP_TEST("LocationFunc.tst", 1);
