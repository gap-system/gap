#############################################################################
##
#W  profile.g                   GAP Library                      Frank Celler
##
#H  @(#)$Id: profile.g,v 4.44 2009/03/09 13:08:23 sal Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the profiling functions.
##
Revision.profile_g :=
    "@(#)$Id: profile.g,v 4.44 2009/03/09 13:08:23 sal Exp $";


#############################################################################
##
#V  PROFILED_FUNCTIONS  . . . . . . . . . . . . . . list of profiled function
##
##  <ManSection>
##  <Var Name="PROFILED_FUNCTIONS"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
PROFILED_FUNCTIONS := [];
PROFILED_FUNCTIONS_NAMES := [];


#############################################################################
##
#V  PREV_PROFILED_FUNCTIONS . . . . . . list of previously profiled functions
##
##  <ManSection>
##  <Var Name="PREV_PROFILED_FUNCTIONS"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
PREV_PROFILED_FUNCTIONS := [];
PREV_PROFILED_FUNCTIONS_NAMES := [];


#############################################################################
##
#F  ClearProfile()  . . . . . . . . . . . . . . clear all profile information
##
##  <#GAPDoc Label="ClearProfile">
##  <ManSection>
##  <Func Name="ClearProfile" Arg=''/>
##
##  <Description>
##  clears all stored profiling information.
##  <P/>
##  <Log><![CDATA[
##  gap> ProfileOperationsAndMethods(true);
##  gap> ConjugacyClasses(PrimitiveGroup(24,1));;
##  gap> ProfileOperationsAndMethods(false);
##  gap> DisplayProfile();
##    count  self/ms  chld/ms  function
##  [the following is excerpted from a much longer list]
##     1620      170       90  CycleStructurePerm: default method
##     1620       20      260  CycleStructurePerm
##   114658      280        0  Size: for a list that is a collection
##      287       20      290  Meth(CyclesOp)
##      287        0      310  CyclesOp
##       26        0      330  Size: for a conjugacy class
##     2219       50      380  Size
##        2        0      670  IsSubset: for two collections (loop over the ele*
##       32        0      670  IsSubset
##       48       10      670  IN: for a permutation, and a permutation group
##        2       20      730  Meth(ClosureGroup)
##        2        0      750  ClosureGroup
##        1        0      780  DerivedSubgroup
##        1        0      780  Meth(DerivedSubgroup)
##        4        0      810  Meth(StabChainMutable)
##       29        0      810  StabChainOp
##        3      700      110  Meth(StabChainOp)
##        1        0      820  Meth(IsSimpleGroup)
##        1        0      820  Meth(IsSimple)
##      552       10      830  Meth(StabChainImmutable)
##       26      490      480  CentralizerOp: perm group,elm
##       26        0      970  Meth(StabilizerOfExternalSet)
##      107        0      970  CentralizerOp
##      926       10      970  Meth(CentralizerOp)
##      819     2100     2340  Meth(IN)
##        1       10     4890  ConjugacyClasses: by random search
##        1        0     5720  ConjugacyClasses: perm group
##        2        0     5740  ConjugacyClasses
##              6920           TOTAL
##  gap> DisplayProfile(StabChainOp,DerivedSubgroup); # only two functions
##    count  self/ms  chld/ms  function
##        1        0      780  DerivedSubgroup
##       29        0      810  StabChainOp
##              6920           OTHER
##              6920           TOTAL
##  ]]></Log>
##  <P/>
##  Note that profiling (even calling <Ref Func="ProfileOperationsAndMethods"/>
##  with <K>true</K>)
##  can take substantial time and &GAP; will perform much more slowly
##  when profiling than when not.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ClearProfile",function()
    local   i;

    for i  in Concatenation(PROFILED_FUNCTIONS, PREV_PROFILED_FUNCTIONS)  do
        CLEAR_PROFILE_FUNC(i);
    od;
end);

#############################################################################
##
#V  PROFILETHRESHOLD
##
##  <#GAPDoc Label="PROFILETHRESHOLD">
##  <ManSection>
##  <Var Name="PROFILETHRESHOLD"/>
##
##  <Description>
##  This variable is a list <M>[<A>cnt</A>,<A>time</A>]</M> of length two. <C>DisplayProfile</C>
##  will only display lines for functions which are called at least <A>cnt</A>
##  times or whose <E>total</E> time (<Q>self</Q>+<Q>child</Q>) is at least <A>time</A>.
##  The default value of <C>PROFILETHRESHOLD</C> is [10000,30].
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
PROFILETHRESHOLD:=[10000,30]; # cnt, time

