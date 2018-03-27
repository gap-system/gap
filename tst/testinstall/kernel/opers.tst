#
# Tests for functions defined in src/opers.c
#
gap> START_TEST("kernel/opers.tst");

#
gap> flags := FLAGS_FILTER(IsMutable);
<flag list>
gap> flags2 := FLAGS_FILTER(IsPGroup and IsMutable);
<flag list>

#
gap> LEN_FLAGS(fail);
Error, <flags> must be a flags list (not a boolean or fail)
gap> LEN_FLAGS(flags);
1

#
gap> ELM_FLAGS(fail,1);
Error, <flags> must be a flags list (not a boolean or fail)
gap> ELM_FLAGS(flags,0);
Error, <pos> must be a small positive integer (not a integer)
gap> ELM_FLAGS(flags,fail);
Error, <pos> must be a small positive integer (not a boolean or fail)
gap> ELM_FLAGS(flags,1);
true
gap> ELM_FLAGS(flags,2);
false

#
gap> HASH_FLAGS(fail);
Error, <flags> must be a flags list (not a boolean or fail)
gap> HASH_FLAGS(flags);
2

#
gap> TRUES_FLAGS(fail);
Error, <flags> must be a flags list (not a boolean or fail)
gap> TRUES_FLAGS(flags);
[ 1 ]

#
gap> SIZE_FLAGS(fail);
Error, <flags> must be a flags list (not a boolean or fail)
gap> SIZE_FLAGS(flags);
1

#
gap> IS_EQUAL_FLAGS(fail, flags);
Error, <flags1> must be a flags list (not a boolean or fail)
gap> IS_EQUAL_FLAGS(flags, fail);
Error, <flags2> must be a flags list (not a boolean or fail)
gap> IS_EQUAL_FLAGS(flags, flags);
true
gap> IS_EQUAL_FLAGS(flags, flags2);
false
gap> IS_EQUAL_FLAGS(flags2, flags);
false

#
gap> IS_SUBSET_FLAGS(fail, flags);
Error, <flags1> must be a flags list (not a boolean or fail)
gap> IS_SUBSET_FLAGS(flags, fail);
Error, <flags2> must be a flags list (not a boolean or fail)
gap> IS_SUBSET_FLAGS(flags, flags);
true
gap> IS_SUBSET_FLAGS(flags, flags2);
false
gap> IS_SUBSET_FLAGS(flags2, flags);
true

#
gap> SUB_FLAGS(fail, flags);
Error, <flags1> must be a flags list (not a boolean or fail)
gap> SUB_FLAGS(flags, fail);
Error, <flags2> must be a flags list (not a boolean or fail)
gap> emptyFlags := SUB_FLAGS(flags, flags);
<flag list>
gap> TRUES_FLAGS(emptyFlags);
[  ]
gap> TRUES_FLAGS(SUB_FLAGS(flags, flags2));
[  ]

# test comparison of equal but not identical filters
gap> f1:=SUB_FLAGS(flags2, flags);; f2:=FLAGS_FILTER(IsPGroup);;
gap> IS_EQUAL_FLAGS(f1, f2);
true
gap> f1 = f2;
true
gap> IsIdenticalObj(f1, f2);
false

#
gap> AND_FLAGS(fail, flags);
Error, <flags1> must be a flags list (not a boolean or fail)
gap> AND_FLAGS(flags, fail);
Error, <flags2> must be a flags list (not a boolean or fail)
gap> TRUES_FLAGS(AND_FLAGS(flags, flags));
[ 1 ]
gap> TRUES_FLAGS(AND_FLAGS(emptyFlags, flags));
[ 1 ]
gap> TRUES_FLAGS(AND_FLAGS(flags, emptyFlags));
[ 1 ]
gap> IS_EQUAL_FLAGS(AND_FLAGS(flags2, flags), flags2);
true
gap> IS_EQUAL_FLAGS(AND_FLAGS(flags, flags2), flags2);
true

#
gap> WITH_HIDDEN_IMPS_FLAGS(fail);
Error, <flags> must be a flags list (not a boolean or fail)
gap> TRUES_FLAGS(WITH_HIDDEN_IMPS_FLAGS(flags));
[ 1, 2 ]

