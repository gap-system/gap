#############################################################################
##
#W  interfac.gi          GAP 4 package AtlasRep                 Thomas Breuer
##
#H  @(#)$Id: interfac.gi,v 1.60 2009/08/19 14:53:39 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the implementation part of the ``high level'' GAP
##  interface to the ATLAS of Group Representations.
##
Revision.( "atlasrep/gap/interfac_gi" ) :=
    "@(#)$Id: interfac.gi,v 1.60 2009/08/19 14:53:39 gap Exp $";


#############################################################################
##
#F  DisplayAtlasInfoOverview( <gapnames>, <tocs>, <conditions> )
##
InstallGlobalFunction( DisplayAtlasInfoOverview,
    function( gapnames, tocs, conditions )
    local columns, type, widths, i, width, result, j;

    # Consider only those names for which actually information is available.
    # (The ordering shall be the same as in the input.)
    if gapnames = "all" then
      gapnames:= AtlasOfGroupRepresentationsInfo.GAPnamesSortDisp;
    else
      gapnames:= Filtered( List( gapnames, AGR_InfoForName ),
                           x -> x <> fail );
    fi;
    gapnames:= Filtered( gapnames,
                   x -> ForAny( tocs, toc -> IsBound( toc.( x[2] ) ) ) );
    if IsEmpty( gapnames ) then
      return;
    fi;

    # Compute the data of the columns.
    columns:= [ [ "group", "l", List( gapnames, x -> [ x[1], false ] ) ] ];
    for type in AGRDataTypes( "rep", "prg" ) do
      if type[2].DisplayOverviewInfo <> fail then
        if type[3] = "rep" then
          Add( columns, [
               type[2].DisplayOverviewInfo[1],
               type[2].DisplayOverviewInfo[2],
               List( gapnames,
                     n -> type[2].DisplayOverviewInfo[3]( tocs,
                              Concatenation( [ n[1] ], conditions ) ) ) ] );
        else
          Add( columns, [
               type[2].DisplayOverviewInfo[1],
               type[2].DisplayOverviewInfo[2],
               List( gapnames,
                     n -> type[2].DisplayOverviewInfo[3]( tocs, n[2] ) ) ] );
        fi;
      fi;
    od;

    # Compute the appropriate column widths.
    widths:= [];
    for i in columns do
      width:= Maximum( Length( i[1] ),       # the header string shall fit
                  Maximum( List( i[3], y -> Length( y[1] ) ) ) );
      if i[2] = "l" then
        width:= -width;
      fi;
      Add( widths, width );
    od;

    result:= [];

    # Add the header line.
    Add( result, JoinStringsWithSeparator( List( [ 1 .. Length( columns ) ],
               j -> String( columns[j][1], widths[j] ) ),  " | " ) );
    Add( result, JoinStringsWithSeparator( List( [ 1 .. Length( columns ) ],
               j -> RepeatedString( "-", AbsInt( widths[j] ) ) ), "-+-" ) );

    # Add the information for each group.
    for i in [ 1 .. Length( gapnames ) ] do
      if ForAny( columns, x -> x[3][i][2] ) then
        columns[1][3][i][1]:= Concatenation( columns[1][3][i][1],
            AtlasOfGroupRepresentationsInfo.markprivate );
      fi;
      Add( result, JoinStringsWithSeparator( List( [ 1 .. Length( columns ) ],
               j -> String( columns[j][3][i][1], widths[j] ) ), " | " ) );
    od;
    Add( result, "" );

    width:= SizeScreen()[1] - 2;
    if width < Length( result[1] ) then
      # Shorten the lines; in particular the output of `Pager' is unusable
      # if the lines are longer than the screen width.
      result:= List( result, line -> line{ [ 1 .. width ] } );
      AtlasOfGroupRepresentationsInfo.displayFunction(
          JoinStringsWithSeparator( result, "\n" ) );
      Print( "#W  screen width too small, lines were shortened\n" );
    else
      AtlasOfGroupRepresentationsInfo.displayFunction(
          JoinStringsWithSeparator( result, "\n" ) );
    fi;
    end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsInfoPRG( <gapname>, <tocs>, <name>, <std> )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsInfoPRG,
    function( gapname, tocs, name, std )
    local stdavail, j, toc, record, type, list, header;

    # If the standardization is prescribed then do not mention it.
    # Otherwise if all information refers to the same standardization then
    # print just one line.
    # Otherwise print the standardization for each entry.
    stdavail:= [];
    if std = true or 1 < Length( std ) then
      for toc in tocs do
        if IsBound( toc.( name ) ) then
          record:= toc.( name );
          for type in AGRDataTypes( "prg" ) do
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
    header:= [ "Programs for G = ", gapname, ":" ];
    if Length( stdavail ) = 1 then
      Append( header, [ "    (all refer to std. generators ",
                        String( stdavail[1] ), ")" ] );
    fi;

    # Collect the info lines for the scripts.
    list:= [];
    for type in AGRDataTypes( "prg" ) do
      Append( list, type[2].DisplayPRG( tocs, name, std, stdavail ) );
    od;

    return rec( header := header,
                list   := list );
    end );


