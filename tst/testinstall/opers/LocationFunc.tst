gap> START_TEST("LocationFunc.tst");
gap> FindDefinitionLine := function(path, symbol)
> local lines, i, j;
> if StartsWith(path, "GAPROOT/") then
>   path := Filename(List(GAPInfo.RootPaths, Directory), path{[9 .. Length(path)]});
> fi;
> lines := SplitString(StringFile(path), "\n", "");
> for i in [1 .. Length(lines)] do
>   if StartsWith(lines[i], Concatenation("static Obj ", symbol)) then
>     for j in [i .. Length(lines)] do
>       if PositionSublist(lines[j], "{") <> fail then
>         return i;
>       fi;
>       if PositionSublist(lines[j], ";") <> fail then
>         break;
>       fi;
>     od;
>   fi;
> od;
> return fail;
> end;;

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
gap> loc:=SplitString(LocationFunc(INSTALL_METHOD_FLAGS), ":");;
gap> Length(loc);
2
gap> loc[1] = "GAPROOT/lib/oper1.g";
true
gap> ForAll(loc[2], IsDigitChar);
true

# proper kernel function
gap> loc:=SplitString(LocationFunc(APPEND_LIST_INTR), ":");;
gap> Length(loc);
2
gap> loc[1] = "GAPROOT/src/listfunc.c";
true
gap> ForAll(loc[2], IsDigitChar);
true
gap> StartlineFunc(APPEND_LIST_INTR) = Int(loc[2]);
true
gap> StartlineFunc(APPEND_LIST_INTR) = FindDefinitionLine(FilenameFunc(APPEND_LIST_INTR), "FuncAPPEND_LIST_INTR(");
true

# kernel function with a multiline signature and inline comment
gap> StartlineFunc(ACTIVATE_PROFILING) = FindDefinitionLine(FilenameFunc(ACTIVATE_PROFILING), "FuncACTIVATE_PROFILING(");
true

# String is an attribute, so no information is stored
gap> LocationFunc( String );
fail

# functions created from a syntax tree have no location
gap> LocationFunc(SYNTAX_TREE_CODE(SYNTAX_TREE(x->x)));
fail

#
gap> STOP_TEST("LocationFunc.tst");
