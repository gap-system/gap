#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the profiling functions.
##


#############################################################################
##
#V  PROFILED_FUNCTIONS  . . . . . . . . . . . . . . list of profiled function
#V  PREV_PROFILED_FUNCTIONS . . . . . . list of previously profiled functions
##
PROFILED_FUNCTIONS := [];
PROFILED_FUNCTIONS_NAMES := [];

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
##  clears all stored profile information.
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
#F  ProfileInfo( <functions>, <mincount>, <mintime> )
##
##  This function collects the information about the currently profiled
##  functions in a table.
##  It is assumed that profiling has been switched off before the function
##  gets called, in order not to mess up the shown data by the function
##  calls inside `ProfileInfo' or inside the function that called it.
##
##  The differences between this function and the corresponding code used in
##  the GAP 4.4 function `DisplayProfile' are that
##  - negative values in the columns 3 and 5 are replaced by zero,
##  - the footer line showing ``OTHER'' contains a value (total memory
##    allocated) in column 4,
##  - the table really contains the rows for those functions that satisfy the
##    conditions defined for `GAPInfo.ProfileThreshold' (its definition
##    says `<=' but the old implementation checked `<'),
##  - the ``TOTAL'' and ``OTHER'' lines show the summation over all profiled
##    functions, including the ones for which no line is shown due to the
##    restrictions imposed by `GAPInfo.ProfileThreshold'.
##
##  This function, in particular the component `funs' in the record it
##  returns, is used also in the package `Browse'.
##
BindGlobal( "ProfileInfo", function( funcs, mincount, mintime )
    local all, nam, pkgnames, pkgpaths, prof, sort, funs, ttim, tsto,
          otim, osto, i, tmp, str, v3, v5, pkg, pi;

    all:= Concatenation( PROFILED_FUNCTIONS,
                         PREV_PROFILED_FUNCTIONS );
    nam:= Concatenation( PROFILED_FUNCTIONS_NAMES,
                         PREV_PROFILED_FUNCTIONS_NAMES );

    if funcs = "all" then
      funcs:= all;
    fi;

    # (Similar code is in `app/methods.g' of the `Browse' package.)
    pkgnames:= ShallowCopy( RecNames( GAPInfo.PackagesLoaded ) );
    pkgpaths:= List( pkgnames, nam -> GAPInfo.PackagesLoaded.( nam )[1] );
    pkgnames:= List( pkgnames, nam -> GAPInfo.PackagesLoaded.( nam )[3] );
    Append( pkgnames, List( GAPInfo.RootPaths, x -> "GAP" ) );
    Append( pkgpaths, GAPInfo.RootPaths );
    Add( pkgnames, "GAP" );
    Add( pkgpaths, "GAPROOT/" ); # used for compiled functions in lib

    prof:= [];
    sort:= [];
    funs:= [];
    ttim:= 0;
    tsto:= 0;
    otim:= 0;
    osto:= 0;
    for i in [ 1 .. Length( all ) ] do
      tmp:= PROF_FUNC( all[i] );
      if ( mincount <= tmp[1] or mintime <= tmp[2] ) and all[i] in funcs then
        if IsString( nam[i] ) then
          str:= nam[i];
        else
          str:= Concatenation( nam[i] );
        fi;
        v3:= tmp[2] - tmp[3];
        if v3 < 0 then
          v3:= 0;
        fi;
        v5:= tmp[4] - tmp[5];
        if v5 < 0 then
          v5:= 0;
        fi;
        pkg:= FilenameFunc( all[i] );
        if pkg <> fail then
          pkg:= PositionProperty( pkgpaths,
                    path -> Length( path ) < Length( pkg )
                    and pkg{ [ 1 .. Length( path ) ] } = path );
        fi;
        if pkg <> fail then
          pkg:= pkgnames[ pkg ];
        elif IsOperation( all[i] ) then
          pkg:= "(oprt.)";
        else
          pkg:= "";
        fi;
        Add( prof, [ tmp[1], tmp[3], v3, tmp[5], v5, pkg, str ] );
        Add( funs, all[i] );
        Add( sort, tmp[2] );
      else
        otim:= otim + tmp[3];
        osto:= osto + tmp[5];
      fi;
      ttim:= ttim + tmp[3];
      tsto:= tsto + tmp[5];
    od;

    # sort functions according to total time spent
    pi:= Sortex( sort );
    prof:= Permuted( prof, pi );
    funs:= Permuted( funs, pi );

    return rec( prof:= prof, ttim:= ttim, tsto:= tsto,
                funs:= funs, otim:= otim, osto:= osto,
                denom:= [ 1, 1, 1, 1024, 1024, 1, 1 ],
                widths:= [ 7, 7, 7, 7, 7, -7, -1 ],
                labelsCol:= [ "  count", "self/ms", "chld/ms", "stor/kb",
                              "chld/kb", "package", "function" ],
                sepCol:= "  " );
end );