#############################################################################
##
#F  DisplayProfile( )
#F  DisplayProfile( <funcs> )
##
##  <#GAPDoc Label="DisplayProfile">
##  <ManSection>
##  <Func Name="DisplayProfile" Arg='[funcs]'/>
##
##  <Description>
##  Called without arguments, <Ref Func="DisplayProfile"/> displays the
##  profiling information for profiled operations, methods and functions.
##  If an argument <A>funcs</A> is given, only profiling information for the
##  functions in <A>funcs</A> is shown.
##  The information for a profiled function is only displayed if the number
##  of calls to the function or the total time spent in the function exceeds
##  a given threshold (see&nbsp;<Ref Var="PROFILETHRESHOLD"/>).
##  <P/>
##  Profiling information is displayed in a list of lines for all functions
##  (also operations and methods) which are profiled. For each function,
##  <Q>count</Q> gives the number of times the function has been called.
##  <Q>self</Q> gives the time spent in the function itself, <Q>child</Q>
##  the time spent in profiled functions called from within this function.
##  The list is sorted according to the total time spent, that is the sum
##  <Q>self</Q>+<Q>child</Q>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("DisplayProfile",function( arg )
    local    prof,  tmp,  i,  p,  w,  j,  line,  str,  n,  s,  tsum,  other,
             funcs,  k,  all,  nam,  tsto,  sum;

    # stop profiling of functions needed below
    for i  in PROFILED_FUNCTIONS  do
        UNPROFILE_FUNC(i);
    od;

    # unravel the arguments
    all := Concatenation( PROFILED_FUNCTIONS,
                          PREV_PROFILED_FUNCTIONS );
    nam := Concatenation( PROFILED_FUNCTIONS_NAMES,
                          PREV_PROFILED_FUNCTIONS_NAMES );
    if 0 = Length(arg)  then
      funcs := all;
    elif Length(arg)=1 and not IsFunction(arg[1]) then
      funcs:=arg[1];
    else
      funcs:=arg;
    fi;

    # get all operations called at least once
    prof  := [];
    tsum  := 0;
    tsto  := 0;
    other := 0;
    for i  in [ 1 .. Length(all) ]  do
	tmp := PROF_FUNC(all[i]);
	if tmp[1] > 0  then
            if all[i] in funcs  then
                n := [];
                if IsString(nam[i])  then
                    str := nam[i];
                else
                    str := ShallowCopy(nam[i][1]);
                    for  k  in [ 2 .. Length(nam[i]) ]  do
                        Append( str, nam[i][k] );
                    od;
                fi;
                Add( n, str );
                Add( n, tmp[1] );
                if 0 < tmp[2]  then Add(n,tmp[2]);  else Add(n,0);  fi;
                if 0 < tmp[3]  then Add(n,tmp[3]);  else Add(n,0);  fi;
                Add( n, QuoInt(tmp[4],1024) );
                Add( n, QuoInt(tmp[5],1024) );
                Add( prof, n );
            elif 0 < tmp[3]  then
                other := other + tmp[3];
            fi;
            if 0 < tmp[3]  then
                tsum := tsum + tmp[3];
            fi;
            if 0 < tmp[5]  then
                tsto := tsto + QuoInt(tmp[5],1024);
            fi;
	fi;
    od;

    # take only those which are not to be ignored
    prof:=Filtered(prof,i->i[2]>PROFILETHRESHOLD[1]
			or i[3]>PROFILETHRESHOLD[2]);

    # sort functions according to time spent in self
    #Sort( prof, function(a,b)
    #    return ( a[4] = b[4] and a[2] > b[2] ) or a[4] > b[4];
    #end );
    #prof := Reversed(prof);

    # sort functions according to total time spent
    Sort( prof, function(a,b)
	return a[3]<b[3];
    end );

    # set width and names
    if ForAll( prof, i -> i[5] = 0 )  then
        w := [ 7, 7, 7, -43 ];
        p := [ 2, 4,-2,   1 ];

        n := [ "count", "self/ms", "chld/ms", "function" ];
    else
        w := [ 7, 7,  7, 7,  7, -30 ];
        p := [ 2, 4, -2, 6, -3,   1 ];
        n := [ "count", "self/ms", "chld/ms", "stor/kb", "chld/kb",
               "function" ];
    fi;
    s := "  ";

    # use screen size for the name
    j := 0;
    for i  in [ 1 .. Length(w) ]  do
        if p[i] <> 1  then
            j := j + AbsInt(w[i]) + Length(s);
        else
            k := i;
        fi;
    od;
    if w[k] < 0  then
        w[k] := - AbsInt( SizeScreen()[1] - j - Length(s) -2);
    else
        w[k] := AbsInt( SizeScreen()[1] - j - Length(s)-2 );
    fi;

    # print a nice header
    line := "";
    for j  in [ 1 .. Length(p) ]  do
	str := String( n[j], w[j] );
	if Length(str) > AbsInt(w[j])  then
	    str := str{[1..AbsInt(w[j])-1]};
	    Add( str, '*' );
	fi;
	Append( line, str );
        Append( line, s   );
    od;
    Print( line, "\n" );

    # print profile
    sum := 0;
    for i  in prof  do
	line := "";
	for j  in [ 1 .. Length(p) ]  do
            if p[j] = -1  then
                sum := sum + i[4];
                str := String( sum, w[j] );
            elif p[j] = -2  then
                str := String( i[3]-i[4], w[j] );
            elif p[j] = -3  then
                str := String( i[5]-i[6], w[j] );
            else
                str := String( i[p[j]], w[j] );
            fi;
            if Length(str) > AbsInt(w[j])  then
                str := str{[1..AbsInt(w[j])-1]};
                Add( str, '*' );
	    fi;
	    Append( line, str );
	    Append( line, s   );
	od;
        Print( line, "\n" );
    od;

    # print other
    if other > 0  then
        line := "";
        for j  in [ 1 .. Length(p) ]  do
            if p[j] = 4  then
                str := String( other, w[j] );
            elif p[j] = 1  then
                str := String( "OTHER", w[j] );
            else
                str := String( " ", w[j] );
            fi;
            if Length(str) > AbsInt(w[j])  then
                str := str{[1..AbsInt(w[j])-1]};
                Add( str, '*' );
            fi;
            Append( line, str );
            Append( line, s   );
        od;
        Print( line, "\n" );
    fi;

    # print total
    line := "";
    for j  in [ 1 .. Length(p) ]  do
	if p[j] = 4  then
	    str := String( tsum, w[j] );
        elif p[j] = 6  then
            str := String( tsto, w[j] );
        elif p[j] = 1  then
            str := String( "TOTAL", w[j] );
	else
	    str := String( " ", w[j] );
	fi;
  	if Length(str) > AbsInt(w[j])  then
	    str := str{[1..AbsInt(w[j])-1]};
	    Add( str, '*' );
	fi;
	Append( line, str );
	Append( line, s   );
    od;
    Print( line, "\n" );

    # start profiling of functions needed above
    for i  in PROFILED_FUNCTIONS  do
        PROFILE_FUNC(i);
    od;

