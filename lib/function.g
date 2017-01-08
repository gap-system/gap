#############################################################################
##
#W  function.g                   GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file deals with functions.
##


#############################################################################
##
#C  IsFunction( <obj> )	. . . . . . . . . . . . . . . . category of functions
##
##  <#GAPDoc Label="IsFunction">
##  <ManSection>
##  <Filt Name="IsFunction" Arg='obj' Type='Category'/>
##
##  <Description>
##  is the category of functions.
##  <P/>
##  <Example><![CDATA[
##  gap> IsFunction(x->x^2);
##  true
##  gap> IsFunction(Factorial);
##  true
##  gap> f:=One(AutomorphismGroup(SymmetricGroup(3)));
##  IdentityMapping( Sym( [ 1 .. 3 ] ) )
##  gap> IsFunction(f);         
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsFunction",
    IS_OBJECT,
    IS_FUNCTION );


#############################################################################
##
#C  IsOperation( <obj> )  . . . . . . . . . . . . . .  category of operations
##
##  <#GAPDoc Label="IsOperation">
##  <ManSection>
##  <Filt Name="IsOperation" Arg='obj' Type='Category'/>
##
##  <Description>
##  is the category of operations.
##  Every operation is a function, but not vice versa.
##  <P/>
##  <Example><![CDATA[
##  gap> MinimalPolynomial;  
##  <Operation "MinimalPolynomial">
##  gap> IsOperation(MinimalPolynomial);
##  true
##  gap> IsFunction(MinimalPolynomial);         
##  true
##  gap> Factorial;
##  function( n ) ... end
##  gap> IsOperation(Factorial);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsOperation",
    IS_FUNCTION,
    IS_OPERATION );


#############################################################################
##
#V  FunctionsFamily . . . . . . . . . . . . . . . . . . . family of functions
##
##  <#GAPDoc Label="FunctionsFamily">
##  <ManSection>
##  <Fam Name="FunctionsFamily"/>
##
##  <Description>
##  is the family of all functions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "FunctionsFamily", NewFamily( "FunctionsFamily", IsFunction ) );


#############################################################################
##
#V  TYPE_FUNCTION . . . . . . . . . . . . . . . . . . . .  type of a function
##
##  <ManSection>
##  <Var Name="TYPE_FUNCTION"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_FUNCTION", NewType( FunctionsFamily,
                          IsFunction and IsInternalRep ) );


#############################################################################
##
#F  TYPE_OPERATION  . . . . . . . . . . . . . . . . . . . type of a operation
##
##  <ManSection>
##  <Func Name="TYPE_OPERATION" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_OPERATION",
    NewType( FunctionsFamily,
             IsFunction and IsOperation and IsInternalRep ) );


#############################################################################
##
#O  NameFunction( <func> )  . . . . . . . . . . . . . . .  name of a function
##
##  <#GAPDoc Label="NameFunction">
##  <ManSection>
##  <Oper Name="NameFunction" Arg='func'/>
##
##  <Description>
##  returns the name of a function. For operations, this is the name used in
##  their declaration. For functions, this is the variable name they were
##  first assigned to. (For some internal functions, this might be a name
##  <E>different</E> from the name that is documented.)
##  If no such name exists, the string <C>"unknown"</C> is returned.
##  <P/>
##  <Example><![CDATA[
##  gap> NameFunction(SylowSubgroup);
##  "SylowSubgroup"
##  gap> Blubberflutsch:=x->x;;
##  gap> NameFunction(Blubberflutsch);
##  "Blubberflutsch"
##  gap> a:=Blubberflutsch;;
##  gap> NameFunction(a);
##  "Blubberflutsch"
##  gap> NameFunction(x->x);
##  "unknown"
##  gap> NameFunction(NameFunction);
##  "NameFunction"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##
DeclareOperationKernel("NameFunction", [IS_OBJECT], NAME_FUNC);


