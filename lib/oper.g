#############################################################################
##
#W  oper.g                      GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                          & Martin Schönert
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file defines operations and such. Some functions have moved
##  to oper1.g so as to be compiled in the default kernel
##


INSTALL_METHOD := false;


#############################################################################
##
#F  INFO_DEBUG( <level>, ... )
##
##  <ManSection>
##  <Func Name="INFO_DEBUG" Arg='level, ...'/>
##
##  <Description>
##  This will delegate to the proper info class <C>InfoDebug</C>
##  as soon as the info classes are available.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "INFO_DEBUG", function( arg )
    Print( "#I  " );
    CALL_FUNC_LIST( Print, arg{ [ 2 .. LEN_LIST( arg ) ] } );
end );


#############################################################################
##
#V  CATS_AND_REPS
##
##  <ManSection>
##  <Var Name="CATS_AND_REPS"/>
##
##  <Description>
##  a list of filter numbers of categories and representations
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "CATS_AND_REPS", [] );
if IsHPCGAP then
    ShareSpecialObj(CATS_AND_REPS);
fi;


#############################################################################
##
#V  IMMEDIATES
##
##  <ManSection>
##  <Var Name="IMMEDIATES"/>
##
##  <Description>
##  is a list that contains at position <M>i</M> the description of all those
##  immediate methods for which <C>FILTERS</C><M>[i]</M> belongs to the
##  requirements.
##  <P/>
##  So each entry of <C>IMMEDIATES</C> is a zipped list, where 6 consecutive
##  positions are ..., and the  position of  the  method itself  in the list
##  <C>IMMEDIATE_METHODS</C>.
##  <P/>
##  Note:
##  1. If a method requires two filters <M>F_1</M> and <M>F_2</M> such that
##     <M>F_1</M> implies <M>F_2</M>,
##     it will <E>not</E> be installed for <M>F_2</M>.
##  2. If not all requirements are categories/representations then
##     the category/representation part of the requirements will be ignored;
##  <!-- and if only cats are required? Does this make sense?-->
##  <!-- and what about representations that may change?-->
##     in other words, the only information that may cause to run immediate
##     methods is acquired information.
##  </Description>
##  </ManSection>
##
if IsHPCGAP then
    BIND_GLOBAL( "IMMEDIATES", AtomicList([]) );
else
    BIND_GLOBAL( "IMMEDIATES", [] );
fi;


#############################################################################
##
#V  IMMEDIATE_METHODS
##
##  <ManSection>
##  <Var Name="IMMEDIATE_METHODS"/>
##
##  <Description>
##  is a list of functions that are installed as immediate methods.
##  </Description>
##  </ManSection>
##
if IsHPCGAP then
    BIND_GLOBAL( "IMMEDIATE_METHODS", AtomicList([]) );
else
    BIND_GLOBAL( "IMMEDIATE_METHODS", [] );
fi;


#############################################################################
##
#V  OPERATIONS
##
##  <ManSection>
##  <Var Name="OPERATIONS"/>
##
##  <Description>
##  is a list that stores all &GAP; operations at the odd positions,
##  and the corresponding list of requirements at the even positions.
##  More precisely, if the operation <C>OPERATIONS[<A>n</A>]</C> has been declared
##  by several calls of <C>DeclareOperation</C>,
##  with second arguments <A>req1</A>, <A>req2</A>, \ldots,
##  each being a list of filters, then <C>OPERATIONS[ <A>n</A>+1 ]</C> is the list
##  <C>[</C> <A>flags1</A>, <A>flags2</A>, <M>\ldots</M>, <C>]</C>,
##  where <A>flagsi</A> is the list of flags of the filters in <A>reqi</A>.
##  </Description>
##  </ManSection>
##
if IsHPCGAP then
    OPERATIONS_REGION := ShareSpecialObj("OPERATIONS_REGION");  # FIXME: remove
    BIND_GLOBAL( "OPERATIONS", MakeStrictWriteOnceAtomic( [] ) );
    BIND_GLOBAL( "OPER_FLAGS", MakeStrictWriteOnceAtomic( rec() ) );
else
    BIND_GLOBAL( "OPERATIONS", [] );
    BIND_GLOBAL( "OPER_FLAGS", rec() );
fi;
BIND_GLOBAL( "STORE_OPER_FLAGS",
function(oper, flags)
  local nr, info;
  nr := MASTER_POINTER_NUMBER(oper);
  if not IsBound(OPER_FLAGS.(nr)) then
    # we need a back link to oper for the post-restore function
    if IsHPCGAP then
        OPER_FLAGS.(nr) := FixedAtomicList([oper,
            MakeWriteOnceAtomic([]), MakeWriteOnceAtomic([])]);
    else
        OPER_FLAGS.(nr) := [oper, [], []];
    fi;
    ADD_LIST(OPERATIONS, oper);
  fi;
  info := OPER_FLAGS.(nr);
  ADD_LIST(info[2], MakeImmutable(flags));
  ADD_LIST(info[3], MakeImmutable([INPUT_FILENAME(), READEVALCOMMAND_LINENUMBER, INPUT_LINENUMBER()]));
end);

BIND_GLOBAL( "GET_OPER_FLAGS", function(oper)
  local nr;
  nr := MASTER_POINTER_NUMBER(oper);
  if not IsBound(OPER_FLAGS.(nr)) then
    return fail;
  fi;
  return OPER_FLAGS.(nr)[2];
end);
BIND_GLOBAL( "GET_DECLARATION_LOCATIONS", function(oper)
  local nr;
  nr := MASTER_POINTER_NUMBER(oper);
  if not IsBound(OPER_FLAGS.(nr)) then
    return fail;
  fi;
  return OPER_FLAGS.(nr)[3];
end);

# the object handles change after loading a workspace
ADD_LIST(GAPInfo.PostRestoreFuncs, function()
  local tmp, a;
  tmp := [];
  for a in REC_NAMES(OPER_FLAGS) do
    ADD_LIST(tmp, OPER_FLAGS.(a));
    Unbind(OPER_FLAGS.(a));
  od;
  for a in tmp do
    OPER_FLAGS.(MASTER_POINTER_NUMBER(a[1])) := a;
  od;
end);

#############################################################################
##
#V  WRAPPER_OPERATIONS
##
##  <ManSection>
##  <Var Name="WRAPPER_OPERATIONS"/>
##
##  <Description>
##  is a list that stores all those &GAP; operations for which the default
##  method is to call a related operation if necessary,
##  and to store and look up the result using an attribute.
##  An example is <C>SylowSubgroup</C>, which calls <C>SylowSubgroupOp</C> if the
##  required Sylow subgroup is not yet stored in <C>ComputedSylowSubgroups</C>.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "WRAPPER_OPERATIONS", [] );
if IsHPCGAP then
    LockAndMigrateObj( WRAPPER_OPERATIONS, OPERATIONS_REGION);
fi;


#############################################################################
##
#F  IsNoImmediateMethodsObject(<obj>)
##
##  <ManSection>
##  <Func Name="IsNoImmediateMethodsObject" Arg='obj'/>
##
##  <Description>
##  If this filter is set immediate methods will be ignored for <A>obj</A>. This
##  can be crucial for performance for objects like PCGS, of which many are
##  created, which are collections, but for which all those immediate
##  methods for <C>IsTrivial</C> et cetera do not really make sense.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL("IsNoImmediateMethodsObject",
  NewFilter("IsNoImmediateMethodsObject"));