end);

#############################################################################
##
#F  ProfileFunctions( <funcs> )
##
##  <#GAPDoc Label="ProfileFunctions">
##  <ManSection>
##  <Func Name="ProfileFunctions" Arg='funcs'/>
##
##  <Description>
##  turns profiling on for all function in <A>funcs</A>.
##  You can use <Ref Func="ProfileGlobalFunctions"/>
##  to turn profiling on for all globally declared functions simultaneously.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ProfileFunctions",function( arg )
    local   funcs,  names,  hands,  pi,  OLD_PROFILED_FUNCTIONS,  
            OLD_PROFILED_FUNCTIONS_NAMES, 
            i,  phands,  pi2,  j,  x,  y,  
                        f;

  if Length(arg)=2 and IsList(arg[1]) and IsList(arg[2]) then
    funcs:=arg[1];
    names:=arg[2];
  else
    if IsFunction(arg[1]) then
      funcs:=arg;
    else
      funcs:=arg[1];
    fi;
    names:=List(funcs,NameFunction);
  fi;
  
  Append(PROFILED_FUNCTIONS, funcs);
  Append(PROFILED_FUNCTIONS_NAMES, names);
  hands := List(PROFILED_FUNCTIONS, HANDLE_OBJ);
  pi := Sortex(hands);
  OLD_PROFILED_FUNCTIONS := Permuted(PROFILED_FUNCTIONS, pi);
  OLD_PROFILED_FUNCTIONS_NAMES := Permuted(PROFILED_FUNCTIONS_NAMES, pi);
  PROFILED_FUNCTIONS := [OLD_PROFILED_FUNCTIONS[1]];
  PROFILED_FUNCTIONS_NAMES := [OLD_PROFILED_FUNCTIONS_NAMES[1]];
  for i in [2..Length(OLD_PROFILED_FUNCTIONS)] do
      if hands[i-1] <> hands[i] then
          Add(PROFILED_FUNCTIONS, OLD_PROFILED_FUNCTIONS[i]);
          Add(PROFILED_FUNCTIONS_NAMES, OLD_PROFILED_FUNCTIONS_NAMES[i]);
      fi;
  od;
  
  hands := List(funcs, HANDLE_OBJ);
  Sort(hands);
  phands := List(PREV_PROFILED_FUNCTIONS, HANDLE_OBJ);
  pi2 := Sortex(phands)^-1;
  i := 1;
  j := 1;
  while i <= Length(hands) and j <= Length(phands) do
      x := hands[i];
      y := phands[j];
      if x < y then
          i := i+1;
      elif y < x then
          j := j+1;
      else
          Unbind(PREV_PROFILED_FUNCTIONS[j^pi2]);
          Unbind(PREV_PROFILED_FUNCTIONS_NAMES[j^pi2]);
      fi;
  od;
  PREV_PROFILED_FUNCTIONS      :=Compacted(PREV_PROFILED_FUNCTIONS);
  PREV_PROFILED_FUNCTIONS_NAMES:=Compacted(PREV_PROFILED_FUNCTIONS_NAMES);
  for f in funcs do
      CLEAR_PROFILE_FUNC(f);
  od;
  