#############################################################################
##
#F  SetNameFunction( <func>, <name> )  . . . . . . . .set  name of a function
##
##  <ManSection>
##  <Func Name="SetNameFunction" Arg='func, name'/>
##
##  <Description>
##  changes the name of a function. This only changes the name stored in
##  the function and used (for instance) in profiling. It does not change
##  any assignments to global variables. 
##  </Description>
##  </ManSection>
##
#T  If objects simulate functions this must become an operation, or an attribute
#T  with the above
##
DeclareOperationKernel( "SetNameFunction", [IS_OBJECT, IS_STRING], SET_NAME_FUNC );


#############################################################################
##
#F  NumberArgumentsFunction( <func> )
##
##  <#GAPDoc Label="NumberArgumentsFunction">
##  <ManSection>
##  <Oper Name="NumberArgumentsFunction" Arg='func'/>
##
##  <Description>
##  returns the number of arguments the function <A>func</A> accepts.
##  -1 is returned for all operations.
##  For functions that use <C>...</C> or <C>arg</C> to take a variable number of
##  arguments, the number returned is -1 times the total number of parameters.
##  For attributes, 1 is returned.
##  <P/>
##  <Example><![CDATA[
##  gap> NumberArgumentsFunction(function(a,b,c,d,e,f,g,h,i,j,k)return 1;end);
##  11
##  gap> NumberArgumentsFunction(Size);
##  1
##  gap> NumberArgumentsFunction(IsCollsCollsElms);
##  3
##  gap> NumberArgumentsFunction(Sum);
##  -1
##  gap> NumberArgumentsFunction(function(a, x...) return 1; end);
##  -2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "NumberArgumentsFunction", [IS_OBJECT], NARG_FUNC );


#############################################################################
##
#F  NamesLocalVariablesFunction( <func> )
##
##  <#GAPDoc Label="NamesLocalVariablesFunction">
##  <ManSection>
##  <Oper Name="NamesLocalVariablesFunction" Arg='func'/>
##
##  <Description>
##  returns a mutable list of strings;
##  the first entries are the names of the arguments of the function
##  <A>func</A>, in the same order as they were entered in the definition of
##  <A>func</A>, and the remaining ones are the local variables as given in
##  the <K>local</K> statement in <A>func</A>.
##  (The number of arguments can be computed with
##  <Ref Func="NumberArgumentsFunction"/>.)
##  <P/>
##  <Example><![CDATA[
##  gap> NamesLocalVariablesFunction(function( a, b ) local c; return 1; end);
##  [ "a", "b", "c" ]
##  gap> NamesLocalVariablesFunction(function( arg ) local a; return 1; end);
##  [ "arg", "a" ]
##  gap> NamesLocalVariablesFunction( Size );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "NamesLocalVariablesFunction", NAMS_FUNC );


#############################################################################
##
##  <#GAPDoc Label="FilenameFunc">
##  <ManSection>
##  <Func Name="FilenameFunc" Arg='func'/>
##
##  <Description>
##  For a function <A>func</A>, <Ref Func="FilenameFunc"/> returns either
##  <K>fail</K> or the absolute path of the file from which <A>func</A>
##  has been read.
##  The return value <K>fail</K> occurs if <A>func</A> is
##  a compiled function or an operation.
##  For functions that have been entered interactively,
##  the string <C>"*stdin*"</C> is returned,
##  see Section <Ref Sect="Special Filenames"/>.
##  <P/>
##  <Log><![CDATA[
##  gap> FilenameFunc( LEN_LIST );  # a kernel function
##  fail
##  gap> FilenameFunc( Size );      # an operation
##  fail
##  gap> FilenameFunc( x -> x^2 );  # an interactively entered function
##  "*stdin*"
##  gap> meth:= ApplicableMethod( Size, [ Group( () ) ] );;
##  gap> FilenameFunc( meth );
##  "... some path .../grpperm.gi"
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "FilenameFunc", FILENAME_FUNC );


