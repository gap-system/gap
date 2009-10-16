#############################################################################
##
#W  package.gi                  GAP Library                      Frank Celler
#W                                                           Alexander Hulpke
##
#H  @(#)$Id: package.gi,v 4.5 2009/08/19 14:04:32 gap Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains support for &GAP; packages.
##
Revision.package_gi :=
    "@(#)$Id: package.gi,v 4.5 2009/08/19 14:04:32 gap Exp $";


#############################################################################
##
#F  CompareVersionNumbers( <supplied>, <required>[, "equal"] )
##
InstallGlobalFunction( CompareVersionNumbers, function( arg )
    local s, r, inequal, i, j, a, b;

    s:= arg[1];
    r:= arg[2];
    inequal:= not ( Length( arg ) = 3 and arg[3] = "equal" );

    # Deal with the case of a `dev' version.
    if   2 < Length( s )
       and s{ [ Length( s ) - 2 .. Length( s ) ] } = "dev" then
      return inequal or ( Length(r)>2 and r{[Length(r)-2..Length(r)]}="dev" );
    elif 2 < Length( r )
       and r{ [ Length( r ) - 2 .. Length( r ) ] } = "dev" then
      return false;
    fi;

    while 0 < Length( s ) or 0 < Length( r ) do

      # Remove leading non-digit characters.
      i:= 1;
      while i <= Length( s ) and not IsDigitChar( s[i] ) do
        i:= i+1;
      od;
      s:= s{ [ i .. Length( s ) ] };
      j:= 1;
      while j <= Length( r ) and not IsDigitChar( r[j] ) do
        j:= j+1;
      od;
      r:= r{ [ j .. Length( r ) ] };

      # If one of the two strings is empty then we are done.
      if   Length( s ) = 0 then
        return Length( r ) = 0;
      elif Length( r ) = 0 then
        return inequal;
      fi;

      # Compare the next portion of digit characters.
      i:= 1;
      while i <= Length( s ) and IsDigitChar( s[i] ) do
        i:= i+1;
      od;
      a:= Int( s{ [ 1 .. i-1 ] } );
      j:= 1;
      while j <= Length( r ) and IsDigitChar( r[j] ) do
        j:= j+1;
      od;
      b:= Int( r{ [ 1 .. j-1 ] } );
      if   a < b then
        return false;
      elif b < a then
        return inequal;
      fi;
      s:= s{ [ i .. Length( s ) ] };
      r:= r{ [ j .. Length( r ) ] };

    od;

    # The two remaining strings are empty.
    return true;
end );


#############################################################################
##
#F  PackageInfo( <pkgname> )
##
InstallGlobalFunction( PackageInfo, function( pkgname )
    pkgname:= LowercaseString( pkgname );
    if not IsBound( GAPInfo.PackagesInfo.( pkgname ) ) then
      return [];
    else
      return GAPInfo.PackagesInfo.( pkgname );
    fi;
    end );


#############################################################################
##
#F  RECORDS_FILE( <name> )
##
InstallGlobalFunction( RECORDS_FILE, function( name )
    local str, rows, recs, pos, r;

    str:= StringFile( name );
    if str = fail then
      return [];
    fi;
    rows:= SplitString( str, "", "\n" );
    recs:= [];
    for r in rows do
      # remove comments starting with `#'
      pos:= Position( r, '#' );
      if pos <> fail then
        r:= r{ [ 1 .. pos-1 ] };
      fi;
      Append( recs, SplitString( r, "", " \n\t\r" ) );
    od;
    return List( recs, LowercaseString );
    end );


#############################################################################
##
#F  SetPackageInfo( <record> )
##
InstallGlobalFunction( SetPackageInfo, function( record )
    GAPInfo.PackageInfoCurrent:= record;
    end );


#############################################################################
##
#F  InitializePackagesInfoRecords( <delay> )
##
InstallGlobalFunction( InitializePackagesInfoRecords, function( delay )
    local dirs, pkgdirs, pkgdir, names, noauto, packagedirs, name, pkgpath,
          file, files, subdirs, subdir, str, record, pkgname, version;

    if IsBound( GAPInfo.PackagesInfoInitialized ) and
       GAPInfo.PackagesInfoInitialized = true then
      # This function has already been executed in this sesion.
      return;
    elif delay = true then
      # Delay the initialization until the first `TestPackageAvailability'
      # call if autoloading is disabled.
      GAPInfo.PackagesNames:= [];
      return;
    fi;

    LogPackageLoadingMessage( PACKAGE_DEBUG,
        "enter InitializePackagesInfoRecords" );
    dirs:= [];
    pkgdirs:= DirectoriesLibrary( "pkg" );
    if pkgdirs = fail then
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "exit InitializePackagesInfoRecords (no pkg directories found)" );
      return;
    fi;

    GAPInfo.PackagesInfo:= [];
    GAPInfo.PackagesInfoAutoloadDocumentation:= [];
    GAPInfo.PackagesInfoRefuseLoad:= [];

    # Loop over the package directories.
    # (We consider the subdirectories and `NOAUTO' files for each directory,
    # and then unite the autoloadable packages for the directories.)
    for pkgdir in pkgdirs do

      # Ignore the filenames listed in the file `pkg/NOAUTO'.
      noauto:= RECORDS_FILE( Filename( pkgdir, "NOAUTO" ) );

      # Loop over subdirectories of the package directory.
      packagedirs:= DirectoryContents( Filename( pkgdir, "" ) );
      for name in packagedirs do
        pkgpath:= Filename( [ pkgdir ], name );
        # This can be 'fail' if 'name' is a void link.
        if pkgpath <> fail and IsDirectoryPath( pkgpath )
                           and not name in [ ".", ".." ] then
          file:= Filename( [ pkgdir ],
                           Concatenation( name, "/PackageInfo.g" ) );
          if file = fail then
            # Perhaps some subdirectories contain `PackageInfo.g' files.
            files:= [];
            subdirs:= DirectoryContents( pkgpath );
            for subdir in subdirs do
              if not subdir in [ ".", ".." ] then
                pkgpath:= Filename( [ pkgdir ],
                                    Concatenation( name, "/", subdir ) );
                if pkgpath <> fail and IsDirectoryPath( pkgpath )
                                   and not subdir in [ ".", ".." ] then
                  file:= Filename( [ pkgdir ],
                      Concatenation( name, "/", subdir, "/PackageInfo.g" ) );
                  if file <> fail then
                    Add( files,
                         [ file, Concatenation( name, "/", subdir ) ] );
                  fi;
                fi;
              fi;
            od;
          else
            files:= [ [ file, name ] ];
          fi;

          for file in files do

            # Read the `PackageInfo.g' file.
            Unbind( GAPInfo.PackageInfoCurrent );
            Read( file[1] );
            record:= GAPInfo.PackageInfoCurrent;
            Unbind( GAPInfo.PackageInfoCurrent );
            pkgname:= LowercaseString( record.PackageName );
            NormalizeWhitespace( pkgname );
            version:= record.Version;
  
            # If we have this version already then leave it out.
            if ForAll( GAPInfo.PackagesInfo,
                r ->    r.PackageName <> record.PackageName
                     or r.Version <> version ) then
  
              # Check whether GAP wants to reset loadability.
              if     IsBound( GAPInfo.PackagesRestrictions.( pkgname ) )
                 and GAPInfo.PackagesRestrictions.( pkgname ).OnInitialization(
                         record ) = false then
                Add( GAPInfo.PackagesInfoRefuseLoad, record );
              else
                record.InstallationPath:= Filename( [ pkgdir ], file[2] );
                if not IsBound( record.PackageDoc ) then
                  record.PackageDoc:= [];
                elif IsRecord( record.PackageDoc ) then
                  record.PackageDoc:= [ record.PackageDoc ];
                fi;
                Add( GAPInfo.PackagesInfo, record );
                if not name in noauto then
                  if ForAny( record.PackageDoc,
                        r -> IsBound( r.Autoload ) and r.Autoload = true ) then
                    Add( GAPInfo.PackagesInfoAutoloadDocumentation, record );
                  fi;
                fi;
              fi;
  
            fi;
          od;
        fi;
      od;
    od;

    # Sort the available info records by their version numbers.
    for record in [ GAPInfo.PackagesInfo,
                    GAPInfo.PackagesInfoAutoloadDocumentation ] do
      SortParallel( List( record, r -> r.Version ), record,
                    CompareVersionNumbers );
    od;

    # Turn the lists into records.
    record:= rec();
    for name in Set( List( GAPInfo.PackagesInfo,
                           r -> LowercaseString( r.PackageName ) ) ) do
      record.( name ):= Filtered( GAPInfo.PackagesInfo,
                            r -> LowercaseString( r.PackageName ) = name );
    od;
    GAPInfo.PackagesInfo:= record;

    # Autoloading documentation makes sense only for not autoloaded packages.
    record:= rec();
    for name in Set( List( GAPInfo.PackagesInfoAutoloadDocumentation,
                           r -> LowercaseString( r.PackageName ) ) ) do
      record.( name ):= Filtered( GAPInfo.PackagesInfoAutoloadDocumentation,
                            r -> LowercaseString( r.PackageName ) = name );
    od;
    GAPInfo.PackagesInfoAutoloadDocumentation:= record;

    # `GAPInfo.Dependencies' describes for which packages automatic loading
    # is suggested.
    # (Users may remove some packages via their `.gaprc' files.)
    GAPInfo.PackagesNames:= List( Concatenation(
        GAPInfo.Dependencies.NeededOtherPackages,
        GAPInfo.Dependencies.SuggestedOtherPackages ),
        x -> x[1] );

    GAPInfo.PackagesInfoInitialized:= true;
    LogPackageLoadingMessage( PACKAGE_DEBUG,
        "exit InitializePackagesInfoRecords" );
    end );