#############################################################################
##
#V  IGNORE_IMMEDIATE_METHODS
##
##  <ManSection>
##  <Var Name="IGNORE_IMMEDIATE_METHODS"/>
##
##  <Description>
##  is usually <K>false</K>.
##  Only inside a call of <C>RunImmediateMethods</C> it is set to
##  <K>true</K>,
##  which causes that <C>RunImmediateMethods</C> does not suffer
##  from recursion.
##  </Description>
##  </ManSection>
##
IGNORE_IMMEDIATE_METHODS := false;


#############################################################################
##
#F  INSTALL_IMMEDIATE_METHOD( <oper>, <info>, <filter>, <rank>, <method> )
##
##  <ManSection>
##  <Func Name="INSTALL_IMMEDIATE_METHOD" Arg='oper, info, filter, rank, method'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_CONSTANT("SIZE_IMMEDIATE_METHOD_ENTRY", 8);
BIND_GLOBAL( "INSTALL_IMMEDIATE_METHOD",
    function( oper, info, filter, rank, method )

    local   flags,
            relev,
            i,
            rflags,
            wif,
            ignore,
            j,
            k,
            replace,
            pos,
            imm;

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
        if not INFO_FILTERS[i] in FNUM_CATS_AND_REPS  then
            ADD_LIST( relev, i );
        fi;
    od;

    # All requirements are categories/representations.
    # Install the method for one of them.
    if LEN_LIST( relev ) = 0  then
        relev:= [ flags[1] ];
    fi;
    flags:= relev;

    atomic FILTER_REGION do

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
    if IsHPCGAP then
        # 'pos' is saved for modifying 'imm' below.
        pos:=AddAtomicList( IMMEDIATE_METHODS, method );
    else
        ADD_LIST( IMMEDIATE_METHODS, method );
        pos := LEN_LIST( IMMEDIATE_METHODS );
    fi;

    for j  in relev  do

      # adjust `IMM_FLAGS'
      IMM_FLAGS:= SUB_FLAGS( IMM_FLAGS, FLAGS_FILTER( FILTERS[j] ) );
#T here it would be better to subtract a flag list
#T with `true' exactly at position `j'!
#T means: When an immed. method gets installed for a property then
#T the property tester should remain in IMM_FLAGS.
#T (This would make an if statement in `RunImmediateMethods' unnecessary!)

      # Find the place to put the new method.
      if not IsHPCGAP then
          if IsBound( IMMEDIATES[j] ) then
              imm := IMMEDIATES[j];
          else
              imm := [];
              IMMEDIATES[j] := imm;
          fi;
      else
          if IsBound( IMMEDIATES[j] ) then
              imm := SHALLOW_COPY_OBJ(IMMEDIATES[j]);
          else
              imm := [];
          fi;
      fi;
      i := 0;
      while i < LEN_LIST(imm) and rank < imm[i+5]  do
          i := i + SIZE_IMMEDIATE_METHOD_ENTRY;
      od;

      # Now is a good time to see if the method is already there 
      if REREADING then
          replace := false;
          k := i;
          while k < LEN_LIST(imm) and rank = imm[k+5] do
              if info = imm[k+7] and oper = imm[k+1] and
                 FLAGS_FILTER( filter ) = imm[k+4] then
                  replace := true;
                  i := k;
                  break;
              fi;
              k := k+SIZE_IMMEDIATE_METHOD_ENTRY;
          od;
      fi;
      
      # push the other functions back
      if not REREADING or not replace then
          imm{[SIZE_IMMEDIATE_METHOD_ENTRY+i+1..SIZE_IMMEDIATE_METHOD_ENTRY+LEN_LIST(imm)]} := imm{[i+1..LEN_LIST(imm)]};
      fi;

      # install the new method
      imm[i+1] := oper;
      imm[i+2] := SETTER_FILTER( oper );
      imm[i+3] := FLAGS_FILTER( TESTER_FILTER( oper ) );
      imm[i+4] := FLAGS_FILTER( filter );
      imm[i+5] := rank;
      imm[i+6] := pos;
      imm[i+7] := IMMUTABLE_COPY_OBJ(info);
      if SIZE_IMMEDIATE_METHOD_ENTRY >= 8 then
          imm[i+8] := MakeImmutable([INPUT_FILENAME(), READEVALCOMMAND_LINENUMBER, INPUT_LINENUMBER()]);
      fi;

      if IsHPCGAP then
          IMMEDIATES[j]:=MakeImmutable(imm);
      fi;
    od;
    od;

end );


#############################################################################
##
#F  InstallImmediateMethod( <opr>[, <info>], <filter>[, <rank>], <method> )
##
##  <#GAPDoc Label="InstallImmediateMethod">
##  <ManSection>
##  <Func Name="InstallImmediateMethod"
##   Arg='opr[, info], filter, rank, method'/>
##
##  <Description>
##  <Ref Func="InstallImmediateMethod"/> installs <A>method</A> as an
##  immediate method for <A>opr</A>, which must be an attribute or a
##  property, with requirement <A>filter</A> and rank <A>rank</A>
##  (the rank can be omitted, in which case 0 is used as rank).
##  The rank must be an integer value that measures the priority of
##  <A>method</A> among the immediate methods for <A>opr</A>.
##  If supplied, <A>info</A> should be a short but informative string
##  that describes the situation in which the method is called.
##  <P/>
##  An immediate method is called automatically as soon as the object lies 
##  in <A>filter</A>, provided that the value is not yet known.
##  Afterwards the attribute setter is called in order to store the value, 
##  unless the method exits via <Ref Func="TryNextMethod"/>.
##  <P/>
##  Note the difference to <Ref Func="InstallMethod"/>
##  that no family predicate occurs
##  because <A>opr</A> expects only one argument,
##  and that <A>filter</A> is not a list of requirements but the argument
##  requirement itself.
##  <P/>
##  Immediate methods are thought of as a possibility for objects to gain
##  useful knowledge.
##  They must not be used to force the storing of <Q>defining information</Q>
##  in an object.
##  In other words, &GAP; should work even if all immediate methods are
##  completely disabled.
##  Therefore, the call to <Ref Func="InstallImmediateMethod"/> installs
##  <A>method</A> also as an ordinary method for <A>opr</A>
##  with requirement <A>filter</A>.
##  <P/>
##  Note that in such a case &GAP; executes a computation for which
##  it was not explicitly asked by the user.
##  So one should install only those methods as immediate methods
##  that are <E>extremely cheap</E>.
##  To emphasize this,
##  immediate methods are also called <E>zero cost methods</E>.
##  The time for their execution should really be approximately zero.
##  <P/>
##  For example, the size of a permutation group can be computed very cheaply
##  if a stabilizer chain of the group is known.
##  So it is reasonable to install an immediate method for
##  <Ref Func="Size"/> with requirement
##  <C>IsGroup and Tester( <A>stab</A> )</C>,
##  where <A>stab</A> is the attribute corresponding to the stabilizer chain.
##  <P/>
##  Another example would be the implementation of the conclusion that
##  every finite group of prime power order is nilpotent.
##  This could be done by installing an immediate method for the attribute
##  <Ref Func="IsNilpotentGroup"/> with requirement
##  <C>IsGroup and Tester( Size )</C>.
##  This method would then check whether the size is a finite prime power,
##  return <K>true</K> in this case and otherwise call
##  <Ref Func="TryNextMethod"/>.
##  But this requires factoring of an integer,
##  which cannot be guaranteed to be very cheap,
##  so one should not install this method as an immediate method.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "InstallImmediateMethod", function( arg )
    local pos, opr, info, filter, rank, method;

    pos := 1;

    if pos <= LEN_LIST( arg ) and IS_OPERATION( arg[pos] ) then
        opr := arg[pos];
        pos := pos + 1;
    else
        pos := -1;
    fi;

    if pos <= LEN_LIST( arg ) and IS_STRING( arg[pos] ) then
        info := arg[pos];
        pos := pos + 1;
    else
        info := false;
    fi;

    if pos <= LEN_LIST( arg ) and IsFilter( arg[pos] ) then
        filter := arg[pos];
        pos := pos + 1;
    else
        pos := -1;
    fi;

    if pos <= LEN_LIST( arg ) and IS_RAT( arg[pos] ) then
        rank := arg[pos];
        pos := pos + 1;
    else
        rank := 0;
    fi;

    if pos <= LEN_LIST( arg ) and IS_FUNCTION( arg[pos] ) then
        method := arg[pos];
        pos := pos + 1;
    else
        pos := -1;
    fi;

    if pos = LEN_LIST( arg ) + 1 then
        INSTALL_IMMEDIATE_METHOD( opr, info, filter, rank, method );
        INSTALL_METHOD( [ opr, info, [ filter ], method ], false );
    else
        Error("usage: InstallImmediateMethod( <opr>[, <info>], <filter>, <rank>, <method> )");
    fi;

