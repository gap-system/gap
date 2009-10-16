#############################################################################
##
#W  access.gi            GAP 4 package AtlasRep                 Thomas Breuer
##
#H  @(#)$Id: access.gi,v 1.99 2009/07/29 15:13:51 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains functions for accessing data from the ATLAS of Group
##  Representations.
##
Revision.( "atlasrep/gap/access_gi" ) :=
    "@(#)$Id: access.gi,v 1.99 2009/07/29 15:13:51 gap Exp $";


#############################################################################
##
##  If the IO package is not installed then an error message is avoided
##  via the following assignment.
##
if not IsBound( SingleHTTPRequest ) then
  SingleHTTPRequest:= "dummy";
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
#T do this outside?

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

if IsString( SingleHTTPRequest ) then
  Unbind( SingleHTTPRequest );
fi;


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
#F  AGRFileContents( <dirname>, <groupname>, <filename>, <type> )
##
InstallGlobalFunction( AGRFileContents,
    function( dirname, groupname, filename, type )
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
end );


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
    for type in AGRDataTypes( "rep", "prg" ) do
      if AGRParseFilenameFormat( filename, type[2].FilenameFormat )
             <> fail then
        return AtlasOfGroupRepresentationsLocalFilenameTransfer( dirname,
                   groupname, filename, type )[1];
      fi;
    od;
    return fail;
end );


#############################################################################
##
#F  AGR_InfoForName( <gapname> )
##
BindGlobal( "AGR_InfoForName", function( gapname )
    local pos;

    pos:= PositionSorted( AtlasOfGroupRepresentationsInfo.GAPnames,
                          [ gapname ] );
    if pos <= Length( AtlasOfGroupRepresentationsInfo.GAPnames ) and
       AtlasOfGroupRepresentationsInfo.GAPnames[ pos ][1] = gapname then
      return AtlasOfGroupRepresentationsInfo.GAPnames[ pos ];
    else
      return fail;
    fi;
end );


#############################################################################
##
#F  AGRGNAN( <gapname>, <atlasname>[, <size>[, <maxessizes>[, "all"
#F           [, <compatinfo>]]]] )
##
InstallGlobalFunction( AGRGNAN, function( arg )
    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) then
      if   ForAny( AtlasOfGroupRepresentationsInfo.GAPnames,
                   pair -> arg[1] = pair[1] ) then
        Error( "cannot notify `", arg[1], "' more than once" );
      elif ForAny( AtlasOfGroupRepresentationsInfo.GAPnames,
                   pair -> arg[2] = pair[2] ) then
        Error( "ambiguous GAP names for ATLAS name `", arg[2], "'" );
      elif IsBound( arg[3] ) and not IsPosInt( arg[3] ) then
        Error( "third entry of <arg>, if given, must be a positive integer" );
      elif IsBound( arg[4] ) and
           not ( IsList( arg[4] ) and ForAll( arg[4], IsPosInt ) ) then
        Error( "fourth entry of <arg>, if given, must be ",
               "a list of positive integers" );
      elif IsBound( arg[5] ) and not IsString( arg[5] ) then
        Error( "fifth entry of <arg>, if given, must be a string" );
      elif IsBound( arg[6] ) and not IsList( arg[6] ) then
        Error( "sixth entry of <arg>, if given, must be a list" );
      fi;
    fi;
    MakeImmutable( arg );
    AddSet( AtlasOfGroupRepresentationsInfo.GAPnames, arg );
#T really AddSet?
end );


#############################################################################
##
#F  AGR_SetGAPnamesSortDisp()
##
AGR_SetGAPnamesSortDisp:= function()
    local list;

    list:= ShallowCopy( AtlasOfGroupRepresentationsInfo.GAPnames );
    SortParallel( List( list, x -> x[1] ), list,
                  BrowseData_CompareAsNumbersAndNonnumbers );
    AtlasOfGroupRepresentationsInfo.GAPnamesSortDisp:= list;
end;


#############################################################################
##
#F  AGRParseFilenameFormat( <string>, <format> )
##
InstallGlobalFunction( "AGRParseFilenameFormat", function( string, format )
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
end );