#############################################################################
##
#I  InfoPackageLoading
##
DeclareInfoClass( "InfoPackageLoading" );

SetInfoLevel( InfoPackageLoading, 1 );


#############################################################################
##
#F  LogPackageLoadingMessage( <severity>, <message> )
##
if not IsBound( TextAttr ) then
  TextAttr:= "dummy";
fi;

InstallGlobalFunction( LogPackageLoadingMessage,
    function( severity, message )
    local currpkg;

    currpkg:= GAPInfo.PackagesCurrentlyLoaded[ Length(
                  GAPInfo.PackagesCurrentlyLoaded ) ];
    if severity <= PACKAGE_WARNING and IsBound( ANSI_COLORS )
       and ANSI_COLORS = true and IsBound( TextAttr )
       and IsRecord( TextAttr ) then
      if severity = PACKAGE_ERROR then
        message:= Concatenation( TextAttr.1, message, TextAttr.reset );
      else
        message:= Concatenation( TextAttr.4, message, TextAttr.reset );
      fi;
    fi;
    Add( GAPInfo.PackageLoadingMessages, [ currpkg, severity, message ] );

    Info( InfoPackageLoading, severity, currpkg, ": ", message );
    end );

if not IsReadOnlyGlobal( TextAttr ) then
  Unbind( TextAttr );
fi;


#############################################################################
##
#F  DisplayPackageLoadingLog( [<severity>] )
##
InstallGlobalFunction( DisplayPackageLoadingLog, function( arg )
    local severity, entry;

    if Length( arg ) = 0 then
      severity:= 2;
    else
      severity:= arg[1];
    fi;

    for entry in GAPInfo.PackageLoadingMessages do
      if severity >= entry[2] then
        Info( InfoPackageLoading, 1, entry[1], ": ", entry[3] );
      fi;
    od;
    end );


#############################################################################
##
#F  TestPackageAvailability( <name>, <version>[, <intest>] )
##
InstallGlobalFunction( TestPackageAvailability, function( arg )
    local name, version, intest, equal, pair, inforec, dep, init;

    # 0. Get the arguments.
    name:= LowercaseString( arg[1] );
    version:= arg[2];
    if Length( arg ) = 2 then
      intest:= [];
    else
      intest:= arg[3];
    fi;
    equal:= "";
    if 0 < Length( version ) and version[1] = '=' then
      equal:= "equal";
    fi;

    # 1. If the package `name' is already loaded then compare the version
    #    number of the loaded package with the required one.
    #    (Note that at most one version of a package can be available.)
    if IsBound( GAPInfo.PackagesLoaded.( name ) ) then
      if CompareVersionNumbers( GAPInfo.PackagesLoaded.( name )[2],
                                version, equal ) then
        return true;
      else
        return fail;
      fi;
    fi;

    # 2. Initialize if this was not yet done.
    #    (When GAP was started with a workspace then this procedure is
    #    started only when the first package is requested that was not yet
    #    loaded in the workspace.
    #    This is why we first checked whether the package is already loaded.)
    InitializePackagesInfoRecords( false );

    # 3. If `name' is among the packages from whose availability test
    #    the current check for `name' arose,
    #    and if the correspondent version number is at least `version'
    #    then return `true'.
    #    (Note that the availability for that package will be decided
    #    on an outer level.)
    for pair in intest do
      if name = pair[1]
         and CompareVersionNumbers( pair[2], version, equal ) then
        return true;
      fi;
    od;

    # 4. Get the info records for the package `name',
    #    and take the first record that satisfies the conditions.
    #    (Note that they are ordered w.r.t. descending version numbers.)
    for inforec in PackageInfo( name ) do

      if IsBound( inforec.Dependencies ) then
        dep:= inforec.Dependencies;
      else
        dep:= rec();
      fi;

      if     CompareVersionNumbers( inforec.Version, version, equal )
         and inforec.AvailabilityTest() = true
         and ( not IsBound( dep.GAP )
               or CompareVersionNumbers( GAPInfo.Version, dep.GAP ) )
         and ( not IsBound( dep.NeededOtherPackages ) or
               ForAll( dep.NeededOtherPackages,
                       pair -> TestPackageAvailability( pair[1], pair[2],
                         Concatenation( intest, [ [ name, version ] ] ) )
                         <> fail ) ) then

        # Print a warning if the package should better be upgraded.
        if IsBound( GAPInfo.PackagesRestrictions.( name ) ) then
          GAPInfo.PackagesRestrictions.( name ).OnLoad( inforec );
        fi;

        # Locate the `init.g' file of the package.
        init:= Filename( [ Directory( inforec.InstallationPath ) ], "init.g" );
        if init = fail  then
          LogPackageLoadingMessage( PACKAGE_DEBUG,
              Concatenation( "cannot locate `", inforec.InstallationPath,
                "/init.g', please check the installation" ) );
        else
          return inforec.InstallationPath;
        fi;

      fi;

    od;

    # No info record satisfies the requirements.
    if not IsBound( GAPInfo.PackagesInfo.( name ) ) then
      inforec:= First( GAPInfo.PackagesInfoRefuseLoad,
                       r -> LowercaseString( r.PackageName ) = name );
      if inforec <> fail then
        # Some versions are installed but all were refused.
        GAPInfo.PackagesRestrictions.( name ).OnLoad( inforec );
      fi;
    else
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "no installed version fulfills the requirements" );
    fi;

    return fail;
    end );


#############################################################################
##
#F  IsPackageMarkedForLoading( <name>, <version> )
##
InstallGlobalFunction( IsPackageMarkedForLoading, function( name, version )
    local equal;

    equal:= "";
    if 0 < Length( version ) and version[1] = '=' then
      equal:= "equal";
    fi;
    name:= LowercaseString( name );
    return IsBound( GAPInfo.PackagesLoaded.( name ) )
           and CompareVersionNumbers( GAPInfo.PackagesLoaded.( name )[2], 
                   version, equal );
    end );


#############################################################################
##
#F  DefaultPackageBannerString( <inforec> )
##
InstallGlobalFunction( DefaultPackageBannerString, function( inforec )
    local sep, str, authors, role, fill, i, person;

    # Start with a row of `-' signs.
    sep:= ListWithIdenticalEntries( SizeScreen()[1] - 3, '-' );
    Add( sep, '\n' );
    str:= ShallowCopy( sep );

    # Add package name and version number.
    if IsBound( inforec.PackageName ) and IsBound( inforec.Version ) then
      Append( str, Concatenation(
              "Loading  ", inforec.PackageName, " ", inforec.Version ) );
    fi;

    # Add the long title.
    if IsBound( inforec.PackageDoc[1] ) and
       IsBound( inforec.PackageDoc[1].LongTitle ) and
       not IsEmpty( inforec.PackageDoc[1].LongTitle ) then
      Append( str, Concatenation(
              " (", inforec.PackageDoc[1].LongTitle, ")" ) );
    fi;
    Add( str, '\n' );

    # Add info about the authors if there are authors;
    # otherwise add maintainers.
    if IsBound( inforec.Persons ) then
      authors:= Filtered( inforec.Persons, x -> x.IsAuthor );
      role:= "by ";
      if IsEmpty( authors ) then
        authors:= Filtered( inforec.Persons, x -> x.IsMaintainer );
        role:= "maintained by ";
      fi;
      fill:= List( role, x -> ' ' );
      Append( str, role );
      for i in [ 1 .. Length( authors ) ] do
        person:= authors[i];
        Append( str, person.FirstNames );
        Append( str, " " );
        Append( str, person.LastName );
        if   IsBound( person.WWWHome ) then
          Append( str, Concatenation( " (", person.WWWHome, ")" ) );
        elif IsBound( person.Email ) then
          Append( str, Concatenation( " (", person.Email, ")" ) );
        fi;
        if   i = Length( authors ) then
          Append( str, ".\n" );
        elif i = Length( authors )-1 then
          if i = 1 then
            Append( str, " and\n" );
          else
            Append( str, ", and\n" );
          fi;
          Append( str, fill );
        else
          Append( str, ",\n" );
          Append( str, fill );
        fi;
      od;
    fi;

    # Add info about the home page of the package.
    if IsBound( inforec.WWWHome ) then
      Append( str, "(See also " );
      Append( str, inforec.PackageWWWHome );
      Append( str, ".)\n" );
    fi;

    Append( str, sep );

    str:= ReplacedString( str, "&auml;", "\"a" );
    str:= ReplacedString( str, "&ouml;", "\"o" );
    str:= ReplacedString( str, "&uuml;", "\"u" );

    return str;
    end );


