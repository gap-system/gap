#############################################################################
##
#W  straight.gi              GAP library                        Thomas Breuer
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1999,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the implementations of methods and functions
##  for straight line programs.
##
##  1. Functions for straight line programs
##  2. Functions for elements represented by straight line programs
##
Revision.straight_gi :=
    "@(#)$Id$";


#############################################################################
##
##  1. Functions for straight line programs
##


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
          sign:= 1;
          pos:= pos + 1;
          if pos <=len and string[ pos ] = '-' then
            sign:= -1;
            pos:= pos + 1;
          fi;
          while pos <= len and IsDigitChar( string[ pos ] ) do
            exp:= 10 * exp + Position( "0123456789", string[ pos ] ) - 1;
            pos:= pos + 1;
          od;
          exp:= sign * exp;
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
    [ IsStraightLineProgram ],
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
    [ IsStraightLineProgram, IsHomogeneousList ],
    function( prog, gens )

    local r,         # list of intermediate results
          respos,    # position of the current intermediate result of `prog'
          line;      # loop over the lines

    # Initialize the list of intermediate results.
    r:= ShallowCopy( gens );
    respos:= false;

    # Loop over the program.
    for line in LinesOfStraightLineProgram( prog ) do

      if   not IsEmpty( line ) and IsInt( line[1] ) then

        # The line describes a word to be appended.
        Add( r, ResultOfLineOfStraightLineProgram( line, r ) );
        respos:= Length( r );

      elif 2 <= Length( line ) and IsInt( line[2] ) then

        # The line describes a word that shall replace.
        r[ line[2] ]:= ResultOfLineOfStraightLineProgram( line[1], r );
        respos:= line[2];

      else

        # The line describes a list of words to be returned.
        return List( line, l -> ResultOfLineOfStraightLineProgram( l, r ) );

      fi;

    od;

    # Return the result.
    return r[ respos ];
    end );


#############################################################################
##
#M  Display( <prog> )
#M  Display( <prog>, <record> )
##
InstallMethod( Display,
    "for a straight line program",
    [ IsStraightLineProgram ],
    function( prog )
    Display( prog, rec() );
    end );

InstallOtherMethod( Display,
    "for a straight line program, and a record",
    [ IsStraightLineProgram, IsRecord ],
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
        if len < line[2] or i = Length( lines ) then
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
    [ IsStraightLineProgram ],
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
    [ IsStraightLineProgram ],
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
    [ IsStraightLineProgram ],
    function( prog )
    Print( "<straight line program>" );
    end );


#############################################################################
##
#F  StringOfResultOfStraightLineProgram( <prog>, <gensnames>[, \"LaTeX\"] )
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
          respos,
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
    respos:= false;

    # Loop over the program.
    for line in LinesOfStraightLineProgram( prog ) do

      if   not IsEmpty( line ) and IsInt( line[1] ) then

        # The line describes a word to be appended.
        Add( r, StringOfResultOfLineOfStraightLineProgram( line,
                    r, a, LaTeX ) );
        respos:= Length( r );
        a[ respos ]:= false;

      elif 2 <= Length( line ) and IsInt( line[2] ) then

        # The line describes a word that shall replace.
        respos:= line[2];
        r[ respos ]:= StringOfResultOfLineOfStraightLineProgram( line[1],
                          r, a, LaTeX );
        a[ respos ]:= false;

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

    return r[ respos ];
end );


#############################################################################
##
#F  CompositionOfStraightLinePrograms( <prog2>, <prog1> )
##
InstallGlobalFunction( CompositionOfStraightLinePrograms,
    function( prog2, prog1 )

    local lines, len, lastline, inp2, max, i, pos, line; 

    lines:= ShallowCopy( LinesOfStraightLineProgram( prog1 ) );
    len:= Length( lines );
    lastline:= lines[ len ];
    inp2:= NrInputsOfStraightLineProgram( prog2 );

    if ForAll( lastline, IsList ) then

      # Check that the programs fit together.
      if inp2 <> Length( lastline ) then
        Error( "outputs of <prog1> incompatible with inputs of <prog2>" );
      fi;

      # The last line is a list of external representations of assoc. words.
      # Copy them first to safe positions, then to the first positions.
      max:= NrInputsOfStraightLineProgram( prog1 );
      for i in [ 1 .. len-1 ] do
        if IsList( lines[i][1] ) then
          max:= Maximum( max, lines[i][2] );
        else
          max:= max + 1;
        fi;
      od;
      Unbind( lines[ len ] );
      pos:= max;
      for i in lastline do
        max:= max + 1;
        Add( lines, [ i, max ] );
      od;
      for i in [ 1 .. Length( lastline ) ] do
        Add( lines, [ [ pos + i, 1 ], i ] );
      od;

    else

      # Check that the programs fit together.
      if inp2 <> 1 then
        Error( "outputs of <prog1> incompatible with inputs of <prog2>" );
      fi;

      if Length( lastline ) = 2 and IsList( lastline[1] ) then

        # The last line is a pair of the external representation of an assoc.
        # word and a positive integer.
        # Copy the word to position 1 if necessary.
        if lastline[2] <> 1 then
          Add( lines, [ [ lastline[2], 1 ], 1 ] );
        fi;

      else

        # The last line is the external representation of an assoc. word.
        # Store it at position 1.
        lines[ Length( lines ) ]:= [ lastline, 1 ];

      fi;

    fi;

    # Append the lines of `prog2'.
    # (Rewrite lines of type 1.)
    max:= inp2;
    for line in LinesOfStraightLineProgram( prog2 ) do
      if ForAll( line, IsList ) then
        Add( lines, line );
      elif ForAll( line, IsInt ) then
        max:= max + 1;
        Add( lines, [ line, max ] );
      else
        max:= Maximum( max, line[2] );
        Add( lines, line );
      fi;
    od;

    # Construct and return the new program.
    return StraightLineProgram( lines,
                                NrInputsOfStraightLineProgram( prog1 ) );
    end );


