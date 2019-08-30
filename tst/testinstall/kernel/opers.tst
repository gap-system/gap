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
gap> HASH_FLAGS(fail);
Error, HASH_FLAGS: <flags> must be a flags list (not the value 'fail')
gap> HASH_FLAGS(flags);
2

#
gap> TRUES_FLAGS(fail);
Error, TRUES_FLAGS: <flags> must be a flags list (not the value 'fail')
gap> TRUES_FLAGS(flags);
[ 1 ]

#
gap> SIZE_FLAGS(fail);
Error, SIZE_FLAGS: <flags> must be a flags list (not the value 'fail')
gap> SIZE_FLAGS(flags);
1

#
gap> IS_EQUAL_FLAGS(fail, flags);
Error, IS_EQUAL_FLAGS: <flags1> must be a flags list (not the value 'fail')
gap> IS_EQUAL_FLAGS(flags, fail);
Error, IS_EQUAL_FLAGS: <flags2> must be a flags list (not the value 'fail')
gap> IS_EQUAL_FLAGS(flags, flags);
true
gap> IS_EQUAL_FLAGS(flags, flags2);
false
gap> IS_EQUAL_FLAGS(flags2, flags);
false

#
gap> IS_SUBSET_FLAGS(fail, flags);
Error, IS_SUBSET_FLAGS: <flags1> must be a flags list (not the value 'fail')
gap> IS_SUBSET_FLAGS(flags, fail);
Error, IS_SUBSET_FLAGS: <flags2> must be a flags list (not the value 'fail')
gap> IS_SUBSET_FLAGS(flags, flags);
true
gap> IS_SUBSET_FLAGS(flags, flags2);
false
gap> IS_SUBSET_FLAGS(flags2, flags);
true

#
gap> SUB_FLAGS(fail, flags);
Error, SUB_FLAGS: <flags1> must be a flags list (not the value 'fail')
gap> SUB_FLAGS(flags, fail);
Error, SUB_FLAGS: <flags2> must be a flags list (not the value 'fail')
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
Error, AND_FLAGS: <flags1> must be a flags list (not the value 'fail')
gap> AND_FLAGS(flags, fail);
Error, AND_FLAGS: <flags2> must be a flags list (not the value 'fail')
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
Error, WITH_HIDDEN_IMPS_FLAGS: <flags> must be a flags list (not the value 'fa\
il')
gap> TRUES_FLAGS(WITH_HIDDEN_IMPS_FLAGS(flags));
[ 1, 2 ]

#
gap> WITH_IMPS_FLAGS(fail);
Error, WITH_IMPS_FLAGS: <flags> must be a flags list (not the value 'fail')
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
Error, filter is already set the other way

# test DoSetReturnTrueFilter
gap> Setter(IS_OBJECT)(G, true);
gap> Setter(IS_OBJECT)(G, false);
Error, you cannot set this flag to 'false'

# test DoSetProperty
gap> SetIsPGroup(G, false);
gap> SetIsPGroup(G, true);
Error, property is already set the other way

#
gap> NEW_FILTER(fail);
Error, NewFilter: <name> must be a string (not the value 'fail')

#
gap> FLAG1_FILTER(fail);
Error, FLAG1_FILTER: <oper> must be an operation (not the value 'fail')
gap> FLAG1_FILTER(Normalizer);
0

#
gap> FLAG2_FILTER(fail);
Error, FLAG2_FILTER: <oper> must be an operation (not the value 'fail')
gap> FLAG2_FILTER(Normalizer);
0

#
gap> FLAGS_FILTER(fail);
Error, FLAGS_FILTER: <oper> must be an operation (not the value 'fail')
gap> FLAGS_FILTER(Normalizer);
false

#
gap> SETTER_FILTER(fail);
Error, SETTER_FILTER: <oper> must be an operation (not the value 'fail')
gap> SETTER_FILTER(Normalizer);
false

#
gap> TESTER_FILTER(fail);
Error, TESTER_FILTER: <oper> must be an operation (not the value 'fail')
gap> TESTER_FILTER(Normalizer);
false

#
#
#

# DoOperationNArgs
gap> SymmetricGroupCons(1,2);
Error, Constructor: the first argument must be a filter (not the integer 1)

#
gap> NEW_OPERATION(fail);
Error, NewOperation: <name> must be a string (not the value 'fail')
gap> NEW_CONSTRUCTOR(fail);
Error, NewConstructor: <name> must be a string (not the value 'fail')
gap> NEW_ATTRIBUTE(fail);
Error, NewAttribute: <name> must be a string (not the value 'fail')
gap> OPER_TO_ATTRIBUTE(fail);
Error, OPER_TO_ATTRIBUTE: <oper> must be an operation (not the value 'fail')
gap> OPER_TO_MUTABLE_ATTRIBUTE(fail);
Error, OPER_TO_MUTABLE_ATTRIBUTE: <oper> must be an operation (not the value '\
fail')
gap> NEW_MUTABLE_ATTRIBUTE(fail);
Error, NewMutableAttribute: <name> must be a string (not the value 'fail')
gap> NEW_PROPERTY(fail);
Error, NewProperty: <name> must be a string (not the value 'fail')