#############################################################################
##
#F  DirectoriesPackagePrograms( <name> )
##
InstallGlobalFunction( DirectoriesPackagePrograms, function( name )
    local arch, dirs, info, version, r, path;

    arch := GAPInfo.Architecture;
    dirs := [];
    # For the reason described above, we are not allowed to call
    # `InstalledPackageVersion', `TestPackageAvailability' etc.
    if not IsBound( GAPInfo.PackagesLoaded.( name ) ) then
      InitializePackagesInfoRecords( false );
    fi;
    info:= PackageInfo( name );
    if IsBound( GAPInfo.PackagesLoaded.( name ) ) then
      version:= GAPInfo.PackagesLoaded.( name )[2];
    elif 0 < Length( info ) then
      version:= info[1].Version;
    else
      version:= "";
    fi;
    for r in info do
      if r.Version = version then
        path:= Concatenation( r.InstallationPath, "/bin/", arch, "/" );
        Add( dirs, Directory( path ) );
      fi;
    od;
    return dirs;
end );


#############################################################################
##
#F  DirectoriesPackageLibrary( <name>[, <path>] )
##
InstallGlobalFunction( DirectoriesPackageLibrary, function( arg )
    local name, path, dirs, info, version, r, tmp;

    if IsEmpty(arg) or 2 < Length(arg) then
        Error( "usage: DirectoriesPackageLibrary( <name>[, <path>] )\n" );
    elif not ForAll(arg, IsString) then
        Error( "string argument(s) expected\n" );
    fi;

    name:= LowercaseString( arg[1] );
    if '\\' in name or ':' in name  then
        Error( "<name> must not contain '\\' or ':'" );
    fi;

    if 1 = Length(arg)  then
        path := "lib";
    else
        path := arg[2];
    fi;

    dirs := [];
    # For the reason described above, we are not allowed to call
    # `InstalledPackageVersion', `TestPackageAvailability' etc.
    if not IsBound( GAPInfo.PackagesLoaded.( name ) ) then
      InitializePackagesInfoRecords( false );
    fi;
    info:= PackageInfo( name );
    if IsBound( GAPInfo.PackagesLoaded.( name ) ) then
      version:= GAPInfo.PackagesLoaded.( name )[2];
    elif 0 < Length( info ) then
      version:= info[1].Version;
    else
      version:= "";
    fi;
    for r in info do
      if r.Version = version then
        tmp:= Concatenation( r.InstallationPath, "/", path );
        if IsDirectoryPath( tmp ) = true then
          Add( dirs, Directory( tmp ) );
        fi;
      fi;
    od;
    return dirs;
end );


#############################################################################
##
#F  ReadPackage( [<name>, ]<file> )
#F  RereadPackage( [<name>, ]<file> )
##
InstallGlobalFunction( ReadPackage, function( arg )
    local pos, relpath, pkgname, namespace, filename, rflc, rfc;

    # Note that we cannot use `ReadAndCheckFunc' because this calls
    # `READ_GAP_ROOT', but here we have to read the file in one of those
    # directories where the package version resides that has been loaded
    # or (at least currently) would be loaded.
    if   Length( arg ) = 1 then
      # Guess the package name.
      pos:= Position( arg[1], '/' );
      relpath:= arg[1]{ [ pos+1 .. Length( arg[1] ) ] };
      pkgname:= arg[1]{ [ 1 .. pos-1 ] };
      namespace := pkgname;
    elif Length( arg ) = 2 then
      pkgname:= LowercaseString( arg[1] );
      namespace := arg[1];
      relpath:= arg[2];
    else
      Error( "expected 1 or 2 arguments" );
    fi;

    filename:= Filename( DirectoriesPackageLibrary( pkgname, "" ), relpath );
    if filename <> fail and IsReadableFile( filename ) then
      ENTER_NAMESPACE(namespace);
      Read( filename );
      LEAVE_NAMESPACE();
      return true;
    else
      return false;
    fi;
    end );

InstallGlobalFunction( RereadPackage, function( arg )
    local res;

    MakeReadWriteGlobal( "REREADING" );
    REREADING:= true;
    MakeReadOnlyGlobal( "REREADING" );
    res:= CallFuncList( ReadPackage, arg );
    MakeReadWriteGlobal( "REREADING" );
    REREADING:= false;
    MakeReadOnlyGlobal( "REREADING" );
    return res;
    end );


#############################################################################
##
#F  LoadPackageDocumentation( <info>, <all> )
##
InstallGlobalFunction( LoadPackageDocumentation, function( info, all )
    local short, pkgdoc, long, sixfile;

    # Depending on `all', load all books for the package or only the ones
    # that are marked as autoloadable.
    for pkgdoc in info.PackageDoc do
      if all or ( IsBound( pkgdoc.Autoload ) and pkgdoc.Autoload = true ) then

        # Fetch the names.
        if IsBound( pkgdoc.LongTitle ) then
          long:= pkgdoc.LongTitle;
        else
          long:= Concatenation( "GAP Package `", info.PackageName, "'" );
        fi;
        short:= pkgdoc.BookName;
        if not IsBound( GAPInfo.PackagesLoaded.( LowercaseString(
                            info.PackageName ) ) ) then
          short:= Concatenation( short, " (not loaded)" );
        fi;

        # Check that the `manual.six' file is available.
        sixfile:= Filename( [ Directory( info.InstallationPath ) ],
                            pkgdoc.SixFile );
        if sixfile = fail then
          Info( InfoWarning, 2,
                "book `", pkgdoc.BookName, "' for package `",
                info.PackageName, "': no manual index file `",
                pkgdoc.SixFile, "', ignored" );
        else
          # Finally notify the book via its directory.
#T Here we assume that this is the directory that contains also `manual.six'!
          HELP_ADD_BOOK( short, long,
              Directory( sixfile{ [ 1 .. Length( sixfile )-10 ] } ) );
        fi;

      fi;
    od;
    end );


#############################################################################
##
#F  LoadPackage( <name>[, <version>[, <banner>[, <outercalls>]]] )
##
InstallGlobalFunction( LoadPackage, function( arg )
    local name, version, banner, outercalls, loadsuggested, path, info,
          filename, read, dep, pair, u, pkg, bannerstring, fun;

    # Get the arguments.
    name:= LowercaseString( arg[1] );
    version:= "";
    if 1 < Length( arg ) then
      version:= arg[2];
    fi;
    banner:= not GAPInfo.CommandLineOptions.q and
             not GAPInfo.CommandLineOptions.b and
             not ( 2 < Length( arg ) and arg[3] = false );
    outercalls:= [ [], [] ];
    if Length( arg ) = 4 then
      outercalls:= arg[4];
    fi;
    loadsuggested:= ( ValueOption( "OnlyNeeded" ) <> true );

    # Start logging.
    LogPackageLoadingMessage( PACKAGE_DEBUG, Concatenation(
        "entering LoadPackage for ", name ) );
    Add( GAPInfo.PackagesCurrentlyLoaded, name );
    if name in outercalls[1] then
      LogPackageLoadingMessage( PACKAGE_DEBUG, Concatenation(
          "return from LoadPackage (already loading ", name, ")" ) );
      Unbind( GAPInfo.PackagesCurrentlyLoaded[
          Length( GAPInfo.PackagesCurrentlyLoaded ) ] );
      return true;
    fi;

    # Test whether the package is available.
    path:= TestPackageAvailability( name, version );
    if not IsString( path ) then
      # either `true' or `fail'
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          Concatenation( "return from LoadPackage, ",
              "TestPackageAvailability returned ", String( path ) ) );
      Unbind( GAPInfo.PackagesCurrentlyLoaded[
          Length( GAPInfo.PackagesCurrentlyLoaded ) ] );
      return path;
    fi;

    # First mark the package as loaded,
    # so `TestPackageAvailability' will return `true' or `fail' if the
    # package `name' is required from a needed or suggested package,
    # depending on the version number.
    info:= First( PackageInfo( name ), r -> r.InstallationPath = path );
    GAPInfo.PackagesLoaded.( name ):=
        [ path, info.Version, info.PackageName ];
#T remove this as soon as possible ...
PACKAGES_VERSIONS.( name ):= info.Version;

    # This is the first attempt to read stuff for this package.
    # So we handle the case of a `PreloadFile' entry.
    if IsBound( info.PreloadFile ) then
      filename:= USER_HOME_EXPAND( info.PreloadFile );
      if filename[1] = '/' then
        read:= READ( filename );
      else
        read:= ReadPackage( name, filename );
      fi;
      if not read then
        Info( InfoWarning, 2,
              "file `", filename, "' cannot be read" );
      fi;
    fi;

    # Notify the documentation (for the available version).
    LoadPackageDocumentation( info, true );

    # Whenever a package requires another package,
    # the inner call is performed with four arguments.
    # Thus we delay reading the implementation part until all
    # declaration parts have been read.
    if Filename( [ Directory( path ) ], "read.g" ) <> fail then
      Add( outercalls[1], name );
      Add( outercalls[2], info );
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "marking the package for later reading read.g" );
    fi;

    if IsBound( info.Dependencies ) then
      # Load the needed other packages.
      # (This is expected to work because of `TestPackageAvailability' above.)
      dep:= info.Dependencies;
      if IsBound( dep.NeededOtherPackages ) then
        for pair in dep.NeededOtherPackages do
          LogPackageLoadingMessage( PACKAGE_DEBUG,
              Concatenation( "trying to load needed package ", pair[1] ) );
          if LoadPackage( pair[1], pair[2], banner, outercalls ) <> true then
            # The package was classified as available, but we cannot load it?
            LogPackageLoadingMessage( PACKAGE_ERROR,
                Concatenation( "cannot load needed package ", pair[1] ) );
            Unbind( GAPInfo.PackagesCurrentlyLoaded[
                Length( GAPInfo.PackagesCurrentlyLoaded ) ] );
            return fail;
          fi;
          LogPackageLoadingMessage( PACKAGE_DEBUG,
              Concatenation( "needed package ", pair[1],
                  " (version ", pair[2], ") loaded" ) );
        od;
      fi;

      # Try to load the suggested other packages,
      # and issue a warning for each such package where this is not possible.
      if IsBound( dep.SuggestedOtherPackages ) then
        if loadsuggested then
          for pair in dep.SuggestedOtherPackages do
            if LoadPackage( pair[1], pair[2], banner, outercalls ) <> true then
              LogPackageLoadingMessage( PACKAGE_DEBUG,
                  Concatenation( "suggested package ", pair[1],
                      " (version ", pair[2], ") cannot be loaded" ) );
            fi;
          od;
        elif not IsEmpty( dep.SuggestedOtherPackages ) then
          LogPackageLoadingMessage( PACKAGE_DEBUG,
              "omitting suggested packages" );
        fi;
      fi;
    fi;

    # Read the `init.g' file.