#############################################################################
##
#F  DisplayProfile( [<functions>][,][<mincount>, <mintime>] )
#V  GAPInfo.ProfileThreshold
##
##  <#GAPDoc Label="DisplayProfile">
##  <ManSection>
##  <Func Name="DisplayProfile" Arg="[functions][,][mincount, mintime]"/>
##  <Var Name="GAPInfo.ProfileThreshold"/>
##
##  <Description>
##  Called without arguments, <Ref Func="DisplayProfile"/> displays the
##  profile information for profiled operations, methods and functions.
##  If an argument <A>functions</A> is given, only profile information for
##  the functions in the list <A>functions</A> is shown.
##  If two integer values <A>mincount</A>, <A>mintime</A> are given as
##  arguments then the output is restricted to those functions that were
##  called at least <A>mincount</A> times or for which the total time spent
##  (see below) was at least <A>mintime</A> milliseconds.
##  The defaults for <A>mincount</A> and <A>mintime</A> are the entries of
##  the list stored in the global variable
##  <Ref Var="GAPInfo.ProfileThreshold"/>.
##  <P/>
##  The default value of <Ref Var="GAPInfo.ProfileThreshold"/> is
##  <C>[ 10000, 30 ]</C>.
##  <P/>
##  Profile information is displayed in a list of lines for all functions
##  (including operations and methods) which are profiled.
##  For each function,
##  <Q>count</Q> gives the number of times the function has been called.
##  <Q>self/ms</Q> gives the time (in milliseconds) spent in the function
##  itself,
##  <Q>chld/ms</Q> the time (in milliseconds) spent in profiled functions
##  called from within this function,
##  <Q>stor/kb</Q> the amount of storage (in kilobytes) allocated by the
##  function itself,
##  <Q>chld/kb</Q> the amount of storage (in kilobytes) allocated by
##  profiled functions called from within this function, and
##  <Q>package</Q> the name of the &GAP; package to which the function
##  belongs; the entry <Q>GAP</Q> in this column means that the function
##  belongs to the &GAP; library, the entry <Q>(oprt.)</Q> means that the
##  function is an operation (which may belong to several packages),
##  and an empty entry means that <Ref Func="FilenameFunc"/> cannot
##  determine in which file the function is defined.
##  <P/>
##  The list is sorted according to the total time spent in the functions,
##  that is the sum of the values in the columns
##  <Q>self/ms</Q> and <Q>chld/ms</Q>.
##  <P/>
##  At the end of the list, two lines are printed that show the total time
##  used and the total memory allocated by the profiled functions not shown
##  in the list (label <C>OTHER</C>)
##  and by all profiled functions (label <C>TOTAL</C>), respectively.
##  <P/>
##  An interactive variant of <Ref Func="DisplayProfile"/> is the function
##  <Ref Func="BrowseProfile" BookName="browse"/> that is provided by the
##  &GAP; package <Package>Browse</Package>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
GAPInfo.ProfileThreshold:=[10000,30]; # cnt, time

