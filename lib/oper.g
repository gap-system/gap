#############################################################################
##
#W  oper.g                      GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file defines operations and such. Some functions have moved
##  to oper1.g so as to be compiled in the default kernel
##
Revision.oper_g :=
    "@(#)$Id$";


INSTALL_METHOD := false;

#############################################################################
##
#V  CATS_AND_REPS
##
##  a list of filter numbers of categories and representations
##
BIND_GLOBAL( "CATS_AND_REPS", [] );


#############################################################################
##
#V  CONSTRUCTORS
##
BIND_GLOBAL( "CONSTRUCTORS", [] );


#############################################################################
##
#V  IMMEDIATES
##
##  is a list  that  contains at position   <i> the description of all  those
##  immediate methods for that `FILTERS[<i>]' belongs to the requirements.
##
##  So   each entry of  `IMMEDIATES'  is a  zipped list,  where 6 consecutive
##  positions  are ..., and the  position of  the  method itself  in the list
##  `IMMEDIATE_METHODS'.
##
##  Note:
##  1. If a method requires two filters $F_1$ and $F_2$ such that $F_1$
##     implies $F_2$, it will *not* be installed for $F_2$.
##  2. If not all requirements are categories/representations then
##     the category/representation part of the requirements will be ignored;
#T and if only cats are required? Does this make sense?
#T and what about representations that may change?
##     in other words, the only information that may cause to run immediate
##     methods is acquired information.
##  
##
BIND_GLOBAL( "IMMEDIATES", [] );


#############################################################################
##
#V  IMMEDIATE_METHODS
##
##  is a list of functions that are installed as immediate methods.
##
BIND_GLOBAL( "IMMEDIATE_METHODS", [] );


#############################################################################
##
#V  NUMBERS_PROPERTY_GETTERS
##
BIND_GLOBAL( "NUMBERS_PROPERTY_GETTERS", [] );


#############################################################################
##
#V  OPERATIONS
##
##  is a list that stores all {\GAP} operations at the odd positions,
##  and the corresponding list of requirements at the even positions.
##  More precisely, if the operation `OPERATIONS[<n>]' has been declared
##  by several calls of `DeclareOperation',
##  with second arguments <req1>, <req2>, \ldots,
##  each being a list of filters, then `OPERATIONS[ <n>+1 ]' is the list
##  $`[' <flags1>, <flags2>, \ldots, `]'$,
##  where <flagsi> is the list of flags of the filters in <reqi>.
##
BIND_GLOBAL( "OPERATIONS", [] );


#############################################################################
##
#V  WRAPPER_OPERATIONS
##
##  is a list that stores all those {\GAP} operations for which the default
##  method is to call a related operation if necessary,
##  and to store and look up the result using an attribute.
##  An example is `SylowSubgroup', which calls `SylowSubgroupOp' if the
##  required Sylow subgroup is not yet stored in `ComputedSylowSubgroups'.
##
BIND_GLOBAL( "WRAPPER_OPERATIONS", [] );


#############################################################################
##
#F  IsNoImmediateMethodsObject(<obj>)
##
##  If this filter is set immediate methods will be ignored for <obj>. This
##  can be crucial for performance for objects like PCGS, of which many are
##  created, which are collections, but for which all those immediate
##  methods for `IsTrivial' et cetera do not really make sense.
BIND_GLOBAL("IsNoImmediateMethodsObject",
  NewFilter("IsNoImmediateMethodsObject"));

#############################################################################
##
#V  IGNORE_IMMEDIATE_METHODS
##
##  is usually `false'.  Only inside a call of `RunImmediateMethods' it is
##  set to `true', which causes that `RunImmediateMethods' does not suffer
##  from recursion.
##
IGNORE_IMMEDIATE_METHODS := false;


