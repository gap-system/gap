#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Functions moved from oper.g, so as to be compiled in the default kernel
##


#############################################################################
##
#F  RunImmediateMethods( <obj>, <flags> )
##
##  applies immediate  methods  for the   object <obj>  for that  the  `true'
##  position in the Boolean list <flags> mean  that the corresponding filters
##  have been discovered recently.
##  So possible consequences of other filters are not checked.
##
RUN_IMMEDIATE_METHODS_RUNS   := 0;
RUN_IMMEDIATE_METHODS_CHECKS := 0;
RUN_IMMEDIATE_METHODS_HITS   := 0;

BIND_GLOBAL( "RunImmediateMethods", function ( obj, flags )

    local   flagspos,   # list of `true' positions in `flags'
            tried,      # list of numbers of methods that have been used
            type,       # type of `obj', used to notice type changes
            j,          # loop over `flagspos'
            imm,        # immediate methods for filter `j'
            i,          # loop over `imm'
            meth,
            res,        # result of an immediate method
            loc,
            newflags;   # newly  found filters

    # Avoid recursive calls from inside a setter,
    # permit complete switch-off of immediate methods,
    # ignore immediate methods for objects which have it turned off.
    if IGNORE_IMMEDIATE_METHODS then return; fi;

    # intersect the flags with those for which immediate methods
    # are installed.
    if IS_SUBSET_FLAGS( IMM_FLAGS, flags ) then return; fi;
    flags := SUB_FLAGS( flags, IMM_FLAGS );

    flagspos := SHALLOW_COPY_OBJ(TRUES_FLAGS(flags));
    tried    := [];
    type     := TYPE_OBJ( obj );
    flags    := type![2];

    RUN_IMMEDIATE_METHODS_RUNS := RUN_IMMEDIATE_METHODS_RUNS + 1;
    if TRACE_IMMEDIATE_METHODS  then
        Print( "#I RunImmediateMethods\n");
    fi;

    # Check the immediate methods for all in `flagspos'.
    # (Note that new information is handled via appending to that list.)
    for j  in flagspos  do

        # Loop over those immediate methods
        # - that require `flags[j]' to be `true',
        # - that are applicable to `obj',
        # - whose result is not yet known to `obj',
        # - that have not yet been tried in this call of
        #   `RunImmediateMethods'.

        if IsBound( IMMEDIATES[j] ) then
#T  the `if' statement can disappear when `IMM_FLAGS' is improved ...
            imm := IMMEDIATES[j];
            for i  in [ 0, SIZE_IMMEDIATE_METHOD_ENTRY .. LEN_LIST(imm)-SIZE_IMMEDIATE_METHOD_ENTRY ]  do

                if        IS_SUBSET_FLAGS( flags, imm[i+4] )
                  and not IS_SUBSET_FLAGS( flags, imm[i+3] )
                  and not imm[i+6] in tried
                then

                    # Call the method, and store that it was used.
                    meth := IMMEDIATE_METHODS[ imm[i+6] ];
                    res := meth( obj );
                    ADD_LIST( tried, imm[i+6] );
                    RUN_IMMEDIATE_METHODS_CHECKS :=
                        RUN_IMMEDIATE_METHODS_CHECKS+1;
                    if TRACE_IMMEDIATE_METHODS  then
                        Print( "#I  immediate: ", NAME_FUNC( imm[i+1] ));
                        if imm[i+7] <> false then
                            Print( ": ", imm[i+7] );
                        fi;
                        Print(" at ", imm[i+8][1], ":", imm[i+8][2], "\n");
                    fi;

                    if res <> TRY_NEXT_METHOD  then

                        # Call the setter, without running immediate methods.
                        IGNORE_IMMEDIATE_METHODS := true;
                        imm[i+2]( obj, res );
                        IGNORE_IMMEDIATE_METHODS := false;
                        RUN_IMMEDIATE_METHODS_HITS :=
                            RUN_IMMEDIATE_METHODS_HITS+1;

                        # If `obj' has noticed the new information,
                        # add the numbers of newly known filters to
                        # `flagspos', in order to call their immediate
                        # methods later.
                        if not IS_IDENTICAL_OBJ( TYPE_OBJ(obj), type ) then

                          type := TYPE_OBJ(obj);

                          newflags := SUB_FLAGS( type![2], IMM_FLAGS );
                          newflags := SUB_FLAGS( newflags, flags );
                          APPEND_LIST_INTR( flagspos,
                                            TRUES_FLAGS( newflags ) );

                          flags := type![2];

                        fi;
                    fi;
                fi;
            od;

        fi;
    od;
end );

#############################################################################
##
#V METHODS_OPERATION_REGION . . . . pseudo lock for updating method lists.
##
## We really just need one arbitrary lock here. Any globally shared
## region will do. This is to prevent concurrent SET_METHODS_OPERATION()
## calls to overwrite each other. Given that these normally only occur
## when loading a package, actual concurrent calls should be vanishingly
## rare.
if IsHPCGAP then
    BIND_GLOBAL("METHODS_OPERATION_REGION", NewSpecialRegion("operation methods"));