BIND_GLOBAL("DisplayProfile",function( arg )
    local i, funcs, mincount, mintime, prof, w, n, s, j, k, line, str, denom,
          qotim, qosto;

    # stop profiling of functions needed below
    for i  in PROFILED_FUNCTIONS  do
        UNPROFILE_FUNC(i);
    od;

    # unravel the arguments
    if 0 = Length(arg)  then
      funcs:= "all";
      mincount:= GAPInfo.ProfileThreshold[1];
      mintime:= GAPInfo.ProfileThreshold[2];
    elif Length( arg ) = 1 and IsList( arg[1] ) then
      funcs:= arg[1];
      mincount:= GAPInfo.ProfileThreshold[1];
      mintime:= GAPInfo.ProfileThreshold[2];
    elif Length( arg ) = 2 and IsInt( arg[1] ) and IsInt( arg[2] ) then
      funcs:= "all";
      mincount:= arg[1];
      mintime:= arg[2];
    elif Length( arg ) = 3 and IsList( arg[1] ) and IsInt( arg[2] )
                           and IsInt( arg[3] ) then
      funcs:= arg[1];
      mincount:= arg[2];
      mintime:= arg[3];
    elif ForAll( arg, IsFunction ) then
      funcs:= arg;
      mincount:= GAPInfo.ProfileThreshold[1];
      mintime:= GAPInfo.ProfileThreshold[2];
    else
      # Start profiling again.
      for i in PROFILED_FUNCTIONS do
        PROFILE_FUNC( i );
      od;
      Error(
        "usage: DisplayProfile( [<functions>][,][<mincount>, <mintime>] )" );
    fi;

    prof:= ProfileInfo( funcs, mincount, mintime );

    # set width and names
    w:= prof.widths;
    n:= prof.labelsCol;
    s:= prof.sepCol;

    # use screen size for the name
    j := 0;
    k:= Length( w );
    for i  in [ 1 .. k ]  do
        if i <> k then
            j := j + AbsInt(w[i]) + Length(s);
        fi;
    od;
    if w[k] < 0  then
        w[k] := - AbsInt( SizeScreen()[1] - j - Length(s) -2);
    else
        w[k] := AbsInt( SizeScreen()[1] - j - Length(s)-2 );
    fi;

    # print a nice header
    line := "";
    for j  in [ 1 .. k ]  do
        if j <> 1 then
          Append( line, s );
        fi;
        str := String( n[j], w[j] );
        if Length(str) > AbsInt(w[j])  then
            str := str{[1..AbsInt(w[j])-1]};
            Add( str, '*' );
        fi;
        Append( line, str );
    od;
    Print( line, "\n" );

    # print profile
    denom:= prof.denom;
    for i in prof.prof do
        line := "";
        for j  in [ 1 .. k ]  do
            if j <> 1 then
                Append( line, s );
            fi;
            if denom[j] <> 1 then
              str:= String( QuoInt( i[j], denom[j] ), w[j] );
            else
              str:= String( i[j], w[j] );
            fi;
            if Length(str) > AbsInt(w[j])  then
                str := str{[1..AbsInt(w[j])-1]};
                Add( str, '*' );
            fi;
            Append( line, str );
        od;
        Print( line, "\n" );
    od;

    # print other
    qotim:= QuoInt( prof.otim, denom[2] );
    qosto:= QuoInt( prof.osto, denom[4] );
    if 0 < qotim or 0 < qosto then
        line := "";
        for j  in [ 1 .. k ]  do
            if j <> 1 then
              Append( line, s   );
            fi;
            if j = 2  then
                str := String( qotim, w[j] );
            elif j = 4  then
                str := String( qosto, w[j] );
            elif j = k  then
                str := String( "OTHER", w[j] );
            else
                str := String( " ", w[j] );
            fi;
            if Length(str) > AbsInt(w[j])  then
                str := str{[1..AbsInt(w[j])-1]};
                Add( str, '*' );
            fi;
            Append( line, str );
        od;
        Print( line, "\n" );
    fi;

    # print total
    line := "";
    for j  in [ 1 .. k ]  do
        if j <> 1 then
          Append( line, s   );
        fi;
        if j = 2  then
          str := String( prof.ttim, w[j] );
        elif j = 4  then
            str := String( QuoInt( prof.tsto, 1024 ), w[j] );
        elif j = k  then
            str := String( "TOTAL", w[j] );
        else
            str := String( " ", w[j] );
        fi;
        if Length(str) > AbsInt(w[j])  then
            str := str{[1..AbsInt(w[j])-1]};
            Add( str, '*' );
        fi;
        Append( line, str );
    od;
    Print( line, "\n" );

    # start profiling of functions needed above
    for i  in PROFILED_FUNCTIONS  do
        PROFILE_FUNC(i);
    od;
end);


