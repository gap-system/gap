#############################################################################
##
#W  test.gi              GAP 4 package AtlasRep                 Thomas Breuer
##
#H  @(#)$Id: test.gi,v 1.84 2009/01/21 16:20:45 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains functions to test the data available in the
##  &ATLAS; of Group Representations.
##
Revision.( "atlasrep/gap/test_gi" ) :=
    "@(#)$Id: test.gi,v 1.84 2009/01/21 16:20:45 gap Exp $";


#############################################################################
##
#V  AtlasRepHardCases
##
InstallValue( AtlasRepHardCases, rec() );


#############################################################################
##
#V  AtlasRepHardCases.MaxNumberMaxes
#V  AtlasRepHardCases.MaxNumberStd
#V  AtlasRepHardCases.MaxTestDegree
##
##  In the test loops, we assume upper bounds on the numbers of available
##  maximal subgroups and standardizations,
##  and we perform some tests only if a sufficiently small permutation
##  representation is available.
##
AtlasRepHardCases.MaxNumberMaxes:= 50;
AtlasRepHardCases.MaxNumberStd:= 2;
AtlasRepHardCases.MaxTestDegree:= 10^5;


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestWords( [<tocid>[, <groupname>]][,]
#F                                        [<verbose>] )
##
AtlasRepHardCases.TestWords:= [
    [ "find", [ "B", "HN", "S417", "F24d2" ] ],
    [ "check", [ "B" ] ],
    [ "maxes", [ "Co1" ] ],
  ];

InstallGlobalFunction( AtlasOfGroupRepresentationsTestWords,
    function( arg )
    local result, maxdeg, tocid, verbose, types, toc, name, r, type, omit,
          entry, prg, gens, grp, size;

    # Initialize the result.
    result:= true;

    maxdeg:= AtlasRepHardCases.MaxTestDegree;

    if Length( arg ) = 0 then
      return AtlasOfGroupRepresentationsTestWords( "local", false );
    elif Length( arg ) = 1 and IsBool( arg[1] ) then
      return AtlasOfGroupRepresentationsTestWords( "local", arg[1] );
    elif Length( arg ) = 1 and IsString( arg[1] ) then
      return AtlasOfGroupRepresentationsTestWords( arg[1], false );
    elif Length( arg ) = 2 and IsString( arg[1] ) and IsString( arg[2] ) then
      return AtlasOfGroupRepresentationsTestWords( arg[1], arg[2], false );
    elif Length( arg ) = 2 and IsString( arg[1] ) and IsBool( arg[2] ) then
      for name in AtlasOfGroupRepresentationsInfo.groupnames do
        result:= AtlasOfGroupRepresentationsTestWords( arg[1],
                     name[3], arg[2] ) and result;
      od;
      return result;
    elif not ( Length( arg ) = 3 and IsString( arg[1] )
                                 and IsString( arg[2] )
                                 and IsBool( arg[3] ) ) then
      Error( "usage: AtlasOfGroupRepresentationsTestWords( [<tocid>[, ",
             "<groupname>]][,]\n[<verbose>] )" );
    fi;

    tocid:= arg[1];
    verbose:= arg[3];

    # Check only straight line programs.
    types:= AGRDataTypes( "prg" );

    toc:= AtlasTableOfContents( tocid );
    if toc = fail then
      # No test is reasonable.
      return true;
    fi;

    name:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                  x -> x[2] = arg[2] );
    if IsBound( toc.TableOfContents.( name[2] ) ) then
      r:= toc.TableOfContents.( name[2] );

      # Note that the ordering in the `and' statement must not be
      # changed, in order to execute all tests!
      for type in types do
        omit:= First( AtlasRepHardCases.TestWords,
                      pair -> pair[1] = type[1] );
        if IsBound( r.( type[1] ) ) then
          if IsList( omit ) and name[2] in omit[2] then
            if verbose then
              Print( "#I  omit TestWords for ", type[1], " and ", name[2],
                     "\n" );
            fi;
          else
            for entry in r.( type[1] ) do
              result:= type[2].TestWords( tocid, name[2],
                           entry[ Length( entry ) ], type, verbose )
                       and result;
            od;
          fi;
        fi;
      od;

      # Check also the `maxext' scripts (which do not form a data type
      # and which are stored in the remote table of contents only).
      r:= AtlasTableOfContents( "remote" ).TableOfContents.( name[2] );
      if IsBound( r.maxext ) then
        for entry in r.maxext do
          prg:= AtlasProgram( name[1], entry[1], "maxes", entry[2] );
          if prg = fail then
            if verbose then
              Print( "#I  omit TestWords for maxext no. ", entry[2], " and ",
                     name[2], "\n" );
            fi;
          elif not IsInternallyConsistent( prg.program )  then
            Print( "#E  program `", entry[3],
                   "' not internally consistent\n" );
            result:= false;
          else
            # Get a representation if available, and map the generators.
            gens:= OneAtlasGeneratingSetInfo( prg.groupname,
                       prg.standardization, NrMovedPoints, [ 2 .. maxdeg ] );
            if gens = fail then
              if verbose then
                Print( "#I  no perm. repres. for `", prg.groupname,
                       "', no check for `", entry[3], "'\n" );
              fi;
            else
              gens:= AtlasGenerators( gens );
              grp:= Group( gens.generators );
              if IsBound( gens.size ) then
                SetSize( grp, gens.size );
              fi;
              gens:= ResultOfStraightLineProgram( prg.program,
                         gens.generators );
              size:= Size( SubgroupNC( grp, gens ) );
              if IsBound( prg.size ) and size <> prg.size then
                Print( "#E  program `", entry[3], "' for group of order ",
                       size, " not ", prg.size, "\n" );
                result:= false;
              fi;
            fi;
          fi;
        od;
      fi;

    fi;

    # Return the result.
    return result;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestFileHeaders( [<tocid>[,<groupname>]] )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsTestFileHeaders,
    function( arg )
    local result, toc, record, type, entry, test, triple;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 2 then

      toc:= AtlasTableOfContents( arg[1] );
      if toc = fail then
        # No test is reasonable.
        return true;
      fi;
      toc:= toc.TableOfContents;
      if IsBound( toc.( arg[2] ) ) then
        record:= toc.( arg[2] );
        for type in AGRDataTypes( "rep" ) do
          if IsBound( record.( type[1] ) ) then
            for entry in record.( type[1] ) do
              test:= type[2].TestFileHeaders( arg[1], arg[2], entry, type );
              if not IsBool( test ) then
                Print( "#E  ", test, " for ", entry[ Length( entry ) ],
                       "\n" );
                test:= false;
              fi;
              result:= test and result;
            od;
          fi;
        od;
      fi;

    elif Length( arg ) = 1 then

      for triple in AtlasOfGroupRepresentationsInfo.groupnames do
        result:= AtlasOfGroupRepresentationsTestFileHeaders( arg[1],
                     triple[3] ) and result;
      od;

    elif Length( arg ) = 0 then
      result:= AtlasOfGroupRepresentationsTestFileHeaders( "local" );
    fi;

    # Return the result.
    return result;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestBinaryFormat()
##  
InstallGlobalFunction( AtlasOfGroupRepresentationsTestBinaryFormat,
    function()
    local tmpfile, formats, dir, result, filename, unpacked, mat, test;

    # Create one temporary file.
    tmpfile:= TmpName();

    # Get the filename format.
    formats:= Filtered(
        AtlasOfGroupRepresentationsInfo.TableOfContents.types.rep,
            x -> x[1] in [ "matff", "perm" ] );
    formats:= List( formats, format -> format[2].FilenameFormat );

    # Loop over the files in directory `dirname' that contain matrices.
    dir:= DirectoriesPackageLibrary( "atlasrep", "datagens" )[1];
    result:= true;
    for filename in DirectoryContents( Filename( dir, "" ) ) do
      unpacked:= filename;
      if Length( filename ) > 3 and filename{ [ Length( filename ) - 2
                                      .. Length( filename ) ] } = ".gz" then
        unpacked:= filename{ [ 1 .. Length( filename ) - 3 ] };
      fi;
      if ForAny( formats, format -> AGRParseFilenameFormat( unpacked,
                                        format ) <> fail ) then
        mat:= ScanMeatAxeFile( Filename( dir, unpacked ) );
        if mat = fail then
          Print( "#E  AtlasOfGroupRepresentationsTestBinaryFormat:\n",
                 "#E  corrupted file `", filename, "'\n" );
          result:= false;
        else
          test:= false;
          if IsList( mat ) and Length( mat ) = 1 and IsPerm( mat[1] ) then
            mat:= mat[1];
            CMtxBinaryFFMatOrPerm( mat, LargestMovedPoint( mat ), tmpfile );
            test:= true;
          elif IsMatrix( mat ) then
            if IsInt( ConvertToMatrixRep( mat ) ) then
              CMtxBinaryFFMatOrPerm( mat, ConvertToMatrixRep( mat ), tmpfile );
              test:= true;
            fi;
          else
            Print( "#E  not permutation or matrix in ", filename, "\n" );
            result:= false;
          fi;
          if test and mat <> FFMatOrPermCMtxBinary( tmpfile ) then
            Print( "#E  AtlasOfGroupRepresentationsTestBinaryFormat:\n",
                   "#E  differences for `", unpacked, "'\n" );
            result:= false;
          fi;
        fi;
      fi;
    od;

    # Remove the temporary file.
    RemoveFile( tmpfile );

    # Return the result.
    return result;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestStandardization( [<gapname>] )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsTestStandardization,
    function( arg )
    local result, name, gapname, groupname, toc, orders, nr, gens, std, ords;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 0 then

      for name in AtlasOfGroupRepresentationsInfo.GAPnames do
        result:= AtlasOfGroupRepresentationsTestStandardization( name[1] )
                     and result;
      od;

    elif Length( arg ) = 1 and IsString( arg[1] ) then

      gapname:= arg[1];
      groupname:= AGR_InfoForName( gapname );
      if groupname = fail then
        Print( "#E  AtlasOfGroupRepresentationsTestStandardization:\n",
               "#E  no group with GAP name `", gapname, "'\n" );
        return false;
      fi;

      toc:= AtlasTableOfContents( "local" ).TableOfContents;

      orders:= [];

      # Loop over the relevant representations.
      nr:= 1;
      gens:= AtlasGenerators( gapname, nr );
      while gens <> fail do
        std:= gens.standardization;
        if ForAll( gens.generators, x -> Inverse( x ) <> fail ) then
          ords:= List( gens.generators, Order );
        else
          ords:= [ fail ];
        fi;
        if not ForAll( ords, IsInt ) then
          Print( "#E  representation `", gens.identifier,
                 "': non-finite order\n" );
          result:= false;
        elif IsBound( orders[ std ] ) then
          if orders[ std ] <> ords then
            Print( "#E  ", Ordinal( nr ), " representation of `", gapname,
                   "': incompatible orders ", ords, " and ", orders[ std ],
                   "\n" );
            result:= false;
          fi;
        else
          orders[ std ]:= ords;
        fi;
        nr:= nr + 1;
        gens:= AtlasGenerators( gapname, nr );
      od;

    fi;

    # Return the result.
    return result;
end );


#############################################################################
##
##  If the IO package is not installed then an error message is avoided
##  via the following assignment.
##
if not IsBound( IO_stat ) then
  IO_stat:= "dummy";
fi;


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestTableOfContentsRemoteUpdates()
##
InstallGlobalFunction(
    AtlasOfGroupRepresentationsTestTableOfContentsRemoteUpdates, function()
    local version, inforec, home, server, path, dstfilename, result, lines,
          datadirs, line, pos, pos2, filename, localfile, servdate, stat;

    if LoadPackage( "io" ) <> true then
      Print( "#E  The package IO is not available.\n" );
      return fail;
    fi;

    # Download the file that lists the changes.
    version:= InstalledPackageVersion( "atlasrep" );
    inforec:= First( PackageInfo( "atlasrep" ), r -> r.Version = version );
    home:= inforec.PackageWWWHome;
    if home{ [ 1 .. 7 ] } = "http://" then
      home:= home{ [ 8 .. Length( home ) ] };
    fi;

    server:= home{ [ 1 .. Position( home, '/' ) - 1 ] };
    path:= home{ [ Position( home, '/' ) + 1 .. Length( home ) ] };
    dstfilename:= Filename( DirectoryTemporary(), "changes.htm" );

    result:= [];
    if AtlasOfGroupRepresentationsTransferFile( server,
               Concatenation( path, "/htm/data/changes.htm" ),
               dstfilename ) then
      lines:= SplitString( StringFile( dstfilename ), "\n" );
      lines:= Filtered( lines,
                  x ->     20 < Length( x ) and x{ [ 1 .. 4 ] } = "<tr>"
                       and x{ [ -3 .. 0 ] + Length( x ) } = " -->" );
      datadirs:= Concatenation(
                     DirectoriesPackageLibrary( "atlasrep", "datagens" ),
                     DirectoriesPackageLibrary( "atlasrep", "dataword" ) );
      for line in lines do
        pos:= PositionSublist( line, "</td><td>" );
        if pos <> fail then
          pos2:= PositionSublist( line, "</td><td>", pos );
          filename:= line{ [ pos+9 .. pos2-1 ] };
          localfile:= Filename( datadirs, filename );
          if localfile <> fail then
            if not IsExistingFile( localfile ) then
              localfile:= Concatenation( localfile, ".gz" );
            fi;
            if IsExistingFile( localfile ) then
              # There is something to compare.
              pos:= PositionSublist( line, "<!-- " );
              if pos <> fail then
                servdate:= Int( line{ [ pos+5 .. Length( line )-4 ] } );
                stat:= IO_stat( localfile );
                if stat <> fail then
                  if stat.mtime < servdate then
                    Add( result, localfile );
                  fi;
                fi;
              fi;
            fi;
          fi;
        fi;
      od;
    fi;
    return result;
end );

if IsString( IO_stat ) then
  Unbind( IO_stat );
fi;


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestFiles( [<tocid>[, <groupname>]] )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsTestFiles, function( arg )
    local result, toc, record, type, entry, triple;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 2 then
      toc:= AtlasTableOfContents( arg[1] );
      if toc = fail then
        return false;
      fi;
      toc:= toc.TableOfContents;
      if IsBound( toc.( arg[2] ) ) then
        record:= toc.( arg[2] );
        for type in AGRDataTypes( "rep" ) do
          if IsBound( record.( type[1] ) ) then
            for entry in record.( type[1] ) do
              result:= type[2].TestFiles( arg[1], arg[2], entry, type )
                       and result;
            od;
          fi;
        od;
      fi;
    elif Length( arg ) = 1 then
      for triple in AtlasOfGroupRepresentationsInfo.groupnames do
        result:= AtlasOfGroupRepresentationsTestFiles( arg[1], triple[3] )
                 and result;
      od;
    elif IsEmpty( arg ) then
      result:= AtlasOfGroupRepresentationsTestFiles( "local" ) and result;
    fi;

    # Return the result.
    return result;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestClassScripts()
#F  AtlasOfGroupRepresentationsTestClassScripts( <groupname> )
##
##  The following groups are (currently) too large for checking
##  centralizer orders in a concrete representation.
#T  Replace this by the check for a suff. small permutation representation?
##
AtlasRepHardCases.TestClassScripts:= [
    "B", "F24", "HN", "J4", "Ly", "M", "ON", "Th", "L37d2",
  ];

InstallGlobalFunction( AtlasOfGroupRepresentationsTestClassScripts,
    function( arg )
    local result, groupname, gapname, toc, record, std, name, prg, tbl,
          outputs, ident, classnames, map, gens, roots, grp, reps, orders1,
          orders2, cents1, cents2, triple, pos, pos2, cycscript;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 1 and IsString( arg[1] ) then

      groupname:= arg[1];
      gapname:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                       pair -> pair[2] = groupname );
      if gapname = fail then
        Print( "#E  no group with name `", groupname, "'\n" );
        return false;
      fi;
      gapname:= gapname[1];
      toc:= AtlasTableOfContents( "local" );
      if toc = fail then
        return false;
      fi;
      toc:= toc.TableOfContents;
#T admit also private tables of contents!
      if IsBound( toc.( groupname ) ) then
        record:= toc.( groupname );
        for name in [ "cyclic", "classes", "cyc2ccl" ] do
          if IsBound( record.( name ) ) then
            for std in Set( List( record.( name ), x -> x[1] ) ) do

              prg:= AtlasProgram( gapname, std, name );
              if prg = fail then
                Print( "#E  inconsistent program `", name, "' for `",
                       gapname, "'\n" );
                result:= false;
              else

                # Fetch the character table of the group.
                # (No further tests are possible if it is not available.)
                tbl:= CharacterTable( gapname );
                if tbl <> fail then

                  ident:= prg.identifier[2];
                  classnames:= AtlasClassNames( tbl );
                  if IsBound( prg.outputs ) then
                    outputs:= prg.outputs;
                    map:= List( outputs, x -> Position( classnames, x ) );
                  else
                    Print( "#E  no component `outputs' in `", name,
                           "' for `", gapname, "'\n" );
                    result:= false;
                    outputs:= [ "-" ];
                    map:= [ fail ];
                  fi;
                  prg:= prg.program;

                  # (If `-' signs occur then we cannot test the names,
                  # but the number of outputs can be checked.)
                  roots:= ClassRoots( tbl );
                  roots:= Filtered( [ 1 .. Length( roots ) ],
                                    i -> IsEmpty( roots[i] ) );
                  roots:= Set( List( roots, x -> ClassOrbit( tbl, x ) ) );

                  if ForAll( outputs, x -> not '-' in x ) then

                    # Check the class names.
                    if fail in map then
                      Print( "#E  strange class names ",
                             Difference( outputs, classnames ),
                             " for `dataword/", ident, "'\n" );
                      result:= false;
                    fi;
                    if     name in [ "classes", "cyc2ccl" ]
                       and Set( classnames ) <> Set( outputs ) then
                      Print( "#E  class names ",
                             Difference( classnames, outputs ),
                             " not hit for `dataword/", ident, "'\n" );
                      result:= false;
                    fi;
                    if name = "cyclic" then
                      # Check whether all maximally cyclic subgroups
                      # are covered.
                      roots:= Filtered( roots,
                                 list -> IsEmpty( Intersection( outputs,
                                             classnames{ list } ) ) );
                      if not IsEmpty( roots ) then
                        Print( "#E  maximally cyclic subgroups ",
                               List( roots, x -> classnames{ x } ),
                               " not hit for `dataword/", ident, "'\n" );
                        result:= false;
                      fi;
                    fi;

                  elif name = "cyclic" and
                       Length( outputs ) <> Length( roots ) then
                    Print( "#E  no. of outputs and cyclic subgroups differ",
                           " for `dataword/", ident, "'\n" );
                  fi;

                  if not ( fail in map or
                       groupname in AtlasRepHardCases.TestClassScripts ) then

                    # Compute the representatives in a representation.
                    # (No further tests are possible if none is available.)
                    gens:= OneAtlasGeneratingSetInfo( gapname, std,
                                                      IsPermGroup, true );
                    if gens <> fail then

                      gens:= AtlasGenerators( gens.identifier );
                      if gens <> fail then
                        gens:= gens.generators;
                      fi;
                      if fail in gens then
                        gens:= fail;
                      fi;

                      if not name in [ "cyclic", "classes" ] then

                        # The input consists of the images of the standard
                        # generators under the `cyc' script.
                        pos:= Position( ident, '-' ) - 1;
                        pos2:= pos;
                        while ident[ pos2 ] <> 'W' do
                          pos2:= pos2 - 1;
                        od;
                        cycscript:= Concatenation( groupname, "G",
                                        String( std ), "-cycW",
                                        ident{ [ pos2+1 .. pos ] } );
                        cycscript:= AtlasProgram(
                            [ gapname, cycscript, std ] );
                        if cycscript = fail then
                          gens:= fail;
                          Print( "#E  no script `", cycscript,
                                 "' available\n" );
                          result:= false;
                        else
                          gens:= ResultOfStraightLineProgram(
                                     cycscript.program, gens );
                        fi;
                      fi;

                    fi;

                    if gens <> fail then

                      grp:= Group( gens );
                      reps:= ResultOfStraightLineProgram( prg, gens );

                      if Length( reps ) <> Length( outputs ) then

                        Print( "#E  inconsistent output numbers for ",
                               "`dataword/", ident, "'\n" );
                        result:= false;

                      else

                        # Check element orders and centralizer orders.
                        orders1:= OrdersClassRepresentatives( tbl ){ map };
                        orders2:= List( reps, Order );
                        if orders1 <> orders2 then
                          Print( "#E  element orders of ",
                              outputs{ Filtered( [ 1 .. Length( outputs ) ],
                                           i -> orders1[i] <> orders2[i] ) },
                              " differ for `dataword/", ident, "'\n" );
                          result:= false;
                        fi;
                        cents1:= SizesCentralizers( tbl ){ map };
                        cents2:= List( reps, x -> Size( Centralizer(grp,x) ) );
                        if    cents1 <> cents2 then
                          Print( "#E  centralizer orders of ",
                              outputs{ Filtered( [ 1 .. Length( outputs ) ],
                                           i -> cents1[i] <> cents2[i] ) },
                              " differ for `dataword/", ident, "'\n" );
                          result:= false;
                        fi;

                      fi;

                    fi;

                  fi;

                fi;
              fi;

            od;
          fi;
        od;
      fi;

    elif IsEmpty( arg ) then
      for triple in AtlasOfGroupRepresentationsInfo.groupnames do
        result:= AtlasOfGroupRepresentationsTestClassScripts( triple[3] )
                 and result;
      od;
    fi;

    # Return the result.
    return result;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestCycToCcls( [<groupname>] )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsTestCycToCcls,
    function( arg )
    local result, groupname, gapname, toc, tbl, record, datadirs, entry,
          tomatch, cyc2ccl, str, prg, triple;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 1 and IsString( arg[1] ) then

      groupname:= arg[1];
      gapname:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                       pair -> pair[2] = groupname );
      if gapname = fail then
        Print( "#E  no group with name `", groupname, "'\n" );
        return false;
      fi;
      gapname:= gapname[1];
      toc:= AtlasTableOfContents( "local" );
      if toc = fail then
        return false;
      fi;
      toc:= toc.TableOfContents;

      # Fetch the character table of the group.
      # (No test is possible if it is not available.)
      tbl:= CharacterTable( gapname );
      if   tbl = fail then
        Print( "#I  no character table of `", gapname, "' is available\n" );
        return true;
      elif not IsBound( toc.( groupname ) ) then
        return true;
      fi;

      record:= toc.( groupname );
      if IsBound( record.cyclic ) then
        if IsBound( record.cyc2ccl ) then
          cyc2ccl:= List( record.cyc2ccl, x -> SplitString( x[2], "-" ) );
        else
          cyc2ccl:= [];
        fi;

        datadirs:= DirectoriesPackageLibrary( "atlasrep", "dataword" );

        for entry in record.cyclic do

          # Check the `cyc2ccl' scripts available.
          tomatch:= Filtered( entry[2], x -> x <> '-' );
          cyc2ccl:= Filtered( cyc2ccl, x -> x[1] = tomatch );
          if IsEmpty( cyc2ccl ) then

            # There is no `cyc2ccl' script but perhaps we can create it.
            str:= StringOfAtlasProgramCycToCcls(
                      Filename( datadirs, entry[2] ), tbl, "names" );
            if str <> fail then
              prg:= ScanStraightLineProgram( str, "string" );
              if prg = fail then
                Print( "#E  automatically created script for `", tomatch,
                       "-cclsW1' would be incorrect" );
              fi;
              prg:= prg.program;