fi;

#############################################################################
##
#F  INSTALL_METHOD_FLAGS( <opr>, <info>, <rel>, <flags>, <rank>, <method> ) .
##
BIND_GLOBAL( "INSTALL_METHOD_FLAGS",
    function( opr, info, rel, flags, baserank, method )
    local   methods,  narg,  i,  k,  tmp, replace, match, j, lk, rank;

    if IS_IDENTICAL_OBJ(opr, method) then
        Error("Cannot install an operation as a method for itself");
    fi;

    if IsHPCGAP then
        # TODO: once the GAP compiler supports 'atomic', use that
        # to replace the explicit locking and unlocking here.
        lk := WRITE_LOCK(METHODS_OPERATION_REGION);
    fi;
    # add the number of filters required for each argument
    if IS_FUNCTION(baserank) then
        rank := baserank();
    else
        rank := baserank;
    fi;
    if IS_CONSTRUCTOR(opr) then
        if 0 = LEN_LIST(flags)  then
            Error(NAME_FUNC(opr),": constructors must have at least one argument");
        fi;
        flags[1]:= WITH_IMPS_FLAGS( flags[1] );
        rank := rank - RankFilter( flags[ 1 ] );
    else
        for i  in flags  do
            rank := rank + RankFilter( i );
        od;
    fi;

    # get the methods list
    narg := LEN_LIST( flags );
    methods := METHODS_OPERATION( opr, narg );
    if IsHPCGAP then
        methods := methods{[1..LEN_LIST(methods)]};
    fi;

    # set the name
    if info = false  then
        info := NAME_FUNC(opr);
    else
        k := SHALLOW_COPY_OBJ(NAME_FUNC(opr));
        APPEND_LIST_INTR( k, ": " );
        APPEND_LIST_INTR( k, info );
        info := k;
        CONV_STRING(info);
    fi;

    # find the place to put the new method
    i := 0;
    while i < LEN_LIST(methods) and rank < methods[i+(narg+3)]  do
        i := i + (narg+BASE_SIZE_METHODS_OPER_ENTRY);
    od;

    # Now is a good time to see if the method is already there
    replace := false;
    if REREADING then
        k := i;
        while k < LEN_LIST(methods) and
          rank = methods[k+narg+3] do
            if info = methods[k+narg+4] then

                # ForAll not available
                match := true;
                for j in [1..narg] do
                    match := match and methods[k+j+1] = flags[j];
                od;
                if match then
                    replace := true;
                    i := k;
                    break;
                fi;
            fi;
            k := k+narg+BASE_SIZE_METHODS_OPER_ENTRY;
        od;
    fi;
    # push the other functions back
    if not REREADING or not replace then
        COPY_LIST_ENTRIES(methods, i+1, 1, methods, narg+BASE_SIZE_METHODS_OPER_ENTRY+i+1,1,
                LEN_LIST(methods)-i);
    fi;

    # check the family predicate
    if   rel = true  then
        rel := RETURN_TRUE;
    elif rel = false  then
        rel := RETURN_FALSE;
    elif IS_FUNCTION(rel)  then
        if CHECK_INSTALL_METHOD  then
            tmp := NARG_FUNC(rel);
            if tmp < -narg-1 or (tmp >= 0 and tmp <> narg)   then
                Error(NAME_FUNC(opr),": <famrel> must accept ",
                      narg, " arguments");
            fi;
        fi;
    else
        Error(NAME_FUNC(opr),
              ": <famrel> must be a function, `true', or `false'" );
    fi;

    # check the method
    if   method = true  then
        method := RETURN_TRUE;
    elif method = false  then
        method := RETURN_FALSE;
    elif IS_FUNCTION(method)  then
        if CHECK_INSTALL_METHOD and not IS_OPERATION( method ) then
            tmp := NARG_FUNC(method);
            if tmp < -narg-1 or (tmp >= 0 and tmp <> narg)  then
               Error(NAME_FUNC(opr),": <method> must accept ",
                     narg, " arguments");
            fi;
        fi;
    else
        Error(NAME_FUNC(opr),
              ": <method> must be a function, `true', or `false'" );
    fi;

    # install the family predicate
    methods[i+1] := rel;

    # install the filters
    for k  in [ 1 .. narg ]  do
        methods[i+k+1] := flags[k];
    od;

    # install the method
    methods[i+(narg+2)] := method;
    methods[i+(narg+3)] := rank;
    methods[i+(narg+4)] := IMMUTABLE_COPY_OBJ(info);
    methods[i+(narg+5)] := MakeImmutable([INPUT_FILENAME(), READEVALCOMMAND_LINENUMBER, INPUT_LINENUMBER()]);
    methods[i+(narg+6)] := baserank;

    # flush the cache
    if IsHPCGAP then
        SET_METHODS_OPERATION( opr, narg, MakeReadOnlySingleObj(methods) );
        UNLOCK(lk);
    else
        CHANGED_METHODS_OPERATION( opr, narg );
    fi;
end );