#############################################################################
##
#F  DisplayProfileSummaryForPackages( [<functions>][,]
#F                                    [<mincount>, <mintime>][,][<mode>] )
##
BIND_GLOBAL( "DisplayProfileSummaryForPackages", function( arg )
    local i, modes, funcs, mincount, mintime, mode, prof, n, pkgpos, timepos,
          storpos, pkgnames, sumtime, sumstor, denom, pkg, pos, range, sep,
          widths;

    # Stop profiling of functions needed below.
    for i in PROFILED_FUNCTIONS do
      UNPROFILE_FUNC( i );
    od;

    modes:= [ "time", "stor", "name", "Name" ];

    # Unravel the arguments.
    funcs:= "all";
    mincount:= GAPInfo.ProfileThreshold[1];
    mintime:= GAPInfo.ProfileThreshold[2];
    mode:= "time";
    if 0 = Length(arg)  then
      # Keep these defaults.
    elif Length( arg ) = 1 and arg[1] in modes then
      mode:= arg[1];
    elif Length( arg ) = 1 and IsList( arg[1] )
                           and ForAll( arg[1], IsFunction ) then
      funcs:= arg[1];
    elif Length( arg ) = 2 and IsInt( arg[1] ) and IsInt( arg[2] ) then
      mincount:= arg[1];
      mintime:= arg[2];
    elif Length( arg ) = 2 and IsList( arg[1] )
                           and ForAll( arg[1], IsFunction )
                           and arg[2] in modes then
      funcs:= arg[1];
      mode:= arg[2];
    elif Length( arg ) = 3 and IsList( arg[1] )
                           and ForAll( arg[1], IsFunction )
                           and IsInt( arg[2] ) and IsInt( arg[3] ) then
      funcs:= arg[1];
      mincount:= arg[2];
      mintime:= arg[3];
    elif Length( arg ) = 3 and IsInt( arg[1] ) and IsInt( arg[2] )
                           and arg[3] in modes then
      mincount:= arg[1];
      mintime:= arg[2];
      mode:= arg[3];
    elif Length( arg ) = 4 and IsList( arg[1] )
                           and ForAll( arg[1], IsFunction )
                           and IsInt( arg[2] ) and IsInt( arg[3] )
                           and arg[4] in modes then
      funcs:= arg[1];
      mincount:= arg[2];
      mintime:= arg[3];
      mode:= arg[4];
    elif ForAll( arg, IsFunction ) then
      funcs:= arg;
    else
      # Start profiling again.
      for i in PROFILED_FUNCTIONS do
        PROFILE_FUNC( i );
      od;
      Error( "usage: DisplayProfileSummaryForPackages( ",
             "[<functions>][,][<mincount>, <mintime>][,][<mode>] )" );
    fi;

    # Collect the data.
    prof:= ProfileInfo( funcs, mincount, mintime );

    # Initialize values.
    n:= prof.labelsCol;
    pkgpos:= Position( n, "package" );
    timepos:= Position( n, "self/ms" );
    storpos:= Position( n, "stor/kb" );
    pkgnames:= [ "GAP" ];
    sumtime:= [ 0 ];
    sumstor:= [ 0 ];

    # Distribute values.
    denom:= prof.denom;
    for i in prof.prof do
      pkg:= i[ pkgpos ];
      if pkg = "GAP" or pkg = "" then
        pos:= 1;
      else
        pos:= Position( pkgnames, pkg );
        if pos = fail then
          Add( pkgnames, pkg );
          pos:= Length( pkgnames );
          sumtime[ pos ]:= 0;
          sumstor[ pos ]:= 0;
        fi;
      fi;
      sumtime[ pos ]:= sumtime[ pos ] + i[ timepos ];
      sumstor[ pos ]:= sumstor[ pos ] + i[ storpos ];
    od;
    sumtime:= List( sumtime, x -> QuoInt( x, denom[ timepos ] ) );
    sumstor:= List( sumstor, x -> QuoInt( x, denom[ storpos ] ) );

    # Sort data.
    range:= [ 1 .. Length( pkgnames ) ];
    if   mode = "time" then
      SortParallel( - sumtime, range );
    elif mode = "stor" then
      SortParallel( - sumstor, range );
    elif mode = "name" then
      SortParallel( List( pkgnames, LowercaseString ), range );
    else      # "Name"
      SortParallel( ShallowCopy( pkgnames ), range );
    fi;

    # Print profile information.
    sep:= "  ";
    widths:= [ - Maximum( Length( "package" ),
                          Maximum( List( pkgnames, Length ) ) ),
               Maximum( Length( "self/ms" ),
                        Length( String( Maximum( sumtime ) ) ) ),
               Maximum( Length( "stor/kb" ),
                        Length( String( Maximum( sumstor ) ) ) ) ];
    Print( "Profile information by packages:\n",
           sep, String( "package", widths[1] ),
           sep, String( "self/ms", widths[2] ),
           sep, String( "stor/kb", widths[3] ), "\n" );
    for i in range do
      Print( sep, String( pkgnames[i], widths[1] ),
             sep, String( sumtime[i], widths[2] ),
             sep, String( sumstor[i], widths[3] ), "\n" );
    od;

    # Start profiling of functions needed above.
    for i in PROFILED_FUNCTIONS do
      PROFILE_FUNC( i );
    od;
end );