end );


#############################################################################
##
#F  TraceImmediateMethods( <flag> )
##
##  <#GAPDoc Label="TraceImmediateMethods">
##  <ManSection>
##  <Func Name="TraceImmediateMethods" Arg='[flag]'/>
##  <Func Name="UntraceImmediateMethods" Arg=''/>
##
##  <Description>
##  <Ref Func="TraceImmediateMethods"/> enables tracing for all immediate methods
##  if <A>flag</A> is either <K>true</K>, or not present.
##  <Ref Func="UntraceImmediateMethods"/>, or <Ref Func="TraceImmediateMethods"/>
##  with <A>flag</A> equal <K>false</K> turns tracing off.
##  (There is no facility to trace <E>specific</E> immediate methods.)
##  <Log><![CDATA[
##  gap> TraceImmediateMethods( );
##  gap> g:= Group( (1,2,3), (1,2) );;
##  #I RunImmediateMethods
##  #I  immediate: Size
##  #I  immediate: IsCyclic
##  #I  immediate: IsCommutative
##  #I  immediate: IsTrivial
##  gap> Size( g );
##  #I  immediate: IsPerfectGroup
##  #I  immediate: IsNonTrivial
##  #I  immediate: Size
##  #I  immediate: IsFreeAbelian
##  #I  immediate: IsTorsionFree
##  #I  immediate: IsNonTrivial
##  #I  immediate: IsPerfectGroup
##  #I  immediate: GeneralizedPcgs
##  #I  immediate: IsEmpty
##  6
##  gap> UntraceImmediateMethods( );
##  gap> UntraceMethods( [ Size ] );
##  ]]></Log>
##  <P/>
##  This example gives an explanation for the two calls of the
##  <Q>system getter</Q> for <Ref Func="Size"/>.
##  Namely, there are immediate methods that access the known size
##  of the group.
##  Note that the group <C>g</C> was known to be finitely generated already
##  before the size was computed,
##  the calls of the immediate method for
##  <Ref Func="IsFinitelyGeneratedGroup"/> after the call of
##  <Ref Func="Size"/> have other arguments than <C>g</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
TRACE_IMMEDIATE_METHODS := false;

BIND_GLOBAL( "UntraceImmediateMethods", function ()
    TRACE_IMMEDIATE_METHODS := false;
end );

BIND_GLOBAL( "TraceImmediateMethods", function( arg )
    if LENGTH(arg) = 0 then
        TRACE_IMMEDIATE_METHODS := true;
        return;
    fi;

    if LENGTH(arg) > 1 or not IS_BOOL(arg[1]) then
      Error("Usage: TraceImmediateMethods( [bool] )");
    fi;

    if arg[1] then
        TRACE_IMMEDIATE_METHODS := true;
    else
        TRACE_IMMEDIATE_METHODS := false;
    fi;
end );


#############################################################################
##
#F  NewOperation( <name>, <args-filts> )
##
##  <#GAPDoc Label="NewOperation">
##  <ManSection>
##  <Func Name="NewOperation" Arg='name, args-filts'/>
##
##  <Description>
##  <Ref Func="NewOperation"/> returns an operation <A>opr</A> with name
##  <A>name</A>.
##  The list <A>args-filts</A> describes requirements about the arguments
##  of <A>opr</A>, namely the number of arguments must be equal to the length
##  of <A>args-filts</A>, and the <M>i</M>-th argument must lie in the filter
##  <A>args-filts</A><M>[i]</M>.
##  <P/>
##  Each method that is installed for <A>opr</A> via
##  <Ref Func="InstallMethod"/> must require that the <M>i</M>-th argument
##  lies in the filter <A>args-filts</A><M>[i]</M>.
##  <P/>
##  One can install methods for other argument tuples via
##  <Ref Func="InstallOtherMethod"/>,
##  this way it is also possible to install methods for a different number
##  of arguments than the length of <A>args-filts</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "NewOperation", function ( name, filters )
    local   oper,  filt,  filter;

    if GAPInfo.MaxNrArgsMethod < LEN_LIST( filters ) then
      Error( "methods can have at most ", GAPInfo.MaxNrArgsMethod,
             " arguments" );
    fi;
    oper := NEW_OPERATION( name );
    filt := [];
    for filter  in filters  do
        if not IS_OPERATION( filter ) then
          Error( "<filter> must be an operation" );
        fi;
        ADD_LIST( filt, FLAGS_FILTER( filter ) );
    od;
    STORE_OPER_FLAGS(oper, filt);
    return oper;
end );