#############################################################################
##
#F  InstallMethod( <opr>[,<info>][,<relation>],<filters>[,<rank>],<method> )
##
##  <#GAPDoc Label="InstallMethod">
##  <ManSection>
##  <Func Name="InstallMethod"
##   Arg="opr[,info][,famp],args-filts[,val],method"/>
##
##  <Description>
##  installs a function method <A>method</A> for the operation <A>opr</A>;
##  <A>args-filts</A> should be a list of requirements for the arguments,
##  each entry being a filter;
##  if supplied <A>info</A> should be a short but informative string
##  that describes for what situation the method is installed,
##  <A>famp</A> should be a function to be applied to the families
##  of the arguments.
##  <A>val</A> should be an integer that measures the priority of the
##  method, or a function of no arguments which should return such an
##  integer and will be called each time method order is being
##  recalculated (see <Ref Func="InstallTrueMethod"/>).
##  <P/>
##  The default values for <A>info</A>, <A>famp</A>, and <A>val</A> are
##  the empty string,
##  the function <Ref Func="ReturnTrue"/>,
##  and the integer zero, respectively.
##  <P/>
##  The exact meaning of the arguments <A>famp</A>, <A>args-filts</A>,
##  and <A>val</A> is explained in
##  Section&nbsp;<Ref Sect="Applicable Methods and Method Selection"/>.
##  <P/>
##  <A>opr</A> expects its methods to require certain filters for their
##  arguments.
##  For example, the argument of a method for the operation
##  <Ref Attr="Zero"/> must be
##  in the category <Ref Filt="IsAdditiveElementWithZero"/>.
##  It is not possible to use <Ref Func="InstallMethod"/> to install
##  a method for which the entries of <A>args-filts</A> do not imply
##  the respective requirements of the operation <A>opr</A>.
##  If one wants to override this restriction,
##  one has to use <Ref Func="InstallOtherMethod"/> instead.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "InstallMethod",
    function( arg )
    INSTALL_METHOD( arg, true );
    end );


#############################################################################
##
#F  InstallOtherMethod( <opr>[,<info>][,<relation>],<filters>[,<rank>],
#F                      <method> )
##
##  <#GAPDoc Label="InstallOtherMethod">
##  <ManSection>
##  <Func Name="InstallOtherMethod"
##   Arg="opr[,info][,famp],args-filts[,val],method"/>
##
##  <Description>
##  installs a function method <A>method</A> for the operation <A>opr</A>,
##  in the same way as for <Ref Func="InstallMethod"/>,
##  but without the restriction that the number of arguments must match
##  a declaration of <A>opr</A>
##  and without the restriction that <A>args-filts</A> imply the respective
##  requirements of the operation <A>opr</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "InstallOtherMethod",
    function( arg )
    INSTALL_METHOD( arg, false );
    end );


#############################################################################
##
#F  InstallEarlyMethod( <opr>,<method> )
##
##  <#GAPDoc Label="InstallEarlyMethod">
##  <ManSection>
##  <Func Name="InstallEarlyMethod" Arg="opr,method"/>
##
##  <Description>
##  installs a special "early" function method <A>method</A> for the
##  operation <A>opr</A>. An early method is special in that it bypasses
##  method dispatch, and is always the first method to be called when
##  invoking the operation.
##  <P/>
##  This can be used to avoid method selection overhead for certain special
##  cases, i.e., as an optimization. Overall, we recommend to use this
##  feature very sparingly, as it is tool with sharp edges: for example, any
##  inputs that are handled by an early method can not be intercepted by a
##  regular method, no matter how high its rank is; this can preclude other
##  kinds of optimizations.
##  <P/>
##  Also, unlike regular methods, no checks are performed on the arguments.
##  Not even the required filters for the operation are tested, so early
##  methods must be careful in validating their inputs.
##  This also means that any operation can have at most one such early
##  method for each arity (i.e., one early method taking 1 argument, one
##  early method taking 2 arguments, etc.).
##  <P/>
##  If an early method determines that it is not applicable, it can resume
##  regular method dispatch by invoking <Ref Func="TryNextMethod"/>.
##  <P/>
##  For an example application of early methods, they are used by
##  <Ref Oper="First"/> to deal with internal lists, for which computing
##  the exact type (needed for method selection) can be very expensive.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "InstallEarlyMethod", INSTALL_EARLY_METHOD );
#TODO; store location info somehow
#MakeImmutable([INPUT_FILENAME(), READEVALCOMMAND_LINENUMBER, INPUT_LINENUMBER()])

#############################################################################
##
#F  INSTALL_METHOD( <arglist>, <check> )  . . . . . . . . .  install a method
##
DeclareGlobalFunction( "EvalString" );

