#############################################################################
##
#W  interfac.gi          GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the implementation part of the ``high level'' GAP
##  interface to the ATLAS of Group Representations.
##


#############################################################################
##
##  Avoid error messages when old GAPDoc versions are used.
##
if not IsBound( RepeatedUTF8String ) then
  RepeatedUTF8String:= "dummy";
fi;


#############################################################################
##
#F  AGR.Pager( <string> )
##
##  Simply calling `Pager' is not good enough, because GAP introduces
##  line breaks in too long lines, and GAP does not compute the printable
##  length of the line but the length as a string.
##
AGR.Pager:= function( string )
    Pager( rec( lines:= string, formatted:= true ) );
    end;


#############################################################################
##
#F  AGR.ShowOnlyASCII()
##
##  Show nicer grids and symbols such as ℤ if the terminal admits this.
##  Currently we do not do this if `Print' is used to show the data,
##  because of the automatically inserted line breaks.
##
AGR.ShowOnlyASCII:= function()
    return not IsBound( RepeatedUTF8String ) or
           IsIdenticalObj( AtlasOfGroupRepresentationsInfo.displayFunction,
#   return IsIdenticalObj( AtlasOfGroupRepresentationsInfo.displayFunction,
#T change the code as soon as GAP 4.4 need not be supported anymore!
                           Print ) or GAPInfo.TermEncoding <> "UTF-8";
    end;


#############################################################################
##
#F  AGR.StringAtlasInfoOverview( <gapnames>, <conditions> )
##
AGR.StringAtlasInfoOverview:= function( gapnames, conditions )
    local columns, type, i, widths, width, fstring, result, mid;

    # Consider only those names for which actually information is available.
    # (The ordering shall be the same as in the input.)
    if gapnames = "all" then
      gapnames:= AtlasOfGroupRepresentationsInfo.GAPnamesSortDisp;
    else
      gapnames:= Filtered( List( gapnames, AGR.InfoForName ),
                           x -> x <> fail );
    fi;
    if IsEmpty( gapnames ) then
      return;
    fi;

    # Compute the data of the columns.
    columns:= [ [ "group", "l", List( gapnames, x -> [ x[1], false ] ) ] ];
    for type in AGR.DataTypes( "rep", "prg" ) do
      if type[2].DisplayOverviewInfo <> fail then
        Add( columns, [
             type[2].DisplayOverviewInfo[1],
             type[2].DisplayOverviewInfo[2],
             List( gapnames,
                   n -> type[2].DisplayOverviewInfo[3](
                            Concatenation( [ n ], conditions ) ) ) ] );
      fi;
    od;

    # Evaluate the privacy flag.
    for i in [ 1 .. Length( gapnames ) ] do
      if ForAny( columns, x -> x[3][i][2] ) then
        columns[1][3][i][1]:= Concatenation( columns[1][3][i][1],
            AtlasOfGroupRepresentationsInfo.markprivate );
      fi;
    od;

    # Compute the appropriate column widths.
    widths:= [];
    for i in columns do
      width:= Maximum( Length( i[1] ),       # the header string shall fit
                  Maximum( List( i[3], y -> Length( y[1] ) ) ) );
      Add( widths, [ width, i[2] ] );
    od;

    fstring:= function( string, width )
      local strwidth, n, n1, n2;

      strwidth:= WidthUTF8String( string );
      if width[1] <= strwidth then
        return string;
      elif width[2] = "l" then
        return Concatenation( string,
                              RepeatedString( ' ', width[1] - strwidth ) );
      elif width[2] = "r" then
        return Concatenation( RepeatedString( ' ', width[1] - strwidth ),
                              string );
      else
        n:= RepeatedString( ' ', width[1] - strwidth );
        n1:= n{ [ QuoInt( Length( n ), 2 ) + 1 .. Length( n ) ] };
        n2:= n{ [ 1 .. QuoInt( Length( n ), 2 ) ] };
        return Concatenation( n1, string, n2 );
      fi;
    end;

    result:= [];

    # Add the header line.
    if AGR.ShowOnlyASCII() then
      mid:= " | ";
    else
      mid:= " │ ";
    fi;
    Add( result, JoinStringsWithSeparator( List( [ 1 .. Length( columns ) ],
               j -> fstring( columns[j][1], widths[j] ) ), mid ) );
    if AGR.ShowOnlyASCII() then
      Add( result, JoinStringsWithSeparator( List( [ 1 .. Length( columns ) ],
                 j -> RepeatedString( "-", widths[j][1] ) ), "-+-" ) );
    else
      Add( result, JoinStringsWithSeparator( List( [ 1 .. Length( columns ) ],
                 j -> RepeatedUTF8String( "─", widths[j][1] ) ), "─┼─" ) );
    fi;

    # Add the information for each group.
    for i in [ 1 .. Length( gapnames ) ] do
      if ForAny( [ 2 .. Length( columns ) ],
                 j -> columns[j][3][i][1] <> "" ) then
        Add( result, JoinStringsWithSeparator( List( [ 1 .. Length( columns ) ],
                 j -> fstring( columns[j][3][i][1], widths[j] ) ), mid ) );
      fi;
    od;

    return result;
    end;