#############################################################################
##
#F  NewConstructor( <name>, <filters> )
##
##  <#GAPDoc Label="NewConstructor">
##  <ManSection>
##  <Func Name="NewConstructor" Arg='name, args-filts'/>
##
##  <Description>
##  <Ref Func="NewConstructor"/> returns a constructor <A>cons</A> with name
##  <A>name</A>.
##  The list <A>args-filts</A> describes requirements about the arguments
##  of <A>cons</A>. Namely the number of arguments must be equal to the length
##  of <A>args-filts</A>, and the <M>i</M>-th argument
##  must lie in the filter <A>args-filts</A><M>[i]</M> for <M>i \neq 1</M>.
##  A constructor expects the first argument to be a <E>filter</E> instead
##  of an object and it must be a subset of the filter
##  <A>args-filts</A><M>[1]</M>.
##  <P/>
##  Each method that is installed for <A>cons</A> via
##  <Ref Func="InstallMethod"/> must require that
##  the <M>i</M>-th argument lies in the filter <A>args-filts</A><M>[i]</M>
##  for <M>i \neq 1</M>.
##  Its first argument is a filter and must be a subset of the filter
##  <A>args-filts</A><M>[1]</M>.
##  <P/>
##  One can install methods for other argument tuples via
##  <Ref Func="InstallOtherMethod"/>,
##  this way it is also possible to install methods for a different number
##  of arguments than the length of <A>args-filts</A>.
##  <P/>
##  Note that the method selection for constructors works slightly differently
##  than for usual operations.
##  As stated above, applicabilty to the first argument in an argument tuple
##  is tested by determining whether the argument-filter is a <E>subset</E> of
##  <A>args-filts</A><M>[1]</M>.
##  <P/>
##  The rank of a method installed for a constructor is determined solely by
##  <A>args-filts</A><M>[1]</M> of the method.
##  Instead of taking the sum of the ranks of filters involved in its
##  <A>args-filts</A><M>[1]</M>, the sum of <M>-1</M> times these values
##  is taken.
##  The result is added to the number <A>val</A> used in the call of
##  <Ref Func="InstallMethod"/>.
##  <P/>
##  This has the following effects on the method selection for constructors.
##  If <A>cons</A> is called with an argument tuple whose first argument is
##  the filter <A>filt</A>, any method whose first argument is
##  <E>more</E> specific than <A>filt</A> is applicable
##  (if its other <A>args-filts</A> also match).
##  Then the method with the <Q>most general</Q> filter <A>args-filts</A><M>[1]</M>
##  is chosen, since the rank is computed by taking <M>-1</M> times the ranks
##  of the involved filters.
##  Thus, a constructor is chosen which returns an object in <A>filt</A> using
##  as few extra filters as possible, which presumably is both more flexible
##  to use and easier to construct.
##  <P/>
##  The following example showcases this behaviour.
##  Note that the argument <A>filter</A> is only used for method dispatch.
##  <Log><![CDATA[
##  DeclareFilter( "IsMyObj" );
##  DeclareFilter( "IsMyFilter" );
##  DeclareFilter( "IsMyOtherFilter" );
##  BindGlobal( "MyFamily", NewFamily( "MyFamily" ) );
##  
##  DeclareConstructor( "NewMyObj", [ IsMyObj ] );
##  
##  InstallMethod( NewMyObj,
##  [ IsMyObj ],
##  function( filter )
##      local type;
##      Print("General constructor\n");
##      type := NewType( MyFamily, IsMyObj );
##      return Objectify( type, [] );
##  end );
##  InstallMethod( NewMyObj,
##  [ IsMyObj and IsMyFilter and IsMyOtherFilter ],
##  function( filter )
##      local type;
##      Print("Special constructor\n");
##      type := NewType( MyFamily, IsMyObj and IsMyFilter and IsMyOtherFilter );
##      return Objectify( type, [] );
##  end );
##  ]]></Log>
##  If only IsMyObj is given, both methods are applicable and the general
##  constructor is called.
##  If also IsMyFilter is given, only the special constructor is applicable.
##  <Log><![CDATA[
##  gap> a := NewMyObj( IsMyObj );;
##  General constructor
##  gap> IsMyOtherFilter(a);
##  false
##  gap> b := NewMyObj( IsMyObj and IsMyFilter );;
##  Special constructor
##  gap> IsMyOtherFilter(b);
##  true
##  gap> c := NewMyObj( IsMyObj and IsMyFilter and IsMyOtherFilter );;
##  Special constructor
##  gap> IsMyOtherFilter(c);
##  true
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "NewConstructor", function ( name, filters )
    local   oper,  filt,  filter;

    if LEN_LIST( filters ) = 0 then
      Error( "constructors must have at least one argument" );
    fi;
    if GAPInfo.MaxNrArgsMethod < LEN_LIST( filters ) then
      Error( "methods can have at most ", GAPInfo.MaxNrArgsMethod,
             " arguments" );
    fi;
    oper := NEW_CONSTRUCTOR( name );
    filt := [];
    for filter  in filters  do
        if not IS_OPERATION( filter ) then
          Error( "<filter> must be an operation" );
        fi;
        ADD_LIST( filt, FLAGS_FILTER( filter ) );
    od;
    STORE_OPER_FLAGS(oper, filt);
    return oper;
end );


#############################################################################
##
#F  DeclareOperation( <name>, <filters> )
##
##  <#GAPDoc Label="DeclareOperation">
##  <ManSection>
##  <Func Name="DeclareOperation" Arg='name, filters'/>
##
##  <Description>
##  does the same as <Ref Func="NewOperation"/> and
##  additionally makes the variable <A>name</A> read-only.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "DeclareOperation", function ( name, filters )
    local gvar, pos, req, filt, filter;

    if   GAPInfo.MaxNrArgsMethod < LEN_LIST( filters ) then
      Error( "methods can have at most ", GAPInfo.MaxNrArgsMethod,
             " arguments" );
    elif ISB_GVAR( name ) then

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
        if pos = fail then

          # `gvar' is an attribute.
          Error( "operation `", name,
                 "' was created as an attribute, use `DeclareAttribute'" );

        elif    INFO_FILTERS[ pos ] in FNUM_TPRS
             or INFO_FILTERS[ pos ] in FNUM_ATTS then

          # `gvar' is an attribute tester or property tester.
          Error( "operation `", name,
                 "' is an attribute tester or property tester" );

        else

          # `gvar' is a property.
          Error( "operation `", name,
                 "' was created as a property, use `DeclareProperty'" );

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
      
      req := GET_OPER_FLAGS(gvar);
      if IsHPCGAP then
        req := FromAtomicList(req);  # so that we can search in it
      fi;
      if filt in req then
        if not REREADING then
          INFO_DEBUG( 1, "equal requirements in multiple declarations ",
              "for operation `", name, "'\n" );
        fi;
      else
        STORE_OPER_FLAGS( gvar, filt );
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
##  <ManSection>
##  <Func Name="DeclareOperationKernel" Arg='name, filters, kernel-oper'/>
##
##  <Description>
##  This function must not be used to re-declare an operation
##  that has already been declared.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "DeclareOperationKernel", function ( name, filters, oper )
    local   filt,  filter;

    if GAPInfo.MaxNrArgsMethod < LEN_LIST( filters ) then
      Error( "methods can have at most ", GAPInfo.MaxNrArgsMethod,
             " arguments" );
    fi;

    # This will yield an error if `name' is already bound.
    BIND_GLOBAL( name, oper );
    SET_NAME_FUNC( oper, name );

    filt := [];
    for filter  in filters  do
        if not IS_OPERATION( filter ) then
          Error( "<filter> must be an operation" );
        fi;
        ADD_LIST( filt, FLAGS_FILTER( filter ) );
    od;

    STORE_OPER_FLAGS(oper, filt);
end );


#############################################################################
##
#F  DeclareConstructor( <name>, <filters> )
##
##  <#GAPDoc Label="DeclareConstructor">
##  <ManSection>
##  <Func Name="DeclareConstructor" Arg='name, filters'/>
##
##  <Description>
##  does the same as <Ref Func="NewConstructor"/> and
##  additionally makes the variable <A>name</A> read-only.
##  <P/>
##  Note that for operations which are constructors special rules with respect
##  to applicability and rank of the corresponding methods apply
##  (see section <Ref Func="NewConstructor"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "DeclareConstructor", function ( name, filters )

    local gvar, req, filt, filter;

    if LEN_LIST( filters ) = 0 then
      Error( "constructors must have at least one argument" );
    elif GAPInfo.MaxNrArgsMethod < LEN_LIST( filters ) then
      Error( "methods can have at most ", GAPInfo.MaxNrArgsMethod,
             " arguments" );
    elif ISB_GVAR( name ) then

      gvar:= VALUE_GLOBAL( name );

      # Check that the variable is in fact an operation.
      if not IS_OPERATION( gvar ) then
        Error( "variable `", name, "' is not bound to an operation" );
      fi;

      # The constructor has already been declared.
      # If it was not created as a constructor
      # then ask for re-declaration as an ordinary operation.
      if not IS_CONSTRUCTOR(gvar) then
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

      STORE_OPER_FLAGS( gvar, filt );

    else

      # The operation is new.
      BIND_GLOBAL( name, NewConstructor( name, filters ) );

    fi;
end );


#############################################################################
##
#F  DeclareConstructorKernel( <name>, <filter>, <kernel-oper> )
##
##  <ManSection>
##  <Func Name="DeclareConstructorKernel" Arg='name, filter, kernel-oper'/>
##
##  <Description>
##  This function must not be used to re-declare a constructor
##  that has already been declared.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "DeclareConstructorKernel", function ( name, filters, oper )
    local   filt,  filter;

    if GAPInfo.MaxNrArgsMethod < LEN_LIST( filters ) then
      Error( "methods can have at most ", GAPInfo.MaxNrArgsMethod,
             " arguments" );
    fi;

    # This will yield an error if `name' is already bound.
    BIND_GLOBAL( name, oper );
    SET_NAME_FUNC( oper, name );

    filt := [];
    for filter  in filters  do
        if not IS_OPERATION( filter ) then
          Error( "<filter> must be an operation" );
        fi;
        ADD_LIST( filt, FLAGS_FILTER( filter ) );
    od;

    STORE_OPER_FLAGS(oper, filt);