#############################################################################
##
#F  ProfileFunctions( <funcs> )
##
##  <#GAPDoc Label="ProfileFunctions">
##  <ManSection>
##  <Func Name="ProfileFunctions" Arg='funcs'/>
##
##  <Description>
##  starts profiling for all function in the list <A>funcs</A>.
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
          j := j+1;
      fi;
  od;
  PREV_PROFILED_FUNCTIONS      :=Compacted(PREV_PROFILED_FUNCTIONS);
  PREV_PROFILED_FUNCTIONS_NAMES:=Compacted(PREV_PROFILED_FUNCTIONS_NAMES);
  for f in funcs do
      PROFILE_FUNC(f);
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
##  stops profiling for all function in the list <A>funcs</A>.
##  Recorded information is still kept, so you can  display it even after
##  turning the profiling off.
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
##  starts profiling of the methods for all operations in the list
##  <A>ops</A>.
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
            meth := MethodsOperation( op, i );
            if meth <> fail  then
                for j in meth do
                    Add( funcs, j.func );
                    if name = j.info  then
                        Add( names, [ "Meth(", name, ")" ] );
                    else
                        Add( names, j.info );
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
##  stops profiling of the methods for all operations in the list <A>ops</A>.
##  Recorded information is still kept, so you can  display it even after
##  turning the profiling off.
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
            meth := MethodsOperation( op, i );
            if meth <> fail  then
                for j in meth do
                    Add( funcs, j.func );
                od;
            fi;
        od;
    od;
    UnprofileFunctions(funcs);
end);


#############################################################################
##
#F  ProfileOperations( [<true/false>] ) . . . . . . . . .  start/stop/display
##
##  <#GAPDoc Label="ProfileOperations">
##  <ManSection>
##  <Func Name="ProfileOperations" Arg='[bool]'/>
##
##  <Description>
##  Called with argument <K>true</K>,
##  <Ref Func="ProfileOperations"/>
##  starts profiling of all operations.
##  Old profile information for all operations is cleared.
##  A function call with the argument <K>false</K>
##  stops profiling of all operations.
##  Recorded information is still kept,
##  so you can display it even after turning the profiling off.
##  <P/>
##  When <Ref Func="ProfileOperations"/> is called without argument,
##  profile information for all operations is displayed
##  (see&nbsp;<Ref Func="DisplayProfile"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
PROFILED_OPERATIONS := [];