#############################################################################
##
#F  AGR.InfoPrgs( <conditions> )
##
AGR.InfoPrgs:= function( conditions )
    local groupname, name, tocs, std, argpos, stdavail, toc, record, type,
          list, header, nams, sort, info, pi;

    groupname:= AGR.InfoForName( conditions[1] );
    if groupname = fail then
      return rec( list:= [] );
    fi;
    conditions:= conditions{ [ 2 .. Length( conditions ) ] };
    name:= groupname[2];
    tocs:= AGR.TablesOfContents( conditions );

    if Length( conditions ) = 0 or
       not ( IsInt( conditions[1] ) or IsList( conditions[1] ) ) then
      std:= true;
      argpos:= 1;
    else
      std:= conditions[1];
      if IsInt( std ) then
        std:= [ std ];
      fi;
      argpos:= 2;
    fi;

    # If the standardization is prescribed then do not mention it.
    # Otherwise if all information refers to the same standardization then
    # print just one line.
    # Otherwise print the standardization for each entry.
    stdavail:= [];
    if std = true or 1 < Length( std ) then
      for toc in tocs do
        if IsBound( toc.( name ) ) then
          record:= toc.( name );
          for type in AGR.DataTypes( "prg" ) do
            if IsBound( record.( type[1] ) ) then
              for list in record.( type[1] ) do
                if std = true or list[1] in std then
                  AddSet( stdavail, list[1] );
                fi;
              od;
            fi;
          od;
        fi;
      od;
    fi;

    # Create the header line.
    # (Because of `AtlasRepCreateHTMLInfoForGroup',
    # `gapname' must occur as an entry of its own .)
    header:= [ "Programs for G = ", groupname[1], ":" ];
    if Length( stdavail ) = 1 then
      Append( header, [ "    (all refer to std. generators ",
                        String( stdavail[1] ), ")" ] );
    fi;

    # Collect the info lines for the scripts.
    list:= [];
    nams:= [];
    sort:= [];
    if ( Length( conditions ) = argpos and
         conditions[ argpos ] = IsStraightLineProgram )
       or ( Length( conditions ) = argpos + 1
            and conditions[ argpos ] = IsStraightLineProgram
            and conditions[ argpos + 1 ] = true )
       or Length( conditions ) < argpos then
      for type in AGR.DataTypes( "prg" ) do
        info:= type[2].DisplayPRG( tocs, name, std, stdavail );
        Add( list, info );
        if IsEmpty( info ) then
          Add( sort, [ 0 ] );
        elif Length( info ) = 1 then
          Add( sort, [ 0, info[1] ] );
        else
          Add( sort, [ 1, info[1] ] );
        fi;
        Add( nams, type[1] );
      od;
    fi;

    # Sort the information such that those come first for which a single
    # line is given.
    # (This is because `BrowseAtlasInfo' turns the parts with more than
    # one line into a subcategory which is created from the first line.)
    # Inside this ordering of entries, sort the information alphabetically.
    pi:= Sortex( sort );

    return rec( header := header,
                list   := Permuted( list, pi ),
                nams   := Permuted( nams, pi ) );
    end;


#############################################################################
##
#F  AGR.EvaluateMinimalityCondition( <gapname>, <conditions> )
##
##  Evaluate conditions involving `"minimal"':
##  Replace the string `"minimal"' by the number in question if known,
##  return `true' in this case and `false' otherwise.
##  (In the `false' case, an info message is printed.)
##
AGR.EvaluateMinimalityCondition:= function( gapname, conditions )
    local pos, info, pos2;

    pos:= Position( conditions, "minimal" );
    if pos <> fail and pos <> 1 then
      if   IsIdenticalObj( conditions[ pos-1 ], NrMovedPoints ) then
        # ..., NrMovedPoints, "minimal", ...
        info:= MinimalRepresentationInfo( gapname, NrMovedPoints );
        if info = fail then
          Info( InfoAtlasRep, 1,
                "minimal perm. repr. of `", gapname, "' not known" );
          return false;
        fi;
        conditions[ pos ]:= info.value;
      elif IsIdenticalObj( conditions[ pos-1 ], Dimension ) then
        pos2:= Position( conditions, Characteristic );
        if pos2 <> fail and pos2 < Length( conditions ) then
          # ..., Characteristic, <p>, ..., Dimension, "minimal", ...
          info:= MinimalRepresentationInfo( gapname,
                     Characteristic, conditions[ pos2+1 ] );
          if info = fail then
            Info( InfoAtlasRep, 1,
                  "minimal matrix repr. of `", gapname,
                  "' in characteristic ", conditions[ pos2+1 ],
                  " not known" );
            return false;
          fi;
          conditions[ pos ]:= info.value;
        else
          pos2:= Position( conditions, Ring );
          if pos2 <> fail and pos2 < Length( conditions )
                         and IsField( conditions[ pos2+1 ] )
                         and IsFinite( conditions[ pos2+1 ] ) then
            # ..., Ring, <R>, ..., Dimension, "minimal", ...
            info:= MinimalRepresentationInfo( gapname,
                       Size, Size( conditions[ pos2+1 ] ) );
            if info = fail then
              Info( InfoAtlasRep, 1,
                    "minimal matrix repr. of `", gapname,
                    "' over `", conditions[ pos2+1 ], "' not known" );
              return false;
            fi;
            conditions[ pos ]:= info.value;
          fi;
        fi;
      fi;
    fi;

    return true;
    end;


#############################################################################
##
#F  AGR.InfoReps( <conditions> )
##
##  This function is used by `AGR.DisplayAtlasInfoGroup' and
##  `BrowseData.AtlasRepGroupInfoTable'.
##
AGR.InfoReps:= function( conditions )
    local info, stdavail, header, list, types, r, type, entry;

    info:= CallFuncList( AllAtlasGeneratingSetInfos, conditions );

    # If all information refers to the same standardization then
    # print just one line.
    # Otherwise print the standardization for each entry.
    stdavail:= Set( List( info, x -> x.standardization ) );

    # Construct the header line.
    # (Because of `AtlasRepCreateHTMLInfoForGroup',
    # `gapname' must occur as an entry of its own .)
    header:= [ "Representations for G = ", AGR.GAPName( conditions[1] ),
               ":" ];
    if Length( stdavail ) = 1 then
      Add( header, Concatenation(
           "    (all refer to std. generators ", String( stdavail[1] ),
           ")" ) );
    fi;

    list:= [];
    types:= AGR.DataTypes( "rep" );
    for r in info do
      type:= First( types, t -> t[1] = r.type );
      entry:= type[2].DisplayGroup( r );
      if IsString( entry ) then
        entry:= [ entry ];
      fi;
      entry:= [ [ String( r.repnr ), ":" ], [ entry[1], "" ],
                entry{ [ 2 .. Length( entry ) ] } ];
      if not IsString( r.identifier[1] ) then
        entry[2][2]:= AtlasOfGroupRepresentationsInfo.markprivate;
      fi;
      if 1 < Length( stdavail ) then
        Add( entry, [ ", w.r.t. std. gen. ", String( r.standardization ) ] );
      fi;
      Add( list, entry );
    od;

    return rec( header := header,
                list   := list );
    end;


