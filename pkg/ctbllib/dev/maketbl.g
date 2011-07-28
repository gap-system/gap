#############################################################################
##
#W  maketbl.g           GAP character table library             Thomas Breuer
##
#H  @(#)$Id: maketbl.g,v 1.5 2010/12/01 17:34:32 gap Exp $
##
#Y  Copyright (C)  2007,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the function `CTblLibRecomputeTOC', which produces
##  the file 'data/ctprimar.tbl' of the CTblLib package of GAP 4
##  from the data files 'data/ct[go]*'.
##  (In earlier versions,
##  this task was done by the `awk' script `etc/maketbl'.)
##
##  For the conventions about the contents of the table library files,
##  see '../gap4/ctadmin.tbd'.
##
##  If a line has more than 78 characters or ends with a backslash,
##  a warning is printed.
##
##  The following calls to 'ARC' are used by this program.
##
##  ARC("<name>","maxes",<list>);
##      The string "<name>M<i>" is constructed as an admissible name for
##      the <i>-th entry of <list> (which may contain holes).
##
##  ARC("<name>","projectives",<list>);
##      The projection maps from the tables whose names occur at the odd
##      positions in <list> to <name> will be stored in the global list
##      'LIBLIST.projections'.
##      It is assumed that after the first line of a call, at most one
##      table name occurs in each line.
##
##  ARC("<name>","isSimple",<list>);
##      The table <name> will occur in the list 'LIBLIST.simpleInfo'.
##
##  ARC("<name>","extInfo",<list>);
##      For simple tables <name>, the info in <list> will be stored in
##      'LIBLIST.simpleInfo'.
##

#T local function, eventually should be available in IO!
CTblLibCurrentDateTimeString:= function( options )
    local name, str, out;

    name:= Filename( DirectoriesSystemPrograms(), "date" );
    if name = fail then
      return "unknown";
    fi;
    str:= "";
    out:= OutputTextString( str, true );
    Process( DirectoryCurrent(), name, InputTextNone(), out, options );
    CloseStream( out );
    Unbind( str[ Length( str ) ] );
    return str;
end;