#############################################################################
##
#F  AGRRNG( <filename>, <descr> )
##
InstallGlobalFunction( AGRRNG, function( filename, descr )
    local triple;

    triple:= [ filename, descr, EvalString( descr ) ];
    if triple in AtlasOfGroupRepresentationsInfo.ringinfo then
      Info( InfoAtlasRep, 1,
            "triple `", triple, "' cannot be notified more than once" );
    else
      Add( AtlasOfGroupRepresentationsInfo.ringinfo, triple );
    fi;
end );


#############################################################################
##
#F  AGRAPI( <repname>, <info> )
##
##  <info> is a list with the following entries:
##  - At position 1, the transitivity is stored.
##  - If the transitivity is zero then the second entry is the list of
##    orbit lengths.
##  - If the transitivity is positive then the second entry is the rank
##    of the action.
##  - If the transitivity is positive then the third entry is one of the
##    strings `"prim"', `"imprim"', denoting primitivity or not.
##  - If the transitivity is positive then the fourth entry is a string
##    that describes the structure of the point stabilizer.
##  - If the third entry is `"prim"' then the fifth entry is either `"???"'
##    or it denotes the number of the class of maximal subgroups
##    that are the point stabilizers.
##
InstallGlobalFunction( AGRAPI, function( repname, info )
    local r;

    if IsBound( AtlasOfGroupRepresentationsInfo.permrepinfo.( repname ) ) then
      Error( "cannot notify this again" );
    fi;
    r:= rec( transitivity:= info[1] );
    if 0 < info[1] then
      r.rankAction:= info[2];
      r.isPrimitive:= ( info[3] = "prim" );
      r.stabilizer:= info[4];
      if r.isPrimitive then
        r.maxnr:= info[5];
      fi;
    else
      r.orbits:= info[2];
    fi;
    AtlasOfGroupRepresentationsInfo.permrepinfo.( repname ):= r;
end );


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
    for type in AGRDataTypes( "rep", "prg" ) do
      format:= AGRParseFilenameFormat( filename, type[2].FilenameFormat );
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
    for name in filelist do
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
                     List( AGRDataTypes( "rep" ), x -> [ "datagens", x ] ),
                     List( AGRDataTypes( "prg" ), x -> [ "dataword", x ] ) );
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
    result.diridPrivate:= string;

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
InstallGlobalFunction( StoreAtlasTableOfContents, function( filename )
    local toc, pos, pos2;

    if IsExistingFile( filename ) and not IsWritableFile( filename ) then
      Error( "<filename> must be writable if exists" );
    elif not IsBound( AtlasOfGroupRepresentationsInfo.TableOfContents.(
                          "remote" ) ) then
      Error( "no remote t.o.c. exists" );
    fi;

    # Copy the constant part of the data to the desired file.
    toc:= StringFile( Filename( DirectoriesPackageLibrary( "atlasrep", "gap" ),
                                "atlasprm.g" ) );
    pos:= PositionSublist( toc, "##  Establish the bijection" );
    pos2:= PositionSublist( toc, "do not edit" );
    pos2:= Position( toc, '\n', pos2 );
    toc:= toc{ [ pos .. pos2 ] };
    Append( toc, "##\n\n" );
    FileString( filename, toc );

    # Add the data.
    AppendTo( filename,
        StringOfAtlasTableOfContents( "remote" ),
        "##################################################################",
        "###########\n##\n#E\n\n" );
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
#T the file is assumed to contain only calls to AGRGNAN, AGRRNG, AGRTOC!
    priv:= AtlasOfGroupRepresentationsInfo.private;
    AtlasOfGroupRepresentationsInfo.GAPnames := [];
    AtlasOfGroupRepresentationsInfo.GAPnamesSortDisp:= [];
    AtlasOfGroupRepresentationsInfo.groupnames := [];
    AtlasOfGroupRepresentationsInfo.ringinfo := [];
    AtlasOfGroupRepresentationsInfo.private := [];

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
    local toc, str, triple, groupname, reps, type, entry, i;

    toc:= AtlasTableOfContents( string ).TableOfContents;
    str:= "";

    for triple in AtlasOfGroupRepresentationsInfo.groupnames do

      # Start with the notification of the group.
      Append( str, "# " );
      Append( str, triple[3] );
      Append( str, "\n" );
      Append( str, "AGRGRP(\"" );
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
        for type in AGRDataTypes( "rep", "prg" ) do
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
        if IsBound( toc.( groupname ).maxextprg ) then
          for entry in toc.( groupname ).maxextprg do
            Append( str, Concatenation( "AGRTOCEXT(\"", groupname,
                             "\",\"", entry[1], "\",[" ) );
            for i in entry[2] do
              Append( str, ReplacedString( String( i ), " ", "" ) );
              Append( str, "," );
            od;
            Append( str, "]);\n" );
          od;
        fi;
        if IsBound( toc.( groupname ).maxext ) then
          for entry in toc.( groupname ).maxext do
            Append( str, Concatenation( "AGRTOCEXT(\"", groupname, "\",",
                           String( entry[1] ), ",", String( entry[2] ),
                           ",[" ) );
            for i in entry[3] do
              Append( str, Concatenation( "\"", i, "\"," ) );
            od;
            Append( str, "]);\n" );
          od;
        fi;
      fi;

      Append( str, "\n" );

    od;

    # Append the current date and time.
    Append( str, "\n" );
    Append( str, "AtlasOfGroupRepresentationsInfo.TableOfContents.( \"" );
    Append( str, string );
    Append( str, "\" ).lastupdated:=\n  \"" );
    Append( str, toc.lastupdated );
    Append( str, "\";\n\n" );

    return str;
end );