end);


#############################################################################
##
#F  UnprofileFunctions( <funcs> ) . . . . . . . . . . . . unprofile functions
##
##  <#GAPDoc Label="UnprofileFunctions">
##  <ManSection>
##  <Func Name="UnprofileFunctions" Arg='funcs'/>
##
##  <Description>
##  turns profiling off for all function in <A>funcs</A>. Recorded information is
##  still kept, so you can  display it even after turning the profiling off.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

BIND_GLOBAL("UnprofileFunctions",function( arg )
local list,  f,  pos;

    if Length(arg)=1 and not IsFunction(arg[1]) then
      list:=arg[1];
    else
      list:=arg;
    fi;

    for f  in list  do
        pos := Position( PROFILED_FUNCTIONS, f );
        if pos <> fail  then
            Add(PREV_PROFILED_FUNCTIONS,PROFILED_FUNCTIONS[pos]);
            Add(PREV_PROFILED_FUNCTIONS_NAMES,PROFILED_FUNCTIONS_NAMES[pos]);
            Unbind( PROFILED_FUNCTIONS[pos] );
            Unbind( PROFILED_FUNCTIONS_NAMES[pos] );
            UNPROFILE_FUNC(f);
        fi;
    od;
    PROFILED_FUNCTIONS       := Compacted(PROFILED_FUNCTIONS);
    PROFILED_FUNCTIONS_NAMES := Compacted(PROFILED_FUNCTIONS_NAMES);
end);


#############################################################################
##
#V  PROFILED_METHODS  . . . . . . . . . . . . . . .  list of profiled methods
##
##  <ManSection>
##  <Var Name="PROFILED_METHODS"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
PROFILED_METHODS := [];


#############################################################################
##
#F  ProfileMethods( <ops> ) . . . . . . . . . . . . . start profiling methods
##
##  <#GAPDoc Label="ProfileMethods">
##  <ManSection>
##  <Func Name="ProfileMethods" Arg='ops'/>
##
##  <Description>
##  starts profiling of the methods for all operations in <A>ops</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

