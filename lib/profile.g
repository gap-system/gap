#############################################################################
##
#W  profile.g                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the profiling functions.
##
Revision.profile_g :=
    "@(#)$Id$";


#############################################################################
##

#V  PROFILED_FUNCTIONS  . . . . . . . . . . . . . . list of profiled function
##
PROFILED_FUNCTIONS := [];
PROFILED_FUNCTIONS_NAMES := [];


#############################################################################
##
#V  PREV_PROFILED_FUNCTIONS . . . . . . list of previously profiled functions
##
PREV_PROFILED_FUNCTIONS := [];
PREV_PROFILED_FUNCTIONS_NAMES := [];


#############################################################################
##
#F  ClearProfile()  . . . . . . . . . . . . . . clear all profile information
##
ClearProfile := function()
    local   i;

    for i  in PROFILED_FUNCTIONS  do
        CLEAR_PROFILE_FUNCTION(i);
    od;
end;


#############################################################################
##
#F  DisplayProfile( <funcs> ) . . . . . . . . . display profiling information
##
DisplayProfile := function( arg )
    local    prof,  tmp,  i,  p,  w,  j,  line,  str,  n,  s,  tsum,  other,
             funcs,  k,  all,  nam,  tsto;

    # stop profiling of functions needed below
    for i  in PROFILED_FUNCTIONS  do
        UNPROFILE_FUNCTION(i);
    od;

    # unravel the arguments
    all := Concatenation( PROFILED_FUNCTIONS,
                          PREV_PROFILED_FUNCTIONS );
    nam := Concatenation( PROFILED_FUNCTIONS_NAMES,
                          PREV_PROFILED_FUNCTIONS_NAMES );
    if 0 = Length(arg)  then
        funcs := all;
    else
        funcs := arg[1];
    fi;

    # get all operations called at least once
    prof  := [];
    tsum  := 0;
    tsto  := 0;
    other := 0;
    for i  in [ 1 .. Length(all) ]  do
	tmp := PROF_FUNCTION(all[i]);
	if tmp[1] > 0  then
            if all[i] in funcs  then
                n := [];
                Add( n, nam[i] );
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

    # sort functions according to time spent in self
    Sort( prof, function(a,b)
        return ( a[4] = b[4] and a[2] > b[2] ) or a[4] > b[4];
    end );

    # set width and names
    if ForAll( prof, i -> i[5] = 0 )  then
        w := [ 7, 7, 7, -50 ];
        p := [ 2, 3, 4,   1 ];
        n := [ "count", "time", "self", "function" ];
    else
        w := [ 7, 7, 7, 7, 7, -30 ];
        p := [ 2, 3, 4, 5, 6,   1 ];
        n := [ "count", "time", "self", "stor", "self", "function" ];
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
        w[k] := - AbsInt( SizeScreen()[1] - j - Length(s) - 2 );
    else
        w[k] := AbsInt( SizeScreen()[1] - j - Length(s) - 2 );
    fi;

    # print a nice header
    line := "";
    for j  in [ 1 .. Length(p) ]  do
	str := FormattedString( n[j], w[j] );
	if Length(str) > AbsInt(w[j])  then
	    str := str{[1..AbsInt(w[j])-1]};
	    Add( str, '*' );
	fi;
	Append( line, str );
        Append( line, s   );
    od;
    Print( line, "\n" );

    # print profile
    for i  in prof  do
	line := "";
	for j  in [ 1 .. Length(p) ]  do
	    str := FormattedString( i[p[j]], w[j] );
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
                str := FormattedString( other, w[j] );
            elif p[j] = 1  then
                str := FormattedString( "OTHER", w[j] );
            else
                str := FormattedString( " ", w[j] );
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
	    str := FormattedString( tsum, w[j] );
        elif p[j] = 6  then
            str := FormattedString( tsto, w[j] );
        elif p[j] = 1  then
            str := FormattedString( "TOTAL", w[j] );
	else
	    str := FormattedString( " ", w[j] );
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
        PROFILE_FUNCTION(i);
    od;

end;


#############################################################################
##

#F  ProfileFunctions( <funcs>, <names> )  . . . . . . . . . profile functions
##
ProfileFunctions := function( funcs, names )
    local   i,  pos;

    for i  in [ 1 .. Length(funcs) ]  do
        if not funcs[i] in PROFILED_FUNCTIONS  then
            Add( PROFILED_FUNCTIONS,       funcs[i] );
            Add( PROFILED_FUNCTIONS_NAMES, names[i] );
            PROFILE_FUNCTION(funcs[i]);
        fi;
        pos := Position( PREV_PROFILED_FUNCTIONS, funcs[i] );
        if pos <> fail  then
            Unbind( PREV_PROFILED_FUNCTIONS[pos] );
            Unbind( PREV_PROFILED_FUNCTIONS_NAMES[pos] );
        fi;
        CLEAR_PROFILE_FUNCTION(funcs[i]);
    od;
    PREV_PROFILED_FUNCTIONS      :=Compacted(PREV_PROFILED_FUNCTIONS);
    PREV_PROFILED_FUNCTIONS_NAMES:=Compacted(PREV_PROFILED_FUNCTIONS_NAMES);
end;