Unbind(INSTALL_METHOD);
BIND_GLOBAL( "INSTALL_METHOD",
    function( arglist, check )
    local len,   # length of `arglist'
          opr,   # the operation
          info,
          pos,
          rel,
          filters,
          info1,
          isstr,
          flags,
          i,
          rank,
          method,
          oreqs,
          req, reqs, match, j, k, imp, notmatch, lk, funcname;

    if IsHPCGAP then
        # TODO: once the GAP compiler supports 'atomic', use that
        # to replace the explicit locking and unlocking here.
        lk := READ_LOCK( OPERATIONS_REGION );
    fi;

    # Check the arguments.
    len:= LEN_LIST( arglist );
    if len < 3 then
      Error( "too few arguments given in <arglist>" );
    fi;

    # The first argument must be an operation.
    opr:= arglist[1];
    if not IS_OPERATION( opr ) then
      Error( "<opr> is not an operation" );
    fi;

    # Check whether an info string is given,
    # or whether the list of argument filters is given by a list of strings.
    if IS_STRING_REP( arglist[2] ) or arglist[2] = false then
      info:= arglist[2];
      pos:= 3;
    else
      info:= false;
      pos:= 2;
    fi;

    # Check whether a family predicate (relation) is given.
    if arglist[ pos ] = true or IS_FUNCTION( arglist[ pos ] ) then
      rel:= arglist[ pos ];
      pos:= pos + 1;
    else
      rel:= true;
    fi;

    # Check the filters list.
    if not IsBound( arglist[ pos ] ) or not IS_LIST( arglist[ pos ] ) then
      Error( "<arglist>[", pos, "] must be a list of filters" );
    fi;
    filters:= arglist[ pos ];
    if GAPInfo.MaxNrArgsMethod < LEN_LIST( filters ) then
      Error( "methods can have at most ", GAPInfo.MaxNrArgsMethod,
             " arguments" );
    fi;

    # If the filters list is given by a list of strings then evaluate them
    # and set `info' if this is not set.
    if 0 < LEN_LIST( filters ) then
      info1:= "[ ";
      isstr:= true;
      for i in [ 1 .. LEN_LIST( filters ) ] do
        if IS_STRING_REP( filters[i] ) then
          APPEND_LIST_INTR( info1, filters[i] );
          APPEND_LIST_INTR( info1, ", " );
          filters[i]:= EvalString( filters[i] );
          if not IS_FUNCTION( filters[i] ) then
            Error( "string does not evaluate to a function" );
          fi;
        else
          isstr:= false;
          break;
        fi;
      od;
      if isstr and info = false then
        info1[ LEN_LIST( info1 ) - 1 ]:= ' ';
        info1[ LEN_LIST( info1 ) ]:= ']';
        info:= info1;
      fi;
    fi;
    pos:= pos + 1;

    # Compute the flags lists for the filters.
    flags:= [];
    for i in filters do
      ADD_LIST( flags, FLAGS_FILTER( i ) );
    od;

    # Check the rank.
    if not IsBound( arglist[ pos ] ) then
      Error( "the method is missing in <arglist>" );
    elif IS_INT( arglist[ pos ] ) or
         (IS_FUNCTION( arglist[ pos ] ) and NARG_FUNC( arglist[ pos ] ) = 0
           and pos < LEN_LIST(arglist)) then
        rank := arglist[ pos ];
        pos := pos+1;
    else
      rank:= 0;
    fi;

    # Get the method itself.
    if not IsBound( arglist[ pos ] ) then
      Error( "the method is missing in <arglist>" );
    fi;
    method:= arglist[ pos ];

    # For a property, check whether this in fact installs an implication.
    if FLAG1_FILTER( opr ) <> 0
       and ( rel = true or rel = RETURN_TRUE )
       and LEN_LIST( filters ) = 1
       and ( method = true or method = RETURN_TRUE ) then
      Error( NAME_FUNC( opr ), ": use `InstallTrueMethod' for <opr>" );
    fi;

    # Test if `check' is `true'.
    if CHECK_INSTALL_METHOD and check then

      # Signal a warning if the operation is only a wrapper operation.
      if opr in WRAPPER_OPERATIONS then
        INFO_DEBUG( 1,
              "a method is installed for the wrapper operation ",
              NAME_FUNC( opr ), " in ",
              INPUT_FILENAME(), ":", STRING_INT(INPUT_LINENUMBER()),
              "\n",
              "#I  it should probably be installed for (one of) its\n",
              "#I  underlying operation(s)" );
      fi;

      # find the operation
      req := GET_OPER_FLAGS(opr);
      if req = fail  then
        Error( "unknown operation ", NAME_FUNC(opr) );
      fi;

      # do check with implications
      imp := [];
      for i in flags  do
        if not GAPInfo.CommandLineOptions.N then
          ADD_LIST( imp, WITH_HIDDEN_IMPS_FLAGS( i ) );
        else
          ADD_LIST( imp, WITH_IMPS_FLAGS( i ) );
        fi;
      od;

      # Check that the requirements of the method match
      # (at least) one declaration.
      j:= 0;
      match:= false;
      notmatch:=0;
      while j < LEN_LIST( req ) and not match do
        j:= j+1;
        reqs:= req[j];
        if LEN_LIST( reqs ) = LEN_LIST( imp ) then
          match:= true;
          for i  in [ 1 .. LEN_LIST(reqs) ]  do
            if not IS_SUBSET_FLAGS( imp[i], reqs[i] )  then
              match:= false;
              notmatch:=i;
              break;
            fi;
          od;
          if match then
            break;
          fi;
        fi;
      od;

      if not match then

        # If the requirements do not match any of the declarations
        # then something is wrong or `InstallOtherMethod' should be used.
        if notmatch=0 then
          if not GAPInfo.CommandLineOptions.N then
            Error("the number of arguments does not match a declaration of ",
                  NAME_FUNC(opr) );
          else
            Print("InstallMethod warning:  nr of args does not ",
                  "match a declaration of ", NAME_FUNC(opr), "\n" );
          fi;
        else
          if not GAPInfo.CommandLineOptions.N then
            Error("required filters ", NamesFilter(imp[notmatch]),"\nfor ",
                  Ordinal(notmatch)," argument do not match a declaration of ",
                  NAME_FUNC(opr) );
          else
            Print("InstallMethod warning: ",  NAME_FUNC(opr), " at \c",INPUT_FILENAME(),":",
                  INPUT_LINENUMBER()," \c","required filter \c",
                  NAME_FUNC(filters[notmatch]),
                  " for ",Ordinal(notmatch)," argument does not match any ",
                  "declaration\n");
          fi;
        fi;

      else

        oreqs:=reqs;

        # If the requirements match *more than one* declaration
        # then a warning is raised by `INFO_DEBUG'.
        for k in [ j+1 .. LEN_LIST( req ) ] do
          reqs:= req[k];
          if LEN_LIST( reqs ) = LEN_LIST( imp ) then
            match:= true;
            for i  in [ 1 .. LEN_LIST(reqs) ]  do
              if not IS_SUBSET_FLAGS( imp[i], reqs[i] )  then
                match:= false;
                break;
              fi;
            od;
            if match and reqs<>oreqs then
              INFO_DEBUG( 1,
                    "method installed for ", NAME_FUNC(opr),
                    " matches more than one declaration in ",
                    INPUT_FILENAME(), ":", STRING_INT(INPUT_LINENUMBER()));
            fi;
          fi;
        od;

      fi;
    fi;

    if IS_FUNCTION(method) and IsBound(HasNameFunction) and
      IsBound(TYPE_FUNCTION_WITH_NAME) and IsBound(TYPE_OPERATION_WITH_NAME) and
      not VAL_GVAR("HasNameFunction")(method) then
        funcname := SHALLOW_COPY_OBJ(NAME_FUNC(opr));
        APPEND_LIST_INTR(funcname, " ");
        if info <> false then
            APPEND_LIST_INTR(funcname, info);
        else
            APPEND_LIST_INTR(funcname, "method");
        fi;
        SET_NAME_FUNC(method, funcname);
    fi;

    if IS_FUNCTION(rank) and IsBound(HasNameFunction) and
       IsBound(TYPE_FUNCTION_WITH_NAME) and IsBound(TYPE_OPERATION_WITH_NAME) and
       not VAL_GVAR("HasNameFunction")(rank) then
        funcname := "Priority calculation for ";
        APPEND_LIST_INTR(funcname, NAME_FUNC(opr));
        if info <> false then
            APPEND_LIST_INTR(funcname, " ");
            APPEND_LIST_INTR(funcname, info);
        fi;
        SET_NAME_FUNC(rank, funcname);
    fi;

    # Install the method in the operation.
    INSTALL_METHOD_FLAGS( opr, info, rel, flags, rank, method );

    if IsHPCGAP then
        UNLOCK( lk );
    fi;
end );