BIND_GLOBAL("ProfileOperationsOn",function()
    local   prof;

    # Note that the list of operations may have grown since the last call.
    if IsHPCGAP then
        prof := MakeImmutable(FromAtomicList(OPERATIONS));
    else
        prof := OPERATIONS;
    fi;
    PROFILED_OPERATIONS := prof;
    UnprofileMethods(prof);
    ProfileFunctions( prof );
end);

BIND_GLOBAL("ProfileOperationsOff",function()
    UnprofileFunctions(PROFILED_OPERATIONS);
    UnprofileMethods(PROFILED_OPERATIONS);

    # methods for the kernel functions
    UnprofileMethods(\+,\-,\*,\/,\^,\mod,\<,\=,\in,
                     \.,\.\:\=,IsBound\.,Unbind\.,
                     \[\],\[\]\:\=,IsBound\[\],Unbind\[\]);
#T Why?  These operations are listed in PROFILED_OPERATIONS!
end);

BIND_GLOBAL("ProfileOperations",function( arg )
    if 0 = Length(arg)  then
        DisplayProfile(PROFILED_OPERATIONS);
    elif arg[1] = true then
      ProfileOperationsOn();
    elif arg[1] = false then
      ProfileOperationsOff();
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
##  <Func Name="ProfileOperationsAndMethods" Arg='[bool]'/>
##
##  <Description>
##  Called with argument <K>true</K>,
##  <Ref Func="ProfileOperationsAndMethods"/>
##  starts profiling of all operations and their methods.
##  Old profile information for these functions is cleared.
##  A function call with the argument <K>false</K>
##  stops profiling of all operations and their methods.
##  Recorded information is still kept,
##  so you can display it even after turning the profiling off.
##  <P/>
##  When <Ref Func="ProfileOperationsAndMethods"/> is called without
##  argument,
##  profile information for all operations and their methods is displayed,
##  see&nbsp;<Ref Func="DisplayProfile"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ProfileOperationsAndMethodsOn",function()
    local   prof;

    if IsHPCGAP then
        prof := MakeImmutable(FromAtomicList(OPERATIONS));
    else
        prof := OPERATIONS;
    fi;
    PROFILED_OPERATIONS := prof;
    ProfileFunctions( prof );
    ProfileMethods(prof);

    # methods for the kernel functions
    ProfileMethods(\+,\-,\*,\/,\^,\mod,\<,\=,\in,
                     \.,\.\:\=,IsBound\.,Unbind\.,
                     \[\],\[\]\:\=,IsBound\[\],Unbind\[\]);
#T Why?  These operations are listed in PROFILED_OPERATIONS!
end);

ProfileOperationsAndMethodsOff := ProfileOperationsOff;

BIND_GLOBAL("ProfileOperationsAndMethods",function( arg )
    if 0 = Length(arg)  then
        DisplayProfile(Concatenation(PROFILED_OPERATIONS,PROFILED_METHODS));
    elif arg[1] = true then
      ProfileOperationsAndMethodsOn();
    elif arg[1] = false then
      ProfileOperationsAndMethodsOff();
    else
        Print( "usage: ProfileOperationsAndMethods( [<true/false>] )" );
    fi;
end );