#############################################################################
##
#F  IntegratedStraightLineProgram( <listofprogs> )
##
##  The idea is to concatenate the lists of lines of the programs in the list
##  <listofprogs> after shifting the positions they refer to.
##  If a program overwrites some of the original generators then we first
##  copy the generators.
##
InstallGlobalFunction( "IntegratedStraightLineProgram",
    function( listofprogs )

    local n,          # number of inputs of all in `listofprogs'
          lines,      # list of lines of the result program
          results,    # results line of the result program
          nextoffset, # maximal position used up to now
          prog,       # loop over `listofprogs'
          proglines,  # list of lines of `prog'
          offset,     # maximal position used before the current program
          shiftgens,  # use a copy of the original generators
          i, line,    # loop over `proglines'
          newline,    # line with shifted source positions
          j;          # loop over the odd positions in `newline'

    # Check the input.
    if    not IsDenseList( listofprogs )
       or IsEmpty( listofprogs )
       or not ForAll( listofprogs, IsStraightLineProgram ) then
      Error( "<listofprogs> must be a nonempty list ",
             "of straight line programs" );
    fi; 
    n:= NrInputsOfStraightLineProgram( listofprogs[1] );
    if not ForAll( listofprogs,
                   prog -> NrInputsOfStraightLineProgram( prog ) = n ) then
      Error( "all in <listofprogs> must have the same number of inputs" );
    fi;

    # Initialize the list of lines, the results line, and the offset.
    lines:= [];
    results:= [];
    nextoffset:= n;

    # Loop over the programs, and add the results to `results'.
    for prog in listofprogs do

      proglines:= LinesOfStraightLineProgram( prog );
      if IsEmpty( proglines ) then
        Error( "each in <listofprogs> must return a single element" );
      fi;

      # Set the positions used up to here.
      offset:= nextoffset;

      # If necessary protect the original generators from being replaced,
      # and work with a shifted copy.
      shiftgens:= false;
      if ForAny( proglines, line ->     Length( line ) = 2 
                                    and IsList( line[1] )
                                    and line[2] in [ 1 .. n ] ) then
        Append( lines, List( [ 1 .. n ], i -> [ [ i, 1 ], i + offset ] ) );
        nextoffset:= offset + n;
        shiftgens:= true;
      else
        offset:= offset - n;
      fi;

      # Loop over the program.
      for i in [ 1 .. Length( proglines ) ] do

        line:= proglines[i];

        if   not IsEmpty( line ) and IsInt( line[1] ) then

          # The line describes a word to be appended.
          # (Increase the positions by `offset'.)
          newline:= ShallowCopy( line );
          for j in [ 1, 3 .. Length( newline )-1 ] do
            if shiftgens or n < newline[j] then
              newline[j]:= newline[j] + offset;
            fi;
          od;
          if i = Length( proglines ) then
            Add( results, newline );
          else
            Add( lines, newline );
            nextoffset:= nextoffset + 1;
          fi;

        elif 2 = Length( line ) and IsInt( line[2] ) then

          # The line describes a word that shall replace.
          # (Increase the positions and the destination by `offset'.)
          newline:= ShallowCopy( line[1] );
          for j in [ 1, 3 .. Length( newline )-1 ] do
            if shiftgens or n < newline[j] then
              newline[j]:= newline[j] + offset;
            fi;
          od;
          if i = Length( proglines ) then
            Add( results, newline );
          else
            newline:= [ newline, line[2] + offset ];
            Add( lines, newline );
            if nextoffset < newline[2] then
              nextoffset:= newline[2];
            fi;
          fi;

        else

          # Lines describing a list of words to be returned are forbidden.
          Error( "each in <listofprogs> must return a single element" );

        fi;

      od;

    od;

    # Add the results line.
    Add( lines, results );

    # Construct and return the new program.
    return StraightLineProgram( lines, n );
    end );


#############################################################################
##
##  2. Functions for elements represented by straight line programs
##


#############################################################################
##
#M  StraightLineProgElmType(<fam>)
##
InstallMethod(StraightLineProgElmType,"generic",true,[IsFamily],0,
function(fam)
  return NewType(fam,IsStraightLineProgElm);
end);

#############################################################################
##
#F  StraightLineProgElm(<seed>,<prog>)
##
InstallGlobalFunction(StraightLineProgElm,function(seeds,prog)
local sr;
  if IsRecord(seeds) then
    sr:=seeds;
    seeds:=sr.seeds;
  else
    sr:=rec(seeds:=seeds);
  fi;
  return Objectify(StraightLineProgElmType(FamilyObj(seeds[1])),[sr,prog]);
end);

#############################################################################
##
#F  EvalStraightLineProgElm(<slpel>)
##
InstallGlobalFunction(EvalStraightLineProgElm,function(slp)
  return ResultOfStraightLineProgram(slp![2],slp![1].seeds);
end);

#############################################################################
##
#F  StraightLineProgGens(<gens>)
##
InstallGlobalFunction(StraightLineProgGens,function(arg)
local gens,sgens,seed;
  gens:=arg[1];
  sgens:=Set(gens);
  seed:=rec(seeds:=sgens);
  if Length(arg)>1 and IsList(arg[2]) then
    seed.base:=arg[2];
  fi;
  return List([1..Length(gens)],i->StraightLineProgElm(seed,
     StraightLineProgramNC([[Position(sgens,gens[i]),1]],Length(sgens))));
end);

