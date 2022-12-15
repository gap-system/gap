#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file deals with functions.
##


#############################################################################
##
#C  IsFunction( <obj> ) . . . . . . . . . . . . . . . . category of functions
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
#O  NameFunction( <func> )  . . . . . . . . . . . . . . .  name of a function
##
##  <#GAPDoc Label="NameFunction">
##  <ManSection>
##  <Attr Name="NameFunction" Arg='func'/>
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
##  gap> HasNameFunction(Blubberflutsch);
##  true
##  gap> NameFunction(Blubberflutsch);
##  "Blubberflutsch"
##  gap> a:=Blubberflutsch;;
##  gap> NameFunction(a);
##  "Blubberflutsch"
##  gap> SetNameFunction(a, "f");
##  gap> NameFunction(a);
##  "f"
##  gap> HasNameFunction(x->x);
##  false
##  gap> NameFunction(x->x);
##  "unknown"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##
DeclareAttributeKernel("NameFunction", IS_OBJECT, NAME_FUNC);


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
BIND_GLOBAL( "TYPE_FUNCTION_WITH_NAME", NewType( FunctionsFamily,
                          IsFunction and IsInternalRep and HasNameFunction ) );


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

BIND_GLOBAL( "TYPE_OPERATION_WITH_NAME",
    NewType( FunctionsFamily,
             IsFunction and IsOperation and IsInternalRep and HasNameFunction ) );


#############################################################################
##
#O  NumberArgumentsFunction( <func> )
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
#O  NamesLocalVariablesFunction( <func> )
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
##  <Ref Oper="NumberArgumentsFunction"/>.)
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
DeclareOperationKernel( "NamesLocalVariablesFunction", [IS_OBJECT], NAMS_FUNC );


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
##  "... some path ... /lib/grpperm.gi"
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
##  Returns a string describing the location of <A>func</A>, or <K>fail</K>
##  if the information cannot be found. This uses the information
##  provided by <Ref Func="FilenameFunc"/> and <Ref Func="StartlineFunc"/>
##  <P/>
##  <Log><![CDATA[
##  gap> LocationFunc( Intersection );
##  "... some path ... gap/lib/coll.gi:2467"
##  # String is an attribute, so no information is stored
##  gap> LocationFunc( String );
##  fail
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "LocationFunc", function(func)
    local nam, line, ret;
    # If someone passes something which isn't a true function,
    # like a method or attribute, just return.
    if not IS_FUNCTION(func) then
        Error("<func> must be a function");
    fi;
    ret := "";
    nam := FILENAME_FUNC(func);
    if nam = fail then
        return fail;
    fi;
    line := STARTLINE_FUNC(func);
    if line <> fail then
        APPEND_LIST(ret, nam);
        APPEND_LIST(ret, ":");
        APPEND_LIST(ret, STRING_INT(line));
        return ret;
    fi;
    line := LOCATION_FUNC(func);
    if line <> fail then
        APPEND_LIST(ret, nam);
        APPEND_LIST(ret, ":");
        APPEND_LIST(ret, line);
        return ret;
    fi;
    return fail;
end);


#############################################################################
##
#O  CallFuncList( <func>, <args> )  . . . . . . . . . . . . . call a function
##
##  <#GAPDoc Label="CallFuncList">
##  <ManSection>
##  <Oper Name="CallFuncList" Arg='func, args'/>
##  <Oper Name="CallFuncListWrap" Arg='func, args'/>
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
##  A more useful application of <Ref Oper="CallFuncList"/> is for a function
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
##  <Ref Oper="CallFuncListWrap"/> differs only in that the result is a list.
##  This returned list is empty if the called function returned no value,
##  else it contains the returned value as its single member. This allows
##  wrapping functions which may, or may not return a value.
##
##  <Example><![CDATA[
##  gap> CallFuncListWrap( x -> x, [1] );
##  [ 1 ]
##  gap> CallFuncListWrap( function(x) end, [1] );
##  [ ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
UNBIND_GLOBAL("CallFuncList"); # was declared 2b defined
DeclareOperationKernel( "CallFuncList", [IS_OBJECT, IS_LIST], CALL_FUNC_LIST );
DeclareOperationKernel( "CallFuncListWrap", [IS_OBJECT, IS_LIST], CALL_FUNC_LIST_WRAP );


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
##  function( first, rest... ) ... end
##  gap> f(1);
##  1
##  gap> f(2,3,4);
##  2
##  gap> f();
##  Error, Function: number of arguments must be at least 1 (not 0)
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
    local  locks, nams, narg, i, isvarg;
    Print("function( ");
    isvarg := false;
    locks := LOCKS_FUNC(func);
    if locks <> fail then
        Print("atomic ");
    fi;
    nams := NAMS_FUNC(func);
    narg := NARG_FUNC(func);
    if narg < 0 then
        isvarg := true;
        narg := -narg;
    fi;
    if narg <> 0 then
        if nams = fail then
            Print( "<",narg," unnamed arguments>" );
        else
            if locks <> fail then
                if locks[1] = '\001' then
                    Print("readonly ");
                elif locks[1] = '\002' then
                    Print("readwrite ");
                fi;
            fi;
            Print(nams[1]);
            for i in [2..narg] do
                if locks <> fail then
                    if locks[i] = '\001' then
                        Print("readonly ");
                    elif locks[i] = '\002' then
                        Print("readwrite ");
                    fi;
                fi;
                Print(", ",nams[i]);
            od;
        fi;
        if isvarg then
            Print("...");
        fi;
    fi;
    Print(" ) ... end");
end);