#############################################################################
##
#F  AGR.StringAtlasInfoGroup( <conditions> )
##
##  Deal with the detailed overview for one group.
##
AGR.StringAtlasInfoGroup:= function( conditions )
    local result, screenwidth, inforeps, list, line, len1, len2, indent,
          underline, i, prefix, entry, infoprgs, j;

    result:= [];
    screenwidth:= SizeScreen()[1] - 1;

    # `DisplayAtlasInfo( <gapname>[, <std>][, <conditions>] )'
    inforeps:= AGR.InfoReps( conditions );
    if not IsEmpty( inforeps.list ) then

      list:= List( inforeps.list, line -> Concatenation(
               [ Concatenation( line[1] ), Concatenation( line[2] ) ],
               Concatenation( line{ [ 3 .. Length( line ) ] } ) ) );
      len1:= Maximum( List( list, x -> WidthUTF8String( x[1] ) ) );
      len2:= Maximum( List( list, x -> WidthUTF8String( x[2] ) ) );
      indent:= 0;
      line:= Concatenation( inforeps.header{ [ 1 .. 3 ] } );
      if AGR.ShowOnlyASCII() then
        underline:= RepeatedString( "-", Sum( List(
                        inforeps.header{ [ 1 .. 3 ] }, Length ) ) );
      else
        underline:= RepeatedUTF8String( "─", Sum( List(
                        inforeps.header{ [ 1 .. 3 ] }, Length ) ) );
      fi;
      for i in [ 4 .. Length( inforeps.header ) ] do
        if WidthUTF8String( line ) + WidthUTF8String( inforeps.header[i] )
           >= screenwidth
           and WidthUTF8String( line ) <> indent then
          Add( result, line );
          Add( result, underline );
          underline:= "";
          line:= "";
        fi;
        Append( line, inforeps.header[i] );
      od;
      if line <> "" then
        Add( result, line );
      fi;
      if underline <> "" then
        Add( result, underline );
      fi;

      indent:= len1 + len2 + 2;
      if indent >= screenwidth then
        indent:= 1;
      fi;
      prefix:= RepeatedString( " ", indent );
      for entry in list do
        # right-aligned number, left-aligned description
        line:= Concatenation( String( entry[1], len1 ), " ",
                              entry[2],
                              RepeatedString( " ", len2
                                  - WidthUTF8String( entry[2] ) ),
                              " " );
        for i in [ 3 .. Length( entry ) ] do
          if WidthUTF8String( line ) + WidthUTF8String( entry[i] )
             >= screenwidth
             and Length( line ) <> indent then
            Add( result, line );
            line:= ShallowCopy( prefix );
          fi;
          Append( line, entry[i] );
        od;
        Add( result, line );
      od;
    fi;

    # `DisplayAtlasInfo( <gapname>[, <std>][, IsStraightLineProgram] )'
    infoprgs:= AGR.InfoPrgs( conditions );
    if ForAny( infoprgs.list, x -> not IsEmpty( x ) ) then
      if IsBound( inforeps ) and not IsEmpty( inforeps.list ) then
        Add( result, "" );
      fi;
      indent:= 0;
      line:= Concatenation( infoprgs.header{ [ 1 .. 3 ] } );
      if AGR.ShowOnlyASCII() then
        underline:= RepeatedString( "-", Sum( List(
                        infoprgs.header{ [ 1 .. 3 ] }, Length ) ) );
      else
        underline:= RepeatedUTF8String( "─", Sum( List(
                        infoprgs.header{ [ 1 .. 3 ] }, Length ) ) );
      fi;
      for i in [ 4 .. Length( infoprgs.header ) ] do
        if WidthUTF8String( line ) + WidthUTF8String( infoprgs.header[i] )
           >= screenwidth
           and WidthUTF8String( line ) <> indent then
          Add( result, line );
          Add( result, underline );
          underline:= "";
          line:= "";
        fi;
        Append( line, infoprgs.header[i] );
      od;
      if line <> "" then
        Add( result, line );
      fi;
      if underline <> "" then
        Add( result, underline );
      fi;
      for i in infoprgs.list do
        if not IsEmpty( i ) then
          if Length( i ) = 1 then
            Add( result, i[1] );
          else
            Add( result, Concatenation( i[1], ":" ) );
            for j in [ 2 .. Length( i ) ] do
              Add( result, Concatenation( "  ", i[j] ) );
            od;
          fi;
        fi;
      od;
    fi;

    return result;
    end;


#############################################################################
##
#F  DisplayAtlasInfo( [<listofnames>][,][<std>][,]["contents", <sourcesid>]
#F                    [, IsPermGroup[, true]]
#F                    [, NrMovedPoints, <n>]
#F                    [, IsMatrixGroup[, true]]
#F                    [, Characteristic, <p>][, Dimension, <n>]
#F                    [, Position, <n>]
#F                    [, Character, <chi>]
#F                    [, Identifier, <id>] )
#F  DisplayAtlasInfo( <gapname>[, <std>][, "contents", <sourcesid>]
#F                    [, IsPermGroup[, true]]
#F                    [, NrMovedPoints, <n>]
#F                    [, IsMatrixGroup[, true]]
#F                    [, Characteristic, <p>][, Dimension, <n>]
#F                    [, Position, <n>]
#F                    [, Character, <chi>]
#F                    [, Identifier, <id>]
#F                    [, IsStraightLineProgram[, true]] )
##
InstallGlobalFunction( DisplayAtlasInfo, function( arg )
    local result, width, toowide, i, line, ints, sum, j, pos;

    # Distinguish the summary overview for at least one group
    # from the detailed overview for exactly one group.
    if   Length( arg ) = 0 then
      result:= AGR.StringAtlasInfoOverview( "all", arg );
    elif IsList( arg[1] ) and ForAll( arg[1], IsString ) then
      result:= AGR.StringAtlasInfoOverview( arg[1],
                    arg{ [ 2 .. Length( arg ) ] } );
    elif not IsString( arg[1] ) or arg[1] = "contents" then
      result:= AGR.StringAtlasInfoOverview( "all", arg );
    else
      result:= AGR.StringAtlasInfoGroup( arg );
    fi;

    width:= SizeScreen()[1] - 2;
    toowide:= false;
    for i in [ 1 .. Length( result ) ] do
      line:= result[i];
      if width < WidthUTF8String( line ) then
        # Shorten the lines; in particular the output of `Pager' is unusable
        # if the lines are longer than the screen width.
        toowide:= true;
#T Is there a function that cuts a unicode string after n visible columns?
        if not IsUnicodeString( line ) then
          line:= Unicode( line,  "UTF-8" );
        fi;
        ints:= IntListUnicodeString( line );
        sum:= 0;
        for j in [ 1 .. Length( ints ) ] do
          if ints[j] > 31 and ints[j] < 127 then
            sum:= sum + 1;
          else
            pos := POSITION_FIRST_COMPONENT_SORTED(WidthUnicodeTable, ints[j]);
            if not IsBound(WidthUnicodeTable[pos]) or WidthUnicodeTable[pos][1] <> ints[j] then
              pos := pos-1;
            fi;
            sum:= sum + WidthUnicodeTable[pos][2];
          fi;
          if width-1 < sum then
            break;
          fi;
        od;
        result[i]:= Concatenation( line{ [ 1 .. j-1 ] }, "*" );
      fi;
    od;
    Add( result, "" );

    AtlasOfGroupRepresentationsInfo.displayFunction(
        JoinStringsWithSeparator( result, "\n" ) );

    if toowide then
      InfoWarning( 1, "screen width is too small, lines were shortened" );
    fi;
    end );


