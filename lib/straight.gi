#############################################################################
##
#W  straight.gi              GAP library                        Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1999,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the implementations of methods and functions
##  for straight line programs.
##
Revision.straight_gi :=
    "@(#)$Id$";


#############################################################################
##
#V  StraightLineProgramsFamily
#V  StraightLineProgramsDefaultType
##
BindGlobal( "StraightLineProgramsFamily",
    NewFamily( "StraightLineProgramsFamily", IsStraightLineProgram ) );

BindGlobal( "StraightLineProgramsDefaultType",
    NewType( StraightLineProgramsFamily,
             IsStraightLineProgram and IsAttributeStoringRep
                                   and HasLinesOfStraightLineProgram ) );


#############################################################################
##
#F  StraightLineProgram( <lines>[, <nrgens>] )
#F  StraightLineProgram( <string>, <gens> )
#F  StraightLineProgramNC( <lines>[, <nrgens>] )
#F  StraightLineProgramNC( <string>, <gens> )
##
InstallGlobalFunction( StraightLineProgram, function( arg )
    local result;
    result:= CallFuncList( StraightLineProgramNC, arg );
    if     not IsStraightLineProgram( result )
       or not IsInternallyConsistent( result ) then
      result:= fail;
    fi;
    return result;
end );


InstallGlobalFunction( StraightLineProgramNC, function( arg )

    local lines, nrgens, prog;

    # Get the arguments.
    if   Length( arg ) = 1 and not IsString( arg[1] ) then
      lines  := arg[1];
    elif Length( arg ) = 2 and IsString( arg[1] ) then
      lines:= [];
      if not StringToStraightLineProgram( arg[1], arg[2], lines ) then
        return fail;
      fi;
      nrgens:= Length( arg[2] );
    elif Length( arg ) = 2 then
      lines  := arg[1];
      nrgens := arg[2];
    else
      Error( "usage: StraightLineProgramNC( <lines>[, <nrgens>] )" );
    fi;

    prog:= rec();
    ObjectifyWithAttributes( prog, StraightLineProgramsDefaultType,
                             LinesOfStraightLineProgram, lines );
    if IsBound( nrgens ) and IsPosInt( nrgens ) then
      SetNrInputsOfStraightLineProgram( prog, nrgens );
    fi;

    return prog;
end );


#############################################################################
##
#F  StringToStraightLineProgram( <string>, <gens>, <script> )
##
InstallGlobalFunction( StringToStraightLineProgram,
    function( string, gens, script )

    local pos,
          extrep,
          len,
          sub,
          ppos,
          exp,
          sign,
          slen,
          open,
          i, j;

    # If the string contains `*' signs then remove them.
    if '*' in string then
      string:= Filtered( string, char -> char <> '*' );
    fi;

    # Split the string according to brackets `(' and `)'
    pos:= Position( string, '(' );
    if pos = fail then

      # Simply create a word.
      extrep:= [];
      while not IsEmpty( string ) do 
        len:= Length( string );
        pos:= First( [ 1 .. len ], i -> string{ [ 1 .. i ] } in gens );
        if pos = fail then return false; fi;
        ppos:= Position( gens, string{ [ 1 .. pos ] } );
        pos:= pos + 1;
        if pos < len and string[ pos ] = '^' then
          exp:= 0;
          pos:= pos + 1;
          while pos <= len and IsDigitChar( string[ pos ] ) do
            exp:= 10 * exp + Position( "0123456789", string[ pos ] ) - 1;
            pos:= pos + 1;
          od;
        else
          exp:= 1;
        fi;
        Append( extrep, [ ppos, exp ] );
        string:= string{ [ pos .. len ] };
      od;

      if not IsEmpty( extrep ) then
        Add( script, [ extrep, Length( script ) + Length( gens ) + 1 ] );
      fi;
      return true;

    elif 1 < pos then

      # Split before the bracket.
      if not StringToStraightLineProgram(
                 string{ [ 1 .. pos-1 ] }, gens, script ) then
        return false;
      fi;
      j:= Length( script ) + Length( gens );
      if not StringToStraightLineProgram(
                 string{ [ pos .. Length( string ) ] }, gens, script ) then
        return false;
      fi;
      slen:= Length( script ) + Length( gens );
      Add( script, [ [ j, 1, slen, 1 ], slen + 1 ] );
      return true;

    else

      # Find the corresponding closing bracket.
      open:= 0;
      len:= Length( string );
      for i in [ 2 .. len ] do
        if string[i] = '(' then
          open:= open+1;
        elif string[i] = ')' then
          if 0 < open then
            open:= open-1;
          else

            # The bracket may be powered or be multiplied.
            if i < len and string[ i+1 ] = '^' then

              exp:= 0;
              j:= i+2;
              sign:= 1;
              if string[j] = '-' then
                sign:= -1;
                j:= j+1;
              fi;
              while j <= len and IsDigitChar( string[j] ) do
                exp:= 10 * exp + Position( "0123456789", string[j] ) - 1;
                j:= j + 1;
              od;
              if not StringToStraightLineProgram(
                         string{ [ 2 .. i-1 ] }, gens, script ) then
                return false;
              fi;
              slen:= Length( script ) + Length( gens ) + 1;
              Add( script, [ [ slen - 1, sign * exp ], slen ] );
              if j <= len then
                if not StringToStraightLineProgram(
                           string{ [ j .. len ] }, gens, script ) then
                  return false;
                fi;
                j:= Length( script ) + Length( gens );
                Add( script, [ [ slen, 1, j, 1 ], j + 1 ] );
              fi;

            else

              if not StringToStraightLineProgram(
                         string{ [ 2 .. i-1 ] }, gens, script ) then
                return false;
              fi;
              j:= Length( script ) + Length( gens );
              if not StringToStraightLineProgram(
                         string{ [ i+1 .. len ] }, gens, script ) then
                return false;
              fi;
              slen:= Length( script ) + Length( gens );
              Add( script, [ [ j, 1, slen, 1 ], slen + 1 ] );

            fi;
            return true;

          fi;
        fi;
      od;
      return false;

    fi;
end );


