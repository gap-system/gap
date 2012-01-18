#############################################################################
##
#W  access.gi            GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains functions for accessing data from the ATLAS of Group
##  Representations.
##


#############################################################################
##
#V  AGR.ExtensionInfoCharacterTable
#V  AGR.HasExtensionInfoCharacterTable
#V  AGR.LibInfoCharacterTable
##
if IsBound( ExtensionInfoCharacterTable ) then
  AGR.ExtensionInfoCharacterTable:= ExtensionInfoCharacterTable;
  AGR.HasExtensionInfoCharacterTable:= HasExtensionInfoCharacterTable;
  AGR.LibInfoCharacterTable:= LibInfoCharacterTable;
fi;


#############################################################################
##
#F  AGR.IsLowerAlphaOrDigitChar( <char> )
##
AGR.IsLowerAlphaOrDigitChar:= 
    char -> IsLowerAlphaChar( char ) or IsDigitChar( char );


#############################################################################
##
##  If the IO package is not installed then error messages are avoided
##  via the following assignments.
##
if not IsBound( SingleHTTPRequest ) then
  SingleHTTPRequest:= "dummy";
fi;
if not IsBound( IO_stat ) then
  IO_stat:= "dummy";
fi;



#############################################################################
##
#F  AtlasOfGroupRepresentationsTransferFile( <server>, <srvfile>, <dstfile> )
##
##  This function encapsulates the access to a file either via <C>wget</C>
##  or via the <Package>IO</Package> package
##  <Cite Key="IO"/><Index>IO package</Index>.
##  <P/>
##  The source file is described by the server name <A>server</A> and the
##  path <A>srvfile</A>.
##  The file is written to the filename <A>dstfile</A>.
##
##  <#GAPDoc Label="IO_or_wget">
##  When access to remote data is enabled
##  (see Section&nbsp;<Ref Subsect="subsect:Local or remote access"/>)
##  then one needs either the &GAP; package <Package>IO</Package>
##  <Cite Key="IO"/><Index>IO package</Index>
##  or the external program <F>wget</F><Index Key="wget"><F>wget</F></Index>
##  for accessing data files.
##  <P/>
##  The chosen alternative is given by the value of the <C>wget</C> component
##  of the global variable <Ref Var="AtlasOfGroupRepresentationsInfo"/>.
##  <P/>
##  If this component has the value <K>true</K> then only <F>wget</F>
##  is tried,
##  if the value is <K>false</K> then only the <Package>IO</Package> package
##  is used.
##  If this component is not bound or bound to another value than <K>true</K>
##  or <K>false</K> (this is also the default)
##  then the <Package>IO</Package> package <Index>IO package</Index>
##  is preferred to <F>wget</F><Index Key="wget"><F>wget</F></Index>
##  if this package is available, and otherwise <F>wget</F> is tried.
##  <P/>
##  Note that the system program <F>wget</F> may be not available,
##  and that it may require some work to install it;
##  hints for that can be found on the home page of the
##  <Package>AtlasRep</Package> package (see
##  Section&nbsp;<Ref Sect="sect:Web Services for the AtlasRep Package"/>).
##  <#/GAPDoc>
##
##  If the access worked then <K>true</K> is returned,
##  otherwise <K>false</K>.
##
BindGlobal( "AtlasOfGroupRepresentationsTransferFile",
    function( server, srvfile, dstfile )
    local wget, io, result;

    # Determine admissible alternatives.
    wget:= true;
    io:= true;
    if IsBound( AtlasOfGroupRepresentationsInfo.wget ) then
      if   AtlasOfGroupRepresentationsInfo.wget = true then
        io:= false;
      elif AtlasOfGroupRepresentationsInfo.wget = false then
        wget:= false;
      fi;
    fi;

    srvfile:= Concatenation( "/", srvfile);

    # Try the IO package if it is admissible.
    if io and LoadPackage( "io" ) = true then
      Info( InfoAtlasRep, 2,
            "calling SingleHTTPRequest to get ", server, srvfile );
      result:= SingleHTTPRequest( server, 80, "GET",
                   srvfile,
                   rec(), false, dstfile );
      if result.statuscode <> 200 then
        Info( InfoAtlasRep, 2,
              "SingleHTTPRequest failed with status\n#I  ", result.status );
      else
        return true;
      fi;
    fi;

    # Try wget if it is admissible.
    if wget then
      wget:= Filename( DirectoriesSystemPrograms(), "wget" );
      if wget = fail then
        Info( InfoAtlasRep, 1, "no `wget' executable found" );
      else
        Info( InfoAtlasRep, 2,
              "calling `wget' to get `", server, srvfile, "'" );
        result:= Process( DirectoryCurrent(), wget,
            InputTextNone(), OutputTextNone(),
            [ "-q", "-O", dstfile,
              Concatenation( "http://", server, srvfile ) ] );
        if result <> 0 then
          Info( InfoAtlasRep, 2,
                "`wget' failed to fetch `",
                Concatenation( "http://", server, srvfile ), "'" );
          RemoveFile( dstfile );
        else
          return true;
        fi;
      fi;
    fi;

    # No admissible alternative was successful.
    return false;
end );


#############################################################################
##
#V  AtlasOfGroupRepresentationsAccessFunctionsDefault
##
##  several functions may be provided; return value `fail' means that
##  the next function is tried, otherwise the result counts
##
InstallValue( AtlasOfGroupRepresentationsAccessFunctionsDefault, [
  rec(
    description:= "default functions (read text files)",

    active:= true,

    location:= function( filename, groupname, dirname, type )
      local datadirs, info, name, namegz, names, fname;

      if dirname in [ "datagens", "dataword" ] then
        datadirs:= DirectoriesPackageLibrary( "atlasrep", dirname );
      else
        for info in AtlasOfGroupRepresentationsInfo.private do
          if dirname = info[2] then
            datadirs:= [ Directory( info[1] ) ];
            break;
          fi;
        od;
        if not IsBound( datadirs ) then
          Error( "no private directory with identifier `", dirname, "'" );
        fi;
      fi;
      # There may be an uncompressed or a compressed version.
      # If both are available then prefer the uncompressed version.
      if IsString( filename ) then
        name:= Filename( datadirs, filename );
        if name = fail or not IsExistingFile( name ) then
          namegz:= Filename( datadirs, Concatenation( filename, ".gz" ) );
          if namegz = fail then
            # No version is available yet.
            return Filename( datadirs[1], filename );
          else
            return namegz;
          fi;
        else
          return name;
        fi;
      else
        # Treat the list entries separately.
        names:= [];
        for fname in filename do
          name:= Filename( datadirs, fname );
          if name = fail or not IsExistingFile( name ) then
            namegz:= Filename( datadirs, Concatenation( fname, ".gz" ) );
            if namegz = fail then
              # No version is available yet.
              Add( names, Filename( datadirs[1], fname ) );
            else
              Add( names, namegz );
            fi;
          else
            Add( names, name );
          fi;
        od;
        return names;
      fi;
    end,

    fetch:= function( filepath, filename, groupname, dirname, type )
      local triple, info, dirnam, result, gzip;

      # Get the group name info.
      triple:= First( AtlasOfGroupRepresentationsInfo.groupnames,
                      x -> x[3] = groupname );
      if triple = fail then
        Error( "illegal value of <groupname>" );
      fi;

      # Try to fetch the remote file.
      result:= fail;
      for info in AtlasOfGroupRepresentationsInfo.servers do

        dirnam:= Concatenation( info[2], triple[1], "/", triple[2] );

        # Compose the name of the directory on the server.
        if   dirname = "dataword" then
          Append( dirnam, "/words/" );
        elif filename[ Length( filename ) ] = 'g' then
          Append( dirnam, "/gap0/" );
        else
          Append( dirnam, "/mtx/" );
        fi;

        # Fetch the file if possible.
        result:= AtlasOfGroupRepresentationsTransferFile( info[1],
                     Concatenation( dirnam, filename ),
                     filepath );
        if result = false then
          Info( InfoAtlasRep, 2,
                "no connection to AtlasRep server ", info[1] );
        else
          break;
        fi;

      od;
      if result = false then
        Info( InfoAtlasRep, 1,
              "no file `", filename, "' found on the servers" );
        return false;
      fi;

      # The file has just been fetched, perform postprocessing.
      # (For MeatAxe format only: If wanted then compress the new file.)
      if     AtlasOfGroupRepresentationsInfo.compress = true
         and dirnam[ Length( dirnam ) - 1 ] = 'x' then
        gzip:= Filename( DirectoriesSystemPrograms(), "gzip" );
        if gzip = fail or not IsExecutableFile( gzip ) then
          Info( InfoAtlasRep, 1, "no `gzip' executable found" );
        else
          result:= Process( DirectoryCurrent(), gzip,
                       InputTextNone(), OutputTextNone(), [ filepath ] );
          if result = fail then
            Info( InfoAtlasRep, 2,
                  "impossible to compress file `", filepath, "'" );
          fi;
        fi;
      fi;

      return true;
    end,

    contents:= function( filepath, filename, groupname, dirname, type )
      local len, i;

      if IsString( filepath ) then
        len:= Length( filepath );
        if 3 < len and filepath{ [ len-2 .. len ] } = ".gz" then
          filepath:= filepath{ [ 1 .. len-3 ] };
        fi;
      else
        filepath:= ShallowCopy( filepath );
        for i in [ 1 .. Length( filepath ) ] do
          len:= Length( filepath[i] );
          if 3 < len and filepath[i]{ [ len-2 .. len ] } = ".gz" then
            filepath[i]:= filepath[i]{ [ 1 .. len-3 ] };
          fi;
        od;
      fi;
      return type[2].ReadAndInterpretDefault( filepath );
    end,
  ),

  rec(
    description:= "read MeatAxe binary not text format",

    active:= false,

    location:= function( filename, groupname, dirname, type )
      local datadirs, info, names, fname, name;

      if not type[1] in [ "perm", "matff" ] then
        return fail;
      fi;
      if dirname = "datagens" then
        datadirs:= DirectoriesPackageLibrary( "atlasrep", dirname );
      else
        for info in AtlasOfGroupRepresentationsInfo.private do
          if dirname = info[2] then
            datadirs:= [ Directory( info[1] ) ];
            break;
          fi;
        od;
        if not IsBound( datadirs ) then
          Error( "no private directory with identifier `", dirname, "'" );
        fi;
      fi;

      # A list of file names is given, and the files are not compressed.
      # Replace the text format names by binary format names.
      filename:= List( filename, nam -> ReplacedString( nam, ".m", ".b" ) );
      names:= [];
      for fname in filename do
        name:= Filename( datadirs, fname );
        if name = fail then
          # No version is available yet.
          Add( names, Filename( datadirs[1], fname ) );
        else
          Add( names, name );
        fi;
      od;
      return names;
    end,

    fetch:= function( filepath, filename, groupname, dirname, type )
      local triple, info, dirnam, result;

      # Get the group name info.
      triple:= First( AtlasOfGroupRepresentationsInfo.groupnames,
                      x -> x[3] = groupname );
      if triple = fail then
        Error( "illegal value of <groupname>" );
      fi;

      # Try to fetch the remote file.
      result:= fail;
      filename:= ReplacedString( filename, ".m", ".b" );
      for info in AtlasOfGroupRepresentationsInfo.servers do

        # Fetch the file if possible.
        result:= AtlasOfGroupRepresentationsTransferFile( info[1],
                     Concatenation( info[2], triple[1], "/", triple[2],
                                    "/bin/", filename ),
                     filepath );
        if result = false then
          Info( InfoAtlasRep, 2,
                "no connection to AtlasRep server ", info[1] );
        else
          break;
        fi;

      od;
      if result = false then
        Info( InfoAtlasRep, 1,
              "no file `", filename, "' found on the servers" );
        return false;
      fi;

      # (Do not compress the new file, it is in binary format.)
      return true;
    end,

    contents:= function( filepath, filename, groupname, dirname, type )
      # This function is called only for the types "perm" and "matff",
      # and binary format files are *not* compressed.
      return List( filepath, FFMatOrPermCMtxBinary );
    end,
  ),

#T The following is currently useless because of an unlucky files format.
#  rec(
#    description:= "read GAP format not MeatAxe format",
#
#    active:= false,
#
#    location:= function( filename, groupname, dirname, type )
#      local datadirs, info, names, fname, name;
#
#      # (Does the same as the `location' function for MeatAxe binary format,
#      # except that we replace the suffix of the filename by `.g' not `.b'.)
#      if not type[1] in [ "perm", "matff" ] then
#        return fail;
#      fi;
#      if dirname = "datagens" then
#        datadirs:= DirectoriesPackageLibrary( "atlasrep", dirname );
#      else
#        for info in AtlasOfGroupRepresentationsInfo.private do
#          if dirname = info[2] then
#            datadirs:= [ Directory( info[1] ) ];
#            break;
#          fi;
#        od;
#        if not IsBound( datadirs ) then
#          Error( "no private directory with identifier `", dirname, "'" );
#        fi;
#      fi;
#
#      # A list of file names is given, and the files are not compressed.
#      # Replace the text format names by binary format names.
#      filename:= List( filename, nam -> ReplacedString( nam, ".m", ".g" ) );
#      names:= [];
#      for fname in filename do
#        name:= Filename( datadirs, fname );
#        if name = fail then
#          # No version is available yet.
#          Add( names, Filename( datadirs[1], fname ) );
#        else
#          Add( names, name );
#        fi;
#      od;
#      return names;
## alternative for ONE file with SEVERAL generators:
##     # Replace the list of text format names by one GAP format name.
##     filename:= ReplacedString( filename[1], ".m1", ".g" );
##     name:= Filename( datadirs, filename );
##     if name = fail then
##       # No version is available yet.
##       return Filename( datadirs[1], filename );
##     else
##       return name;
##     fi;
#    end,
#
#    fetch:= function( filepath, filename, groupname, dirname, type )
#      local triple, info, dirnam, result;
#
#      # (Does the same as the `fetch' function for MeatAxe binary format,
#      # except that the source file is expected in `gap' not `bin'.)
#      # Get the group name info.
#      triple:= First( AtlasOfGroupRepresentationsInfo.groupnames,
#                      x -> x[3] = groupname );
#      if triple = fail then
#        Error( "illegal value of <groupname>" );
#      fi;
#
#      # Try to fetch the remote file.
#      result:= fail;
#      filename:= ReplacedString( filename, ".m", ".g" );
#      for info in AtlasOfGroupRepresentationsInfo.servers do
#
#        # Fetch the file if possible.
#        result:= AtlasOfGroupRepresentationsTransferFile( info[1],
#                     Concatenation( info[2], triple[1], "/", triple[2],
#                                    "/gap/", filename ),
#                     filepath );
#        if result = false then
#          Info( InfoAtlasRep, 2,
#                "no connection to AtlasRep server ", info[1] );
#        else
#          break;
#        fi;
#
#      od;
#      if result = false then
#        Info( InfoAtlasRep, 1,
#              "no file `", filename, "' found on the servers" );
#        return false;
#      fi;
#
#      # (Do not compress the new file, it is not in MeatAxe text format.)
#      return true;
#    end,
#
#    contents:= function( filepath, filename, groupname, dirname, type )
#      # This function is called only for the types "perm" and "matff",
#      # and GAP format files are *not* compressed.
#      return List( filepath, AtlasDataGAPFormatFile );
## alternative for ONE file with SEVERAL generators:
##     return AtlasDataGAPFormatFile( filepath );
#    end,
#  ),

  rec(
    description:= "direct access to a local server",

    active:= false,

    location:= function( filename, groupname, dirname, type )
      local triple, dirnam, name, names, fname;

      # This is meaningful only for official data
      # and if there is a local server.
      if not ( dirname in [ "datagens", "dataword" ] and
               IsBound( AtlasOfGroupRepresentationsInfo.localserver ) ) then
        return fail;
      fi;

      # Get the group name info.
      triple:= First( AtlasOfGroupRepresentationsInfo.groupnames,
                      x -> x[3] = groupname );
      if triple = fail then
        Error( "illegal value of <groupname>" );
      fi;

      # Compose the name of the directory on the server.
      dirnam:= Concatenation( AtlasOfGroupRepresentationsInfo.localserver,
                              triple[1], "/", triple[2] );
      if   dirname = "dataword" then
        Append( dirnam, "/words/" );
      elif filename[ Length( filename ) ] = 'g' then
        Append( dirnam, "/gap0/" );
      else
        Append( dirnam, "/mtx/" );
      fi;

      # Check whether the file(s) exist(s).
      if IsString( filename ) then
        name:= Concatenation( dirnam, filename );
        if IsExistingFile( name ) then
          return name;
        fi;
        return fail;
      else
        names:= [];
        for fname in filename do
          name:= Concatenation( dirnam, fname );
          if IsExistingFile( name ) then
            Add( names, name );
          else
            return fail;
          fi;
        od;
        return names;
      fi;
    end,

    fetch:= function( filepath, filename, groupname, dirname, type )
      # The `location' function has checked that the file exists.
      return true;
    end,

    contents:= function( filepath, filename, groupname, dirname, type )
      # We need not care about compressed files.
      return type[2].ReadAndInterpretDefault( filepath );
    end,
  ),
  ] );