BIND_GLOBAL("ProfileMethods",function( arg )
    local   funcs,  names,  op,  name,  i,  meth,  j,  hands,  
            NEW_PROFILED_METHODS;
    arg := Flat(arg);
    funcs := [];
    names := [];
    for op  in arg  do
        name := NameFunction(op);
        for i  in [ 0 .. 6 ]  do
            meth := METHODS_OPERATION( op, i );
            if meth <> fail  then
                for j  in [ 0, (4+i) .. Length(meth)-(4+i) ]  do
                    Add( funcs, meth[j+(2+i)] );
                    if name = meth[j+(4+i)]  then
                        Add( names, [ "Meth(", name, ")" ] );
                    else
                        Add( names, meth[j+(4+i)] );
                    fi;
                od;
            fi;
        od;
    od;
    ProfileFunctions( funcs,names );
    Append(PROFILED_METHODS, funcs);
    hands := List(PROFILED_METHODS, HANDLE_OBJ);
    SortParallel(hands, PROFILED_METHODS);
    NEW_PROFILED_METHODS := [PROFILED_METHODS[1]];
    for i in [2..Length(hands)] do
        if hands[i] <> hands[i-1] then
            Add(NEW_PROFILED_METHODS, PROFILED_METHODS[i]);
        fi;
    od;
    PROFILED_METHODS := NEW_PROFILED_METHODS;
end);


#############################################################################
##
#F  UnprofileMethods( <ops> ) . . . . . . . . . . . .  stop profiling methods
##
##  <#GAPDoc Label="UnprofileMethods">
##  <ManSection>
##  <Func Name="UnprofileMethods" Arg='ops'/>
##
##  <Description>
##  stops profiling of the methods for all operations in <A>ops</A>. Recorded
##  information is still kept, so you can  display it even after turning the
##  profiling off.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("UnprofileMethods",function( arg )
    local   funcs,  op,  i,  meth,  j;

    arg := Flat(arg);
    funcs := [];
    for op  in arg  do
        for i  in [ 0 .. 6 ]  do
            meth := METHODS_OPERATION( op, i );
            if meth <> fail  then
                for j  in [ 0, (4+i) .. Length(meth)-(4+i) ]  do
                    Add( funcs, meth[j+(2+i)] );
                od;
            fi;
        od;
    od;
    UnprofileFunctions(funcs);
end);


#############################################################################
##
#V  PROFILED_OPERATIONS . . . . . . . . . . . . . list of profiled operations
##
##  <ManSection>
##  <Var Name="PROFILED_OPERATIONS"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##

PROFILED_OPERATIONS := [];


#############################################################################
##
#F  ProfileOperationsOn() . . . . . . . . . . . start profiling of operations
##
##  <ManSection>
##  <Func Name="ProfileOperationsOn" Arg=''/>
##
##  <Description>
##  starts profiling of all operations.
##  </Description>
##  </ManSection>
##

BIND_GLOBAL("ProfileOperationsOn",function()
    local   prof,  nams;

    prof := OPERATIONS{[ 1, 3 .. Length(OPERATIONS)-1 ]};
    nams := List( prof, NameFunction );
    PROFILED_OPERATIONS := prof;
    UnprofileMethods(prof);
    ProfileFunctions( prof );
end);


#############################################################################
##
#F  ProfileOperationsAndMethodsOn() . . start profiling of operations/methods
##
##  <ManSection>
##  <Func Name="ProfileOperationsAndMethodsOn" Arg=''/>
##
##  <Description>
##  starts profiling of all operations and their methods. Old profiling
##  information is cleared.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL("ProfileOperationsAndMethodsOn",function()
    local   prof,  nams;

    prof := OPERATIONS{[ 1, 3 .. Length(OPERATIONS)-1 ]};
    nams := List( prof, NameFunction );
    PROFILED_OPERATIONS := prof;
    ProfileMethods(prof);
    ProfileFunctions( prof );

    # methods for the kernel functions
    ProfileMethods(\+,\-,\*,\/,\^,\mod,\<,\=,\in,
                     \.,\.\:\=,IsBound\.,Unbind\.,
                     \[\],\[\]\:\=,IsBound\[\],Unbind\[\]);
end);


#############################################################################
##
#F  ProfileOperationsOff()  . . . . . . . . . .  stop profiling of operations
##
##  <ManSection>
##  <Func Name="ProfileOperationsOff" Arg=''/>
##
##  <Description>
##  stops profiling of all operations.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL("ProfileOperationsOff",function()
    UnprofileFunctions(PROFILED_OPERATIONS);
    UnprofileMethods(PROFILED_OPERATIONS);

    # methods for the kernel functions
    UnprofileMethods(\+,\-,\*,\/,\^,\mod,\<,\=,\in,
                     \.,\.\:\=,IsBound\.,Unbind\.,
                     \[\],\[\]\:\=,IsBound\[\],Unbind\[\]);