#
gap> WITH_IMPS_FLAGS(fail);
Error, <flags> must be a flags list (not a boolean or fail)
gap> TRUES_FLAGS(WITH_IMPS_FLAGS(flags));
[ 1, 2 ]

#
gap> WITH_IMPS_FLAGS_STAT();;

# test DoSetAndFilter
gap> G:=SymmetricGroup(3);;
gap> filter:=Setter(IsPGroup and IsAbelian);;
gap> filter(G, false);
Error, You cannot set an "and-filter" except to true

# test DoSetFilter
gap> filter:=SETTER_FILTER(IsMutable);;
gap> filter(G, false);
gap> filter(G, true);
Error, value feature is already set the other way

# test DoSetReturnTrueFilter
gap> Setter(IS_OBJECT)(G, true);
gap> Setter(IS_OBJECT)(G, false);
Error, you cannot set this flag to 'false'

# test DoSetProperty
gap> SetIsPGroup(G, false);
gap> SetIsPGroup(G, true);
Error, Value property is already set the other way

#
gap> NEW_FILTER(fail);
Error, usage: NewFilter( <name> )

#
gap> FLAG1_FILTER(fail);
Error, <oper> must be an operation
gap> FLAG1_FILTER(Normalizer);
0
gap> SET_FLAG1_FILTER(fail, 1);
Error, <oper> must be an operation

#
gap> FLAG2_FILTER(fail);
Error, <oper> must be an operation
gap> FLAG2_FILTER(Normalizer);
0
gap> SET_FLAG2_FILTER(fail, 1);
Error, <oper> must be an operation

#
gap> FLAGS_FILTER(fail);
Error, <oper> must be an operation
gap> FLAGS_FILTER(Normalizer);
false
gap> SET_FLAGS_FILTER(fail, 1);
Error, <oper> must be an operation

#
gap> SETTER_FILTER(fail);
Error, <oper> must be an operation
gap> SETTER_FILTER(Normalizer);
false
gap> SET_SETTER_FILTER(fail, 1);
Error, <oper> must be an operation

#
gap> TESTER_FILTER(fail);
Error, <oper> must be an operation
gap> TESTER_FILTER(Normalizer);
false
gap> SET_TESTER_FILTER(fail, 1);
Error, <oper> must be an operation

#
# COMPACT_TYPE_IDS is called when we run out of type ids, it removes
# unused type ids and renumbers the remaining ons. On a 64bit system, it
# is probably never called under normal circumstances. In any case, just
# calling it, w/o any further checks (other than GAP not crashing) is
# already a pretty good check. However, on HPC-GAP, this function is not
# available.
#
gap> if not IsHPCGAP then COMPACT_TYPE_IDS(); fi;

#
# ensure at least some of the "verbose" profiling code path is hit
#
gap> opers:=[IsAbelian,Size,SylowSubgroup,NthRootsInGroup,AbelianGroupCons];;
gap> ProfileFunctions(opers);
gap> G := Group( (1,2,3), (4,5,6));;
gap> Size(G);
9
gap> SylowSubgroup(G, 3) = G;
true
gap> NthRootsInGroup(G, G.1, 3);
[  ]
gap> IsAbelian(G);
true
gap> G = AbelianGroupCons(IsPermGroup, [3,3]);
true
gap> UnprofileFunctions(opers);

#
#
#

#
gap> NEW_OPERATION(fail);
Error, usage: NewOperation( <name> )
gap> NEW_CONSTRUCTOR(fail);
Error, usage: NewConstructor( <name> )
gap> NEW_ATTRIBUTE(fail);
Error, usage: NewAttribute( <name> )
gap> OPER_TO_ATTRIBUTE(fail);
Error, usage: OPER_TO_ATTRIBUTE( <oper> )
gap> OPER_TO_MUTABLE_ATTRIBUTE(fail);
Error, usage: OPER_TO_MUTABLE_ATTRIBUTE( <oper> )
gap> NEW_MUTABLE_ATTRIBUTE(fail);
Error, usage: NewMutableAttribute( <name> )
gap> NEW_PROPERTY(fail);
Error, usage: NewProperty( <name> )