#############################################################################
##
#M  ViewObj(<slpel>)
##
InstallMethod(ViewObj,"straight line program elements",true,
  [IsStraightLineProgElm],0,
function(slp)
  Print("<");
  ViewObj(LinesOfStraightLineProgram(slp![2]));
  if Sum(LinesOfStraightLineProgram(slp![2]),Length)<50 then
    Print("|");
    ViewObj(EvalStraightLineProgElm(slp));
  fi;
  Print(">");
end);

#############################################################################
##
#M  OneOp(<slpel>)
##
InstallMethod(OneOp,"straight line program elements",true,
  [IsStraightLineProgElm],0,
function(slp)
  return One(FamilyObj(slp));
end);

#############################################################################
##
#M  InverseOp(<slpel>)
##
InverseSLPElm:=function(slp)
local l,n;
  l:=LinesOfStraightLineProgram(slp![2]);
  l:=ShallowCopy(l);
  n:=Length(l);
  # invert last
  l[n]:=ERepAssWorInv(l[n]);

  return StraightLineProgElm(slp![1],
           StraightLineProgramNC(l,Length(slp![1].seeds)));
end;

# words in fp elements have separate methods for `Inverse' and `InverseOp'
# -- so we must duplicate the installation here as well
InstallMethod(Inverse,"straight line program elements",true,
  [IsStraightLineProgElm],0,InverseSLPElm);

InstallMethod(InverseOp,"straight line program elements",true,
  [IsStraightLineProgElm],0,InverseSLPElm);

#############################################################################
##
#M  Order(<slpel>)
##
InstallMethod(Order,"straight line program elements",true,
  [IsStraightLineProgElm],
  # we have to be better than specialized methods
  10,
function(slp)
  return Order(EvalStraightLineProgElm(slp));
end);

#############################################################################
##
#M  \*
##
InstallMethod(\*,"straight line program element with x",true,
  [IsStraightLineProgElm,IsMultiplicativeElement],0,
function(slp,x)
  if IsOne(x) then return slp;fi;
  return EvalStraightLineProgElm(slp)*x;
end);

InstallMethod(\*,"x with straight line program element",true,
  [IsMultiplicativeElement,IsStraightLineProgElm],0,
function(x,slp)
  if IsOne(x) then return slp;fi;
  return x*EvalStraightLineProgElm(slp);
end);

#T this would be better recoded as variant of the substring algorithm in
#T steps of 2
BindGlobal("PosSublOdd",function(a,b)
local p;
  p:=PositionSublist(a,b);
  while IsInt(p) and IsInt(p/2) do
    p:=PositionSublist(a,b,p);
  od;
  return p;
end);

