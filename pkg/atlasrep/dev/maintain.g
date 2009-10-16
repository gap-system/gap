#############################################################################
##
#W  maintain.g           GAP 4 package AtlasRep                 Thomas Breuer
##
#H  @(#)$Id: maintain.g,v 1.32 2009/01/14 17:04:15 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains &GAP; functions that are needed for maintaining the
##  &ATLAS; of Group Representations but not intended for the distribution
##  of the package.
##
##  The following directories are used for that.
##  `dev/log' :
##      Logfiles for the script <F>update.g</F> are stored here.
##
##  `dev/magma' :
##      New Magma format files are transferred here directly from the server.
##
##  `dev/archive' :
##      Outdated Magma format files are moved here from <F>dev/magma</F>,
##      via <Ref Func="UpdateNewMagmaFormatFiles"/>;
##      other files are entered from the local data directories,
##      via the update script <F>update.g</F>.
##
##  `dev/gap0' :
##      The translations of Magma format files to &GAP; format
##      (via <F>etc/mtog</F>)
##      are added here by <Ref Func="UpdateNewMagmaFormatFiles"/>.
##
Revision.( "atlasrep/gap/maintain_g" ) :=
    "@(#)$Id: maintain.g,v 1.32 2009/01/14 17:04:15 gap Exp $";


#############################################################################
##
#V  AtlasOfGroupRepresentationsInfo.dirnames
#V  AtlasOfGroupRepresentationsInfo.subdirnames
##
##  Set components needed only for administration.
##
AtlasOfGroupRepresentationsInfo.dirnames:= [
    "alt",
    "clas",
    "exc",
    "lin",
    "misc",
    "spor",
    ];;

AtlasOfGroupRepresentationsInfo.subdirnames:= [
    "gap0",
    "mtx",
    "words",
    ];;


#############################################################################
##
#F  AGR_DirectoryTree( <startpath>, <filename> )
##
##  We assume that there is no cycle, cf. BrowseData.DirectoryTree.
##
DeclareGlobalFunction( "AGR_DirectoryTree" );

InstallGlobalFunction( AGR_DirectoryTree, function( startpath, filename )
    local startfile, files, nondirs, dirs, startdir, file;

    startfile:= Filename( Directory( startpath ), filename );
    if not IsExistingFile( startfile ) then
      return fail;
    elif IsDirectoryPath( startfile ) then
      files:= Filtered( DirectoryContents( startfile ),
                        x -> not x in [ ".", ".." ] );
      Sort( files );
      nondirs:= [];
      dirs:= [];
      startdir:= Directory( startfile );
      for file in files do
        if IsDirectoryPath( Filename( startdir, file ) ) then
          Add( dirs, file );
        else
          Add( nondirs, file );
        fi;
      od;
      return [ filename, nondirs,
               List( dirs, x -> AGR_DirectoryTree( startfile, x ) ) ];
    else
      return filename;
    fi;
    end );