#############################################################################
##
#M  NrInputsOfStraightLineProgram( <prog> )
##
##  If no lines of type 1. occur then the number of generators can be
##  read off from the lines;
##  it is equal to the maximum of positions such that in a step of the
##  program the entry is accessed but the position has not been assigned
##  before.
##
InstallMethod( NrInputsOfStraightLineProgram,
    "for a straight line program",
    true,
    [ IsStraightLineProgram ], 0,
    function( prog )

    local defined,    # list of currently assigned positions
          maxinput,   # current maximum of input needed
          lines,      # lines of `prog'
          len,        # length of `lines'
          adjust,     # local function to  increase the number
          line,       # one line of the program
          i, j;       # loop over the lines

    defined:= [];
    maxinput:= 0;
    lines:= LinesOfStraightLineProgram( prog );
    len:= Length( lines );

    adjust:= function( line )
      local needed;
      needed:= Difference( line{ [ 1, 3 .. Length( line ) - 1 ] },
                           defined );
      if not IsEmpty( needed ) then
        needed:= MaximumList( needed );
        if maxinput < needed then
          maxinput:= needed;
        fi;
      fi;
    end;

    # Inspect the lines.
    for i in [ 1 .. len ] do

      line:= lines[i];
      if ForAll( line, IsInt ) then

        if i = len then
          adjust( line );
        else
          Error( "<prog> contains a line of kind 1." );
        fi;

      elif Length( line ) = 2 and IsInt( line[2] ) then

        adjust( line[1] );
        AddSet( defined, line[2] );

      elif i = len and ForAll( line, IsList ) then

        for j in line do
          adjust( j );
        od;

      fi;

    od;

    return maxinput;
end );


#############################################################################
##
#M  ResultOfStraightLineProgram( <prog>, <gens> )
##
BindGlobal( "ResultOfLineOfStraightLineProgram",
    function( line, r )

    local new, i;

    new:= r[ line[1] ];
    if line[2] <> 1 then
      new:= new^line[2];
    fi;
    for i in [ 4, 6 .. Length( line ) ] do
      if line[i] = 1 then
        new:= new * r[ line[ i-1 ] ];
      else
        new:= new * r[ line[ i-1 ] ]^line[i];
      fi;
    od;
    return new;
end );

InstallMethod( ResultOfStraightLineProgram,
    "for a straight line program, and a homogeneous list",
    true,
    [ IsStraightLineProgram, IsHomogeneousList ], 0,
    function( prog, gens )

    local r, line;

    # Initialize the list of intermediate results.
    r:= ShallowCopy( gens );

    # Loop over the program.
    for line in LinesOfStraightLineProgram( prog ) do

      if   not IsEmpty( line ) and IsInt( line[1] ) then

        # The line describes a word to be appended.
        Add( r, ResultOfLineOfStraightLineProgram( line, r ) );

      elif 2 <= Length( line ) and IsInt( line[2] ) then

        # The line describes a word that shall replace.
        r[ line[2] ]:= ResultOfLineOfStraightLineProgram( line[1], r );

      else

        # The line describes a list of words to be returned.
        return List( line, l -> ResultOfLineOfStraightLineProgram( l, r ) );

      fi;

    od;

    return r[ Length( r ) ];
    end );