#############################################################################
##
#M  default attribute getter and setter methods
##
##  The default getter method requires the category part of the attribute's
##  requirements, tests the property getters of the requirements,
##  and --if they are `true' and afterwards stored in the object--
##  calls the attribute operation again.
##  Note that we do *not* install this method for an attribute
##  that requires only categories.
##
##  The default setter method does nothing.
##
LENGTH_SETTER_METHODS_2 := LENGTH_SETTER_METHODS_2 + (BASE_SIZE_METHODS_OPER_ENTRY+2);  # one method

InstallAttributeFunction(
    function ( name, filter, getter, setter, tester, mutflag )

    local flags, rank, cats, props, i, lk;

    if not IS_IDENTICAL_OBJ( filter, IS_OBJECT ) then

        flags := FLAGS_FILTER( filter );
        rank  := 0;
        cats  := IS_OBJECT;
        props := [];
        if IsHPCGAP then
            # TODO: once the GAP compiler supports 'atomic', use that
            # to replace the explicit locking and unlocking here.
            lk := READ_LOCK(FILTER_REGION);
        fi;
        for i in TRUES_FLAGS( flags ) do
            if INFO_FILTERS[i] in FNUM_CATS_AND_REPS  then
                cats := cats and FILTERS[i];
                rank := rank - RankFilter( FILTERS[i] );
            elif INFO_FILTERS[i] in FNUM_PROS  then
                ADD_LIST( props, FILTERS[i] );
            fi;
        od;
        if IsHPCGAP then
            UNLOCK(lk);
        fi;

        # Because the getter function may be called from other
        # threads, <props> needs to be immutable or atomic.
        MakeImmutable(props);

        if 0 < LEN_LIST( props ) then

          # It might be that an object fits to the *first* declaration
          # of the attribute, but that some properties are not yet known.
#T change this, look for *all* declarations of the attribute!
          # If this is the case then we redispatch,
          # otherwise we give up.
          InstallOtherMethod( getter,
              "default method requiring categories and checking properties",
              true,
              [ cats ], rank,
              function ( obj )
              local found, prop;

              found:= false;
              for prop in props do
                if not Tester( prop )( obj ) then
                  found:= true;
                  if not ( prop( obj ) and Tester( prop )( obj ) ) then
                    TryNextMethod();
                  fi;
                fi;
              od;

              if found then
                return getter( obj );
              else
                TryNextMethod();
              fi;
              end );

        fi;
    fi;
    end );