#############################################################################
##
#F  AtlasGenerators( <gapname>, <repnr>[, <maxnr>] )
#F  AtlasGenerators( <identifier> )
##
##  <identifier> is a list containing at the first position the string
##  <gapname>,
##  at the second position a string or a list of strings
##  (describing filenames),
##  at the third position a positive integer denoting the standardization of
##  the representation,
##  at the fourth position a positive integer describing the common ring of
##  the generators,
##  and at the fifth position, if bound, a positive integer denoting the
##  number of the maximal subgroup to which the representation is restricted.
##
InstallGlobalFunction( AtlasGenerators, function( arg )
    local tocs, identifier, gapname, prefix, groupname, maxnr, file, repnr,
          res, type, j, toc, record, pos, try, gens, name, gen, result, prog,
          repname;

    tocs:= AGR.TablesOfContents( "all" );
    if Length( arg ) = 1 then

      # `AtlasGenerators( <identifier> )'
      identifier:= arg[1];
      if IsRecord( identifier ) and IsBound( identifier.identifier ) then
        identifier:= identifier.identifier;
      fi;
      gapname:= identifier[1];
      if Length( gapname ) = 2 and IsString( gapname[1] ) then
        # file in a private directory
        prefix:= gapname[1];
        gapname:= gapname[2];
      else
        prefix:= "datagens";
      fi;
      groupname:= AGR.InfoForName( gapname );
      if IsBound( identifier[5] ) then
        maxnr:= identifier[5];
      fi;
      file:= identifier[2];
      if not IsString( file ) then
        file:= file[1];
      fi;

      # Compute the type, and the current number of the representation.
      repnr:= 0;
      res:= false;
      for type in AGR.DataTypes( "rep" ) do
        for toc in tocs do
          if IsBound( toc.( groupname[2] ) ) then
            record:= toc.( groupname[2] );
            if IsBound( record.( type[1] ) ) then
              pos:= PositionProperty( record.( type[1] ),
                        entry -> entry[ Length( entry ) ] = identifier[2] );
              if pos = fail then
                repnr:= repnr + Length( record.( type[1] ) );
              else
                repnr:= repnr + pos;
                res:= true;
                break;
              fi;
            fi;
          fi;
        od;
        if res then
          break;
        fi;
      od;
      if not res then
        return fail;
      fi;

    elif  ( Length( arg ) = 2 and IsString( arg[1] ) and IsPosInt( arg[2] ) )
       or ( Length( arg ) = 3 and IsString( arg[1] ) and IsPosInt( arg[2] )
                              and IsPosInt( arg[3] ) ) then

      # `AtlasGenerators( <gapname>, <repnr>[, <maxnr>] )'
      gapname:= arg[1];
      groupname:= AGR.InfoForName( gapname );
      if groupname = fail then
        Info( InfoAtlasRep, 1,
              "AtlasGenerators: no group with GAP name `", gapname, "'" );
        return fail;
      fi;

      try:= function( repnr, type )
        local j, toc, record;
        for j in [ 1 .. Length( tocs ) ] do
          toc:= tocs[j];
          if IsBound( toc.( groupname[2] ) ) then
            record:= toc.( groupname[2] );
            if IsBound( record.( type ) ) then
              if repnr <= Length( record.( type ) ) then
                return [ j, record.( type )[ repnr ] ];
              fi;
              repnr:= repnr - Length( record.( type ) );
            fi;
          fi;
        od;
        return repnr;
      end;

      repnr:= arg[2];
      res:= repnr;
      for type in AGR.DataTypes( "rep" ) do
        res:= try( res, type[1] );
        if not IsInt( res ) then
          break;
        fi;
      od;
      if IsInt( res ) then
        return fail;
      fi;

      if res[1] = 1 then
        prefix:= "datagens";
      else
        prefix:= AtlasOfGroupRepresentationsInfo.private[ res[1]-1 ][2];
      fi;
      res:= res[2];
      identifier:= [ gapname, res[ Length( res) ], res[1], res[2] ];
      if prefix <> "datagens" then
        identifier[1]:= [ prefix, gapname ];
      fi;
      if IsBound( arg[3] ) then
        maxnr:= arg[3];
        identifier[5]:= maxnr;
      fi;

    else
      Error( "usage: AtlasGenerators( <gapname>,<repnr>[,<maxnr>] ) or\n",
             "       AtlasGenerators( <identifier> )" );
    fi;

    # Access the data file(s).
    gens:= AGR.FileContents( prefix, groupname[2], identifier[2], type );
    if gens = fail then
      return fail;
    fi;
    result:= rec( generators      := gens,
                  standardization := identifier[3],
                  repnr           := repnr,
                  identifier      := identifier );

    if IsBound( maxnr ) then

      # Compute the straight line program for the restriction
      # (w.r.t. the correct standardization).
      prog:= AtlasProgram( gapname, identifier[3], maxnr );
      if prog = fail then
        return fail;
      fi;

      # Evaluate the straight line program.
      result.generators:= ResultOfStraightLineProgram( prog.program, gens );

      # Add info.
      if IsBound( groupname[3].sizesMaxes )
         and IsBound( groupname[3].sizesMaxes[ maxnr ] ) then
        result.size:= groupname[3].sizesMaxes[ maxnr ];
      fi;
      if IsBound( groupname[3].structureMaxes )
         and IsBound( groupname[3].structureMaxes[ maxnr ] ) then
        result.groupname:= groupname[3].structureMaxes[ maxnr ];
      fi;

    else

      # Add info.
      repname:= identifier[2];
      if not IsString( repname ) then
        repname:= repname[1];
      fi;
      repname:= repname{ [ 1 .. Position( repname, '.' )-1 ] };

      result.groupname:= gapname;
      result.repname:= repname;
      result.type:= type[1];

      type[2].AddDescribingComponents( result, type );
      if IsBound( groupname[3].size ) then
        result.size:= groupname[3].size;
      fi;

    fi;

    # Return the result.
    return Immutable( result );
    end );


