#############################################################################
##
#W  stdgen.gi                GAP library                        Thomas Breuer
##
#H  @(#)$Id: stdgen.gi,v 1.1 2002/02/20 17:21:29 gap Exp $
##
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the implementations needed for dealing with standard
##  generators of finite groups.
##
Revision.stdgen_gi :=
    "@(#)$Id: stdgen.gi,v 1.1 2002/02/20 17:21:29 gap Exp $";


#############################################################################
##
#F  HumanReadableDefinition( <info> )
##
InstallGlobalFunction( HumanReadableDefinition, function( info )

    local nrgens,
          alpha,
          lalpha,
          generators,
          i,
          m,
          gensstring,
          nraux,
          auxnames,
          description,
          script,
          len,
          line,
          word,
          pos,
          str,
          j,
          strline,
          linelen;

    # Check the argument.
    if not ( IsRecord( info ) and IsBound( info.script ) ) then
      Error( "<info> must be a record with a component `script'" );
    elif not IsBound( info.description ) then

      # Get names of the standard generators.
      alpha:= [ "a","b","c","d","e","f","g","h","i","j","k","l","m",
                "n","o","p","q","r","s","t","u","v","w","x","y","z" ];
      lalpha:= Length( alpha );
      if not IsBound( info.generators ) then

        nrgens:= Number( info.script,
                         line -> Length( line ) <= 3 and IsInt( line[2] ) );
        generators:= [];
        for i in [ 1 .. nrgens ] do
          if i <= lalpha then
            generators[i]:= alpha[i];
          else
            m:= (i-1) mod lalpha + 1;
            generators[i]:= Concatenation( alpha[m],
                                           String( ( i - m ) / lalpha ) );
          fi;
        od;

        gensstring:= "";
        for i in generators do
          Append( gensstring, i );
          Append( gensstring, ", " );
        od;
        Unbind( gensstring[ Length( gensstring ) ] );
        Unbind( gensstring[ Length( gensstring ) ] );
        info.generators:= gensstring;

      else

        gensstring:= info.generators;
        generators:= SplitString( gensstring, ",", " " );
        nrgens:= Length( generators );

      fi;

      # Get the names of auxiliary generators needed.
      nraux:= Number( info.script,
                      line -> Length( line ) = 3 and IsInt( line[2] ) );
      if nrgens + nraux <= lalpha then
        auxnames:= alpha{ [ lalpha-nraux+1 .. lalpha ] };
        if not IsEmpty( Intersection( generators, auxnames ) ) then
          auxnames:= List( [ 1 .. nraux ],
                           i -> Concatenation( "X", String(i) ) );
        fi;
      else
        auxnames:= List( [ 1 .. nraux ],
                         i -> Concatenation( "X", String(i) ) );
      fi;
      nraux:= 1;

      # Initialize the result string.
      description:= "";

      # Scan the script linearly.
      script:= info.script;
      len:= Length( script );
      for i in [ 1 .. len ] do

        line:= script[i];

        if IsList( line[2] ) and IsString( line[2][1] ) then

          # condition line.
          word:= "";
          linelen:= Length( line[1] );
          for j in [ 1, 3 .. linelen-1 ] do
            Append( word, generators[ line[1][j] ] );
            if line[1][ j+1 ] = 2 then
              Append( word, generators[ line[1][j] ] );
            elif line[1][ j+1 ] <> 1 then
              Add( word, '^' );
              Append( word, String( line[1][ j+1 ] ) );
            fi;
          od;
          str:= ShallowCopy( line[2] );
          for j in [ 1 .. Length( str ) ] do
            if not IsBound( str[j] ) then
              str[j]:= word;
            fi;
          od;
          strline:= Concatenation( str );
          Add( strline, '=' );
          Append( strline, String( line[3] ) );

        elif Length( line ) = 2 then

          # definition line
          strline:= Concatenation( "|", generators[ line[1] ], "|=",
                        String( line[2] ) );

        elif Length( line ) = 3 and IsInt( line[2] ) then

          # definition line involving an auxiliary name
          strline:= Concatenation( "|", auxnames[ nraux ], "|=",
                        String( line[2] ), ", ", auxnames[ nraux ],
                        "^", String( line[3] ), "=", generators[ line[1] ] );
          nraux:= nraux+1;

        else

          # relation line
          linelen:= Length( line );
          if linelen = 3 then
            strline:= Concatenation( "|",
                          StringOfResultOfStraightLineProgram( line[2],
                              generators{ line[1] } ),
                          "|=", String( line[3] ) );
          else
            strline:= "|";
            for j in [ 1, 3 .. linelen-2 ] do
              Append( strline, generators[ line[j] ] );
              if line[ j+1 ] = 2 then
                Append( strline, generators[ line[j] ] );
              elif line[ j+1 ] <> 1 then
                Add( strline, '^' );
                Append( strline, String( line[ j+1 ] ) );
              fi;
            od;
            Append( strline, "|=" );
            Append( strline, String( line[ linelen ] ) );
          fi;

        fi;

        Append( description, strline );
        if i < len then
          Append( description, ", " );
        fi;

      od;

      # Store the value.
      info.description:= description;

    fi;

    # Return the result.
    return info.description;
end );