#############################################################################
##
#F  AGR_TablesOfContents( <descr> )
##
##  Admissible arguments are
##  - the string "all",
##  - the string "public",
##  - a string describing a private table of contents, or
##  - a list of strings as above.
##
BindGlobal( "AGR_TablesOfContents", function( descr )
    local label, tocs, flag, toc, pair;

    if IsString( descr ) then
      label:= descr;
    else
      label:= JoinStringsWithSeparator( SortedList( descr ), "|" );
    fi;

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
end );


#############################################################################
##
#F  AGRGRP( <dirname>, <simpname>, <groupname> )
##
InstallGlobalFunction( AGRGRP,
    function( dirname, simpname, groupname )
    local entry;

    if ForAll( AtlasOfGroupRepresentationsInfo.GAPnames,
               pair -> pair[2] <> groupname ) then

      # There is no corresponding {\GAP} name.
      AddSet( AtlasOfGroupRepresentationsInfo.GAPnames,
              Immutable( [ groupname, groupname ] ) );
      AGR_SetGAPnamesSortDisp();
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
end );


#############################################################################
##
#F  AGRTOC( <arg> )
##
InstallGlobalFunction( AGRTOC, function( arg )
    local type, string, t, record, entry, groupname, added, j;

    # Get the arguments.
    type:= arg[1];
    if Length( arg ) = 3 then
      string:= Concatenation( arg[2], "1" );
    else
      string:= arg[2];
    fi;

    # Parse the filename with the given format info.
    # type:= First( AGRDataTypes( "rep", "prg" ), x -> x[1] = type );
    for t in AGRDataTypes( "rep", "prg" ) do
      if t[1] = type then
        type:= t;
        break;
      fi;
    od;
    record:= AtlasTableOfContents( "remote" ).TableOfContents;
    entry:= AGRParseFilenameFormat( string, type[2].FilenameFormat );
    if entry = fail then
      Info( InfoAtlasRep, 1, "`", arg, "' is not a valid t.o.c. entry" );
      return;
    fi;

    # Get the list for the data in the record for the group name.
    groupname:= entry[1];
    if IsBound( AtlasOfGroupRepresentationsInfo.checkData ) and
       ForAll( AtlasOfGroupRepresentationsInfo.groupnames,
               x -> x[3] <> groupname ) then
      Info( InfoAtlasRep, 1, "`", groupname, "' is not a valid group name" );
      return;
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
end );