#############################################################################
##
#F  AtlasOfGroupRepresentationsLocalFilename( <dirname>, <groupname>,
#F      <filename>, <type> )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsLocalFilename,
    function( dirname, groupname, filename, type )
    local cand, r, path;

    cand:= [];
    for r in Reversed( AtlasOfGroupRepresentationsInfo.accessFunctions ) do
      if r.active = true then
        path:= r.location( filename, groupname, dirname, type );
        if path <> fail then
          if IsString( path ) then
            path:= [ path ];
          fi;
          if ForAll( path, IsExistingFile ) then
            # This has priority, do not consider other sources.
            cand:= [ [ r, List( path, x -> [ x, true ] ) ] ];
            break;
          else
            Add( cand, [ r, List( path, x -> [ x, IsExistingFile( x ) ] ) ] );
          fi;
        fi;
      fi;
    od;
    return cand;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsLocalFilenameTransfer( <dirname>, <groupname>,
#F      <filename>, <type> )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsLocalFilenameTransfer,
    function( dirname, groupname, filename, type )
    local cand, list;

    # 1. Determine the local directory where to look for the file,
    #    and the functions that claim to be applicable.
    cand:= AtlasOfGroupRepresentationsLocalFilename( dirname, groupname,
               filename, type );

    if not IsEmpty( cand ) then
      # 2. Check whether the file is already stored.
      #    If not and if it is not private and if remote access is allowed
      #    then try to transfer it.
      if   ForAll( cand[1][2], x -> x[2] ) then
        # 3. We have the local file(s).  Return path(s) and access functions.
        if IsString( filename )  then
          return [ cand[1][2][1][1], cand[1][1] ];
        else
          return [ List( cand[1][2], x -> x[1] ), cand[1][1] ];
        fi;
      elif AtlasOfGroupRepresentationsInfo.remote = true
           and dirname in [ "datagens", "dataword" ] then
        # Try to fetch the remote file(s) from the servers,
        # using the applicable methods.
        for list in cand do
          if   IsString( filename ) and Length( list[2] ) = 1
               and ( list[2][1][2] or list[1].fetch( list[2][1][1], filename,
                                        groupname, dirname, type ) ) then
            # 3. We have the local file.
            #    Return path and access functions.
            return [ list[2][1][1], list[1] ];
          elif not IsString( filename )
               and Length( list[2] ) = Length( filename )
               and ForAll( [ 1 .. Length( list[2] ) ],
                     i -> list[2][i][2] or list[1].fetch( list[2][i][1],
                              filename[i], groupname, dirname, type ) ) then
            # 3. We have the local file(s).
            #    Return path(s) and access functions.
            return [ List( list[2], x -> x[1] ), list[1] ];
          fi;
        od;
      fi;
    fi;

    # The file cannot be made available.
    Info( InfoAtlasRep, 1,
          "no file(s) `", filename, "' found in the local directories" );
    return fail;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsTestTableOfContentsRemoteUpdates()
##
InstallGlobalFunction(
    AtlasOfGroupRepresentationsTestTableOfContentsRemoteUpdates, function()

    local version, inforec, home, server, path, dstfilename, result, lines,
          datadirs, line, pos, pos2, filename, localfile, servdate, stat;

    if LoadPackage( "io" ) <> true then
      Info( InfoAtlasRep, 1, "the package IO is not available" );
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


#############################################################################
##
#F  AGR.FileContents( <dirname>, <groupname>, <filename>, <type> )
##
AGR.FileContents:= function( dirname, groupname, filename, type )
    local result;

    if not ( IsString( filename ) or
             ( IsList( filename ) and ForAll( filename, IsString ) ) ) then
      Error( "<file> must be a string or a list of strings" );
    fi;

    result:= AtlasOfGroupRepresentationsLocalFilenameTransfer( dirname,
                 groupname, filename, type );
    if result = fail then
      return fail;
    fi;

    # 3. We have the local file(s).  Try to extract the contents.
    return result[2].contents( result[1], filename, groupname, dirname, type );
    end;


#############################################################################
##
#F  FilenameAtlas( <dirname>, <groupname>, <filename> )
##
InstallGlobalFunction( FilenameAtlas,
    function( dirname, groupname, filename )
    local type;

    if not IsBound( AtlasOfGroupRepresentationsInfo.WarnedFilenameAtlas ) then
      AtlasOfGroupRepresentationsInfo.WarnedFilenameAtlas:= true;
      Info( InfoWarning, 1,
            "FilenameAtlas is deprecated,\n#I  use ",
            "`AtlasOfGroupRepresentationsLocalFilenameTransfer' instead" );
    fi;
    for type in AGR.DataTypes( "rep", "prg" ) do
      if AGR.ParseFilenameFormat( filename, type[2].FilenameFormat )
             <> fail then
        return AtlasOfGroupRepresentationsLocalFilenameTransfer( dirname,
                   groupname, filename, type )[1];
      fi;
    od;
    return fail;
end );


#############################################################################
##
#F  AGR.InfoForName( <gapname> )
##
AGR.InfoForName:= function( gapname )
    local pos;

    gapname:= AGR.GAPName( gapname );
    pos:= PositionSorted( AtlasOfGroupRepresentationsInfo.GAPnames,
                          [ gapname ] );
    if pos <= Length( AtlasOfGroupRepresentationsInfo.GAPnames ) and
       AtlasOfGroupRepresentationsInfo.GAPnames[ pos ][1] = gapname then
      return AtlasOfGroupRepresentationsInfo.GAPnames[ pos ];
    else
      return fail;
    fi;
    end;


#############################################################################
##
##  auxiliary function
##
AGR.TST:= function( gapname, value, compname, testfun, msg )
    if not IsBound( AGR.GAPnamesRec.( gapname ) ) then
      Error( "AGR.GAPnamesRec.( \"", gapname, "\" ) is not bound" );
    elif not IsBound( AGR.GAPnamesRec.( gapname )[3] ) then
      Error( "AGR.GAPnamesRec.( \"", gapname, "\" )[3] is not bound" );
    elif IsBound( AGR.GAPnamesRec.( gapname )[3].( compname ) ) then
      Error( "AGR.GAPnamesRec.( \"", gapname, "\" )[3].", compname,
             " is bound" );
    elif not testfun( value ) then
      Error( "<", compname, "> must be a ", msg );
    fi;
    end;


#############################################################################
##
#F  AGR.IsRepNameAvailable( <repname> )
##
##  If `AtlasOfGroupRepresentationsInfo.checkData' is bound then this
##  function is called when additional data are added that refer to the
##  representation <repname>.
##
AGR.IsRepNameAvailable:= function( repname )
    local filenames, type, parsed, groupname, gapname;

    filenames:= [ Concatenation( repname, ".m1" ),
                  Concatenation( repname, ".g" ) ];
    for type in AGR.DataTypes( "rep" ) do
      parsed:= List( filenames,
          x -> AGR.ParseFilenameFormat( x, type[2].FilenameFormat ) );
      if ForAny( parsed, IsList ) then
        break;
      fi;
    od;
    if ForAll( parsed, IsBool ) then
      Print( "#E  wrong format of `", repname, "'\n" );
      return false;
    fi;
    groupname:= First( parsed, IsList )[1];
    gapname:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                     pair -> pair[2] = groupname );
    if gapname = fail then
      Print( "#E  no group name `", groupname, "' for `", repname, "'\n" );
      return false;
    elif ForAll( AllAtlasGeneratingSetInfos( gapname[1] ),
                 x -> x.repname <> repname ) then
      Print( "#E  no representation `", repname, "' available\n" );
      return false;
    fi;

    return true;
    end;


#############################################################################
##
#F  AGR.IsPrgNameAvailable( <prgname> )
##
##  If `AtlasOfGroupRepresentationsInfo.checkData' is bound then this
##  function is called when additional data are added that refer to the
##  program <prgname>.
##
AGR.IsPrgNameAvailable:= function( prgname )
    local type, parsed, groupname;

    for type in AGR.DataTypes( "prg" ) do
      parsed:= AGR.ParseFilenameFormat( prgname, type[2].FilenameFormat );
      if IsList( parsed ) then
        break;
      fi;
    od;
    if parsed = fail then
      Print( "#E  wrong format of `", prgname, "'\n" );
      return false;
    fi;
    groupname:= parsed[1];
    if ForAny( AGR.TablesOfContents( "all" ),
           toc -> IsBound( toc.( groupname ) ) and
                  ForAny( RecNames( toc.( groupname ) ),
                      nam -> ForAny( toc.( groupname ).( nam ),
                                 l -> l[ Length( l ) ] = prgname ) ) ) then
      return true;
    else
      Print( "#E  no program `", prgname, "' available\n" );
      return false;
    fi;
    end;


#############################################################################
##
#V  AGR.MapNameToGAPName
#F  AGR.GAPName( <name> )
##
##  Let <name> be a string.
##  If `LowercaseString( <name> )' is the lower case version of the GAP name
##  of an ATLAS group then `AGR.GAPName' returns this GAP name.
##  If <name> is an admissible name of a GAP character table with identifier
##  <id> (this condition is already case insensitive) then `AGR.GAPName'
##  returns `AGR.GAPName( <id> )'.
##
##  These two conditions are forced to be consistent, as follows.
##  Whenever a GAP name <nam>, say, of an ATLAS group is notified with
##  `AGR.GNAN', we compute `LibInfoCharacterTable( <nam> )'.
##  If this is `fail' then there is no danger of an inconsistency,
##  and if the result is a record <r> then we have the condition
##  `AGR.GAPName( <r>.firstName ) = <nam>'.
##
##  So a case insensitive partial mapping from character table identifiers
##  to GAP names of ATLAS groups is built in `AGR.GNAN',
##  and is used in `AGR.GAPName'
##
##  Examples of different names for a group are `"F3+"' vs. `"Fi24'"'
##  and `"S6"' vs. `"A6.2_1"'.
##
AGR.MapNameToGAPName:= [ [], [] ];

AGR.GAPName:= function( name )
    local r, nname, pos;

    # Make sure that the file `gap/types.g' is alreay loaded.
    IsRecord( AtlasOfGroupRepresentationsInfo );

    if IsBound( AGR.LibInfoCharacterTable ) then
      r:= AGR.LibInfoCharacterTable( name );
    else
      r:= fail;
    fi;
    if r = fail then
      nname:= LowercaseString( name );
    else
      nname:= r.firstName;
    fi;
    pos:= Position( AGR.MapNameToGAPName[1], nname );
    if pos = fail then
      return name;
    fi;
    return AGR.MapNameToGAPName[2][ pos ];
    end;


#############################################################################
##
#F  AGR.GNAN( <gapname>, <atlasname> )
##
##  <#GAPDoc Label="AGR.GNAN">
##  <Mark><C>AGR.GNAN( <A>gapname</A>, <A>atlasname</A> )</C></Mark>
##  <Item>
##    Called with two strings <A>gapname</A> (the &GAP; name of the group)
##    and <A>atlasname</A> (the &ATLAS; name of the group),
##    <C>AGR.GNAN</C> stores the information in the list
##    <C>AtlasOfGroupRepresentationsInfo.GAPnames</C>,
##    which defines the name mapping between the <Package>ATLAS</Package>
##    names and &GAP; names of the groups.
##    <P/>
##    This function may be used also for private extensions of the database.
##    <P/>
##    An example of a valid call is
##    <C>AGR.GNAN("A5.2","S5")</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.GNAN:= function( gapname, atlasname )
    local value, r, pos;

    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) then
      if   ForAny( AtlasOfGroupRepresentationsInfo.GAPnames,
                   pair -> gapname = pair[1] ) then
        Error( "cannot notify `", gapname, "' more than once" );
      elif ForAny( AtlasOfGroupRepresentationsInfo.GAPnames,
                   pair -> atlasname = pair[2] ) then
        Error( "ambiguous GAP names for ATLAS name `", atlasname, "'" );
      fi;
    fi;

    # Make the character table names admissible.
    if IsBound( AGR.LibInfoCharacterTable ) then
      r:= AGR.LibInfoCharacterTable( gapname );
    else
      r:= fail;
    fi;
    if r = fail then
      # Store the lowercase name.
      Add( AGR.MapNameToGAPName[1], LowercaseString( gapname ) );
      Add( AGR.MapNameToGAPName[2], gapname );
    elif not r.firstName in AGR.MapNameToGAPName[1] then
      Add( AGR.MapNameToGAPName[1], r.firstName );
      Add( AGR.MapNameToGAPName[2], gapname );
    else
      Error( "<gapname> is not compatible with CTblLib" );
    fi;

    value:= [ gapname, atlasname, rec() ];
    AddSet( AtlasOfGroupRepresentationsInfo.GAPnames, value );
    AGR.GAPnamesRec.( gapname ):= value;
    end;