#############################################################################
##
#F  AGREvaluateMinimalityCondition( <gapname>, <conditions> )
##
##  Evaluate conditions involving `"minimal"'.
##  The return value is a copy of <conditions> in which one occurrence of
##  `"minimal"' is replaced by the corresponding number if this is known,
##  or a string describing an info message otherwise.
##
BindGlobal( "AGREvaluateMinimalityCondition", function( gapname, conditions )
    local pos, info, pos2;

    pos:= Position( conditions, "minimal" );
    if pos <> fail and pos <> 1 then
      if   IsIdenticalObj( conditions[ pos-1 ], NrMovedPoints ) then
        # ..., NrMovedPoints, "minimal", ...
        info:= MinimalRepresentationInfo( gapname, NrMovedPoints );
        if info = fail then
          return Concatenation( 
                     "minimal perm. repr. of `", gapname, "' not known" );
        fi;
        conditions:= ShallowCopy( conditions );
        conditions[ pos ]:= info.value;
      elif IsIdenticalObj( conditions[ pos-1 ], Dimension ) then
        pos2:= Position( conditions, Characteristic );
        if pos2 <> fail and pos2 < Length( conditions ) then
          # ..., Characteristic, <p>, ..., Dimension, "minimal", ...
          info:= MinimalRepresentationInfo( gapname,
                     Characteristic, conditions[ pos2+1 ] );
          if info = fail then
            return Concatenation( "minimal matrix repr. of `", gapname,
                                  "' in characteristic ",
                                  conditions[ pos2+1 ], " not known" );
          fi;
          conditions:= ShallowCopy( conditions );
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
              return Concatenation( "minimal matrix repr. of `", gapname,
                                    "' over `", conditions[ pos2+1 ],
                                    "' not known" );
            fi;
            conditions:= ShallowCopy( conditions );
            conditions[ pos ]:= info.value;
          fi;
        fi;
      fi;
    fi;

    return conditions;
    end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsInfoGroup( <tocs>, <conditions> )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsInfoGroup,
    function( tocs, conditions )
    local info, stdavail, header, list, r, entry;

    info:= AtlasGeneratingSetInfo( tocs, conditions, "disp" );

    # If all information refers to the same standardization then
    # print just one line.
    # Otherwise print the standardization for each entry.
    stdavail:= Set( List( info, x -> x.standardization ) );

    # Construct the header line.
    # (Because of `AtlasRepCreateHTMLInfoForGroup',
    # `gapname' must occur as an entry of its own .)
    header:= [ "Representations for G = ", conditions[1], ":" ];
    if Length( stdavail ) = 1 then
      Add( header, Concatenation(
           "    (all refer to std. generators ", String( stdavail[1] ),
           ")" ) );
    fi;

    list:= [];
    for r in info do
      entry:= r.displayGroup;
      if IsString( entry ) then
        entry:= [ entry ];
      fi;
      entry:= [ [ String( r.repnr ), ":" ], [ entry[1], "" ],
                entry{ [ 2 .. Length( entry ) ] } ];
      if r.private then
        entry[2][2]:= AtlasOfGroupRepresentationsInfo.markprivate;
      fi;
      if 1 < Length( stdavail ) then
        Add( entry, [ ", w.r.t. std. gen. ", String( r.standardization ) ] );
      fi;
      Add( list, entry );
    od;

    return rec( header := header,
                list   := list );
    end );