#T Perhaps a package in ``old'' format is read from `.gaprc',
#T so the obsolete function names are not yet known.
if GAPInfo.ReadObsolete <> false and not IsBoundGlobal( "ReadPkg" ) then
  RereadLib( "obsolete.g" );
fi;
    LogPackageLoadingMessage( PACKAGE_DEBUG, "reading file init.g" );
#T Ignore possible `RequirePackage' calls in `init.g' files.
#T (Remove this as soon as `RequirePackage' is removed.)
RequirePackage:= ReturnTrue;
    Read( Filename( Directory( path ), "init.g" ) );
    LogPackageLoadingMessage( PACKAGE_DEBUG, "file init.g read" );
RequirePackage:= LoadPackage;

    # If the function was called on the outermost level
    # then we read the implementation part of all those packages
    # that have been loaded in the meantime;
    # it is contained in the file `read.g' in each package home directory.
    # If wanted then show also the package banners.
    if Length( arg ) <> 4 then
      for pkg in Reversed( outercalls[1] ) do
        LogPackageLoadingMessage( PACKAGE_DEBUG, Concatenation(
            "reading file read.g of package ", pkg ) );
        ReadPackage( pkg, "read.g" );
        LogPackageLoadingMessage( PACKAGE_DEBUG, Concatenation(
            "file read.g of package ", pkg, " read" ) );
      od;
    fi;

    Unbind( GAPInfo.PackagesCurrentlyLoaded[
        Length( GAPInfo.PackagesCurrentlyLoaded ) ] );

    if Length( arg ) <> 4 and banner then
      for info in Reversed( outercalls[2] ) do
        # If the component `BannerString' is bound in `info' then we print
        # this string, otherwise we print the default banner string.
        if IsBound( info.BannerString ) then
          bannerstring:= info.BannerString;
        else
          bannerstring:= DefaultPackageBannerString( info );
        fi;
        # Be aware of umlauts, accents etc. in the banner.
        if IsBoundGlobal( "Unicode" ) and IsBoundGlobal( "Encode" )
           and not "gapdoc" in GAPInfo.PackagesCurrentlyLoaded then
          fun:= ValueGlobal( "Unicode" );
          u:= fun( bannerstring, "UTF-8" );
          if u = fail then
          u:= fun( bannerstring, "ISO-8859-1");
          fi;
          fun:= ValueGlobal( "Encode" );
          Print( fun( u, GAPInfo.TermEncoding ) );
        else
          # GAPDoc is not available, simply print the banner string as is.
          Print( bannerstring );
        fi;
      od;
    fi;

    LogPackageLoadingMessage( PACKAGE_DEBUG, Concatenation(
        "return from LoadPackage for ", name ) );
    return true;
    end );


#############################################################################
##
#F  LoadAllPackages()
##
InstallGlobalFunction( LoadAllPackages, function()
    InitializePackagesInfoRecords( false );
    List( RecNames( GAPInfo.PackagesInfo ), LoadPackage );
    end );


#############################################################################
##
#F  InstalledPackageVersion( <name> )
##
InstallGlobalFunction( InstalledPackageVersion, function( name )
    local avail, info;

    avail:= TestPackageAvailability( name, "" );
    if   avail = fail then
      return fail;
    elif avail = true then
      return GAPInfo.PackagesLoaded.( LowercaseString( name ) )[2];
    fi;
    info:= First( PackageInfo( name ), r -> r.InstallationPath = avail );
    return info.Version;
    end );


#############################################################################
##
#F  AutoloadPackages()
##
InstallGlobalFunction( AutoloadPackages, function()
    local pair, name, record;

    # Load the needed other packages (suppressing banners)
    # that are not yet loaded.
    if ForAny( GAPInfo.Dependencies.NeededOtherPackages,
               p -> not IsBound( GAPInfo.PackagesLoaded.( p[1] ) ) ) then
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "trying to load needed packages of GAP" );
      for pair in GAPInfo.Dependencies.NeededOtherPackages do
        if LoadPackage( pair[1], pair[2], false ) <> true then
          LogPackageLoadingMessage( PACKAGE_ERROR, Concatenation(
              "needed package ", pair[1], " cannot be loaded" ) );
          Error( "failed to load needed package `", pair[1],
                 "' (version ", pair[2], ")" );
        elif not pair[1] in GAPInfo.PackagesNames then
          Error( "needed package `", pair[1],
                 "' (version ", pair[2], ") must not be excluded" );
        fi;
      od;
      LogPackageLoadingMessage( PACKAGE_DEBUG, "needed packages loaded" );
    fi;

    if not GAPInfo.CommandLineOptions.A then
      if ForAny( GAPInfo.Dependencies.SuggestedOtherPackages,
                 p -> not IsBound( GAPInfo.PackagesLoaded.( p[1] ) ) ) then
        if ValueOption( "OnlyNeeded" ) <> true then
          # Try to load the suggested other packages (suppressing banners),
          # issue a warning for each such package where this is not possible.
          LogPackageLoadingMessage( PACKAGE_DEBUG,
              "trying to load suggested packages of GAP" );
          for pair in GAPInfo.Dependencies.SuggestedOtherPackages do
            if pair[1] in GAPInfo.PackagesNames then
              LogPackageLoadingMessage( PACKAGE_DEBUG,
                  Concatenation( "considering for autoloading: ", pair[1] ) );
              if LoadPackage( pair[1], pair[2], false ) <> true then
                LogPackageLoadingMessage( PACKAGE_DEBUG,
                     Concatenation( "suggested package ", pair[1],
                         " (version ", pair[2], ") cannot be loaded" ) );
              fi;
              LogPackageLoadingMessage( PACKAGE_DEBUG,
                  Concatenation( pair[1], " loaded" ) );
            fi;
          od;
          LogPackageLoadingMessage( PACKAGE_DEBUG,
              "suggested packages loaded" );
        else
          LogPackageLoadingMessage( PACKAGE_DEBUG,
              "omitting suggested packages" );
        fi;
      fi;

      # Load the autoloadable documentation for not yet loaded packages.
      for name in RecNames( GAPInfo.PackagesInfoAutoloadDocumentation ) do
        if not IsBound( GAPInfo.PackagesLoaded.( name ) ) then
          record:= First( GAPInfo.PackagesInfoAutoloadDocumentation.( name ),
                          IsRecord );
          if IsRecord( record ) then
            LoadPackageDocumentation( record, false );
          fi;
        fi;
      od;
    fi;
    end );


#############################################################################
##
#F  ExcludeFromAutoload( <pkgname1>, <pkgname2>, ... )
##
InstallGlobalFunction( ExcludeFromAutoload, function( arg )
    SubtractSet( GAPInfo.PackagesNames, List(arg, LowercaseString) );
    end );


#############################################################################
##
#F  GAPDocManualLab(<pkgname>) . create manual.lab for package w/ GAPDoc docs
##
# avoid warning (will be def. in GAPDoc)
if not IsBound(StripEscapeSequences) then
  StripEscapeSequences := 0;
fi;
InstallGlobalFunction( GAPDocManualLabFromSixFile,
    function( bookname, sixfilepath )
    local stream, entries, SecNumber, esctex, file;

    stream:= InputTextFile( sixfilepath );
    entries:= HELP_BOOK_HANDLER.GapDocGAP.ReadSix( stream ).entries;
    SecNumber:= function( list )
      if IsEmpty( list ) or list[1] = 0 then
        return "";
      fi;
      while list[ Length( list ) ] = 0 do
        Unbind( list[ Length( list ) ] );
      od;
      return JoinStringsWithSeparator( List( list, String ), "." );
    end;

    # throw away TeX critical characters here
    esctex:= function( str )
      return Filtered( StripEscapeSequences( str ), c -> not c in "%#$&^_~" );
    end;

    bookname:= LowercaseString( bookname );
    entries:= List( entries,
                     entry -> Concatenation( "\\makelabel{", bookname, ":",
                                             esctex(entry[1]), "}{",
                                             SecNumber( entry[3] ), "}\n" ) );
    file:= Concatenation( sixfilepath{ [ 1 .. Length( sixfilepath ) - 3 ] },
                          "lab" );
    FileString( file, Concatenation( entries ) );
    Info( InfoWarning, 1, "File: ", file, " written." );
end );

