#############################################################################
##
#W  oper.g                      GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file defines operations and such.
##
Revision.oper_g :=
    "@(#)$Id$";


#############################################################################
##

#F  STRING_INT( <int> ) . . . . . . . . . . . . . . . .  string of an integer
##
STRING_INT := function ( n )
    local  str,  num,  digits;

    # construct the string without sign
    num:= n;
    if num < 0 then num := - n; fi;
    digits := [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ];
    str := "";
    repeat
        ADD_LIST( str, digits[num mod 10 + 1] );
        num := QUO_INT( num, 10 );
    until num = 0;

    # add the sign and return
    if n < 0  then
        ADD_LIST( str, '-' );
    fi;
    return str{[LEN_LIST(str),LEN_LIST(str)-1 .. 1]};
end;


#############################################################################
##
#F  Ordinal( <n> )  . . . . . . . . . . . . . ordinal of an integer as string
##
Ordinal := function ( n )
    local   str;

    str := STRING_INT(n);
    if   n mod 10 = 1  and n mod 100 <> 11  then
        APPEND_LIST_INTR( str, "st" );
    elif n mod 10 = 2  and n mod 100 <> 12  then
        APPEND_LIST_INTR( str, "nd" );
    elif n mod 10 = 3  and n mod 100 <> 13  then
        APPEND_LIST_INTR( str, "rd" );
    else
        APPEND_LIST_INTR( str, "th" );
    fi;
    return str;
end;


############################################################################
##

#F  CallFuncList( <func>, <args> )
##
CallFuncList := CALL_FUNC_LIST;


#############################################################################
##
#F  Setter( <filter> )
##
Setter := SETTER_FILTER;


#############################################################################
##
#F  Tester( <filter> )
##
Tester := TESTER_FILTER;


#############################################################################
##

#V  CATS_AND_REPS
##
##  a list of filter numbers of categories and representations
##
CATS_AND_REPS := [];


#############################################################################
##
#V  CONSTRUCTORS
##
CONSTRUCTORS := [];


#############################################################################
##
#V  FILTERS
##
##  is a list containing at position <i> the filter with number <i>.
##
FILTERS := [];


#############################################################################
##
#V  IMMEDIATES
##
##  is a list  that  contains at position   <i> the description of all  those
##  immediate methods for that 'FILTERS[<i>]' belongs to the requirements.
##
##  So   each entry of  'IMMEDIATES'  is a  zipped list,  where 6 consecutive
##  positions  are ..., and the  position of  the  method itself  in the list
##  'IMMEDIATE_METHODS'.
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
IMMEDIATES := [];


#############################################################################
##
#V  IMMEDIATE_METHODS
##
##  is a list of functions that are installed as immediate methods.
##
IMMEDIATE_METHODS := [];


#############################################################################
##
#V  NUMBERS_PROPERTY_GETTERS
##
NUMBERS_PROPERTY_GETTERS := [];


#############################################################################
##
#V  OPERATIONS
##
OPERATIONS := [];


#############################################################################
##
#V  SUM_FLAGS
##
SUM_FLAGS := 2000;


#############################################################################
##

#V  IGNORE_IMMEDIATE_METHODS
##
##  is usually 'false'.  Only inside a call of 'RunImmediateMethods' it is
##  set to 'true', which causes that 'RunImmediateMethods' does not suffer
##  from recursion.
##
IGNORE_IMMEDIATE_METHODS := false;


#############################################################################
##

#F  NamesFilter( <flags> )
##
NamesFilter := function( flags )
    local  bn,  i;

    if IS_FUNCTION(flags)  then
        flags := FLAGS_FILTER(flags);
    fi;
    bn := SHALLOW_COPY_OBJ(TRUES_FLAGS(flags));
    for i  in  [ 1 .. LEN_LIST(bn) ]  do
        if not IsBound(FILTERS[ bn[i] ])  then
            bn[i] := STRING_INT( bn[i] );
        else
            bn[i] := NAME_FUNCTION(FILTERS[ bn[i] ]);
        fi;
    od;
    return bn;

end;


#############################################################################
##
#F  InstallHiddenTrueMethod( <filter>, <filters> )
##
HIDDEN_IMPS := [];
WITH_HIDDEN_IMPS_FLAGS_CACHE      := [];
WITH_HIDDEN_IMPS_FLAGS_COUNT      := 0;
WITH_HIDDEN_IMPS_FLAGS_CACHE_MISS := 0;
WITH_HIDDEN_IMPS_FLAGS_CACHE_HIT  := 0;

CLEAR_HIDDEN_IMP_CACHE := function()
    WITH_HIDDEN_IMPS_FLAGS_CACHE      := [];
    WITH_HIDDEN_IMPS_FLAGS_CACHE_HIT  := 0;
    WITH_HIDDEN_IMPS_FLAGS_CACHE_MISS := 0;