#############################################################################
##
#F  INSTALL_IMMEDIATE_METHOD( <oper>, <name>, <filter>, <rank>, <method> )
##
BIND_GLOBAL( "INSTALL_IMMEDIATE_METHOD",
    function( oper, name, filter, rank, method )

    local   flags,
            relev,
            i,
            rflags,
            wif,
            ignore,
            j,
            k,
            replace;

    # Check whether <oper> really is an operation.
    if not IS_OPERATION(oper)  then
        Error( "<oper> is not an operation" );
    fi;
    
    # Check whether this in fact installs an implication.
    if    FLAGS_FILTER(oper) <> false
      and (method = true or method = RETURN_TRUE)
    then
        Error( "use `InstallTrueMethod' for <oper>" );
    fi;

    # Find the requirements.
    flags := TRUES_FLAGS( FLAGS_FILTER( filter ) );
    if LEN_LIST( flags ) = 0 then
        Error( "no immediate methods without requirements!" );
    elif FLAG1_FILTER( IS_MUTABLE_OBJ ) in flags  then
        Error( "no immediate methods for mutable objects!" );
    fi;
    relev := [];
    for i  in flags  do
        if not i in CATS_AND_REPS  then
            ADD_LIST( relev, i );
        fi;
    od;

    # All requirements are categories/representations.
    # Install the method for one of them.
    if LEN_LIST( relev ) = 0  then
        relev:= [ flags[1] ];
    fi;
    flags:= relev;

    # Remove requirements that are implied by the remaining ones.
    # (Note that it is possible to have implications from a filter
    # to another one with a bigger number.)
    relev  := [];
    rflags := [];
    for i  in flags  do

      # Get the implications of this filter.
      wif:= WITH_IMPS_FLAGS( FLAGS_FILTER( FILTERS[i] ) );

      # If the filter is implied by one in `relev', ignore it.
      # Otherwise add it to `relev', and remove all those that
      # are implied by the new filter.
      ignore:= false;
      for j  in [ 1 .. LEN_LIST( relev ) ]  do
          if IsBound( rflags[j] ) then
              if IS_SUBSET_FLAGS( rflags[j], wif ) then

                  # `FILTERS[i]' is implied by one in `relev'.
                  ignore:= true;
                  break;
              elif IS_SUBSET_FLAGS( wif, rflags[j] ) then

                  # `FILTERS[i]' implies one in `relev'.
                  Unbind( relev[j]  );
                  Unbind( rflags[j] );
              fi;
          fi;
      od;
      if not ignore then
          ADD_LIST( relev, i    );
          ADD_LIST( rflags, wif );
      fi;
    od;

    # We install the method for the requirements in `relev'.
    ADD_LIST( IMMEDIATE_METHODS, method );

    for j  in relev  do

      # adjust `IMM_FLAGS'
      IMM_FLAGS:= SUB_FLAGS( IMM_FLAGS, FLAGS_FILTER( FILTERS[j] ) );
#T here it would be better to subtract a flag list
#T with `true' exactly at position `j'!

      # Find the place to put the new method.
      if not IsBound( IMMEDIATES[j] ) then
          IMMEDIATES[j]:= [];
      fi;
      i := 0;
      while i < LEN_LIST(IMMEDIATES[j]) and rank < IMMEDIATES[j][i+5]  do
          i := i + 7;
      od;
      
      # Now is a good time to see if the method is already there 
      if REREADING then
          replace := false;
          k := i;
          while k < LEN_LIST(IMMEDIATES[j]) and 
            rank = IMMEDIATES[j][k+5] do
              if name = IMMEDIATES[j][k+7] and 
                 oper = IMMEDIATES[j][k+1] and
                 FLAGS_FILTER( filter ) = IMMEDIATES[j][k+4] then
                  replace := true;
                  i := k;
                  break;
              fi;
              k := k+7;
          od;
      fi;
      
      # push the other functions back
      if not REREADING or not replace then
          IMMEDIATES[j]{[i+8..7+LEN_LIST(IMMEDIATES[j])]}
            := IMMEDIATES[j]{[i+1..LEN_LIST(IMMEDIATES[j])]};
      fi;

      # install the new method
      IMMEDIATES[j][i+1] := oper;
      IMMEDIATES[j][i+2] := SETTER_FILTER( oper );
      IMMEDIATES[j][i+3] := FLAGS_FILTER( TESTER_FILTER( oper ) );
      IMMEDIATES[j][i+4] := FLAGS_FILTER( filter );
      IMMEDIATES[j][i+5] := rank;
      IMMEDIATES[j][i+6] := LEN_LIST( IMMEDIATE_METHODS );
      IMMEDIATES[j][i+7] := IMMUTABLE_COPY_OBJ(name);

    od;

end );


#############################################################################
##
#F  InstallImmediateMethod( <opr>[, <name>], <filter>, <rank>, <method> )
##
##  installs  <method>  as  immediate  method for <opr>,   which  must  be an
##  operation of one argument, with requirement <filter> and rank <rank>.
##
##  Since the whole system shall work also after completely disabling the
##  immediate methods stuff, we also install <method> as an ordinary method
##  for <opr>, with requirement <filter>.
##
BIND_GLOBAL( "InstallImmediateMethod", function( arg )
    local name;

    if     LEN_LIST( arg ) = 4
       and IS_OPERATION( arg[1] )
       and IsFilter( arg[2] )
       and IS_RAT( arg[3] )
       and IS_FUNCTION( arg[4] ) then
        name := NAME_FUNC(arg[1]);
        INSTALL_IMMEDIATE_METHOD( arg[1], name, arg[2], arg[3], arg[4] );
        INSTALL_METHOD( [ arg[1], [ arg[2] ], arg[4] ], false );
    elif   LEN_LIST( arg ) = 5
       and IS_OPERATION( arg[1] )
       and IS_STRING( arg[2] )
       and IsFilter( arg[3] )
       and IS_RAT( arg[4] )
       and IS_FUNCTION( arg[5] ) then
        INSTALL_IMMEDIATE_METHOD( arg[1], arg[2], arg[3], arg[4], arg[5] );
        INSTALL_METHOD( [ arg[1], [ arg[3] ], arg[5] ], false );
    else
      Error("usage: InstallImmediateMethod(<opr>,<filter>,<rank>,<method>)");
    fi;
end );