#############################################################################
##
#F  CTblLibRecomputeTOC()
##
##  replaces the file `data/ctprimar.tbl' by an updated version,
##  according to the data files `data/cto*.tbl' and `data/ctg*.tbl',
##  saves the old contents in `data/ctprimar.tbl~'
##
CTblLibRecomputeTOC:= function()
    local match, matchstart, matchend, app, amend, setnewname, dir, infiles,
          ordinfiles, modinfiles, clminfiles, outfile, bakfile, outstr,
          firstnames, allnames, lowerposition, simplenames, extinfo, tbltom,
          projectivesinfo, fusions, currname, infile, lines, i, line, nam,
          tolo, spl, k, entry, l, map, known, currfile, count, filecounts,
          pair, oldcontents, pos, diff, str, out;

    match:= function( str, substr )
      return PositionSublist( str, substr ) <> fail;
    end;

    matchstart:= function( str, prefix )
      return Length( prefix ) <= Length( str ) and
             str{ [ 1 .. Length( prefix ) ] } = prefix;
    end;

    matchend:= function( str, suffix )
      return Length( suffix ) <= Length( str ) and
             str{ [ 1 - Length( suffix ) .. 0 ] + Length( str ) } = suffix;
    end;

    app:= function( arg )
      local string;
      for string in arg do
        Append( outstr, string );
      od;
    end;

    amend:= function( line, prefix, toadd, suffix, indent )
      if Sum( List( [ line, prefix, toadd, suffix ], Length ) ) <= 77 then
        return Concatenation( line, prefix, toadd, suffix );
      else
        app( line, "\n" );
        return Concatenation( indent, prefix, toadd, suffix );
      fi;
    end;

    setnewname:= function( new, old, first )
      local known;

      known:= First( allnames, x -> new in x[2] );
      if known = fail then
        known:= First( allnames, x -> old = x[1] );
        if known = fail then
          Add( allnames, [ old, [ new ] ] );
        else
          AddSet( known[2], new );
        fi;
      elif old <> known[1] then
        Print( "clash: name '", new, "' for tables '", old, "' and '",
               known[1], "'\n" );
      elif first = 0 then
        # Omit this warning if the first name of the table is <nam>M<n>.
        Print( "name '", new, "' defined twice for table '", old, "'\n" );
      fi;
    end;

    # input files
    dir:= DirectoriesPackageLibrary( "ctbllib", "data" );
    infiles:= SortedList( DirectoryContents( Filename( dir, "" ) ) );
    ordinfiles:= Filtered( infiles,
                     f -> matchstart( f, "cto" ) and matchend( f, ".tbl" ) );
    modinfiles:= Filtered( infiles,
                     f -> matchstart( f, "ctb" ) and matchend( f, ".tbl" ) );
    clminfiles:= Filtered( infiles,
                     f -> matchstart( f, "clm" ) and matchend( f, ".tbl" ) );
    outfile:= Filename( dir, "ctprimar.tbl" );
    bakfile:= Filename( dir, "ctprimar.tbl~" );

    # Keep the initial part of the output file.
    outstr:= StringFile( outfile );
    outstr:= outstr{ [ 1 ..
                       PositionSublist( outstr, "\nLIBLIST.firstnames" ) ] };

    # Initialize the lists of names.
    firstnames:= [];
    allnames:= [];
    lowerposition:= [];
    simplenames:= [];
    extinfo:= [];
    tbltom:= [];
    projectivesinfo:= [];
    fusions:= [];
    currname:= "(unbound)";

    # Loop over the input files.
    for infile in ordinfiles do
      lines:= SplitString( StringFile( Filename( dir, infile ) ), "\n" );
      i:= 1;
      while i <= Length( lines ) do

        line:= lines[i];

        # Check for lines with more than 78 characters.
        if 78 < Length( line ) then
          Print( "too long line in ", infile, ":\n", line, "\n" );
        fi;

        # Check for trailing backslashes.
        if matchend( line, "\\" ) then
          Print( "trailing backslash in ", infile, ":\n", line, "\n" );
        fi;

        # Store the first names and the corresponding file names.
        if matchstart( line, "MOT" ) then
          nam:= SplitString( line, "\"" )[2];
          currname:= nam;
          tolo:= LowercaseString( nam );
          if tolo in lowerposition then
            Print( "double name ", tolo, " (ignored in ", infile, ")\n" );
          else
            Add( firstnames, [ nam, infile ] );
            AddSet( lowerposition, tolo );
            setnewname( tolo, nam, 1 );
          fi;
        fi;

        # Store the other names of the tables.
        if matchstart( line, "ALN(" ) then
          spl:= SplitString( line, "\"" );
          nam:= spl[2];
          if nam <> currname then
            Print( "ALN call for `", nam, "' under `", currname, "'\n" );
          fi;
          for k in [ 4 .. Length( spl ) ] do
            if spl[k] <> "" and spl[k] <> "," and spl[k] <> "]);" then
              setnewname( LowercaseString( spl[k] ), nam, 0 );
            fi;
          od;

          # Scan until the assignment is complete.
          while not ';' in spl[ Length( spl ) ] do
            i:= i + 1;
            line:= lines[i];
            spl:= SplitString( line, "\"" );
            for entry in spl do
              if entry <> "" and entry <> "," and entry <> "]);" then
                setnewname( LowercaseString( entry ), nam, 0 );
              fi;
            od;
          od;
        fi;

        if matchstart( line, "ARC(" ) then
          spl:= SplitString( line, "\"" );
          if spl[2] <> currname then
            Print( "ARC call for `", spl[2], "' under `", currname, "'\n" );
          fi;
        fi;

        # Store the extension info for simple groups.
        if matchstart( line, "ARC(" ) and match( line, "\"isSimple\"" ) then
          spl:= SplitString( line, "\"" );
          if spl[5] = ",true);" then
            Add( simplenames, spl[2] );
          fi;
        fi;
        if matchstart( line, "ARC(" ) and match( line, "\"extInfo\"" ) then
          Add( extinfo, SplitString( line, "\"" ){ [ 6, 2, 8 ] } );
        fi;

        # Create the names defined by 'maxes' components.
        if matchstart( line, "ARC(" ) and match( line, "\"maxes\"" ) then
          spl:= SplitString( line, "\"" );
          nam:= LowercaseString( spl[2] );
          l:= Number( spl[5], x -> x = ',' );
          for k in [ 6 .. Length( spl ) ] do
            entry:= spl[k];
            if ',' in entry and ForAll( entry, x -> x = ',' ) then
              l:= l + Number( entry, x -> x = ',' );
            elif not ';' in entry then
              tolo:= Concatenation( nam, "m", String( l ) );
              if tolo <> LowercaseString( entry ) then
                setnewname( tolo, entry, 0 );
              fi;
            fi;
          od;

          # Scan until the assignment is complete.
          while not ';' in spl[ Length( spl ) ] do
            i:= i + 1;
            line:= lines[i];
            spl:= SplitString( line, "\"" );
            for entry in spl do
              if ',' in entry and ForAll( entry, x -> x = ',' ) then
                l:= l + Number( entry, x -> x = ',' );
              elif entry <> "" and not ';' in entry then
                tolo:= Concatenation( nam, "m", String( l ) );
                if tolo <> LowercaseString( entry ) then
                  setnewname( tolo, entry, 0 );
                fi;
              fi;
            od;
          od;
        fi;

        # Store the info needed for the map to the names of tables of marks.
        if matchstart( line, "ARC(" ) and match( line, "\"tomfusion\"" ) then
          spl:= SplitString( line, "\"" );
          Add( tbltom, [ spl[6], spl[2] ] );
        fi;

        # Store the source and destination of fusions (just for checks),
        # and store the fusions (for the treatment of projections).
        if matchstart( line, "ALF(" ) then
          spl:= SplitString( line, "\"" );
          if spl[2] <> currname then
            Print( "ALF call for `", spl[2], "' under `", currname, "'\n" );
          fi;
          map:= spl[5];
          if map[ Length( map ) ] in ";[" then
            # The complete assignment fits in one line.
            map:= map{ [ 2 .. Length( map ) - 2 ] };
          else
            # There are more than one line to scan.
            map:= map{ [ 2 .. Length( map ) ] };
            i:= i + 1;
            line:= lines[i];
            while not line[ Length( line ) ] in ";[" do
              Append( map, "\n  " );
              Append( map, line );
              i:= i + 1;
              line:= lines[i];
            od;
            Append( map, "\n  " );
            Append( map, line{ [ 1 .. Length( line ) - 2 ] } );
          fi;
          known:= Filtered( fusions, x -> x[1] = spl[2] and x[2] = spl[4] );
          if ForAny( known, x -> x[3] = map ) then
            Print( infile, ": remove duplicate fusion ",
                   spl[2], " -> ", spl[4], "\n" );
          elif not IsEmpty( known ) then
            Print( infile, ": several fusions ",
                   spl[2], " -> ", spl[4], "?\n" );
            Add( fusions, [ spl[2], spl[4], map ] );
          else
            Add( fusions, [ spl[2], spl[4], map ] );
          fi;
        fi;

        # Store the names of source and image of the projections.
        if matchstart( line, "ARC(" ) and match( line, "\"projectives\"" ) then
          spl:= SplitString( line, "\"" );
          nam:= spl[2];
          Add( projectivesinfo, spl{ [ 2, 6 ] } );

          # Scan until the assignment is complete.
          while not ';' in spl[ Length( spl ) ] do
            i:= i + 1;
            line:= lines[i];
            spl:= SplitString( line, "\"" );
            if Length( spl ) <> 1 then
              Add( projectivesinfo, [ nam, spl[2] ] );
            fi;
          od;
        fi;

        i:= i + 1;
      od;
    od;

    # Print the list of first names, in lines of length at most 77.
    line:= "LIBLIST.firstnames := [";
    currfile:= "";
    count:= 0;
    filecounts:= [];
    for pair in firstnames do
      if pair[2] <> currfile then
        # Start of a new file, separate the portions.
        currfile:= pair[2];
        app( line, "\n # file ", currfile{ [ 1 .. Length( currfile ) - 4 ] },
             "\n" );
        line:= " ";
        Add( filecounts, String( count ) );
        count:= 0;
      fi;
      count:= count + 1;
      line:= amend( line, " \"", pair[1], "\",", " " );
    od;
    Add( filecounts, String( count ) );
    app( line, "];\nMakeImmutable( LIBLIST.firstnames );\n\n" );

    # Check whether for the Brauer tables in the file 'ctb<id>.tbl',
    # the ordinary tables are in 'cto<id>.tbl'.
    for infile in modinfiles do
      for line in SplitString( StringFile( Filename( dir, infile ) ), "\n" ) do
        if matchstart( line, "MBT(" ) then
          spl:= SplitString( line, "\"" );
          if not [ spl[2], ReplacedString( infile, "ctb", "cto" ) ]
                 in firstnames then
            Print( "for ", spl[2], ", a modular table is in ", infile, "\n" );
          fi;
        fi;
      od;
    od;

    # Print the list of file positions.
    app( "LIBLIST.files := [\n" );
    line:= " ";
    for i in [ 2 .. Length( filecounts ) ] do
      line:= amend( line, " ", filecounts[i], ",", " " );
    od;
    app( line,
         " ];\nLIBLIST.filenames := ",
         "Concatenation( List( [ 1 .. Length( LIBLIST.files ) ],\n",
         "    i -> ListWithIdenticalEntries( LIBLIST.files[i], i ) ) );\n",
         "MakeImmutable( LIBLIST.filenames );\n\n" );

    # Print the list of file names.
    app( "LIBLIST.files := [\n" );
    line:= " ";
    for infile in List( ordinfiles, x -> x{ [ 1 .. Length( x ) - 4 ] } ) do
      line:= amend( line, " \"", infile, "\",", " " );
    od;
    app( line, " ];\nMakeImmutable( LIBLIST.files );\n\n" );

    # Check whether the names that occur in fusions are valid.
    firstnames:= List( firstnames, x -> x[1] );
    for pair in fusions do
      if not pair[1] in firstnames then
        Print( "fusion source '", pair[1], "' not valid first name\n" );
      fi;
      if not pair[2] in firstnames then
        Print( "fusion destination '", pair[2], "' not valid first name\n" );
      fi;
    od;

    # Print the list of fusion sources.
    app( "LIBLIST.fusionsource := [\n" );
    for nam in firstnames do
      app( "  [ # fusions to ", nam, "\n" );
      line:= " ";
      for entry in Filtered( fusions, pair -> pair[2] = nam ) do
        line:= amend( line, " \"", entry[1], "\",", " " );
      od;
      app( line, " ],\n" );
    od;
    app( "  ];\nMakeImmutable( LIBLIST.fusionsource );\n\n" );

    # Print the list of admissible names.
    Sort( allnames );
    app( "LIBLIST.names := [\n" );
    for pair in allnames do
      if not pair[1] in firstnames then
        Print( "no table \"", pair[1], "\"\n" );
      else
        line:= Concatenation( " [\"", pair[1], "\"" );
        for nam in pair[2] do
          if Length( line ) + Length( nam ) + 3 <= 77 then
            Append( line, Concatenation( ",\"", nam, "\"" ) );
          else
            app( line, ",\n" );
            line:= Concatenation( "  \"", nam, "\"" );
          fi;
        od;
        line:= amend( line, "", "],", "", "  " );
        app( line, "\n" );
      fi;
    od;
    app( "];\n\n" );

    # Construct the components 'LIBLIST.allnames', 'LIBLIST.position'.
    app( "LIBLIST.allnames:= [];\n",
         "LIBLIST.position:= [];\n",
         "LIBLIST.makenames:= function()\n",
         "local entry;\n",
         "for entry in LIBLIST.names do\n",
         "  LIBLIST.pos:= Position( LIBLIST.firstnames, entry[1] );\n",
         "  Append( LIBLIST.allnames,\n",
         "          entry{ [2..Length(entry)] } );\n",
         "  Append( LIBLIST.position,\n",
         "          List( [2..Length(entry)], x -> LIBLIST.pos ) );\n",
         "od;\n",
         "Unbind( LIBLIST.names );\n",
         "Unbind( LIBLIST.pos );\n",
         "Unbind( LIBLIST.makenames );\n",
         "for entry in LIBLIST.allnames do MakeImmutable( entry ); od;\n",
         "end;\n",
         "LIBLIST.makenames();\n\n" );

    # They shall be sorted according to the ordering of GAP,
    # so we leave the sorting to GAP.
    app( "SortParallel( LIBLIST.allnames, LIBLIST.position );\n\n" );