#############################################################################
##
#F  ProfileGlobalFunctions( [<true/false>] )
##
##  <#GAPDoc Label="ProfileGlobalFunctions">
##  <ManSection>
##  <Func Name="ProfileGlobalFunctions" Arg='[bool]'/>
##
##  <Description>
##  Called with argument <K>true</K>,
##  <Ref Func="ProfileGlobalFunctions"/>
##  starts profiling of all functions that have been declared via
##  <Ref Func="DeclareGlobalFunction"/>.
##  Old profile information for all these functions is cleared.
##  A function call with the argument <K>false</K>
##  stops profiling of all these functions.
##  Recorded information is still kept,
##  so you can display it even after turning the profiling off.
##  <P/>
##  When <Ref Func="ProfileGlobalFunctions"/> is called without argument,
##  profile information for all global functions is displayed,
##  see&nbsp;<Ref Func="DisplayProfile"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
PROFILED_GLOBAL_FUNCTIONS := [];
if IsHPCGAP then
    MakeThreadLocal("PROFILED_GLOBAL_FUNCTIONS");
fi;

BIND_GLOBAL( "ProfileGlobalFunctions", function( arg )
    local name, func;
    if 0 = Length(arg) then
        DisplayProfile( PROFILED_GLOBAL_FUNCTIONS );
    elif arg[1] = true then
        PROFILED_GLOBAL_FUNCTIONS  := [];
        atomic readonly GLOBAL_FUNCTION_NAMES do
            for name in GLOBAL_FUNCTION_NAMES do
                if IsBoundGlobal(name) then
                    func := ValueGlobal(name);
                    if IsFunction(func) then
                        Add(PROFILED_GLOBAL_FUNCTIONS, func);
                    fi;
                fi;
            od;
        od;
        ProfileFunctions(PROFILED_GLOBAL_FUNCTIONS);
    elif arg[1] = false then
        UnprofileFunctions(PROFILED_GLOBAL_FUNCTIONS);
    else
      Print( "usage: ProfileGlobalFunctions( [<true/false>] )" );
    fi;
end);


#############################################################################
##
#F  ProfileFunctionsInGlobalVariables( [<true/false>] )
##
##  <ManSection>
##  <Func Name="ProfileFunctionsInGlobalVariables" Arg='[bool]'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
PROFILED_GLOBAL_VARIABLE_FUNCTIONS := [];

BIND_GLOBAL( "ProfileFunctionsInGlobalVariables", function( arg )
    local name, func, r, nam;
    if 0 = Length(arg) then
        DisplayProfile( PROFILED_GLOBAL_VARIABLE_FUNCTIONS );
    elif arg[1] = true then
        PROFILED_GLOBAL_VARIABLE_FUNCTIONS  := [];
        for name in NamesGVars() do
            if IsBoundGlobal(name) then
                func := ValueGlobal(name);
                if IsFunction(func) then
                    Add(PROFILED_GLOBAL_VARIABLE_FUNCTIONS, func);
                elif IsRecord( func ) then
                  r:= func;
                  for nam in RecNames( r ) do
                    func:= r.( nam );
                    if IsFunction( func ) then
                      Add( PROFILED_GLOBAL_VARIABLE_FUNCTIONS, func );
                    fi;
                  od;
                fi;
            fi;
        od;
        ProfileFunctions(PROFILED_GLOBAL_VARIABLE_FUNCTIONS);
    elif arg[1] = false then
        UnprofileFunctions(PROFILED_GLOBAL_VARIABLE_FUNCTIONS);
        PROFILED_GLOBAL_VARIABLE_FUNCTIONS := [];
    else
      Print( "usage: ProfileFunctionsInGlobalVariables( [<true/false>] )" );
    fi;
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
    local   cache,  names,  i;

    cache := ShallowCopy(OPERS_CACHE_INFO());

    # remove two last entries (currently not supported)
    Remove(cache); Remove(cache);

    # add type cache data
    Append( cache, [
        NEW_TYPE_CACHE_HIT,
        NEW_TYPE_CACHE_MISS,
    ] );

    names := [
        "AND_FLAGS cache hits",
        "AND_FLAGS cache miss",
        "AND_FLAGS cache losses",
        "Operation L1 cache hits",
        "Operation TryNextMethod",
        "Operation cache misses",
        "IS_SUBSET_FLAGS calls",
        "WITH_HIDDEN_IMPS hits",
        "WITH_HIDDEN_IMPS misses",
        "WITH_IMPS hits",
        "WITH_IMPS misses",
        "NEW_TYPE hits",
        "NEW_TYPE misses",
    ];

    if Length(names) <> Length(cache)  then
        Error( "<names> and <cache> have different lengths" );
    fi;

    for i  in [1..Length(cache)]  do
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
    NEW_TYPE_CACHE_HIT := 0;
    NEW_TYPE_CACHE_MISS := 0;
end);