#############################################################################
##
#F  ScriptFromString( <string> )
##
InstallGlobalFunction( ScriptFromString, function( string )

    local gensnames,
          gensorder,
          lines,
          nrlines,
          k,
          line,
          pos,
          int,
          aux,
          len,
          pos2,
          script,
          nrgens,
          i,
          found,
          list,
          init,
          initlen,
          linelen,
          scr,
          try,
          j,
          word;

    gensnames:= [];
    gensorder:= [];
    lines:= SplitString( string, ",", " " );
    nrlines:= Length( lines );

    # Loop over the lines.
    script:= [];
    nrgens:= 0;
    k:= 1;
    while k <= nrlines do

      line:= lines[k];

      # The names of the standard generators occur in lines
      # starting not with `|' or lines containing neither `(' nor `^',
      # and having a letter at position $2$ and a non-letter at position $3$.
      if line[1] = '|' and IsAlphaChar( line[2] )
                       and not IsAlphaChar( line[3] )
                       and not ( '(' in line or '^' in line ) then

        # This entry belongs to a definition
        # (perhaps of an auxiliary element) via order.
        pos:= Position( line, '|', 1 );
        if pos = fail or line[ pos+1 ] <> '=' then
          return fail;
        fi;
        Add( gensnames, line{ [ 2 .. pos-1 ] } );
        int:= Int( line{ [ pos+2 .. Length( line ) ] } );
        if int = fail then
          return fail;
        fi;
        Add( gensorder, int );
        len:= Length( gensnames );
        nrgens:= nrgens + 1;

        # Check whether this was an auxiliary element,
        # and the next line (if there is one)
        # defines a generator relative to this one.
        if k < nrlines and lines[ k+1 ][1] <> '|'
                       and not '(' in lines[ k+1 ] then

          # This line belongs to a definition via a power.
          k:= k+1;
          line:= lines[k];
          pos:= Position( line, '^' );
          if pos = fail then
            return fail;
          fi;
          aux:= line{ [ 1 .. pos-1 ] };
          if gensnames[ len ] <> aux then
            return fail;
          fi;
          pos2:= Position( line, '=' );
          int:= Int( line{ [ pos+1 .. pos2-1 ] } );
          if int = fail then
            return fail;
          fi;
          gensnames[ len ]:= line{ [ pos2+1 .. Length( line ) ] };

          # Add the definition to the script.
          Add( script, [ nrgens, gensorder[ len ], int ] );

        else

          # Add the definition to the script.
          Add( script, [ nrgens, gensorder[ len ] ] );

        fi;

      else

        pos:= Position( line, '=' );
        if pos = fail then
          return fail;
        fi;
        int:= Int( line{ [ pos+1 .. Length( line ) ] } );
        if int = fail then
          return fail;
        fi;

        # Check whether the line matches the first part of a function string.
        found:= false;
        for i in [ 1, 3 .. Length( StandardGeneratorsFunctions )-1 ] do
          list:= StandardGeneratorsFunctions[ i+1 ];
          init:= list[1];
          initlen:= Length( init );
          if init[ initlen ] <> '(' then
            Error( "symbol <list> must enclose arguments in ( and )" );
          elif init = line{ [ 1 .. initlen ] } then

            # Find the word in question, and check it.
            pos2:= initlen + 1;
            linelen:= Length( line );
            while pos2 <= linelen and not line[ pos2 ] in "()" do
              pos2:= pos2 + 1;
            od;
            if pos2 <= linelen and line[ pos2 ] <> '(' then
              word:= line{ [ initlen+1 .. pos2-1 ] };
              try:= ShallowCopy( list );
              for j in [ 1 .. Length( list ) ] do
                if not IsBound( try[j] ) then
                  try[j]:= word;
                fi;
              od;
              try:= Concatenation( try );
              if try = line{ [ 1 .. pos-1 ] } then
                scr:= [];
                found:= StringToStraightLineProgram( word, gensnames, scr );
                if found then
                  Add( script, [ scr[1][1], list, int ] );
                fi;
              fi;
            fi;
            if found then
              break;
            fi;

          fi;
        od;

        if not found then

          # Check for a relation.
          if line[1] <> '|' then
            return fail;
          fi;
          pos:= Position( line, '=' );
          if pos = fail then
            return fail;
          fi;
          if line[ pos-1 ] <> '|' then
            return fail;
          fi;
          int:= Int( line{ [ pos+1 .. Length( line ) ] } );
          if int = fail then
            return fail;
          fi;
          word:= [];
          if not StringToStraightLineProgram( line{ [ 2 .. pos-2 ] },
                                              gensnames, word ) then
            return fail;
          fi;

          # Create a straight line program if brackets were found.
          if Length( word ) = 1 then
            word:= word[1][1];
            Add( word, int );
            Add( script, word );
          else
            Add( script, [ [ 1 .. Length( gensnames ) ],
                           StraightLineProgram( word, Length( gensnames ) ),
                           int ] );
          fi;

        fi;

      fi;

      k:= k+1;

    od;

    # Return the result;
    return script;
end );