#############################################################################
##
#F  AGR.MergedTableOfContents( <tocid>, <gapname> )
##
##  `AGR.MergedTableOfContents' returns a list of the known representations
##  for the group with name <gapname>.
##  This list is sorted by types and for each type by its `SortTOCEntries'
##  function.
##  The list is cached in the component <gapname> of the global record
##  `AtlasOfGroupRepresentationsInfo.TableOfContents.merged'.
##  When a new table of contents is notified with
##  `AtlasOfGroupRepresentationsNotifyPrivateDirectory' then the cache is
##  cleared.
##
AGR.MergedTableOfContents:= function( tocid, gapname )
    local merged, label, groupname, result, tocs, type, typeresult, sortkeys,
          toc, record, id, i, repname, oneresult;

    merged:= AtlasOfGroupRepresentationsInfo.TableOfContents.merged;
    label:= Concatenation( tocid, "|", gapname );
    if not IsBound( merged.( label ) ) then

      groupname:= AGR.InfoForName( gapname );
      if groupname = fail then
        return [];
      fi;

      result:= [];

      # Loop over the relevant representations, sort them for each type.
      tocs:= AGR.TablesOfContents( [ "contents", tocid ] );
      for type in AGR.DataTypes( "rep" ) do
        typeresult:= [];
        sortkeys:= [];
        for toc in tocs do
          if IsBound( toc.( groupname[2] ) ) then
            record:= toc.( groupname[2] );
            if IsBound( record.( type[1] ) ) then
              if not IsBound( toc.diridPrivate ) then
                id:= gapname;
              else
                id:= [ toc.diridPrivate, gapname ];
              fi;
              for i in record.( type[1] ) do
                repname:= i[ Length(i) ];
                if not IsString( repname ) then
                  repname:= repname[1];
                fi;
                repname:= repname{ [ 1 .. Position( repname, '.' )-1 ] };
                oneresult:= rec( groupname       := gapname,
                                 identifier      := [ id, i[ Length(i) ],
                                                      i[1], i[2] ],
                                 repname         := repname,
                                 standardization := i[1],
                                 type            := type[1] );
                type[2].AddDescribingComponents( oneresult, type );
                Add( typeresult, oneresult );
                Add( sortkeys, type[2].SortTOCEntries( i ) );
              od;
            fi;
          fi;
        od;
        SortParallel( sortkeys, typeresult );
        Append( result, typeresult );
      od;

      if IsBound( groupname[3].size ) then
        for i in result do
          i.size:= groupname[3].size;
        od;
      fi;
      for i in [ 1 .. Length( result ) ] do
        result[i].repnr:= i;
      od;

      merged.( label ):= result;
    fi;

    return merged.( label );
end;


#############################################################################
##
#F  AGR.EvaluateCharacterCondition( <gapname>, <conditions>, <reps> )
##
##  Evaluate conditions involving `Character'.
##  The list <conditions> is changed in place.
##  The return value is a copy of <conditions> in which one occurrence of
##  `Character' is replaced by the corresponding `Identifier' condition
##  if this is known,
##  or a nonempty string describing an info message otherwise.
##
AGR.EvaluateCharacterCondition:= function( gapname, conditions, reps )
    local pos, chi, len, i, map, tbl, p, dec, list, j, repname, newreps;

    # If `Character' does not occur then we need not work.
    pos:= Position( conditions, Character );
    if pos = fail then
      return reps;
    elif pos = Length( conditions ) then
      return [];
    fi;

    map:= AtlasOfGroupRepresentationsInfo.characterinfo;
    if not IsBound( map.( gapname ) ) then
      Info( InfoAtlasRep, 1,
            "no character information for ", gapname, " known" );
      return [];
    fi;
    map:= map.( gapname );

    tbl:= CharacterTable( gapname );
    if tbl = fail then
      Info( InfoAtlasRep, 1, "no character table for ", gapname, " known" );
      return [];
    fi;
    chi:= conditions[ pos+1 ];

    # Remove the entries from `conditions'.
    len:= Length( conditions );
    for i in [ pos .. Length( conditions )-2 ] do
      conditions[i]:= conditions[ i+2 ];
    od;
    Unbind( conditions[ len ] );
    Unbind( conditions[ len-1 ] );

    # Check whether `Characteristic' is specified.
    pos:= Position( conditions, Characteristic );
    if pos = fail then
      p:= "?";
    elif pos = Length( conditions ) then
      return [];
    else
      p:= conditions[ pos+1 ];
      if not ( p = 0 or IsPosInt( p ) ) then
        return [];
      fi;
    fi;

    # Interpret the character.
    if   IsClassFunction( chi ) then
      # the character is explicitly given
      if p = "?" then
        p:= UnderlyingCharacteristic( UnderlyingCharacterTable( chi ) );
      elif p <> UnderlyingCharacteristic( UnderlyingCharacterTable( chi ) ) then
        return [];
      elif p <> 0 then
        tbl:= tbl mod p;
      fi;
    else
      if p = "?" then
        p:= 0;
      elif p <> 0 then
        tbl:= tbl mod p;
      fi;
      if   IsPosInt( chi ) and chi <= NrConjugacyClasses( tbl ) then
        # the `chi'-th irreducible character in characteristic `p'
        chi:= Irr( tbl )[ chi ];
      elif IsString( chi ) then
        # the character is irreducible and specified by its name,
        # as defined by `AtlasCharacterNames'.
        chi:= Position( AtlasCharacterNames( tbl ), chi );
        if chi = fail then
          return [];
        fi;
        chi:= Irr( tbl )[ chi ];
      else
        return [];
      fi;
    fi;

    if Identifier( UnderlyingCharacterTable( chi ) ) <> Identifier( tbl ) then
      return [];
    fi;
             
    # Check whether character information for the given type is stored.
    if p = 0 and IsBound( map[1] ) then
      map:= map[1];
    elif IsPosInt( p ) and IsBound( map[p] ) then
      if tbl = fail then
        Info( InfoAtlasRep, 1,
              "no ", p, "-modular character table for ", gapname, " known" );
        return [];
      fi;
      map:= map[p];
    else
      Info( InfoAtlasRep, 1,
            "no character information for ", gapname, " in characteristic ",
            p, " known" );
      return [];
    fi;

    # Look for the character.
    if p = 0 then
      dec:= MatScalarProducts( tbl, Irr( tbl ), [ chi ] )[1];
    else
      dec:= Decomposition( Irr( tbl ), [ chi ], "nonnegative" )[1];
    fi;
    if dec = fail or not ForAll( dec, x -> IsInt( x ) and 0 <= x ) then
      Info( InfoAtlasRep, 1, "character does not decompose properly" );
      return [];
    fi;
    list:= [];
    for i in [ 1 .. Length( dec ) ] do
      if dec[i] = 1 then
        Add( list, i );
      elif 1 < dec[i] then
        Add( list, [ i, dec[i] ] );
      fi;
    od;
    if Length( list ) = 1 then
      list:= list[1];
    fi;
    pos:= Position( map[1], list );
    if pos = fail then
      Info( InfoAtlasRep, 1, "character not found" );
      return [];
    fi;

    # We have found the character.
    repname:= map[2][ pos ];

    return Filtered( reps, r -> r.repname = repname );
    end;