#############################################################################
##
#F  START_TEST( <name> )  . . . . . . . . . . . . . . . . . . start test file
#F  STOP_TEST( <name> )  . . . . . . . . . . . . . . . . . . . stop test file
##
##  <#GAPDoc Label="StartStopTest">
##  <ManSection>
##  <Heading>Starting and stopping test</Heading>
##  <Func Name="START_TEST" Arg='name'/>
##  <Func Name="STOP_TEST" Arg='name'/>
##
##  <Description>
##  <Ref Func="START_TEST"/> and <Ref Func="STOP_TEST"/> may be optionally
##  used in files that are read via <Ref Func="Test"/>. If used,
##  <Ref Func="START_TEST"/> reinitialize the caches and the global
##  random number generator, in order to be independent of the reading
##  order of several test files. Furthermore, the assertion level
##  (see&nbsp;<Ref Func="Assert"/>) is set to <M>2</M> (if it was lower before) by
##  <Ref Func="START_TEST"/> and set back to the previous value in the
##  subsequent <Ref Func="STOP_TEST"/> call.
##  <P/>
##  To use these options, a test file should be started with a line
##  <P/>
##  <Log><![CDATA[
##  gap> START_TEST( "arbitrary identifier string" );
##  ]]></Log>
##  <P/>
##  (Note that the <C>gap> </C> prompt is part of the line!)
##  <P/>
##  and should be finished with a line
##  <P/>
##  <Log><![CDATA[
##  gap> STOP_TEST( "same identifier string as for START_TEST" );
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
START_TEST := function( name )
    if IsBound( GAPInfo.TestData.START_NAME ) then
      Info( InfoWarning, 2, "`START_TEST' was already called with name `",
             GAPInfo.TestData.START_NAME, "'" );
    fi;
    FlushCaches();
    Reset(GlobalRandomSource);
    Reset(GlobalMersenneTwister);
    CollectGarbage(true);
    GAPInfo.TestData.START_TIME := Runtime();
    GAPInfo.TestData.START_NAME := name;
    GAPInfo.TestData.AssertionLevel:= AssertionLevel();
    if GAPInfo.TestData.AssertionLevel < 2 then
        SetAssertionLevel( 2 );
    fi;
    GAPInfo.TestData.InfoPerformanceLevel:= InfoLevel( InfoPerformance );
    if GAPInfo.TestData.InfoPerformanceLevel > 0 then
        SetInfoLevel( InfoPerformance, 0 );
    fi;
end;

STOP_TEST_QUIET := function( name, args... )
    local time;

    if not IsBound( GAPInfo.TestData.START_NAME ) then
      Error( "`STOP_TEST' command without `START_TEST' command for `",
             name, "'" );
    fi;

    if GAPInfo.TestData.START_NAME <> name then
      Info( InfoWarning, 2, "`STOP_TEST' command with name `", name,
            "' after `START_TEST' ", "command with name `",
            GAPInfo.TestData.START_NAME, "'" );
    fi;

    time:= Runtime() - GAPInfo.TestData.START_TIME;
    SetAssertionLevel( GAPInfo.TestData.AssertionLevel );
    SetInfoLevel( InfoPerformance, GAPInfo.TestData.InfoPerformanceLevel );
    Unbind( GAPInfo.TestData.AssertionLevel );
    Unbind( GAPInfo.TestData.START_TIME );
    Unbind( GAPInfo.TestData.START_NAME );
    Unbind( GAPInfo.TestData.InfoPerformanceLevel );

    return time;
end;

STOP_TEST := function( name, args... )
    local time;

    time := STOP_TEST_QUIET( name );

    Print( name, "\n" );
    Print( "msecs: ", time, "\n" );

end;