#############################################################################
##
#F  AGR.GRP( <dirname>, <simpname>, <groupname> )
##
##  <#GAPDoc Label="AGR.GRP">
##  <Mark><C>AGR.GRP( <A>dirname</A>, <A>simpname</A>, <A>groupname</A>)</C></Mark>
##  <Item>
##    Called with three strings, <C>AGR.GRP</C> stores in the
##    <C>groupname</C> component of 
##    <Ref Var="AtlasOfGroupRepresentationsInfo"/> in which path on the
##    servers the data about the group with &ATLAS; name <A>groupname</A>
##    can be found.
##    <P/>
##    This function is <E>not</E> intended for private extensions of the
##    database.
##    <P/>
##    An example of a valid call is
##    <C>AGR.GRP("alt","A5","S5")</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.GRP:= function( dirname, simpname, groupname )
    local entry;

    if ForAll( AtlasOfGroupRepresentationsInfo.GAPnames,
               pair -> pair[2] <> groupname ) then

      # There is no corresponding GAP name.
      AddSet( AtlasOfGroupRepresentationsInfo.GAPnames,
              Immutable( [ groupname, groupname ] ) );
      AGR.SetGAPnamesSortDisp();
      Info( InfoAtlasRep, 1,
            "no GAP name known for `", groupname, "'" );

    fi;

    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) then
      entry:= First( AtlasOfGroupRepresentationsInfo.groupnames,
                     l -> l[3] = groupname );
      if entry <> fail then

        # Check whether the group is already notified.
        if entry[1] = dirname then
          Info( InfoAtlasRep, 1,
                "group with Atlas name `", groupname, "' already notified" );
        else
          Error( "group with Atlas name `", groupname,
                 "' notified for different directories!" );
        fi;
        if entry[2] <> simpname then
          Error( "group with Atlas name `", groupname,
                 "' notified for different simple groups!" );
        fi;
        return;
      fi;
    fi;

    # Notify the group.
    Add( AtlasOfGroupRepresentationsInfo.groupnames,
         [ dirname, simpname, groupname ] );
    end;


#############################################################################
##
#F  AGR.TOC( <typename>, <filename>[, <n>] )
##
##  <#GAPDoc Label="AGR.TOC">
##  <Mark><C>AGR.TOC( <A>typename</A>, <A>filename</A>[, <A>n</A>] )</C></Mark>
##  <Item>
##    Called with two strings <A>typename</A> and <A>filename</A>,
##    <C>AGR.TOC</C> notifies an entry to the <C>TableOfContents.remote</C>
##    component of <Ref Var="AtlasOfGroupRepresentationsInfo"/>,
##    where <A>typename</A> must be the name of the data type to which
##    the entry belongs and <A>filename</A> must be the prefix of the data
##    file(s); the optional third argument <A>n</A> indicates that the
##    generators are located in <A>n</A> files.
##    <P/>
##    This function is <E>not</E> intended for private extensions of the
##    database.
##    <P/>
##    An example of a valid call is
##    <C>AGR.TOC("perm","S5G1-p5B0.m",2)</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.TOC:= function( arg )
    local type, string, t, record, entry, groupname, added, j;

    # Get the arguments.
    type:= arg[1];
    if Length( arg ) = 3 then
      string:= Concatenation( arg[2], "1" );
    else
      string:= arg[2];
    fi;

    # Parse the filename with the given format info.
    # type:= First( AGR.DataTypes( "rep", "prg" ), x -> x[1] = type );
    for t in AGR.DataTypes( "rep", "prg" ) do
      if t[1] = type then
        type:= t;
        break;
      fi;
    od;
    record:= AtlasTableOfContents( "remote" ).TableOfContents;
    entry:= AGR.ParseFilenameFormat( string, type[2].FilenameFormat );
    if entry = fail then
      Info( InfoAtlasRep, 1, "`", arg, "' is not a valid t.o.c. entry" );
      return;
    fi;

    # Get the list for the data in the record for the group name.
    groupname:= entry[1];
    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) and
       ForAll( AtlasOfGroupRepresentationsInfo.groupnames,
               x -> x[3] <> groupname ) then
      Error( "`", groupname, "' is not a valid group name" );
    fi;
    if not IsBound( record.( groupname ) ) then
      record.( groupname ):= rec();
    fi;
    record:= record.( groupname );
    if not IsBound( record.( type[1] ) ) then
      record.( type[1] ):= [];
    fi;

    # Add the first filename.
    added:= type[2].AddFileInfo( record.( type[1] ), entry, string );

    # Add the other filenames if necessary.
    if added and Length( arg ) = 3 then
      for j in [ 2 .. arg[3] ] do
        entry[ Length( entry ) ]:= j;
        added:= type[2].AddFileInfo( record.( type[1] ), entry,
                    Concatenation( arg[2], String( j ) ) )
                and added;
      od;
    fi;

    if not added then
      Info( InfoAtlasRep, 1, "`", arg, "' is not a valid t.o.c. entry" );
    fi;
    end;