InstallMethod(\*,"straight line program elements",IsIdenticalObj,
  [IsStraightLineProgElm,IsStraightLineProgElm],0,
function(aob,bob)
# this multiplication routine tries to find duplicate patterns. It
# implicitly assumes, however that the input is in some way ``reduced'' as
# an SLP.
local a,b,	# lines of slp
      aep,bep,  # upto this generator index, entries are known.
      ta,tb,    # new indices for old
      tal,tbl,  # up to this index, old and new indices are the same
      la,lb,	# lengths
      laa,lba,	# last entries absolute
      ap,bp,	# processing indices old
      anp,bnp,	# ditto new
      asn,bsn,	# lengths of original seeds
      as,bs,	# subset
      l,	# result list
      ale,ble,	# indices in l of a/b entries
      i,j,k,	# index
      seed,	# seed
      seen,	# nr of seeds in toto
      e,	# entry
      ei,	# inverse
      bpre,	# bs-entries that have been taken earlier
      bleu,	# corresponding ble
      found,	# substring found?
      laro,	# flag when dealing with the last elements.
      p;	# position

  seed:=aob![1];
  asn:=Length(seed.seeds);
  aep:=Length(seed.seeds);
  b:=bob![1];
  bep:=Length(b.seeds);
  bsn:=Length(b.seeds);
  if IsIdenticalObj(seed,b) then
    # identical seeds -- easiest case
    ta:=[1..aep]; # translation of the numbers
    tb:=[1..bep];
  elif IsSubset(seed.seeds,b.seeds) then
    # b is a subset of a
    ta:=[1..aep]; # translation of the numbers
    tb:=List(b.seeds,i->Position(seed.seeds,i));
  elif IsSubset(b.seeds,seed.seeds) then
    # a is a subset of b
    ta:=List(seed.seeds,i->Position(b.seeds,i));
    tb:=[1..bep];
    seed:=b;
  else
    # none is a subset of the other
    a:=seed;
    seed:=rec(seeds:=Union(a.seeds,b.seeds));
    if IsBound(a.lmp) and IsBound(b.lmp) then
      seed.lmp:=Maximum(a.lmp,b.lmp);
    fi;
    if IsBound(a.base) and IsBound(b.base) then
      seed.base:=Union(a.base,b.base);
    fi;
    ta:=List(a.seeds,i->Position(seed.seeds,i));
    tb:=List(b.seeds,i->Position(seed.seeds,i));
  fi;
  seen:=Length(seed.seeds);
  tal:=First([1..Length(ta)],i->ta[i]<>i);
  if tal=fail then
    tal:=Length(ta);
  else
    tal:=tal-1;
  fi;
  tbl:=First([1..Length(tb)],i->tb[i]<>i);
  if tbl=fail then
    tbl:=Length(tb);
  else
    tbl:=tbl-1;
  fi;

  a:=LinesOfStraightLineProgram(aob![2]);
  b:=LinesOfStraightLineProgram(bob![2]);
  l:=[];
  la:=Length(a)-1; # the last entries are treated specially
  lb:=Length(b)-1;

  # special case: Multiplication with generator powers
  if la=0 and Length(a[1])=2 then
    a:=a[1];
    l:=ShallowCopy(b);
    # translate
    Append(tb,seen+[1..Length(b)]);
    for i in [1..Length(l)] do
      e:=ShallowCopy(l[i]);
      for j in [1,3..Length(e)-1] do
	e[j]:=tb[e[j]];
      od;
      l[i]:=e;
    od;
    e:=l[Length(l)];
    if e[1]=ta[a[1]] then
      e[2]:=e[2]+a[2];
      if e[2]=0 then
	e:=e{[3..Length(e)]};
      fi;
    else
      e:=Concatenation([ta[a[1]],a[2]],e);
    fi;
    l[Length(l)]:=e;
  elif lb=0 and Length(b[1])=2 then
    b:=b[1];
    l:=ShallowCopy(a);
    # translate
    Append(ta,seen+[1..Length(a)]);
    for i in [1..Length(l)] do
      e:=ShallowCopy(l[i]);
      for j in [1,3..Length(e)-1] do
	e[j]:=ta[e[j]];
      od;
      l[i]:=e;
    od;
    e:=l[Length(l)];
    if e[Length(e)-1]=tb[b[1]] then
      e[Length(e)]:=e[Length(e)]+b[2];
      if e[Length(e)]=0 then
	e:=e{[1..Length(e)-2]};
      fi;
    else
      e:=Concatenation(e,[tb[b[1]],b[2]]);
    fi;
    l[Length(l)]:=e;
  else

    ap:=1;
    bp:=1;
    ale:=[]; # a-indices in l
    ble:=[]; # b-indices in l

    laro:=false;
    while la<=Length(a) do
#Print("<\n");
      while ap<=la or bp<=lb do
#Print(">",ap,",",bp,"\n");
	# how many ap's do use up to generator aep;
	anp:=ap;
	while anp<=la and ForAll(a[anp]{[1,3..Length(a[anp])-1]},i->i<=aep) do
	  anp:=anp+1;
	od;
	as:=a{[ap..anp-1]};

	# translate the generator numbers
	if aep>tal then # otherwise no translation needs to take place
	  for i in [1..Length(as)] do
	    e:=ShallowCopy(as[i]);
	    for j in [1,3..Length(e)-1] do
	      e[j]:=ta[e[j]];
	      if e[j]<0 then
		# inverse
	        e[j]:=-e[j];
	        e[j+1]:=-e[j+1];
	      fi;
	    od;
	    as[i]:=e;
	  od;
	fi;

	# how many bp's do use up to generator bep;
	bnp:=bp;
	while bnp<=lb and ForAll(b[bnp]{[1,3..Length(b[bnp])-1]},i->i<=bep) do
	  bnp:=bnp+1;
	od;
	bs:=b{[bp..bnp-1]};

	# translate the generator numbers
	if bep>tbl then # otherwise no translation needs to take place
	  for i in [1..Length(bs)] do
	    e:=ShallowCopy(bs[i]);
	    for j in [1,3..Length(e)-1] do
	      e[j]:=tb[e[j]];
	      if e[j]<0 then
		# inverse
	        e[j]:=-e[j];
	        e[j+1]:=-e[j+1];
	      fi;
	    od;
	    bs[i]:=e;
	  od;
	fi;

	bpre:=[];
	bleu:=[];
	# add the as
	for i in [1..Length(as)] do
	  e:=as[i];
	  repeat
	    # search substring in recorded b-parts
	    found:=false;
	    j:=1;
	    while found=false and j<=Length(ble) do
	      p:=PosSublOdd(e,l[ble[j]]);
	      found:=p<>fail;
	      j:=j+1;
	    od;
	    if found=true then
	      j:=ble[j-1]+1; # the other case will always add 1.
	    else
	      # search substring in bs
	      j:=1;
	      while found=false and j<=Length(bs) do
		p:=PosSublOdd(e,bs[j]);
		if p<>fail then
		  found:=true;
		  if not j in bpre then
		    # record this bs in l
		    Add(l,bs[j]);
		    AddSet(bleu,Length(l));
		    AddSet(bpre,j); #  this one is taken already
		    tb[bsn+bp+j-1]:=Length(l)+seen; # store the index
		    j:=Length(l); # position of the l-entry that is sub
		  else
		    # we stored it already
		    j:=Position(l,bs[j]);
		  fi;
		fi;
		j:=j+1;
	      od;
	    fi;
	    if found<>false then
	      # the subentry starts at index p
	      # j is the l-index of the entry which is sub+1
	      e:=Concatenation(e{[1..p-1]},[j+seen-1,1],
			      e{[p+Length(l[j-1])..Length(e)]});
	    else
	      # search substring in recorded b-parts (inverse)
	      ei:=ERepAssWorInv(e);
	      j:=1;
	      while found=false and j<=Length(ble) do
		p:=PosSublOdd(ei,l[ble[j]]);
		found:=p<>fail;
		j:=j+1;
	      od;
	      if found=true then
		j:=ble[j-1]+1; # the other case will always add 1.
	      else
		# search substring in bs
		j:=1;
		while found=false and j<=Length(bs) do
		  p:=PosSublOdd(ei,bs[j]);
		  if p<>fail then
		    found:=true;
		    if not j in bpre then
		      AddSet(bpre,j); #  this one is taken now
		      # record this bs in l
		      if bs[j] in l then
			# happens to be coincidence.
			k:=Position(l,bs[j]);
			tb[bsn+bp+j-1]:=k+seen; # store the index
			j:=k; # position of the l-entry that is sub
		      else
			Add(l,bs[j]);
			AddSet(bleu,Length(l));
			tb[bsn+bp+j-1]:=Length(l)+seen; # store the index
			j:=Length(l); # position of the l-entry that is sub
		      fi;
		    else
		      # we stored it already
		      j:=Position(l,bs[j]);
		    fi;
		  fi;
		  j:=j+1;
		od;
	      fi;
	      if found<>false then
		# the subentry starts at index p in the inverse
		e:=Concatenation(e{[1..Length(e)+1-p-Length(l[j-1])]},
		                 [j+seen-1,-1],
				 e{[Length(e)-p+2..Length(e)]});

		ei:=ERepAssWorInv(e);
	      fi;
	    fi;

	  until found=false; # several substrings might occur

	  # finally store, unless trivial and not the last one
	  if Length(e)>2 or AbsInt(e[2])>1 or laro then
	    if e in l then
	      # the replacement could rarely produce duplicates
	      ta[asn+ap+i-1]:=Position(l,e)+seen;
	    else
	      Add(l,e);
	      if not laro then
		# do not add in the last step -- this might confuse b
		AddSet(ale,Length(l));
	      fi;
	      ta[asn+ap+i-1]:=Length(l)+seen;
	    fi;
	  else
	    # complete replacement
	    ta[asn+ap+i-1]:=SignInt(e[2])*e[1];
	  fi;
	od;
	ble:=Union(ble,bleu); # the b-indices that were added
	# add the bs
	for i in [1..Length(bs)] do
	  if not i in bpre then
	    e:=bs[i];
	    repeat
	      # search substring in recorded a-parts
	      found:=false;
	      j:=1;
	      while found=false and j<=Length(ale) do
		p:=PosSublOdd(e,l[ale[j]]);
		found:=p<>fail;
		j:=j+1;
	      od;
	      if found<>false then
		# the subentry starts at index p
		# j is the l-index of the entry which is sub+1
		j:=ale[j-1];
		e:=Concatenation(e{[1..p-1]},[j+seen,1],
				e{[p+Length(l[j])..Length(e)]});
	      else
		# search substring in recorded a-parts
		found:=false;
		j:=1;
		ei:=ERepAssWorInv(e);
		while found=false and j<=Length(ale) do
		  p:=PosSublOdd(e,l[ale[j]]);
		  found:=p<>fail;
		  j:=j+1;
		od;
		if found<>false then
		  # the subentry starts at index p in the inverse
		  # j is the l-index of the entry which is sub+1
		  j:=ale[j-1];
		  e:=Concatenation(e{[1..Length(e)+1-p-Length(l[j-1])]},
				  [j+seen-1,-1],
				  e{[Length(e)-p+2..Length(e)]});
		  ei:=ERepAssWorInv(e);
		fi;
	      fi;
	    until found=false; # several substrings might occur
	    # finally store
	    if Length(e)>2 or AbsInt(e[2])>1 then
	      if e in l then
		# the replacement could rarely produce duplicates
		tb[bsn+bp+i-1]:=Position(l,e)+seen;
	      else
		Add(l,e);
		AddSet(ble,Length(l));
		tb[bsn+bp+i-1]:=Length(l)+seen;
	      fi;
	    else
	      # complete replacement
	      tb[bsn+bp+i-1]:=SignInt(e[2])*e[1];
	    fi;
	  fi;
	od;

	ap:=anp;
	bp:=bnp;
	aep:=aep+1;
	bep:=bep+1;

      od;
      # this ensures the last two entries are processed last
      la:=la+1;
      lb:=lb+1;
      laro:=true;
    od;

    # finally multiply the last entries.

    # get the indices in l of the corresponding last entries
    # the -1 in the argument only undoes the +1 at the end of the `while' loop
    la:=ta[la+asn-1];
    lb:=tb[lb+bsn-1];
    laa:=AbsInt(la);
    lba:=AbsInt(lb);


    if la=Length(l)+seen-1 then
      # last a is in the but last position
      if lb=Length(l)+seen then
#  Print("case1\n");
	# last b is in the last position: combine last two
	e:=l[Length(l)-1];
	j:=l[Length(l)];

	# does b refer to a?
	if ForAny([1,3..Length(j)-1],k->j[k]=la) then
	  Add(l,[la,1,lb,1]);
	else
	  l[Length(l)-1]:=ERepAssWorProd(e,j);
	  Unbind(l[Length(l)]);
        fi;
      else
	Error("spurious last entry");
      fi;
    else
      # last a is not in the but last position
      if lb=Length(l)+seen then
#  Print("case2\n");
	# last b is in the last position: Change it
	l[Length(l)]:=ERepAssWorProd([la,1],l[Length(l)]);
      else
	# last b is not in the last position:
	if la=Length(l)+seen then
#  Print("case3\n");
	  # but a is: change a in last position
	  l[Length(l)]:=ERepAssWorProd(l[Length(l)],[lb,1]);
	else
#  Print("case4\n");
	  # last b is not in the last position or inverses used: Add another
	  Add(l,[laa,SignInt(la),lba,SignInt(lb)]);
	fi;
      fi;
    fi;

  fi;
  #Error(a,"*",b,"=",l,"\n");
  #if ForAny(l,i->Length(i)=2) then
  #  Error("hui");
  #fi;

  if Length(l[Length(l)])=0 then
    return One(aob);
  else
#if ForAny([2..Length(l)],i->Length(l[i])=2 and AbsInt(l[i][2])=1) then
#  Error();
#fi;
#    Assert(1,not
#    ForAny([1..Length(l)],i->ForAny([1..i-1],j->PositionSublist(l[i],l[j])<>fail)));
    
    Assert(1,Length(Set(l))=Length(l));
    l:=StraightLineProgElm(seed,StraightLineProgramNC(l,seen));
    Assert(2,EvalStraightLineProgElm(aob)*EvalStraightLineProgElm(bob)=
             EvalStraightLineProgElm(l));
    return l;
  fi;
end);

