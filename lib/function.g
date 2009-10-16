#############################################################################
##
#W  function.g                   GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id: function.g,v 4.21 2008/09/09 16:11:14 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file deals with functions.
##
Revision.function_g :=
    "@(#)$Id: function.g,v 4.21 2008/09/09 16:11:14 gap Exp $";


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
##  <Var Name="FunctionsFamily"/>
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
#F  NameFunction( <func> )  . . . . . . . . . . . . . . .  name of a function
##
##  <#GAPDoc Label="NameFunction">
##  <ManSection>
##  <Func Name="NameFunction" Arg='func'/>
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
##  "NAME_FUNC"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
#T  If objects simulate functions this must become an operation.
##
BIND_GLOBAL( "NameFunction", NAME_FUNC );

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
BIND_GLOBAL( "SetNameFunction", SET_NAME_FUNC );


#############################################################################
##
#F  NumberArgumentsFunction( <func> )
##
##  <#GAPDoc Label="NumberArgumentsFunction">
##  <ManSection>
##  <Func Name="NumberArgumentsFunction" Arg='func'/>
##
##  <Description>
##  returns the number of arguments the function <A>func</A> accepts.
##  For functions that use <C>arg</C> to take a variable number of arguments,
##  as well as for operations, -1 is returned.
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
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "NumberArgumentsFunction", NARG_FUNC );


#############################################################################
##
#F  NamesLocalVariablesFunction( <func> )
##
##  <#GAPDoc Label="NamesLocalVariablesFunction">
##  <ManSection>
##  <Func Name="NamesLocalVariablesFunction" Arg='func'/>
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
##  gap> NamesLocalVariablesFunction( function( a, b ) local c; return 1; end );
##  [ "a", "b", "c" ]
##  gap> NamesLocalVariablesFunction( function( arg ) local a; return 1; end );
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
#F  CallFuncList( <func>, <args> )  . . . . . . . . . . . . . call a function
##
##  <#GAPDoc Label="CallFuncList">
##  <ManSection>
##  <Func Name="CallFuncList" Arg='func, args'/>
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
##  function( arg ) ... end
##  gap> PrintNumberFromDigits( 1, 9, 7, 3, 2 );
##  19732
##  gap> PrintDigits := function ( arg )
##  >     Print( arg );
##  >     Print( "\n" );
##  >    end;
##  function( arg ) ... end
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
BIND_GLOBAL( "CallFuncList", CALL_FUNC_LIST );


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
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "ReturnFail", RETURN_FAIL );


#############################################################################
##
#F  IdFunc( <obj> ) . . . . . . . . . . . . . . . . . . . . . .  return <obj>
##
##  <#GAPDoc Label="IdFunc">
##  <ManSection>
##  <Func Name="IdFunc" Arg='obj'/>
##
##  <Description>
##  returns <A>obj</A>.
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
    local nams, narg, i;
    Print("function( ");
    nams := NAMS_FUNC(func);
    narg := NARG_FUNC(func);
    if nams = fail then
        Print( "<",narg," unnamed arguments>" );
    elif narg = -1 then
        Print("arg");
    elif narg > 0 then
        Print(nams[1]);
        for i in [2..narg] do
            Print(", ",nams[i]);
        od;
    fi;
    Print(" ) ... end");
end);

    
BIND_GLOBAL( "PRINT_OPERATION",    function ( op )
    Print("<Operation \"",NAME_FUNC(op),"\">");
         end);  
    
    InstallMethod( ViewObj, "for an operation", true, [IsOperation], 0,
            PRINT_OPERATION);
    

#############################################################################
##
#E