#############################################################################
##
#F  TraceImmediateMethods( <flag> )
##
##  If <flag> is true, tracing for all immediate methods is turned on.
##  If <flag> is false it is turned off.
##  (There is no facility to trace *specific* immediate methods.)
##
TRACE_IMMEDIATE_METHODS := false;

BIND_GLOBAL( "TraceImmediateMethods", function( flag )
    if flag  then
        TRACE_IMMEDIATE_METHODS := true;
    else
        TRACE_IMMEDIATE_METHODS := false;
    fi;
end );




#############################################################################
##
#F  NewOperation( <name>, <filters> )
##
BIND_GLOBAL( "NewOperation", function ( name, filters )
    local   oper,  filt,  filter;

    oper := NEW_OPERATION( name );
    filt := [];
    for filter  in filters  do
        if not IS_OPERATION( filter ) then
          Error( "<filter> must be an operation" );
        fi;
        ADD_LIST( filt, FLAGS_FILTER( filter ) );
    od;
    ADD_LIST( OPERATIONS, oper );
    ADD_LIST( OPERATIONS, [ filt ] );
    return oper;
end );


#############################################################################
##
#F  NewConstructor( <name>, <filters> )
##
BIND_GLOBAL( "NewConstructor", function ( name, filters )
    local   oper,  filt,  filter;

    oper := NEW_CONSTRUCTOR( name );
    filt := [];
    for filter  in filters  do
        if not IS_OPERATION( filter ) then
          Error( "<filter> must be an operation" );
        fi;
        ADD_LIST( filt, FLAGS_FILTER( filter ) );
    od;
    ADD_LIST( CONSTRUCTORS, oper );
    ADD_LIST( OPERATIONS,   oper );
    ADD_LIST( OPERATIONS,   [ filt ] );
    return oper;
end );


#############################################################################
##
#F  DeclareOperation( <name>, <filters> )
##
BIND_GLOBAL( "DeclareOperation", function ( name, filters )

    local gvar, pos, filt, filter;

    if ISB_GVAR( name ) then

      gvar:= VALUE_GLOBAL( name );

      # Check that the variable is in fact an operation.
      if not IS_OPERATION( gvar ) then
        Error( "variable `", name, "' is not bound to an operation" );
      fi;

      # The operation has already been declared.
      # If it was created as attribute or property,
      # and if the new declaration is unary
      # then ask for re-declaration as attribute or property.
      # (Note that the values computed for objects matching the new
      # requirements will be stored.)
      if LEN_LIST( filters ) = 1 and FLAG2_FILTER( gvar ) <> 0 then

        # `gvar' is an attribute (tester) or property (tester).
        pos:= POS_LIST_DEFAULT( FILTERS, gvar, 0 );
        if pos = 0 then

          # `gvar' is an attribute.
          Error( "operation `", name,
                 "' was created as an attribute, use`DeclareAttribute'" );

        elif    INFO_FILTERS[ pos ] in FNUM_TPRS
             or INFO_FILTERS[ pos ] in FNUM_ATTS then

          # `gvar' is an attribute tester or property tester.
          Error( "operation `", name,
                 "' is an attribute tester or property tester" );

        else

          # `gvar' is a property.
          Error( "operation `", name,
                 "' was created as a property, use`DeclareProperty'" );

        fi;

      fi;

      # Add the new requirements if they differ from known ones.
      filt := [];
      for filter  in filters  do
        if not IS_OPERATION( filter ) then
          Error( "<filter> must be an operation" );
        fi;
        ADD_LIST( filt, FLAGS_FILTER( filter ) );
      od;

      pos:= POS_LIST_DEFAULT( OPERATIONS, gvar, 0 );
      if filt in OPERATIONS[ pos+1 ] then
        if not REREADING then
          Print( "#W  equal requirements in multiple declarations ",
                 "for operation `", name, "'\n" );
        fi;
      else
        ADD_LIST( OPERATIONS[ pos+1 ], filt );
      fi;

    else

      # The operation is new.
      BIND_GLOBAL( name, NewOperation( name, filters ) );

    fi;
end );