#############################################################################
##
#F  DisplayAtlasInfo( [<listofnames>][, ]["contents", <sources>]
#F                    [, IsPermGroup[, true]]
#F                    [, NrMovedPoints, <n>]
#F                    [, IsMatrixGroup[, true]]
#F                    [, Characteristic, <p>][, Dimension, <n>]
#F                    [, Position, <n>]
#F                    [, Identifier, <id>] )
#F  DisplayAtlasInfo( <gapname>[, <std>][, "contents", <sources>]
#F                    [, IsPermGroup[, true]]
#F                    [, NrMovedPoints, <n>]
#F                    [, IsMatrixGroup[, true]]
#F                    [, Characteristic, <p>][, Dimension, <n>]
#F                    [, Position, <n>]
#F                    [, Identifier, <id>]
#F                    [, IsStraightLineProgram[, true]] )
##
InstallGlobalFunction( DisplayAtlasInfo, function( arg )
    local argpos, tocs, gapname, groupname, result, std, info1, list, line,
          len1, len2, screenwidth, indent, underline, i, prefix, entry, info2;

    argpos:= Position( arg, "contents" );
    if argpos <> fail then
      tocs:= AGR_TablesOfContents( arg[ argpos+1 ] );
      arg:= Concatenation( arg{ [ 1 .. argpos-1 ] },
                           arg{ [ argpos+2 .. Length( arg ) ] } );
    else
      tocs:= AGR_TablesOfContents( "all" );
    fi;

    # Deal with the summary overview for more than one group.
    if   Length( arg ) = 0 then
      DisplayAtlasInfoOverview( "all", tocs, [] );
      return;
    elif IsList( arg[1] ) and ForAll( arg[1], IsString ) then
      DisplayAtlasInfoOverview( arg[1], tocs, arg{ [ 2 .. Length( arg ) ] } );
      return;
    elif not IsString( arg[1] ) then
      DisplayAtlasInfoOverview( "all", tocs, arg );
      return;
    fi;

    # Deal with the detailed overview for one group.
    gapname:= arg[1];
    groupname:= AGR_InfoForName( gapname );
    if groupname = fail then
      Info( InfoAtlasRep, 1,
            "DisplayAtlasInfo: no group with GAP name `", gapname, "'" );
      return;
    fi;

    result:= "";

    if Length( arg ) = 1 or not ( IsInt( arg[2] ) or IsList( arg[2] ) ) then
      std:= true;
      argpos:= 2;
    else
      std:= arg[2];
      if IsInt( std ) then
        std:= [ std ];
      fi;
      argpos:= 3;
    fi;

    if Length( arg ) <> argpos or arg[ argpos ] <> IsStraightLineProgram then

      # `DisplayAtlasInfo( <gapname>[, <std>][, <conditions>] )'
      info1:= AtlasOfGroupRepresentationsInfoGroup( tocs, arg );
      if not IsEmpty( info1.list ) then

        list:= [];
        for line in info1.list do
          Add( list, Concatenation(
               [ Concatenation( line[1] ), Concatenation( line[2] ) ],
               Concatenation( line{ [ 3 .. Length( line ) ] } ) ) );
        od;
        len1:= Maximum( List( list, x -> Length( x[1] ) ) );
        len2:= - Maximum( List( list, x -> Length( x[2] ) ) );
        screenwidth:= SizeScreen()[1] - 1;
        indent:= 0;
        line:= Concatenation( info1.header{ [ 1 .. 3 ] } );
        underline:= ListWithIdenticalEntries( Sum( List(
                        info1.header{ [ 1 .. 3 ] }, Length ) ), '-' );
        Add( underline, '\n' );
        for i in [ 4 .. Length( info1.header ) ] do
          if Length( line ) + Length( info1.header[i] ) >= screenwidth
             and Length( line ) <> indent then
            Append( result, line );
            Add( result, '\n' );
            Append( result, underline );
            underline:= "";
            line:= "";
          fi;
          Append( line, info1.header[i] );
        od;
        Append( result, line );
        Add( result, '\n' );
        Append( result, underline );

        indent:= len1 - len2 + 2;
        if indent >= screenwidth then
          indent:= 1;
        fi;
        prefix:= RepeatedString( " ", indent );
        for entry in list do
          line:= Concatenation( String( entry[1], len1 ), " ",
                                String( entry[2], len2 ), " " );
          for i in [ 3 .. Length( entry ) ] do
            if Length( line ) + Length( entry[i] ) >= screenwidth
               and Length( line ) <> indent then
              Append( result, line );
              Add( result, '\n' );
              line:= ShallowCopy( prefix );
            fi;
            Append( line, entry[i] );
          od;
          Append( result, line );
          Add( result, '\n' );
        od;
      fi;
    fi;
    if ( Length( arg ) = argpos and arg[ argpos ] = IsStraightLineProgram )
       or ( Length( arg ) = argpos + 1
            and arg[ argpos ] = IsStraightLineProgram
            and arg[ argpos + 1 ] = true )
       or Length( arg ) < argpos then

      # `DisplayAtlasInfo( <gapname>[, <std>][, IsStraightLineProgram] )'
      info2:= AtlasOfGroupRepresentationsInfoPRG( gapname, tocs,
                  groupname[2], std );
      if not IsEmpty( info2.list ) then
        if IsBound( info1 ) and not IsEmpty( info1.list ) then
          Append( result, "\n" );
        fi;
        Append( result, Concatenation(
                  Concatenation( info2.header ), "\n",
                  ListWithIdenticalEntries( Sum( List(
                      info2.header{ [ 1 .. 3 ] }, Length ) ), '-' ),
                  "\n",
                  Concatenation( info2.list ) ) );
      fi;

    fi;

    AtlasOfGroupRepresentationsInfo.displayFunction( result );
    end );