InstallMethod(\^,"power straight line program elements",true,
  [IsStraightLineProgElm,IsInt],0,
function(a,e)
local l,n;
  if e=0 then
    return One(a);
  elif e=1 then
    return a;
  elif e=-1 then
    return Inverse(a);
  fi;
  l:=LinesOfStraightLineProgram(a![2]);
  n:=Length(a![1].seeds);
  if Length(l)=1 and Length(l[1])=2 then
    # special case: generators
    l:=[[l[1][1],l[1][2]*e]];
  else
    l:=ShallowCopy(l);
    Add(l,[Length(l)+n,e]);
  fi;
  return StraightLineProgElm(a![1],StraightLineProgramNC(l,n));
end);

InstallMethod(\=,"straight line program element with x",IsIdenticalObj,
  [IsStraightLineProgElm,IsMultiplicativeElement],0,
function(slp,x)
  return EvalStraightLineProgElm(slp)=x;
end);

InstallMethod(\<,"straight line program element with x",IsIdenticalObj,
  [IsStraightLineProgElm,IsMultiplicativeElement],0,
function(slp,x)
  return EvalStraightLineProgElm(slp)<x;
end);

InstallMethod(\<,"x with straight line program element",IsIdenticalObj,
  [IsMultiplicativeElement,IsStraightLineProgElm],0,
function(x,slp)
  return x<EvalStraightLineProgElm(slp);
end);