#############################################################################
##
#F  DeclareOperationKernel( <name>, <filters>, <kernel-oper> )
##
##  This function must not be used to re-declare an operation
##  that has already been declared.
##
BIND_GLOBAL( "DeclareOperationKernel", function ( name, filters, oper )
    local   filt,  filter;

    # This will yield an error if `name' is already bound.
    BIND_GLOBAL( name, oper );

    filt := [];
    for filter  in filters  do
        if not IS_OPERATION( filter ) then
          Error( "<filter> must be an operation" );
        fi;
        ADD_LIST( filt, FLAGS_FILTER( filter ) );
    od;

    ADD_LIST( OPERATIONS, oper );
    ADD_LIST( OPERATIONS, [ filt ] );
end );


#############################################################################
##
#F  DeclareConstructor( <name>, <filters> )
##
BIND_GLOBAL( "DeclareConstructor", function ( name, filters )

    local gvar, pos, filt, filter;

    if ISB_GVAR( name ) then

      gvar:= VALUE_GLOBAL( name );

      # Check that the variable is in fact an operation.
      if not IS_OPERATION( gvar ) then
        Error( "variable `", name, "' is not bound to an operation" );
      fi;

      # The constructor has already been declared.
      # If it was not created as a constructor
      # then ask for re-declaration as an ordinary operation.
      if not gvar in CONSTRUCTORS then
        Error( "operation `", name, "' was not created as a constructor" );
      fi;

      # Add the new requirements.
      filt := [];
      for filter  in filters  do
        if not IS_OPERATION( filter ) then
          Error( "<filter> must be an operation" );
        fi;
        ADD_LIST( filt, FLAGS_FILTER( filter ) );
      od;

      pos:= POS_LIST_DEFAULT( OPERATIONS, gvar, 0 );
      ADD_LIST( OPERATIONS[ pos+1 ], filt );

    else

      # The operation is new.
      BIND_GLOBAL( name, NewConstructor( name, filters ) );

    fi;
end );


#############################################################################
##
#F  DeclareConstructorKernel( <name>, <filter>, <kernel-oper> )
##
##  This function must not be used to re-declare a constructor
##  that has already been declared.
##
BIND_GLOBAL( "DeclareConstructorKernel", function ( name, filters, oper )
    local   filt,  filter;

    # This will yield an error if `name' is already bound.
    BIND_GLOBAL( name, oper );

    filt := [];
    for filter  in filters  do
        if not IS_OPERATION( filter ) then
          Error( "<filter> must be an operation" );
        fi;
        ADD_LIST( filt, FLAGS_FILTER( filter ) );
    od;

    ADD_LIST( CONSTRUCTORS, oper );
    ADD_LIST( OPERATIONS,   oper );
    ADD_LIST( OPERATIONS,   [ filt ] );
end );


#############################################################################
##
#F  InstallAttributeFunction( <func> )  . . . run function for each attribute
##
##  `InstallAttributeFunction' installs <func>, so that
##  `<func>( <name>, <filter>, <getter>, <setter>, <tester>, <mutflag> )'
##  is called for each attribute.
##
BIND_GLOBAL( "ATTRIBUTES", [] );

BIND_GLOBAL( "ATTR_FUNCS", [] );

BIND_GLOBAL( "InstallAttributeFunction", function ( func )
    local   attr;
    for attr in ATTRIBUTES do
        func( attr[1], attr[2], attr[3], attr[4], attr[5], attr[6] );
    od;
    ADD_LIST( ATTR_FUNCS, func );
end );

BIND_GLOBAL( "RUN_ATTR_FUNCS",
    function ( filter, getter, setter, tester, mutflag )
    local    name, func;
    name:= NAME_FUNC( getter );
    for func in ATTR_FUNCS do
        func( name, filter, getter, setter, tester, mutflag );
    od;
    ADD_LIST( ATTRIBUTES, [ name, filter, getter, setter, tester, mutflag ] );
end );


#############################################################################
##
#F  DeclareAttributeKernel( <name>, <filter>, <getter> )  . . . new attribute
##
##  This function must not be used to re-declare an attribute
##  that has already been declared.
##
BIND_GLOBAL( "DeclareAttributeKernel", function ( name, filter, getter )
    local setter, tester, nname;

    # This will yield an error if `name' is already bound.
    BIND_GLOBAL( name, getter );

    # construct setter and tester
    setter := SETTER_FILTER( getter );
    tester := TESTER_FILTER( getter );

    # add getter, setter and tester to the list of operations
    ADD_LIST( OPERATIONS, getter );
    ADD_LIST( OPERATIONS, [ [ FLAGS_FILTER(filter) ] ] );
    ADD_LIST( OPERATIONS, setter );
    ADD_LIST( OPERATIONS,
              [ [ FLAGS_FILTER( filter ), FLAGS_FILTER( IS_OBJECT ) ] ] );
    ADD_LIST( OPERATIONS, tester );
    ADD_LIST( OPERATIONS, [ [ FLAGS_FILTER(filter) ] ] );

    # store the information about the filter
    FILTERS[ FLAG2_FILTER( tester ) ] := tester;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( tester ) );
    INFO_FILTERS[ FLAG2_FILTER( tester ) ] := 5;

    # clear the cache because <filter> is something old
    InstallHiddenTrueMethod( filter, tester );
    CLEAR_HIDDEN_IMP_CACHE( tester );

    # run the attribute functions
    RUN_ATTR_FUNCS( filter, getter, setter, tester, false );

    # store the ranks
    RANK_FILTERS[ FLAG2_FILTER( tester ) ] := 1;

    # and make the remaining assignments
    nname:= "Set"; APPEND_LIST_INTR( nname, name );
    BIND_GLOBAL( nname, setter );
    nname:= "Has"; APPEND_LIST_INTR( nname, name );
    BIND_GLOBAL( nname, tester );