end;


InstallHiddenTrueMethod := function ( filter, filters )
    local   imp;

    imp := [];
    imp[1] := FLAGS_FILTER( filter );
    imp[2] := FLAGS_FILTER( filters );
    ADD_LIST( HIDDEN_IMPS, imp );
    CLEAR_HIDDEN_IMP_CACHE();
end;


WITH_HIDDEN_IMPS_FLAGS := function ( flags )
    local   with,  changed,  imp,  hash,  hash2,  i;

    hash := HASH_FLAGS(flags) mod 11001;
    for i  in [ 0 .. 3 ]  do
      hash2 := 2 * ((hash+31*i) mod 11001) + 1;
      if IsBound(WITH_HIDDEN_IMPS_FLAGS_CACHE[hash2])  then
        if IS_IDENTICAL_OBJ(WITH_HIDDEN_IMPS_FLAGS_CACHE[hash2],flags) then
          WITH_HIDDEN_IMPS_FLAGS_CACHE_HIT :=
            WITH_HIDDEN_IMPS_FLAGS_CACHE_HIT + 1;
          return WITH_HIDDEN_IMPS_FLAGS_CACHE[hash2+1];
        fi;
      else
        break;
      fi;
    od;
    if i = 3  then
      WITH_HIDDEN_IMPS_FLAGS_COUNT :=
        ( WITH_HIDDEN_IMPS_FLAGS_COUNT + 1 ) mod 4;
      i := WITH_HIDDEN_IMPS_FLAGS_COUNT;
      hash2 := 2*((hash+31*i) mod 11001) + 1;
    fi;

    WITH_HIDDEN_IMPS_FLAGS_CACHE_MISS := WITH_HIDDEN_IMPS_FLAGS_CACHE_MISS+1;
    with := flags;
    changed := true;
    while changed  do
        changed := false;
        for imp in HIDDEN_IMPS  do
            if        IS_SUBSET_FLAGS( with, imp[2] )
              and not IS_SUBSET_FLAGS( with, imp[1] )
            then
                with := AND_FLAGS( with, imp[1] );
                changed := true;
            fi;
        od;
    od;

    WITH_HIDDEN_IMPS_FLAGS_CACHE[hash2  ] := flags;
    WITH_HIDDEN_IMPS_FLAGS_CACHE[hash2+1] := with;
    return with;
end;


#############################################################################
##
#F  InstallTrueMethod( <to>, <from> )
##
IMPLICATIONS := [];
WITH_IMPS_FLAGS_CACHE      := [];
WITH_IMPS_FLAGS_COUNT      := 0;
WITH_IMPS_FLAGS_CACHE_HIT  := 0;
WITH_IMPS_FLAGS_CACHE_MISS := 0;

CLEAR_IMP_CACHE := function()
    WITH_IMPS_FLAGS_CACHE      := [];
    WITH_IMPS_FLAGS_CACHE_HIT  := 0;
    WITH_IMPS_FLAGS_CACHE_MISS := 0;
end;


InstallTrueMethod := function ( filter, filters )
    local   imp;
    imp := [];
    imp[1] := FLAGS_FILTER( filter );
    imp[2] := FLAGS_FILTER( filters );
    ADD_LIST( IMPLICATIONS, imp );
    InstallHiddenTrueMethod( filter, filters );
end;

InstallImplication := InstallTrueMethod;


WITH_IMPS_FLAGS := function ( flags )
    local   with,  changed,  imp,  hash,  hash2,  i;

    hash := HASH_FLAGS(flags) mod 11001;
    for i  in [ 0 .. 3 ]  do
        hash2 := 2 * ((hash+31*i) mod 11001) + 1;
        if IsBound(WITH_IMPS_FLAGS_CACHE[hash2])  then
            if IS_IDENTICAL_OBJ(WITH_IMPS_FLAGS_CACHE[hash2],flags) then
                WITH_IMPS_FLAGS_CACHE_HIT := WITH_IMPS_FLAGS_CACHE_HIT + 1;
                return WITH_IMPS_FLAGS_CACHE[hash2+1];
            fi;
        else
            break;
        fi;
    od;
    if i = 3  then
        WITH_IMPS_FLAGS_COUNT := ( WITH_IMPS_FLAGS_COUNT + 1 ) mod 4;
        i := WITH_IMPS_FLAGS_COUNT;
        hash2 := 2*((hash+31*i) mod 11001) + 1;
    fi;

    WITH_IMPS_FLAGS_CACHE_MISS := WITH_IMPS_FLAGS_CACHE_MISS + 1;
    with := flags;
    changed := true;
    while changed  do
        changed := false;
        for imp in IMPLICATIONS  do
            if        IS_SUBSET_FLAGS( with, imp[2] )
              and not IS_SUBSET_FLAGS( with, imp[1] )
            then
                with := AND_FLAGS( with, imp[1] );
                changed := true;
            fi;
        od;
    od;

    WITH_IMPS_FLAGS_CACHE[hash2  ] := flags;
    WITH_IMPS_FLAGS_CACHE[hash2+1] := with;
    return with;