#############################################################################
##
#O  StretchImportantSLPElement(<elm>)
##
InstallMethod(StretchImportantSLPElement,"arbitrary elements: do nothing",true,
  [IsMultiplicativeElementWithInverse],0,
Ignore);

InstallMethod(StretchImportantSLPElement,"straight line program elements",true,
  [IsStraightLineProgElm],0,
function(a)
local e,s,r;
  e:=LinesOfStraightLineProgram(a![2]);
  if Product(e,i->Sum(List(i{[2,4..Length(i)]},AbsInt)))>200 then
    e:=EvalStraightLineProgElm(a);
    s:=Union(a![1].seeds,[e]);
    e:=Position(s,e);
    r:=rec(seeds:=s);
    if IsBound(a![1].lmp) then
      # transfer largest moved point information for perms.
      r.lmp:=a![1].lmp;
    fi;
    if IsBound(a![1].base) then
      # transfer base information for perms.
      r.base:=a![1].base;
    fi;
    a![1]:=r;
    a![2]:=StraightLineProgramNC([[e,1]],Length(s));
  fi;
end);

##
##  special methods for straight line permutations
##

InstallMethod(\=,"x with straight line program element",IsIdenticalObj,
  [IsMultiplicativeElement,IsStraightLineProgElm],0,
function(x,slp)
  return x=EvalStraightLineProgElm(slp);
end);

BindGlobal("ImgElmSLP",function(x,slp,pre)
local s,m,l,trace;
   # trace through
   trace:=function(y,n)
   local e,i,j;
     if n<0 then
      n:=-n;
      if n<=m then
	return y/s[n];
      else
	e:=l[n-m];
	for i in [Length(e)-1,Length(e)-3..1] do
	  if e[i+1]<0 then
	    for j in [e[i+1]..-1] do
	      y:=trace(y,e[i]);
	    od;
	  else
	    for j in [1..e[i+1]] do
	      y:=trace(y,-e[i]);
	    od;
	  fi;
	od;
      fi;

     elif n<=m then
       return y^s[n];
     else
       e:=l[n-m];
       for i in [1,3..Length(e)-1] do
         if e[i+1]<0 then
	   for j in [e[i+1]..-1] do
	     y:=trace(y,-e[i]);
	   od;
	 else
	   for j in [1..e[i+1]] do
	     y:=trace(y,e[i]);
	   od;
	 fi;
       od;
     fi;

     return y;
   end;

   s:=slp![1].seeds;
   m:=Length(s);
   l:=LinesOfStraightLineProgram(slp![2]);
   if pre then
     # preimage!
     return trace(x,Length(l)+m);
   else
     return trace(x,-(Length(l)+m));
   fi;
end);

# The following function ought to perform better, being nonrecursive.
# In practice the recursion, being executed in the kernel, works out
# better. However this function ought to give the better performance if
# compiled.
BindGlobal("ImgElmSLPNonrecursive",function(x,slp,npre)
local s,m,l,stack,pos,row,ind,step,cnt,v,e,i,sp,ae;
  s:=slp![1].seeds;
  m:=Length(s);
  l:=LinesOfStraightLineProgram(slp![2]);
  stack:=[];
  sp:=0;
  pos:=Length(l);
  row:=l[pos];

  if npre then
    ind:=1;
    step:=2;
  else
    ind:=Length(row)-1;
    step:=-2;
  fi;
  cnt:=0;

  repeat
    v:=row[ind];
    e:=row[ind+1];
    ae:=AbsInt(e);
    if not npre then
      e:=-e;
    fi;
    if v<=m then
      # do the most simple cases themselves
      if e=-1 then
	x:=x/s[v];
      elif e=1 then
	x:=x^s[v];
      elif e>0 then
	for i in [1..e] do
	  x:=x^s[v];
	od;
      else
	for i in [1..-e] do
	  x:=x/s[v];
	od;
      fi;
      cnt:=ae; # did all
    else
      #push
      sp:=sp+1;
      stack[sp]:=[pos,ind,step,cnt];
      pos:=v-m;
      row:=l[pos];
      npre:=e>0;
      if npre then
	ind:=1;
	step:=2;
      else
	ind:=Length(row)-1;
	step:=-2;
      fi;
      cnt:=0; # we just started

    fi;

    while cnt>=ae do
      ind:=ind+step;
      cnt:=0;
      if ind>Length(row) or ind<1 then
	# pop
	if sp=0 then
	  # through!
	  return x;
	fi;
	row:=stack[sp];
	sp:=sp-1;
	pos:=row[1];
	ind:=row[2];
	step:=row[3];
	npre:=step>0;
	cnt:=row[4]+1; # +1 since we did one
	row:=l[pos];
	ae:=AbsInt(row[ind+1]);
      fi;
    od;
  until false; # we will stop by returning the result
end);

