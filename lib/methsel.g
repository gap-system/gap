#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file defines the less frequently used functions to select
##  methods. More frequently used functions used to be in methsel1.g,
##  which was compiled in the default setup; this code has now been
##  replaced by hand written C code in the kernel.
##


#############################################################################
##
#F  # # # # # # # # # # # # #  method selection # # # # # # # # # # # # # # #
##


#############################################################################
##
#F  AttributeValueNotSet( <attr>, <obj> )
##
BIND_GLOBAL( "AttributeValueNotSet", function(attr,obj)
local type,fam,methods,i,j,flag,erg;
  type:=TypeObj(obj);
  fam:=FamilyObj(obj);
  methods:=METHODS_OPERATION(attr,1);
  for i in [1..LEN_LIST(methods)/(1+BASE_SIZE_METHODS_OPER_ENTRY)] do
    j:=(1+BASE_SIZE_METHODS_OPER_ENTRY)*(i-1);
    flag:=true;
    flag:=flag and IS_SUBSET_FLAGS(type![2],methods[j+2]);
    if flag then
      flag:=flag and methods[j+1](fam);
    fi;
    if flag then
      attr:=methods[j+3];
      erg:=attr(obj);
      if not IS_IDENTICAL_OBJ(erg,TRY_NEXT_METHOD) then
        return erg;
      fi;
    fi;
  od;
  Error("No applicable method found for attribute");
end );


#############################################################################
##
#F  # # # # # # # # # # #  verbose method selection # # # # # # # # # # # # #
##
BIND_GLOBAL( "VMETHOD_PRINT_INFO", function ( methods, i, arity)
    local offset;
    offset := (arity+BASE_SIZE_METHODS_OPER_ENTRY)*(i-1)+arity;
    Print("#I  ", methods[offset+4],
          " at ", methods[offset+5][1], ":", methods[offset+5][2], "\n");
end );

#############################################################################
##
#F  # # # # # # # # # # #  verbose try next method  # # # # # # # # # # # # #
##
BIND_GLOBAL( "NEXT_VMETHOD_PRINT_INFO", function ( methods, i, arity)
    local offset;
    offset := (arity+BASE_SIZE_METHODS_OPER_ENTRY)*(i-1)+arity;
    Print("#I Trying next: ", methods[offset+4],
          " at ", methods[offset+5][1], ":", methods[offset+5][2], "\n");
end );

#############################################################################
##
#F  NewTagBasedOperation( <name>, <requirements> )
#F  DeclareTagBasedOperation( <name>, <requirements> )
#F  InstallTagBasedMethod( <oper>[, <tag>], <meth> )
##
##  <#GAPDoc Label="DeclareTagBasedOperation">
##  <ManSection>
##  <Heading>Tag Based Operations</Heading>
##  <Func Name="NewTagBasedOperation" Arg='name, requirements'/>
##  <Func Name="DeclareTagBasedOperation" Arg='name, requirements'/>
##  <Func Name="InstallTagBasedMethod" Arg='oper[, tag], meth'/>
##
##  <Description>
##  <Ref Func="NewTagBasedOperation"/> returns an operation with name
##  <A>name</A> that is declared as <E>tag based</E>
##  w.r.t. the list <A>requirements</A> of filters for its arguments.
##  If an operation with name <A>name</A> exists already before the call
##  then this operation is returned, otherwise a new operation gets created.
##  <P/>
##  <Ref Func="DeclareTagBasedOperation"/> does the same and additionally
##  binds the returned operation to the global variable <A>name</A> if the
##  operation is new.
##  <P/>
##  Declaring the operation <A>oper</A> as tag based w.r.t.
##  <A>requirements</A> means that <Ref Func="InstallTagBasedMethod"/>
##  can be used to install the method <A>meth</A> for <A>oper</A>,
##  a function whose arguments satisfy <A>requirements</A>,
##  with the following meaning.
##  <P/>
##  <List>
##  <Item>
##    The method <A>meth</A> is applicable if the first argument
##    of the call to <A>oper</A> is identical (in the sense of
##    <Ref Func="IsIdenticalObj"/>) with the tag <A>tag</A> that has been
##    specified in the <Ref Func="InstallTagBasedMethod"/> call.
##  </Item>
##  <Item>
##    If none of the tag based methods for <A>oper</A> has a <A>tag</A>
##    that is identical with the first argument of the call to <A>oper</A>
##    and if there is a tag based method for <A>oper</A> for which no
##    <A>tag</A> was specified then this method is applicable.
##  </Item>
##  </List>
##  <P/>
##  Thus at most <E>one</E> tag based method for <A>oper</A> is applicable,
##  and if a method without <A>tag</A> has been installed then it serves as
##  the default method.
##  This is in contrast to the situation with constructors
##  (see <Ref Sect="Constructors"/>) where the first argument is a filter
##  that is used as a tag, but several methods can be applicable in a call
##  to a constructor and one cannot define a default method for it.
##  <P/>
##  Typical use cases for tag based operations are operations that shall
##  create objects in particular internal representations; the filters that
##  define these representations are then used as the first argument,
##  and one wants that either the unique method that belongs to this filter
##  or a default method is called.
##  <P/>
##  Currently it is possible to declare an operation as tag based
##  only for <E>one</E> list of requirements.
##  <P/>
##  Installing methods with <Ref Func="InstallMethod"/> for a tag based
##  operation is possible.
##  However, installing such methods with the same requirements as the ones
##  for the tag based methods will have no effect because the handling of
##  tag based methods gets installed with <Ref Func="InstallEarlyMethod"/>
##  and thus has higher priority.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "_METHODS_TAG_BASED", OBJ_MAP() );
BIND_GLOBAL( "_METHODS_TAG_BASED_DEFAULTS", OBJ_MAP() );