#############################################################################
##
##  <#GAPDoc Label="StartlineFunc">
##  <ManSection>
##  <Func Name="StartlineFunc" Arg='func'/>
##  <Func Name="EndlineFunc" Arg='func'/>
##
##  <Description>
##  Let <A>func</A> be a function.
##  If <Ref Func="FilenameFunc"/> returns <K>fail</K> for <A>func</A> then
##  also <Ref Func="StartlineFunc"/> returns <K>fail</K>.
##  If <Ref Func="FilenameFunc"/> returns a filename for <A>func</A> then
##  <Ref Func="StartlineFunc"/> returns the line number in this file
##  where the definition of <A>func</A> starts.
##  <P/>
##  <Ref Func="EndlineFunc"/> behaves similarly and returns the line number 
##  in this file where the definition of <A>func</A> ends.
##  <P/>
##  <Log><![CDATA[
##  gap> meth:= ApplicableMethod( Size, [ Group( () ) ] );;
##  gap> FilenameFunc( meth );
##  "... some path ... gap4r5/lib/grpperm.gi"
##  gap> StartlineFunc( meth );
##  487
##  gap> EndlineFunc( meth );
##  487
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "StartlineFunc", STARTLINE_FUNC );
BIND_GLOBAL( "EndlineFunc", ENDLINE_FUNC );

#############################################################################
##
##  <#GAPDoc Label="LocationFunc">
##  <ManSection>
##  <Func Name="LocationFunc" Arg='func'/>
##
##  <Description>
##  Let <A>func</A> be a function.
##  Returns a string describing the location of <A>func</A>, or an empty
##  string if the information cannot be found. This uses the information
##  provided by <Ref Func="FilenameFunc"/> and <Ref Func="StartlineFunc"/>
##  <P/>
##  <Log><![CDATA[
##  gap> FilenameFunc( Intersection );
##  "... some path ... gap/lib/coll.gi:2467"
##  # String is an attribute, so no information is stored
##  gap> FilenameFunc( String );
##  ""
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "LocationFunc", function(x)
    local nam, line, ret;
    # If someone passes something which isn't a true function,
    # like a method or attribute, just return.
    if not(IS_FUNCTION(x)) then
        return "";
    fi;
    nam := FILENAME_FUNC(x);
    line := STARTLINE_FUNC(x);
    ret := "";
    if nam <> fail and line <> fail then
        APPEND_LIST(ret, nam);
        APPEND_LIST(ret, ":");
        APPEND_LIST(ret, STRING_INT(line));
    fi;
    return ret;
end);


#############################################################################
##
#F  CallFuncList( <func>, <args> )  . . . . . . . . . . . . . call a function
##
##  <#GAPDoc Label="CallFuncList">
##  <ManSection>
##  <Oper Name="CallFuncList" Arg='func, args'/>
##
##  <Description>
##  returns the result, when calling function <A>func</A> with the arguments
##  given in the list <A>args</A>,
##  i.e.&nbsp;<A>args</A> is <Q>unwrapped</Q> so that <A>args</A> 
##  appears as several arguments to <A>func</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> CallFuncList(\+, [6, 7]);
##  13
##  gap> #is equivalent to:
##  gap> \+(6, 7);
##  13
##  ]]></Example>
##  <P/>
##  A more useful application of <Ref Func="CallFuncList"/> is for a function
##  <C>g</C> that is called in the body of a function <C>f</C> with
##  (a sublist of) the arguments of <C>f</C>, where <C>f</C> has been defined
##  with a single formal argument <C>arg</C>
##  (see&nbsp;<Ref Sect="Function"/>), as in the following code fragment.
##  <P/>
##  <Log><![CDATA[
##  f := function ( arg )
##         CallFuncList(g, arg);
##         ...
##       end;
##  ]]></Log>
##  <P/>
##  In the body of <C>f</C> the several arguments passed to <C>f</C> become a
##  list <C>arg</C>.
##  If <C>g</C> were called instead via <C>g( arg )</C> then <C>g</C> would
##  see a single list argument, so that <C>g</C> would, in general, have to
##  <Q>unwrap</Q> the passed list.
##  The following (not particularly useful) example demonstrates both
##  described possibilities for the call to <C>g</C>.
##  <P/>
##  <Example><![CDATA[
##  gap> PrintNumberFromDigits := function ( arg )
##  >     CallFuncList( Print, arg );
##  >     Print( "\n" );
##  >    end;
##  function( arg... ) ... end
##  gap> PrintNumberFromDigits( 1, 9, 7, 3, 2 );
##  19732
##  gap> PrintDigits := function ( arg )
##  >     Print( arg );
##  >     Print( "\n" );
##  >    end;
##  function( arg... ) ... end
##  gap> PrintDigits( 1, 9, 7, 3, 2 );
##  [ 1, 9, 7, 3, 2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
#T  If objects simulate functions this must become an operation.
##
UNBIND_GLOBAL("CallFuncList"); # was declared 2b defined
DeclareOperationKernel( "CallFuncList", [IS_OBJECT, IS_LIST], CALL_FUNC_LIST );