#############################################################################
##
#F  AGRTOCEXT( <atlasname>, <factname>, <lines> )
#F  AGRTOCEXT( <atlasname>, <std>, <maxnr>, <files> )
##
InstallGlobalFunction( AGRTOCEXT, function( arg )
    local record, groupname;

    if Length( arg ) < 3 or not IsString( arg[1] ) then
      Info( InfoAtlasRep, 1, "`", arg, "' is not a valid t.o.c.ext entry" );
      return;
    fi;
    record:= AtlasTableOfContents( "remote" ).TableOfContents;
    groupname:= arg[1];
    if ForAll( AtlasOfGroupRepresentationsInfo.GAPnames,
               x -> x[2] <> groupname )  then
      Info( InfoAtlasRep, 1, "`", groupname, "' is not a valid group name" );
      return;
    fi;
    if not IsBound( record.( groupname ) ) then
      record.( groupname ):= rec();
    fi;
    record:= record.( groupname );
    if   IsString( arg[2] ) and IsDenseList( arg[3] ) then
      # Notify lines of a straight line program.
      if not IsBound( record.maxextprg )  then
        record.maxextprg:= [];
      fi;
      if ForAny( record.maxextprg, x -> x[1] = arg[2] ) then
        Info( InfoAtlasRep, 1, "`", arg,
              "' is not a valid t.o.c.ext entry" );
        return;
      fi;
      Add( record.maxextprg, arg{ [ 2, 3 ] } );
    elif Length( arg ) = 4 and IsPosInt( arg[2] ) and IsPosInt( arg[3] )
                           and IsList( arg[4] )
                           and ForAll( arg[4], IsString ) then
      if not IsBound( record.maxext )  then
        record.maxext:= [];
      fi;
      Add( record.maxext, arg{ [ 2 .. 4 ] } );
    else
      Info( InfoAtlasRep, 1, "`", arg, "' is not a valid t.o.c.ext entry" );
    fi;
end );


#############################################################################
##
#F  AtlasOfGroupRepresentationsNotifyPrivateDirectory( <dir>[, <dirid>] )
##
InstallGlobalFunction( AtlasOfGroupRepresentationsNotifyPrivateDirectory,
    function( arg )
    local dirname, dirid, dir, prm, toc, allfilenames, RemovedDirectories,
          groupname, record, type, entry, name, tocs, ok, oldtoc, names,
          unknown;

    # Get and check the arguments.
    if   Length( arg ) = 1 and IsString( arg[1] ) then
      dirname:= ShallowCopy( arg[1] );
      dirid:= dirname;
      dir:= Directory( dirname );
    elif Length( arg ) = 1 and IsDirectory( arg[1] ) then
      dir:= arg[1];
      dirname:= ShallowCopy( dir![1] );
#T this is not clean!
#T (how to call DirectoryContents for a directory given as an object?)
      dirid:= dirname;
    elif Length( arg ) = 2 and IsString( arg[1] ) and IsString( arg[2] ) then
      dirname:= ShallowCopy( arg[1] );
      dirid:= ShallowCopy( arg[2] );
      dir:= Directory( dirname );
    elif Length( arg ) = 2 and IsDirectory( arg[1] )
                           and IsString( arg[2] ) then
      dir:= arg[1];
      dirname:= ShallowCopy( dir![1] );
      dirid:= ShallowCopy( arg[2] );
    else
      Error( "usage: AtlasOfGroupRepresentationsNotifyPrivateDirectory(\n",
             "<dirname>[,<dirid>])" );
    fi;

    AtlasOfGroupRepresentationsInfo.checkData:= true;

    # Read the primary file (for the group declarations).
    prm:= Filename( dir, "toc.g" );
    if IsExistingFile( prm ) = true then
      Read( prm );
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

    AGR_SetGAPnamesSortDisp();
    AtlasOfGroupRepresentationsInfo.TOC_Cache:= rec();
    Unbind( AtlasOfGroupRepresentationsInfo.checkData );

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
          pos:= PositionSublist( str, "AGRGNAN" );
          while pos <> fail do
            while pos <= Length( str ) and str[ pos ] <> '"' do
              pos:= pos + 1;
              pos2:= Position( str, '"', pos );
              if pos2 <> fail then
                gapname:= str{ [ pos+1 .. pos2-1 ] };
                for j in [ 1 .. Length( GAPnames ) ] do
                  if IsBound( GAPnames[j] ) and GAPnames[j][1] = gapname then
                    Unbind( GAPnames[j] );
                    break;
                  fi;
                od;
              fi;
            od;
            pos:= PositionSublist( str, "AGRGNAN", pos2 );
          od;
        fi;

        # Remove the information concerning the private directory.
        Unbind( private[i] );
        AtlasOfGroupRepresentationsInfo.private:= Compacted( private );
        break;

      fi;
    od;

    AtlasOfGroupRepresentationsInfo.GAPnames:= Compacted( GAPnames );
    AGR_SetGAPnamesSortDisp();
    AtlasOfGroupRepresentationsInfo.TOC_Cache:= rec();
    end );


#############################################################################
##
#E