#############################################################################
##
#V  StandardGeneratorsFunctions
##
InstallValue( StandardGeneratorsFunctions, [] );

CentralizerOrder := function( G, g ) return Size( Centralizer( G, g ) ); end;

Append( StandardGeneratorsFunctions, [ CentralizerOrder, [ "|C(",,")|" ] ] );


#############################################################################
##
#F  IsStandardGeneratorsOfGroup( <info>, <G>, <gens> )
##
InstallGlobalFunction( IsStandardGeneratorsOfGroup, function( info, G, gens )

    local script,
          i,
          line,
          g,
          next,
          linelen,
          j;

    # Initialize, and start the loop.
    script:= info.script;
    for i in [ 1 .. Length( script ) ] do

      Info( InfoGroup, 3,
            "StandardGenerators: inspecting line ", i );
      line:= script[i];

      if IsList( line[2] ) and IsString( line[2][1] ) then

        # condition line.
        # First compute the element to be checked.
        if IsEmpty( line[1] ) then
          g:= One( G );
        elif not IsBound( gens[ line[1][1] ] ) then
          return false;
        else
          g:= gens[ line[1][1] ];
          if line[1][2] <> 1 then
            g:= g ^ line[1][2];
          fi;
          for j in [ 3, 5 .. Length( line[1] ) - 1 ] do
            if not IsBound( gens[ line[1][j] ] ) then
              return false;
            fi;
            next:= gens[ line[1][j] ];
            if line[1][ j+1 ] <> 1 then
              next:= next ^ line[1][ j+1 ];
            fi;
            g:= g * next;
          od;
        fi;
        # Next compute the value under the function, and compare.
        if StandardGeneratorsFunctions[ Position(
                  StandardGeneratorsFunctions, line[2] ) - 1 ]( G,
                      g ) <> line[3] then
          return false;
        fi;

      elif Length( line ) <= 3 and IsInt( line[2] ) then

        # definition line
        if    not IsBound( gens[ line[1] ] )
           or ( Length( line ) = 2 and Order( gens[ line[1] ] ) <> line[2] )
           or ( Length( line ) = 3 and Order( gens[ line[1] ] )
                                  <> line[2] / Gcd( line[2], line[3] ) ) then
          return false;
        fi;

      else

        # relation line
        linelen:= Length( line );
        if linelen = 3 then
          if Order( ResultOfStraightLineProgram( line[2], gens{ line[1] } ) )
             <> line[3] then
            return false;
          fi;
        else
          g:= gens[ line[1] ]^line[2];
          for j in [ 3, 5 .. linelen-2 ] do
            next:= gens[ line[j] ];
            if line[ j+1 ] <> 1 then
              next:= next^line[ j+1 ];
            fi;
            g:= g * next;
          od;
          if Order( g ) <> line[ linelen ] then
            return false;
          fi;
        fi;

      fi;

    od;

    # All conditions are satisfied.
    return true;
end );