end );


#############################################################################
##
#F  InstallAttributeFunction( <func> )  . . . run function for each attribute
##
##  <ManSection>
##  <Func Name="InstallAttributeFunction" Arg='func'/>
##
##  <Description>
##  <C>InstallAttributeFunction</C> installs <A>func</A>, so that
##  <C><A>func</A>( <A>name</A>, <A>filter</A>, <A>getter</A>, <A>setter</A>, <A>tester</A>, <A>mutflag</A> )</C>
##  is called for each attribute.
##  </Description>
##  </ManSection>
##
if IsHPCGAP then
    BIND_GLOBAL( "ATTRIBUTES", MakeStrictWriteOnceAtomic( [] ) );
    BIND_GLOBAL( "ATTR_FUNCS", MakeStrictWriteOnceAtomic( [] ) );
else
    BIND_GLOBAL( "ATTRIBUTES", [] );
    BIND_GLOBAL( "ATTR_FUNCS", [] );
fi;

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
    ADD_LIST( ATTRIBUTES,
        MakeImmutable( [ name, filter, getter, setter, tester, mutflag ] ) );
end );


#############################################################################
##
BIND_GLOBAL( "BIND_SETTER_TESTER",
function( name, setter, tester)
    local nname;
    nname:= "Set"; APPEND_LIST_INTR( nname, name );
    BIND_GLOBAL( nname, setter );
    nname:= "Has"; APPEND_LIST_INTR( nname, name );
    BIND_GLOBAL( nname, tester );
end );


#############################################################################
##
#F  DeclareAttributeKernel( <name>, <filter>, <getter> )  . . . new attribute
##
##  <ManSection>
##  <Func Name="DeclareAttributeKernel" Arg='name, filter, getter'/>
##
##  <Description>
##  This function must not be used to re-declare an attribute
##  that has already been declared.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "DeclareAttributeKernel", function ( name, filter, getter )
    local setter, tester;

    # This will yield an error if `name' is already bound.
    BIND_GLOBAL( name, getter );
    SET_NAME_FUNC( getter, name );

    # construct setter and tester
    setter := SETTER_FILTER( getter );
    tester := TESTER_FILTER( getter );

    # add getter, setter and tester to the list of operations
    STORE_OPER_FLAGS(getter, [ FLAGS_FILTER(filter) ]);
    STORE_OPER_FLAGS(setter, [ FLAGS_FILTER(filter), FLAGS_FILTER(IS_OBJECT) ]);
    STORE_OPER_FLAGS(tester, [ FLAGS_FILTER(filter) ]);

    # store the information about the filter
    atomic FILTER_REGION do
    FILTERS[ FLAG2_FILTER( tester ) ] := tester;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( tester ) );
    INFO_FILTERS[ FLAG2_FILTER( tester ) ] := 5;
    od;

    # clear the cache because <filter> is something old
    if not GAPInfo.CommandLineOptions.N then
      InstallHiddenTrueMethod( filter, tester );
    fi;
    CLEAR_HIDDEN_IMP_CACHE( tester );

    # run the attribute functions
    RUN_ATTR_FUNCS( filter, getter, setter, tester, false );

    # store the ranks
    atomic FILTER_REGION do
    RANK_FILTERS[ FLAG2_FILTER( tester ) ] := 1;
    od;

    # and make the remaining assignments
    BIND_SETTER_TESTER( name, setter, tester );

end );


#############################################################################
##
#F  NewAttribute( <name>, <filter>[, <mutable>][, <rank>] ) . . new attribute
##
##  <#GAPDoc Label="NewAttribute">
##  <ManSection>
##  <Func Name="NewAttribute" Arg='name, filter[, "mutable"][, rank]'/>
##
##  <Description>
##  <Ref Func="NewAttribute"/> returns a new attribute getter with name
##  <A>name</A> that is applicable to objects with the property
##  <A>filter</A>.
##  <P/>
##  Contrary to the situation with categories and representations,
##  the tester of the new attribute does <E>not</E> imply <A>filter</A>.
##  This is exactly because of the possibility to install methods
##  that do not require <A>filter</A>.
##  <P/>
##  For example, the attribute <Ref Func="Size"/> was created
##  with second argument a list or a collection,
##  but there is also a method for <Ref Func="Size"/> that is
##  applicable to a character table,
##  which is neither a list nor a collection.
##  <P/>
##  For the optional third and fourth arguments, there are the following
##  possibilities.
##  <List>
##  <Item> The integer argument <A>rank</A> causes the attribute tester to have
##  this incremental rank (see&nbsp;<Ref Sect="Filters"/>),
##  </Item>
##  <Item> If the argument <A>mutable</A> is the string <C>"mutable"</C> or
##  the boolean <C>true</C>, then the values of the attribute are mutable.
##  </Item>
##  <Item> If the argument <A>mutable</A> is the boolean <C>false</C>, then
##  the values of the attribute are immutable.
##  </Item>
##  </List>
##  <P/>
##  When a value of such mutable attribute is set
##  then this value itself is stored, not an immutable copy of it, 
##  and it is the user's responsibility to set an object that is mutable.
##  This is useful for an attribute whose value is some partial information
##  that may be completed later.
##  For example, there is an attribute <C>ComputedSylowSubgroups</C>
##  for the list holding those Sylow subgroups of a group that have been
##  computed already by the function
##  <Ref Func="SylowSubgroup"/>,
##  and this list is mutable because one may want to enter groups into it
##  as they are computed.
##  <!-- in the current implementation, one can overwrite values of mutable-->
##  <!-- attributes; is this really intended?-->
##  <!-- if yes then it should be documented!-->
##  <P/>
##  If no argument for <A>rank</A> is given, then the rank of the tester is 1.
##  <P/>
##  Each method for the new attribute that does <E>not</E> require
##  its argument to lie in <A>filter</A> must be installed using
##  <Ref Func="InstallOtherMethod"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "OPER_SetupAttribute", function(getter, flags, mutflag, filter, rank, name)
    local   setter,  tester,   nname;
              # store the information about the filter
          INFO_FILTERS[ FLAG2_FILTER(getter) ] := 6;

          # add  setter and tester to the list of operations
          setter := SETTER_FILTER( getter );
          tester := TESTER_FILTER( getter );

          STORE_OPER_FLAGS(setter, [ flags, FLAGS_FILTER( IS_OBJECT ) ]);
          STORE_OPER_FLAGS(tester, [ flags ]);

          # install the default functions
          FILTERS[ FLAG2_FILTER( tester ) ] := tester;
          IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( tester ) );

          # the <tester> is newly made, therefore  the cache cannot contain a  flag
          # list involving <tester>
          if not GAPInfo.CommandLineOptions.N then
            InstallHiddenTrueMethod( filter, tester );
          fi;
          # CLEAR_HIDDEN_IMP_CACHE();

          # run the attribute functions
          RUN_ATTR_FUNCS( filter, getter, setter, tester, mutflag );

          # store the rank
          RANK_FILTERS[ FLAG2_FILTER( tester ) ] := rank;
          
          
          return;
      end);