end );


#############################################################################
##
#F  NewAttribute( <name>, <filter> [,"mutable"] [,<rank>] ) . . new attribute
##
##  is a new attribute getter with name  <name> that is applicable to objects
##  with the property <filter>.  If the optional third argument is given then
##  there are  two possibilities.  Either it is  an integer <rank>,  then the
##  attribute tester has this rank.  Or it  is the string "mutable", then the
##  values of the attribute shall be mutable; more precisely, when a value of
##  such a mutable attribute is set then this value itself is stored, not an
##  immutable copy of it.
##  (So it is the user's responsibility to set an object that is in fact
##  mutable.)
#T in the current implementation, one can overwrite values of mutable
#T attributes; is this really intended?
#T if yes then it should be documented!
##
##  If no third argument is given then the rank of the tester is 1.
##
BIND_GLOBAL( "NewAttribute", function ( arg )
    local   name, filter, flags, mutflag, getter, setter, tester;

    # construct getter, setter and tester
    name   := arg[1];
    filter := arg[2];

    if not IS_OPERATION( filter ) then
      Error( "<filter> must be an operation" );
    fi;
    flags:= FLAGS_FILTER( filter );

    # the mutability flags is the third one (which can also be the rank)
    mutflag := LEN_LIST(arg) = 3 and arg[3] = "mutable";

    # construct a new attribute
    if mutflag then
        getter := NEW_MUTABLE_ATTRIBUTE( name );
    else
        getter := NEW_ATTRIBUTE( name );
    fi;

    # store the information about the filter
    INFO_FILTERS[ FLAG2_FILTER(getter) ] := 6;

    # add getter, setter and tester to the list of operations
    setter := SETTER_FILTER( getter );
    tester := TESTER_FILTER( getter );

    ADD_LIST( OPERATIONS, getter );
    ADD_LIST( OPERATIONS, [ [ flags ] ] );
    ADD_LIST( OPERATIONS, setter );
    ADD_LIST( OPERATIONS, [ [ flags, FLAGS_FILTER( IS_OBJECT ) ] ] );
    ADD_LIST( OPERATIONS, tester );
    ADD_LIST( OPERATIONS, [ [ flags ] ] );

    # install the default functions
    FILTERS[ FLAG2_FILTER( tester ) ] := tester;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( tester ) );

    # the <tester> is newly made, therefore  the cache cannot contain a  flag
    # list involving <tester>
    InstallHiddenTrueMethod( filter, tester );
    # CLEAR_HIDDEN_IMP_CACHE();

    # run the attribute functions
    RUN_ATTR_FUNCS( filter, getter, setter, tester, mutflag );

    # store the rank
    if LEN_LIST( arg ) = 3 and IS_INT( arg[3] ) then
        RANK_FILTERS[ FLAG2_FILTER( tester ) ] := arg[3];
    else
        RANK_FILTERS[ FLAG2_FILTER( tester ) ] := 1;
    fi;

    # and return the getter
    return getter;
end );


#############################################################################
##
#F  DeclareAttribute( <name>, <filter> [,"mutable"] [,<rank>] ) new attribute
##
BIND_GLOBAL( "DeclareAttribute", function ( arg )

    local attr, name, nname, gvar, pos, filter;

    name:= arg[1];

    if ISB_GVAR( name ) then

      gvar:= VALUE_GLOBAL( name );

      # Check that the variable is in fact an operation.
      if not IS_OPERATION( gvar ) then
        Error( "variable `", name, "' is not bound to an operation" );
      fi;

      # The attribute has already been declared.
      # If it was not created as an attribute
      # then ask for re-declaration as an ordinary operation.
      # (Note that the values computed for objects matching the new
      # requirements cannot be stored.)
      if FLAG2_FILTER( gvar ) = 0 or gvar in FILTERS then

        # `gvar' is not an attribute (tester) and not a property (tester),
        # or `gvar' is a filter;
        # in any case, `gvar' is not an attribute.
        Error( "operation `", name, "' was not created as an attribute,",
               " use`DeclareOperation'" );

      fi;

      # Add the new requirements.
      filter:= arg[2];
      if not IS_OPERATION( filter ) then
        Error( "<filter> must be an operation" );
      fi;

      pos:= POS_LIST_DEFAULT( OPERATIONS, gvar, 0 );
      ADD_LIST( OPERATIONS[ pos+1 ], [ FLAGS_FILTER( filter ) ] );

      # also set the extended range for the setter
      pos:= POS_LIST_DEFAULT( OPERATIONS, Setter(gvar), pos );
      ADD_LIST( OPERATIONS[ pos+1 ],
                [ FLAGS_FILTER( filter),OPERATIONS[pos+1][1][2] ] );

    else

      # The attribute is new.
      attr:= CALL_FUNC_LIST( NewAttribute, arg );
      BIND_GLOBAL( name, attr );
      nname:= "Set"; APPEND_LIST_INTR( nname, name );
      BIND_GLOBAL( nname, SETTER_FILTER( attr ) );
      nname:= "Has"; APPEND_LIST_INTR( nname, name );
      BIND_GLOBAL( nname, TESTER_FILTER( attr ) );

    fi;
end );