#############################################################################
##
#F  AGR.AtlasGeneratingSetInfo( <conditions>, "one" )
#F  AGR.AtlasGeneratingSetInfo( <conditions>, "all" )
#F  AGR.AtlasGeneratingSetInfo( <conditions>, <types> )
##
##  This function does the work for `OneAtlasGeneratingSetInfo',
##  `AllAtlasGeneratingSetInfos', and `AGR.InfoReps'.
##  The first entry in <conditions> can be a group name
##  or a list of group names.
##
AGR.AtlasGeneratingSetInfo:= function( conditions, mode )
    local pos, tocid, gapnames, types, std, position, result, gapname, reps,
          cond, info, type;

    pos:= Position( conditions, "contents" );
    if pos <> fail then
      tocid:= conditions[ pos+1 ];
      conditions:= Concatenation( conditions{ [ 1 .. pos-1 ] },
                       conditions{ [ pos+2 .. Length( conditions ) ] } );
    else
      tocid:= "all";
    fi;

    # The first argument (if there is one) is a group name,
    # or a list of group names,
    # or an integer (denoting a standardization),
    # or a function (denoting the first condition).
    if Length( conditions ) = 0 or IsInt( conditions[1] )
                                or IsFunction( conditions[1] ) then
      # The group is not restricted.
      gapnames:= List( AtlasOfGroupRepresentationsInfo.GAPnamesSortDisp,
                       pair -> pair[1] );
    elif IsString( conditions[1] ) then
      # Only one group is considered.
      gapnames:= [ AGR.GAPName( conditions[1] ) ];
      conditions:= conditions{ [ 2 .. Length( conditions ) ] };
    elif IsList( conditions[1] ) and ForAll( conditions[1], IsString ) then
      # A list of group names is prescribed.
      gapnames:= List( conditions[1], AGR.GAPName );
      conditions:= conditions{ [ 2 .. Length( conditions ) ] };
    else
      Error( "invalid first argument ", conditions[1] );
    fi;

    types:= AGR.DataTypes( "rep" );

    # Deal with a prescribed standardization.
    if 1 <= Length( conditions ) and
       ( IsPosInt( conditions[1] ) or IsList( conditions[1] ) ) then
      std:= conditions[1];
      if IsPosInt( std ) then
        std:= [ std ];
      fi;
      conditions:= conditions{ [ 2 .. Length( conditions ) ] };
    else
      std:= true;
    fi;

    # Deal with a prescribed representation number.
    pos:= Position( conditions, Position );
    if pos <> fail then
      if pos = Length( conditions ) or not IsPosInt( conditions[ pos+1 ] ) then
        Error( "condition `Position' must be followed by a pos. integer" );
      fi;
      position:= conditions[ pos+1 ];
      conditions:= Concatenation( conditions{ [ 1 .. pos-1 ] },
                       conditions{ [ pos+2 .. Length( conditions ) ] } );
    fi;

    result:= [];

    for gapname in gapnames do

      reps:= AGR.MergedTableOfContents( tocid, gapname );

      # Evaluate the `Position' condition.
      if pos <> fail then
        if position <= Length( reps ) then
          reps:= [ reps[ position ] ];
        else
          reps:= [];
        fi;
      fi;

      cond:= ShallowCopy( conditions );

      # Evaluate conditions involving `"minimal"' (modify `cond' in place).
      if AGR.EvaluateMinimalityCondition( gapname, cond ) then
        # Evaluate the `Character' condition.
        if Character in cond then
          reps:= AGR.EvaluateCharacterCondition( gapname, cond, reps );
        fi;

        # Loop over the relevant representations.
        for info in reps do
          type:= First( types, t -> t[1] = info.type );
          if ( std = true or info.standardization in std ) and
             type[2].AccessGroupCondition( info, ShallowCopy( cond ) ) then
            if mode = "one" then
              return info;
            else
              Add( result, info );
            fi;
          fi;
        od;
      fi;
    od;

    # We have checked all available representations.
    if mode = "one" then
      return fail;
    else
      return result;
    fi;
    end;


#############################################################################
##
#F  OneAtlasGeneratingSetInfo( [<gapname>][, <std>] )
#F  OneAtlasGeneratingSetInfo( [<gapname>][, <std>], IsPermGroup[, true] )
#F  OneAtlasGeneratingSetInfo( [<gapname>][, <std>], NrMovedPoints, <n> )
#F  OneAtlasGeneratingSetInfo( [<gapname>][, <std>], IsMatrixGroup[, true] )
#F  OneAtlasGeneratingSetInfo( [<gapname>][, <std>][, Characteristic, <p>]
#F                                                 [, Dimension, <m>] )
#F  OneAtlasGeneratingSetInfo( [<gapname>][, <std>][, Ring, <R>]
#F                                                 [, Dimension, <m>] )
#F  OneAtlasGeneratingSetInfo( [<gapname>,][ <std>,] Position, <n> )
##
InstallGlobalFunction( OneAtlasGeneratingSetInfo, function( arg )
    return AGR.AtlasGeneratingSetInfo( arg, "one" );
    end );


#############################################################################
##
#F  AllAtlasGeneratingSetInfos( [<gapname>][, <std>] )
#F  AllAtlasGeneratingSetInfos( [<gapname>][, <std>], IsPermGroup[, true] )
#F  AllAtlasGeneratingSetInfos( [<gapname>][, <std>], NrMovedPoints, <n> )
#F  AllAtlasGeneratingSetInfos( [<gapname>][, <std>], IsMatrixGroup[, true] )
#F  AllAtlasGeneratingSetInfos( [<gapname>][, <std>][, Characteristic, <p>]
#F                                                  [, Dimension, <m>] )
#F  AllAtlasGeneratingSetInfos( [<gapname>][, <std>][, Ring, <R>]
#F                                                  [, Dimension, <m>] )
##
InstallGlobalFunction( AllAtlasGeneratingSetInfos, function( arg )
    return AGR.AtlasGeneratingSetInfo( arg, "all" );
    end );