InstallAttributeFunction(
    function ( name, filter, getter, setter, tester, mutflag )
    InstallOtherMethod( setter,
        "default method, does nothing",
        true,
        [ IS_OBJECT, IS_OBJECT ], 0,
            DO_NOTHING_SETTER );
    end );

#############################################################################
##
#F  PositionSortedOddPositions( <list>, <elm> )
##
##  works like PositionSorted, but only looks at odd positions
##  compared with the original algorithm, this translates
##  indices i -> 2*i - 1
##
##  keep function here so it will be compiled
##
BIND_GLOBAL ("PositionSortedOddPositions",
function (list, elm)

    local i, j, k;

    k := LEN_LIST( list ) + 1;
    if k mod 2 = 0 then
        k := k + 1;
    fi;

    i := -1;

    while i + 2 < k do

        # (i < 0 or list[i] < elm) and (k > Length( list ) or list[k] >= elm)

        j := 2 * QUO_INT( i+k+2, 4 ) - 1;
        if list[j] < elm then
            i := j;
        else
            k := j;
        fi;
    od;

    return k;
end);

#############################################################################
##
#F  KeyDependentOperation( <name>, <dom-req>, <key-req>, <key-test> )
##
##  <#GAPDoc Label="KeyDependentOperation">
##  <ManSection>
##  <Func Name="KeyDependentOperation"
##   Arg='name, dom-req, key-req, key-test'/>
##
##  <Description>
##  There are several functions that require as first argument a domain,
##  e.g., a  group, and as second argument something much simpler,
##  e.g., a prime.
##  <Ref Oper="SylowSubgroup"/> is an example.
##  Since its value depends on two arguments, it cannot be an attribute,
##  yet one would like to store the Sylow subgroups once they have been
##  computed.
##  <P/>
##  The idea is to provide an attribute of the group,
##  called <C>ComputedSylowSubgroups</C>,
##  and to store the groups in this list.
##  The name implies that the value of this attribute may change in the
##  course of a &GAP; session,
##  whenever a newly-computed Sylow subgroup is put into the list.
##  Therefore, this is a <E>mutable attribute</E>
##  (see <Ref Sect="Attributes"/>).
##  The list contains primes in each bound odd position and a corresponding
##  Sylow subgroup in the following even position.
##  More precisely, if
##  <C><A>p</A> = ComputedSylowSubgroups( <A>G</A> )[ <A>even</A> - 1 ]</C>
##  then <C>ComputedSylowSubgroups( <A>G</A> )[ <A>even</A> ]</C> holds the
##  value of <C>SylowSubgroup( <A>G</A>, <A>p</A> )</C>.
##  The pairs are sorted in increasing order of <A>p</A>,
##  in particular at most one Sylow <A>p</A> subgroup of <A>G</A> is stored
##  for each prime <A>p</A>.
##  This attribute value is maintained by the function
##  <Ref Oper="SylowSubgroup"/>,
##  which calls the operation <C>SylowSubgroupOp( <A>G</A>, <A>p</A> )</C>
##  to do the real work, if the prime <A>p</A> cannot be found in the list.
##  So methods that do the real work should be installed
##  for <C>SylowSubgroupOp</C>
##  and not for <Ref Oper="SylowSubgroup"/>.
##  <P/>
##  The same mechanism works for other functions as well,
##  e.g., for <Ref Oper="PCore"/>,
##  but also for <Ref Oper="HallSubgroup"/>,
##  where the second argument is not a prime but a set of primes.
##  <P/>
##  <Ref Func="KeyDependentOperation"/> declares the two operations and the
##  attribute as described above,
##  with names <A>name</A>, <A>name</A><C>Op</C>,
##  and <C>Computed</C><A>name</A><C>s</C>, as well as tester and setter operations
##  <C>Has</C><A>name</A> and <C>Set</C><A>name</A>, respectively. Note, however,
##  that the tester is not a filter.
##  <A>dom-req</A> and <A>key-req</A> specify the required filters for the
##  first and second argument of the operation <A>name</A><C>Op</C>,
##  which are needed to create this operation with
##  <Ref Func="DeclareOperation"/>.
##  <A>dom-req</A> is also the required filter for the corresponding
##  attribute <C>Computed</C><A>name</A><C>s</C>.
##  The fourth argument <A>key-test</A> is in general a function to which the
##  second argument
##  <A>info</A> of <C><A>name</A>( <A>D</A>, <A>info</A> )</C> will be
##  passed.
##  This function can perform tests on <A>info</A>,
##  and raise an error if appropriate.
##  <P/>
##  For example, to set up the three objects
##  <Ref Oper="SylowSubgroup"/>,
##  <C>SylowSubgroupOp</C>,
##  <C>ComputedSylowSubgroups</C> together,
##  the declaration file <F>lib/grp.gd</F> contains the following line of
##  code.
##  <Log><![CDATA[
##  KeyDependentOperation( "SylowSubgroup", IsGroup, IsPosInt, "prime" );
##  ]]></Log>
##  In this example, <A>key-test</A> has the value <C>"prime"</C>,
##  which is silently replaced by a function that tests whether its argument
##  is a prime.
##  <P/>
##  <Example><![CDATA[
##  gap> s4 := Group((1,2,3,4),(1,2));;
##  gap> SylowSubgroup( s4, 7 );;  ComputedSylowSubgroups( s4 );
##  [ 7, Group(()) ]
##  gap> SylowSubgroup( s4, 2 );;  ComputedSylowSubgroups( s4 );
##  [ 2, Group([ (3,4), (1,4)(2,3), (1,3)(2,4) ]), 7, Group(()) ]
##  gap> HasSylowSubgroup( s4, 5 );
##  false
##  gap> SetSylowSubgroup( s4, 5, Group(()));; ComputedSylowSubgroups( s4 );
##  [ 2, Group([ (3,4), (1,4)(2,3), (1,3)(2,4) ]), 5, Group(()), 7, Group(()) ]
##  ]]></Example>
##  <P/>
##  <Log><![CDATA[
##  gap> SylowSubgroup( s4, 6 );
##  Error, SylowSubgroup: <p> must be a prime called from
##  <compiled or corrupted call value>  called from
##  <function>( <arguments> ) called from read-eval-loop
##  Entering break read-eval-print loop ...
##  you can 'quit;' to quit to outer loop, or
##  you can 'return;' to continue
##  brk> quit;
##  ]]></Log>
##  <P/>
##  Thus the prime test need not be repeated in the methods for the operation
##  <C>SylowSubgroupOp</C> (which are installed to do
##  the real work).
##  Note that no methods need be installed for
##  <Ref Oper="SylowSubgroup"/> and
##  <C>ComputedSylowSubgroups</C>.
##  If a method is installed with <Ref Func="InstallMethod"/>
##  for a wrapper operation such as
##  <Ref Oper="SylowSubgroup"/> then a warning is signalled
##  provided the <Ref InfoClass="InfoWarning"/> level
##  is at least <C>1</C>.
##  (Use <Ref Func="InstallMethod"/> in order to suppress the
##  warning.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
IsPrimeInt := "2b defined";