#T check the composition?
              Print( "#I  add the following script, in the new file `",
                     tomatch, "-cclsW1':\n",
                     str, "\n" );
              result:= false;
            fi;

          fi;
        od;
      fi;

    elif IsEmpty( arg ) then
      for triple in AtlasOfGroupRepresentationsInfo.groupnames do
        result:= AtlasOfGroupRepresentationsTestCycToCcls( triple[3] )
                 and result;
      od;
    fi;

    # Return the result.
    return result;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestGroupOrders( [true] )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsTestGroupOrders,
    function( arg )
    local verbose, formats, maxdeg, SizesFromName, result, entry, size;

    verbose:= ( Length( arg ) <>  0 and arg[1] = true );

    formats:= [
      [ [ "L", IsDigitChar, "(", IsDigitChar, ")" ],
        l -> Size( PSL( l[2], l[4] ) ) ],
      [ [ "2.L", IsDigitChar, "(", IsDigitChar, ")" ],
        l -> 2 * Size( PSL( l[2], l[4] ) ) ],
      [ [ "S", IsDigitChar, "(", IsDigitChar, ")" ],
        l -> Size( PSp( l[2], l[4] ) ) ],
      [ [ "2.S", IsDigitChar, "(", IsDigitChar, ")" ],
        l -> 2 * Size( PSp( l[2], l[4] ) ) ],
      [ [ "U", IsDigitChar, "(", IsDigitChar, ")" ],
        l -> Size( PSU( l[2], l[4] ) ) ],
    ];

    maxdeg:= AtlasRepHardCases.MaxTestDegree;

    SizesFromName:= function( name )
      local result, pair, parse, tbl, tom, data, pos, size1, size2;

      result:= [];

      # Deal with the case of integers.
      if ForAll( name, x -> IsDigitChar( x ) or x = '^' ) then