#############################################################################
##
#F  ReturnTrue( ... ) . . . . . . . . . . . . . . . . . . . . . . always true
##
##  <#GAPDoc Label="ReturnTrue">
##  <ManSection>
##  <Func Name="ReturnTrue" Arg='...'/>
##
##  <Description>
##  This function takes any number of arguments,
##  and always returns <K>true</K>.
##  <P/>
##  <Example><![CDATA[
##  gap> f:=ReturnTrue;  
##  function( arg... ) ... end
##  gap> f();  
##  true
##  gap> f(42);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "ReturnTrue", RETURN_TRUE );


#############################################################################
##
#F  ReturnFalse( ... )  . . . . . . . . . . . . . . . . . . . .  always false
##
##  <#GAPDoc Label="ReturnFalse">
##  <ManSection>
##  <Func Name="ReturnFalse" Arg='...'/>
##
##  <Description>
##  This function takes any number of arguments,
##  and always returns <K>false</K>.
##  <P/>
##  <Example><![CDATA[
##  gap> f:=ReturnFalse;  
##  function( arg... ) ... end
##  gap> f();  
##  false
##  gap> f("any_string");
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "ReturnFalse", RETURN_FALSE );


#############################################################################
##
#F  ReturnFail( ... ) . . . . . . . . . . . . . . . . . . . . . . always fail
##
##  <#GAPDoc Label="ReturnFail">
##  <ManSection>
##  <Func Name="ReturnFail" Arg='...'/>
##
##  <Description>
##  This function takes any number of arguments,
##  and always returns <K>fail</K>.
##  <P/>
##  <Example><![CDATA[
##  gap> oops:=ReturnFail;  
##  function( arg... ) ... end
##  gap> oops();  
##  fail
##  gap> oops(-42);  
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "ReturnFail", RETURN_FAIL );

#############################################################################
##
#F  ReturnNothing( ... ) . . . . . . . . . . . . . . . . . . 
##
##  <#GAPDoc Label="ReturnNothing">
##  <ManSection>
##  <Func Name="ReturnNothing" Arg='...'/>
##
##  <Description>
##  This function takes any number of arguments,
##  and always returns nothing.
##  <P/>
##  <Example><![CDATA[
##  gap> n:=ReturnNothing;
##  function( object... ) ... end
##  gap> n();
##  gap> n(-42);
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "ReturnNothing", RETURN_NOTHING );

#############################################################################
##
#F  ReturnFirst( ... ) . . . . . . . . . . . . . . . . . . 
##
##  <#GAPDoc Label="ReturnFirst">
##  <ManSection>
##  <Func Name="ReturnFirst" Arg='...'/>
##
##  <Description>
##  This function takes one or more arguments, and always returns
##  the first argument. <Ref Func="IdFunc"/> behaves similarly, but only
##  accepts a single argument.
##  <P/>
##  <Example><![CDATA[
##  gap> f:=ReturnFirst;
##  function( object... ) ... end
##  gap> f(1);
##  1
##  gap> f(2,3,4);
##  2
##  gap> f();
##  Error, RETURN_FIRST requires one or more arguments
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "ReturnFirst", RETURN_FIRST );