BIND_GLOBAL( "KeyDependentOperation",
    function( name, domreq, keyreq, keytest )
    local str, oper, attr, lk;

    if keytest = "prime"  then
      keytest := function( key )
          if not IsPrimeInt( key ) then
            Error( name, ": <p> must be a prime" );
          fi;
      end;
    fi;

    # Create the two-argument operation.
    str:= SHALLOW_COPY_OBJ( name );
    APPEND_LIST_INTR( str, "Op" );

    DeclareOperation( str, [ domreq, keyreq ] );
    oper:= VALUE_GLOBAL( str );

    # Create the mutable attribute and install its default method.
    str:= "Computed";
    APPEND_LIST_INTR( str, name );
    APPEND_LIST_INTR( str, "s" );
    DeclareAttribute( str, domreq, "mutable" );
    attr:= VALUE_GLOBAL( str );

    InstallMethod( attr, "default method", true, [ domreq ], 0, D -> [] );

    # Create the wrapper operation that mainly calls the operation.
    DeclareOperation( name, [ domreq, keyreq ] );

    if IsHPCGAP then
        # TODO: once the GAP compiler supports 'atomic', use that
        # to replace the explicit locking and unlocking here.
        lk := WRITE_LOCK( OPERATIONS_REGION );
    fi;
    ADD_LIST( WRAPPER_OPERATIONS, VALUE_GLOBAL( name ) );
    if IsHPCGAP then
        UNLOCK( lk );
    fi;

    # Install the default method that uses the attribute.
    # (Use `InstallOtherMethod' in order to avoid the warning
    # that is signalled whenever a method is installed for a wrapper.)
    InstallOtherMethod( VALUE_GLOBAL( name ),
        "default method",
        true,
        [ domreq, keyreq ], 0,
        function( D, key )
        local known, i, erg;

        keytest( key );
        known:= attr( D );

        i:= PositionSortedOddPositions( known, key );

        if LEN_LIST( known ) < i or known[i] <> key then
            erg := oper( D, key );

            # re-compute position, just in case the call to oper added to known
            # including the possibility that the result is already stored
            # don't use setter because erg isn't necessarily equal to the stored result
            i:= PositionSortedOddPositions( known, key );
            if LEN_LIST( known ) < i or known[i] <> key then
                known{ [ i + 2 .. LEN_LIST( known ) + 2 ] }:=
                    known{ [ i .. LEN_LIST( known ) ] };
                known[  i  ]:= IMMUTABLE_COPY_OBJ(key);
                known[ i+1 ]:= IMMUTABLE_COPY_OBJ(erg);
            fi;
        fi;
        return known[ i+1 ];
        end );

    # define tester function
    str:= "Has";
    APPEND_LIST_INTR( str, name );
    DeclareOperation( str, [ domreq, keyreq ] );
    InstallOtherMethod( VALUE_GLOBAL( str ),
        "default method",
        true,
        [ domreq, keyreq ], 0,
        function( D, key )

            local known, i;

            keytest( key );
            known:= attr( D );
            i:= PositionSortedOddPositions( known, key );
            return i <= LEN_LIST( known ) and known[i] = key;
        end );
    # define tester function
    str:= "Set";
    APPEND_LIST_INTR( str, name );
    DeclareOperation( str, [ domreq, keyreq, IS_OBJECT ] );
    InstallOtherMethod( VALUE_GLOBAL( str ),
        "default method",
        true,
        [ domreq, keyreq, IS_OBJECT ], 0,
        function( D, key, obj )

            local known, i;

            keytest( key );
            known:= attr( D );
            i:= PositionSortedOddPositions( known, key );
            if LEN_LIST( known ) < i or known[i] <> key then
                known{ [ i + 2 .. LEN_LIST( known ) + 2 ] }:=
                known{ [ i .. LEN_LIST( known ) ] };
                known[  i  ]:= IMMUTABLE_COPY_OBJ(key);
                known[ i+1 ]:= IMMUTABLE_COPY_OBJ(obj);
            fi;
        end );
end );