end;


#############################################################################
##
#F  INSTALL_IMMEDIATE_METHOD( <oper>, <name>, <filter>, <rank>, <method> )
##
INSTALL_IMMEDIATE_METHOD := function( oper, name, filter, rank, method )

    local   flags,
            relev,
            i,
            rflags,
            wif,
            ignore,
            j;

    # Check whether this in fact installs an implication.
    if    FLAGS_FILTER(oper) <> false
      and (method = true or method = RETURN_TRUE)
    then
        Error( "use 'InstallTrueMethod' for <oper>" );
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

      # If the filter is implied by one in 'relev', ignore it.
      # Otherwise add it to 'relev', and remove all those that
      # are implied by the new filter.
      ignore:= false;
      for j  in [ 1 .. LEN_LIST( relev ) ]  do
          if IsBound( rflags[j] ) then
              if IS_SUBSET_FLAGS( rflags[j], wif ) then

                  # 'FILTERS[i]' is implied by one in 'relev'.
                  ignore:= true;
                  break;
              elif IS_SUBSET_FLAGS( wif, rflags[j] ) then

                  # 'FILTERS[i]' implies one in 'relev'.
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

    # We install the method for the requirements in 'relev'.
    ADD_LIST( IMMEDIATE_METHODS, method );

    for j  in relev  do

      # Find the place to put the new method.
      if not IsBound( IMMEDIATES[j] ) then
          IMMEDIATES[j]:= [];
      fi;
      i := 0;
      while i < LEN_LIST(IMMEDIATES[j]) and rank < IMMEDIATES[j][i+5]  do
          i := i + 7;
      od;

      # push the other functions back
      IMMEDIATES[j]{[i+1..LEN_LIST(IMMEDIATES[j])]+7}
          := IMMEDIATES[j]{[i+1..LEN_LIST(IMMEDIATES[j])]};

      # install the new method
      IMMEDIATES[j][i+1] := oper;
      IMMEDIATES[j][i+2] := SETTER_FILTER( oper );
      IMMEDIATES[j][i+3] := FLAGS_FILTER( TESTER_FILTER( oper ) );
      IMMEDIATES[j][i+4] := FLAGS_FILTER( filter );
      IMMEDIATES[j][i+5] := rank;
      IMMEDIATES[j][i+6] := LEN_LIST( IMMEDIATE_METHODS );
      IMMEDIATES[j][i+7] := IMMUTABLE_COPY_OBJ(name);

    od;

end;


#############################################################################
##
#F  InstallImmediateMethod( <opr>, <filter>, <rank>, <method> )
##
##  installs  <method>  as  immediate  method for <opr>,   which  must  be an
##  operation of one argument, with requirement <filter> and rank <rank>.
##
InstallImmediateMethod := function( arg )
    local   name;

    if LEN_LIST(arg) = 4  then
        name := NAME_FUNCTION(arg[1]);
        INSTALL_IMMEDIATE_METHOD( arg[1], name, arg[2], arg[3], arg[4] );
    elif LEN_LIST(arg) = 5  then
        INSTALL_IMMEDIATE_METHOD( arg[1], arg[2], arg[3], arg[4], arg[5] );
    fi;
end;


#############################################################################
##
#F  TraceImmediateMethods( <flag> )
##
TRACE_IMMEDIATE_METHODS := false;

TraceImmediateMethods := function( flag )
    if flag  then
        TRACE_IMMEDIATE_METHODS := true;
    else
        TRACE_IMMEDIATE_METHODS := false;
    fi;
end;


#############################################################################
##
#F  RunImmediateMethods( <obj>, <flags> )
##
##  applies immediate  methods  for the   object <obj>  for that  the  'true'
##  position in the Boolean list <flags> mean  that the corresponding filters
##  have been found out recently.   So possible consequences of other filters
##  are not checked.
##
RUN_IMMEDIATE_METHODS_CHECKS := 0;
RUN_IMMEDIATE_METHODS_HITS   := 0;