#############################################################################
##
#F  AGR.GRS( <gapname>, <size> )
##
##  <#GAPDoc Label="AGR.GRS">
##  <Mark><C>AGR.GRS( <A>gapname</A>, <A>size</A> )</C></Mark>
##  <Item>
##    Called with the string <A>gapname</A> (the &GAP; name of the group)
##    and the integer <A>size</A> (the order of the group),
##    <C>AGR.GRS</C> stores this information in
##    <C>AtlasOfGroupRepresentationsInfo.GAPnames</C>.
##    <P/>
##    An example of a valid call is
##    <C>AGR.GRS("A5.2",120)</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.GRS:= function( gapname, size )
    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) then
      AGR.TST( gapname, size, "size", IsPosInt, "positive integer" );
    fi;
    AGR.GAPnamesRec.( gapname )[3].size:= size;
    end;


#############################################################################
##
#F  AGR.MXN( <gapname>, <nrMaxes> )
##
##  <#GAPDoc Label="AGR.MXN">
##  <Mark><C>AGR.MXN( <A>gapname</A>, <A>nrMaxes</A> )</C></Mark>
##  <Item>
##    Called with the string <A>gapname</A> (the &GAP; name of the group)
##    and the integer <A>nrMaxes</A> (the number of classes of maximal
##    subgroups of the group),
##    <C>AGR.MXN</C> stores the information in
##    <C>AtlasOfGroupRepresentationsInfo.GAPnames</C>.
##    <P/>
##    An example of a valid call is
##    <C>AGR.MXN("A5.2",4)</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.MXN:= function( gapname, nrMaxes )
    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) then
      AGR.TST( gapname, nrMaxes, "nrMaxes", IsPosInt, "positive integer" );
    fi;
    AGR.GAPnamesRec.( gapname )[3].nrMaxes:= nrMaxes;
    end;


#############################################################################
##
#F  AGR.MXO( <gapname>, <sizesMaxes> )
##
##  <#GAPDoc Label="AGR.MXO">
##  <Mark><C>AGR.MXO( <A>gapname</A>, <A>sizesMaxes</A> )</C></Mark>
##  <Item>
##    Called with the string <A>gapname</A> (the &GAP; name of the group)
##    and the list <A>sizesMaxes</A> (of subgroup orders of the classes of
##    maximal subgroups of the group, not necessarily dense,
##    in non-increasing order),
##    <C>AGR.MXO</C> stores the information in
##    <C>AtlasOfGroupRepresentationsInfo.GAPnames</C>.
##    <P/>
##    An example of a valid call is
##    <C>AGR.MXO("A5.2",[60,24,20,12])</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.MXO:= function( gapname, sizesMaxes )
    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) then
      AGR.TST( gapname, sizesMaxes, "sizesMaxes",
          x -> IsList( x ) and ForAll( x, IsPosInt )
                           and IsSortedList( Reversed( Compacted( x ) ) ),
          "list of non-increasing pos. integers" );
    fi;
    AGR.GAPnamesRec.( gapname )[3].sizesMaxes:= sizesMaxes;
    end;


#############################################################################
##
#F  AGR.MXS( <gapname>, <structureMaxes> )
##
##  <#GAPDoc Label="AGR.MXS">
##  <Mark><C>AGR.MXS( <A>gapname</A>, <A>structureMaxes</A> )</C></Mark>
##  <Item>
##    Called with the string <A>gapname</A> (the &GAP; name of the group)
##    and the list <A>structureMaxes</A> (of strings describing the
##    structures of the maximal subgroups of the group, not necessarily dense),
##    <C>AGR.MXS</C> stores the information in
##    <C>AtlasOfGroupRepresentationsInfo.GAPnames</C>.
##    <P/>
##    An example of a valid call is
##    <C>AGR.MXS("A5.2",["A5","S4","5:4","S3x2"])</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.MXS:= function( gapname, structureMaxes )
    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) then
      AGR.TST( gapname, structureMaxes, "structureMaxes",
          x -> IsList( x ) and ForAll( x, IsString ),
          "list of strings" );
    fi;
    AGR.GAPnamesRec.( gapname )[3].structureMaxes:= structureMaxes;
    end;


#############################################################################
##
##  AGR.KERPRG( <gapname>, <kernelProgram> )
##
##  <#GAPDoc Label="AGR.KERPRG">
##  <Mark><C>AGR.KERPRG( <A>gapname</A>, <A>kernelProgram</A> )</C></Mark>
##  <Item>
##    Called with the string <A>gapname</A> (the &GAP; name of the group)
##    and the list <A>kernelProgram</A> (with entries the standardization of
##    the group, the &GAP; name of a factor group, and the list of lines of a
##    straight line program that computes generators of the kernel of the
##    epimorphism from the group to the factor group),
##    <C>AGR.KERPRG</C> stores the information in
##    <C>AtlasOfGroupRepresentationsInfo.GAPnames</C>.
##    <P/>
##    An example of a valid call is
##    <C>AGR.KERPRG("2.J2",[1,"J2",[[[1,2]]]])</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.KERPRG:= function( gapname, kernelProgram )
    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) and
       not ( IsList( kernelProgram ) and Length( kernelProgram ) = 3 and
             IsPosInt( kernelProgram[1] ) and
             IsString( kernelProgram[2] ) and
             IsDenseList( kernelProgram[3] ) ) then
      Error( "<kernelProgram> must be a suitable list" );
    fi;
    if not IsBound( AGR.GAPnamesRec.( gapname )[3].kernelPrograms ) then
      AGR.GAPnamesRec.( gapname )[3].kernelPrograms:= [];
    fi;
    Add( AGR.GAPnamesRec.( gapname )[3].kernelPrograms, kernelProgram );
    end;


#############################################################################
##
#F  AGR.STDCOMP( <gapname>, <factorCompatibility> )
##
##  <#GAPDoc Label="AGR.STDCOMP">
##  <Mark><C>AGR.STDCOMP</C></Mark>
##  <Item>
##    Called with the string <A>gapname</A> (the &GAP; name of the group)
##    and the list <A>factorCompatibility</A> (with entries
##    the standardization of the group, the &GAP; name of a factor group,
##    the standardization of this factor group, and
##    <K>true</K> or <K>false</K>, indicating whether mapping the standard
##    generators for <A>gapname</A> to those of <A>factgapname</A> defines an
##    epimorphism),
##    <C>AGR.STDCOMP</C> stores the information in
##    <C>AtlasOfGroupRepresentationsInfo.GAPnames</C>.
##    <P/>
##    An example of a valid call is
##    <C>AGR.STDCOMP("2.A5.2",[1,"A5.2",1,true])</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.STDCOMP:= function( gapname, factorCompatibility )
    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) and
       not ( IsList( factorCompatibility ) and
             Length( factorCompatibility ) = 4 and
             IsPosInt( factorCompatibility[1] ) and
             IsString( factorCompatibility[2] ) and
             IsPosInt( factorCompatibility[3] ) and
             IsBool( factorCompatibility[4] ) ) then
      Error( "<factorCompatibility> must be a suitable list" );
    fi;
    if not IsBound( AGR.GAPnamesRec.( gapname )[3].factorCompatibility ) then
      AGR.GAPnamesRec.( gapname )[3].factorCompatibility:= [];
    fi;
    Add( AGR.GAPnamesRec.( gapname )[3].factorCompatibility,
         factorCompatibility );
    end;


#############################################################################
##
#F  AGR.RNG( <repname>, <descr> )
##
##  <#GAPDoc Label="AGR.RNG">
##  <Mark><C>AGR.RNG( <A>repname</A>, <A>descr</A> )</C></Mark>
##  <Item>
##    Called with two strings <A>repname</A> (denoting the name
##    of a file containing the generators of a matrix representation over a
##    ring that is not determined by the filename)
##    and <A>descr</A> (describing this ring <M>R</M>, say),
##    <C>AGR.RNG</C> adds the triple
##    <M>[ <A>repname</A>, <A>descr</A>, R ]</M>
##    to the list stored in the <C>ringinfo</C> component of
##    <Ref Var="AtlasOfGroupRepresentationsInfo"/>.
##    <P/>
##    An example of a valid call is
##    <C>AGR.RNG("A5G1-Ar3aB0","Field([Sqrt(5)])")</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.RNG:= function( repname, descr )
    local triple;

    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) then
      # Check that this representation really exists.
      if not AGR.IsRepNameAvailable( repname ) then
        return;
      fi;
    fi;

    triple:= [ repname, descr, EvalString( descr ) ];
    if triple in AtlasOfGroupRepresentationsInfo.ringinfo then
      Info( InfoAtlasRep, 1,
            "triple `", triple, "' cannot be notified more than once" );
    else
      Add( AtlasOfGroupRepresentationsInfo.ringinfo, triple );
    fi;
    end;


#############################################################################
##
#F  AGR.TOCEXT( <atlasname>, <std>, <maxnr>, <files> )
##
##  <#GAPDoc Label="AGR.TOCEXT">
##  <Mark><C>AGR.TOCEXT( <A>atlasname</A>, <A>std</A>, <A>maxnr</A>, <A>files</A> )</C></Mark>
##  <Item>
##    Called with the string <A>atlasname</A> (the &ATLAS; name of the
##    group), the positive integers <A>std</A> (the standardization) and
##    <A>maxnr</A> (the number of the class of maximal subgroups), and
##    the list <A>files</A> (of filenames of straight line programs for
##    computing generators of the <A>maxnr</A>-th maximal subgroup, using
##    a straight line program for a factor group plus perhaps some straight
##    line program for computing kernel generators),
##    <C>AGR.TOCEXT</C> stores the information in the <C>maxext</C> component
##    of the <A>atlasname</A> component of the <C>"remote"</C>
##    table of contents.
##    <P/>
##    An example of a valid call is
##    <C>AGR.TOCEXT("2A5",1,3,["A5G1-max3W1"])</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.TOCEXT:= function( atlasname, std, maxnr, files )
    local r, info;

    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) then
      if not ( IsString( atlasname ) and IsPosInt( std )
                                     and IsPosInt( maxnr )
                                     and IsList( files )
                                     and ForAll( files, IsString ) ) then
        Error( "not a valid t.o.c.ext entry" );
      elif ForAll( AtlasOfGroupRepresentationsInfo.GAPnames,
                   x -> x[2] <> atlasname )  then
        Error( "`", atlasname, "' is not a valid group name" );
      fi;

      # Check that the required programs really exist.
      if not AGR.IsPrgNameAvailable( files[1] ) then
        # The program for the max. subgroup of the factor is not available.
        return;
      elif IsBound( files[2] ) then
        # Check whether the required program for computing kernel generators
        # is available.
        info:= First( AtlasOfGroupRepresentationsInfo.GAPnames,
                      x -> x[2] = atlasname )[3];
        if not ( IsBound( info.kernelPrograms ) and
                 ForAny( info.kernelPrograms, x -> x[2] = files[2] ) ) then
          Print( "#E  kernel program required by `", atlasname, "' and `",
                 files, "' not available\n" );
          return;
        fi;
      fi;
    fi;

    r:= AtlasTableOfContents( "remote" ).TableOfContents;
    if not IsBound( r.( atlasname ) ) then
      r.( atlasname ):= rec();
    fi;
    r:= r.( atlasname );
    if not IsBound( r.maxext )  then
      r.maxext:= [];
    fi;
    Add( r.maxext, [ std, maxnr, files ] );
    end;