InstallOtherMethod(\^,"int with straight line perm",true,
  [IsInt,IsStraightLineProgElm and IsPerm],0,
function(x,slp)
  # do not use for straight line elements!
  if IsStraightLineProgElm(x) then
    TryNextMethod();
  fi;
  return ImgElmSLP(x,slp,true);
end);

InstallOtherMethod(\/,"x with straight line perm",true,
  [IsPosInt,IsStraightLineProgElm and IsPerm],0,
function(x,slp)
  return ImgElmSLP(x,slp,false);
end);

# takes a seed record and fetches/adds a largest moved point entry
BindGlobal("LMPSLPSeed",function(r)
  if not IsBound(r.lmp) then
    r.lmp:=LargestMovedPoint(r.seeds);
  fi;
  return r.lmp;
end);

InstallMethod(LargestMovedPoint,"straight line program permutation",true,
  [IsStraightLineProgElm and IsPerm],0,
function(slp)
local p,q;
  p:=LMPSLPSeed(slp![1]);
  if p>1000 then
    q:=p-100;
  else
    q:=0;
  fi;
  while p>q and ImgElmSLP(p,slp,true)=p do
    p:=p-1;
  od;

  if p>q then
    return p;
  elif q=0 then
    return q;
  else
    # catch the () case quickly if base given.
    if IsBound(slp![1].base) and IsOne(slp) then
      return 0;
    fi;
    # the element seems to be the identity. Expand!
    q:=EvalStraightLineProgElm(slp);
    return LargestMovedPoint(q);
  fi;

end);

InstallMethod(\=,"straight line program element with perm",IsIdenticalObj,
  [IsStraightLineProgElm and IsPerm,IsPerm],0,
function(slp,perm)
local r;
  r:=LargestMovedPoint(perm);
  if r=0 then
    return IsOne(slp);
  else
    if r^perm<>ImgElmSLP(r,slp,true) then
      return false;
    fi;
  fi;
  if IsBound(slp![1].base) then
    return ForAll(slp![1].base,i->ImgElmSLP(i,slp,true)=i^perm)
           and r<=LMPSLPSeed(slp![1]);
  fi;
  return EvalStraightLineProgElm(slp)=perm;
end);

InstallMethod(\=,"perm with straight line program element",IsIdenticalObj,
  [IsPerm,IsStraightLineProgElm and IsPerm],0,
function(perm,slp)
local r;
  r:=LargestMovedPoint(perm);
  if r=0 then
    return IsOne(slp);
  else
    if r^perm<>ImgElmSLP(r,slp,true) then
      return false;
    fi;
  fi;
  if IsBound(slp![1].base) then
    return ForAll(slp![1].base,i->ImgElmSLP(i,slp,true)=i^perm)
           and r<=LMPSLPSeed(slp![1]);
  fi;
  return perm=EvalStraightLineProgElm(slp);
end);

InstallMethod(\=,"straight line program perms",IsIdenticalObj,
  [IsStraightLineProgElm and IsPerm,IsStraightLineProgElm and IsPerm],0,
function(a,b)
local l,m;
  if not IsIdenticalObj(a![1],b![1]) then
    l:=Maximum(LMPSLPSeed(a![1]),LMPSLPSeed(b![1]));
  else
    l:=LMPSLPSeed(a![1]);
  fi;
  if IsBound(a![1].base) and IsBound(b![1].base) then
    return
    ForAll(Union(a![1].base,b![1].base),
           i->ImgElmSLP(i,a,true)=ImgElmSLP(i,b,true));
  fi;
  if l<1000 then
    m:=0;
  else
    m:=l-100;
  fi;
  while l>m do
    if ImgElmSLP(l,a,true)<>ImgElmSLP(l,b,true) then
      return false;
    fi;
    l:=l-1;
  od;
  if l=0 then
    return true;
  fi;
  # the elements look very similar, but there are a lot of points.
  return EvalStraightLineProgElm(a)=EvalStraightLineProgElm(b);
end);

InstallMethod(\<,"straight line program perms",IsIdenticalObj,
  [IsStraightLineProgElm and IsPerm,IsStraightLineProgElm and IsPerm],0,
function(a,b)
local l,m,x,y;
  l:=1;
  if not IsIdenticalObj(a![1],b![1]) then
    m:=Maximum(LMPSLPSeed(a![1]),LMPSLPSeed(b![1]));
  else
    m:=LMPSLPSeed(a![1]);
  fi;
  if m>1000 then
    m:=1000;
  fi;
  while l<m do
    x:=ImgElmSLP(l,a,true);
    y:=ImgElmSLP(l,b,true);
    if x<y then return true;
    elif y<x then return false;
    fi;
    l:=l+1;
  od;
  # the elements look very similar, but there are a lot of points.
  return EvalStraightLineProgElm(a)<EvalStraightLineProgElm(b);
end);