end);


#############################################################################
##
#F  ProfileOperationsAndMethodsOff()  .  stop profiling of operations/methods
##
##  <ManSection>
##  <Func Name="ProfileOperationsAndMethodsOff" Arg=''/>
##
##  <Description>
##  stops profiling of all operations and their methods.
##  </Description>
##  </ManSection>
##
ProfileOperationsAndMethodsOff := ProfileOperationsOff;


#############################################################################
##
#F  ProfileOperations( [<true/false>] ) . . . . . . . . .  start/stop/display
##
##  <#GAPDoc Label="ProfileOperations">
##  <ManSection>
##  <Func Name="ProfileOperations" Arg='[true/false]'/>
##
##  <Description>
##  When called with argument <A>true</A>, this function starts profiling of all
##  operations.
##  Old profiling information is cleared.
##  When called with <A>false</A> it stops profiling of all operations.
##  Recorded information is still kept,
##  so you can display it even after turning the profiling off.
##  <P/>
##  When called without argument, profiling information for all profiled
##  operations is displayed (see&nbsp;<Ref Func="DisplayProfile"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ProfileOperations",function( arg )
    if 0 = Length(arg)  then
	DisplayProfile(PROFILED_OPERATIONS);
    elif 1 = Length(arg)  then
        if arg[1]  then
            ProfileOperationsOn();
        else
            ProfileOperationsOff();
        fi;
    else
        Print( "usage: ProfileOperations( [<true/false>] )" );
    fi;
end);


#############################################################################
##
#F  ProfileOperationsAndMethods( [<true/false>] ) . . . .  start/stop/display
##
##  <#GAPDoc Label="ProfileOperationsAndMethods">
##  <ManSection>
##  <Func Name="ProfileOperationsAndMethods" Arg='[true/false]'/>
##
##  <Description>
##  When called with argument <A>true</A>, this function starts profiling of all
##  operations and their methods.
##  Old profiling information is cleared.
##  When called with <A>false</A> it stops profiling of all operations and their
##  methods.
##  Recorded information is still kept,
##  so you can display it even after turning the profiling off.
##  <P/>
##  When called without argument, profiling information for all profiled
##  operations and their methods is displayed (see&nbsp;<Ref Func="DisplayProfile"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ProfileOperationsAndMethods",function( arg )
    if 0 = Length(arg)  then
	DisplayProfile(Concatenation(PROFILED_OPERATIONS,PROFILED_METHODS));
    elif 1 = Length(arg)  then
        if arg[1]  then
            ProfileOperationsAndMethodsOn();
        else
            ProfileOperationsAndMethodsOff();
        fi;
    else
        Print( "usage: ProfileOperationsAndMethods( [<true/false>] )" );
    fi;
end);

#############################################################################
##
#F  ProfileGlobalFunctions(true)
#F  ProfileGlobalFunctions(false)
##
##  <#GAPDoc Label="ProfileGlobalFunctions">
##  <ManSection>
##  <Func Name="ProfileGlobalFunctions" Arg='bool'/>
##
##  <Description>
##  Called with argument <K>true</K>, <Ref Func="ProfileGlobalFunctions"/>
##  turns on profiling for all functions that have been declared via
##  <Ref Func="DeclareGlobalFunction"/>.
##  A function call with the argument <K>false</K> turns it off again.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
PROFILED_GLOBAL_FUNCTIONS := [];

BIND_GLOBAL( "ProfileGlobalFunctions", function( arg )
    local name, func, funcs;
    if 0 = Length(arg) then
        DisplayProfile( PROFILED_GLOBAL_FUNCTIONS );
    elif arg[1] then
        PROFILED_GLOBAL_FUNCTIONS  := [];
        for name in GLOBAL_FUNCTION_NAMES do
            if IsBoundGlobal(name) then
                func := ValueGlobal(name);
                if IsFunction(func) then
                    Add(PROFILED_GLOBAL_FUNCTIONS, func);
                fi;
            fi;
        od;
        ProfileFunctions(PROFILED_GLOBAL_FUNCTIONS);
    else
        UnprofileFunctions(PROFILED_GLOBAL_FUNCTIONS);
        PROFILED_GLOBAL_FUNCTIONS := [];
    fi;
end);
        