#############################################################################
##
#F  UnprofileFunctions( <funcs> ) . . . . . . . . . . . . unprofile functions
##
UnprofileFunctions := function( list )
    local   f,  pos;

    for f  in list  do
        pos := Position( PROFILED_FUNCTIONS, f );
        if pos <> fail  then
            Add(PREV_PROFILED_FUNCTIONS,PROFILED_FUNCTIONS[pos]);
            Add(PREV_PROFILED_FUNCTIONS_NAMES,PROFILED_FUNCTIONS_NAMES[pos]);
            Unbind( PROFILED_FUNCTIONS[pos] );
            Unbind( PROFILED_FUNCTIONS_NAMES[pos] );
            UNPROFILE_FUNCTION(f);
        fi;
    od;
    PROFILED_FUNCTIONS       := Compacted(PROFILED_FUNCTIONS);
    PROFILED_FUNCTIONS_NAMES := Compacted(PROFILED_FUNCTIONS_NAMES);
end;


#############################################################################
##

#V  PROFILED_METHODS  . . . . . . . . . . . . . . .  list of profiled methods
##
PROFILED_METHODS := [];


#############################################################################
##
#F  ProfileMethods( <ops> ) . . . . . . . . . . . . . start profiling methods
##
ProfileMethods := function( arg )
    local   funcs,  names,  op,  i,  meth,  j,  name;

    if IsList(arg)  then
        arg := arg[1];
    fi;
    funcs := [];
    names := [];
    for op  in arg  do
        name := NAME_FUNCTION(op);
        for i  in [ 0 .. 6 ]  do
            meth := METHODS_OPERATION( op, i );
            if meth <> fail  then
                for j  in [ 0, (4+i) .. Length(meth)-(4+i) ]  do
                    Add( funcs, meth[j+(2+i)] );
                    if name = meth[j+(4+i)]  then
                        Add( names, Concatenation("Method(",name,")") );
                    else
                        Add( names, meth[j+(4+i)] );
                    fi;
                od;
            fi;
        od;
    od;
    ProfileFunctions( funcs, names );
    for op  in funcs  do
        if not op in PROFILED_METHODS  then
            Add( PROFILED_METHODS, op );
        fi;
    od;
end;


#############################################################################
##
#F  UnprofileMethods( <ops> ) . . . . . . . . . . . .  stop profiling methods
##
UnprofileMethods := function( arg )
    local   funcs,  op,  i,  meth,  j;

    if IsList(arg)  then
        arg := arg[1];
    fi;
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
end;


#############################################################################
##

#V  PROFILED_OPERATIONS . . . . . . . . . . . . . list of profiled operations
##
PROFILED_OPERATIONS := [];


#############################################################################
##
#F  ProfileOperationsOn() . . . . . . . . . . . start profiling of operations
##
ProfileOperationsOn := function()
    local   prof,  nams;

    prof := OPERATIONS{[ 1, 3 .. Length(OPERATIONS)-1 ]};
    nams := List( prof, NAME_FUNCTION );
    PROFILED_OPERATIONS := prof;
    UnprofileMethods(prof);
    ProfileFunctions( prof, nams );
end;


#############################################################################
##
#F  ProfileOperationsAndMethodsOn() . . start profiling of operations/methods
##
ProfileOperationsAndMethodsOn := function()
    local   prof,  nams;

    prof := OPERATIONS{[ 1, 3 .. Length(OPERATIONS)-1 ]};
    nams := List( prof, NAME_FUNCTION );
    PROFILED_OPERATIONS := prof;
    ProfileMethods(prof);
    ProfileFunctions( prof, nams );
end;


#############################################################################
##
#F  ProfileOperationsOff()  . . . . . . . . . .  stop profiling of operations
##
ProfileOperationsOff := function()
    UnprofileFunctions(PROFILED_OPERATIONS);
    UnprofileMethods(PROFILED_OPERATIONS);
end;


#############################################################################
##
#F  ProfileOperationsAndMethodsOff()  .  stop profiling of operations/methods
##
ProfileOperationsAndMethodsOff := ProfileOperationsOff;


#############################################################################
##
#F  ProfileOperations( [<true/false>] ) . . . . . . . . .  start/stop/display
##
ProfileOperations := function( arg )
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
end;


#############################################################################
##
#F  ProfileOperationsAndMethods( [<true/false>] ) . . . .  start/stop/display
##
ProfileOperationsAndMethods := function( arg )
    if 0 = Length(arg)  then
	DisplayProfile(Concatenation(PROFILED_OPERATIONS,PROFILED_METHODS));
    elif 1 = Length(arg)  then
        if arg[1]  then
            ProfileOperationsAndMethodsOn();
        else
            ProfileOperationsAndMethodsOff();
        fi;
    else
        Print( "usage: ProfileOperations( [<true/false>] )" );
    fi;
end;


#############################################################################
##

#F  START_TEST( <id> )  . . . . . . . . . . . . . . . . . . . start test file
##
START_TIME := 0;
START_NAME  := "";

START_TEST := function( name )
    GASMAN("collect");
    START_TIME := Runtime();
    START_NAME := name;
end;


#############################################################################
##
#F  STOP_TEST( <file>, <fac> )  . . . . . . . . . . . . . . .  stop test file
##
STOP_TEST := function( file, fac )
    local   time;

    time := Runtime() - START_TIME;
    Print( START_NAME, "\n" );
    Print( "GAP4stones: ", QuoInt( fac, time ), "\n" );
end;

#############################################################################
##

#E  profile.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