#T We could store the sorted result lists directly,
#T this would speed up the loading process.
#T Disadvantages would be that the differences between versions of the
#T file `ctprimar.tbl' would be large also in the case of small changes
#T of the contents, and that we would not have a list of all names for a
#T given table in the file.

    # Print the map to the identifiers of tables of marks.
    app( "BindGlobal( \"TOM_TBL_INFO\", [ [], [] ] );\n",
         "if TestPackageAvailability(\"tomlib\",\"1.0\") <> fail then\n" );
#T Call `IsPackageMarkedForLoading' instead!
    for i in [ 1, 2 ] do
      app( "  TOM_TBL_INFO[", String( i ), "]:= [\n" );
      line:= "  ";
      for pair in tbltom do
        line:= amend( line, "\"", LowercaseString( pair[i] ), "\",", "  " );
      od;
      app( line, " ];\n" );
    od;
    app( "  MakeImmutable( TOM_TBL_INFO );\nfi;\n\n" );

    # Deal with projections.
    app( "LIBLIST.projections := [\n" );
    for entry in fusions do
      if entry{ [ 2, 1 ] } in projectivesinfo then
        line:= Concatenation( "  [\"", entry[1], "\",\"", entry[2], "\",[" );
        for i in ProjectionMap( EvalString( entry[3] ) ) do
          line:= amend( line, "", String( i ), ",", "  " );
        od;
        line:= amend( line, "", "]],", "", "  " );
        app( line, "\n" );
      fi;
    od;
    app( "  ];\nMakeImmutable( LIBLIST.projections );\n\n" );

    # Store info about the tables of simple groups, their Schur multipliers
    # and outer automorphism groups.
    app( "LIBLIST.simpleInfo := [\n" );
    for entry in extinfo do
      if entry[2] in simplenames then
        app( "  [ \"", entry[1], "\", \"", entry[2], "\", \"", entry[3],
             "\" ],\n" );
      else
        Print( "extInfo for nonsimple table ", entry[2], "?\n" );
      fi;
    od;
    app( "  ];\nMakeImmutable( LIBLIST.simpleInfo );\n\n\n" );

    # Add the info about sporadic simple groups.
    app( "LIBLIST.sporadicSimple := [\n",
    "  \"M11\", \"M12\", \"J1\", \"M22\", \"J2\", \"M23\", \"HS\", \"J3\",\n",
    "  \"M24\", \"McL\", \"He\", \"Ru\", \"Suz\", \"ON\", \"Co3\", \"Co2\",\n",
    "  \"Fi22\", \"HN\", \"Ly\", \"Th\", \"Fi23\", \"Co1\", \"J4\", \"F3+\",\n",
    "  \"B\", \"M\" ];\n",
    "MakeImmutable( LIBLIST.sporadicSimple );\n\n" );

    # Add the info about generic tables.
    app( "LIBLIST.GENERIC := [\n" );
    for line in Filtered( SplitString(
        StringFile( Filename( dir, "ctgeneri.tbl" ) ), "\n" ),
            x -> matchstart( x, "LIBTABLE" ) and match( x, "(\"" ) ) do
      app( "  \"", SplitString( line, "\"" )[2], "\",\n" );
    od;
    app( "  ];\n\n", "LIBLIST.GENERIC:= rec(\n",
         "   allnames:= List( LIBLIST.GENERIC, LowercaseString ),\n",
         "   firstnames:= LIBLIST.GENERIC );\n\n" );

    # Compare the file with the current contents.
    oldcontents:= StringFile( outfile );
    pos:= PositionSublist( oldcontents, "LIBLIST.lastupdated:= \"" );
    if pos <> fail and outstr = oldcontents{ [ 1 .. pos-1 ] } then
      Print( "no update of ctprimar.tbl is necessary\n" );
    else
      # Add a timestamp.
      app( "LIBLIST.lastupdated:= \"",
           CTblLibCurrentDateTimeString( [ "-u", "+%d-%b-%Y, %T UTC" ] ),
           "\";\n\n" );

      # Add the info about the end of the file ...
      app( RepeatedString( '#', 77 ), "\n##\n#E\n\n" );

      # Save the old file.
      Exec( "mv", outfile, bakfile );

      # Create the new file (without trailing backslashes).
      FileString( outfile, outstr );

      # Print the differences between old and new version.
      diff:= Filename( DirectoriesSystemPrograms(), "diff" );
      str:= "";
      out:= OutputTextString( str, true );
      Process( DirectoryCurrent(), diff, InputTextNone(), out,
               [ bakfile, outfile ] );
      CloseStream( out );
      Print( str );
    fi;

    # Call GAP without library functions, and check that the table files
    # 'clm*', 'ctb*', and 'cto*' can be read and do contain only admissible
    # function calls.
    # In the list given below, 'Concatenation' and 'TransposedMat' are
    # the only library functions that are not defined in the 'ctadmin' file.
    outstr:= "";
    app( "LIBTABLE:=\n",
         "rec( LOADSTATUS:= rec(), clmelab:= [], clmexsp:= [] );;\n",
         "Ignore:= function( arg ) return arg; end;;\n",
         "SET_TABLEFILENAME:= Ignore;;\n",
         "GALOIS:= ( x -> x );;\n",
         "TENSOR:= ( x -> x );;\n",
         "EvalChars:= Ignore;;\n",
         "ALF:= function( arg ); end;;\n",
         "ACM:= function( arg ); end;;\n",
         "ARC:= function( arg ); end;;\n",
         "NotifyNameOfCharacterTable:= function( arg ); end;;\n",
         "ALN:= function( arg ); end;;\n",
         "MBT:= function( arg ); end;;\n",
         "MOT:= function( arg ); end;;\n",
         "Concatenation:= function( arg ) return 0; end;;\n",
         "TransposedMat:= function( arg ) return 0; end;;\n",
         "if not IsBound( Revision ) then Revision:= rec(); fi;\n" );
    for infile in Concatenation( clminfiles, ordinfiles, modinfiles ) do
      app( "READ(\"", Filename( dir, infile ), "\");\n" );
    od;
    FileString( "maketbl.checkin", outstr );
    Exec( "~sam/gap/3.5/bin/gap-ibm-i386-linux-gcc2 -b -l ~ ",
          "< maketbl.checkin > maketbl.checkout" );
    Exec( "sed -e '1d;/^gap> true$/d;/^gap> $/d' < maketbl.checkout" );
    RemoveFile( "maketbl.checkin" );
    RemoveFile( "maketbl.checkout" );

    # Load the updated table of contents.
    RereadPackage( "ctbllib", "data/ctprimar.tbl" );
    for nam in RecNames( LIBTABLE.LOADSTATUS ) do
      Unbind( LIBTABLE.LOADSTATUS.( nam ) );
    od;
end;


#############################################################################
##
#E