#############################################################################
##
#V  LENGTH_SETTER_METHODS_2
##
##  is the current length of `METHODS_OPERATION( <attr>, 2 )'
##  for an attribute <attr> for which no individual setter methods
##  are installed.
##  (This is used for `ObjectifyWithAttributes'.)
##
LENGTH_SETTER_METHODS_2 := 0;




#############################################################################
##
#F  DeclarePropertyKernel( <name>, <filter>, <getter> ) . . . .  new property
##
##  This function must not be used to re-declare a property
##  that has already been declared.
##
BIND_GLOBAL( "DeclarePropertyKernel", function ( name, filter, getter )
    local setter, tester, nname;

    # This will yield an error if `name' is already bound.
    BIND_GLOBAL( name, getter );

    # construct setter and tester
    setter := SETTER_FILTER( getter );
    tester := TESTER_FILTER( getter );

    # store the property getters
    ADD_LIST( NUMBERS_PROPERTY_GETTERS, FLAG1_FILTER( getter ) );

    # add getter, setter and tester to the list of operations
    ADD_LIST( OPERATIONS, getter );
    ADD_LIST( OPERATIONS, [ [ FLAGS_FILTER(filter) ] ] );
    ADD_LIST( OPERATIONS, setter );
    ADD_LIST( OPERATIONS,
              [ [ FLAGS_FILTER( filter ), FLAGS_FILTER( IS_BOOL ) ] ] );
    ADD_LIST( OPERATIONS, tester );
    ADD_LIST( OPERATIONS, [ [ FLAGS_FILTER(filter) ] ] );

    # install the default functions
    FILTERS[ FLAG1_FILTER( getter ) ]:= getter;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( getter ) );
    FILTERS[ FLAG2_FILTER( getter ) ]:= tester;
    INFO_FILTERS[ FLAG1_FILTER( getter ) ]:= 7;
    INFO_FILTERS[ FLAG2_FILTER( getter ) ]:= 8;

    # clear the cache because <filter> is something old
    InstallHiddenTrueMethod( tester, getter );
    CLEAR_HIDDEN_IMP_CACHE( getter );
    InstallHiddenTrueMethod( filter, tester );
    CLEAR_HIDDEN_IMP_CACHE( tester );

    # run the attribute functions
    RUN_ATTR_FUNCS( filter, getter, setter, tester, false );

    # store the ranks
    RANK_FILTERS[ FLAG1_FILTER( getter ) ] := 1;
    RANK_FILTERS[ FLAG2_FILTER( getter ) ] := 1;

    # and make the remaining assignments
    nname:= "Set"; APPEND_LIST_INTR( nname, name );
    BIND_GLOBAL( nname, setter );
    nname:= "Has"; APPEND_LIST_INTR( nname, name );
    BIND_GLOBAL( nname, tester );
end );