#############################################################################
##
#F  ProfileFunctionsInGlobalVariables()
##
##  <ManSection>
##  <Func Name="ProfileFunctionsInGlobalVariables" Arg=''/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
PROFILED_GLOBAL_VARIABLE_FUNCTIONS := [];

BIND_GLOBAL( "ProfileFunctionsInGlobalVariables", function( arg )
    local name, func, funcs;
    if 0 = Length(arg) then
        DisplayProfile( PROFILED_GLOBAL_VARIABLE_FUNCTIONS );
    elif arg[1] then
        PROFILED_GLOBAL_VARIABLE_FUNCTIONS  := [];
        for name in NamesGVars() do
            if IsBoundGlobal(name) then
                func := ValueGlobal(name);
                if IsFunction(func) then
                    Add(PROFILED_GLOBAL_VARIABLE_FUNCTIONS, func);
                fi;
            fi;
        od;
        ProfileFunctions(PROFILED_GLOBAL_VARIABLE_FUNCTIONS);
    else
        UnprofileFunctions(PROFILED_GLOBAL_VARIABLE_FUNCTIONS);
        PROFILED_GLOBAL_VARIABLE_FUNCTIONS := [];
    fi;
end);
        
        

#############################################################################
##
#F  DisplayRevision() . . . . . . . . . . . . . . .  display revision entries
##
##  <#GAPDoc Label="DisplayRevision">
##  <ManSection>
##  <Func Name="DisplayRevision" Arg=''/>
##
##  <Description>
##  Displays the revision numbers of all loaded files from the library.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("DisplayRevision",function()
    local   names,  source,  library,  unknown,  name,  p,  s,  type,  
            i,  j;

    names   := RecNames( Revision );
    source  := [];
    library := [];
    unknown := [];

    for name  in names  do
        p := Position( name, '_' );
        if p = fail  then
            Add( unknown, name );
        else
            s := name{[p+1..Length(name)]};
            if s = "c" or s = "h"  then
                Add( source, name );
            elif s = "g" or s = "gi" or s = "gd"  then
                Add( library, name );
            else
                Add( unknown, name );
            fi;
        fi;
    od;
    Sort( source );
    Sort( library );
    Sort( unknown );

    for type  in [ source, library, unknown ]  do
        if 0 < Length(type)  then
            if IsIdenticalObj(type,source)  then
                Print( "Source Files\n" );
            elif IsIdenticalObj(type,library)  then
                Print( "Library Files\n" );
            else
                Print( "Unknown Files\n" );
            fi;
            j := 1;
            for name  in type  do
                s := Revision.(name);
                p := Position( s, ',' )+3;
                i := p;
                while s[i] <> ' '  do i := i + 1;  od;
                s := Concatenation( String( Concatenation(
                         name, ":" ), -15 ), String( s{[p..i]},
                         -5 ) );
                if j = 3  then
                    Print( s, "\n" );
                    j := 1;
                else
                    Print( s, "    " );
                    j := j + 1;
                fi;
            od;
            if j <> 1  then Print( "\n" );  fi;
            Print( "\n" );
        fi;
    od;
end);


#############################################################################
##
#F  DisplayCacheStats() . . . . . . . . . . . . . .  display cache statistics
##
##  <#GAPDoc Label="DisplayCacheStats">
##  <ManSection>
##  <Func Name="DisplayCacheStats" Arg=''/>
##
##  <Description>
##  displays statistics about the different caches used by the method
##  selection.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("DisplayCacheStats",function()
    local   cache,  names,  pos,  i;

    cache := ShallowCopy(OPERS_CACHE_INFO());
    Append( cache, [
        WITH_HIDDEN_IMPS_FLAGS_CACHE_HIT,
        WITH_HIDDEN_IMPS_FLAGS_CACHE_MISS,
        WITH_IMPS_FLAGS_CACHE_HIT,
        WITH_IMPS_FLAGS_CACHE_MISS,
        NEW_TYPE_CACHE_HIT,
        NEW_TYPE_CACHE_MISS,
    ] );

    names := [
        "AND_FLAGS cache hits",
        "AND_FLAGS cache miss",
        "AND_FLAGS cache losses",
        "Operation L1 cache hits",
        "Operation cache misses",
        "IS_SUBSET_FLAGS calls",
        "IS_SUBSET_FLAGS less trues",
        "IS_SUBSET_FLAGS few trues",
        "Operation TryNextMethod",
        "WITH_HIDDEN_IMPS hits",
        "WITH_HIDDEN_IMPS misses",
        "WITH_IMPS hits",
        "WITH_IMPS misses",
        "NEW_TYPE hits",
        "NEW_TYPE misses",
    ];

    pos := [ 1, 2, 3, 4, 9, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15 ];

    if Length(pos) <> Length(names)  then
        Error( "<pos> and <names> have different lengths" );
    fi;
    if Length(pos) <> Length(cache)  then
        Error( "<pos> and <cache> have different lengths" );
    fi;

    for i  in pos  do
        Print( String( Concatenation(names[i],":"), -30 ),
               String( String(cache[i]), 12 ), "\n" );
    od;