#############################################################################
##
#F  AtlasGenerators( <gapname>, <repnr> )
#F  AtlasGenerators( <gapname>, <repnr>, <maxnr> )
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
          res, type, j, toc, record, pos, try, gens, name, gen, result, prog;

    tocs:= AGR_TablesOfContents( "all" );
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
      groupname:= AGR_InfoForName( gapname );
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
      for type in AGRDataTypes( "rep" ) do
        for j in [ 1 .. Length( tocs ) ] do
          toc:= tocs[j];
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
      groupname:= AGR_InfoForName( gapname );
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
      for type in AGRDataTypes( "rep" ) do
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
    gens:= AGRFileContents( prefix, groupname[2], identifier[2], type );
    if gens = fail then
      return fail;
    fi;
    result:= rec( generators      := gens,
                  groupname       := gapname,
                  standardization := identifier[3],
                  repnr           := repnr,
                  identifier      := identifier );
    type[2].AddDescribingComponents( result, type );

    if IsBound( maxnr ) then

      Unbind( result.groupname );

      # Compute the straight line program for the restriction
      # (w.r.t. the correct standardization).
      prog:= AtlasProgram( gapname, identifier[3], maxnr );
      if prog = fail then
        return fail;
      fi;

      # Evaluate the straight line program.
      result.generators:= ResultOfStraightLineProgram( prog.program, gens );

      if IsBound( groupname[4] ) and IsBound( groupname[4][ maxnr ] ) then
        result.size:= groupname[4][ maxnr ];
      fi;

    elif IsBound( groupname[3] ) then
      result.size:= groupname[3];
    fi;

    # Return the result.
    return Immutable( result );
    end );