InstallMethod(IsOne,"straight line program perms",true,
  [IsStraightLineProgElm and IsPerm],0,
function(slp)
local l,m;
  if IsBound(slp![1].base) then
    return ForAll(slp![1].base,i->ImgElmSLP(i,slp,true)=i);
  fi;
  l:=LMPSLPSeed(slp![1]);
  if l<1000 then
    m:=0;
  else
    m:=l-100;
  fi;
  while l>m do
    if ImgElmSLP(l,slp,true)<>l then
      return false;
    fi;
    l:=l-1;
  od;
  if l=0 then
    return true;
  fi;
  return EvalStraightLineProgElm(slp)=();
end);

InstallOtherMethod( CycleLengthOp, "straight line program perms", true,
  [ IsPerm and IsStraightLineProgElm, IsInt ],1, 
function(p,e)
local i,f;
  i:=0;
  f:=e;
  repeat
    f:=f^p;
    i:=i+1;
  until f=e;
  return i;
end);

InstallOtherMethod( CycleOp, "straight line program perms", true,
  [ IsPerm and IsStraightLineProgElm, IsInt ],1, 
function(p,e)
local c,i,f;
  i:=0;
  f:=e;
  c:=[];
  repeat
    Add(c,f);
    f:=f^p;
    i:=i+1;
  until f=e;
  return c;
end);

##
##  special methods for straight line assoc words
##

#############################################################################
##
#M  ExtRepOfObj
##
InstallMethod(ExtRepOfObj,"for a straight line program word",true,
  [IsAssocWord and IsStraightLineProgElm],0,
function(slp)
  return ExtRepOfObj(EvalStraightLineProgElm(slp));
end);

#############################################################################
##
#M  NumberSyllables
##
InstallMethod(NumberSyllables,"for a straight line program word",true,
  [IsAssocWord and IsStraightLineProgElm],0,
function(slp)
  return NumberSyllables(EvalStraightLineProgElm(slp));
end);

#############################################################################
##
#M  MappedWord
##
InstallMethod(MappedWord,"for a straight line program word, and two lists",
  IsElmsCollsX,
  [ IsAssocWord and IsStraightLineProgElm, IsAssocWordCollection, IsList ], 0,
function(slp,gens,imgs)
  # evaluate in mapped generators
  return ResultOfStraightLineProgram(slp![2],List(slp![1].seeds,
    i->MappedWord(i,gens,imgs)) # images of the roots
    );
end);

# words represented as tree elements (those are useful for decoding subgroup
# presentations)

#############################################################################
##
#F  TreeRepresentedWord( <roots>,<tree>,<nr> )
##
##  these elements are represented as straight line program elements
InstallGlobalFunction(TreeRepresentedWord,function(r,t,n)
local z,d,l,count,b;
  z:=Length(t[1]);
  b:=Length(r);
  if n<=b then
    return StraightLineProgElm(r,StraightLineProgramNC([[n,1]],Length(r)));
  fi;

  # which elements are referred to several times
  d:=ListWithIdenticalEntries(z,0);
  count:=function(i)
    if i>b then
      if d[i]=0 then
	count(AbsInt(t[1][i]));
	count(AbsInt(t[2][i]));
      fi;
      d[i]:=d[i]-1;
    fi;
  end;

  count(n);

  # now we will collect in d slp entries (or indices in l by positive numbers)
  l:=[];
  d[n]:=-2; # this will force element n to be stored as word (and it will be
            # at the end of l)
  count:=function(i)
  local e,f,x,y,j;
    if i<=b then
      return i;
    elif not (IsInt(d[i]) and d[i]<0) then
      return d[i];
    fi;
    e:=count(AbsInt(t[1][i]));
    f:=count(AbsInt(t[2][i]));
    x:=SignInt(t[1][i]);
    y:=SignInt(t[2][i]);
    # put together
    if IsInt(e) and IsInt(f) then
      if e=f then
	if x+y=0 then
	  Error("strange tree element");
	else
	  e:=[e,x+y];
	fi;
      else
        e:=[e,x,f,y];
      fi;
    else
      # take care of inverses
      if IsList(e) and x<1 then
	x:=[]; #revert
	for j in [Length(e)-1,Length(e)-3..1] do
	  Add(x,j);
	  Add(x,j+1);
	od;
        e:=e{x};
	x:=[2,4..Length(e)]; # exponent indices
	e{x}:=-e{x};
      fi;
      if IsList(f) and y<1 then
	y:=[]; #revert
	for j in [Length(f)-1,Length(f)-3..1] do
	  Add(y,j);
	  Add(y,j+1);
	od;
        f:=f{y};
	y:=[2,4..Length(f)]; # exponent indices
	f{y}:=-f{y};
      fi;

      if IsInt(e) then
	e:=Concatenation([e,x],f);
      elif IsInt(f) then
	e:=Concatenation(e,[f,y]);
      else
	# multiply
	f:=ShallowCopy(f);
	while Length(e)>1 and Length(f)>0 and e[Length(e)-1]=f[1] do
	  # same variables: reduce
	  f[2]:=f[2]+e[Length(e)];
	  if f[2]=0 then
	    f:=f{[3..Length(f)]};
	  fi;
	  e:=e{[1..Length(e)-2]};
	od;
	e:=Concatenation(e,f);
      fi;

    fi;
    if d[i]<-1 then
      # this becomes a new definition
      Add(l,e);
      e:=Length(l)+b; # number of this definition
    fi;
    d[i]:=e; # store
    return e;
  end;
  count(n);

  return StraightLineProgElm(r,StraightLineProgramNC(l,Length(r)));
end);


#############################################################################
##
#E