#############################################################################
##
#M  Display( <prog> )
#M  Display( <prog>, <record> )
##
InstallMethod( Display,
    "for a straight line program",
    true,
    [ IsStraightLineProgram ], 0,
    function( prog )
    Display( prog, rec() );
    end );

InstallOtherMethod( Display,
    "for a straight line program, and a record",
    true,
    [ IsStraightLineProgram, IsRecord ], 0,
    function( prog, record )
    local gensnames,
          listname,
          PrintLine,
          i,
          lines,
          len,
          line,
          j;

    # Get and check the arguments.
    if IsBound( record.gensnames ) then
      gensnames:= record.gensnames;
    else
      gensnames:= List( [ 1 ..  NrInputsOfStraightLineProgram( prog ) ],
                        i -> Concatenation( "g", String( i ) ) );
    fi;
    if IsBound( record.listname ) then
      listname:= record.listname;
    else
      listname:= "r";
    fi;

    PrintLine := function( line )
      local j;
      for j in [ 2, 4 .. Length( line )-2 ] do
        Print( "r[", line[ j-1 ], "]" );
        if line[j] <> 1 then
          Print( "^", line[j] );
        fi;
        Print( "*" );
      od;
      j:= Length( line );
      if 0 < j then
        Print( "r[", line[ j-1 ], "]" );
        if line[j] <> 1 then
          Print( "^", line[j] );
        fi;
      fi;
    end;

    # Print the initialisation.
    Print( "# input:\n" );
    Print( listname, ":= [ " );
    if not IsEmpty( gensnames ) then
      Print( gensnames[1] );
    fi;
    for i in [ 2 .. Length( gensnames ) ] do
      Print( ", ", gensnames[i] );
    od;
    Print( " ];\n" );

    # Loop over the lines.
    lines:= LinesOfStraightLineProgram( prog );
    len:= Length( gensnames );
    Print( "# program:\n" );
    for i in [ 1 .. Length( lines ) ] do

      line:= lines[i];
      if   Length( line ) = 2 and IsList( line[1] )
                              and IsPosInt( line[2] ) then

        Print( "r[", line[2], "]:= " );
        PrintLine( line[1] );
        Print( ";\n" );
        if len < line[2] then
          len:= line[2];
        fi;

      elif not IsEmpty( line ) and ForAll( line, IsInt ) then

        len:= len + 1;
        Print( "r[", len, "]:= " );
        PrintLine( line );
        Print( ";\n" );

      elif ForAll( line, IsList ) and i = Length( lines ) then

        Print( "# return values:\n[ " );
        len:= Length( line );
        for j in [ 1 .. len - 1 ] do
          PrintLine( line[j] );
          Print( ", " );
        od;
        if 0 < len then
          PrintLine( line[ len ] );
        fi;
        Print( " ]\n" );
        return;

      fi;

    od;

    Print( "# return value:\nr[", len, "]\n" );
    end );


#############################################################################
##
#M  IsInternallyConsistent( <prog> )
##
InstallMethod( IsInternallyConsistent,
    "for a straight line program",
    true,
    [ IsStraightLineProgram ], 0,
    function( prog )

    local lines,
          nrgens,
          defined,
          testline,
          len,
          i,
          line;

    lines:= LinesOfStraightLineProgram( prog );
    if not IsList( lines ) or IsEmpty( lines ) then
      return false;
    fi;

    if HasNrInputsOfStraightLineProgram( prog ) then
      nrgens:= NrInputsOfStraightLineProgram( prog );
      defined:= [ 1 .. nrgens ];
    else
      defined:= [];
    fi;

    testline:= function( line )
      local len, gens;

      # The external representation of an associative word has even length,
      len:= Length( line );
      if len mod 2 <> 0 then
        return false;
      fi;

      # and the generator numbers are stored at odd positions.
      gens:= line{ [ 1, 3 .. len-1 ] };
      if not ForAll( gens, IsPosInt ) then
        return false;
      fi;

      # If the number of generators is stored then check
      # that only defined positions are accessed.
      if IsBound( nrgens ) and not IsSubset( defined, gens ) then
        return false;
      else
        return true;
      fi;
    end;

    len:= Length( lines );
    for i in [ 1 .. len ] do

      line:= lines[i];

      if   not IsList( line ) then

        return false;

      elif not IsEmpty( line ) and ForAll( line, IsInt ) then

        if not testline( line ) or ( i < len and not IsBound( nrgens ) )then
          return false;
        fi;
        AddSet( defined, Length( defined ) + 1 );

      elif Length( line ) = 2 and IsPosInt( line[2] ) then

        if not ( IsList( line[1] ) and ForAll( line[1], IsInt ) ) then
          return false;
        fi;
        if not testline( line[1] ) then
          return false;
        fi;
        AddSet( defined, line[2] );

      elif i = len and ForAll( line, x -> IsList( x )
                                          and ForAll( x, IsInt ) ) then

        return ForAll( line, testline );

      else

        # The syntax of the line is not correct.
        return false;

      fi;

    od;

    return true;
    end );


