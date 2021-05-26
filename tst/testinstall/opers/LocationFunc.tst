gap> START_TEST("LocationFunc.tst");

#
gap> LocationFunc(fail);
Error, <func> must be a function

# regular GAP function
gap> f:=x->x;;
gap> LocationFunc(f);
"stream:1"

# Library function
gap> PositionSublist(LocationFunc(Where),"/lib/error.g:") <> fail;
true

# GAP function which was compiled to C code by gac
# this yields something like "GAPROOT/lib/oper1.g:147"
# but we don't want to depend on the changing line numbers,
# so we invest some extra work to test the format without
# relying on the specific content
gap> loc:=LocationFunc(INSTALL_METHOD_FLAGS);;
gap> StartsWith(loc, "GAPROOT/lib/oper1.g:");
true
gap> ForAll(loc{[21..Length(loc)]}, IsDigitChar);
true

# proper kernel function
gap> LocationFunc(APPEND_LIST_INTR);
"src/listfunc.c:APPEND_LIST_INTR"

# String is an attribute, so no information is stored
gap> LocationFunc( String );
fail

# functions created from a syntax tree have no location
gap> LocationFunc(SYNTAX_TREE_CODE(SYNTAX_TREE(x->x)));
fail

#
gap> STOP_TEST("LocationFunc.tst", 1);