BIND_GLOBAL( "NewTagBasedOperation",
    function( name, requirements )
    local oper, methods;

    # get the operation
    if ISBOUND_GLOBAL( name ) then
      oper:= VALUE_GLOBAL( name );
      DeclareOperation( name, requirements );
    else
      oper:= NewOperation( name, requirements );
    fi;

    # initialize the tag handling for 'oper'
    if FIND_OBJ_MAP( _METHODS_TAG_BASED, oper, fail ) <> fail then
      Error( "operation <oper> has already been declared as tag based" );
    fi;
    methods:= OBJ_MAP();
    ADD_OBJ_MAP( _METHODS_TAG_BASED, oper, methods );
    ADD_OBJ_MAP( _METHODS_TAG_BASED_DEFAULTS, oper, requirements );

    # install the method for 'oper' that uses the tag handling
    if LENGTH( requirements ) = 1 then
      InstallEarlyMethod( oper,
        function( req1 )
        local method;

        if not requirements[1]( req1 ) then
          TryNextMethod();
        fi;

        method:= FIND_OBJ_MAP( methods, req1, fail );
        if method = fail then
          # Take the default method if there is one.
          method:= FIND_OBJ_MAP( methods, IS_OBJECT, fail );
        fi;
        if method = fail then
          Error( "no default installed for tag based operation <oper>" );
        fi;

        return method( req1 );
        end );
    elif LENGTH( requirements ) = 2 then
      InstallEarlyMethod( oper,
        function( req1, req2 )
        local method;

        if not ( requirements[1]( req1 ) and
                 requirements[2]( req2 ) ) then
          TryNextMethod();
        fi;

        method:= FIND_OBJ_MAP( methods, req1, fail );
        if method = fail then
          # Take the default method if there is one.
          method:= FIND_OBJ_MAP( methods, IS_OBJECT, fail );
        fi;
        if method = fail then
          Error( "no default installed for tag based operation <oper>" );
        fi;

        return method( req1, req2 );
        end );
    elif LENGTH( requirements ) = 3 then
      InstallEarlyMethod( oper,
        function( req1, req2, req3 )
        local method;

        if not ( requirements[1]( req1 ) and
                 requirements[2]( req2 ) and
                 requirements[3]( req3 ) ) then
          TryNextMethod();
        fi;

        method:= FIND_OBJ_MAP( methods, req1, fail );
        if method = fail then
          # Take the default method if there is one.
          method:= FIND_OBJ_MAP( methods, IS_OBJECT, fail );
        fi;
        if method = fail then
          Error( "no default installed for tag based operation <oper>" );
        fi;

        return method( req1, req2, req3 );
        end );
    elif LENGTH( requirements ) = 4 then
      InstallEarlyMethod( oper,
        function( req1, req2, req3, req4 )
        local method;

        if not ( requirements[1]( req1 ) and
                 requirements[2]( req2 ) and
                 requirements[3]( req3 ) and
                 requirements[4]( req4 ) ) then
          TryNextMethod();
        fi;

        method:= FIND_OBJ_MAP( methods, req1, fail );
        if method = fail then
          # Take the default method if there is one.
          method:= FIND_OBJ_MAP( methods, IS_OBJECT, fail );
        fi;
        if method = fail then
          Error( "no default installed for tag based operation <oper>" );
        fi;

        return method( req1, req2, req3, req4 );
        end );
    else
      Error( "tag based operations for ", LENGTH( requirements ),
             " arguments are currently not supported" );
    fi;

    return oper;
end );

BIND_GLOBAL( "DeclareTagBasedOperation",
    function( name, requirements )
    local oper;

    oper:= NewTagBasedOperation( name, requirements );
    if not ISBOUND_GLOBAL( name ) then
      BIND_GLOBAL( name, oper );
    fi;
end );

BIND_GLOBAL( "InstallTagBasedMethod", function( oper, meth... )
    local dict, defaultdata, tag, n;

    dict:= FIND_OBJ_MAP( _METHODS_TAG_BASED, oper, fail );
    if dict = fail then
      Error( "<oper> is not declared as tag based operation" );
    fi;
    defaultdata:= FIND_OBJ_MAP( _METHODS_TAG_BASED_DEFAULTS, oper, fail );
    if defaultdata = fail then
      Error( "this should not happen" );
    fi;

    if LENGTH( meth ) = 1 then
      tag:= IS_OBJECT;
      meth:= meth[1];
    elif LENGTH( meth ) = 2 then
      tag:= meth[1];
      meth:= meth[2];
    else
      Error( "usage: InstallTagBasedMethod( oper[, tag], meth )" );
    fi;

    if FIND_OBJ_MAP( dict, tag, fail ) <> fail then
      Error( "<tag> has already been set in <dict>" );
    elif not IS_FUNCTION( meth ) then
      Error( "<meth> must be a function" );
    fi;
    n:= NARG_FUNC( meth );
    if n > 0 and n <> LENGTH( defaultdata ) then
      Error( "<meth> must take ", LENGTH( defaultdata ), " arguments" );
    fi;

    ADD_OBJ_MAP( dict, tag, meth );
end );