#T improve: admit also brackets and '+' (problem of *matching* brackets)
        # No other criterion matches with this format, so we return.
        return [ EvalString( name ) ];
      fi;

      for pair in formats do
        parse:= ParseBackwards( name, pair[1] );
        if parse <> fail then
          AddSet( result, pair[2]( parse ) );
        fi;
      od;

      # Try to use the character table information.
      tbl:= CharacterTable( name );
      if tbl <> fail then
        AddSet( result, Size( tbl ) );
      fi;

      # Try to use the table of marks information.
      tom:= TableOfMarks( name );
      if tom <> fail then
        AddSet( result, Size( UnderlyingGroup( tom ) ) );
      fi;

      # Try to use the database.
      data:= OneAtlasGeneratingSetInfo( name,
                 NrMovedPoints, [ 1 .. maxdeg ] );
   #  if data = fail then
   #    data:= OneAtlasGeneratingSetInfo( name,
   #               Dimension, [ 1 .. 10 ] );
   #  fi;
      if data <> fail then
        data:= AtlasGenerators( data );
        if data <> fail then
          AddSet( result, Size( Group( data.generators ) ) );
        fi;
      fi;

      # Try to evaluate the name structure.
      pos:= Position( name, '.' );
#T improve: split also at ':'
      if pos <> fail then
        size1:= SizesFromName( name{ [ 1 .. pos-1 ] } );
        size2:= SizesFromName( name{ [ pos+1 .. Length( name ) ] } );
        if Length( size1 ) = 1 and Length( size2 ) = 1 then
          AddSet( result, size1[1] * size2[1] );
        elif Length( size1 ) > 1 or Length( size2 ) > 1 then
          Print( "#E  group orders: problem with `", name, "'\n" );
        fi;
      fi;

      return result;
    end;

    result:= true;

    for entry in AtlasOfGroupRepresentationsInfo.GAPnames do
      size:= SizesFromName( entry[1] );
      if 1 < Length( size ) then
        Print( "#E  AGRGNAN: several group orders for `", entry[1],
               "':\n#E  ", size, "\n" );
        result:= false;
      elif not IsBound( entry[3] ) then
        if Length( size ) = 0 then
          if verbose then
            Print( "#I  AGRGNAN: group order for `", entry[1],
                   "' unknown\n" );
          fi;
        else
          entry[3]:= size[1];
          Print( "#I  AGRGNAN: set group order `", size[1], "' for `",
                 entry[1], "'\n" );
        fi;
      elif Length( size ) = 0 then
        if verbose then
          Print( "#I  AGRGNAN: cannot verify group order for `", entry[1],
                 "'\n" );
        fi;
      elif size[1] <> entry[3] then
        Print( "#E  AGRGNAN: wrong group order for `", entry[1], "'\n" );
        result:= false;
      fi;
    od;

    return result;