# construct getter, setter and tester
BIND_GLOBAL( "NewAttribute", function ( name, filter, args... )
    local  flags, mutflag, getter, rank;

    if not IS_STRING( name ) then
        Error( "<name> must be a string");
    fi;

    if not IsFilter( filter ) then
        Error( "<filter> must be a filter" );
    fi;

    rank := 1;
    mutflag := false;
    if LEN_LIST(args) = 0 then
        # this is fine, but does nothing
    elif LEN_LIST(args) = 1 and args[1] in [ "mutable", true, false ] then
        mutflag := args[1] in [ "mutable", true];
    elif LEN_LIST(args) = 1 and IS_INT(args[1]) then
        rank := args[1];
    elif LEN_LIST(args) = 2
         and args[1] in [ "mutable", true, false ]
         and IS_INT(args[2]) then
        mutflag := args[1] in [ "mutable", true ];
        rank := args[2];
    else
        Error("Usage: NewAttribute( <name>, <filter>[, <mutable>][, <rank>] )");
    fi;

    flags:= FLAGS_FILTER( filter );

    # construct a new attribute
    if mutflag then
        getter := NEW_MUTABLE_ATTRIBUTE( name );
    else
        getter := NEW_ATTRIBUTE( name );
    fi;
    STORE_OPER_FLAGS(getter, [ flags ]);

    atomic FILTER_REGION do
    OPER_SetupAttribute(getter, flags, mutflag, filter, rank, name);
    od;

    # And return the getter
    return getter;
end );


#############################################################################
##
#F  DeclareAttribute( <name>, <filter>[, "mutable"][, <rank>] ) new attribute
##
##  <#GAPDoc Label="DeclareAttribute">
##  <ManSection>
##  <Func Name="DeclareAttribute" Arg='name, filter[, "mutable"][, rank]'/>
##
##  <Description>
##  does the same as <Ref Func="NewAttribute"/>,
##  additionally makes the variable <A>name</A> read-only
##  and also binds read-only global variables with names
##  <C>Has<A>name</A></C> and <C>Set<A>name</A></C>
##  for the tester and setter of the attribute (see Section
##  <Ref Sect="Setter and Tester for Attributes"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

BIND_GLOBAL( "ConvertToAttribute",
function(name, op, filter, rank, mutable)
    local req, reqs, flags;
    # `op' is not an attribute (tester) and not a property (tester),
    # or `op' is a filter; in any case, `op' is not an attribute.

    # if `op' has no one argument declarations we can turn it into 
    # an attribute
    req := GET_OPER_FLAGS(op);
    for reqs in req do
        if LENGTH(reqs)  = 1 then
            Error( "operation `", name, "' has been declared as a one ",
                   "argument Operation and cannot also be an Attribute");
        fi;
    od;

    flags := FLAGS_FILTER(filter);
    STORE_OPER_FLAGS( op, [ FLAGS_FILTER( filter ) ] );

    # kernel magic for the conversion
    if mutable then
        OPER_TO_MUTABLE_ATTRIBUTE(op);
    else
        OPER_TO_ATTRIBUTE(op);
    fi;

    OPER_SetupAttribute(op, flags, mutable, filter, rank, name);

    # and make the remaining assignments
    BIND_SETTER_TESTER( name, SETTER_FILTER(op), TESTER_FILTER(op) );
end);

BIND_GLOBAL( "DeclareAttribute", function ( name, filter, args... )
    local gvar, req, reqs, setter, tester,
              attr, mutflag, flags, rank;

    if not IS_STRING( name ) then
        Error( "<name> must be a string");
    fi;

    if not IsFilter( filter ) then
        Error( "<filter> must be a filter" );
    fi;

    rank := 1;
    mutflag := false;
    if LEN_LIST(args) = 0 then
        # this is fine, but does nothing
    elif LEN_LIST(args) = 1 and args[1] in [ "mutable", true, false ] then
        mutflag := args[1] in [ "mutable", true];
    elif LEN_LIST(args) = 1 and IS_INT(args[1]) then
        rank := args[1];
    elif LEN_LIST(args) = 2
         and args[1] in [ "mutable", true, false ]
         and IS_INT(args[2]) then
        mutflag := args[1] in [ "mutable", true ];
        rank := args[2];
    else
        Error("Usage: DeclareAttribute( <name>, <filter>[, <mutable>][, <rank>] )");
    fi;

    if ISB_GVAR( name ) then
      atomic FILTER_REGION do
        # The variable exists already.
        gvar := VALUE_GLOBAL( name );

        # Check that the variable is in fact bound to an operation.
        if not IS_OPERATION( gvar ) then
            Error( "variable `", name, "' is not bound to an operation" );
        fi;

        # The attribute has already been declared.
        # If it was not created as an attribute
        # then we may be able to convert it
        if FLAG2_FILTER( gvar ) = 0 or IS_ELEMENTARY_FILTER(gvar) then
            ConvertToAttribute(name, gvar, filter, rank, mutflag);
        else
            STORE_OPER_FLAGS( gvar, [ FLAGS_FILTER( filter ) ] );

            # also set the extended range for the setter
            req := GET_OPER_FLAGS( Setter(gvar) );
            STORE_OPER_FLAGS( Setter(gvar), [ FLAGS_FILTER( filter), req[1][2] ] );
        fi;
      od;
    else
        # The attribute is new.
        attr := NewAttribute(name, filter, mutflag, rank);
        BIND_GLOBAL( name, attr );

        # and make the remaining assignments
        BIND_SETTER_TESTER( name, SETTER_FILTER(attr), TESTER_FILTER(attr) );
    fi;
end );


#############################################################################
##
#V  LENGTH_SETTER_METHODS_2
##
##  <ManSection>
##  <Var Name="LENGTH_SETTER_METHODS_2"/>
##
##  <Description>
##  is the current length of <C>METHODS_OPERATION( <A>attr</A>, 2 )</C>
##  for an attribute <A>attr</A> for which no individual setter methods
##  are installed.
##  (This is used for <C>ObjectifyWithAttributes</C>.)
##  </Description>
##  </ManSection>
##
LENGTH_SETTER_METHODS_2 := 0;


#############################################################################
##
#F  DeclarePropertyKernel( <name>, <filter>, <getter> ) . . . .  new property
##
##  <ManSection>
##  <Func Name="DeclarePropertyKernel" Arg='name, filter, getter'/>
##
##  <Description>
##  This function must not be used to re-declare a property
##  that has already been declared.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "DeclarePropertyKernel", function ( name, filter, getter )
    local setter, tester;

    # This will yield an error if `name' is already bound.
    BIND_GLOBAL( name, getter );
    SET_NAME_FUNC( getter, name );

    # construct setter and tester
    setter := SETTER_FILTER( getter );
    tester := TESTER_FILTER( getter );

    # add getter, setter and tester to the list of operations
    STORE_OPER_FLAGS(getter, [ FLAGS_FILTER(filter) ]);
    STORE_OPER_FLAGS(setter, [ FLAGS_FILTER(filter), FLAGS_FILTER(IS_BOOL) ]);
    STORE_OPER_FLAGS(tester, [ FLAGS_FILTER(filter) ]);

    # install the default functions
    FILTERS[ FLAG1_FILTER( getter ) ]:= getter;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( getter ) );
    FILTERS[ FLAG2_FILTER( getter ) ]:= tester;
    INFO_FILTERS[ FLAG1_FILTER( getter ) ]:= 7;
    INFO_FILTERS[ FLAG2_FILTER( getter ) ]:= 8;

    # clear the cache because <filter> is something old
    if not GAPInfo.CommandLineOptions.N then
      InstallHiddenTrueMethod( tester, getter );
      CLEAR_HIDDEN_IMP_CACHE( getter );
      InstallHiddenTrueMethod( filter, tester );
      CLEAR_HIDDEN_IMP_CACHE( tester );
    fi;

    # run the attribute functions
    RUN_ATTR_FUNCS( filter, getter, setter, tester, false );

    # store the ranks
    RANK_FILTERS[ FLAG1_FILTER( getter ) ] := 1;
    RANK_FILTERS[ FLAG2_FILTER( getter ) ] := 1;

    # and make the remaining assignments
    BIND_SETTER_TESTER( name, setter, tester );