#############################################################################
##
#F  IdFunc( <obj> ) . . . . . . . . . . . . . . . . . . . . . .  return <obj>
##
##  <#GAPDoc Label="IdFunc">
##  <ManSection>
##  <Func Name="IdFunc" Arg='obj'/>
##
##  <Description>
##  returns <A>obj</A>. <Ref Func="ReturnFirst"/> is similar, but accepts
##  one or more arguments, returning only the first.
##  <P/>
##  <Example><![CDATA[
##  gap> id:=IdFunc;  
##  function( object ) ... end
##  gap> id(42);  
##  42
##  gap> f:=id(SymmetricGroup(3));                 
##  Sym( [ 1 .. 3 ] )
##  gap> s:=One(AutomorphismGroup(SymmetricGroup(3)));
##  IdentityMapping( Sym( [ 1 .. 3 ] ) )
##  gap> f=s;
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "IdFunc", ID_FUNC );


#############################################################################
##
#M  ViewObj( <func> ) . . . . . . . . . . . . . . . . . . . . . . view method
##
InstallMethod( ViewObj, "for a function", true, [IsFunction], 0,
        function ( func )
    local nams, narg, i, isvarg;
    Print("function( ");
    isvarg := false;
    nams := NAMS_FUNC(func);
    narg := NARG_FUNC(func);
    if narg < 0 then
        isvarg := true;
        narg := -narg;
    fi;
    if narg = 1 and nams <> fail and nams[1] = "arg" then
        isvarg := true;
    fi;
    if narg <> 0 then
        if nams = fail then
            Print( "<",narg," unnamed arguments>" );
        else
            Print(nams[1]);
            for i in [2..narg] do
                Print(", ",nams[i]);
            od;
        fi;
        if isvarg then
            Print("...");
        fi;
    fi;    
    Print(" ) ... end");
end);

BIND_GLOBAL( "VIEW_STRING_OPERATION",    function ( op )
    local   class,  flags,  types,  catok,  repok,  propok,  seenprop,
            t, res;
    class := "Operation";
    if IS_IDENTICAL_OBJ(op,IS_OBJECT) then
        class := "Filter";
    elif IS_CONSTRUCTOR(op) then
        class := "Constructor";
    elif IsFilter(op) then
        class := "Filter";
        flags := FLAGS_FILTER(op);
        if flags <> false then
            flags := TRUES_FLAGS(FLAGS_FILTER(op));
        else
            flags := [];
        fi;
        types := INFO_FILTERS{flags};
        catok := true;
        repok := true;
        propok := true;
        seenprop := false;
        for t in types do
            if not t in FNUM_REPS then
                repok := false;
            fi;
            if not t in FNUM_CATS then
                catok := false;
            fi;
            if not t in FNUM_PROS and not t in FNUM_TPRS then
                propok := false;
            fi;
            if t in FNUM_PROS then
                seenprop := true;
            fi;
        od;
        if seenprop and propok then
            class := "Property";
        elif catok then
            class := "Category";
        elif repok then
            class := "Representation";
        fi;
    elif Tester(op) <> false  then
        # op is an attribute
        class := "Attribute";
    fi;

    # Horrible.
    res := "<";
    APPEND_LIST(res, class);
    APPEND_LIST(res, " \"");
    APPEND_LIST(res, NAME_FUNC(op));
    APPEND_LIST(res, "\">");
    return res;
end);

BIND_GLOBAL( "PRINT_OPERATION",
function ( op )
    Print(VIEW_STRING_OPERATION(op));
end);

InstallMethod( ViewObj,
    "for an operation",
    [ IsOperation ],
    PRINT_OPERATION );

InstallMethod( ViewString,
    "for an operation",
    [ IsOperation ],
function(op)
    return VIEW_STRING_OPERATION(op);
end);

#############################################################################
##
#E