#############################################################################
##
#F  AtlasGeneratingSetInfo( <tocs>, <conditions>, "one" )
#F  AtlasGeneratingSetInfo( <tocs>, <conditions>, "all" )
#F  AtlasGeneratingSetInfo( <tocs>, <conditions>, "disp" )
#F  AtlasGeneratingSetInfo( <tocs>, <conditions>, <types> )
##
InstallGlobalFunction( AtlasGeneratingSetInfo,
    function( tocs, conditions, mode )
    local gapnames, types, std, pos, position, result, gapname, groupname,
          cond, repnr, type, typeresult, sortkeys, j, toc, record, i, id,
          oneresult;

    # The first argument (if there is one) is a group name,
    # a list of group names, an integer (denoting a standardization),
    # or a function (denoting the first condition).
    if Length( conditions ) = 0 or IsInt( conditions[1] )
                                or IsFunction( conditions[1] ) then
      # The group is not restricted.
      gapnames:= List( AtlasOfGroupRepresentationsInfo.GAPnamesSortDisp,
                       pair -> pair[1] );
    elif IsString( conditions[1] ) then
      # Only one group is considered.
      gapnames:= [ conditions[1] ];
      conditions:= conditions{ [ 2 .. Length( conditions ) ] };
    elif IsList( conditions[1] ) and ForAll( conditions[1], IsString ) then
      # A list of group names is prescribed.
      gapnames:= conditions[1];
      conditions:= conditions{ [ 2 .. Length( conditions ) ] };
    else
      Error( "invalid first argument ", conditions[1] );
    fi;

    # The list argument is either a string or a list of types.
    if IsString( mode ) then
      types:= AGRDataTypes( "rep" );
    else
      types:= mode;
    fi;

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
        Error( "Position must be followed by a positive integer" );
      fi;
      position:= conditions[ pos+1 ];
      conditions:= Concatenation( conditions{ [ 1 .. pos-1 ] },
                       conditions{ [ pos+2 .. Length( conditions ) ] } );
    fi;
 
    result:= [];
    repnr:= 1;

    for gapname in gapnames do
      groupname:= AGR_InfoForName( gapname );
      if groupname <> fail then

        # Evaluate conditions involving `"minimal"'.
        cond:= AGREvaluateMinimalityCondition( gapname, conditions );
        if IsString( cond ) and not IsEmpty( cond ) then
          Info( InfoAtlasRep, 1, cond ); 
        else

          # Loop over the relevant representations.
          for type in types do
            typeresult:= [];
            sortkeys:= [];
            for j in [ 1 .. Length( tocs ) ] do
              toc:= tocs[j];
              if IsBound( toc.( groupname[2] ) ) then
                record:= toc.( groupname[2] );
                if IsBound( record.( type[1] ) ) then
                  for i in record.( type[1] ) do
                    if not IsBound( toc.diridPrivate ) then
                      id:= gapname;
                    else
                      id:= [ toc.diridPrivate, gapname ];
                    fi;
                    id:= [ id, i[ Length(i) ], i[1], i[2] ];
                    oneresult:= rec(
                                     groupname       := gapname,
                                     standardization := id[3],
                                     identifier      := id,
                                   );
                    type[2].AddDescribingComponents( oneresult, type );
                    if mode = "disp" or not IsString( mode ) then
                      oneresult.displayGroup:= type[2].DisplayGroup( i );
                      oneresult.private:= IsBound( toc.diridPrivate );
                    fi;
                    if IsBound( groupname[3] ) then
                      oneresult.size:= groupname[3];
                    fi;
                    Add( typeresult, oneresult );
                    Add( sortkeys, type[2].SortTOCEntries( i ) );
                  od;
                fi;
              fi;
            od;
            SortParallel( sortkeys, typeresult );
            for i in [ 1 .. Length( typeresult ) ] do
              typeresult[i].repnr:= repnr;
              if     ( pos = fail or position = repnr )
                 and ( std = true or typeresult[i].standardization in std )
                 and type[2].AccessGroupCondition( typeresult[i],
                         ShallowCopy( cond ) ) then
                if mode = "one" then
                  return typeresult[i];
                fi;
              else
                Unbind( typeresult[i] );
              fi;
              repnr:= repnr + 1;
            od;
            Append( result, Compacted( typeresult ) );
          od;

        fi;

      fi;
    od;

    # We have checked all available representations.
    if mode = "one" then
      return fail;
    else
      return result;
    fi;
    end );