#############################################################################
##
#F  AGR.API( <repname>, <info> )
##
##  <#GAPDoc Label="AGR.API">
##  <Mark><C>AGR.API( <A>repname</A>, <A>info</A> )</C></Mark>
##  <Item>
##    Called with the string <A>repname</A> (denoting the name of a
##    permutation representation)
##    and the list <A>info</A> (describing the point stabilizer of this
##    representation),
##    <C>AGR.API</C> binds the component <A>repname</A> of the record
##    <C>AtlasOfGroupRepresentationsInfo.permrepinfo</C> to <A>info</A>.
##    <P/>
##    <A>info</A> has the following entries.
##    <List>
##    <Item>
##      At position <M>1</M>, the transitivity is stored.
##    </Item>
##    <Item>
##      If the transitivity is zero then the second entry is the list of
##      orbit lengths.
##    </Item>
##    <Item>
##      If the transitivity is positive then the second entry is the rank
##      of the action.
##    </Item>
##    <Item>
##      If the transitivity is positive then the third entry is one of the
##      strings <C>"prim"</C>, <C>"imprim"</C>, denoting primitivity or not.
##    </Item>
##    <Item>
##      If the transitivity is positive then the fourth entry is a string
##      describing the structure of the point stabilizer.
##      If the third entry is <C>"imprim"</C> then this description consists
##      of a subgroup part and a maximal subgroup part, separated by
##      <C>" &lt; "</C>.
##    </Item>
##    <Item>
##      If the third entry is <C>"prim"</C> then the fifth entry is either
##      <C>"???"</C>
##      or it denotes the number of the class of maximal subgroups
##      that are the point stabilizers.
##    </Item>
##    </List>
##    <P/>
##    An example of a valid call is
##    <C>AGR.API("A5G1-p5B0",[3,2,"prim","A4",1])</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.API:= function( repname, info )
    local r;

    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) then
      if IsBound( AtlasOfGroupRepresentationsInfo.permrepinfo.( repname ) ) then
        Error( "cannot notify `", repname, "' more than once" );
      fi;

      # Check that this representation really exists.
      if not AGR.IsRepNameAvailable( repname ) then
        return;
      fi;
    fi;

    r:= rec( transitivity:= info[1] );
    if info[1] = 0 then
      r.orbits:= info[2];
    else
      r.rankAction:= info[2];
      r.isPrimitive:= ( info[3] = "prim" );
      r.stabilizer:= info[4];
      if r.isPrimitive then
        r.maxnr:= info[5];
      fi;
    fi;
    AtlasOfGroupRepresentationsInfo.permrepinfo.( repname ):= r;
    end;


#############################################################################
##
#F  AGR.CHAR( <groupname>, <repname>, <char>, <pos>[, <charname>] )
##
##  <#GAPDoc Label="AGR.CHAR">
##  <Mark><C>AGR.CHAR( <A>groupname</A>, <A>repname</A>, <A>char</A>, <A>pos</A>[, <A>charname</A>] )</C></Mark>
##  <Item>
##    Called with the strings <A>groupname</A> (the &GAP; name of the group)
##    and <A>repname</A> (denoting the name of the representation),
##    the integer <A>char</A> (the characteristic of the representation),
##    and <A>pos</A> (the position or list of positions of the irreducible
##    constituent(s)),
##    <C>AGR.CHAR</C> stores the information in
##    <C>AtlasOfGroupRepresentationsInfo.characterinfo</C>.
##    A string describing the character can be entered as <A>charname</A>.
##    <P/>
##    An example of a valid call is
##    <C>AGR.CHAR("M11","M11G1-p11B0",0,[1,2],"1a+10a")</C>.
##  </Item>
##  <#/GAPDoc>
##
AGR.CHAR:= function( arg )
    local map, groupname, repname, char, pos;

    map:= AtlasOfGroupRepresentationsInfo.characterinfo;
    groupname:= arg[1];
    repname:= arg[2];
    char:= arg[3];
    pos:= arg[4];
    if not IsBound( map.( groupname ) ) then
      map.( groupname ):= [];
    fi;
    map:= map.( groupname );
    if char = 0 then
      char:= 1;
    fi;
    if not IsBound( map[ char ] ) then
      map[ char ]:= [ [], [], [] ];
    fi;
    map:= map[ char ];

    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) then
      # Check whether we have already a character for this representation.
      # (Two different representations with the same character are allowed.)
      if arg[2] in map[2] and map[1][ Position( map[2], repname ) ] <> pos then
        Error( "attempt to enter two different characters for ", arg[2] );
      fi;

      # Check that this representation really exists.
      if not AGR.IsRepNameAvailable( repname ) then
        return;
      fi;
    fi;

    Add( map[1], pos );
    Add( map[2], repname );
    if Length( arg ) = 5 then
      Add( map[3], arg[5] );
    else
      Add( map[3], fail );
    fi;
    end;


#############################################################################
##
#F  AGR.CompareAsNumbersAndNonnumbers( <nam1>, <nam2> )
##
##  This function is available as `BrowseData.CompareAsNumbersAndNonnumbers'
##  if the Browse package is available.
##  But we must deal also with the case that this package is not available.
##
AGR.CompareAsNumbersAndNonnumbers:= function( nam1, nam2 )
    local len1, len2, len, digit, comparenumber, i;

    len1:= Length( nam1 );
    len2:= Length( nam2 );
    len:= len1;
    if len2 < len then
      len:= len2;
    fi;
    digit:= false;
    comparenumber:= 0;
    for i in [ 1 .. len ] do
      if nam1[i] in DIGITS then
        if nam2[i] in DIGITS then
          digit:= true;
          if comparenumber = 0 then
            # first digit of a number, or previous digits were equal
            if nam1[i] < nam2[i] then
              comparenumber:= 1;
            elif nam1[i] <> nam2[i] then
              comparenumber:= -1;
            fi;
          fi;
        else
          # if digit then the current number in `nam2' is shorter,
          # so `nam2' is smaller;
          # if not digit then a number starts in `nam1' but not in `nam2',
          # so `nam1' is smaller
          return not digit;
        fi;
      elif nam2[i] in DIGITS then
        # if digit then the current number in `nam1' is shorter,
        # so `nam1' is smaller;
        # if not digit then a number starts in `nam2' but not in `nam1',
        # so `nam2' is smaller
        return digit;
      else
        # both characters are non-digits
        if digit then
          # first evaluate the current numbers (which have the same length)
          if comparenumber = 1 then
            # nam1 is smaller
            return true;
          elif comparenumber = -1 then
            # nam2 is smaller
            return false;
          fi;
          digit:= false;
        fi;
        # now compare the non-digits
        if nam1[i] <> nam2[i] then
          return nam1[i] < nam2[i];
        fi;
      fi;
    od;

    if digit then
      # The suffix of the shorter string is a number.
      # If the longer string continues with a digit then it is larger,
      # otherwise the first digits of the number decide.
      if len < len1 and nam1[ len+1 ] in DIGITS then
        # nam2 is smaller
        return false;
      elif len < len2 and nam2[ len+1 ] in DIGITS then
        # nam1 is smaller
        return true;
      elif comparenumber = 1 then
        # nam1 is smaller
        return true;
      elif comparenumber = -1 then
        # nam2 is smaller
        return false;
      fi;
    fi;

    # Now the longer string is larger.
    return len1 < len2;
    end;


#############################################################################
##
#F  AGR.SetGAPnamesSortDisp()
##
##  Bind the component `AtlasOfGroupRepresentationsInfo.GAPnamesSortDisp'.
##
AGR.SetGAPnamesSortDisp:= function()
    local list;

    list:= ShallowCopy( AtlasOfGroupRepresentationsInfo.GAPnames );
    SortParallel( List( list, x -> x[1] ), list,
                  AGR.CompareAsNumbersAndNonnumbers );
    AtlasOfGroupRepresentationsInfo.GAPnamesSortDisp:= list;
    end;


#############################################################################
##
#F  AGR.ParseFilenameFormat( <string>, <format> )
##
AGR.ParseFilenameFormat:= function( string, format )
    local result, i, res;

    string:= SplitString( string, "-" );
    if Length( string ) <> Length( format[1] ) then
      return fail;
    fi;
    result:= [];
    for i in [ 1 .. Length( string ) ] do

      # Loop over the '-' separated components.
      res:= format[2][i]( string[i], format[1][i] );
      if res = fail then
        return fail;
      fi;
      Append( result, res );

    od;
    return result;
    end;


#############################################################################
##
#F  AtlasDataGAPFormatFile( <filename> )
##
InstallGlobalFunction( AtlasDataGAPFormatFile, function( filename )
    local record;

    InfoRead1( "#I  reading `", filename, "' started\n" );
    record:= ReadAsFunction( filename );
    InfoRead1( "#I  reading `", filename, "' done\n" );
    if record = fail then
      Info( InfoAtlasRep, 1,
            "problem reading `", filename, "' as function\n" );
    else
      record:= record();
    fi;
    return record;
end );