RunImmediateMethods := function ( obj, flags )

    local   flagspos,   # list of 'true' positions in 'flags'
            tried,      # list of numbers of methods that have been used
            kind,       # kind of 'obj', used to notice kind changes
            j,          # loop over 'flagspos'
            imm,        # immediate methods for filter 'j'
            i,          # loop over 'imm'
            res,        # result of an immediate method
            newflags;   # newly  found filters

    # Avoid recursive calls from inside a setter.
    if IGNORE_IMMEDIATE_METHODS then return; fi;

    flagspos := SHALLOW_COPY_OBJ(TRUES_FLAGS(flags));
    tried    := [];
    kind     := KIND_OBJ( obj );
    flags    := kind![2];

    # Check the immediate methods for all in 'flagspos'.
    # (Note that new information is handled via appending to that list.)
    for j  in flagspos  do

        # Loop over those immediate methods
        # - that require 'flags[j]' to be 'true',
        # - that are applicable to 'obj',
        # - whose result is not yet known to 'obj',
        # - that have not yet been tried in this call of 
        #   'RunImmediateMethods'.

        if IsBound( IMMEDIATES[j] ) then
            imm := IMMEDIATES[j];
            for i  in [ 0, 7 .. LEN_LIST(imm)-7 ]  do
    
                if        IS_SUBSET_FLAGS( flags, imm[i+4] )
                  and not IS_SUBSET_FLAGS( flags, imm[i+3] )
                  and not imm[i+6] in tried
                then
    
                    # Call the method, and store that it was used.
                    res := IMMEDIATE_METHODS[ imm[i+6] ]( obj );
                    ADD_LIST( tried, imm[i+6] );
                    RUN_IMMEDIATE_METHODS_CHECKS :=
                        RUN_IMMEDIATE_METHODS_CHECKS+1;
    
                    if res <> TRY_NEXT_METHOD  then
                        if TRACE_IMMEDIATE_METHODS  then
                            Print( "#I  immediate: ", imm[i+7], "\n" );
                        fi;
    
                        # Call the setter, without running immediate methods.
                        IGNORE_IMMEDIATE_METHODS := true;
                        imm[i+2]( obj, res );
                        IGNORE_IMMEDIATE_METHODS := false;
                        RUN_IMMEDIATE_METHODS_HITS :=
                            RUN_IMMEDIATE_METHODS_HITS+1;
                              
                        # If 'obj' has noticed the new information,
                        # add the numbers of newly known filters to
                        # 'flagspos', in order to call their immediate
                        # methods later.
                        if not IS_IDENTICAL_OBJ( KIND_OBJ(obj), kind ) then

                          kind := KIND_OBJ(obj);
                          newflags := SHALLOW_COPY_OBJ(TRUES_FLAGS(kind![2]));
                          SUBTR_SET( newflags, TRUES_FLAGS(flags) );
                          APPEND_LIST_INTR( flagspos, newflags );
                          flags := kind![2];

                        fi;
                    fi;
                fi;
            od;

        fi;
    od;
end;