end );


#############################################################################
##
#F  IsKernelInFrattiniSubgroup( <tbl>, <factfus> )
##
##  We try to deduce the orders of maximal subgroups from those of factor
##  groups.
##  Namely, if <M>K</M> is a normal subgroup in <M>G</M> such that <M>K</M>
##  is contained in the Frattini subgroup <M>\Phi(G)</M> of <M>G</M>
##  (i. e., contained in any maximal subgroup of <M>G</M>)
##  then the maximal subgroups of <M>G</M> are exactly the preimages of the
##  maximal subgroups of <M>G/K</M> under the natural epimorphism.
##  <P/>
##  Since <M>G' \cap Z(G) \leq \Phi(G)</M>, this situation occurs in the case
##  of central extensions of perfect groups,
##  for example the orders of the maximal subgroups of <M>3.A_6</M> are
##  the orders of the maximal subgroups of <M>A_6</M>, multiplied by the
##  factor three.
##  <P/>
##  Since <M>\Phi(N) \leq \Phi(G)</M> holds for any normal subgroup <M>N</M>
##  of <M>G</M>
##  (see <Cite Key="Hup67" SubKey="Kap. III, §3, Hilfssatz 3.3 b)"/>),
##  this situation occurs in the case of upward extensions of central
##  extensions of perfect groups,
##  for example the orders of the maximal subgroups of <M>3.A_6.2_1</M> are
##  the orders of the maximal subgroups of <M>A_6.2_1</M>, multiplied by the
##  factor three.
##
BindGlobal( "IsKernelInFrattiniSubgroup", function( tbl, factfus )
    local ker, nam, subtbl, subfus, subker;

    # Compute the kernel <M>K</M> of the epimorphism.
    ker:= ClassPositionsOfKernel( factfus.map );
    if Length( ker ) = 1 or not
       IsSubset( ClassPositionsOfDerivedSubgroup( tbl ), ker ) then
      return false;
    elif IsSubset( ClassPositionsOfCentre( tbl ), ker ) then
      # We have <M>K \leq G' \cap Z(G)</M>,
      # so the maximal subgroups are exactly the preimages of the
      # maximal subgroups in the factor group.
      return true;
    fi;

    # Look for a suitable normal subgroup <M>N</M> of <M>G</M>.
    for nam in NamesOfFusionSources( tbl ) do
      subtbl:= CharacterTable( nam );
      subfus:= GetFusionMap( subtbl, tbl );
      if Size( subtbl ) = Sum( SizesConjugacyClasses( tbl ){
                                 Set( subfus ) } ) and
         IsSubset( subfus, ker ) then
        # <M>N</M> is normal in <M>G</M>, with <M>K \leq N</M>
        subker:= Filtered( [ 1 .. Length( subfus ) ],
                           i -> subfus[i] in ker );
        if IsSubset( ClassPositionsOfDerivedSubgroup( subtbl ),
                   subker ) and
             IsSubset( ClassPositionsOfCentre( subtbl ), subker ) then
          # We have <M>K \leq N' \cap Z(N)</M>.
          return true;
        fi;
      fi;
    od;

    return false;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestSubgroupOrders( [true] )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsTestSubgroupOrders,
    function( arg )
    local verbose, maxdeg, maxmax, MaxesSizesForName, result, toc, entry,
          info, size;

    verbose:= ( Length( arg ) <>  0 and arg[1] = true );
    maxdeg:= AtlasRepHardCases.MaxTestDegree;
    maxmax:= AtlasRepHardCases.MaxNumberMaxes;

    MaxesSizesForName:= function( name )
      local result, complete, tbl, oneresult, i, subtbl, tom, std, data, prg,
            gens, factfus, recurs, good;

      result:= [];
      complete:= false;

      # Try to use the character table information.
      tbl:= CharacterTable( name );
      if tbl <> fail then
        if HasMaxes( tbl ) then
          complete:= true;
          AddSet( result, List( Maxes( tbl ),
                                nam -> Size( CharacterTable( nam ) ) ) );
        else
          # Try whether individual names of maxes are supported.
          oneresult:= [];
          if tbl <> fail then
            for i in [ 1 .. maxmax ] do
              subtbl:= CharacterTable( Concatenation( Identifier( tbl ), "M",
                                                      String( i ) ) );
              if subtbl <> fail then
                oneresult[i]:= Size( subtbl );
              fi;
            od;
          fi;
          if not IsEmpty( oneresult ) then
            AddSet( result, oneresult );
          fi;
        fi;
      fi;

      # Try to use the table of marks information.
      tom:= TableOfMarks( name );
      if tom <> fail then
        complete:= true;
        AddSet( result, OrdersTom( tom ){ MaximalSubgroupsTom( tom )[1] } );
      fi;

      # Try to use the database.
      for std in [ 1 .. AtlasRepHardCases.MaxNumberStd ] do
        data:= OneAtlasGeneratingSetInfo( name, std,
                                          NrMovedPoints, [ 1 .. maxdeg ] );
     #  if data = fail then
     #    data:= OneAtlasGeneratingSetInfo( name, std,
     #               Dimension, [ 1 .. 10 ] );
     #  fi;
        if data <> fail then
          data:= AtlasGenerators( data );
          if data <> fail then
            oneresult:= [];
            for i in [ 1 .. maxmax ] do
              prg:= AtlasProgram( name, std, "maxes", i );
              if prg <> fail then
                gens:= ResultOfStraightLineProgram( prg.program,
                                                    data.generators );
                oneresult[i]:= Size( Group( gens ) );
              fi;
            od;
            if not IsEmpty( oneresult ) then
              AddSet( result, oneresult );
            fi;
          fi;
        fi;
      od;

      # Try to deduce the orders of maximal subgroups from those of factors.
      if tbl <> fail then
        for factfus in ComputedClassFusions( tbl ) do
          if IsKernelInFrattiniSubgroup( tbl, factfus ) then
            recurs:= MaxesSizesForName( factfus.name );
            if recurs.complete then
              complete:= true;
            fi;
            UniteSet( result,
              recurs.maxes * Sum( SizesConjugacyClasses( tbl ){
                  ClassPositionsOfKernel( factfus.map ) } ) );
          fi;
        od;
      fi;

      # Compact the partial results.
      good:= true;
      for oneresult in result{ [ 2 .. Length( result ) ] } do
        for i in [ 1 .. Length( oneresult ) ] do
          if   IsBound( result[1][i] ) then
            if IsBound( oneresult[i] ) then
              if result[1][i] <> oneresult[i] then
                good:= false;
              fi;
            fi;
          elif IsBound( oneresult[i] ) then
            result[1][i]:= oneresult[i];
          fi;
        od;
      od;
      if good and not IsEmpty( result ) then
        result:= [ result[1] ];
      fi;

      return rec( maxes:= result, complete:= complete );
    end;

    result:= true;
    toc:= AtlasOfGroupRepresentationsInfo.TableOfContents.remote;

    for entry in AtlasOfGroupRepresentationsInfo.GAPnames do
      info:= MaxesSizesForName( entry[1] );
      size:= info.maxes;
      if 1 < Length( size ) then
        Print( "#E  AGRGNAN: several maxes orders for `", entry[1],
               "':\n#E  ", size, "\n" );
        result:= false;
      elif not IsBound( entry[4] ) then
        # No maxes orders are stored yet.
        if Length( size ) = 0 then
          if verbose or ( IsBound( toc.( entry[2] ) ) and
                          IsBound( toc.( entry[2] ).maxes ) and
                          not IsEmpty( toc.( entry[2] ).maxes ) ) then
            Print( "#I  AGRGNAN: maxes orders for `", entry[1],
                   "' unknown\n" );
          fi;
        else
          if IsBound( entry[3] ) then
            if entry[3] in size[1] then
              Print( "#E  AGRGNAN: group order in computed maxes orders ",
                     "list for `", entry[1], "'\n" );
              result:= false;
            fi;
            if ForAny( size[1], x -> entry[3] mod x <> 0 ) then
              Print( "#E  AGRGNAN: strange subgroup order for `",
                     entry[1], "'\n" );
              result:= false;
            fi;
          fi;
          if IsSortedList( - Compacted( size[1] ) ) then
            entry[4]:= size[1];
            Print( "#I  AGRGNAN: set maxes orders `", size[1], "' for `",
                   entry[1], "'\n" );
          else
            Print( "#E  AGRGNAN: computed maxes orders for `",
                   entry[1], "' are not sorted:\n", size[1], "\n" );
          fi;
        fi;
      elif Length( size ) = 0 then
        if verbose then
          Print( "#I  AGRGNAN: cannot verify stored maxes orders for `",
                 entry[1], "'\n" );
        fi;
      elif not IsSortedList( - Compacted( size[1] ) ) then
        Print( "#E  AGRGNAN: computed maxes orders for `",
               entry[1], "' are not sorted:\n", size[1], "\n" );
      elif size[1] <> entry[4] then
        Print( "#E  AGRGNAN: computed and stored maxes orders for `",
               entry[1], "' differ:\n" );
        Print( "#E  ", size[1], " vs. ", entry[4], "\n" );
        result:= false;
      fi;
      if not IsBound( entry[5] ) or entry[5] <> "all" then
        if info.complete then
          entry[5]:= "all"; 
          Print( "#I  AGRGNAN: set maxes completeness info \"all\" for `",
                 entry[1], "'\n" );
        fi;
      elif entry[5] = "all" and not info.complete then
        if verbose then
          Print( "#I  AGRGNAN: cannot verify stored maxes completeness ",
                 "for `", entry[1], "'\n" );
        fi;
      fi;
    od;

    return result;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestStdCompatibility( [[<entry>, ]<verbose>] )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsTestStdCompatibility,
    function( arg )
    local verbose, maxstd, CompInfoForEntry, result, toc, entry, info, diff;

    verbose:= ( Length( arg ) <>  0 and arg[ Length( arg ) ] = true );
    maxstd:= AtlasRepHardCases.MaxNumberStd;

    CompInfoForEntry:= function( entry )
      local result, tbl, fus, factentry, factstd, pres, std, gens, prg, res,
            ker;

      result:= [];
      tbl:= CharacterTable( entry[1] );
      if tbl <> fail then
        for fus in ComputedClassFusions( tbl ) do
          if 1 < Length( ClassPositionsOfKernel( fus.map ) ) then
            factentry:= AGR_InfoForName( fus.name );
            if factentry <> fail then
              for factstd in [ 1 .. maxstd ] do
                pres:= AtlasProgram( fus.name, factstd, "presentation" );
                if pres <> fail then
                  for std in [ 1 .. maxstd ] do
                    gens:= OneAtlasGeneratingSet( entry[1], std );
                    if gens <> fail then
                      prg:= StraightLineProgramFromStraightLineDecision(
                                pres.program );
                      res:= ResultOfStraightLineProgram( prg,
                                gens.generators );
                      ker:= Group( res );
                      if Size( tbl ) / Size( CharacterTable( fus.name ) )
                         = Size( ker ) then
                        Add( result, [ std, fus.name, factstd, true ] );
                      else
                        Add( result, [ std, fus.name, factstd, false ] );
                      fi;
                    fi;
                  od;
                fi;
              od;
            fi;
          fi;
        od;
      fi;
      return result;
    end;

    result:= true;
    toc:= AtlasOfGroupRepresentationsInfo.TableOfContents.remote;

    if Length( arg ) = 0 or ( Length( arg ) = 1 and IsBool( arg[1] ) ) then
      for entry in AtlasOfGroupRepresentationsInfo.GAPnames do
        result:= AtlasOfGroupRepresentationsTestStdCompatibility( entry,
                     verbose ) and result;
      od;
    else
      entry:= arg[1];
      info:= CompInfoForEntry( entry );
      if not IsBound( entry[6] ) then 
        # No compatibility info is stored yet.
        if not IsEmpty( info ) then
          Print( "#I  AGRGNAN: set compatibility info `", info, "' for `", 
                 entry[1], "'\n" );
        fi;
      else
        diff:= Difference( info, entry[6] );
        if not IsEmpty( diff ) then
          Print( "#I  AGRGNAN: add `", diff,
                 "' to the compatibility info for `", entry[1], "'\n" );
        fi;
        diff:= Difference( entry[6], info );
        if not IsEmpty( diff ) then
          Print( "#I  AGRGNAN: cannot verify compatibility info `", diff,
                 "' for `", entry[1], "'\n" );
        fi;
        if ForAny( entry[6], l1 -> ForAny( info,
             l2 -> l1{[1..3]} = l2{[1..3]} and l1[4] <> l2[4] ) ) then
          Print( "#E  AGRGNAN: contradiction of compatibility info for `",
                 entry[1], "'\n" );
          result:= false;
        fi;
      fi;
    fi;

    return result;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestCompatibleMaxes( [[<entry>, ]<verbose>] )
##
##
InstallGlobalFunction( AtlasOfGroupRepresentationsTestCompatibleMaxes,
    function( arg )
    local verbose, maxdeg, maxmax, CompMaxForEntry, result, toc, entry, info,
          stored, entry2, filt;

    verbose:= ( Length( arg ) <>  0 and arg[ Length( arg ) ] = true );
    maxdeg:= AtlasRepHardCases.MaxTestDegree;
    maxmax:= AtlasRepHardCases.MaxNumberMaxes;

    CompMaxForEntry:= function( entry )
      local result, tbl, l, factname, factstd, gens, i, prg, max, pres,
            factprg, res, perm, words, addgens, j;

      result:= [];
      tbl:= CharacterTable( entry[1] );
      if IsBound( entry[4] ) and IsBound( entry[6] ) and tbl <> fail then
        # Maxes orders info and compatibility info are known.
        for l in Filtered( entry[6], x -> x[4] = true ) do
          # Check whether the maxes of the two groups are in bijection.
          factname:= l[2];
          factstd:= l[3];
          if ForAny( ComputedClassFusions( tbl ),
                     fus -> fus.name = factname and
                            IsKernelInFrattiniSubgroup( tbl, fus ) ) then
            gens:= OneAtlasGeneratingSet( entry[1], l[1],
                                          NrMovedPoints, [ 1 .. maxdeg ] );
            if gens <> fail then
              for i in [ 1 .. maxmax ] do
                prg:= AtlasProgram( factname, factstd, "maxes", i );
                if prg <> fail and IsBound( entry[4][i] ) then
                  # try the program for the ext. gp.
                  max:= ResultOfStraightLineProgram( prg.program,
                            gens.generators );
                  max:= Group( max );
                  if Size( max ) = entry[4][i] then
                    Add( result,
                         [ entry[2], factstd, i, [ prg.identifier[2] ] ] );
                  else
                    # We add generators of the kernel.
                    pres:= AtlasProgram( factname, factstd, "presentation" );
                    if pres <> fail then
                      factprg:= StraightLineProgramFromStraightLineDecision(
                                    pres.program );
                      res:= ResultOfStraightLineProgram( factprg,
                                gens.generators );
                      perm:= Sortex( -List( res, Order ) );
                      res:= Permuted( res, perm );
                      words:= Permuted( [ 1 .. Length( res ) ], perm );
                      addgens:= [];
                      for j in [ 1 .. Length( res ) ] do
                        Add( addgens, words[j] );
                        max:= ClosureGroup( max, res[j] );
                        if Size( max ) = entry[4][i] then
                          break;
                        fi;
                      od;
                      if Size( max ) = entry[4][i] then
                        Add( result,
                             [ entry[2], l[3], i,
                               [ prg.identifier[2], factname,
                                 LinesOfStraightLineProgram(
                                     RestrictOutputsOfSLP( factprg,
                                         addgens ) ) ] ] );
                      else
                        Print( "#E  not enough generators for the kernel ",
                               "(max. ", i, " of ", entry[1], ")\n" );
                      fi;
                    fi;
                  fi;
                fi;
              od;
            fi;
          fi;
        od;
      fi;
      return result;
    end;

    result:= true;
    toc:= AtlasOfGroupRepresentationsInfo.TableOfContents.remote;

    if Length( arg ) = 0 or ( Length( arg ) = 1 and IsBool( arg[1] ) ) then
      for entry in AtlasOfGroupRepresentationsInfo.GAPnames do
        result:= AtlasOfGroupRepresentationsTestCompatibleMaxes( entry,
                     verbose ) and result;
      od;
    else
      entry:= arg[1];
      info:= CompMaxForEntry( entry );
      stored:= [];
      if IsBound( toc.( entry[2] ) ) and
         IsBound( toc.( entry[2] ).maxext ) then
        stored:= List( toc.( entry[2] ).maxext,
                       x -> Concatenation( [ entry[2] ], x ) );
      fi;
      for entry2 in info do
        filt:= Filtered( stored,
                         x ->     x{ [ 1 .. 3 ] } = entry2{ [ 1 .. 3 ] }
                              and x[4][1] = entry2[4][1] );
        if IsEmpty( filt ) then
          # The entry is new.
          if Length( entry2[4] ) = 1 then
            Print( "#I  AGRTOCEXT: set entry\nAGRTOCEXT(\"", entry2[1],
                   "\",", entry2[2], ",", entry2[3], ",[\"",
                   entry2[4][1], "\"]);\n" );
          else
            Print( "#I  AGRTOCEXT: set entry\nAGRTOCEXT(\"", entry2[1],
                   "\",\"", entry2[4][2], "\",", entry2[4][3], ");\n" );
            Print( "#I  AGRTOCEXT: set entry\nAGRTOCEXT(\"", entry2[1],
                   "\",", entry2[2], ",", entry2[3], ",[\"",
                   entry2[4][1], "\",\"", entry2[4][2], "\"]);\n" );
          fi;
        elif Length( entry2[4] ) <> Length( filt[1][4] ) then
          if Length( entry2[4] ) = 3 and Length( filt[1][4] ) = 2 then
            if entry2[4]{ [ 1, 2 ] } <> filt[1][4] then
              # We have already such an entry but it is different.
              Print( "#E  AGRTOCEXT: difference ", entry2, " vs. ", filt[1],
                     "\n" );
              result:= false;
            fi;
#T check also equality of the script with a stored one if applicable!
          else
            # We have already such an entry but it is different.
            Print( "#E  AGRTOCEXT: difference ", entry2, " vs. ", filt[1],
                   "\n" );
            result:= false;
          fi;
        fi;
      od;
      for entry2 in stored do
        filt:= Filtered( info,
                         x ->     x{ [ 1 .. 3 ] } = entry2{ [ 1 .. 3 ] }
                              and x[4][1] = entry2[4][1] );
        if IsEmpty( filt ) then
          Print( "#I  AGRTOCEXT: cannot verify stored value ", entry2, "\n" );
        fi;
      od;
    fi;

    return result;
end );


#############################################################################
##
#E