InstallGlobalFunction( GAPDocManualLab, function(pkgname)
  local pinf, book, file;

  if not IsString(pkgname) then
    Error("argument <pkgname> should be a string\n");
  fi;
  pkgname := LowercaseString(pkgname);
  LoadPackage(pkgname);
  if not IsBound(GAPInfo.PackagesInfo.(pkgname)) then
    Error("Could not load package ", pkgname, ".\n");
  fi;
  if LoadPackage("GAPDoc") <> true then
    Error("package `GAPDoc' not installed. Please install `GAPDoc'\n" );
  fi;

  pinf := GAPInfo.PackagesInfo.(pkgname)[1];
  for book in pinf.PackageDoc do
    file := Filename([Directory(pinf.InstallationPath)], book.SixFile);
    if file = fail or not IsReadableFile(file) then
      Error("could not open `manual.six' file of package `", pkgname, "'.\n",
            "Please compile its documentation\n");
    fi;
    GAPDocManualLabFromSixFile( book.BookName, file );
#     stream := InputTextFile(file);
#     entries := HELP_BOOK_HANDLER.GapDocGAP.ReadSix(stream).entries;
#     SecNumber := function(list)
#       if IsEmpty(list) or list[1] = 0 then
#         return "";
#       fi;
#       while list[ Length(list) ] = 0 do
#         Unbind( list[ Length(list) ] );
#       od;
#       return JoinStringsWithSeparator( List(list, String), "." );
#     end;
# 
#     # throw away TeX critical characters here
#     esctex := function(str)
#       return Filtered(StripEscapeSequences(str), c-> not c in "%#$&^_~");
#     end;
# 
#     bookname := LowercaseString(book.BookName);
#     entries := List( entries,
#                      entry -> Concatenation( "\\makelabel{", bookname, ":",
#                                              esctex(entry[1]), "}{",
#                                              SecNumber( entry[3] ), "}\n" ) );
#     file := Concatenation(file{[1..Length(file)-3]}, "lab");
#     FileString( file, Concatenation(entries) );
#     Info(InfoWarning, 1, "File: ", file, " written.");
  od;
end );
if StripEscapeSequences = 0 then
  Unbind(StripEscapeSequences);
fi;


#############################################################################
##
#F  DeclareAutoreadableVariables( <pkgname>, <filename>, <varlist> )
##
InstallGlobalFunction( DeclareAutoreadableVariables,
    function( pkgname, filename, varlist )
    CallFuncList( AUTO, Concatenation( [
      function( x )
        # Avoid nested calls to `RereadPackage',
        # which could cause that `REREADING' is set to `false' too early.
        if REREADING then
          ReadPackage( pkgname, filename );
        else
          RereadPackage( pkgname, filename );
        fi;
      end, filename ], varlist ) );
    end );


#############################################################################
##
##  Tests whether loading a package works and does not obviously break
##  anything.
##  (This is very preliminary.)
##


#############################################################################
##
#F  ValidatePackageInfo( <record> )
#F  ValidatePackageInfo( <filename> )
##
InstallGlobalFunction( ValidatePackageInfo, function( record )
    local IsStringList, IsRecordList, IsProperBool,
          result,
          TestOption, TestMandat,
          subrec, list;

    if IsString( record ) then
      if IsReadableFile( record ) then
        Unbind( GAPInfo.PackageInfoCurrent );
        Read( record );
        if IsBound( GAPInfo.PackageInfoCurrent ) then
          record:= GAPInfo.PackageInfoCurrent;
          Unbind( GAPInfo.PackageInfoCurrent );
        else
          Error( "the file <record> is not a `PackageInfo.g' file" );
        fi;
      else
        Error( "<record> is not the name of a readable file" );
      fi;
    elif not IsRecord( record ) then
      Error( "<record> must be either a record or a filename" );
    fi;

    IsStringList:= x -> IsList( x ) and ForAll( x, IsString );
    IsRecordList:= x -> IsList( x ) and ForAll( x, IsRecord );
    IsProperBool:= x -> x = true or x = false;

    result:= true;

    TestOption:= function( record, name, type, typename )
    if IsBound( record.( name ) ) and not type( record.( name ) ) then
      Print( "#E  component `", name, "', if present, must be bound to ",
             typename, "\n" );
      result:= false;
      return false;
    fi;
    return true;
    end;

    TestMandat:= function( record, name, type, typename )
    if not IsBound( record.( name ) ) or not type( record.( name ) ) then
      Print( "#E  component `", name, "' must be bound to ",
             typename, "\n" );
      result:= false;
      return false;
    fi;
    return true;
    end;

    TestMandat( record, "PackageName",
        x -> IsString(x) and 0 < Length(x),
        "a nonempty string" );
    TestMandat( record, "Subtitle", IsString, "a string" );
    TestMandat( record, "Version",
        x -> IsString(x) and 0 < Length(x) and x[1] <> '=',
        "a nonempty string that does not start with `='" );
    TestMandat( record, "Date",
        x -> IsString(x) and Length(x) = 10 and x{ [3,6] } = "//"
                 and ForAll( x{ [1,2,4,5,7,8,9,10] }, IsDigitChar ),
        "a string of the form `dd/mm/yyyy'" );
    TestMandat( record, "ArchiveURL", IsString, "a string" );
    TestMandat( record, "ArchiveFormats", IsString, "a string" );
    TestOption( record, "TextFiles", IsStringList, "a list of strings" );
    TestOption( record, "BinaryFiles", IsStringList, "a list of strings" );
    if     TestOption( record, "Persons", IsRecordList, "a list of records" )
       and IsBound( record.Persons ) then
      for subrec in record.Persons do
        TestMandat( subrec, "LastName", IsString, "a string" );
        TestMandat( subrec, "FirstNames", IsString, "a string" );
        if not (    IsBound( subrec.IsAuthor )
                 or IsBound( subrec.IsMaintainer ) ) then
          Print( "#E  one of the components `IsAuthor', `IsMaintainer' ",
                 "must be bound\n" );
          result:= false;
        fi;
        TestOption( subrec, "IsAuthor", IsProperBool, "`true' or `false'" );
        TestOption( subrec, "IsMaintainer", IsProperBool,
            "`true' or `false'" );

        if not (    IsBound( subrec.Email ) or IsBound( subrec.WWWHome )
                 or IsBound( subrec.PostalAddress ) ) then
          Print( "#E  one of the components `Email', `WWWHome', ",
                 "`PostalAddress' must be bound\n" );
          result:= false;
        fi;
        TestOption( subrec, "Email", IsString, "a string" );
        TestOption( subrec, "WWWHome", IsString, "a string" );
        TestOption( subrec, "PostalAddress", IsString, "a string" );
        TestOption( subrec, "Place", IsString, "a string" );
        TestOption( subrec, "Institution", IsString, "a string" );
      od;
    fi;

    if TestMandat( record, "Status",
           x -> x in [ "accepted", "deposited", "dev", "other" ],
           "one of \"accepted\", \"deposited\", \"dev\", \"other\"" )
       and record.Status = "accepted" then
      TestMandat( record, "CommunicatedBy",
          x -> IsString(x) and PositionSublist( x, " (" ) <> fail
                   and x[ Length(x) ] = ')',
          "a string of the form `<name> (<place>)'" );
      TestMandat( record, "AcceptDate",
          x -> IsString( x ) and Length( x ) = 7 and x[3] = '/'
                   and ForAll( x{ [1,2,4,5,6,7] }, IsDigitChar ),
          "a string of the form `mm/yyyy'" );
    fi;
    TestMandat( record, "README_URL", IsString, "a string" );
    TestMandat( record, "PackageInfoURL", IsString, "a string" );
    TestMandat( record, "AbstractHTML", IsString, "a string" );
    TestMandat( record, "PackageWWWHome", IsString, "a string" );
    if TestMandat( record, "PackageDoc",
           x -> IsRecord( x ) or IsRecordList( x ),
           "a record or a list of records" ) then
      if IsRecord( record.PackageDoc ) then
        list:= [ record.PackageDoc ];
      else
        list:= record.PackageDoc;
      fi;
      for subrec in list do
        TestMandat( subrec, "BookName", IsString, "a string" );
        if not IsBound(subrec.Archive) and not
                                   IsBound(subrec.ArchiveURLSubset) then
          Print("#E  PackageDoc component must have `Archive' or \
`ArchiveURLSubset' component\n");
          result := false;
        fi;
        TestOption( subrec, "Archive", IsString, "a string" );
        TestOption( subrec, "ArchiveURLSubset", IsStringList,
                    "a list of strings" );
        TestMandat( subrec, "HTMLStart", IsString, "a string" );
        TestMandat( subrec, "PDFFile", IsString, "a string" );
        TestMandat( subrec, "SixFile", IsString, "a string" );
        TestMandat( subrec, "LongTitle", IsString, "a string" );
        TestMandat( subrec, "Autoload", IsProperBool, "`true' or `false'" );
      od;
    fi;
    if     TestOption( record, "Dependencies", IsRecord, "a record" )
       and IsBound( record.Dependencies ) then
      TestOption( record.Dependencies, "NeededOtherPackages",
          comp -> IsList( comp ) and ForAll( comp,
                      l -> IsList( l ) and Length( l ) = 2
                                       and ForAll( l, IsString ) ),
          "a list of pairs `[ <pkgname>, <pkgversion> ]' of strings" );
      TestOption( record.Dependencies, "SuggestedOtherPackages",
          comp -> IsList( comp ) and ForAll( comp,
                      l -> IsList( l ) and Length( l ) = 2
                                       and ForAll( l, IsString ) ),
          "a list of pairs `[ <pkgname>, <pkgversion> ]' of strings" );
      TestOption( record.Dependencies, "ExternalConditions",
          comp -> IsList( comp ) and ForAll( comp,
                      l -> IsString( l ) or ( IsList( l ) and Length( l ) = 2
                                      and ForAll( l, IsString ) ) ),
          "a list of strings or of pairs `[ <text>, <URL> ]' of strings" );
    fi;
    TestMandat( record, "AvailabilityTest", IsFunction, "a function" );
    TestOption( record, "BannerString", IsString, "a string" );
    TestMandat( record, "Autoload", IsProperBool, "`true' or `false'" );
    TestOption( record, "TestFile",
        x -> IsString( x ) and IsBound( x[1] ) and x[1] <> '/',
        "a string denoting a relative path" );
    TestOption( record, "PreloadFile", IsString, "a string" );
    TestOption( record, "Keywords", IsStringList, "a list of strings" );

    return result;
    end );