#############################################################################
##
#F  NewProperty( <name>, <filter> [,<rank>] ) . . . . . . . . .  new property
##
##  is a new property  getter with name <name>  that is applicable to objects
##  with property <filter>.  If  the optional argument  <rank> is  given then
##  the property getter has this rank, otherwise its rank is 1.
##
BIND_GLOBAL( "NewProperty", function ( arg )
    local   name, filter, flags, getter, setter, tester;

    name   := arg[1];
    filter := arg[2];

    if not IS_OPERATION( filter ) then
      Error( "<filter> must be an operation" );
    fi;
    flags:= FLAGS_FILTER( filter );

    # construct getter, setter and tester
    getter := NEW_PROPERTY(  name );
    setter := SETTER_FILTER( getter );
    tester := TESTER_FILTER( getter );

    # add getter, setter and tester to the list of operations
    ADD_LIST( OPERATIONS, getter );
    ADD_LIST( OPERATIONS, [ [ flags ] ] );
    ADD_LIST( OPERATIONS, setter );
    ADD_LIST( OPERATIONS, [ [ flags, FLAGS_FILTER( IS_BOOL ) ] ] );
    ADD_LIST( OPERATIONS, tester );
    ADD_LIST( OPERATIONS, [ [ flags ] ] );

    # store the property getters
    ADD_LIST( NUMBERS_PROPERTY_GETTERS, FLAG1_FILTER( getter ) );

    # install the default functions
    FILTERS[ FLAG1_FILTER( getter ) ] := getter;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( getter ) );
    FILTERS[ FLAG2_FILTER( getter ) ] := tester;
    INFO_FILTERS[ FLAG1_FILTER( getter ) ] := 9;
    INFO_FILTERS[ FLAG2_FILTER( getter ) ] := 10;

    # the <tester> and  <getter> are newly  made, therefore the cache cannot
    # contain a flag list involving <tester> or <getter>
    InstallHiddenTrueMethod( tester, getter );
    InstallHiddenTrueMethod( filter, tester );
    # CLEAR_HIDDEN_IMP_CACHE();

    # run the attribute functions
    RUN_ATTR_FUNCS( filter, getter, setter, tester, false );

    # store the rank
    if LEN_LIST( arg ) = 3 and IS_INT( arg[3] ) then
        RANK_FILTERS[ FLAG1_FILTER( getter ) ]:= arg[3];
    else
        RANK_FILTERS[ FLAG1_FILTER( getter ) ]:= 1;
    fi;
    RANK_FILTERS[ FLAG2_FILTER( tester ) ]:= 1;

    # and return the getter
    return getter;
end );


#############################################################################
##
#F  DeclareProperty( <name>, <filter> [,<rank>] ) . . . . . . .  new property
##
BIND_GLOBAL( "DeclareProperty", function ( arg )

    local prop, name, nname, gvar, pos, filter;

    name:= arg[1];

    if ISB_GVAR( name ) then

      gvar:= VALUE_GLOBAL( name );

      # Check that the variable is in fact an operation.
      if not IS_OPERATION( gvar ) then
        Error( "variable `", name, "' is not bound to an operation" );
      fi;

      # The property has already been declared.
      # If it was not created as a property
      # then ask for re-declaration as an ordinary operation.
      # (Note that the values computed for objects matching the new
      # requirements cannot be stored.)
      if FLAG1_FILTER( gvar ) = 0 or FLAG2_FILTER( gvar ) = 0 then

        # `gvar' is not a property (tester).
        Error( "operation `", name, "' was not created as a property,",
               " use`DeclareOperation'" );

      fi;

      # Add the new requirements.
      filter:= arg[2];
      if not IS_OPERATION( filter ) then
        Error( "<filter> must be an operation" );
      fi;

      pos:= POS_LIST_DEFAULT( OPERATIONS, gvar, 0 );
      ADD_LIST( OPERATIONS[ pos+1 ], [ FLAGS_FILTER( filter ) ] );

    else

      # The property is new.
      prop:= CALL_FUNC_LIST( NewProperty, arg );
      BIND_GLOBAL( name, prop );
      nname:= "Set"; APPEND_LIST_INTR( nname, name );
      BIND_GLOBAL( nname, SETTER_FILTER( prop ) );
      nname:= "Has"; APPEND_LIST_INTR( nname, name );
      BIND_GLOBAL( nname, TESTER_FILTER( prop ) );

    fi;
end );



#############################################################################
##

#F  InstallAtExit( <func> ) . . . . . . . . . . function to call when exiting
##
BIND_GLOBAL( "InstallAtExit", function( func )

    if not IS_FUNCTION(func)  then
        Error( "<func> must be a function" );
    fi;
    if CHECK_INSTALL_METHOD  then
        if not NARG_FUNC(func) in [ -1, 0 ]  then
            Error( "<func> must accept zero arguments" );
        fi;
    fi;
    ADD_LIST( AT_EXIT_FUNCS, func );

end );


#############################################################################
##
#O  ViewObj( <obj> )  . . . . . . . . . . . . . . . . . . . .  view an object
##
##  `ViewObj' prints information about the object <obj>.
##  This information is thought to be short and human readable,
##  in particular *not* necessarily detailed enough for defining <obj>,
##  an in general *not* {\GAP} readable.
##
##  More detailed information can be obtained by `PrintObj',
##  and {\GAP} readable data can be produced with `SaveObj'.
##
##DeclareOperation( "ViewObj", [ IS_OBJECT ] );

##ViewObj := VIEW_OBJ;

DeclareOperationKernel( "ViewObj", [ IS_OBJECT ], VIEW_OBJ );