#############################################################################
##
#M  PrintObj( <prog> )
##
InstallMethod( PrintObj,
    "for a straight line program",
    true,
    [ IsStraightLineProgram ], 0,
    function( prog )
    Print( "StraightLineProgram( ",
           LinesOfStraightLineProgram( prog ) );
    if HasNrInputsOfStraightLineProgram( prog ) then
      Print( ", ", NrInputsOfStraightLineProgram( prog ) );
    fi;
    Print( " )" );
    end );


#############################################################################
##
#M  ViewObj( <prog> )
##
InstallMethod( ViewObj,
    "for a straight line program",
    true,
    [ IsStraightLineProgram ], 0,
    function( prog )
    Print( "<straight line program>" );
    end );


#############################################################################
##
#F  StringOfResultOfStraightLineProgram( <prog>, <gensnames>[, \"LaTeX\"] )
##
##  `StringOfResultOfStraightLineProgram' returns a string that describes the
##  result of the straight line program (see~"IsStraightLineProgram") <prog> 
##  as word(s) in terms of the strings in the list <gensnames>.
##  If the result of <prog> is a single element then the return value of
##  `StringOfResultOfStraightLineProgram' is a string consisting of the
##  entries of <gensnames>, opening and closing brackets `(' and `)',
##  and powering by integers via `^'.
##  If the result of <prog> is a list of elements then the return value of
##  `StringOfResultOfStraightLineProgram' is a comma separated concatenation
##  of the strings of the single elements, enclosed in `[' and `]'.
##
BindGlobal( "StringOfResultOfLineOfStraightLineProgram",
    function( line, r, isatomic, LaTeX )

    local new, i;

    new:= "";
    for i in [ 2, 4 .. Length( line ) ] do
      if line[i] = 1 then
        Append( new, r[ line[ i-1 ] ] );
      else
        if not isatomic[ line[ i-1 ] ] then
          Add( new, '(' );
        fi;
        Append( new, r[ line[ i-1 ] ] );
        if not isatomic[ line[ i-1 ] ] then
          Add( new, ')' );
        fi;
        Add( new, '^' );
        if LaTeX then
          Add( new, '{' );
        fi;
        Append( new, String( line[i] ) );
        if LaTeX then
          Add( new, '}' );
        fi;
      fi;
    od;
    return new;
end );

InstallGlobalFunction( StringOfResultOfStraightLineProgram, function( arg )

    local prog,
          gensnames,
          LaTeX,
          r,
          a,
          line,
          result,
          l;

    # Get and check the arguments.
    if   Length( arg ) = 2 and IsStraightLineProgram( arg[1] )
                           and IsList( arg[2] ) then

      prog:= arg[1];
      gensnames:= arg[2];
      LaTeX:= false;

    elif Length( arg ) = 3 and IsStraightLineProgram( arg[1] )
                           and IsList( arg[2] )
                           and IsString( arg[3] )
                           and LowercaseString( arg[3] ) = "latex" then

      prog:= arg[1];
      gensnames:= arg[2];
      LaTeX:= true;

    else
      Error( "usage: StringOfResultOfStraightLineProgram( <prog>, ",
             "<gensnames>[, \"LaTeX\"] )" );
    fi;

    # Initialize the list of intermediate results.
    r:= ShallowCopy( gensnames );
    a:= ListWithIdenticalEntries( Length( r ), true );

    # Loop over the program.
    for line in LinesOfStraightLineProgram( prog ) do

      if   not IsEmpty( line ) and IsInt( line[1] ) then

        # The line describes a word to be appended.
        Add( r, StringOfResultOfLineOfStraightLineProgram( line,
                    r, a, LaTeX ) );
        a[ Length(r) ]:= false;

      elif 2 <= Length( line ) and IsInt( line[2] ) then

        # The line describes a word that shall replace.
        r[ line[2] ]:= StringOfResultOfLineOfStraightLineProgram( line[1],
                           r, a, LaTeX );
        a[ line[2] ]:= false;

      else

        # The line describes a list of words to be returned.
        result:= "[ ";
        for l in line do
          Append( result,
                  StringOfResultOfLineOfStraightLineProgram( l,
                      r, a, LaTeX ) );
          Append( result, ", " );
        od;
        if not IsEmpty( line ) then
          Unbind( result[ Length( result ) ] );
          Unbind( result[ Length( result ) ] );
        fi;
        Append( result, " ]" );
        return result;

      fi;

    od;

    return r[ Length( r ) ];
end );


#############################################################################
##
#E