end );


#############################################################################
##
#F  NewProperty( <name>, <filter>[, <rank>] ) . . . . . . . . .  new property
##
##  <#GAPDoc Label="NewProperty">
##  <ManSection>
##  <Func Name="NewProperty" Arg='name, filter[, rank]'/>
##
##  <Description>
##  <Ref Func="NewProperty"/> returns a new property <A>prop</A> with name
##  <A>name</A> (see also&nbsp;<Ref Sect="Properties"/>).
##  The filter <A>filter</A> describes the involved filters of <A>prop</A>.
##  As in the case of attributes,
##  <A>filter</A> is not implied by <A>prop</A>.
##  <P/>
##  The optional third argument <A>rank</A> denotes the incremental rank
##  (see&nbsp;<Ref Sect="Filters"/>) of the property
##  <A>prop</A> itself, i.e. <E>not</E> of its tester;
##  the default value is 1.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
    STORE_OPER_FLAGS(getter, [ flags ]);
    STORE_OPER_FLAGS(setter, [ flags, FLAGS_FILTER(IS_BOOL) ]);
    STORE_OPER_FLAGS(tester, [ flags ]);

    # install the default functions
    atomic FILTER_REGION do
    FILTERS[ FLAG1_FILTER( getter ) ] := getter;
    IMM_FLAGS:= AND_FLAGS( IMM_FLAGS, FLAGS_FILTER( getter ) );
    FILTERS[ FLAG2_FILTER( getter ) ] := tester;
    INFO_FILTERS[ FLAG1_FILTER( getter ) ] := 9;
    INFO_FILTERS[ FLAG2_FILTER( getter ) ] := 10;
    od;

    # the <tester> and  <getter> are newly  made, therefore the cache cannot
    # contain a flag list involving <tester> or <getter>
    if not GAPInfo.CommandLineOptions.N then
      InstallHiddenTrueMethod( tester, getter );
      InstallHiddenTrueMethod( filter, tester );
    fi;
    # CLEAR_HIDDEN_IMP_CACHE();

    # run the attribute functions
    RUN_ATTR_FUNCS( filter, getter, setter, tester, false );

    # store the rank
    atomic FILTER_REGION do
    if LEN_LIST( arg ) = 3 and IS_INT( arg[3] ) then
        RANK_FILTERS[ FLAG1_FILTER( getter ) ]:= arg[3];
    else
        RANK_FILTERS[ FLAG1_FILTER( getter ) ]:= 1;
    fi;
    RANK_FILTERS[ FLAG2_FILTER( tester ) ]:= 1;
    od;

    # and return the getter
    return getter;
end );


#############################################################################
##
#F  DeclareProperty( <name>, <filter> [,<rank>] ) . . . . . . .  new property
##
##  <#GAPDoc Label="DeclareProperty">
##  <ManSection>
##  <Func Name="DeclareProperty" Arg='name, filter [,rank]'/>
##
##  <Description>
##  does the same as <Ref Func="NewProperty"/>,
##  additionally makes the variable <A>name</A> read-only
##  and also binds read-only global variables with names
##  <C>Has<A>name</A></C> and <C>Set<A>name</A></C>
##  for the tester and setter of the property (see Section
##  <Ref Sect="Setter and Tester for Attributes"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "DeclareProperty", function ( arg )

    local prop, name, gvar, req, filter;

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
               " use `DeclareOperation'" );

      fi;

      # Add the new requirements.
      filter:= arg[2];
      if not IS_OPERATION( filter ) then
        Error( "<filter> must be an operation" );
      fi;

      STORE_OPER_FLAGS( gvar, [ FLAGS_FILTER( filter ) ] );

    else

      # The property is new.
      prop:= CALL_FUNC_LIST( NewProperty, arg );
      BIND_GLOBAL( name, prop );
      BIND_SETTER_TESTER( name, SETTER_FILTER( prop ), TESTER_FILTER( prop ) );

    fi;
end );



#############################################################################
##
#F  InstallAtExit( <func> ) . . . . . . . . . . function to call when exiting
##
BIND_GLOBAL( "InstallAtExit", function( func )
    local f;
    if not IS_FUNCTION(func)  then
        Error( "<func> must be a function" );
    fi;
    if CHECK_INSTALL_METHOD  then
        if not NARG_FUNC(func) in [ -1, 0 ]  then
            Error( "<func> must accept zero arguments" );
        fi;
    fi;
    # Return if function has already been installed
    # Use this long form to support both List and AtomicList
    for f in GAPInfo.AtExitFuncs do
        if f = func then
            return;
        fi;
    od;
    ADD_LIST( GAPInfo.AtExitFuncs, func );
end );


#############################################################################
##
#O  ViewObj( <obj> )  . . . . . . . . . . . . . . . . . . . .  view an object
##
##  <ManSection>
##  <Oper Name="ViewObj" Arg='obj'/>
##
##  <Description>
##  <Ref Oper="ViewObj"/> prints information about the object <A>obj</A>.
##  This information is thought to be short and human readable,
##  in particular <E>not</E> necessarily detailed enough for defining <A>obj</A>,
##  an in general <E>not</E> &GAP; readable.
##  <P/>
##  More detailed information can be obtained by <Ref Func="PrintObj"/>
##  </Description>
##  </ManSection>
##
DeclareOperationKernel( "ViewObj", [ IS_OBJECT ], VIEW_OBJ );


#############################################################################
##
#O  ViewString( <obj> )  . . . . . . . . . . . . . . . . . . . view an object
##
##  <#GAPDoc Label="ViewString">
##  <ManSection>
##  <Oper Name="ViewString" Arg='obj'/>
##
##  <Description>
##  <Ref Oper="ViewString"/> returns a string which would be displayed 
##  by <Ref Oper="ViewObj"/> for an
##  object. Note that no method for <Ref Oper="ViewString"/> may 
##  delegate to any of
##  the operations <Ref Oper="Display"/>, <Ref Oper="ViewObj"/>,
##  <Ref Oper="DisplayString"/> or <Ref Oper="PrintObj"/> to avoid 
##  circular delegations.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ViewString", [ IS_OBJECT ]);


#############################################################################
##
#F  View( <obj1>, <obj2>... ) . . . . . . . . . . . . . . . . .  view objects
##
##  <#GAPDoc Label="View">
##  <ManSection>
##  <Func Name="View" Arg='obj1, obj2...'/>
##
##  <Description>
##  <Ref Func="View"/> shows the objects <A>obj1</A>, <A>obj2</A>... etc.
##  <E>in a short form</E> on the standard output by calling the
##  <Ref Oper="ViewObj"/> operation on each of them.
##  <Ref Func="View"/> is called in the read-eval-print loop,
##  thus the output looks exactly like the representation of the
##  objects shown by the main loop.
##  Note that no space or newline is printed between the objects.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "View", function( arg )
    local   obj;

    for obj  in arg  do
        ViewObj(obj);
    od;
end );