#############################################################################
##
#F  INSTALL_METHOD( <oper>, ... ) . . . . . . . . install a method for <oper>
##
INSTALL_METHOD := function( opr, info, rel, filters, rank, method, check )
    local   tmp,  tmp2,  req,  i,  imp,  k,  narg,  methods;

    # check whether this really installs an implication
    if    FLAGS_FILTER(opr) <> false
      and (rel = true or rel = RETURN_TRUE)
      and LEN_LIST(filters) = 1
      and (method = true or method = RETURN_TRUE)
    then
        Error( "use 'InstallTrueMethod' for <opr>" );
    fi;

    # check <info>
    if info <> false and not IS_STRING(info)  then
        Error( "<info> must be a string or 'false'" );
    fi;

    # test if <check> is true
    if check  then

        # find the operation
        req := false;
        for i  in [ 1, 3 .. LEN_LIST(OPERATIONS)-1 ]  do
            if IS_IDENTICAL_OBJ( OPERATIONS[i], opr )  then
                req := OPERATIONS[i+1];
                break;
            fi;
        od;
        if req = false  then
            Error( "unknown operation ", NAME_FUNCTION(opr) );
        fi;
        if LEN_LIST(filters) <> LEN_LIST(req)  then
            Error( "expecting ", LEN_LIST(req), " arguments for operation ",
                   NAME_FUNCTION(opr) );
        fi;

        # do check with implications
        imp := [];
        for i  in filters  do
            ADD_LIST( imp, WITH_HIDDEN_IMPS_FLAGS( FLAGS_FILTER(i) ) );
        od;

        # check the requirements
        for i  in [ 1 .. LEN_LIST(req) ]  do
            if not IS_SUBSET_FLAGS( imp[i], req[i] )  then
                tmp  := NamesFilter(req[i]);
                tmp2 := NamesFilter(imp[i]);
                Error( Ordinal(i), " argument of ", NAME_FUNCTION(opr),
                       " must have ", tmp, " not ", tmp2 );
            fi;
        od;
    fi;

    # add the number of filters required for each argument
    if opr in CONSTRUCTORS  then
        if 0 < LEN_LIST(filters)  then
            rank := rank - 
              SIZE_FLAGS(WITH_HIDDEN_IMPS_FLAGS(FLAGS_FILTER(filters[1])));
        fi;
    else
        for i  in filters  do
            rank := rank
                    + SIZE_FLAGS(WITH_HIDDEN_IMPS_FLAGS(FLAGS_FILTER(i)));
        od;
    fi;

    # get the methods list
    narg := LEN_LIST( filters );
    methods := METHODS_OPERATION( opr, narg );

    # find the place to put the new method
    i := 0;
    while i < LEN_LIST(methods) and rank < methods[i+(narg+3)]  do
        i := i + (narg+4);
    od;

    # push the other functions back
    methods{[i+1..LEN_LIST(methods)]+(narg+4)}
        := methods{[i+1..LEN_LIST(methods)]};

    # install the new method
    if   rel = true  then
        methods[i+1] := RETURN_TRUE;
    elif rel = false  then
        methods[i+1] := RETURN_FALSE;
    elif IS_FUNCTION(rel)  then
        methods[i+1] := rel;
        tmp := NARG_FUNCTION(rel);
        if tmp <> AINV(1) and tmp <> LEN_LIST(filters)  then
           Error( "<rel> must accept ", LEN_LIST(filters), " arguments" );
        fi;
    else
        Error( "<rel> must be a function, 'true', or 'false'" );
    fi;

    # install the filters
    for k  in [ 1 .. narg ]  do
        methods[i+k+1] := FLAGS_FILTER( filters[k] );
    od;

    # install the method
    if   method = true  then
        methods[i+(narg+2)] := RETURN_TRUE;
    elif method = false  then
        methods[i+(narg+2)] := RETURN_FALSE;
    elif IS_FUNCTION(method)  then
        methods[i+(narg+2)] := method;
        tmp := NARG_FUNCTION(method);
        if tmp <> AINV(1) and tmp <> LEN_LIST(filters)  then
           Error( "<method> must accept ", LEN_LIST(filters), " arguments" );
        fi;
    else
        Error( "<method> must be a function, 'true', or 'false'" );
    fi;
    methods[i+(narg+3)] := rank;

    # set the name
    if info = false  then
        info := NAME_FUNCTION(opr);
    else
        k := SHALLOW_COPY_OBJ(NAME_FUNCTION(opr));
        APPEND_LIST_INTR( k, ": " );
        APPEND_LIST_INTR( k, info );
        info := k;
        CONV_STRING(info);
    fi;
    methods[i+(narg+4)] := IMMUTABLE_COPY_OBJ(info);

    # flush the cache
    CHANGED_METHODS_OPERATION( opr, narg );
end;


#############################################################################
##
#F  InstallMethod( <opr>, <relation>, <filters>, <rank>, <method> )
##
InstallMethod := function ( arg )
    if 6 = LEN_LIST(arg)  then
        INSTALL_METHOD(arg[1],arg[2],arg[3],arg[4],arg[5],arg[6],true);
    elif 5 = LEN_LIST(arg)  then
        INSTALL_METHOD(arg[1],false,arg[2],arg[3],arg[4],arg[5],true);
    else
        Error("usage: InstallMethod( <opr>, <rel>, <fil>, <rk>, <method> )");
    fi;
end;


#############################################################################
##
#F  InstallOtherMethod( <opr>, <relation>, <filters>, <rank>, <method> )
##
InstallOtherMethod := function ( arg )
    if 6 = LEN_LIST(arg)  then
        INSTALL_METHOD(arg[1],arg[2],arg[3],arg[4],arg[5],arg[6],false);
    elif 5 = LEN_LIST(arg)  then
        INSTALL_METHOD(arg[1],false,arg[2],arg[3],arg[4],arg[5],false);
    else
        Error( "usage: InstallOtherMethod( <opr>, <rel>, <fil>, <rk>, ",
               "<method> )" );
    fi;
end;


#############################################################################
##
#F  InstallSubsetTrueMethod( <opr>, <super_req>, <sub_req> )
##
##  <opr> is a property.
#T how to check this?
##  If a domain $S$ has the property <sub_req> and is known to be a subset of
##  a  domain with the property  <super_req> then the  value of <opr> for $S$
##  shall be 'true'.
##
SUBSET_TRUE_METHODS := [];

InstallSubsetTrueMethod := function ( operation, super_req, sub_req )
    ADD_LIST( SUBSET_TRUE_METHODS,
              [ Setter( operation ),
                super_req, Tester( super_req ),
                sub_req,   Tester( sub_req )    ] );
end;

RunSubsetImplications := function( super, sub )
    local tuple;
    for tuple in SUBSET_TRUE_METHODS do
      if     tuple[3]( super ) and tuple[2]( super )
         and tuple[5]( sub   ) and tuple[4]( sub   ) then
        tuple[1]( sub, true );
      fi;
    od;
end;