#############################################################################
##
#F  CheckPackageLoading( <pkgname> )
##
InstallGlobalFunction( CheckPackageLoading, function( pkgname )
    local result, oldinfo, i;

    result:= true;

    # Check that loading the package does not change info levels that were
    # defined before the package was loaded.
    oldinfo:= rec( CurrentLevels := ShallowCopy( InfoData.CurrentLevels ),
                   ClassNames := ShallowCopy( InfoData.ClassNames ) );
    LoadPackage( pkgname );
    for i in [ 1 .. Length( oldinfo.CurrentLevels ) ] do
      if oldinfo.CurrentLevels[i] <> InfoData.CurrentLevels[
             Position( InfoData.ClassNames, oldinfo.ClassNames[i] ) ] then
        Print( "#E  package `", pkgname, "' modifies info level of `",
               oldinfo.ClassNames[i], "'\n" );
        result:= false;
      fi;
    od;

    # Check the contents of the `PackageInfo.g' file of the package.
    Unbind( GAPInfo.PackageInfoCurrent );
    ReadPackage( pkgname, "PackageInfo.g" );
    if IsBound( GAPInfo.PackageInfoCurrent ) then
      result:= ValidatePackageInfo( GAPInfo.PackageInfoCurrent ) and result;
    else
      Print( "#E  missing or corrupted file `PackageInfo.g' for package `",
             pkgname, "'\n" );
      result:= false;
    fi;
    Unbind( GAPInfo.PackageInfoCurrent );

    return result;
    end );


#############################################################################
##
#V  GAPInfo.PackagesRestrictions
##
##  <ManSection>
##  <Var Name="GAPInfo.PackagesRestrictions"/>
##
##  <Description>
##  This is a mutable record, each component being the name of a package
##  <A>pkg</A> (in lowercase letters) that is required/recommended to be
##  updated to a certain version,
##  the value being a record with the following components.
##  <P/>
##  <List>
##  <Mark><C>OnInitialization</C></Mark>
##  <Item>
##      a function that takes one argument, the record stored in the
##      <F>PackageInfo.g</F> file of the package,
##      and returns <K>true</K> if the package can be loaded,
##      and returns <K>false</K> if not;
##      the function is allowed to change components of the argument record,
##      for example to reset the <C>Autoload</C> component to <K>false</K>;
##      it should not print any message,
##      this should be left to the <C>OnLoad</C> component,
##  </Item>
##  <Mark><C>OnLoad</C></Mark>
##  <Item>
##      a function that takes one argument, the record stored in the
##      <F>PackageInfo.g</F> file of the package, and can print a message
##      when the availability of the package is checked for the first time;
##      this message is thought to explain why the package cannot loaded due
##      to the <K>false</K> result of the <C>OnInitialization</C> component,
##      or as a warning about known problems (when the package is in fact
##      loaded), and it might give hints for upgrading the package.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##
GAPInfo.PackagesRestrictions := rec(
  anupq := rec(
    OnInitialization := function( pkginfo )
        if CompareVersionNumbers( pkginfo.Version, "1.3" ) = false then
          pkginfo.Autoload:= false;
          return false;
        fi;
        return true;
        end,
    OnLoad := function( pkginfo )
        if CompareVersionNumbers( pkginfo.Version, "1.3" ) = false then
          Print( "  The package `anupq'",
              " should better be upgraded at least to version 1.3,\n",
              "  the given version (", pkginfo.Version,
              ") is known to be incompatible\n",
              "  with the current version of GAP.\n",
              "  It is strongly recommended to update to the ",
              "most recent version, see URL\n",
              "      http://www.math.rwth-aachen.de/~Greg.Gamble/ANUPQ\n" );
        fi;
        end ),

  autpgrp := rec(
    OnInitialization := function( pkginfo )
        if CompareVersionNumbers( pkginfo.Version, "1.1" ) = false then
          pkginfo.Autoload:= false;
        fi;
        return true;
        end,
    OnLoad := function( pkginfo )
        if CompareVersionNumbers( pkginfo.Version, "1.1" ) = false then
          Print( "  The package `autpgrp'",
              " should better be upgraded at least to version 1.1,\n",
              "  the given version (", pkginfo.Version,
              ") is known to be incompatible\n",
              "  with the current version of GAP.\n",
              "  It is strongly recommended to update to the ",
              "most recent version, see URL\n",
              "      http://www-public.tu-bs.de:8080/~beick/so.html\n" );
        fi;
        end ) );


#############################################################################
##
#F  SuggestUpgrades( versions ) . . compare installed with distributed versions
##
InstallGlobalFunction( SuggestUpgrades, function( suggestedversions )
    local ok, outstr, out, entry, inform, info;

    suggestedversions := Set( List( suggestedversions, ShallowCopy ) );
    ok:= true;
    # We collect the output in a string, because availability test may
    # cause some intermediate printing. This way the output of the present
    # function comes after such texts.
    outstr := "";
    out := OutputTextString(outstr, true);
    PrintTo(out, "#I ======================================================",
                 "================ #\n",
                 "#I      Result of 'SuggestUpgrades':\n#I\n"
                 );
    # Deal with the kernel and library versions.
    entry:= First( suggestedversions, x -> x[1] = "GAPLibrary" );
    if entry = fail then
      PrintTo(out,  "#E  no info about suggested GAP library version ...\n" );
      ok:= false;
    elif not CompareVersionNumbers( GAPInfo.Version, entry[2] ) then
      PrintTo(out,  "#E  You are using version ", GAPInfo.Version,
             " of the GAP library.\n",
             "#E  Please upgrade to version ", entry[2], ".\n\n" );
      ok:= false;
    elif not CompareVersionNumbers( entry[2], GAPInfo.Version ) then
      PrintTo(out,  "#E  You are using version ", GAPInfo.Version,
             " of the GAP library.\n",
             "#E  This is newer than the distributed version ",
             entry[2], ".\n\n" );
      ok:= false;
    fi;
    RemoveSet( suggestedversions, entry );

    entry:= First( suggestedversions, x -> x[1] = "GAPKernel" );
    if entry = fail then
      PrintTo(out,  "#E  no info about suggested GAP kernel version ...\n" );
      ok:= false;
    elif not CompareVersionNumbers( GAPInfo.KernelVersion, entry[2] ) then
      PrintTo(out,  "#E  You are using version ", GAPInfo.KernelVersion,
             " of the GAP kernel.\n",
             "#E  Please upgrade to version ", entry[2], ".\n\n" );
      ok:= false;
    elif not CompareVersionNumbers( entry[2], GAPInfo.KernelVersion ) then
      PrintTo(out,  "#E  You are using version ", GAPInfo.KernelVersion,
             " of the GAP kernel.\n",
             "#E  This is newer than the distributed version ",
             entry[2], ".\n\n" );
      ok:= false;
    fi;
    RemoveSet( suggestedversions, entry );

    # Deal with present packages which are not distributed.
    LoadPackage("blubberblaxyz");
#T clean this!
    inform := Difference(NamesOfComponents(GAPInfo.PackagesInfo),
              List(suggestedversions, x-> LowercaseString(x[1])));
    if not IsEmpty( inform ) then
      PrintTo(out,  "#I  The following GAP packages are present but not ",
                    "officially distributed.\n" );
      for entry in inform do
        info := GAPInfo.PackagesInfo.(entry)[1];
        PrintTo(out,  "#I    ", info.PackageName, " ", info.Version, "\n" );
      od;
      PrintTo(out,  "\n" );
      ok:= false;
    fi;


    # Deal with packages that are not installed.
    inform := Filtered( suggestedversions, entry -> not IsBound(
                   GAPInfo.PackagesInfo.( LowercaseString( entry[1] ) ) )
                 and ForAll( GAPInfo.PackagesInfoRefuseLoad,
                             r -> LowercaseString( entry[1] )
                                  <> LowercaseString( r.PackageName ) ) );
    if not IsEmpty( inform ) then
      PrintTo(out,  "#I  The following distributed GAP packages are ",
                    "not installed.\n" );
      for entry in inform do
        PrintTo(out,  "#I    ", entry[1], " ", entry[2], "\n" );
      od;
      PrintTo(out,  "\n" );
      ok:= false;
    fi;
    SubtractSet( suggestedversions, inform );

    # Deal with packages whose installed versions are not available
    # (without saying anything about the reason).
#T Here it would be desirable to omit those packages that cannot be loaded
#T on the current platform; e.g., Windoofs users need not be informed about
#T packages for which no Windoofs version is available.
    # These packages can be up to date or outdated.
    for entry in suggestedversions do
      Add( entry, InstalledPackageVersion( entry[1] ) );
#T Here we may get print statements from the availability testers;
#T how to avoid this?
    od;
    inform:= Filtered( suggestedversions, entry -> entry[3] = fail );
    if not IsEmpty( inform ) then
      PrintTo(out,  "#I  The following GAP packages are present ",
             "but cannot be used.\n" );
      for entry in inform do
        PrintTo(out,  "#I    ", entry[1], " ",
             GAPInfo.PackagesInfo.( LowercaseString( entry[1] ) )[1].Version,
             "\n" );
        if not ForAny( GAPInfo.PackagesInfo.( LowercaseString( entry[1] ) ),
                   r -> CompareVersionNumbers( r.Version, entry[2] ) ) then
          PrintTo(out,  "#I         (distributed version is newer:   ",
                   entry[2], ")\n" );
        fi;
      od;
      PrintTo(out, "\n" );
      ok:= false;
    fi;
    SubtractSet( suggestedversions, inform );

    # Deal with packages in *newer* (say, dev-) versions than the
    # distributed ones.
    inform:= Filtered( suggestedversions, entry -> not CompareVersionNumbers(
                 entry[2], entry[3] ) );
    if not IsEmpty( inform ) then
      PrintTo(out,
             "#I  Your following GAP packages are *newer* than the ",
             "distributed version.\n" );
      for entry in inform do
        PrintTo(out,  "#I    ", entry[1], " ", entry[3],
               " (distributed is ", entry[2], ")\n" );
      od;
      PrintTo(out,  "\n" );
      ok:= false;
    fi;
    # Deal with packages whose installed versions are not up to date.
    inform:= Filtered( suggestedversions, entry -> not CompareVersionNumbers(
                 entry[3], entry[2] ) );
    if not IsEmpty( inform ) then
      PrintTo(out,
             "#I  The following GAP packages are available but outdated.\n" );
      for entry in inform do
        PrintTo(out,  "#I    ", entry[1], " ", entry[3],
               " (please upgrade to ", entry[2], ")\n" );
      od;
      PrintTo(out,  "\n" );
      ok:= false;
    fi;

    if ok then
      PrintTo(out,  "#I  Your GAP installation is up to date with the ",
      "official distribution.\n\n" );
    fi;
    CloseStream(out);
    Print( outstr );
    end );