#############################################################################
##
#F  StandardGeneratorsOfGroup( <info>, <G>[, <randfunc>] )
##
InstallGlobalFunction( StandardGeneratorsOfGroup, function( arg )

    local info,
          G,
          randfunc,
          gens,
          script,
          len,
          i,
          line,
          g,
          next,
          linelen,
          j;

    # Get and check the arguments.
    if   Length( arg ) = 2 and IsRecord( arg[1] ) and IsGroup( arg[2] ) then
      info     := arg[1];
      G        := arg[2];
      randfunc := PseudoRandom;
    elif Length( arg ) = 3 and IsRecord( arg[1] ) and IsGroup( arg[2] )
                           and IsFunction( arg[3] ) then
      info     := arg[1];
      G        := arg[2];
      randfunc := arg[3];
    else
      Error( "usage: StandardGenerators( <info>, <G>[, <randfunc>] )" );
    fi;

    # Initialize, and start the loop.
    if not IsBound( info.script ) then
      if not IsBound( info.description ) then
        Error( "need at least a component `script' or `description'" );
      else
        info.script:= ScriptFromString( info.description );
      fi;
    fi;
    script:= info.script;
    len:= Length( script );
    i:= 1;
    gens:= [];
    while i <= len do

      Info( InfoGroup, 3,
            "StandardGenerators: inspecting line ", i );
      line:= script[i];

      if IsList( line[2] ) and IsString( line[2][1] ) then

        # condition line.
        # First compute the element to be checked.
        if IsEmpty( line[1] ) then
          g:= One( G );
        elif not IsBound( gens[ line[1][1] ] ) then
          Error( "definition of ", Ordinal( line[1][1] ),
                 " generator missing before line ", i );
        else
          g:= gens[ line[1][1] ];
          if line[1][2] <> 1 then
            g:= g ^ line[1][2];
          fi;
          for j in [ 3, 5 .. Length( line[1] ) - 1 ] do
            if not IsBound( gens[ line[1][j] ] ) then
              Error( "definition of ", Ordinal( line[1][j] ),
                     " generator missing before line ", i );
            fi;
            next:= gens[ line[1][j] ];
            if line[1][ j+1 ] <> 1 then
              next:= next ^ line[1][ j+1 ];
            fi;
            g:= g * next;
          od;
        fi;
        # Next compute the value under the function, and compare.
        if StandardGeneratorsFunctions[ Position(
                  StandardGeneratorsFunctions, line[2] ) - 1 ]( G,
                      g ) <> line[3] then
          gens:= [];
          i:= 0;
        fi;

      elif Length( line ) <= 3 and IsInt( line[2] ) then

        # definition line
        if IsBound( gens[ line[1] ] ) then
          Error( Ordinal( line[1] ),
                 " generator defined a second time in line ", i );
        fi;
        repeat
          g:= randfunc( G );
        until Order( g ) = line[2];
        if IsBound( line[3] ) and line[3] <> 1 then
          g:= g^line[3];
        fi;
        gens[ line[1] ]:= g;

      else

        # relation line
        linelen:= Length( line );
        if linelen = 3 then
          g:= ResultOfStraightLineProgram( line[2], gens{ line[1] } );
        else
          g:= gens[ line[1] ]^line[2];
          for j in [ 3, 5 .. linelen-2 ] do
            g:= g * gens[ line[j] ]^line[ j+1 ];
          od;
        fi;
        if Order( g ) <> line[ linelen ] then
          gens:= [];
          i:= 0;
        fi;

      fi;

      # Inspect the next line.
      i:= i + 1;

    od;

    # Return the result.
    return gens;
end );


#############################################################################
##
#E