#############################################################################
##
#F  InstallIsomorphismTrueMethod( <opr>, <old_req>, <new_req> )
##
##  <opr> is a property.
#T how to check this?
#T here we also want attributes, such as Size, DegreeOverPrimeField etc.
#T ('InstallIsomorphismInvariance'?)
##  If  a domain  $D$ has  the property  <old_req> and is    known to be  the
##  isomorphic to a domain $E$ with the property <new_req>  then the value of
##  <opr> for $E$ shall be 'true'.
##
ISOMORPHISM_TRUE_METHODS := [];

InstallIsomorphismTrueMethod := function( opr, old_req, new_req )
    ADD_LIST( ISOMORPHISM_TRUE_METHODS,
              [ Setter( opr ),
                old_req,  Tester( old_req ),
                new_req,  Tester( new_req )  ] );
end;

RunIsomorphismImplications := function( old, new )
    local tuple;
    for tuple in ISOMORPHISM_TRUE_METHODS do
      if     tuple[3]( old ) and tuple[2]( old )
         and tuple[5]( new ) and tuple[4]( new ) then
        tuple[1]( new, true );
      fi;
    od;
end;


#############################################################################
##
#F  InstallFactorTrueMethod( <opr>, <numer_req>, <denom_req>, <factor_req> )
##
##  <opr> is a property.
#T how to check this?
##  If a  domain $F$ has the  property <factor_req>  and is  known to  be the
##  homomorphic image of  a domain with the property  <numer_req> by a domain
##  with the  property <denom_req> then the  value of <opr>  for $F$ shall be
##  'true'.
##
##  Note that the implications installed  by 'InstallFactorTrueMethod' can be
##  used in the case of isomorphisms.
##
FACTOR_TRUE_METHODS := [];

InstallFactorTrueMethod := function( opr, numer_req, denom_req, factor_req )
    ADD_LIST( FACTOR_TRUE_METHODS,
              [ Setter( opr ),
                numer_req,  Tester( numer_req ),
                denom_req,  Tester( denom_req ),
                factor_req, Tester( factor_req )   ] );
    InstallIsomorphismTrueMethod( opr, numer_req, factor_req );
end;

RunFactorImplications := function( numer, denom, factor )
    local tuple;
    for tuple in FACTOR_TRUE_METHODS do
      if     tuple[3]( numer  ) and tuple[2]( numer  )
         and tuple[5]( denom  ) and tuple[4]( denom  )
         and tuple[7]( factor ) and tuple[6]( factor ) then
        tuple[1]( factor, true );
      fi;
    od;
end;


#############################################################################
##
#F  NewOperation( <name>, <filters> )
##
NewOperation := function ( name, filters )
    local   oper,  filt,  i;

    oper := NEW_OPERATION( name );
    filt := [];
    for i  in filters  do
        ADD_LIST( filt, FLAGS_FILTER(i) );
    od;
    ADD_LIST( OPERATIONS, oper );
    ADD_LIST( OPERATIONS, filt );
    return oper;
end;


#############################################################################
##
#F  NewOperationKernel( <name>, <filter>, <kernel-oper> )
##
NewOperationKernel := function ( name, filters, oper )
    local   filt,  i;

    filt := [];
    for i  in filters  do
        ADD_LIST( filt, FLAGS_FILTER(i) );
    od;
    ADD_LIST( OPERATIONS, oper );
    ADD_LIST( OPERATIONS, filt );
    return oper;
end;


#############################################################################
##
#F  NewConstructor( <name>, <filters> )
##
NewConstructor := function ( name, filters )
    local   oper,  filt,  i;

    oper := NEW_CONSTRUCTOR( name );
    filt := [];
    for i  in filters  do
        ADD_LIST( filt, FLAGS_FILTER(i) );
    od;
    ADD_LIST( CONSTRUCTORS, oper );
    ADD_LIST( OPERATIONS,   oper );
    ADD_LIST( OPERATIONS,   filt );
    return oper;
end;


#############################################################################
##
#F  NewConstructorKernel( <name>, <filter>, <kernel-oper> )
##
NewConstructorKernel := function ( name, filters, oper )
    local   filt,  i;

    filt := [];
    for i  in filters  do
        ADD_LIST( filt, FLAGS_FILTER(i) );
    od;
    ADD_LIST( CONSTRUCTORS, oper );
    ADD_LIST( OPERATIONS,   oper );
    ADD_LIST( OPERATIONS,   filt );
    return oper;
end;


#############################################################################
##
#F  NewOperationArgs( <name> )
##
NewOperationArgs := function ( name )
    return function ( arg )
        Error( "no method found for operation '", name, "'" );
    end;
end;


#############################################################################
##
#F  InstallAttributeFunction( <func> )  . . . run function for each attribute
##
##  'InstallAttributeFunction' installs <func>, so that
##  '<func>( <name>, <filter>, <getter>, <setter>, <tester>, <mutflag> )'
##  is called for each attribute.
##
ATTRIBUTES := [];