#############################################################################
##
#F  AtlasStringOfFieldOfMatrixEntries( <mats> )
#F  AtlasStringOfFieldOfMatrixEntries( <filename> )
##
InstallGlobalFunction( AtlasStringOfFieldOfMatrixEntries, function( mats )
    local F, n, str;

    if IsString( mats ) then
      mats:= AtlasDataGAPFormatFile( mats ).generators;
    fi;

    if   IsCyclotomicCollCollColl( mats ) then
      F:= Field( Rationals, Flat( mats ) );
    elif ForAll( mats, IsQuaternionCollColl ) then
      F:= Field( Flat( List( Flat( mats ), ExtRepOfObj ) ) );
    else
      Error( "<mats> must be a matrix list of cyclotomics or quaternions" );
    fi;

    n:= Conductor( F );

    if DegreeOverPrimeField( F ) = 2 then

      # The field is quadratic,
      # so it is generated by `Sqrt(n)' if $`n' \equiv 1 \pmod{4}$,
      # by `Sqrt(-n)' if $`n' \equiv 3 \pmod{4}$,
      # and by one of `Sqrt(n/4)', `Sqrt(-n/4)' otherwise.
      if   n mod 4 = 1 then
        str:= Concatenation( "[Sqrt(", String( n ), ")]" );
      elif n mod 4 = 3 then
        str:= Concatenation( "[Sqrt(-", String( n ), ")]" );
      elif Sqrt( -n/4 ) in F then
        str:= Concatenation( "[Sqrt(-", String( n/4 ), ")]" );
      else
        str:= Concatenation( "[Sqrt(", String( n/4 ), ")]" );
      fi;

    elif IsCyclotomicField( F ) then

      # The field is not quadratic but cyclotomic.
      str:= Concatenation( "[E(", String( n ), ")]" );

    else
      str:= "";
    fi;

    if IsCyclotomicCollCollColl( mats ) then
      if str = "" then
        str:= String( F );
      else
        str:= Concatenation( "Field(", str, ")" );
      fi;
    elif F = Rationals then
      str:= "QuaternionAlgebra(Rationals)";
    elif str = "" then
      str:= Concatenation( "QuaternionAlgebra(", String( F ), ")" );
    else
      str:= Concatenation( "QuaternionAlgebra(", str, ")" );
    fi;

    return [ F, str ];
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsScanFilename( <name>, <result> )
##
BindGlobal( "AtlasOfGroupRepresentationsScanFilename",
    function( name, result )
    local filename, pos, type, format, groupname;

    filename:= name;
    pos:= Position( filename, '/' );
    while pos <> fail do
      filename:= filename{ [ pos+1 .. Length( filename ) ] };
      pos:= Position( filename, '/' );
    od;
    for type in AGR.DataTypes( "rep", "prg" ) do
      format:= AGR.ParseFilenameFormat( filename, type[2].FilenameFormat );
      if format <> fail then
        groupname:= format[1];
        if not IsBound( result.( groupname ) ) then
          result.( groupname ):= rec();
        fi;
        if not IsBound( result.( groupname ).( type[1] ) ) then
          result.( groupname ).( type[1] ):= [];
        fi;
        return type[2].AddFileInfo( result.( groupname ).( type[1] ),
                                    format, name );
      fi;
    od;
    return false;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsUpdateTableOfContentsFile( <dstfilename> )
##
##  Fetch the current table of contents from the package's home directory,
##  and write it to the file <A>dstfilename</A>,
##  which is interpreted as an absolute path.
##
##  This function is used by the script <F>etc/maketoc</F> and in the call
##  <C>AtlasTableOfContents( "remote" )</C>.
##
BindGlobal( "AtlasOfGroupRepresentationsUpdateTableOfContentsFile",
    function( dstfilename )
    local version, inforec, home, server, path;

    version:= InstalledPackageVersion( "atlasrep" );
    inforec:= First( PackageInfo( "atlasrep" ), r -> r.Version = version );
    home:= inforec.PackageWWWHome;
    if home{ [ 1 .. 7 ] } = "http://" then
      home:= home{ [ 8 .. Length( home ) ] };
    fi;

    server:= home{ [ 1 .. Position( home, '/' ) - 1 ] };
    path:= home{ [ Position( home, '/' ) + 1 .. Length( home ) ] };

    # Fetch the file if possible.
    return AtlasOfGroupRepresentationsTransferFile( server,
               Concatenation( path, "/atlasprm.g" ),
               dstfilename );
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsComposeTableOfContents( <filelist>,
#F                                                     <groupnames> )
##
##  This code is used by `AtlasTableOfContents'.
##
BindGlobal( "AtlasOfGroupRepresentationsComposeTableOfContents",
    function( filelist, groupnames )
    local result, name, len, groupname, record, type, listtosort;

    # Initialize the result record.
    result:= rec( otherfiles:= [] );

    # Deal with the case of `gzip'ped files, and omit obvious garbage.
    for name in Set( filelist ) do
      len:= Length( name );
      if 3 <= len and name{ [ len-2 .. len ] } = ".gz" then
        name:= name{ [ 1 .. len-3 ] };
      fi;
      if AtlasOfGroupRepresentationsScanFilename( name, result ) = false then
        if not ( name in [ "dummy", ".", "..", "CVS", "CVS:", "./CVS:",
                           "Entries", "Repository", "Root", "toc.g",
                           ".cvsignore" ] or
                 name[ Length( name ) ] = '%' or
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
        for type in AGR.DataTypes( "rep", "prg" ) do
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
    return result;
end );


#############################################################################
##
#F  AtlasTableOfContents( <dirname> )
##
InstallGlobalFunction( AtlasTableOfContents, function( string )
    local toc, groupnames, prefix, filenames, dstdir, dstfile, tocremote,
          typeinfo, groupname, r, pair, type, entry, fileinfo, filename, loc,
          dirname, privdir, dir, result;

    toc:= AtlasOfGroupRepresentationsInfo.TableOfContents;

    # Take the stored version if it is already available.
    groupnames:= AtlasOfGroupRepresentationsInfo.groupnames;
    if IsBound( toc.( string ) ) then
      return rec( groupnames      := groupnames,
                  TableOfContents := toc.( string ) );
    fi;

    prefix:= "";
    filenames:= [];
    if string = "remote" then
      # Someone has unbound the value, we interpret this as the wish
      # to transfer the current file `atlasprm.g' from the package homepage,
      # and to read it.
      # If we are allowed to overwrite the file from the installation
      # then we do this, otherwise we use a temporary file.
      dstdir:= DirectoriesPackageLibrary( "atlasrep", "gap" );
      dstfile:= Filename( dstdir, "atlasprm.g" );
      if not IsWritableFile( dstfile ) then
        dstfile:= Filename( DirectoryTemporary(), "atlasprm.g" );
      fi;
      if not AtlasOfGroupRepresentationsUpdateTableOfContentsFile( dstfile )
         then
        return fail;
      fi;
      ReplaceAtlasTableOfContents( dstfile );
      return rec( groupnames      := AtlasOfGroupRepresentationsInfo.groupnames,
                  TableOfContents := toc.remote );
    elif string = "local" then
      # List the information that is locally available,
      # by testing which of the files in the remote t.o.c. are stored.
      tocremote:= AtlasTableOfContents( "remote" ).TableOfContents;
      typeinfo:= Concatenation(
                     List( AGR.DataTypes( "rep" ), x -> [ "datagens", x ] ),
                     List( AGR.DataTypes( "prg" ), x -> [ "dataword", x ] ) );
      for groupname in RecNames( tocremote ) do
        r:= tocremote.( groupname );
        if IsRecord( r ) then
          for pair in typeinfo do
            type:= pair[2];
            if IsBound( r.( type[1] ) ) then
              for entry in r.( type[1] ) do
                fileinfo:= entry[ Length( entry ) ];
                if IsString( fileinfo ) then
                  fileinfo:= [ fileinfo ];
                fi;
                for filename in fileinfo do
                  loc:= AtlasOfGroupRepresentationsLocalFilename( pair[1],
                         groupname, filename, type );
                  if not IsEmpty( loc ) and ForAll( loc[1][2], x -> x[2] ) then
                    Add( filenames, filename );
                  fi;
                od;
              od;
            fi;
          od;
        fi;
      od;
    else
      # List the contents of the private data directories.
      dirname:= First( AtlasOfGroupRepresentationsInfo.private,
                       pair -> pair[2] = string )[1];
      if IsExistingFile( dirname ) then
        # List the information available in the given private directory.
        # (Up to one directory layer above the data files is supported.)
        filenames:= [];
        privdir:= Directory( dirname );
        for dir in Difference( DirectoryContents( dirname ), [ ".", ".." ] ) do
          dstfile:= Filename( privdir, dir );
          if IsDirectoryPath( dstfile ) then
            Append( filenames, List( DirectoryContents( dstfile ),
                                     x -> Concatenation( dir, "/", x ) ) );
          else
            Add( filenames, dir );
          fi;
        od;
      fi;
    fi;

    # Compose the result record.
    result:= AtlasOfGroupRepresentationsComposeTableOfContents( filenames,
                 groupnames );
    if string <> "local" then
      result.diridPrivate:= string;
    fi;

    # Store the newly computed table of contents.
    toc.( string ):= result;

    # Return the result record.
    return rec( groupnames      := groupnames,
                TableOfContents := result );
end );


#############################################################################
##
#F  ReloadAtlasTableOfContents( \"local\" )
#F  ReloadAtlasTableOfContents( \"remote\" )
##
InstallGlobalFunction( ReloadAtlasTableOfContents, function( string )
    local toc, old, new;

    toc:= AtlasOfGroupRepresentationsInfo.TableOfContents;
    if IsBound( toc.( string ) ) then
      old:= toc.( string );
      Unbind( toc.( string ) );
    fi;
    new:= AtlasTableOfContents( string );
    if new = fail then
      if IsBound( old ) then
        toc.( string ):= old;
      fi;
      Info( InfoAtlasRep, 1,
            "could not reload ", string, " table of contents" );
      return fail;
    fi;
    toc.( string ):= new.TableOfContents;
    if string = "remote" then
      AtlasOfGroupRepresentationsInfo.groupnames:= new.groupnames;
    fi;
    return true;
end );


#############################################################################
##
#F  StoreAtlasTableOfContents( <filename> )
##
##  Note that we must put everything into a single file because this is the
##  one that can be fetched automatically by users.
##
InstallGlobalFunction( StoreAtlasTableOfContents, function( filename )
    if IsExistingFile( filename ) and not IsWritableFile( filename ) then
      Error( "<filename> must be writable if exists" );
    elif not IsBound( AtlasOfGroupRepresentationsInfo.TableOfContents.(
                          "remote" ) ) then
      Error( "no remote t.o.c. exists" );
    fi;

    # Add the data.
    FileString( filename, StringOfAtlasTableOfContents( "remote" ) );
end );


#############################################################################
##
#F  ReplaceAtlasTableOfContents( <filename> )
##
InstallGlobalFunction( ReplaceAtlasTableOfContents, function( filename )
    local  priv, pair;

    if not IsReadableFile( filename ) then
      Error( "<filename> must be the name of a readable file" );
    fi;

    # Remove the information we are going to add by reading the file.
    AtlasOfGroupRepresentationsInfo.TableOfContents.( "remote" ):= rec();
    priv:= AtlasOfGroupRepresentationsInfo.private;
    AtlasOfGroupRepresentationsInfo.GAPnames := [];
    AtlasOfGroupRepresentationsInfo.GAPnamesSortDisp:= [];
    AtlasOfGroupRepresentationsInfo.groupnames := [];
    AtlasOfGroupRepresentationsInfo.ringinfo := [];
    AtlasOfGroupRepresentationsInfo.private := [];
    AtlasOfGroupRepresentationsInfo.characterinfo:= rec();
    AtlasOfGroupRepresentationsInfo.permrepinfo:= rec();
    AGR.MapNameToGAPName:= [ [], [] ];
    AGR.GAPnamesRec:= rec();

    # Replace the old version by the new one.
    AtlasOfGroupRepresentationsInfo.checkData:= true;
    Reread( filename );
    Unbind( AtlasOfGroupRepresentationsInfo.checkData );

    # Reinsert the information from private directories.
    for pair in priv do
      AtlasOfGroupRepresentationsNotifyPrivateDirectory( pair[1], pair[2] );
    od;
end );


#############################################################################
##
#F  StringOfAtlasTableOfContents( <string> )
##
InstallGlobalFunction( StringOfAtlasTableOfContents, function( string )
    local str, pos, toc, sepline, triple, groupname, reps, type, entry,
          lines, nam, line, r, map, i, j;

    # Currently only the argument `"remote"' is supported.
    if string <> "remote" then
      Error( "sorry, private tables of contents are not yet supported here" );
    fi;

    # Copy the constant part of the data to the desired file.
    str:= StringFile( Filename( DirectoriesPackageLibrary( "atlasrep", "gap" ),
                                "atlasprm.g" ) );
    pos:= PositionSublist( str, "AGR.SetGAPnamesSortDisp();" );
    pos:= Position( str, '\n', pos );
    str:= str{ [ 1 .. pos ] };

    toc:= AtlasTableOfContents( string ).TableOfContents;
    sepline:= RepeatedString( "#", 77 );

    Append( str, "\n\n" );
    Append( str, sepline );
    Append( str, "\n##\n##  " );
    Append( str, "Store group orders.\n" );
    Append( str, "##\n" );
    lines:= [];
    for nam in RecNames( AGR.GAPnamesRec ) do
      if IsBound( AGR.GAPnamesRec.( nam )[3].size ) then
        entry:= AGR.GAPnamesRec.( nam )[3].size;
        Add( lines, Concatenation( "AGR.GRS(\"", nam, "\",",
                        String( entry ), ");\n" ) );
      fi;
    od;
    Sort( lines );
    for line in lines do
      Append( str, line );
    od;

    Append( str, "\n\n" );
    Append( str, sepline );
    Append( str, "\n##\n##  " );
    Append( str, "Store numbers of classes of maximal subgroups.\n" );
    Append( str, "##\n" );
    lines:= [];
    for nam in RecNames( AGR.GAPnamesRec ) do
      if IsBound( AGR.GAPnamesRec.( nam )[3].nrMaxes ) then
        entry:= AGR.GAPnamesRec.( nam )[3].nrMaxes;
        Add( lines, Concatenation( "AGR.MXN(\"", nam, "\",",
                        String( entry ), ");\n" ) );
      fi;
    od;
    Sort( lines );
    for line in lines do
      Append( str, line );
    od;

    Append( str, "\n\n" );
    Append( str, sepline );
    Append( str, "\n##\n##  " );
    Append( str, "Store orders of maximal subgroups.\n" );
    Append( str, "##\n" );
    lines:= [];
    for nam in RecNames( AGR.GAPnamesRec ) do
      if IsBound( AGR.GAPnamesRec.( nam )[3].sizesMaxes ) then
        entry:= AGR.GAPnamesRec.( nam )[3].sizesMaxes;
        Add( lines, Concatenation( "AGR.MXO(\"", nam, "\",",
                        ReplacedString( String( entry ), " ", "" ), ");\n" ) );
      fi;
    od;
    Sort( lines );
    for line in lines do
      Append( str, line );
    od;

    Append( str, "\n\n" );
    Append( str, sepline );
    Append( str, "\n##\n##  " );
    Append( str, "Store structures of maximal subgroups.\n" );
    Append( str, "##\n" );
    lines:= [];
    for nam in RecNames( AGR.GAPnamesRec ) do
      if IsBound( AGR.GAPnamesRec.( nam )[3].structureMaxes ) then
        entry:= AGR.GAPnamesRec.( nam )[3].structureMaxes;
        Add( lines, Concatenation( "AGR.MXS(\"", nam, "\",",
                        ReplacedString( String( entry ), " ", "" ), ");\n" ) );
      fi;
    od;
    Sort( lines );
    for line in lines do
      Append( str, line );
    od;

    Append( str, "\n\n" );
    Append( str, sepline );
    Append( str, "\n##\n##  " );
    Append( str, "Store information about generators of kernels.\n" );
    Append( str, "##\n" );
    lines:= [];
    for nam in RecNames( AGR.GAPnamesRec ) do
      if IsBound( AGR.GAPnamesRec.( nam )[3].kernelPrograms ) then
        for entry in AGR.GAPnamesRec.( nam )[3].kernelPrograms do
          Add( lines, Concatenation( "AGR.KERPRG(\"", nam, "\",",
                          ReplacedString( String( entry ), " ", "" ), ");\n" ) );
        od;
      fi;
    od;
    Sort( lines );
    for line in lines do
      Append( str, line );
    od;

    Append( str, "\n\n" );
    Append( str, sepline );
    Append( str, "\n##\n##  " );
    Append( str, "In the following, the table of contents is built\n" );
    Append( str, "##  using `AGR.GRP' and `AGR.TOC'.\n" );
    Append( str, "##  This part of the file is created by the function\n" );
    Append( str, "##  `RecomputeAtlasTableOfContents',\n" );
    Append( str, "##  do not edit below this line!\n" );
    Append( str, "##\n\n" );

    for triple in AtlasOfGroupRepresentationsInfo.groupnames do

      # Start with the notification of the group.
      Append( str, "# " );
      Append( str, triple[3] );
      Append( str, "\n" );
      Append( str, "AGR.GRP(\"" );
      Append( str, triple[1] );
      Append( str, "\",\"" );
      Append( str, triple[2] );
      Append( str, "\",\"" );
      Append( str, triple[3] );
      Append( str, "\");\n" );

      # Append the notifications of data entries for the group.
      groupname:= triple[3];
      if IsBound( toc.( groupname ) ) then
        reps:= toc.( groupname );
        for type in AGR.DataTypes( "rep", "prg" ) do
          if IsBound( reps.( type[1] ) ) then
            for entry in reps.( type[1] ) do
              if IsBound( type[2].TOCEntryString ) then
                Append( str, type[2].TOCEntryString( type[1], entry ) );
              else
                Info( InfoAtlasRep, 1,
                      "no component `TOCEntryString' for data type `",
                      type[1], "'" );
              fi;
            od;
          fi;
        od;
      fi;

      Append( str, "\n" );

    od;

    Append( str, "\n" );
    Append( str, sepline );
    Append( str, "\n##\n##  " );
    Append( str,
      "What follows now are the representation dependent additional data.\n" );
    Append( str, "##  They must be read after the notification of the representations,\n" );
    Append( str, "##  in order to give us a chance to check the existence of the underlying\n");
    Append( str, "##  representation.\n" );
    Append( str, "##\n" );

    # Append the compatibility information w.r.t. factors.
    Append( str, "\n\n" );
    Append( str, sepline );
    Append( str, "\n##\n##  " );
    Append( str, "Store info about compatibility of generators with those of factor groups.\n" );
    Append( str, "##\n" );
    lines:= [];
    for nam in RecNames( AGR.GAPnamesRec ) do
      if IsBound( AGR.GAPnamesRec.( nam )[3].factorCompatibility ) then
        for entry in AGR.GAPnamesRec.( nam )[3].factorCompatibility do
          Add( lines, Concatenation( "AGR.STDCOMP(\"", nam, "\",",
                          ReplacedString( String( entry ), " ", "" ), ");\n" ) );
        od;
      fi;
    od;
    Sort( lines );
    for line in lines do
      Append( str, line );
    od;

    # Append the information about the base rings of char. zero repres.
    Append( str, "\n\n" );
    Append( str, sepline );
    Append( str, "\n##\n##  " );
    Append( str, "Store information about the rings over which characteristic zero\n" );
    Append( str, "##  representations are written if known.\n" );
    Append( str, "##  Note that the filenames do not contain this information,\n" );
    Append( str, "##  so it has to be stored explicitly.\n" );
    Append( str, "##\n" );
    lines:= [];
    for entry in AtlasOfGroupRepresentationsInfo.ringinfo do
      Add( lines, Concatenation( "AGR.RNG(\"", entry[1], "\",\"", entry[2],
                                 "\");\n" ) );
    od;
    Sort( lines );
    for line in lines do
      Append( str, line );
    od;

    # Append the information about compatibility of maxes scripts.
    Append( str, "\n\n" );
    Append( str, sepline );
    Append( str, "\n##\n##  " );
    Append( str,
        "Store information which straight line programs for restricting to maximal\n" );
    Append( str,
        "##  subgroups of a group can be used also for restricting to maximal\n" );
    Append( str, "##  subgroups of downward extensions.\n" );
    Append( str, "##\n" );
    lines:= [];
    for nam in RecNames( toc ) do
      if IsRecord( toc.( nam ) ) and IsBound( toc.( nam ).maxext ) then
        for entry in toc.( nam ).maxext do
          Add( lines, Concatenation( "AGR.TOCEXT(\"", nam, "\",",
            String( entry[1] ), ",", String( entry[2] ), ",",
            ReplacedString( String( entry[3] ), " ", "" ), ");\n" ) );
        od;
      fi;
    od;
    Sort( lines );
    for line in lines do
      Append( str, line );
    od;

    # Append the primitivity information.
    Append( str, "\n\n" );
    Append( str, sepline );
    Append( str, "\n##\n##  " );
    Append( str,
        "Store information about the point stabilizers of permutation\n" );
    Append( str, "##  representations if known.\n" );
    Append( str,
        "##  Note that the filenames do not contain this information,\n" );
    Append( str, "##  so it has to be stored explicitly.\n" );
    Append( str, "##\n" );
    lines:= [];
    for nam in RecNames( AtlasOfGroupRepresentationsInfo.permrepinfo ) do
      r:= AtlasOfGroupRepresentationsInfo.permrepinfo.( nam );
      if not IsBound( r.isPrivate ) then
        line:= Concatenation( "AGR.API(\"", nam, "\",[" );
        Append( line, String( r.transitivity ) );
        Append( line, "," );
        if r.transitivity = 0 then
          Append( line, ReplacedString( String( r.orbits ), " ", "" ) );
          Append( line, "]);\n" );
        else
          Append( line, String( r.rankAction ) );
          Append( line, "," );
          if r.isPrimitive then
            Append( line, "\"prim\"" );
          else
            Append( line, "\"imprim\"" );
          fi;
          Append( line, ",\"" );
          Append( line, r.stabilizer );
          Append( line, "\"" );
          if r.isPrimitive then
            Append( line, "," );
            if IsInt( r.maxnr ) then
              Append( line, String( r.maxnr ) );
            else
              Append( line, "\"" );
              Append( line, String( r.maxnr ) );
              Append( line, "\"" );
            fi;
          fi;
          Append( line, "]);\n" );
        fi;
        Add( lines, line );
      fi;
    od;
    Sort( lines );
    for line in lines do
      Append( str, line );
    od;

    # Append the character information.
    Append( str, "\n\n" );
    Append( str, sepline );
    Append( str, "\n##\n##  precomputed character data\n" );
    Append( str, "##\n" );
    lines:= [];
    for nam in RecNames( AtlasOfGroupRepresentationsInfo.characterinfo ) do
      map:= AtlasOfGroupRepresentationsInfo.characterinfo.( nam );
      for i in [ 1 .. Length( map ) ] do
        if IsBound( map[i] ) then
          for j in [ 1 .. Length( map[i][1] ) ] do
            line:= Concatenation( "AGR.CHAR(\"", nam, "\",\"", map[i][2][j], "\"," );
#T only for the non-private ones!
            if i = 1 then
              Append( line, "0" );
            else
              Append( line, String( i ) );
            fi;
            Append( line, "," );
            Append( line, ReplacedString( String( map[i][1][j] ), " ", "" ) );
            if map[i][3][j] <> fail then
              Append( line, ",\"" );
              Append( line, map[i][3][j] );
              Append( line, "\"" );
            fi;
            Append( line, ");\n" );
            Add( lines, line );
          od;
        fi;
      od;
    od;
    Sort( lines );
    for line in lines do
      Append( str, line );
    od;

    # Finally, append the current date and time.
    Append( str, "\n\n" );
    Append( str, "AtlasOfGroupRepresentationsInfo.TableOfContents.( \"" );
    Append( str, string );
    Append( str, "\" ).lastupdated:=\n  \"" );
    Append( str, toc.lastupdated );
    Append( str, "\";\n\n" );
    Append( str, sepline );
    Append( str, "\n##\n#E\n\n" );

    return str;
end );


#############################################################################
##
#F  AGR.TablesOfContents( <descr> )
##
##  Admissible arguments are
##  1 the string "all",
##  2 the string "public",
##  3 a string describing a private table of contents,
##    (which occurs as the second component of an entry in
##    `AtlasOfGroupRepresentationsInfo.private') or
##  4 a list of conditions such as [ <std>, "contents", <...> ]
##  5 a list of strings as 1-3.
##
AGR.TablesOfContents:= function( descr )
    local pos, tocid, i, label, tocs, flag, toc, pair;

    if descr = [] then
      descr:= [ "all" ];
    elif IsString( descr ) then
      descr:= [ descr ];
    elif not IsList( descr ) then
      Error( "<descr> must be a string or a list of strings/conditions" );
    fi;

    pos:= Position( descr, "contents" );
    if pos <> fail then
      # `descr' is a list of conditions.
      # Evaluate its "contents" part,
      # i. e., restrict the tables of contents, and remove this condition.
      tocid:= descr[ pos+1 ];
      for i in [ pos .. Length( descr ) - 2 ] do
        descr[i]:= descr[ i+2 ];
      od;
      Unbind( descr[ Length( descr ) ] );
      Unbind( descr[ Length( descr ) ] );
      if IsString( tocid ) then
        descr:= [ tocid ];
      else
        descr:= tocid;
      fi;
    elif ForAny( descr, x -> x <> "all" and x <> "public"
                        and ForAll( AtlasOfGroupRepresentationsInfo.private,
                                    pair -> x <> pair[2] ) ) then
      # `descr' is a list of conditions that does not restrict the
      # table of contents.
      descr:= [ "all" ];
    fi;

    # Now `descr' is a list of identifiers of tables of contents.
    label:= JoinStringsWithSeparator( SortedList( descr ), "|" );
    if not IsBound( AtlasOfGroupRepresentationsInfo.TOC_Cache.( label ) ) then
      tocs:= [];
      if descr = "all" or descr = "public" or
         "all" in descr or "public" in descr then
        flag:= String( AtlasOfGroupRepresentationsInfo.remote );
        if not IsBound( AtlasOfGroupRepresentationsInfo.TOC_Cache.(
                          flag ) ) then
          if flag = "true" then
            toc:= AtlasTableOfContents( "remote" ).TableOfContents;
          else
            toc:= AtlasTableOfContents( "local" ).TableOfContents;
          fi;
          AtlasOfGroupRepresentationsInfo.TOC_Cache.( flag ):= toc;
        fi;
        Add( tocs, AtlasOfGroupRepresentationsInfo.TOC_Cache.( flag ) );
      fi;
      for pair in AtlasOfGroupRepresentationsInfo.private do
        if descr = "all" or "all" in descr or
           descr = pair[2] or pair[2] in descr then
          Add( tocs,
               AtlasOfGroupRepresentationsInfo.TableOfContents.( pair[2] ) );
        fi;
      od;
      AtlasOfGroupRepresentationsInfo.TOC_Cache.( label ):= tocs;
    fi;
    return AtlasOfGroupRepresentationsInfo.TOC_Cache.( label );
end;


#############################################################################
##
#F  AtlasOfGroupRepresentationsNotifyPrivateDirectory( <dir>[, <dirid>]
#F     [, <test>] )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsNotifyPrivateDirectory,
    function( arg )
    local dirname, dirid, test, oldtest, olddata, dir, prm, toc,
          allfilenames, RemovedDirectories,
          groupname, record, type, entry, name, tocs, ok, oldtoc, names,
          unknown, nam;

    # Get and check the arguments.
    if 1 <= Length( arg ) and Length( arg ) <= 3 and
       ( IsString( arg[1] ) or IsDirectory( arg[1] ) ) and
       ( Length( arg ) = 1 or ( IsString( arg[2] ) or IsBool( arg[2] ) ) ) and
       ( Length( arg ) < 3 or ( IsString( arg[2] ) and IsBool( arg[3] ) ) ) then
      if IsString( arg[1] ) then
        dirname:= ShallowCopy( arg[1] );
      else
        dir:= arg[1];
        dirname:= ShallowCopy( dir![1] );
#T this is not clean!
#T (how to call DirectoryContents for a directory given as an object?)
      fi;
      if Length( arg ) = 1 then
        dirid:= dirname;
      elif IsString( arg[2] ) or Length( arg ) = 3 then
        dirid:= arg[2];
      else
        dirid:= dirname;
      fi;
      if Length( arg ) = 1 then
        test:= false;
      elif IsBool( arg[2] ) then
        test:= arg[2];
      elif Length( arg ) = 3 then
        test:= arg[3];
      else
        test:= false;
      fi;
    else
      Error( "usage: AtlasOfGroupRepresentationsNotifyPrivateDirectory(\n",
             "  <dirname>[,<dirid>][,<test>])" );
    fi;

    # Add the directory name.
    if IsEmpty( dirname ) then
      Error( "<dirname> must not be empty" );
    elif dirname[ Length( dirname ) ] <> '/' then
      Add( dirname, '/' );
    fi;
    if ForAny( AtlasOfGroupRepresentationsInfo.private,
               pair -> pair[2] = dirid and pair[1] <> dirname ) then
      Error( dirid,
             " is already the identifier of another private directory" );
    fi;
    AddSet( AtlasOfGroupRepresentationsInfo.private, [ dirname, dirid ] );

    # Read the primary file (for group declarations and describing data).
    # The file may contain calls of `AGR.GNAN' (which must come *before* the
    # data for the groups in question can be notified) and of `AGR.API' and
    # `AGR.CHAR' (which must come *afterwards*).
    # So we must postpone the calls of `AGR.IsRepNameAvailable'.
    oldtest:= IsBound( AtlasOfGroupRepresentationsInfo.checkData );
    Unbind( AtlasOfGroupRepresentationsInfo.checkData );
    olddata:= rec(
      permrepinfo:= RecNames( AtlasOfGroupRepresentationsInfo.permrepinfo ),
      );
#T same for characters!

    prm:= Filename( dir, "toc.g" );
    if IsExistingFile( prm ) = true then
      Read( prm );
    fi;

    # Set up a table of contents for the private directory.
    toc:= AtlasTableOfContents( dirid ).TableOfContents;
    Unbind( toc.otherfiles );

    # Check that no filename of this table of contents exists already in
    # other tables of contents.
    # 1. Compute the list of all filenames.
    allfilenames:= [];

    RemovedDirectories:= function( string )
      string:= SplitString( string, "/" );
      return string[ Length( string ) ];
    end;

    for groupname in RecNames( toc ) do
      record:= toc.( groupname );
      if IsRecord( record ) then
        for type in RecNames( record ) do
          for entry in record.( type ) do
            name:= entry[ Length( entry ) ];
            if IsString( name ) then
              Add( allfilenames, RemovedDirectories( name ) );
            else
              Append( allfilenames, List( name, RemovedDirectories ) );
            fi;
          od;
        od;
      fi;
    od;

    # 2. Check whether the list is disjoint to the other tables of contents.
#T this is expensive
    if AtlasOfGroupRepresentationsInfo.remote = true then
      tocs:= [ AtlasTableOfContents( "remote" ).TableOfContents ];
    else
      tocs:= [ AtlasTableOfContents( "local" ).TableOfContents ];
    fi;
    Append( tocs, List( Filtered( AtlasOfGroupRepresentationsInfo.private,
                                  pair -> pair[2] <> dirid ),
        x -> AtlasOfGroupRepresentationsInfo.TableOfContents.( x[2] ) ) );
    ok:= true;
    for oldtoc in tocs do
      for groupname in RecNames( toc ) do
        if IsBound( oldtoc.( groupname ) ) then
          record:= oldtoc.( groupname );
          if IsRecord( record ) then
            for type in RecNames( record ) do
              for entry in record.( type ) do
                names:= entry[ Length( entry ) ];
                if IsString( names ) then
                  names:= [ names ];
                fi;
                for name in names do
                  if name in allfilenames then
                    ok:= false;
                    Info( InfoAtlasRep, 1,
                          "file `", name, "' was already in another t.o.c." );
#T better remove the entry for this file
                  fi;
                od;
              od;
            od;
          fi;
        fi;
      od;
    od;

    # Add group names that were not notified.
    unknown:= Set( Filtered( RecNames( toc ),
                       x -> ForAll( AtlasOfGroupRepresentationsInfo.GAPnames,
                                    pair -> x <> pair[2] ) ) );
    RemoveSet( unknown, "diridPrivate" );
    RemoveSet( unknown, "lastupdated" );
    if not IsEmpty( unknown ) then
      ok:= false;
      Info( InfoAtlasRep, 1,
            "no GAP names defined for ", unknown );
      UniteSet( AtlasOfGroupRepresentationsInfo.GAPnames,
                List( unknown, x -> [ x, x ] ) );
    fi;

    AGR.SetGAPnamesSortDisp();
    AtlasOfGroupRepresentationsInfo.TOC_Cache:= rec();
    AtlasOfGroupRepresentationsInfo.TableOfContents.merged:= rec();

    # Run the postponed tests.
    if test then
      AtlasOfGroupRepresentationsInfo.checkData:= true;
      for nam in Difference(
                   RecNames( AtlasOfGroupRepresentationsInfo.permrepinfo ),
                   olddata.permrepinfo ) do
        AtlasOfGroupRepresentationsInfo.permrepinfo.( nam ).isPrivate:= true;
        ok:= AGR.IsRepNameAvailable( nam ) and ok;
      od;
#T check also the characters!
    fi;

    # Restore the original flag.
    if not oldtest then
      Unbind( AtlasOfGroupRepresentationsInfo.checkData );
    fi;

    # Return the flag.
    return ok;
    end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsForgetPrivateDirectory( <dirid> )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsForgetPrivateDirectory,
    function( dirid )
    local private, i, dirname, dir, prm, str, file, GAPnames, pos, pos2,
          gapname, j;

    Unbind( AtlasOfGroupRepresentationsInfo.TableOfContents.( dirid ) );
    GAPnames:= AtlasOfGroupRepresentationsInfo.GAPnames;

    private:= AtlasOfGroupRepresentationsInfo.private;
    for i in [ 1 .. Length( private ) ] do
      if private[i][2] = dirid then

        # Remove the group declarations.
        dirname:= private[i][1];
        dir:= Directory( dirname );
        prm:= Filename( dir, "toc.g" );
        if IsExistingFile( prm ) = true then
          str:= StringFile( prm );
          pos:= PositionSublist( str, "GNAN" );
          while pos <> fail do
            while pos <= Length( str ) and str[ pos ] <> '"' do
              pos:= pos + 1;
              pos2:= Position( str, '"', pos );
              if pos2 <> fail then
                gapname:= str{ [ pos+1 .. pos2-1 ] };
                for j in [ 1 .. Length( GAPnames ) ] do
                  if IsBound( GAPnames[j] ) and GAPnames[j][1] = gapname then
                    Unbind( GAPnames[j] );
                    Unbind( AGR.GAPnamesRec.( gapname ) );
                    break;
                  fi;
                od;
              fi;
            od;
            pos:= PositionSublist( str, "GNAN", pos2 );
          od;
        fi;

        # Remove the information concerning the private directory.
        Unbind( private[i] );
        AtlasOfGroupRepresentationsInfo.private:= Compacted( private );
        break;

      fi;
    od;

    AtlasOfGroupRepresentationsInfo.GAPnames:= Compacted( GAPnames );
    AGR.SetGAPnamesSortDisp();
    AtlasOfGroupRepresentationsInfo.TOC_Cache:= rec();
    end );


if IsString( SingleHTTPRequest ) then
  Unbind( SingleHTTPRequest );
fi;
if IsString( IO_stat ) then
  Unbind( IO_stat );
fi;


#############################################################################
##
#E

#str:= StringOfAtlasTableOfContents( "remote" );;
#FileString( "fil", str );