#############################################################################
##
#F  RedispatchOnCondition( <oper>, <fampred>[, <info>], <reqs>, <cond>, <val> )
##
##  <#GAPDoc Label="RedispatchOnCondition">
##  <ManSection>
##  <Func Name="RedispatchOnCondition" Arg="oper[, info], fampred, reqs, cond, val"/>
##
##  <Description>
##  This function installs a method for the operation <A>oper</A> under the
##  conditions <A>fampred</A> and <A>reqs</A> which has absolute value
##  <A>val</A>;
##  that is, the value of the filters <A>reqs</A> is disregarded.
##  <A>cond</A> is a list of filters.
##  If not all the values of properties involved in these filters are already
##  known for actual arguments of the method,
##  they are explicitly tested and if they are fulfilled <E>and</E> stored
##  after this test, the operation is dispatched again.
##  Otherwise the method exits with <Ref Func="TryNextMethod"/>.
##  If supplied, <A>info</A> should be a short but informative string
##  that describes these conditions.
##  This can be used to enforce tests like
##  <Ref Prop="IsFinite"/> in situations when all
##  existing methods require this property.
##  The list <A>cond</A> may have unbound entries in which case
##  the corresponding argument is ignored for further tests.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
CallFuncList:="2b defined";

BIND_GLOBAL( "RedispatchOnCondition", function(arg)
    local oper,info,fampred,reqs,cond,val,re,i;

    if LEN_LIST(arg) = 5 then
        oper := arg[1];
        info :=" fallback method to test conditions";
        fampred := arg[2];
        reqs := arg[3];
        cond := arg[4];
        val := arg[5];
    elif LEN_LIST(arg) = 6 then
        oper := arg[1];
        info := arg[2];
        fampred := arg[3];
        reqs := arg[4];
        cond := arg[5];
        val := arg[6];
    else
        Error("Usage: RedispatchOnCondition(oper[,info],fampred,reqs,cond,val)");
    fi;

    # force value 0 (unless offset).
    for i in reqs do
      val:=val-RankFilter(i);
    od;

    InstallOtherMethod( oper,
      info,
      fampred,
      reqs, val,
      function( arg )
        re:= false;
        for i in [1..LEN_LIST(reqs)] do
          re:= re or
            (     IsBound( cond[i] )                  # there is a condition,
              and ( not Tester( cond[i] )( arg[i] ) ) # partially unknown,
              and cond[i]( arg[i] )                   # in fact true (here
                                                      # the test is forced),
              and Tester( cond[i] )( arg[i] ) );      # stored after the test
        od;
        if re then
          # at least one property was found out, redispatch
          return CallFuncList(oper,arg);
        else
          TryNextMethod(); # all filters hold already, go away
        fi;
      end);
end);


#############################################################################
##
#M  ViewObj( <obj> )  . . . . . . . . . . . .  default method uses `PrintObj'
##
InstallMethod( ViewObj,
    "default method using `PrintObj'",
    true,
    [ IS_OBJECT ],
    0,
    PRINT_OBJ );

# A dummy version of this function is installed here, the full version
# is defined in attr.gi, after Info-related functionality is set up.
CHECK_REPEATED_ATTRIBUTE_SET := function(obj, name, val) end;