end);


#############################################################################
##
#F  ClearCacheStats() . . . . . . . . . . . . . . . .  clear cache statistics
##
##  <#GAPDoc Label="ClearCacheStats">
##  <ManSection>
##  <Func Name="ClearCacheStats" Arg=''/>
##
##  <Description>
##  clears all statistics about the different caches used by the method
##  selection.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ClearCacheStats",function()
    CLEAR_CACHE_INFO();
    WITH_HIDDEN_IMPS_FLAGS_CACHE_HIT := 0;
    WITH_HIDDEN_IMPS_FLAGS_CACHE_MISS := 0;
    WITH_IMPS_FLAGS_CACHE_HIT := 0;
    WITH_IMPS_FLAGS_CACHE_MISS := 0;
    NEW_TYPE_CACHE_HIT := 0;
    NEW_TYPE_CACHE_MISS := 0;
end);


#############################################################################
##  
#F  START_TEST( <id> )  . . . . . . . . . . . . . . . . . . . start test file
#F  STOP_TEST( <file>, <fac> )  . . . . . . . . . . . . . . .  stop test file
##
##  <ManSection>
##  <Func Name="START_TEST" Arg='id'/>
##  <Func Name="STOP_TEST" Arg='file, fac'/>
##
##  <Description>
##  <Ref Func="START_TEST"/> and <Ref Func="STOP_TEST"/> are used in files
##  that are read via <Ref Func="ReadTest"/>.
##  We reinitialize the caches and the global random number generator,
##  in order to be independent of the reading order of several test files.
##  Furthermore, the assertion level (see&nbsp;<Ref Func="Assert"/>)
##  is set to <M>2</M> by <Ref Func="START_TEST"/> and set back to the
##  previous value in the subsequent <Ref Func="STOP_TEST"/> call.
##  <P/>
##  Note that the functions in <F>tst/testutil.g</F> temporarily replace
##  <Ref Func="STOP_TEST"/> before they call <Ref Func="ReadTest"/>.
##  </Description>
##  </ManSection>
##
START_TEST := function( name )
    FlushCaches();
    RANDOM_SEED(1);
    Reset(GlobalMersenneTwister, 1);
    GASMAN( "collect" );
    GAPInfo.TestData.START_TIME := Runtime();
    GAPInfo.TestData.START_NAME := name;
    GAPInfo.TestData.AssertionLevel:= AssertionLevel();
    SetAssertionLevel( 2 );
end;

STOP_TEST := function( file, fac )
    local time; 
    
    if not IsBound( GAPInfo.TestData.START_TIME ) then
      Error( "`STOP_TEST' command without `START_TEST' command for `",
             file, "'" );
    fi;
    time:= Runtime() - GAPInfo.TestData.START_TIME;
    Print( GAPInfo.TestData.START_NAME, "\n" );
    if time <> 0 and IsInt( fac ) then
      Print( "GAP4stones: ", QuoInt( fac, time ), "\n" );
    else
      Print( "GAP4stones: infinity\n" );
    fi;
    SetAssertionLevel( GAPInfo.TestData.AssertionLevel );
    Unbind( GAPInfo.TestData.AssertionLevel );
    Unbind( GAPInfo.TestData.START_TIME );
    Unbind( GAPInfo.TestData.START_NAME );
end;


#############################################################################
##
#E