ATTR_FUNCS := [];

InstallAttributeFunction := function ( func )
    local   attr;
    for attr in ATTRIBUTES do
        func( attr[1], attr[2], attr[3], attr[4], attr[5], attr[6] );
    od;
    ADD_LIST( ATTR_FUNCS, func );
end;

RUN_ATTR_FUNCS := function ( name, filter, getter, setter, tester, mutflag )
    local    func;
    for func in ATTR_FUNCS do
        func( name, filter, getter, setter, tester, mutflag );
    od;
    ADD_LIST( ATTRIBUTES, [ name, filter, getter, setter, tester, mutflag ] );
end;


#############################################################################
##
#F  NewAttribute( <name>, <filter> )
#F  NewAttribute( <name>, <filter>, "mutable" )
##
NewAttribute := function ( arg )
    local   name, filter, mutflag, getter, setter, tester;

    # construct getter, setter and tester
    name   := arg[1];
    filter := arg[2];

    mutflag := LEN_LIST( arg ) = 3 and arg[3] = "mutable";

    if mutflag then
      getter := NEW_MUTABLE_ATTRIBUTE( name );
    else
      getter := NEW_ATTRIBUTE( name );
    fi;

    setter := SETTER_FILTER( getter );
    tester := TESTER_FILTER( getter );

    # add getter, setter and tester to the list of operations
    ADD_LIST( OPERATIONS, getter );
    ADD_LIST( OPERATIONS, [ FLAGS_FILTER(filter) ] );
    ADD_LIST( OPERATIONS, setter );
    ADD_LIST( OPERATIONS, [ FLAGS_FILTER(filter),FLAGS_FILTER(IS_OBJECT) ] );
    ADD_LIST( OPERATIONS, tester );
    ADD_LIST( OPERATIONS, [ FLAGS_FILTER(filter) ] );

    # install the default functions
    FILTERS[ FLAG2_FILTER( tester ) ] := tester;
    InstallHiddenTrueMethod( filter, tester );
    RUN_ATTR_FUNCS( name, filter, getter, setter, tester, mutflag );

    # and return the getter
    return getter;
end;

NewAttributeKernel := function ( name, filter, getter )
    local   setter,  tester;

    # construct setter and tester
    setter := SETTER_FILTER( getter );
    tester := TESTER_FILTER( getter );

    # add getter, setter and tester to the list of operations
    ADD_LIST( OPERATIONS, getter );
    ADD_LIST( OPERATIONS, [ FLAGS_FILTER(filter) ] );
    ADD_LIST( OPERATIONS, setter );
    ADD_LIST( OPERATIONS, [ FLAGS_FILTER(filter), [] ] );
    ADD_LIST( OPERATIONS, tester );
    ADD_LIST( OPERATIONS, [ FLAGS_FILTER(filter) ] );

    # install the default functions
    FILTERS[ FLAG2_FILTER( tester ) ]:= tester;
    InstallHiddenTrueMethod( filter, tester );
    RUN_ATTR_FUNCS( name, filter, getter, setter, tester, false );

    # and return the getter
    return getter;
end;


#############################################################################
##
#M  default attribute getter and setter methods
##
##  There are the following three default getter methods.
##  The first requires only 'IsObject', and signals what categories the
##  attribute requires.
##  The second requires the category part of the attribute's requirements,
##  tests the property getters of the requirements,
##  and -if they are 'true' and afterwards stored in the object- calls the 
##  attribute operation again.
##  The third requires the attribute's requirements, and signals that no
##  method was found.
##
##  The default setter method does nothing.
##
##  Note that we do *not* install any default getter method for an attribute
##  that requires only 'IsObject'.
##  (The error message is printed by the method selection in this case.)
##  Also the second and third default method are installed only if the
##  property getter part of the attribute's requirements is nontrivial.
##  
InstallAttributeFunction(
    function ( name, filter, getter, setter, tester, mutflag )
    local flags, cats, props, i;
    if not IS_IDENTICAL_OBJ( filter, IS_OBJECT ) then

        flags := FLAGS_FILTER( filter );

        InstallOtherMethod( getter,
            true, [ IS_OBJECT ], 0,
            function ( obj )
            local filt, hascats, i;
            filt:= [];
            hascats:= true;
            for i in [ 1 .. LEN_FLAGS(flags) ] do
                if ELM_FLAGS(flags,i) and i in CATS_AND_REPS  then
                    if not FILTERS[i]( obj ) then
                        hascats:= false;
                    fi;
                    ADD_LIST( filt, NAME_FUNCTION( FILTERS[i] ) );
                fi;
            od;
            if not hascats then
                Error( "argument for '", name,
                       "' must have categories '", filt, "'" );
            else
                Error( "no method found for operation ", name );
            fi;
            end
        );

        cats  := IS_OBJECT;
        props := [];
        for i in [ 1 .. LEN_FLAGS(flags) ] do
            if ELM_FLAGS(flags,i)  then
                if i in CATS_AND_REPS  then
                    cats:= cats and FILTERS[i];
                elif i in NUMBERS_PROPERTY_GETTERS  then
                    ADD_LIST( props, FILTERS[i] );
                fi;
            fi;
        od;
        if 0 < LEN_LIST(props) then
          InstallOtherMethod( getter,
              true, [ cats ], 0,
              function ( obj )
              local prop;
              for prop in props do
                if not ( prop( obj ) and Tester( prop )( obj ) ) then
                  Error( "<obj> must have the properties in <props>" );
                fi;
              od;
              return getter( obj );
              end
          );
  
          InstallMethod( getter,
              true, [ filter ], 0,
              function ( obj )
              Error( "no method found for operation ", name );
              end
          );
        fi;
    fi;
    end );