#############################################################################
##
#F  AtlasGroup( [<gapname>[, <std>]] )
#F  AtlasGroup( [<gapname>[, <std>]], IsPermGroup[, true] )
#F  AtlasGroup( [<gapname>[, <std>]], NrMovedPoints, <n> )
#F  AtlasGroup( [<gapname>[, <std>]], IsMatrixGroup[, true] )
#F  AtlasGroup( [<gapname>[, <std>]][, Characteristic, <p>]
#F                                  [, Dimension, <m>] )
#F  AtlasGroup( [<gapname>[, <std>]][, Ring, <R>][, Dimension, <m>] )
#F  AtlasGroup( [<gapname>[, <std>]], Position, <n> )
#F  AtlasGroup( <identifier> )
##
InstallGlobalFunction( AtlasGroup, function( arg )
    local info, gens, result;

    if   Length( arg ) = 1 and IsRecord( arg[1] ) then
      info:= arg[1];
    elif Length( arg ) = 1 and IsList( arg[1] ) and not IsString( arg[1] ) then
      info:= rec( identifier:= arg[1] );
    else
      info:= CallFuncList( OneAtlasGeneratingSetInfo, arg );
    fi;
    if info <> fail then
      gens:= AtlasGenerators( info.identifier );
      if gens <> fail then
        result:= GroupWithGenerators( gens.generators );
        if IsBound( gens.size ) then
          SetSize( result, gens.size );
          SetAtlasRepInfoRecord( result, info );
        fi;
        return result;
      fi;
    fi;
    return fail;
    end );


#############################################################################
##
#F  AtlasSubgroup( <gapname>[, <std>], <maxnr> )
#F  AtlasSubgroup( <gapname>[, <std>], IsPermGroup[, true], <maxnr> )
#F  AtlasSubgroup( <gapname>[, <std>], NrMovedPoints, <n>, <maxnr> )
#F  AtlasSubgroup( <gapname>[, <std>], IsMatrixGroup[, true], <maxnr> )
#F  AtlasSubgroup( <gapname>[, <std>][, Characteristic, <p>]
#F                                  [, Dimension, <m>], <maxnr> )
#F  AtlasSubgroup( <gapname>[, <std>][, Ring, <R>]
#F                                  [, Dimension, <m>], <maxnr> )
#F  AtlasSubgroup( <gapname>[, <std>], Position, <n>, <maxnr> )
#F  AtlasSubgroup( <G>, <maxnr> )
#F  AtlasSubgroup( <identifier>, <maxnr> )
##
InstallGlobalFunction( AtlasSubgroup, function( arg )
    local maxnr, info, groupname, std, prog, result, inforec;

    maxnr:= arg[ Length( arg ) ];
    if not IsPosInt( maxnr ) then
      Error( "<maxnr> must be a positive integer" );
    fi;

    if   Length( arg ) = 2 and IsRecord( arg[1] ) then
      info:= arg[1];
      groupname:= info.groupname;
    elif Length( arg ) = 2 and IsGroup( arg[1] ) then
      if not HasAtlasRepInfoRecord( arg[1] ) then
        Error( "the `AtlasRepInfoRecord' value is not set for the group" );
      fi;
      info:= AtlasRepInfoRecord( arg[1] );
      groupname:= info.groupname;
    elif Length( arg ) = 2 and IsList( arg[1] ) and not IsString( arg[1] ) then
      info:= rec( identifier:= arg[1], standardization:= arg[1][3] );
      groupname:= arg[1][1];
    elif 1 < Length( arg ) then
      info:= CallFuncList( OneAtlasGeneratingSetInfo,
                           arg{ [ 1 .. Length( arg ) - 1 ] } );
      groupname:= arg[1];
    else
      info:= fail;
    fi;

    if info = fail then
      return fail;
    fi;

    std:= info.standardization;
    prog:= AtlasProgram( groupname, std, "maxes", maxnr );
    if prog = fail then
      return fail;
    fi;

    if Length( arg ) = 2 and IsGroup( arg[1] ) then
      # We need not load the generators from files.
      result:= GroupWithGenerators( ResultOfStraightLineProgram( prog.program,
                                    GeneratorsOfGroup( arg[1] ) ) );
    else
      result:= AtlasGenerators( info.identifier );
      if result = fail then
        return fail;
      fi;
      result:= GroupWithGenerators( ResultOfStraightLineProgram( prog.program,
                                    result.generators ) );
    fi;

    if IsBound( prog.size ) then
      SetSize( result, prog.size );
    fi;
    inforec:= rec( identifier:= Concatenation( info.identifier,
                                               [ maxnr ] ),
                   standardization:= info.standardization );
    if IsBound( info.repnr ) then
      inforec.repnr:= info.repnr;
    fi;
    if IsBound( prog.subgroupname ) then
      inforec.groupname:= prog.subgroupname;
    fi;
    if IsBound( prog.size ) then
      inforec.size:= prog.size;
    fi;
    SetAtlasRepInfoRecord( result, inforec );

    return result;
    end );