#T better provide a merged table of contents,
#T which is sorted; then we can immediately return the first found repres.
#T in the "one" case, and we need not collect objects for uninteresting
#T representations!
#T recompute this t.o.c. whenever a new t.o.c. is notified!


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
    local argpos, tocs;

    argpos:= Position( arg, "contents" );
    if argpos <> fail then
      tocs:= AGR_TablesOfContents( arg[ argpos+1 ] );
      arg:= Concatenation( arg{ [ 1 .. argpos-1 ] },
                           arg{ [ argpos+2 .. Length( arg ) ] } );
    else
      tocs:= AGR_TablesOfContents( "all" );
    fi;

    return AtlasGeneratingSetInfo( tocs, arg, "one" );
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
    local argpos, tocs;

    argpos:= Position( arg, "contents" );
    if argpos <> fail then
      tocs:= AGR_TablesOfContents( arg[ argpos+1 ] );
      arg:= Concatenation( arg{ [ 1 .. argpos-1 ] },
                           arg{ [ argpos+2 .. Length( arg ) ] } );
    else
      tocs:= AGR_TablesOfContents( "all" );
    fi;

    return AtlasGeneratingSetInfo( tocs, arg, "all" );
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
    local info, result;

    if   Length( arg ) = 1 and IsRecord( arg[1] ) then
      info:= arg[1];
    elif Length( arg ) = 1 and IsList( arg[1] ) and not IsString( arg[1] ) then
      info:= rec( identifier:= arg[1] );
    else
      info:= CallFuncList( OneAtlasGeneratingSetInfo, arg );
    fi;
    if info <> fail then
      info:= AtlasGenerators( info.identifier );
      result:= GroupWithGenerators( info.generators );
      if IsBound( info.size ) then
        SetSize( result, info.size );
      fi;
      return result;
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
#F  AtlasSubgroup( <identifier>, <maxnr> )
##
InstallGlobalFunction( AtlasSubgroup, function( arg )
    local info, groupname, maxnr, std, prog, gens, result;

    if   Length( arg ) = 2 and IsRecord( arg[1] ) then
      info:= arg[1];
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
    maxnr:= arg[ Length( arg ) ];
    if info <> fail then
      std:= info.standardization;
      prog:= AtlasProgram( groupname, std, "maxes", maxnr );
      if prog <> fail then
        gens:= AtlasGenerators( info.identifier );
        if gens <> fail then
          result:= ResultOfStraightLineProgram( prog.program,
                                                gens.generators );
          result:= GroupWithGenerators( result );
          if IsBound( prog.size ) then
            SetSize( result, prog.size );
          fi;
          return result;
        fi;
      fi;
    fi;

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
    local identifier, gapname, prefix, groupname, type, result, std,
          argpos, conditions, tocs, j, toc, record, id;

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
      groupname:= AGR_InfoForName( gapname );
      if groupname = fail then
        return fail;
      fi;
      for type in AGRDataTypes( "prg" ) do
        result:= type[2].AtlasProgram( type, identifier, prefix,
                                       groupname[2] );
        if result <> fail then
          result.groupname:= gapname;
          return Immutable( result );
        fi;
      od;
      return fail;

    fi;

    # Now handle the cases of more than one argument.
    if Length( arg ) = 0 or not IsString( arg[1] ) then
      Error( "the first argument must be the GAP name of a group" );
    fi;
    gapname:= arg[1];
    groupname:= AGR_InfoForName( gapname );
    if groupname = fail then
      Info( InfoAtlasRep, 1,
            "AtlasProgram: no group with GAP name `", gapname, "'" );
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

    # `AtlasProgram( <gapname>[, <std>][, "maxes"], <maxnr> )'
    if Length( conditions ) = 1 and IsInt( conditions[1] ) then
      conditions:= [ "maxes", conditions[1] ];
    fi;

    tocs:= AGR_TablesOfContents( "all" );
    for j in [ 1 .. Length( tocs ) ] do
      toc:= tocs[j];
      if IsBound( toc.( groupname[2] ) ) then
        record:= toc.( groupname[2] );
        for type in AGRDataTypes( "prg" ) do
          id:= type[2].AccessPRG( record, std, conditions );
          if id <> fail then
            if not IsBound( toc.diridPrivate ) then
              id:= Concatenation( [ groupname[1] ], id );
            else
              id:= Concatenation( [ [ toc.diridPrivate, groupname[1] ] ],
                                  id );
            fi;
            return AtlasProgram( id );
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
#F  AtlasOfGroupRepresentationsShowUserParameters()
##
InstallGlobalFunction( AtlasOfGroupRepresentationsShowUserParameters,
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

    Print( str );
end );


#############################################################################
##
#E