#
gap> NEW_GLOBAL_FUNCTION(fail);
Error, usage: NewGlobalFunction( <name> )
gap> INSTALL_GLOBAL_FUNCTION(fail, fail);
Error, <oper> must be a function (not a boolean or fail)
gap> func := NEW_GLOBAL_FUNCTION("quux");;
gap> INSTALL_GLOBAL_FUNCTION(func, fail);
Error, <func> must be a function (not a boolean or fail)
gap> INSTALL_GLOBAL_FUNCTION(func, Size);
Error, <func> must not be an operation
gap> INSTALL_GLOBAL_FUNCTION(func, x -> x);
gap> INSTALL_GLOBAL_FUNCTION(func, x -> x);
Error, operation already installed

#
gap> METHODS_OPERATION(fail,1);
Error, <oper> must be an operation
gap> METHODS_OPERATION(Size,-1);
Error, <narg> must be a nonnegative integer
gap> METHODS_OPERATION(Size,0);
[  ]

# note: CHANGED_METHODS_OPERATION is not usable on HPC-GAP
gap> CHANGED_METHODS_OPERATION(fail,1);
Error, <oper> must be an operation
gap> CHANGED_METHODS_OPERATION(Size,-1);
Error, <narg> must be a nonnegative integer
gap> if not IsHPCGAP then CHANGED_METHODS_OPERATION(Size,0); fi;

#
gap> SET_METHODS_OPERATION (fail,1,[]);
Error, <oper> must be an operation
gap> SET_METHODS_OPERATION (Size,-1,[]);
Error, <narg> must be a nonnegative integer
gap> SET_METHODS_OPERATION (Size,0,[]);

#
gap> f:=SETTER_FUNCTION("foobar", IsPGroup);;
gap> f(fail, false);
Error, <obj> must be a component object
gap> SetIsPGroup(fail, false);
Error, Value cannot be set for internal objects

#
gap> f:=GETTER_FUNCTION("foobar");;
gap> f(fail);
Error, <obj> must be a component object

#
gap> CLEAR_CACHE_INFO();
gap> OPERS_CACHE_INFO();
[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]

#
# method tracing
#
gap> g:= Group( (1,2,3), (1,2) );;  Size( g );
6
gap> TraceMethods();
Error, `TraceMethods' require at least one argument
gap> TraceMethods([ 1 ]);
Error, <oper> must be an operation
gap> TraceMethods( [ Size ] );
gap> Size(g);
#I  Size: system getter
6
gap> UntraceMethods( [ Size ] );

# temporarily override (NEXT_)VMETHOD_PRINT_INFO to avoid system
# specific paths in the output
gap> MakeReadWriteGlobal("VMETHOD_PRINT_INFO");
gap> MakeReadWriteGlobal("NEXT_VMETHOD_PRINT_INFO");
gap> old1:=VMETHOD_PRINT_INFO;;
gap> old2:=NEXT_VMETHOD_PRINT_INFO;;
gap> VMETHOD_PRINT_INFO := function(methods, i, arity)
>     Print("#I  ", methods[(arity+4)*i], "\n");
> end;;
gap> NEXT_VMETHOD_PRINT_INFO := function(methods, i, arity)
>     Print("#I Trying next: ", methods[(arity+4)*i], "\n");
> end;;

#
gap> TraceMethods( [ IsCyclic ] );
gap> g:= Group( (1,2,3), (1,2) );;
gap> IsCyclic(g);
#I  IsCyclic
#I Trying next: IsCyclic: generic method for groups
false
gap> g:= Group( (1,2,3), (1,3,2) );;
gap> IsCyclic(g);
#I  IsCyclic
#I Trying next: IsCyclic: generic method for groups
true

# restore PRINT_INFO functions
gap> VMETHOD_PRINT_INFO:=old1;;
gap> NEXT_VMETHOD_PRINT_INFO:=old2;;
gap> MakeReadOnlyGlobal("VMETHOD_PRINT_INFO");
gap> MakeReadOnlyGlobal("NEXT_VMETHOD_PRINT_INFO");

#
gap> UntraceMethods();
Error, `UntraceMethods' require at least one argument
gap> UntraceMethods([ 1 ]);
Error, <oper> must be an operation
gap> UntraceMethods( [ IsCyclic ] );

#
gap> STOP_TEST("kernel/opers.tst", 1);