#############################################################################
##
#F  AGR_SpecialFormatFiles( <srcdir>, <formats> )
##
BindGlobal( "AGR_SpecialFormatFiles", function( srcdir, formats )
    local filenames, dir, filesindir, groupinfo, simpname, dirname, subinfo,
          filename;

    # Create the list of the relevant filenames (plus path information).
    filenames:= [];
    for dir in AtlasOfGroupRepresentationsInfo.dirnames do
      filesindir:= AGR_DirectoryTree( Concatenation( srcdir, "/", dir ), "" );
      if filesindir <> fail then
        for groupinfo in filesindir[3] do
          simpname:= groupinfo[1];
          # Add the files in the subdirectories given by `formats'.
          for dirname in formats do
            subinfo:= First( groupinfo[3], l -> l[1] = dirname );
            if subinfo <> fail then
              for filename in subinfo[2] do
                Add( filenames, [ dir, simpname, dirname, filename ] );
              od;
            fi;
          od;
        od;
      fi;
    od;

    # Return the list.
    return filenames;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestTableOfContentsContainment()
##
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsTestTableOfContentsContainment"
##  Arg=''/>
##
##  <Description>
##  It is checked whether the local table of contents is a subset of the
##  currently stored version of the table of contents of the server.
##  The return value is the list of names of all those files in the local
##  data directories that have to be removed.
##  For the files in the local data directories that are not part of the
##  remote data, information lines are printed.
##  </Description>
##  </ManSection>
##
BindGlobal( "AtlasOfGroupRepresentationsTestTableOfContentsContainment",
    function()
    local filenames, dir, localtoc, remotetoc, badnames, lnames, rnames,
          name, groupname, entry, list;

    # Compute the true contents of the directories `datagens', `dataword'.
    filenames:= [];
    for dir in DirectoriesPackageLibrary( "atlasrep", "datagens" ) do
      Append( filenames, DirectoryContents( Filename( dir, "" ) ) );
    od;
    for dir in DirectoriesPackageLibrary( "atlasrep", "dataword" ) do
      Append( filenames, DirectoryContents( Filename( dir, "" ) ) );
    od;
    localtoc:= AtlasOfGroupRepresentationsComposeTableOfContents( filenames,
                   AtlasOfGroupRepresentationsInfo.groupnames );
    remotetoc:= AtlasOfGroupRepresentationsInfo.TableOfContents;
    if not IsBound( remotetoc.remote ) then
      Print( "#I  omitting ",
          "`AtlasOfGroupRepresentationsTestTableOfContentsContainment'\n" );
      return false;
    fi;
    remotetoc:= remotetoc.remote;
    badnames:= [];

    # Check whether there are ``illegal'' group names.
    lnames:= RecNames( localtoc );
    rnames:= RecNames( remotetoc );
    for name in Difference( lnames, rnames ) do
      if not name in [ "data", "otherfiles", "lastupdated" ] then
        Add( badnames, Concatenation( name, "G*" ) );
        Print( "#I  remove all local files for the group`", name, "'\n" );
      fi;
    od;

    # Loop over the ``legal'' group names.
    for groupname in Intersection( lnames, rnames ) do
      if not groupname in [ "otherfiles", "lastupdated" ] then

        # Check whether there are ``illegal'' components for this group.
        lnames:= RecNames( localtoc.( groupname ) );
        rnames:= RecNames( remotetoc.( groupname ) );
        for name in Difference( lnames, rnames ) do
          if not IsEmpty( localtoc.( groupname ).( name ) ) then
            for entry in localtoc.( groupname ).( name ) do
              if IsString( entry[ Length( entry ) ] ) then
                Add( badnames, entry[ Length( entry ) ] );
              else
                Append( badnames, entry[ Length( entry ) ] );
              fi;
            od;
            Print( "#I  remove all local files for the group `", groupname,
                   "' corresp. to the component `", name, "'\n" );
          fi;
        od;

        # Check the files for the ``legal'' components.
        for name in Intersection( lnames, rnames ) do
          for entry in Difference( localtoc.( groupname ).( name ),
                                   remotetoc.( groupname ).( name ) ) do
            if IsString( entry[ Length( entry ) ] ) then
              Add( badnames, [ entry[ Length( entry ) ] ] );
            else
              Append( badnames, [ entry[ Length( entry ) ] ] );
            fi;
            Print( "#I  remove the local file(s) given by `",
                   entry[ Length( entry ) ], "'\n" );
          od;
        od;

      fi;
    od;

    # Return the result.
    return badnames;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestTableOfContentsRemoteDiff( srcdir,
#F      filenames )
##
BindGlobal( "AtlasOfGroupRepresentationsTestTableOfContentsRemoteDiff",
    function( srcdir, filenames )
    local toc, locdirs, bad, entry, locfile, srcfile, loctime, srctime;

    # If not yet available then read the local and remote table of contents.
    AtlasTableOfContents( "local" );
    AtlasTableOfContents( "remote" );
    toc:= AtlasOfGroupRepresentationsInfo.TableOfContents;

    if   IsSubset( [ "lastupdated", "otherfiles" ],
                   RecNames( toc.( "local" ) ) ) then
      # If the local data directories are empty then nothing is to check.
      return [];
    elif not IsBound( toc.( "local" ) ) or not IsBound( toc.remote ) then
      Print( "#I  could not load the two tables of contents\n" );
      return [];
    fi;

    # Compare the contents of the file in the installation and in the mirror.
    locdirs:= Concatenation(
                  DirectoriesPackageLibrary( "atlasrep", "datagens" ),
                  DirectoriesPackageLibrary( "atlasrep", "dataword" ) );
    bad:= [];
    for entry in filenames do
      locfile:= Filename( locdirs, entry[4] );
      if locfile <> fail then
        srcfile:= Concatenation( srcdir,
                      JoinStringsWithSeparator( entry, "/" ) );
        if StringFile( locfile ) <> StringFile( srcfile ) then
          if not IsExistingFile( locfile ) then
            locfile:= Concatenation( locfile, ".gz" );
          fi;
          if IsExistingFile( locfile ) then
            loctime:= IO_stat( locfile ).mtime;
            srctime:= IO_stat( srcfile ).mtime;
            if loctime <= srctime then
              # The local file is older than the server file.
              Add( bad, [ entry[4], String( loctime ) ] );
              Print( "#I  update local file `", locfile, "'\n" );
            else
              Print( "#E  local file `", locfile, "' was changed!\n" );
            fi;
          fi;
        fi;
      fi;
    od;

    # Return the result.
    return bad;
end );


#############################################################################
##
#V  AtlasOfGroupRepresentationsInfo.ExclusionList
##
##  Several files must be excluded,
##  for example because the contents is wrong or not GAP readable,
##  and the files are not removed in time from the server.
##
AtlasOfGroupRepresentationsInfo.ExclusionList:= [
    "McLG1-Zr22B0.g", # syntax error in the GAP file
    "2Co1G1-Zr24B0.g",        # not in the common GAP input format
    "Sz8G1-Zr105B0.g",        # not integral, name should be Sz8G1-Ar105B0.g
    "2J2d2G1-f7r448bB0.m1",   # the order is a little bit too large
    "2J2d2G1-f7r448bB0.m2",   # (other generator corrupted)
    "TF42d2G1-f3r54B0.m1",    # these are not standard generators
    "TF42d2G1-f3r54B0.m2",
    "4Sz8d3G1-f5r24B0.m1",
    "4Sz8d3G1-f5r24B0.m2",
    "A10G1-f7r101B0.m1",      # the two generators are identical
    "A10G1-f7r101B0.m2",
    "L227G1-f27r2aB0.m1",     # these would belong to 2L227,
    "L227G1-f27r2aB0.m2",     # and the corresponding correct files for 2L227
    "L227G1-f27r2bB0.m1",     # are available
    "L227G1-f27r2bB0.m2",     # ...
    "L227G1-f27r2cB0.m1",     # ...
    "L227G1-f27r2cB0.m2",     # (until here)
    "2O73d2G1-f3r8B0.m1",     # these would belong to 2O73d2i
    "2O73d2G1-f3r8B0.m2",     # (compute random elements, find order 60)
    "Mmax27wrongG0-p17B0.m1", # these should not be available ...
    "Mmax27wrongG0-p17B0.m2",

    "U52G1-f11r55aB0.m1",     # the two generators are identical!
    "U52G1-f11r55aB0.m2",
    "F22d2G1-max3W1", # order is 185794560 (should be F22d2G1-max5W1)
    "F22d2G1-max4W1", # (should be F22d2G1-max6W1)
    "F22d2G1-max5W1", # order is 78382080 (should be F22d2G1-max7W1)
    "F22d2G1-max6W1", # order is 35942400 (should be F22d2G1-max8W1)
    "F22d2G1-max7W1", # order is 35389440 (should be F22d2G1-max9W1)
    "F22d2G1-max8W1", # order is 25194240 (should be F22d2G1-max10W1)
    "F22d2G1-max9W1", # order is 10077696 (should be F22d2G1-max11W1)
    "F22d2G1-max10W1", # order is 908328960 (should be F22d2G1-max4W1)
    "F22d2G1-max11W1", # order is 8491392 (should be F22d2G1-max12W1)
    "F22d2G1-max12W1", # order is 2090188800 (should be F22d2G1-max3W1)
    "L34G1-max4W1", # order is 20160 not 360
    "L34G1-max5W1", # order is 10 not 360
    "L38d2G1-max2W1", # order is 12
    "L38d2G1-max3W1", # order is 32965632
    "L38d2G1-max4W1", # order is 6
    "L38d2G1-max5W1", # order is 32965632
    "L38d2G1-max6W1", # order is 6
    "McLd2G1-f4r896aB0.m1", # the order of the second generator is 5
    "McLd2G1-f4r896aB0.m2", # but should be 3
    "McLd2G1-f4r896bB0.m1", # the order of the second generator is 5
    "McLd2G1-f4r896bB0.m2", # but should be 3
    "G25G1-cycW1", # in line `mu 9 25A 30A', label `9' is used but not defined
    "J2d2G1-P1", # in three lines, add comment signs or remove comments
    "J3d2G1-f17r761aB0.m1", # the order of the second generator is 6
    "J3d2G1-f17r761aB0.m2", # but should be 3
    "L52G1-f31r124B0.m1", # the orders of the generators should be [ 2, 5 ]
    "L52G1-f31r124B0.m2", # not [ 5, 2 ]
    "ONd2G1-find1", # commas in a list of element orders seem to be not
                    # allowed, according to the BBox language specification
  ];;


#############################################################################
##
#V  AtlasOfGroupRepresentationsInfo.IdentificationOfGroupNames
##
##  For several groups, the data are contained in different
##  server directories.
##  We can consider only one directory,
##  and we prescribe preferences.
##  This list is used in `RecomputeAtlasTableOfContents'.
##
AtlasOfGroupRepresentationsInfo.IdentificationOfGroupNames:= [

    [ [ "lin", "L213", "L213" ], [ "lin", "L216", "L213" ] ],
    [ [ "lin", "L72", "L72" ], [ "lin", "L62", "L72" ] ],

    [ [ "alt", "A6", "2A6" ], [ "clas", "S42", "2A6" ] ],
    [ [ "alt", "A6", "3A6" ], [ "clas", "S42", "3A6" ] ],
    [ [ "alt", "A6", "6A6" ], [ "clas", "S42", "6A6" ] ],
    [ [ "alt", "A6", "A6" ], [ "clas", "S42", "A6" ] ],
    [ [ "alt", "A6", "2S6" ], [ "clas", "S42", "2S6" ] ],
    [ [ "alt", "A6", "3S6" ], [ "clas", "S42", "3S6" ] ],
    [ [ "alt", "A6", "6S6" ], [ "clas", "S42", "6S6" ] ],
    [ [ "alt", "A6", "A6V4" ], [ "clas", "S42", "A6V4" ] ],
    [ [ "alt", "A6", "M10" ], [ "clas", "S42", "M10" ] ],
    [ [ "alt", "A6", "PGL29" ], [ "clas", "S42", "PGL29" ] ],
    [ [ "alt", "A6", "S6" ], [ "clas", "S42", "S6" ] ],
    [ [ "clas", "U42", "2U42" ], [ "clas", "S43", "2U42" ] ],
    [ [ "clas", "U42", "U42" ], [ "clas", "S43", "U42" ] ],
    [ [ "clas", "U42", "2U42d2" ], [ "clas", "S43", "2U42d2" ] ],
    [ [ "clas", "U42", "U42d2" ], [ "clas", "S43", "U42d2" ] ],
    [ [ "clas", "U33", "U33" ], [ "exc", "G22", "U33" ] ],
    [ [ "clas", "U33", "U33d2" ], [ "exc", "G22", "U33d2" ] ],
    [ [ "alt", "A5", "2A5" ], [ "lin", "L24", "2A5" ] ],
    [ [ "alt", "A5", "2S5" ], [ "lin", "L24", "2S5" ] ],
    [ [ "alt", "A5", "2S5i" ], [ "lin", "L24", "2S5i" ] ],
    [ [ "alt", "A5", "A5" ], [ "lin", "L24", "A5" ] ],
    [ [ "alt", "A5", "S5" ], [ "lin", "L24", "S5" ] ],
    [ [ "alt", "A5", "2A5" ], [ "lin", "L25", "2A5" ] ],
    [ [ "alt", "A5", "2S5" ], [ "lin", "L25", "2S5" ] ],
    [ [ "alt", "A5", "2S5i" ], [ "lin", "L25", "2S5i" ] ],
    [ [ "alt", "A5", "A5" ], [ "lin", "L25", "A5" ] ],
    [ [ "alt", "A5", "S5" ], [ "lin", "L25", "S5" ] ],
    [ [ "lin", "L28", "L28" ], [ "exc", "R3", "L28" ] ],
    [ [ "lin", "L28", "L28d3" ], [ "exc", "R3", "L28d3" ] ],

    [ [ "spor", "F24", "3F24d2" ], [ "spor", "M", "Mmax3" ] ],
# just two representations for 3F24d2 in spor/M
    [ [ "spor", "M", "Mmax19" ], [ "spor", "M", "Mnotmax19" ] ],
# what is this?
    [ [ "lin", "L271", "L271" ], [ "spor", "M", "Mmax37" ] ],
# just one representation for L271 in spor/M
    [ [ "lin", "L259", "L259" ], [ "spor", "M", "Mmax38" ] ],
# just one representation for L259 in spor/M
    [ [ "lin", "L229", "L229d2" ], [ "spor", "M", "Mmax40" ] ],
# just one representation for L229d2 in spor/M
    [ [ "lin", "L219", "L219d2" ], [ "spor", "M", "Mmax42" ] ],
# just one representation for L219d2 in spor/M

    [ [ "alt", "A6", "2A6" ], [ "lin", "L29", "2A6" ] ],
    [ [ "alt", "A6", "3A6" ], [ "lin", "L29", "3A6" ] ],
    [ [ "alt", "A6", "6A6" ], [ "lin", "L29", "6A6" ] ],
    [ [ "alt", "A6", "A6" ], [ "lin", "L29", "A6" ] ],
    [ [ "alt", "A6", "2S6" ], [ "lin", "L29", "2S6" ] ],
    [ [ "alt", "A6", "3S6" ], [ "lin", "L29", "3S6" ] ],
    [ [ "alt", "A6", "6S6" ], [ "lin", "L29", "6S6" ] ],
    [ [ "alt", "A6", "A6V4" ], [ "lin", "L29", "A6V4" ] ],
    [ [ "alt", "A6", "M10" ], [ "lin", "L29", "M10" ] ],
    [ [ "alt", "A6", "PGL29" ], [ "lin", "L29", "PGL29" ] ],
    [ [ "alt", "A6", "S6" ], [ "lin", "L29", "S6" ] ],
    [ [ "lin", "L27", "L27" ], [ "lin", "L32", "L27" ] ],
    [ [ "lin", "L27", "2L27" ], [ "lin", "L32", "2L27" ] ],
    [ [ "lin", "L27", "2L27d2" ], [ "lin", "L32", "2L27d2" ] ],
    [ [ "lin", "L27", "2L27d2i" ], [ "lin", "L32", "2L27d2i" ] ],
    [ [ "lin", "L27", "L27d2" ], [ "lin", "L32", "L27d2" ] ],
    [ [ "alt", "A8", "2A8" ], [ "lin", "L42", "2A8" ] ],
    [ [ "alt", "A8", "A8" ], [ "lin", "L42", "A8" ] ],
    [ [ "alt", "A8", "S8" ], [ "lin", "L42", "S8" ] ],
    [ [ "clas", "O8m3", "O8m3d2c" ], [ "spor", "M", "O8m3d2c" ] ],
  ];;


#############################################################################
##
#F  RecomputeAtlasTableOfContents( <srcdir> )
##
##  <ManSection>
##  <Func Name="RecomputeAtlasTableOfContents" Arg='srcdir'/>
##
##  <Description>
##  Let <srcdir> be a <E>local</E> path to a server for the data of the
##  &ATLAS; of Group Representations.
##  This function computes the current table of contents from these data,
##  and replaces the file <F>gap/atlasprm.g</F> of the package by an updated
##  version.
##  (The header part of the old file is kept.)
##  <P/>
##  The functions
##  <C>AtlasOfGroupRepresentationsTestTableOfContentsContainment</C> and
##  <C>AtlasOfGroupRepresentationsTestTableOfContentsRemoteDiff</C> are
##  called afterwards.
##  </Description>
##  </ManSection>
##
BindGlobal( "RecomputeAtlasTableOfContents", function( srcdir )
    local filenames, types, groupnames, ignorenames, identifications,
          exclude, exclude_orig, i, entry, name, type, parsed, new, known,
          filt, result, len, groupname, record, listtosort, dirs, tocfile,
          archfile, intermed, toc, pos, bad, mv, diff, str, out;

    # Create the list of the relevant filenames (plus path information).
    filenames:= AGR_SpecialFormatFiles( srcdir,
                    AtlasOfGroupRepresentationsInfo.subdirnames );

    # Create the group names information.
    types:= AGRDataTypes( "rep", "prg" );
    groupnames:= [];
    ignorenames:= [];
    identifications:= Set(
        AtlasOfGroupRepresentationsInfo.IdentificationOfGroupNames );
    exclude:= Set( AtlasOfGroupRepresentationsInfo.ExclusionList );
    exclude_orig:= ShallowCopy( exclude );

    # Loop over the entries.
    for i in [ 1 .. Length( filenames ) ] do
      # Extract the group name from the filename.
      entry:= filenames[i];
      name:= entry[4];
      if name in exclude_orig then
        Unbind( filenames[i] );
        RemoveSet( exclude, name );
        Info( InfoAtlasRep, 1,
              "excluding file `", name, "' as desired" );
      else
        for type in types do
          parsed:= AGRParseFilenameFormat( name, type[2].FilenameFormat );
          if parsed <> fail then
            new:= [ entry[1], entry[2], parsed[1] ];
            if   new in ignorenames then
              Unbind( filenames[i] );
            elif not new in groupnames then
              # We meet this triple for the first time.
              known:= First( identifications, pair -> new = pair[2] );
              if known <> fail then
                # This triple is deprecated.
                Info( InfoAtlasRep, 1,
                      "prefer ", known[1], " to ", known[2] );
                Add( ignorenames, new );
                Unbind( filenames[i] );
                # This identification has been used.  Remove it.
                RemoveSet( identifications, known );
              else
                # Consider the triple.
                filt:= Filtered( groupnames, tr -> tr[3] = new[3] );
                if not IsEmpty( filt ) then
                  # An unexpected ambiguity occurs.
                  Unbind( filenames[i] );
                  Info( InfoAtlasRep, 1,
                        "group name `", new[3], "' used already in ", filt[1],
                        "\n", "#E  (ignore parse result ", new, "),\n",
                        "#E  fix this and then rerun the computation!" );
                  Add( ignorenames, new );
                else
                  AddSet( groupnames, new );
                fi;
              fi;
            fi;
            break;
          fi;
        od;
      fi;
    od;

    # Are there outdated identifications?
    if not IsEmpty( identifications ) then
      Info( InfoAtlasRep, 1,
            "the following identifications were not used:\n",
            identifications );
    fi;

    # Are there outdated exclusions?
    if not IsEmpty( exclude ) then
      Info( InfoAtlasRep, 1,
            "the following exclusions were not used:\n",
            exclude );
    fi;

    # Initialize the result record.
    result:= rec( otherfiles:= [] );

    # Deal with the case of `gzip'ped files, and omit obvious garbage.
    for name in List( filenames, x -> x[4] ) do
      len:= Length( name );
      if 3 <= len and name{ [ len-2 .. len ] } = ".gz" then
        name:= name{ [ 1 .. len-3 ] };
      fi;
      if AtlasOfGroupRepresentationsScanFilename( name, result ) = false then
        if not ( name in [ "dummy", ".", "..", ".:", "CVS", "CVS:", "./CVS:",
                           ".cvsignore", "Entries", "Repository", "Root",
                           "toc.g" ] or
                 name[ Length( name ) ] in [ '%', '~' ] or
                 ( 3 <= Length( name )
                   and name{ Length( name ) + [ - 2 .. 0 ] } = "BAK" ) ) then
          Info( InfoAtlasRep, 3,
                "t.o.c. construction: ignoring name `", name, "'" );
          AddSet( result.otherfiles, name );
        fi;
      fi;
    od;

    # Postprocessing,
    # and *sort* the representations as given in the type definition.
    for groupname in List( groupnames, x -> x[3] ) do
      if IsBound( result.( groupname ) ) then

        record:= result.( groupname );
        for type in AGRDataTypes( "rep", "prg" ) do
          if IsBound( record.( type[1] ) ) then

            type[2].PostprocessFileInfo( result, record );

            # Sort the data of the given type as defined.
            if IsBound( type[2].SortTOCEntries ) then
              listtosort:= List( record.( type[1] ), type[2].SortTOCEntries );
              SortParallel( listtosort, record.( type[1] ) );
            fi;

          fi;
        od;

      fi;
    od;

    # Store the current date in Coordinated Universal Time
    # (Greenwich Mean Time).
    result.lastupdated:= CurrentDateTimeString();

    # Store the new table of contents.
    AtlasOfGroupRepresentationsInfo.TableOfContents.remote:= result;
    AtlasOfGroupRepresentationsInfo.groupnames:= groupnames;

    # Copy the constant part of the data to the desired file.
    dirs:= DirectoriesPackageLibrary( "atlasrep", "gap" );
    tocfile  := Filename( dirs, "atlasprm.g"   );
    archfile := Filename( dirs[1], "atlasprm.old" );
    intermed := Filename( dirs[1], "atlasprm.new" );

    toc:= StringFile( tocfile );
    pos:= PositionSublist( toc, "do not edit" );
    pos:= Position( toc, '\n', pos );
    toc:= toc{ [ 1 .. pos ] };
    Append( toc, "##\n\n" );
    FileString( intermed, toc );

    # Add the data.
    AppendTo( intermed,
        StringOfAtlasTableOfContents( "remote" ),
        "##################################################################",
        "###########\n##\n#E\n\n" );

    # Perform the tests.
    bad:= [];
    bad[1]:= AtlasOfGroupRepresentationsTestTableOfContentsContainment();
    bad[2]:= AtlasOfGroupRepresentationsTestTableOfContentsRemoteDiff(
                 srcdir, filenames );

    # Save the old version of the file, and replace it by the new version.
    mv:= Filename( DirectoriesSystemPrograms(), "mv" );
    diff:= Filename( DirectoriesSystemPrograms(), "diff" );

    Process( DirectoryCurrent(), mv, InputTextNone(), OutputTextNone(),
             [ tocfile, archfile ] );
    Process( DirectoryCurrent(), mv, InputTextNone(), OutputTextNone(),
             [ intermed, tocfile ] );

    # Print the differences between old and new version.
    str:= "";
    out:= OutputTextString( str, true );
    Process( DirectoryCurrent(), diff, InputTextNone(), out,
             [ archfile, tocfile ] );
    CloseStream( out );
    Info( InfoAtlasRep, 2,
          str );

    return bad;
end );


#############################################################################
##
##  The leading information is given by the Magma format files
##  in the <F>mag</F> directories on the server.
##  The corresponding &GAP; format files (if they exist) are in <F>gap0</F>
##  directories on the server.
##  <P/>
##  Updates are necessary for <F>mag</F> files that either have no
##  <F>gap0</F> counterpart or whose <F>gap0</F> counterpart is older than
##  the <F>mag</F> file.
##  <P/>
##  In this case, the <F>mag</F> files in question are transferred
##  to the local <F>dev/magma</F> directory (after saving a perhaps existing
##  version of this file in <F>dev/archive</F> before),
##  and then the script <F>etc/mtog</F> is called in order to create a &GAP;
##  readable version in <F>dev/gap0</F>
##  (see <Ref Func="UpdateNewMagmaFormatFiles"/>).
##  <P/>
##  The local files in <F>dev/gap0</F> are then checked
##  (see <Ref Func="TestAfterMTOG"/>),
##  before they they are offered to Rob Wilson,
##  for being made available on the server.
##  <P/>
##  Afterwards, these files are fetched from the server in the regular update
##  process (see <F>dev/update.g</F> and the <C>update</C> target in
##  <F>Makefile</F>),
##  and appear in the local <F>datagens</F> directory.
##  They must then coincide with the ones in <F>dev/gap0</F>,
##  which is checked by <Ref Func="CompareFilesInDatagensAndDev"/>.
##


#############################################################################
##
#F  AtlasOfGroupRepresentationsUpdateData( [<groupnames>] )
##
##  The purpose of this function is to transfer data files of the
##  &ATLAS; of Group Representations available on the remote servers
##  to the local data directories.
##  If a list <A>groupnames</A> of &GAP; names is given as argument
##  (see <Ref Sect="Group Names Used in the AtlasRep Package"/>)
##  then all files for these groups are fetched from the servers
##  (if not yet locally available),
##  the default is the list of all &GAP; names.
##  <P/>
##  Note that this function is thought for adding a few new files to an
##  already existing local installation of the &ATLAS; data
##  (see <Ref Sect="Local or Remote Installation of the AtlasRep Package"/>).
##  The function is <E>not</E> thought for creating a local copy
##  of the servers' data from scratch.
##
BindGlobal( "AtlasOfGroupRepresentationsUpdateData", function( arg )
    local file, toc, groupnames, errors, pair, record, name, entry;

    file:= function( dir, groupname, names, type )
      if IsString( names ) then
        return AtlasOfGroupRepresentationsLocalFilenameTransfer( dir,
                   groupname, names, type ) <> fail;
      else
        return ForAll( names, name ->
          IsString( name ) and
            AtlasOfGroupRepresentationsLocalFilenameTransfer( dir,
                   groupname, name, type ) <> fail );
      fi;
    end;

    toc:= AtlasTableOfContents( "remote" ).TableOfContents;

    groupnames:= AtlasOfGroupRepresentationsInfo.GAPnames;
    if Length( arg ) = 1 and IsList( arg[1] ) then
      groupnames:= Filtered( groupnames, pair -> pair[1] in arg[1] );
    fi;

    errors:= [];

    for pair in groupnames do
      if IsBound( toc.( pair[2] ) ) then
        record:= toc.( pair[2] );
        for name in AGRDataTypes( "rep" ) do
          if IsBound( record.( name[1] ) ) then
            for entry in record.( name[1] ) do
              if not file( "datagens", pair[2], entry[ Length( entry ) ],
                           name[2] ) then
                Add( errors, entry[ Length( entry ) ] );
              fi;
            od;
          fi;
        od;
        for name in AGRDataTypes( "prg" ) do
          if IsBound( record.( name[1] ) ) then
            for entry in record.( name[1] ) do
              if not file( "dataword", pair[2], entry[ Length( entry ) ],
                           name[2] ) then
                Add( errors, entry[ Length( entry ) ] );
              fi;
            od;
          fi;
        od;
      fi;
    od;

    for entry in errors do
      if IsString( entry ) then
        Print( "#E  failed to fetch the file `", entry, "'\n" );
      else
        Print( "#E  failed to fetch the file `", entry[1], "'\n" );
      fi;
    od;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsArchiveOutdatedFiles( <files>, <suffix> )
##
BindGlobal( "AtlasOfGroupRepresentationsArchiveOutdatedFiles",
    function( files, suffix )
    local dir, archivedir, filename, name, archivefile;

    dir:= Concatenation(
              DirectoriesPackageLibrary( "atlasrep", "datagens" ),
              DirectoriesPackageLibrary( "atlasrep", "dataword" ) );
    archivedir:= DirectoriesPackageLibrary( "atlasrep", "dev/archive" )[1];
    for filename in Concatenation(
            Concatenation( Filtered( files, x -> not IsString( x ) ) ),
                           Filtered( files, IsString ) ) do
      if Int( filename ) <> fail
         and filename[ Length( filename ) ] <> '*' then
        # The file may be in one of the directories `datagens', `dataword';
        # and it may be compressed or not.
        name:= Filename( dir, filename );
        archivefile:= Concatenation( Filename( archivedir, filename ),
                          suffix );
        if IsString( name ) then
          if IsExistingFile( name ) = false then
            name:= Concatenation( name, ".gz" );
            archivefile:= Concatenation( archivefile, ".gz" );
          fi;
          if IsExistingFile( name ) = false then
            Print( "#E  cannot find outdated file `", filename, "'\n" );
          else
            Print( "#I  archiving and removing `", filename,
                   "' as `", archivefile, "'\n" );
            Exec( Concatenation( "mv ", name, " ", archivefile ) );
          fi;
        else
          Print( "#E  cannot find outdated file `", filename, "'\n" );
        fi;
      fi;
    od;
    end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsMatalgInfo()
##
##  <ManSection>
##  <Func Name="AtlasOfGroupRepresentationsMatalgInfo" Arg=''/>
##
##  <Description>
##  This function checks whether the representations mentioned in the
##  <C>ringinfo</C> component of
##  <Ref Var="AtlasOfGroupRepresentationsInfo"/> are available according
##  to the table of contents,
##  and computes the <C>ringinfo</C> string for those representations of the
##  types <C>matalg</C> and <C>quat</C> that are available and for which no
##  entry has been stored yet.
##  The return value is a string that can be used as a part of the file
##  <F>gap/atlasprm.g</F>.
##  <P/>
##  (Note that the availability and correctness of the <C>ringinfo</C> entry
##  for each characteristic zero representation actually available is checked
##  via the <C>TestFileHeaders</C> function in the type records for these
##  representations.
##  This check is performed in
##  <C>AtlasOfGroupRepresentationsTestFileHeaders</C>.)
##  </Description>
##  </ManSection>
##
BindGlobal( "AtlasOfGroupRepresentationsMatalgInfo", function()
    local toc, groupnames, filenames, groupname, datarec, ringinfo, entry,
          pos, i, file, str;

    toc:= AtlasTableOfContents( "remote" );
    groupnames:= List( toc.groupnames, x -> x[3] );
    toc:= toc.TableOfContents;

    # List all files of the type 'matalg'.
    filenames:= [];
    for groupname in groupnames do
      if IsBound( toc.( groupname ) ) then
        datarec:= toc.( groupname );
        if IsBound( datarec.matalg ) then
          Append( filenames, List( datarec.matalg, x -> x[5] ) );
        fi;
        if IsBound( datarec.quat ) then
          Append( filenames, List( datarec.quat, x -> x[5] ) );
        fi;
      fi;
    od;

    # Compare this list with the stored ring info.
    # Prefer the stored description to the computed one.
    ringinfo:= [];
    for entry in AtlasOfGroupRepresentationsInfo.ringinfo do
      pos:= Position( filenames, Concatenation( entry[1], ".g" ) );
      if pos = fail then
        Info( InfoAtlasRep, 3,
              "`AtlasOfGroupRepresentationsMatalgInfo':\n",
              "#E  field info stored for `", entry[1],
              "' but representation not available" );
      else
        ringinfo[ pos ]:= entry{ [ 1, 2 ] };
      fi;
    od;

    # Compute the missing descriptions.
    for i in [ 1 .. Length( filenames ) ] do
      if not IsBound( ringinfo[i] ) then
        file:= Filename( DirectoriesPackageLibrary( "atlasrep", "datagens" ),
                         filenames[i] );
        if file = fail then
          Info( InfoAtlasRep, 3,
                "`AtlasOfGroupRepresentationsMatalgInfo':\n",
                "#I  file `", filenames[i],
                "' not available, ringinfo missing" );
        else
          ringinfo[i]:= [ filenames[i]{ [ 1 .. Length( filenames[i] )-2 ] },
                          AtlasStringOfFieldOfMatrixEntries( file )[2] ];
          Info( InfoAtlasRep, 3,
                "`AtlasOfGroupRepresentationsMatalgInfo':\n",
                "#I  new description `", ringinfo[i], "' added" );
        fi;
      fi;
    od;

    # Compose the result string (sorted lexicographically).
    str:= "";
    for entry in Set( ringinfo ) do
      Append( str, Concatenation( "AGRRNG(\"", entry[1], "\",\"", entry[2],
                                  "\");\n" ) );
    od;

    # Return the result.
    return str;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsReplaceRingInfo()
##
##  Replace the <C>ringinfo</C> part of the file <F>atlasprm.g</F>
##  if necessary.
##  This must be done after the files have been transferred, since only the
##  available files are read.
##
BindGlobal( "AtlasOfGroupRepresentationsReplaceRingInfo", function()
    local dirs, tocfile, toc, pos, header, pos2, middle, footer, new,
          mv, diff, archfile, intermed, str, out;

    # The filenames of the current table of contents, of the archive file,
    # and of the intermediate file.
    dirs:= DirectoriesPackageLibrary( "atlasrep", "gap" );
    tocfile  := Filename( dirs, "atlasprm.g"   );

    # Split the file with the remote table of contents into three parts.
    toc:= StringFile( tocfile );
    pos:= PositionSublist( toc, "AGRRNG(" );
    header:= toc{ [ 1 .. pos-1 ] };
    pos2:= PositionSublist( toc, "AGRRNG(", pos );
    while pos2 <> fail do
      pos:= pos2;
      pos2:= PositionSublist( toc, "AGRRNG(", pos );
    od;
    pos:= PositionSublist( toc, "\n", pos );
    middle:= toc{ [ Length( header ) + 1 .. pos ] };
    footer:= toc{ [ pos + 1 .. Length( toc ) ] };

    new:= AtlasOfGroupRepresentationsMatalgInfo();
    if new <> middle then

      # Replace the `ringinfo' part by the computed one.
      mv:= Filename( DirectoriesSystemPrograms(), "mv" );
      diff:= Filename( DirectoriesSystemPrograms(), "diff" );
      archfile := Filename( dirs[1], "atlasprm.old" );
      intermed := Filename( dirs[1], "atlasprm.new" );
      FileString( intermed, Concatenation( header, new, footer ) );
      Process( DirectoryCurrent(), mv, InputTextNone(), OutputTextNone(),
               [ tocfile, archfile ] );
      Process( DirectoryCurrent(), mv, InputTextNone(), OutputTextNone(),
               [ intermed, tocfile ] );

      # Print the differences between old and new version.
      str:= "";
      out:= OutputTextString( str, true );
      Process( DirectoryCurrent(), diff, InputTextNone(), out,
               [ archfile, tocfile ] );
      CloseStream( out );
      Info( InfoAtlasRep, 2,
            str );

    fi;
    end );


#############################################################################
##
#F  UpdateNewMagmaFormatFiles( <srcdir> )
##
##  This function lists the Magma format files on the server and compares
##  this with the list of corresponding &GAP; format files available.
##  Those Magma format files that are not yet available in the package
##  are transferred from the server to the directory <F>dev/magma</F>,
##  then they are translated via <F>etc/mtog</F>,
##  and the result is put into the directory <F>dev/gap0</F>.
##
##  The return value is the list of filenames of new Magma format files.
##
BindGlobal( "UpdateNewMagmaFormatFiles", function( srcdir )
    local datestring, serverfiles, gapfiles, i, len, diffs, name,
          filename, file1, file2, types, mv, mtog, diff, magmadirs, archive,
          nameformat, dircurr, triple, namedat, localfile, archivefile,
          parsed, type, outfile, pos, str, out;

    datestring:= CurrentDateTimeString( [ "-u", "+%Y-%m-%d-%H-%M" ] );

    # Get the list of Magma format files that are available on the server.
    # (Note that here only the `.M' files are considered,
    # and the type definitions cover the suffixes `.g' and `.M'.)
    serverfiles:= AGR_SpecialFormatFiles( srcdir, [ "mag" ] );

    # Get the list of corresponding GAP format files on the server.
    gapfiles:= List( AGR_SpecialFormatFiles( srcdir, [ "gap0" ] ),
                     x -> x[4] );
    for i in [ 1 .. Length( gapfiles ) ] do
      len:= Length( gapfiles[i] );
      if 2 < len and gapfiles[i]{ [ len-1 .. len ] } = ".g" then
        gapfiles[i][ len ]:= 'M';
      fi;
    od;

    # Get the names of Magma format files that are not (yet) available
    # *on the server* in GAP format,
    # and those names for which the GAP format on the server
    # differs from the local one.
    diffs:= [];
    srcdir:= Directory( srcdir );
    for name in serverfiles do
      if not name[4] in gapfiles then
        Add( diffs, name[4] );
      else
        filename:= ShallowCopy( name[4] );
        filename[ Length( filename ) ]:= 'g';
        file1:= Filename( srcdir,
                    Concatenation( name[1], "/", name[2], "/", filename ) );
        file2:= Filename( DirectoriesPackageLibrary( "atlasrep",
                              "datagens" ), filename );
#T this can be fail! (file available on server but not local!)
        if StringFile( file1 ) <> StringFile( file2 ) then
          Add( diffs, name[4] );
        fi;
      fi;
    od;

    # Take only those names that match one of the formats
    # `matmodn', `matalg', `matint'.
    types:= Filtered( AGRDataTypes( "rep" ),
                pair -> pair[1] in [ "matmodn", "matalg", "matint" ] );
    diffs:= Filtered( diffs,
                name -> ForAny( types,
                            type -> AGRParseFilenameFormat( name,
                                        type[2].FilenameFormat ) <> fail ) );

    # Get the necessary executables.
    mv:= Filename( DirectoriesSystemPrograms(), "mv" );
    if mv = fail or not IsExecutableFile( mv ) then
      Info( InfoWarning, 1,
            "Package `atlasrep':",
            "  The system program `mv' is not executable." );
      return fail;
    fi;

    mtog:= Filename( DirectoriesPackageLibrary( "atlasrep", "etc" ),
                     "mtog" );
    if mtog = fail or not IsExecutableFile( mtog ) then
      Info( InfoAtlasRep, 1, "no script `etc/mtog' found" );
      return fail;
    fi;

    diff:= Filename( DirectoriesSystemPrograms(), "diff" );
    if diff = fail or not IsExecutableFile( diff ) then
      Info( InfoAtlasRep, 1, "no executable `diff' found" );
      return fail;
    fi;

    magmadirs:= DirectoriesPackageLibrary( "atlasrep", "dev/magma" );
    archive:= DirectoriesPackageLibrary( "atlasrep", "dev/archive" );

    # This is used for extracting the group name.
    nameformat:= [ [ IsChar, "G", IsDigitChar ], [ IsChar, ".M" ] ];
    dircurr:= DirectoryCurrent();

    for name in diffs do

      # Save the local Magma format files that have updated server versions
      # into the `archive' directory.
      namedat:= Concatenation( name, "_", datestring );
      localfile:= Filename( magmadirs[1], name );
      if IsExistingFile( localfile ) then
        Print( "#I  saving file `", name, "' in `dev/archive/", namedat,
               "',\n" );
        archivefile:= Filename( archive[1], namedat );
        Process( dircurr, mv, InputTextNone(), OutputTextNone(),
                 [ localfile, archivefile ] );
      else
        Info( InfoAtlasRep, 2,
              "for file `", name,
              "' no earlier version was available in `dev/magma'" );
        archivefile:= fail;
      fi;

      # Transfer those Magma format files to `dev/magma' that are not yet
      # available in {\GAP} format or whose server version is newer,
      # and try to translate them to {\GAP} format.

      # Get the group name.
      parsed:= AGRParseFilenameFormat( name, nameformat );

      # Get the file.
      for type in AGRDataTypes( "rep" ) do
        if AGRParseFilenameFormat( filename, type[2].FilenameFormat )
               <> fail then
          filename:= AtlasOfGroupRepresentationsLocalFilenameTransfer(
                         "datagens", parsed[1], name, type );
          if filename <> fail then
            break;
          fi;
        fi;
      od;
      if filename = fail then
        Info( InfoAtlasRep, 2,
              "did not succeed to transfer `", name, "'" );
      else

        filename:= filename[1];

        # Move the file to the right directory.
        Process( dircurr, mv, InputTextNone(), OutputTextNone(),
                 [ filename, localfile ] );

        # Try to translate the Magma file to {\GAP} format.
        outfile:= ShallowCopy( localfile );
        outfile[ Length( outfile ) ]:= 'g';
        pos:= PositionSublist( outfile, "magma" );
        outfile:= Concatenation( outfile{ [ 1 .. pos-1 ] }, "gap0",
                                 outfile{ [ pos+5 .. Length( outfile )-1 ] },
                                 "g" );
        Info( InfoAtlasRep, 2,
              "calling `etc/mtog' for file `", localfile, "'" );
        Process( dircurr, mtog, InputTextNone(), OutputTextNone(),
                 [ localfile, outfile ] );
        if IsExistingFile( outfile ) <> true then
          Info( InfoAtlasRep, 2,
                "translation of `", filename, "' with `etc/mtog' failed" );
        fi;

        # Print the diffs between the versions of the Magma format file.
        if archivefile <> fail and IsExistingFile( archivefile ) then
          Info( InfoAtlasRep, 2,
                "update of file `", name, "', here are the differences:" );
          str:= "";
          out:= OutputTextString( str, true );
          Process( dircurr, diff, InputTextNone(), out,
                   [ archivefile, localfile ] );
          CloseStream( out );
          Info( InfoAtlasRep, 2,
                str );
        fi;

      fi;

    od;

    return diffs;
    end );


#############################################################################
##
#F  TestAfterMTOG( <filenames> )
##
##  Let <filenames> be a list of names of Magma format files for which &GAP;
##  readable versions have been produced by the script <F>etc/mtog</F>.
##  <C>TestAfterMTOG</C> reads the &GAP; equivalents of these files,
##  and then performs the following tests:
##  The generators are matrices of the same dimension, the invariant forms
##  are really invariant, and the generators of the centralizer algebra
##  really centralize.
##
BindGlobal( "TestAfterMTOG", function( filenames )
    local cnj, dirs, filename, gapfile, record, dim, compname, form, cen;

    cnj:= mat -> List( mat, row -> List( row, ComplexConjugate ) );
    dirs:= DirectoriesPackageLibrary( "atlasrep", "dev/gap0" );

    for filename in filenames do

      # Construct the name of the {\GAP} readable file.
      gapfile:= ShallowCopy( filename );
      gapfile[ Length( gapfile ) ]:= 'g';
      gapfile:= Filename( dirs, gapfile );

      # Try to read the file.
      record:= ReadAsFunction( gapfile );
      if IsFunction( record ) then
        record:= record();

        # Check that all matrices and forms have the same dimension.
        dim:= Length( record.generators[1] );
        if ForAny( record.generators,
               m -> not IsMatrix( m ) or Length( m ) <> dim
                                      or Length( m[1] ) <> dim ) then
          Print( "#E  wrong format of generator in `", filename, "'\n" );
        fi;

        # Check that the forms are nondegenerate and really invariant.
        for compname in [ "symmetricforms", "antisymmetricforms",
                          "hermitianforms" ] do
          for form in record.( compname ) do
            if Length( form ) <> dim or Length( form[1] ) <> dim
                                  or not IsMatrix( form ) then
              Print( "#E  wrong format of form in `", filename, "'\n" );
            fi;
            if compname = "hermitianforms" then
              if ForAny( record.generators,
                     m -> m * form * cnj( TransposedMat( m ) ) <> form ) then
                Print( "#E  problem for `", filename, "' in `", compname,
                       "': not invariant\n" );
              fi;
            else
              if ForAny( record.generators,
                     m -> m * form * TransposedMat( m ) <> form ) then
                Print( "#E  problem for `", filename, "' in `", compname,
                       "': not invariant\n" );
              fi;
            fi;
          od;
        od;

        # Check that the centralizer algebra really centralizes.
        for cen in record.centralizeralgebra do
          if ForAny( record.generators,
                     m -> m * cen <> cen * m ) then
            Print( "#E  problem for `", filename,
                   "' in `centralizeralgebra'\n" );
          fi;
        od;

      else
        Print( "#E  file `", filename, "' does not evaluate to function\n" );
      fi;

    od;
    end );


#############################################################################
##
#F  CompareFilesInDatagensAndDev()
##
##  This function lists the files in the directory <F>dev/gap0</F>,
##  and compares the files with the corresponding ones in <F>datagens</F>.
##  Where differences are detected, a message is printed.
##
BindGlobal( "CompareFilesInDatagensAndDev", function()
    local dir, datagens, name, file1, file2;

    # Loop over the files in `dev/gap0'.
    dir:= DirectoriesPackageLibrary( "atlasrep", "dev/gap0" );
    datagens:= DirectoriesPackageLibrary( "atlasrep", "datagens" );
    for name in DirectoryContents(
                    Filename( DirectoriesPackageLibrary( "atlasrep",
                                           "dev" ), "gap0" ) ) do
      file1:= Filename( datagens, name );
      if file1 = fail then
        Info( InfoAtlasRep, 2,
              "`", name, "' is in `dev/gap0' but not in `datagens'" );
      else
        file2:= Filename( dir, name );
        if StringFile( file1 ) <> StringFile( file2 ) then
          Info( InfoAtlasRep, 1,
                "versions of `", name,
                "' in `dev/gap0' and `datagens' differ" );
        fi;
      fi;
    od;
    end );


#############################################################################
##
#F  AGRTestCompareMTXBinariesAndTextFiles( <srcdir> )
##
BindGlobal( "AGRTestCompareMTXBinariesAndTextFiles", function( srcdir )
    local txt2bin, txt2gap, bin2txt, gap2txt, binnames, txtnames, gapnames,
          result, dir, rplnames, diff, name, txt, bin, gap;

    txt2bin:= txtname -> ReplacedString(
                             ReplacedString( txtname, ".m", ".b" ),
                             "/mtx/", "/bin/" );

    txt2gap:= txtname -> ReplacedString(
                             ReplacedString( txtname, ".m", ".g" ),
                             "/mtx/", "/gap/" );

    bin2txt:= binname -> ReplacedString(
                             ReplacedString( binname, ".b", ".m" ),
                             "/bin/", "/mtx/" );

    gap2txt:= gapname -> ReplacedString(
                             ReplacedString( gapname, ".g", ".m" ),
                             "/gap/", "/mtx/" );

    binnames:= List( AGR_SpecialFormatFiles( srcdir, [ "bin" ] ),
                     l -> JoinStringsWithSeparator( l, "/" ) );
    txtnames:= List( AGR_SpecialFormatFiles( srcdir, [ "mtx" ] ),
                     l -> JoinStringsWithSeparator( l, "/" ) );
    gapnames:= List( AGR_SpecialFormatFiles( srcdir, [ "gap" ] ),
                     l -> JoinStringsWithSeparator( l, "/" ) );

    result:= true;
    dir:= Directory( srcdir );

    # Compare the directory contents (bin vs. mtx).
    rplnames:= List( binnames, bin2txt );
    diff:= Difference( txtnames, rplnames );
    if not IsEmpty( diff ) then
      Print( "#E  as text files but not as binary files:\n",
             "\"", JoinStringsWithSeparator( diff, "\n\"" ), "\"\n" );
      result:= false;
    fi;
    diff:= Difference( rplnames, txtnames );
    if not IsEmpty( diff ) then
      Print( "#E  as binary files but not as text files:\n",
             "\"", JoinStringsWithSeparator( List( diff, txt2bin ), "\n\"" ),
             "\"\n" );
      result:= false;
    fi;

    # Compare the file contents.
    for name in Intersection( txtnames, rplnames ) do
      txt:= ScanMeatAxeFile( Filename( dir, name ) );
      bin:= FFMatOrPermCMtxBinary( Filename( dir, txt2bin( name ) ) );
      if txt <> bin then
        Print( "#E  binary file and text file differ: ", name, "\n" );
        result:= false;
      fi;
    od;

    # Compare the directory contents (gap vs. mtx).
    rplnames:= List( gapnames, gap2txt );
    diff:= Difference( txtnames, rplnames );
    if not IsEmpty( diff ) then
      Print( "#E  as text files but not as GAP files:\n",
             "\"", JoinStringsWithSeparator( diff, "\n\"" ), "\"\n" );
      result:= false;
    fi;
    diff:= Difference( rplnames, txtnames );
    if not IsEmpty( diff ) then
      Print( "#E  as GAP files but not as text files:\n",
             "\"", JoinStringsWithSeparator( List( diff, txt2gap ), "\n\"" ),
             "\"\n" );
      result:= false;
    fi;

    # Compare the file contents.
    for name in Intersection( txtnames, rplnames ) do
      txt:= ScanMeatAxeFile( Filename( dir, name ) );
      gap:= ReadAsFunction( Filename( dir, txt2gap( name ) ) );
      if txt <> gap() then
        Print( "#E  GAP file and text file differ: ", name, "\n" );
        result:= false;
      fi;
    od;

    return result;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsUpdateChangesFile( <todo> )
##
##  extends the table of updates/removals in the package file
##  <F>htm/data/changes.htm</F> by new rows.
##  The argument <A>todo</A> must be a list of length two,
##  as returned by <Ref Function="RecomputeAtlasTableOfContents"/>.
##  (The first entry is a list of (lists of) filenames of removed files,
##  the second entry is a list of filenames of updates files.)
##
BindGlobal( "AtlasOfGroupRepresentationsUpdateChangesFile", function( todo )
    local currdate, currdateint, rows, pair, date, pos, docstring, entry,
          changes, filename, filestr, pos1, pos2, mv, archivefilename, diff,
          str, out;

    currdate:= CurrentDateTimeString();
    currdate:= currdate{ [ 1 .. Position( currdate, ',' )-1 ] };
    currdateint:= CurrentDateTimeString( [ "+%s" ] );

    # information about removed files
    rows:= Concatenation( Filtered( todo[1], x -> not IsString( x ) ) );
    Append( rows, Filtered( todo[1], IsString ) );
    Sort( rows );
    rows:= List( rows, name -> [ currdate, name, "removed", currdateint ] );

    # information about changed files
    # (the 2nd entry is the server date of the updated file)
    for pair in todo[2] do
      date:= pair[2];
      Add( rows, [ StringDate( Int( Int( date ) / 86400 ) ), pair[1],
                   "updated", date ] );
    od;

    if IsEmpty( rows ) then
      return;
    fi;

    # Sort the rows by date.
    SortParallel( List( rows, x -> Int( x[4] ) ), rows );

    # Turn the rows into text.
    docstring:= Concatenation( List( rows,
        entry -> Concatenation( "<tr><td>", entry[1], "</td><td>",
                                entry[2], "</td><td>", entry[3],
                                "</td></tr><!-- ", entry[4], " -->\n" ) ) );

    # There were changes, update the HTML file.
    changes:= "htm/data/changes.htm";
    filename:= Filename( DirectoriesPackageLibrary( "atlasrep",
                             "htm/data" )[1],
                         "changes.htm" );
    filestr:= StringFile( filename );
    if filestr = fail then
      Print( "#E  no file `", changes, "' found!\n" );
      return;
    fi;

    # Cut the file at the place where the new lines have to be added.
    pos:= PositionSublist( filestr, "<!-- ==== add new lines here" );
    if pos = fail then
      Print( "#E  no comment line for new lines in `", changes, "'!\n" );
      return;
    fi;

    filestr:= Concatenation( filestr{ [ 1 .. pos-1 ] },
                  "<!-- ", ListWithIdenticalEntries( 67, '=' ), " -->\n",
                  docstring,
                  filestr{ [ pos .. Length( filestr ) ] } );

    # Adjust also the ``last modified'' line.
    pos1:= PositionSublist( filestr, "Last modified on " );
    pos2:= PositionSublist( filestr, " by ", pos1 );
    if pos1 = fail or pos2 = fail then
      Print( "#E  no ``last modified'' line in `", changes, "'!\n" );
      return;
    fi;
    filestr:= Concatenation( filestr{ [ 1 .. pos1 + 16 ] },
                             currdate,
                             filestr{ [ pos2 .. Length( filestr ) ] } );

    # Replace the old version by the updated one.
    mv:= Filename( DirectoriesSystemPrograms(), "mv" );
    if mv = fail or not IsExecutableFile( mv ) then
      Print( "#E  no executable `mv' found\n" );
      return;
    fi;
    archivefilename:= Concatenation( filename, ".old" );
    Process( DirectoryCurrent(), mv, InputTextNone(), OutputTextNone(),
             [ filename, archivefilename ] );

    FileString( filename, filestr );

    # Print differences of the two files.
    diff:= Filename( DirectoriesSystemPrograms(), "diff" );
    if diff = fail or not IsExecutableFile( diff ) then
      Print( "#E  no executable `diff' found\n" );
      return;
    fi;
    str:= "";
    out:= OutputTextString( str, true );
    Process( DirectoryCurrent(), diff, InputTextNone(), out,
                   [ archivefilename, filename ] );
    CloseStream( out );
    Print( str, "\n" );
    end );


#############################################################################
##
#F  AtlasRepCleanedGroupName( <name> )
##
##  Replace backslash and colon, as `Filename' does not accept them.
##
BindGlobal( "AtlasRepCleanedGroupName",
    name -> JoinStringsWithSeparator( SplitString( name, ":\\" ), "." ) );


#############################################################################
##
#F  AtlasRepCreateHTMLInfoForGroup( <name> )
##
BindGlobal( "AtlasRepCreateHTMLInfoForGroup", function( name )
    local tocs, str, dirinfo, link, info, list, entry;

    tocs:= [ AtlasTableOfContents( "remote" ).TableOfContents ];

    # Create the file header.
    str:= HTMLHeader( "GAP Package AtlasRep",
                      "../../atlasrep.css",
                      Concatenation( "<a href=\"../../index.html\">",
                          "GAP Package AtlasRep</a>" ),
                      Concatenation( "AtlasRep Info for ",
                                     DecMatName( name[1], "HTML" ) ) );

    Append( str, "<dl>\n" );

    # Append the links to the overview
    # and to the page for this group in the ATLAS database.
    Append( str, "<dt>\n" );
    dirinfo:= First( AtlasOfGroupRepresentationsInfo.groupnames,
                     x -> x[3] = name[2] );
    link:= Concatenation( "http://",
               AtlasOfGroupRepresentationsInfo.servers[1][1], "/",
               AtlasOfGroupRepresentationsInfo.servers[1][2],
               dirinfo[1], "/", dirinfo[2], "/" );
    Append( str, Concatenation( "<a href=\"", link,
                     "\">-> ATLAS page for ", DecMatName( name[1], "HTML" ),
                     "</a>\n" ) );
    Append( str, "</dt>\n" );
    Append( str, "<dt>\n" );
    Append( str, Concatenation( "<a href=\"overview.htm\">",
                     "-> Overview of Groups</a>\n" ) );
    Append( str, "</dt>\n" );

    # Append the information about representations.
    info:= AtlasOfGroupRepresentationsInfoGroup( [ name[1] ] );

    if not IsEmpty( info.list ) then
      Append( str, "<dt>\n" );
      Append( str, Concatenation(
                       info.header[1], DecMatName( info.header[2], "HTML" ) ) );
      Append( str, Concatenation(
                       info.header{ [ 3 .. Length( info.header ) ] } ) );
      Append( str, "\n" );
      Append( str, "</dt>\n" );
      Append( str, "<dd>\n" );

      list:= [];
      for entry in info.list do
        if entry[2][2] <> AtlasOfGroupRepresentationsInfo.markprivate then
          entry[2][1]:= ReplacedString( entry[2][1], "<=", HTMLGlobals.leq );
          if 4 <= Length( entry[2] ) then
            entry[2][4]:= DecMatName2( entry[2][4], "HTML" );
          fi;
          Add( list, [ entry[1], entry[2][1],
               Concatenation( entry[2]{ [ 2 .. Length( entry[2] ) ] } ) ] );
        fi;
      od;
      Append( str, HTMLStandardTable( fail, list,
                                      "datatable",
                                      [ "pright", "pleft", "pleft" ] ) );
      Append( str, "</dd>\n" );
    fi;

    # Append the information about programs.
    info:= AtlasOfGroupRepresentationsInfoPRG( name[1], tocs, name[2],
               true );
    if not IsEmpty( info.list ) then
      Append( str, "<dt>\n" );
      Append( str, Concatenation(
                       info.header[1], DecMatName( info.header[2], "HTML" ) ) );
      Append( str, Concatenation(
                       info.header{ [ 3 .. Length( info.header ) ] } ) );
      Append( str, "\n" );
      Append( str, "</dt>\n" );
      Append( str, "<dd>\n" );
      Append( str, HTMLStandardTable( fail, List( info.list, x -> [ x ] ),
                                      "datatable",
                                      [ "pleft" ] ) );
      Append( str, "</dd>\n" );
      Append( str, "\n" );
    fi;

    Append( str, "</dl>" );

    # Append the footer string.
    Append( str, HTMLFooter() );

    # Create the file.
    info:= PrintToIfChanged( Concatenation(
               AtlasRepCleanedGroupName( name[1] ), ".htm" ), str );
    if info{ [ 1 .. 9 ] } <> "unchanged" then
      Print( "#I  ", info, "\n" );
    fi;
    end );


#############################################################################
##
#F  AtlasRepCreateHTMLOverview()
##
#T  This is currently copied from `DisplayAtlasInfoOverview';
#T  eventually this should be handled via `DisplayStringLabelledMatrix'.
##
BindGlobal( "AtlasRepCreateHTMLOverview", function()
    local tocs,
          gapnames,
          groupnames,
          columns,
          active,
          str,
          matrix,
          alignments,
          row,
          i, j,
          info,
          dir,
          name;

    tocs:= [ AtlasTableOfContents( "remote" ).TableOfContents ];

    # Consider only those names for which actually information is available.
    gapnames:= Filtered( AtlasOfGroupRepresentationsInfo.GAPnames,
                   x -> ForAny( tocs, toc -> IsBound( toc.( x[2] ) ) ) );

    # Construct the links for the names.
    groupnames:= List( gapnames,
                       x -> Concatenation( "<a href=\"",
                                AtlasRepCleanedGroupName( x[1] ), ".htm\">",
                                DecMatName( x[1], "HTML" ), "</a>" ) );
#T generalize the function `NameWithLink' from `ctbltoc',
#T and use it here!

    # Compute the data of the columns.
    columns:= [ [ "group", "l", groupnames ] ];

    Append( columns, List( AGRDataTypes( "rep", "prg" ),
                    type ->
           [ type[2].DisplayOverviewInfo[1],
             type[2].DisplayOverviewInfo[2],
             List( gapnames,
                   n -> type[2].DisplayOverviewInfo[3]( tocs, n[2] )[1] ) ] ) );
    active:= Filtered( [ 1 .. Length( columns ) ],
                 i -> not IsEmpty( columns[i][1] ) );

    # Create the file header.
    str:= HTMLHeader( "GAP Package AtlasRep",
                      "../../atlasrep.css",
                      Concatenation( "<a href=\"../../index.html\">",
                          "GAP Package AtlasRep</a>" ),
                      "Available via the GAP Interface" );

    # Insert the explanatory text.
    Append( str, StringFile( Filename(
        DirectoriesPackageLibrary( "atlasrep", "dev" ),
                                 "overviewtxt.htm" ) ) );

    matrix:= [ [] ];
    alignments:= [];

    # Add the table header line.
    for j in active do
      if columns[j][2] = "l" then
        Add( alignments, "tdleft" );
      else
        Add( alignments, "tdright" );
      fi;
      Add( matrix[1], columns[j][1] );
    od;

    # Collect the information for each group.
    for i in [ 1 .. Length( gapnames ) ] do
      row:= [];
      Add( matrix, row );
      for j in active do
        Add( row, columns[j][3][i] );
      od;

      # Create the file for this group.
      AtlasRepCreateHTMLInfoForGroup( gapnames[i] );
    od;

    Append( str, HTMLStandardTable( fail, matrix, "datatable", alignments ) );

    # Append the footer string.
    Append( str, HTMLFooter() );

    # Create the file.
    info:= PrintToIfChanged( "overview.htm", str );
    if info{ [ 1 .. 9 ] } <> "unchanged" then
      Print( "#I  ", info, "\n" );
    fi;

    # Finally, report about HTML files that should be removed.

    # List the files in `toc'.
    dir:= Filename( DirectoriesPackageLibrary( "atlasrep", "htm/data" ), "" );
    str:= Difference( DirectoryContents( dir ), List( gapnames,
          x -> Concatenation( AtlasRepCleanedGroupName( x[1] ), ".htm" ) ) );
    SubtractSet( str, [ "CVS", "changes.htm", "changes.htm.old",
                        "overview.htm", ".", "..", ".cvsignore" ] );
    if not IsEmpty( str ) then
      Print( "#I  Remove the following files from `atlasrep/htm/data':\n" );
      for name in str do
        Print( "#I  ", name, "\n" );
      od;
    fi;
    end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsCreateDataArchive()
##
##  Collect all permutation representations up to degree 10000,
##  all matrix representations up to dimension 10,
##  and all scripts.
##  The archive is stored in the <F>pkg</F> directory of the &GAP;
##  installation (so it must be unpacked there) and is called
##  <F>atlasrepdata.tar.gz</F>.
##
BindGlobal( "AtlasOfGroupRepresentationsCreateDataArchive", function()
    local dir, tar, dstfile, filename, proc, gensinfo, r, id,
          files, absfilename, gzip;

    dir:= DirectoriesLibrary( "pkg" )[1];
    tar:= Filename( DirectoriesSystemPrograms(), "tar" );
    if tar = fail then
      Info( InfoAtlasRep, 1, "no `tar' executable found" );
      return false;
    fi;
    dstfile:= "atlasrepdata.tar";

    # Remove the old archive.
    filename:= Filename( dir, "atlasrepdata.tar.gz" );
    if IsExistingFile( filename ) then
      RemoveFile( filename );
    fi;

    # Create the new archive containing all files from `dataword'.
    proc:= Process( dir, tar,
               InputTextNone(), OutputTextNone(),
               [ "-cf", dstfile, "atlasrep/dataword/" ] );
    if proc = fail then
      Info( InfoAtlasRep, 2,
            "`tar' failed to create `", dstfile, "'" );
      return false;
    fi;

    # Add the selected files from `datagens'.
    gensinfo:= Concatenation(
        AllAtlasGeneratingSetInfos( NrMovedPoints, [ 1 .. 10^5 ] ),
        AllAtlasGeneratingSetInfos( Dimension, [ 1 .. 10 ] ) );
    for r in gensinfo do
      id:= r.identifier[2];
      if IsString( id ) then
        files:= [ id ];
      else
        files:= id;
      fi;
      for filename in files do
        absfilename:= Filename( dir,
            Concatenation( "atlasrep/datagens/", filename ) );
        if not IsExistingFile( absfilename ) then
          filename:= Concatenation( filename, ".gz" );
          absfilename:= Concatenation( absfilename, ".gz" );
        fi;
        if IsExistingFile( absfilename ) then
          proc:= Process( dir, tar,
                     InputTextNone(), OutputTextNone(),
                     [ "-rf", dstfile, Concatenation( "atlasrep/datagens/",
                                           filename ) ] );
          if proc = fail then
            Info( InfoAtlasRep, 2,
                  "`tar' failed to add `", filename, "'" );
            return false;
          fi;
        fi;
      od;
    od;

    # Compress the archive
    gzip:= Filename( DirectoriesSystemPrograms(), "gzip" );
    if gzip = fail or not IsExecutableFile( gzip ) then
      Info( InfoAtlasRep, 1, "no `gzip' executable found" );
      return false;
    else
      proc:= Process( dir, gzip,
                 InputTextNone(), OutputTextNone(), [ dstfile ] );
      if proc = fail then
        Info( InfoAtlasRep, 2,
              "impossible to compress file `", dstfile, "'" );
        return false;
      fi;
    fi;

    return true;
    end );


#############################################################################
##
#E