#############################################################################
##
#F  AtlasProgramInfo( <gapname>[, <std>][, "maxes"], <maxnr> )
#F  AtlasProgramInfo( <gapname>[, <std>], "classes" )
#F  AtlasProgramInfo( <gapname>[, <std>], "cyclic" )
#F  AtlasProgramInfo( <gapname>[, <std>], "automorphism", <autname> )
#F  AtlasProgramInfo( <gapname>[, <std>], "check" )
#F  AtlasProgramInfo( <gapname>[, <std>], "pres" )
#F  AtlasProgramInfo( <gapname>[, <std>], "find" )
#F  AtlasProgramInfo( <gapname>, <std>, "restandardize", <std2> )
#F  AtlasProgramInfo( <gapname>[, <std>], "other", <descr> )
##
##  (Also the argument pair [, "contents", <sources> ] is supported.)
##
InstallGlobalFunction( AtlasProgramInfo, function( arg )
    local identifier, gapname, prefix, groupname, type, result, std, argpos,
          conditions, tocs, toc, record, id;

    if Length( arg ) = 1 then

      # `AtlasProgramInfo( <identifier> )'
      identifier:= arg[1];
      gapname:= identifier[1];
      if Length( gapname ) = 2 and IsString( gapname[1] ) then
        prefix:= gapname[1];
        gapname:= gapname[2];
      else
        prefix:= "dataword";
      fi;
      groupname:= AGR.InfoForName( gapname );
      if groupname = fail then
        return fail;
      fi;
      for type in AGR.DataTypes( "prg" ) do
        result:= type[2].AtlasProgramInfo( type, identifier, prefix,
                                           groupname[2] );
        if result <> fail then
          result.groupname:= gapname;
          return Immutable( result );
        fi;
      od;
      return fail;

    elif Length( arg ) = 0 or not IsString( arg[1] ) then
      Error( "the first argument must be the GAP name of a group" );
    fi;

    # Now handle the cases of more than one argument.
    gapname:= arg[1];
    groupname:= AGR.InfoForName( gapname );
    if groupname = fail then
      Info( InfoAtlasRep, 1,
            "AtlasProgramInfo: no group with GAP name `", gapname, "'" );
      return fail;
    fi;

    if IsInt( arg[2] ) and 2 < Length( arg ) then
      std:= [ arg[2] ];
      argpos:= 3;
    else
      std:= true;
      argpos:= 2;
    fi;
    conditions:= arg{ [ argpos .. Length( arg ) ] };

    # Restrict to a prescribed selection of tables of contents.
    tocs:= AGR.TablesOfContents( conditions );

    # `AtlasProgramInfo( <gapname>[, <std>][, "maxes"], <maxnr> )'
    if Length( conditions ) = 1 and IsInt( conditions[1] ) then
      conditions:= [ "maxes", conditions[1] ];
    fi;

    for toc in tocs do
      if IsBound( toc.( groupname[2] ) ) then
        record:= toc.( groupname[2] );
        for type in AGR.DataTypes( "prg" ) do
          id:= type[2].AccessPRG( record, std, conditions );
          if id <> fail then
            # The table of contents provides a program as is required.
            if not IsBound( toc.diridPrivate ) then
              id:= Concatenation( [ groupname[1] ], id );
            else
              id:= Concatenation( [ [ toc.diridPrivate, groupname[1] ] ],
                                  id );
            fi;
            return AtlasProgramInfo( id );
          fi;
        od;
      fi;
    od;

    # No program was found.
    Info( InfoAtlasRep, 2,
          "no program for conditions ", conditions, "\n",
          "#I  of the group with GAP name `", groupname[1], "'" );
    return fail;
end );


#############################################################################
##
#F  AtlasProgram( <gapname>[, <std>][, "maxes"], <maxnr> )
#F  AtlasProgram( <gapname>[, <std>], "classes" )
#F  AtlasProgram( <gapname>[, <std>], "cyclic" )
#F  AtlasProgram( <gapname>[, <std>], "automorphism", <autname> )
#F  AtlasProgram( <gapname>[, <std>], "check" )
#F  AtlasProgram( <gapname>[, <std>], "pres" )
#F  AtlasProgram( <gapname>[, <std>], "find" )
#F  AtlasProgram( <gapname>, <std>, "restandardize", <std2> )
#F  AtlasProgram( <gapname>[, <std>], "other", <descr> )
#F  AtlasProgram( <identifier> )
##
##  <identifier> is a list containing at the first position the string
##  <gapname>,
##  at the second position a string or a list of strings
##  (describing the filenames involved),
##  and at the third position a positive integer denoting the standardization
##  of the program.
##
InstallGlobalFunction( AtlasProgram, function( arg )
    local identifier, gapname, prefix, groupname, type, result, info;

    if Length( arg ) = 1 then

      # `AtlasProgram( <identifier> )'
      identifier:= arg[1];
      gapname:= identifier[1];
      if Length( gapname ) = 2 and IsString( gapname[1] ) then
        prefix:= gapname[1];
        gapname:= gapname[2];
      else
        prefix:= "dataword";
      fi;
      groupname:= AGR.InfoForName( gapname );
      if groupname = fail then
        return fail;
      fi;
      for type in AGR.DataTypes( "prg" ) do
        result:= type[2].AtlasProgram( type, identifier, prefix,
                                       groupname[2] );
        if result <> fail then
          result.groupname:= groupname[1];
          return Immutable( result );
        fi;
      od;
      return fail;

    elif Length( arg ) = 0 or not IsString( arg[1] ) then
      Error( "the first argument must be the GAP name of a group" );
    fi;

    # Now handle the cases of more than one argument.
    info:= CallFuncList( AtlasProgramInfo, arg );
    if info = fail then
      return fail;
    fi;
    return AtlasProgram( info.identifier );
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsUserParameters()
##
InstallGlobalFunction( AtlasOfGroupRepresentationsUserParameters,
  function()
    local str, prefix, pair, r;

    str:= "access to remote data:    ";
    if AtlasOfGroupRepresentationsInfo.remote then
      Append( str, "yes\n" );
    else
      Append( str, "no\n" );
    fi;

    prefix:= "servers:                  ";
    for pair in AtlasOfGroupRepresentationsInfo.servers do
      Append( str, prefix );
      prefix:= "                          ";
      Append( str, pair[1] );
      Append( str, "/" );
      Append( str, pair[2] );
      Append( str, "\n" );
    od;

    Append( str, "access remote data:       " );
    if   not IsBound( AtlasOfGroupRepresentationsInfo.wget )
         or not AtlasOfGroupRepresentationsInfo.wget in [ true, false ] then
      Append( str, "via the IO package (preferred) or wget\n" );
    elif AtlasOfGroupRepresentationsInfo.wget = true then
      Append( str, "only via wget\n" );
    else
      Append( str, "only via the IO package\n" );
    fi;

    Append( str, "compress data files:      " );
    if AtlasOfGroupRepresentationsInfo.compress then
      Append( str, "yes\n" );
    else
      Append( str, "no\n" );
    fi;

    Append( str, "display overviews via:    " );
    Append( str,
        NameFunction( AtlasOfGroupRepresentationsInfo.displayFunction ) );
    Append( str, "\n" );

    prefix:= "access functions:         ";
    for r in Reversed( AtlasOfGroupRepresentationsInfo.accessFunctions ) do
      Append( str, prefix );
      prefix:= "                          ";
      Append( str, r.description );
      if r.active = true then
        Append( str, " [enabled]\n" );
      else
        Append( str, " [disabled]\n" );
      fi;
    od;

    Append( str, "read MeatAxe text files:  " );
    if IsBound( CMeatAxe.FastRead ) and CMeatAxe.FastRead = true then
      Append( str, "fast\n" );
    else
      Append( str, "minimizing the space\n" );
    fi;

    return str;
end );


if IsString( RepeatedUTF8String ) then
  Unbind( RepeatedUTF8String );
fi;

#############################################################################
##
#E