#############################################################################
##
#F  TraceMethods( <oprs> )
##
##  <#GAPDoc Label="TraceMethods">
##  <ManSection>
##  <Func Name="TraceMethods" Arg='opr1, opr2, ...' Label ="for operations"/>
##  <Func Name="TraceMethods" Arg='oprs' Label ="for a list of operations"/>
##
##  <Description>
##  After the call of <C>TraceMethods</C>,  whenever a method of one of 
##  the operations <A>opr1</A>, <A>opr2</A>, ... is called, the
##  information string used in the installation of the method is printed.
##  The second form has the same effect for each operation from the list
##  <A>oprs</A> of operations.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "TraceMethods", function( arg )
    local   fun;
    if LEN_LIST( arg ) = 0 then
      Error("`TraceMethods' require at least one argument");
    fi;
    if IS_LIST(arg[1])  then
        arg := arg[1];
    fi;
    for fun  in arg  do
        TRACE_METHODS(fun);
    od;

end );

#############################################################################
##
#F  TraceAllMethods( )
##
##  <#GAPDoc Label="TraceAllMethods">
##  <ManSection>
##  <Func Name="TraceAllMethods" Arg=""/>
##
##  <Description>
##  Invokes <C>TraceMethods</C> for all operations.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "TraceAllMethods", function( arg )
    local   fun;
    TraceMethods(OPERATIONS);
end );


#############################################################################
##
#F  UntraceMethods( <oprs>)
##
##  <#GAPDoc Label="UntraceMethods">
##  <ManSection>
##  <Func Name="UntraceMethods" Arg='opr1, opr2, ...' Label ="for operations"/>
##  <Func Name="UntraceMethods" Arg='oprs' Label ="for a list of operations"/>
##
##  <Description>
##  turns the tracing off for all operations <A>opr1</A>, <A>opr2</A>, ... or
##  in the second form, for all operations in the list <A>oprs</A>.
##  <Log><![CDATA[
##  gap> TraceMethods( [ Size ] );
##  gap> g:= Group( (1,2,3), (1,2) );;
##  gap> Size( g );
##  #I  Size: for a permutation group at /gap5/lib/grpperm.gi:487
##  #I  Setter(Size): system setter
##  #I  Size: system getter
##  #I  Size: system getter
##  6
##  gap> UntraceMethods( [ Size ] );
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "UntraceMethods", function( arg )
    local   fun;
    if LEN_LIST( arg ) = 0 then
      Error("`UntraceMethods' require at least one argument");
    fi;
    if IS_LIST(arg[1])  then
        arg := arg[1];
    fi;
    for fun  in arg  do
        UNTRACE_METHODS(fun);
    od;

end );


#############################################################################
##
#F  UntraceAllMethods( <oprs>)
##
##  <#GAPDoc Label="UntraceAllMethods">
##  <ManSection>
##  <Func Name="UntraceAllMethods" Arg=""/>
##
##  <Description>
##  Equivalent to calling <C>UntraceMethods</C> for all operations.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "UntraceAllMethods", function( arg )
    local   fun;
    UntraceMethods(OPERATIONS);
end );

#############################################################################
##
#F  DeclareGlobalFunction( <name>, <info> ) . .  create a new global function
#F  InstallGlobalFunction( <oper>, <func> )
##
##  <#GAPDoc Label="DeclareGlobalFunction">
##  <ManSection>
##  <Func Name="DeclareGlobalFunction" Arg='name, info'/>
##  <Func Name="InstallGlobalFunction" Arg='oper, func'/>
##
##  <Description>
##  <Ref Func="DeclareGlobalFunction"/> 
##  &GAP; functions that are not operations and that are intended to be
##  called by users should be notified to &GAP; in the declaration part
##  of the respective package
##  (see Section&nbsp;<Ref Sect="Declaration and Implementation Part"/>)
##  via <Ref Func="DeclareGlobalFunction"/>, which returns a function that
##  serves as a place holder for the function that will be installed later,
##  and that will print an error message if it is called.
##  See also&nbsp;<Ref Func="DeclareSynonym"/>.
##  <P/>
##  A global function declared with <Ref Func="DeclareGlobalFunction"/>
##  can be given its value <A>func</A> via
##  <Ref Func="InstallGlobalFunction"/>;
##  <A>gvar</A> is the global variable (or a string denoting its name)
##  named with the <A>name</A> argument of the call to
##  <Ref Func="DeclareGlobalFunction"/>.
##  For example, a declaration like
##  <P/>
##  <Log><![CDATA[
##  DeclareGlobalFunction( "SumOfTwoCubes" );
##  ]]></Log>
##  <P/>
##  in the <Q>declaration part</Q>
##  (see Section&nbsp;<Ref Sect="Declaration and Implementation Part"/>)
##  might have a corresponding <Q>implementation part</Q> of:
##  <P/>
##  <Log><![CDATA[
##  InstallGlobalFunction( SumOfTwoCubes, function(x, y) return x^3 + y^3; end);
##  ]]></Log>
##  <P/>
##  <!-- Commented out by AK after the withdrowal of completion files:
##  <E>Note:</E> <A>func</A> must be a function which has <E>not</E> been
##  declared with <Ref Func="DeclareGlobalFunction"/> itself.
##  Otherwise completion files
##  (see&nbsp;<Ref Sect="Completion Files"/>) get confused! -->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  Global functions of the &GAP; library must be distinguished from other
##  global variables (see <C>variable.g</C>) because of the completion
##  mechanism.
##
if IsHPCGAP then
    BIND_GLOBAL( "GLOBAL_FUNCTION_NAMES", ShareSpecialObj([], "GLOBAL_FUNCTION_NAMES") );
else
    BIND_GLOBAL( "GLOBAL_FUNCTION_NAMES", [] );
fi;

BIND_GLOBAL( "DeclareGlobalFunction", function( arg )
    local   name;

    name := arg[1];
    atomic GLOBAL_FUNCTION_NAMES do
    ADD_SET( GLOBAL_FUNCTION_NAMES, IMMUTABLE_COPY_OBJ(name) );
    od;
    BIND_GLOBAL( name, NEW_GLOBAL_FUNCTION( name ) );
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
      if not ISBOUND_GLOBAL(oper) then
        Error("global function `", oper, "' is not declared yet");
      fi;
      oper:= VALUE_GLOBAL( oper );
    fi;
    atomic readonly GLOBAL_FUNCTION_NAMES do
    if NAME_FUNC(func) in GLOBAL_FUNCTION_NAMES then
      Error("you cannot install a global function for another global ",
            "function,\nuse `DeclareSynonym' instead!");
    fi;
    INSTALL_GLOBAL_FUNCTION( oper, func );
    od;
end );

if not IsHPCGAP then

BIND_GLOBAL( "FLUSH_ALL_METHOD_CACHES", function()
    local oper,j;
    for oper in OPERATIONS do
        for j in [1..6] do
            CHANGED_METHODS_OPERATION(oper,j);
        od;
    od;
end);

fi;

if BASE_SIZE_METHODS_OPER_ENTRY <> 5 then
    Error("MethodsOperation must be updated for new BASE_SIZE_METHODS_OPER_ENTRY");
fi;

# TODO: document this?!
BIND_GLOBAL("MethodsOperation", function(oper, nargs)
    local meths, len, result, i, m;

    meths := METHODS_OPERATION(oper, nargs);
    if meths = fail then
        return fail;
    fi;
    len := BASE_SIZE_METHODS_OPER_ENTRY + nargs;
    result := [];
    for i in [0, len .. LENGTH(meths) - len] do
        m := rec(
            famPred := meths[i + 1],
            argFilt := meths{[i + 2 .. i + nargs + 1]},
            func    := meths[i + nargs + 2],
            rank    := meths[i + nargs + 3],
            info    := meths[i + nargs + 4],
            );
        ADD_LIST(result, m);
        if IsBound(meths[i + nargs + 5]) then
            m.location := meths[i + nargs + 5];
        fi;
    od;
    return result;
end );

#############################################################################
##
#E