NormalizedNameAndKey:= "dummy";
RepeatedString:= "dummy";
FormatParagraph:= "dummy";
Unicode:= "dummy";
Encode:= "dummy";

#############################################################################
##
#F  BibEntry( "GAP"[, <key>] )
#F  BibEntry( <pkgname>[, <key>] )
#F  BibEntry( <pkginfo>[, <key>] )
##
InstallGlobalFunction( BibEntry, function( arg )
    local key, pkgname, pkginfo, GAP, ps, months, val, entry, author;

    if LoadPackage( "GAPDoc" ) <> true then
      return fail;
    fi;

    key:= false;
    if   Length( arg ) = 1 and IsString( arg[1] ) then
      pkgname:= arg[1];
    elif Length( arg ) = 2 and IsString( arg[1] ) and IsString( arg[2] ) then
      pkgname:= arg[1];
      key:= arg[2];
    elif Length( arg ) = 1 and IsRecord( arg[1] ) then
      pkginfo:= arg[1];
    elif Length( arg ) = 2 and IsRecord( arg[1] ) and IsString( arg[2] ) then
      pkginfo:= arg[1];
      key:= arg[2];
    else
      Error( "usage: BibEntry( \"GAP\"[, <key>] ), ",
             "BibEntry( <pkgname>[, <key>] ), ",
             "BibEntry( <pkginfo>[, <key>] )" );
    fi;

    GAP:= false;
    if IsBound( pkgname ) then
      if pkgname = "GAP" then
        GAP:= true;
      else
        pkginfo:= PackageInfo( pkgname );
        if pkginfo = [] then
          return "";
        fi;
        pkginfo:= pkginfo[1];
      fi;
    fi;

    if key = false then
      if GAP then
        key:= Concatenation( "GAP", GAPInfo.Version );
      elif IsBound( pkginfo.Version ) then
        key:= Concatenation( pkginfo.PackageName, pkginfo.Version );
      else
        key:= pkginfo.PackageName;
      fi;
    fi;

    ps:= function( str )
      local uni;

      uni:= Unicode( str );
      if uni = fail then
        uni:= Unicode( str, "latin1" );
      fi;
      return Encode( uni );
    end;

    # According to \cite{La85},
    # the supported fields of a Bib{\TeX} entry of `@misc' type are
    # `author'
    #   computed from the `Persons' component of the package,
    #   not distinguishing authors and maintainers,
    #   keeping the order of entries,
    # `title'
    #   computed from the `PackageName' and `Subtitle' components
    #   of the package,
    # `month' and `year'
    #   computed from the `Date' component of the package,
    # `note'
    #   the string `"Refereed \\textsf{GAP} package"' or
    #   `"\\textsf{GAP} package"',
    # `howpublished'
    #   the `PackageWWWHome' component of the package.
    # Also the `edition' component seems to be supported;
    # it is computed from the `Version' component of the package.
    months:= [ "Jan", "Feb", "Mar", "Apr", "May", "Jun",
               "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ];
    if GAP then
      val:= SplitString( GAPInfo.Date, "-" );
      if Length( val ) = 3 then
        val:= Concatenation( "  <month>", months[ Int( val[2] ) ],
                             "</month>\n  <year>", val[3], "</year>\n" );
      else
        val:= "";
      fi;
      entry:= Concatenation(
        "<entry id=\"", key, "\"><manual>\n",
        "  <title><C>GAP</C> &ndash;",
        " <C>G</C>roups, <C>A</C>lgorithms, and <C>P</C>rogramming,\n",
        "         <C>V</C>ersion ", GAPInfo.Version, "</title>\n",
        "  <organization>The GAP-Group</organization>\n",
        val,
        "  <key>GAP</key>\n",
        "  <keywords>groups; *; gap; manual</keywords>\n",
        "  <url>http://www.gap-system.org</url>\n",
        "</manual></entry>" );
# ...
## Print(TemplateBibXML("misc"));
# str:= entry;
# val:= ParseBibXMLextString( str );
# Print( StringBibXMLEntry( val.entries[1], "BibTeX" ) );
# ...
    else
      entry:= Concatenation( "<entry id=\"", key, "\"><manual>\n" );
      author:= List( Filtered( pkginfo.Persons,
        person -> person.IsAuthor or person.IsMaintainer ),
          person -> Concatenation(
            "    <name><first>", person.FirstNames,
            "</first><last>", person.LastName, "</last></name>\n" ) );
      if not IsEmpty( author ) then
        Append( entry, Concatenation(
          "  <author>\n",
          ps( Concatenation( author ) ),
          "  </author>\n" ) );
      fi;
      Append( entry, Concatenation(
        "  <title><C>", pkginfo.PackageName, "</C>" ) );
      if IsBound( pkginfo.Subtitle ) then
        Append( entry, Concatenation(
          ", ", ps( pkginfo.Subtitle ) ) );
      fi;
      if IsBound( pkginfo.Version ) then
        Append( entry, Concatenation(
          ",\n         <C>V</C>ersion ", pkginfo.Version ) );
      fi;
      Append( entry, "</title>\n" );
      if IsBound( pkginfo.Date ) then
        Append( entry, Concatenation(
          "  <month>", months[ Int( pkginfo.Date{ [ 4, 5 ] } ) ], "</month>\n",
          "  <year>", pkginfo.Date{ [ 7 .. 10 ] }, "</year>\n" ) );
      fi;
      if IsBound( pkginfo.Status ) and pkginfo.Status = "accepted" then
        Append( entry, "  <note>Refereed GAP package</note>\n" );
      else
        Append( entry, "  <note>GAP package</note>\n" );
      fi;
      if IsBound( pkginfo.PackageWWWHome ) then
        Append( entry, Concatenation(
          "  <url>", pkginfo.PackageWWWHome, "</url>\n" ) );
      fi;
      Append( entry, "</manual></entry>" );
    fi;

    return entry;
end );

Unbind( NormalizedNameAndKey );
Unbind( RepeatedString );
Unbind( FormatParagraph );
Unbind( Unicode );
Unbind( Encode );

NamesSystemGVars := "dummy";   # is not yet defined when this file is read
NamesUserGVars   := "dummy";

#############################################################################
##
#F  PackageVariablesInfo( <pkgname>[, <version>] )
##
InstallGlobalFunction( PackageVariablesInfo, function( arg )
    local pkgname, version, test, info, banner, outercalls, name, pair,
          user_vars_orig, new, new_up_to_case, redeclared, newmethod, rules,
          data, rule, loaded, pkg, args, docmark, done, result, subrule,
          added, prev, subresult, entry, isrelevantvarname, globals,
          protected;

    # Get and check the arguments.
    if   Length( arg ) = 1 and IsString( arg[1] ) then
      pkgname:= LowercaseString( arg[1] );
      version:= "";
    elif Length( arg ) = 2 and IsString( arg[1] ) and IsString( arg[2] ) then
      pkgname:= LowercaseString( arg[1] );
      version:= arg[2];
    else
      Error( "usage: ShowPackageVariables( <pkgname>[ <version>] )" );
    fi;

    # Check that the package is available but not yet loaded.
    test:= TestPackageAvailability( pkgname, version );
    if test = true then
      Print( "#E  the package `", pkgname, "' is already loaded\n" );
      return [];
    elif test = fail then
      Print( "#E  the package `", pkgname, "' cannot be loaded" );
      if version <> "" then
        Print( " in version `", version, "'" );
      fi;
      Print( "\n" );
      return [];
    fi;

    # Note that we want to list only variables defined in the package
    # `pkgname' but not in the required or suggested packages.
    # So we first load these packages but *not* `pkgname'.
    # Actually only the declaration part of these packages is loaded,
    # since the implementation part may rely on variables that are declared
    # in the declaration part of `pkgname'.
    info:= First( GAPInfo.PackagesInfo.( pkgname ),
        r -> IsBound( r.InstallationPath ) and r.InstallationPath = test );
    banner:= not GAPInfo.CommandLineOptions.q and
             not GAPInfo.CommandLineOptions.b;
    outercalls:= [ pkgname ];
    if IsBound( info.Dependencies ) then
      for name in [ "NeededOtherPackages", "SuggestedOtherPackages" ] do
        if IsBound( info.Dependencies.( name ) ) then
          for pair in info.Dependencies.( name ) do
            LoadPackage( pair[1], pair[2], banner, outercalls );
          od;
        fi;
      od;
    fi;

    # Store the current list of global variables.
    user_vars_orig:= Union( NamesSystemGVars(), NamesUserGVars() );
    new:= function( entry )
        if entry[1] in user_vars_orig then
          return fail;
        else
          return [ entry[1], ValueGlobal( entry[1] ) ];
        fi;
      end;

    new_up_to_case:= function( entry )
        if   entry[1] in user_vars_orig then
          return fail;
        elif LowercaseString( entry[1] ) in GAPInfo.data.lowercase_vars then
          return [ entry[1], ValueGlobal( entry[1] ) ];
        else
          Add( GAPInfo.data.lowercase_vars, LowercaseString( entry[1] ) );
          return fail;
        fi;
      end;

    redeclared:= function( entry )
        if entry[1] in user_vars_orig then
          return [ entry[1], ValueGlobal( entry[1] ) ];
        else
          return fail;
        fi;
      end;

    newmethod:= function( entry )
      local setter;

      if IsString( entry[2] ) and entry[2] in
             [ "system setter", "default method, does nothing" ] then
        setter:= entry[1];
        if ForAny( ATTRIBUTES, entry -> IsIdenticalObj( setter,
                                            Setter( entry[3] ) ) ) then
          return fail;
        fi;
      fi;
      return [ NameFunction( entry[1] ), entry[ Length( entry ) ] ];
      end;

    # List the cases to be dealt with.
    rules:= [
      [ "DeclareGlobalFunction",
        [ "new global functions", new ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareGlobalVariable",
        [ "new global variables", new ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareOperation",
        [ "new operations", new ],
        [ "redeclared operations", redeclared ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareAttribute",
        [ "new attributes", new ],
        [ "redeclared attributes", redeclared ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareProperty",
        [ "new properties", new ],
        [ "redeclared properties", redeclared ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareCategory",
        [ "new categories", new ],
        [ "redeclared categories", redeclared ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareRepresentation",
        [ "new representations", new ],
        [ "redeclared representations", redeclared ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareFilter",
        [ "new plain filters", new ],
        [ "redeclared plain filters", redeclared ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "InstallMethod",
        [ "new methods", newmethod ] ],
      [ "InstallOtherMethod",
        [ "new other methods", newmethod ] ],
      [ "DeclareSynonymAttr",
        [ "new synonyms of attributes", new ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareSynonym",
        [ "new synonyms", new ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      ];

    # Save the relevant global variables, and replace them.
    GAPInfo.data:= rec();
    GAPInfo.data.lowercase_vars:= List( user_vars_orig, LowercaseString );
    for rule in rules do
      GAPInfo.data.( rule[1] ):= [ ValueGlobal( rule[1] ), [] ];
      MakeReadWriteGlobal( rule[1] );
      UnbindGlobal( rule[1] );
      BindGlobal( rule[1], EvalString( Concatenation(
          "function( arg ) ",
          "Add( GAPInfo.data.( \"", rule[1], "\" )[2], arg ); ",
          "CallFuncList( GAPInfo.data.( \"", rule[1], "\" )[1], arg ); ",
          "end" ) ) );

    od;

    # Load the package `pkgname', under the assumption that the
    # needed/suggested packages are already loaded).
    loaded:= LoadPackage( pkgname );

    # Put the original global variables back.
    for rule in rules do
      MakeReadWriteGlobal( rule[1] );
      UnbindGlobal( rule[1] );
      BindGlobal( rule[1], GAPInfo.data.( rule[1] )[1] );
    od;

    if not loaded then
      Print( "#E  the package `", pkgname, "' could not be loaded\n" );
      return [];
    fi;

    # Store the list of globals available before the implementation part
    # of the needed/suggested packages is read.
    globals:= Difference( NamesUserGVars(), user_vars_orig );

    # Read the implementation part of the needed/suggested packages.
    outercalls:= Reversed( outercalls );
    Unbind( outercalls[ Length( outercalls ) ] );
    for pkg in outercalls do
      ReadPackage( pkg, "read.g" );
    od;

    # Functions are printed via their lists of arguments.
    args:= function( func )
      local num, nam, str;

      if not IsFunction( func ) then
        return "";
      fi;
      num:= NumberArgumentsFunction( func );
      nam:= NamesLocalVariablesFunction( func );
      if num = -1 then
        str:= "arg";
      elif nam = fail then
        str:= "...";
      else
        str:= JoinStringsWithSeparator( nam{ [ 1 .. num ] }, ", " );
      fi;
      return Concatenation( "( ", str, " )" );
    end;

    # Mark undocumented globals with an asterisk.
    docmark:= function( varname )
      if not IsDocumentedVariable( varname ) then
        return "*";
      else
        return "";
      fi;
    end;

    # Prepare the output.
    done:= [];
    result:= [];
    for rule in rules do
      for subrule in rule{ [ 2 .. Length( rule ) ] } do
        added:= Filtered( List( GAPInfo.data.( rule[1] )[2], subrule[2] ),
                          x -> x <> fail );
        prev:= First( result, x -> x[1] = subrule[1] );
        if prev = fail then
          Add( result, [ subrule[1], added ] );
        else
          Append( prev[2], added );
        fi;
      od;
    od;
    for subresult in result do
      if IsEmpty( subresult[2] ) then
        subresult[1]:= Concatenation( "no ", subresult[1] );
      else
        subresult[1]:= Concatenation( subresult[1], ":" );
        added:= subresult[2];
        subresult[2]:= [];
        Sort( added, function( a, b ) return a[1] < b[1]; end );
        for entry in added do
          Add( subresult[2], [ "  ", entry[1], args( entry[2] ),
                               docmark( entry[1] ) ] );
          AddSet( done, entry[1] );
        od;
      fi;
    od;
    Unbind( GAPInfo.data );

    # Mention the remaining new globals.
    # (Omit `Set<attr>' and `Has<attr>' type variables.)
    isrelevantvarname:= function( name )
      local attr;

      if Length( name ) <= 3
         or not ( name{ [ 1 .. 3 ] } in [ "Has", "Set" ] ) then
        return true;
      fi;
      name:= name{ [ 4 .. Length( name ) ] };
      if not IsBoundGlobal( name ) then
        return true;
      fi;
      attr:= ValueGlobal( name );
      if ForAny( ATTRIBUTES, entry -> IsIdenticalObj( attr, entry[3] ) ) then
        return false;
      fi;
      return true;
    end;

    added:= Filtered( Difference( globals, done ), isrelevantvarname );
    protected:= Filtered( added, IsReadOnlyGVar );
    if not IsEmpty( protected ) then
      subresult:= [ "other new globals (write protected):", [] ];
      for entry in SortedList( protected ) do
        Add( subresult[2], [ "  ", entry, args( ValueGlobal( entry ) ),
                             docmark( entry ) ] );
      od;
      Add( result, subresult );
    fi;
    added:= Difference( added, protected );
    if not IsEmpty( added ) then
      subresult:= [ "other new globals (not write protected):", [] ];
      for entry in SortedList( added ) do
        Add( subresult[2], [ "  ", entry, args( ValueGlobal( entry ) ),
                             docmark( entry ) ] );
      od;
      Add( result, subresult );
    fi;

    return result;
    end );

Unbind( NamesSystemGVars );
Unbind( NamesUserGVars );


#############################################################################
##
#F  ShowPackageVariables( <pkgname>[, <version>] )
##
InstallGlobalFunction( ShowPackageVariables, function( arg )
    local entry, subentry;

    for entry in CallFuncList( PackageVariablesInfo, arg ) do
      Print( entry[1], "\n" );
      for subentry in entry[2] do
        Print( Concatenation( subentry ), "\n" );
      od;
      Print( "\n" );
    od;
    end );


#############################################################################
##
#E