#############################################################################
##
#F  View( <obj1>, <obj2>... ) . . . . . . . . . . . . . . . . .  view objects
##  
##  `View' shows the objects <obj1>, <obj2>... etc. *in a short form*
##  on the standard output.
##  `View' is called in the read--eval--print loop,
##  thus the output looks exactly like the representation of the
##  objects shown by the main loop.
##  Note that no space or newline is printed between the objects.
##
BIND_GLOBAL( "View", function( arg )
    local   obj;

    for obj  in arg  do
        ViewObj(obj);
    od;
end );


#############################################################################
##
#F  ViewLength( <len> )
##
##  `View' will usually display objects in short form if they would need
##  more than <len> lines.
##  The default is 3.
##
BIND_GLOBAL( "ViewLength", function(arg)
  if LEN_LIST( arg ) = 0 then
    return GAPInfo.ViewLength;
  else
    GAPInfo.ViewLength:= arg[1];
  fi;
end );


#############################################################################
##
#O  TeXObj( <obj> ) . . . . . . . . . . . . . . . . . . . . . . TeX an object
##
DeclareOperation( "TeXObj", [ IS_OBJECT ] );


#############################################################################
##
#F  TeX( <obj1>, ... )  . . . . . . . . . . . . . . . . . . . . . TeX objects
##
BIND_GLOBAL( "TeX", function( arg )
    local   str,  res,  obj;

    str := "";
    for obj  in arg  do
        res := TeXObj(obj);
        APPEND_LIST_INTR( str, res );
        APPEND_LIST_INTR( str, "%\n" );
    od;
    CONV_STRING(str);
    return str;
end );


#############################################################################
##
#O  LaTeXObj( <obj> ) . . . . . . . . . . . . . . . . . . . . LaTeX an object
##
DeclareOperation( "LaTeXObj", [ IS_OBJECT ] );


#############################################################################
##
#F  LaTeX( <obj1>, ... )  . . . . . . . . . . . . . . . . . . . LaTeX objects
##
BIND_GLOBAL( "LaTeX", function( arg )
    local   str,  res,  obj;

    str := "";
    for obj  in arg  do
        res := LaTeXObj(obj);
        APPEND_LIST_INTR( str, res );
        APPEND_LIST_INTR( str, "%\n" );
    od;
    CONV_STRING(str);
    return str;
end );


#############################################################################
##
#F  TraceMethods( <oprs> )
##
##  After the call of `TraceMethods' with a list <oprs> of operations,
##  whenever a method of one of the operations in <oprs> is called the
##  information string used in the installation of the method is printed.
##
BIND_GLOBAL( "TraceMethods", function( arg )
    local   fun;

    if IS_LIST(arg[1])  then
        arg := arg[1];
    fi;
    for fun  in arg  do
        TRACE_METHODS(fun);
    od;

end );


#############################################################################
##
#F  UntraceMethods( <oprs>)
##
##  turns the tracing off for all operations in <oprs>.
##
BIND_GLOBAL( "UntraceMethods", function( arg )
    local   fun;

    if IS_LIST(arg[1])  then
        arg := arg[1];
    fi;
    for fun  in arg  do
        UNTRACE_METHODS(fun);
    od;

end );


#############################################################################
##
#F  DeclareGlobalFunction( <name>, <info> ) . .  create a new global function
#F  InstallGlobalFunction( <oprname>[, <info>], <func> )
#F  InstallGlobalFunction( <oper>[, <info>], <func> )
##
##  Global functions of the {\GAP} library must be distinguished from other
##  global variables (see `variable.g') because of the completion mechanism.
##
BIND_GLOBAL( "GLOBAL_FUNCTION_NAMES", [] );

BIND_GLOBAL( "DeclareGlobalFunction", function( arg )
    local   name;

    name := arg[1];
    ADD_SET( GLOBAL_FUNCTION_NAMES, IMMUTABLE_COPY_OBJ(name) );
    BIND_GLOBAL( name, NEW_OPERATION_ARGS( name ) );
end );

BIND_GLOBAL( "InstallGlobalFunction", function( arg )
    local   oper,  info,  func;

    if LEN_LIST(arg) = 3  then
        oper := arg[1];
        info := arg[2];
        func := arg[3];
    else
        oper := arg[1];
        func := arg[2];
    fi;
    if IS_STRING( oper ) then
      oper:= VALUE_GLOBAL( oper );
    fi;
    if NAME_FUNC(func) in GLOBAL_FUNCTION_NAMES then
      Error("you cannot install a global function for another global ",
            "function,\nuse `DeclareSynonym' instead!");
    fi;
    INSTALL_METHOD_ARGS( oper, func );
end );


BIND_GLOBAL( "FLUSH_ALL_METHOD_CACHES", function()
    local i,j;
    for i in [1,3..LEN_LIST(OPERATIONS)-1] do
        for j in [1..6] do
            CHANGED_METHODS_OPERATION(OPERATIONS[i],j);
        od;
    od;
end);
        

#############################################################################
##
#E