#
gap> NEW_GLOBAL_FUNCTION(fail);
Error, NewGlobalFunction: <name> must be a string (not the value 'fail')
gap> INSTALL_GLOBAL_FUNCTION(fail, fail);
Error, INSTALL_GLOBAL_FUNCTION: <oper> must be a function (not the value 'fail\
')
gap> func := NEW_GLOBAL_FUNCTION("quux");;
gap> INSTALL_GLOBAL_FUNCTION(func, fail);
Error, INSTALL_GLOBAL_FUNCTION: <func> must be a function (not the value 'fail\
')
gap> INSTALL_GLOBAL_FUNCTION(func, Size);
Error, <func> must not be an operation
gap> INSTALL_GLOBAL_FUNCTION(func, x -> x);
gap> INSTALL_GLOBAL_FUNCTION(func, x -> x);
Error, operation already installed

#
gap> METHODS_OPERATION(fail,1);
Error, METHODS_OPERATION: <oper> must be an operation (not the value 'fail')
gap> METHODS_OPERATION(Size,-1);
Error, METHODS_OPERATION: <narg> must be an integer between 0 and 6 (not the i\
nteger -1)
gap> METHODS_OPERATION(Size,0);
[  ]
gap> METHODS_OPERATION(Size,6);
[  ]
gap> METHODS_OPERATION(Size,7);
Error, METHODS_OPERATION: <narg> must be an integer between 0 and 6 (not the i\
nteger 7)

# note: CHANGED_METHODS_OPERATION is not usable on HPC-GAP
gap> CHANGED_METHODS_OPERATION(fail,1);
Error, CHANGED_METHODS_OPERATION: <oper> must be an operation (not the value '\
fail')
gap> CHANGED_METHODS_OPERATION(Size,-1);
Error, CHANGED_METHODS_OPERATION: <narg> must be an integer between 0 and 6 (n\
ot the integer -1)
gap> if not IsHPCGAP then CHANGED_METHODS_OPERATION(Size,0); fi;
gap> if not IsHPCGAP then CHANGED_METHODS_OPERATION(Size,6); fi;
gap> CHANGED_METHODS_OPERATION(Size,7);
Error, CHANGED_METHODS_OPERATION: <narg> must be an integer between 0 and 6 (n\
ot the integer 7)

#
gap> SET_METHODS_OPERATION (fail,1,[]);
Error, SET_METHODS_OPERATION: <oper> must be an operation (not the value 'fail\
')
gap> SET_METHODS_OPERATION (Size,-1,[]);
Error, SET_METHODS_OPERATION: <narg> must be an integer between 0 and 6 (not t\
he integer -1)
gap> SET_METHODS_OPERATION (Size,0,[]);
gap> SET_METHODS_OPERATION (Size,6,[]);
gap> SET_METHODS_OPERATION (Size,7,[]);
Error, SET_METHODS_OPERATION: <narg> must be an integer between 0 and 6 (not t\
he integer 7)

#
gap> f:=SETTER_FUNCTION("foobar", IsPGroup);;
gap> f(fail, false);
Error, <obj> must be a component object
gap> SetIsPGroup(fail, false);
Error, property cannot be set for internal objects

#
gap> f:=GETTER_FUNCTION("foobar");;
gap> f(fail);
Error, <obj> must be a component object

#
gap> CLEAR_CACHE_INFO();
gap> opcheck := OPERS_CACHE_INFO();;
gap> if GAPInfo.KernelInfo.KernelDebug then
>   if IsHPCGAP then
>     ops := [ 0, 0, 0, 6, 0, 0, 4, 0, 0, 0, 0];
>   else
>     ops := [ 0, 0, 0, 7, 0, 0, 2, 0, 0, 0, 0];
>   fi;
> else
>  ops := [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
> fi;
gap> opcheck{[1..11]} = ops;
true

#
# method tracing
#
gap> g:= Group( (1,2,3), (1,2) );;  Size( g );
6
gap> TraceMethods();
Error, `TraceMethods' require at least one argument
gap> TraceMethods([ 1 ]);
Error, TRACE_METHODS: <oper> must be an operation (not the integer 1)
gap> TraceMethods( [ Size ] );
gap> UntraceMethods( [ Size ] );

# temporarily override (NEXT_)VMETHOD_PRINT_INFO to avoid system
# specific paths in the output
gap> MakeReadWriteGlobal("VMETHOD_PRINT_INFO");
gap> MakeReadWriteGlobal("NEXT_VMETHOD_PRINT_INFO");
gap> old1:=VMETHOD_PRINT_INFO;;
gap> old2:=NEXT_VMETHOD_PRINT_INFO;;
gap> VMETHOD_PRINT_INFO := function(methods, i, arity)
>     local offset;
>     offset := (arity+BASE_SIZE_METHODS_OPER_ENTRY)*(i-1)+arity;
>     Print("#I  ", methods[offset+4], "\n");
> end;;
gap> NEXT_VMETHOD_PRINT_INFO := function(methods, i, arity)
>     local offset;
>     offset := (arity+BASE_SIZE_METHODS_OPER_ENTRY)*(i-1)+arity;
>     Print("#I Trying next: ", methods[offset+4], "\n");
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
Error, UNTRACE_METHODS: <oper> must be an operation (not the integer 1)
gap> UntraceMethods( [ IsCyclic ] );

#
gap> STOP_TEST("kernel/opers.tst", 1);