InstallAttributeFunction(
    function ( name, filter, getter, setter, tester, mutflag )
    InstallOtherMethod( setter,
        true, [ IS_OBJECT, IS_OBJECT ], 0,
        function ( obj, val )
        end );
    end );


#############################################################################
##
#F  NewProperty( <name>, <filter> )
##
NewProperty := function ( name, filter )
    local   getter, setter, tester;

    # construct getter, setter and tester
    getter := NEW_PROPERTY(  name );
    setter := SETTER_FILTER( getter );
    tester := TESTER_FILTER( getter );

    # add getter, setter and tester to the list of operations
    ADD_LIST( OPERATIONS, getter );
    ADD_LIST( OPERATIONS, [ FLAGS_FILTER(filter) ] );
    ADD_LIST( OPERATIONS, setter );
    ADD_LIST( OPERATIONS, [ FLAGS_FILTER(filter), FLAGS_FILTER(IS_BOOL) ] );
    ADD_LIST( OPERATIONS, tester );
    ADD_LIST( OPERATIONS, [ FLAGS_FILTER(filter) ] );

    # store the property getters
    ADD_LIST( NUMBERS_PROPERTY_GETTERS, FLAG1_FILTER( getter ) );

    # install the default functions
    FILTERS[ FLAG1_FILTER( getter ) ] := getter;
    FILTERS[ FLAG2_FILTER( getter ) ] := tester;
    InstallHiddenTrueMethod( tester, getter );
    InstallHiddenTrueMethod( filter, tester );
    RUN_ATTR_FUNCS( name, filter, getter, setter, tester, false );

    # and return the getter
    return getter;
end;

NewPropertyKernel := function ( name, filter, getter )
    local   setter,  tester;

    # construct setter and tester
    setter := SETTER_FILTER( getter );
    tester := TESTER_FILTER( getter );

    # store the property getters
    ADD_LIST( NUMBERS_PROPERTY_GETTERS, FLAG1_FILTER( getter ) );

    # add getter, setter and tester to the list of operations
    ADD_LIST( OPERATIONS, getter );
    ADD_LIST( OPERATIONS, [ FLAGS_FILTER(filter) ] );
    ADD_LIST( OPERATIONS, setter );
    ADD_LIST( OPERATIONS, [ FLAGS_FILTER(filter), FLAGS_FILTER(IS_BOOL) ] );
    ADD_LIST( OPERATIONS, tester );
    ADD_LIST( OPERATIONS, [ FLAGS_FILTER(filter) ] );

    # install the default functions
    FILTERS[ FLAG1_FILTER( getter ) ]:= getter;
    FILTERS[ FLAG2_FILTER( getter ) ]:= tester;
    InstallHiddenTrueMethod( tester, getter );
    InstallHiddenTrueMethod( filter, tester );
    RUN_ATTR_FUNCS( name, filter, getter, setter, tester, false );

    # and return the getter
    return getter;
end;


#############################################################################
##
#F  RankFilter( <filter> )
##
RankFilter := function( filter )
    return SIZE_FLAGS( FLAGS_FILTER(filter) );
end;


#############################################################################
##

#F  TraceMethods( <method1>, ... )
##
TraceMethods := function( arg )
    local   fun;

    if IS_LIST(arg[1])  then
        arg := arg[1];
    fi;
    for fun  in arg  do
        TRACE_METHODS(fun);
    od;

end;


#############################################################################
##
#F  UntraceMethods( <method1>, ... )
##
UntraceMethods := function( arg )
    local   fun;

    if IS_LIST(arg[1])  then
        arg := arg[1];
    fi;
    for fun  in arg  do
        UNTRACE_METHODS(fun);
    od;

end;


#############################################################################
##

#E  oper.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
