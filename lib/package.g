#############################################################################
##
#W  package.g                   GAP Library                      Frank Celler
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains support for {\GAP} packages.
##
##  The following global variables are used for package loading
##  (see `lib/version.g').
##  `GAPInfo.PackagesLoaded',
##  `GAPInfo.PackagesInfo',
##  `GAPInfo.PackagesInfoAutoload',
##  `GAPInfo.PackagesInfoAutoloadDocumentation',
##  `GAPInfo.PackagesInfoInitialized',
##  `GAPInfo.PackagesNames',
##  `GAPInfo.PackagesRestrictions', and
##  `GAPInfo.PackageInfoCurrent'.
##
#T TODO:
#T - document the utilities `SuggestUpgrades', `CheckPackageLoading',
#T   `ShowPackageVariables', `LoadAllPackages'.
##
Revision.package_g :=
    "@(#)$Id$";

#T remove this as soon as possible (currently used in several packages)
PACKAGES_VERSIONS:= rec();


#############################################################################
##
#F  CompareVersionNumbers( <supplied>, <required> )
#F  CompareVersionNumbers( <supplied>, <required>, \"equal\" )
##
##  compares two version numbers, given as strings. They are split at
##  non-digit characters, the resulting integer lists are compared
##  lexicographically.
##  The routine tests whether <supplied> is at least as large as <required>,
##  and returns `true' or `false' accordingly.
##  A version number ending in `dev' is considered to be infinite.
##  See Section~"ext:Version Numbers" of ``Extending GAP'' for details
##  about version numbers.
##
BindGlobal( "CompareVersionNumbers", function( arg )
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
##  Fetch the list of info records for the package with name <pkgname>.
##  This information is assumed to be set by `InitializePackagesInfoRecords'.
##
BindGlobal( "PackageInfo", function( pkgname )
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
##  a helper (for `InitializePackagesInfoRecords'), get records from a file
##  First removes everything in each line which starts with a `#', then
##  splits remaining content at whitespace.
##
BindGlobal( "RECORDS_FILE", function( name )
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
##  Each `PackageInfo.g' file contains a call to `SetPackageInfo'.
##
BindGlobal( "SetPackageInfo", function( record )
    GAPInfo.PackageInfoCurrent:= record;
    end );


#############################################################################
##
#F  InitializePackagesInfoRecords( <delay> )
##
##  If the argument <delay> is `true' then only a few initializations are
##  preformed; this is used for delaying the initialization until the first
##  call of `TestPackageAvailability' (such that the information is
##  available in the first `LoadPackage' call) if autoloading packages is
##  switched off.
##
##  Otherwise all `PackageInfo.g' files in all `pkg' subdirectories of
##  {\GAP} root directories are read,
##  the conditions in `GAPInfo.PackagesRestrictions' are checked,
##  and the lists of records are sorted according to descending package
##  version numbers.
##
##  The function initializes three global records.
##  \beginitems
##  `GAPInfo.PackagesInfo' &
##       the record with the lists of info records of all existing packages;
##       they are looked up in all subdirectories of `pkg' subdirectories of
##       {\GAP} root directories,
##
##  `GAPInfo.PackagesInfoAutoload' &
##       the record with the lists of info records for all those existing
##       packages for which at least one version is to be autoloaded,
##       according to the exclusion list in the `NOAUTO' file and to the
##       package's `PackageInfo.g' file,
##
##  `GAPInfo.PackagesInfoAutoloadDocumentation' &
##       the record with the lists of info records for all those existing
##       packages which are not scheduled for autoloading
##       but for which at least one version has autoloadable documentation,
##       according to its `PackageInfo.g' file.
##  \enditems
##
##  `GAPInfo.PackagesNames' is set to the list of all components of
##  `GAPInfo.PackagesInfoAutoload'; it can be modified in the user's `.gaprc'
##  file, only those packages will be autoloaded whose names occur in
##  `GAPInfo.PackagesNames' after the `.gaprc' file has been read.
##
BindGlobal( "InitializePackagesInfoRecords", function( delay )
    local dirs, pkgdirs, pkgdir, names, noauto, name, file, str, record,
          pkgname, version;

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

    dirs:= [];
    pkgdirs:= DirectoriesLibrary( "pkg" );
    if pkgdirs = fail then
      return;
    fi;

    GAPInfo.PackagesInfo:= [];
    GAPInfo.PackagesInfoAutoload:= [];
    GAPInfo.PackagesInfoAutoloadDocumentation:= [];
    GAPInfo.PackagesInfoRefuseLoad:= [];

    # Loop over the package directories.
    # (We consider the subdirectories and `NOAUTO' files for each directory,
    # and then unite the autoloadable packages for the directories.)
    for pkgdir in pkgdirs do

      # Ignore the filenames listed in the file `pkg/NOAUTO'.
      noauto:= RECORDS_FILE( Filename( pkgdir, "NOAUTO" ) );

      # Loop over subdirectories of the package directory.
      for name in DirectoryContents( Filename( pkgdir, "" ) ) do
        file:= Filename( [ pkgdir ], Concatenation( name, "/PackageInfo.g" ) );
if file = fail then
#T Remove this as soon as it is not used anymore!
  file:= Filename( [ pkgdir ], Concatenation( name, "/PkgInfo.g" ) );
fi;
        if file <> fail then

          # Read the `PackageInfo.g' file.
          Unbind( GAPInfo.PackageInfoCurrent );
          Read( file );
          record:= GAPInfo.PackageInfoCurrent;
          Unbind( GAPInfo.PackageInfoCurrent );
if IsBound( record.PkgName ) then
#T Remove this as soon as it is not used anymore!
  record.PackageName:= record.PkgName;
fi;
          pkgname:= LowercaseString( record.PackageName );
          NormalizeWhitespace( pkgname );
          version:= record.Version;

          # If we have this version already then leave it out.
          if ForAll( GAPInfo.PackagesInfo,
              r ->    r.PackageName <> record.PackageName
                   or r.Version <> version ) then

            # Check whether {\GAP} wants to reset (auto)loadability.
            if     IsBound( GAPInfo.PackagesRestrictions.( pkgname ) )
               and GAPInfo.PackagesRestrictions.( pkgname ).OnInitialization(
                       record ) = false then
              Add( GAPInfo.PackagesInfoRefuseLoad, record );
            else
              record.InstallationPath:= Filename( [ pkgdir ], name );
              if not IsBound( record.PackageDoc ) then
                record.PackageDoc:= [];
              elif IsRecord( record.PackageDoc ) then
                record.PackageDoc:= [ record.PackageDoc ];
              fi;
              Add( GAPInfo.PackagesInfo, record );
              if not name in noauto then
if IsBound( record.AutoLoad ) then
#T Remove this as soon as it is not used anymore!
  record.Autoload:= record.AutoLoad;
fi;
for name in record.PackageDoc do
  if IsBound( name.AutoLoad ) then
#T Remove this as soon as it is not used anymore!
    name.Autoload:= name.AutoLoad;
  fi;
od;
                if  IsBound( record.Autoload ) and record.Autoload = true then
                  Add( GAPInfo.PackagesInfoAutoload, record );
                elif ForAny( record.PackageDoc,
                      r -> IsBound( r.Autoload ) and r.Autoload = true ) then
                  Add( GAPInfo.PackagesInfoAutoloadDocumentation, record );
                fi;
              fi;
            fi;

          fi;
        fi;
      od;
    od;

    # Sort the available info records by their version numbers.
    for record in [ GAPInfo.PackagesInfo, GAPInfo.PackagesInfoAutoload,
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

    record:= rec();
    names:= Set( List( GAPInfo.PackagesInfoAutoload,
                       r -> LowercaseString( r.PackageName ) ) );
    for name in names do
      record.( name ):= Filtered( GAPInfo.PackagesInfoAutoload,
                            r -> LowercaseString( r.PackageName ) = name );
    od;
    GAPInfo.PackagesInfoAutoload:= record;

    # Autoloading documentation makes sense only for not autoloaded packages.
    record:= rec();
    for name in Difference( Set( List(
                    GAPInfo.PackagesInfoAutoloadDocumentation,
                        r -> LowercaseString( r.PackageName ) ) ), names ) do
      record.( name ):= Filtered( GAPInfo.PackagesInfoAutoloadDocumentation,
                            r -> LowercaseString( r.PackageName ) = name );
    od;
    GAPInfo.PackagesInfoAutoloadDocumentation:= record;

    GAPInfo.PackagesNames:= Set( RecNames( GAPInfo.PackagesInfoAutoload ) );

    GAPInfo.PackagesInfoInitialized:= true;
    end );


#############################################################################
##
#F  TestPackageAvailability( <name>, <version> )
#F  TestPackageAvailability( <name>, <version>, <intest> )
##
##  For strings <name> and <version>, `TestPackageAvailability' tests
##  whether the  {\GAP} package <name> is available for loading in a
##  version that is at least <version>, or equal to <version> if the first
##  character of <version> is `=',
##  see Section "ext:Version Numbers" of ``Extending GAP'' for details about
##  version numbers.
##
##  The result is `true' if the package is already loaded,
##  `fail' if it is not available,
##  and the string denoting the {\GAP} root path where the package resides
##  if it is available, but not yet loaded.
##  A test function (the value of the component `AvailabilityTest' in the
##  `PackageInfo.g' file of the package) should therefore test for the result
##  of `TestPackageAvailability' being not equal to `fail'.
##
##  The argument <name> is case insensitive.
##
##  The optional argument <intest> is a list of pairs
##  `[ <pkgnam>, <pkgversion> ]' such that the function has been called with
##  these arguments on outer levels.
##  (Note that several packages may require each other, with different
##  required versions.)
##
DeclareGlobalFunction( "TestPackageAvailability" );

InstallGlobalFunction( "TestPackageAvailability", function( arg )
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

    # Initialize if this was not yet done.
    InitializePackagesInfoRecords( false );

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

    # 2. If `name' is among the packages from whose availability test
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

    # 3. Get the info records for the package `name',
    #    and take the first record that satisfies the conditions.
    #    (Note that they are ordered w.r.t. descending version numbers.)
    for inforec in PackageInfo( name ) do

      dep:= inforec.Dependencies;

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
          Info( InfoWarning, 1,
                "Package `", name,
                "': cannot locate `", inforec.InstallationPath,
                "/init.g', please check the installation" );
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
      Info( InfoWarning, 2,
            "Package `", name,
            "': no installed version fulfills the requirements" );
    fi;

    return fail;
    end );


#############################################################################
##
#F  DefaultPackageBannerString( <inforec> )
##
##  For a record <inforec> as stored in the `PackageInfo.g' file of a {\GAP}
##  package, `DefaultPackageBannerString' returns a string denoting a
##  banner for the package.
##
BindGlobal( "DefaultPackageBannerString", function( inforec )
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
##  returns a list of the `bin/<architecture>' subdirectories of all
##  packages <name> where <architecture> is the architecture on which {\GAP}
#T As soon as `GAPInfo' is documented, add a cross-reference to it here!
##  has been compiled and the version of the installed package coincides with
##  the version of the package <name> that either is already loaded or that
##  would be the first version {\GAP} would try to load (if no other version
##  is explicitly prescribed).
##
##  Note that `DirectoriesPackagePrograms' is likely to be called in the
##  `AvailabilityTest' function in the package's `PackageInfo.g' file,
##  so we cannot guarantee that the returned directories belong to a version
##  that really can be loaded.
##
##  The directories returned by `DirectoriesPackagePrograms' are the place
##  where external binaries of the {\GAP} package <name> for the current
##  package version and the current architecture should be located.
##
BIND_GLOBAL( "DirectoriesPackagePrograms", function( name )
    local arch, dirs, info, version, r, path;

    arch := GAPInfo.Architecture;
    dirs := [];
    # For the reason described above, we are not allowed to call
    # `InstalledPackageVersion', `TestPackageAvailability' etc.
    InitializePackagesInfoRecords( false );
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
##  takes the string <name>, a name of a {\GAP} package and returns a list of
##  directory objects for those sub-directory/ies containing the library
##  functions of this {\GAP} package, for the version that is already loaded
##  or would be loaded if no other version is explicitly prescribed,
##  up to one directory for each `pkg' sub-directory of a path in
##  `GAPInfo.RootPaths'.
#T As soon as `GAPInfo' is documented, add a cross-reference to it here!
##  The default is that the library functions are in the subdirectory `lib'
##  of the {\GAP} package's home directory.
##  If this is not the case, then the second argument <path> needs to be
##  present and must be a string that is a path name relative to the home
##  directory  of the {\GAP} package with name <name>.
##
##  Note that `DirectoriesPackageLibrary' may be called in the
##  `AvailabilityTest' function in the package's `PackageInfo.g' file,
##  so we cannot guarantee that the returned directories belong to a version
##  that really can be loaded.
##
BIND_GLOBAL( "DirectoriesPackageLibrary", function( arg )
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
    InitializePackagesInfoRecords( false );
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
#F  ReadPackage( <name>, <file> )
#F  ReadPackage( <pkg-file> )
#F  RereadPackage( <name>, <file> )
#F  RereadPackage( <pkg-file> )
##
##  In the first form, `ReadPackage' reads the file <file> of the {\GAP}
##  package <name>, where <file> is given as a path relative to the home
##  directory of <name>.
##  In the second form where only one argument <pkg-file> is given, this
##  should be the path of a file relative to the `pkg' subdirectory of {\GAP}
##  root paths (see~"ref:GAP Root Directory" in the {\GAP} Reference Manual).
##  Note that in this case, the package name is assumed to be equal to the
##  first part of <pkg-file>, *so this form is not recommended*.
##
##  The absolute path is determined as follows.
##  If the package in question has already been loaded then the file in the
##  directory of the loaded version is read.
##  If the package is available but not yet loaded then the directory given
##  by `TestPackageAvailability' (see~"TestPackageAvailability"), without
##  prescribed version number, is used.
##  (Note that the `ReadPackage' call does *not* force the package to be
##  loaded.)
##
##  If the file is readable then `true' is returned, otherwise `false'.
##
##  Each of <name>, <file> and <pkg-file> should be a string.
##  The <name> argument is case insensitive.
##
##  `RereadPackage' does the same as `ReadPackage', except that also
##  read-only global variables are overwritten
##  (cf~"ref:Reread" in the {\GAP} Reference Manual).
##
BindGlobal( "ReadPackage", function( arg )
    local pos, relpath, pkgname, filename, rflc, rfc;

    # Note that we cannot use `ReadAndCheckFunc' because this calls
    # `READ_GAP_ROOT', but here we have to read the file in one of those
    # directories where the package version resides that has been loaded
    # or (at least currently) would be loaded.
    if   Length( arg ) = 1 then
      # Guess the package name.
      pos:= Position( arg[1], '/' );
      relpath:= arg[1]{ [ pos+1 .. Length( arg[1] ) ] };
      pkgname:= arg[1]{ [ 1 .. pos-1 ] };
    elif Length( arg ) = 2 then
      pkgname:= LowercaseString( arg[1] );
      relpath:= arg[2];
    else
      Error( "expected 1 or 2 arguments" );
    fi;

    filename:= Filename( DirectoriesPackageLibrary( pkgname, "" ), relpath );
    if filename <> fail and IsReadableFile( filename ) then
      Read( filename );
      return true;
    else
      return false;
    fi;
    end );

BindGlobal( "RereadPackage", function( arg )
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
##  Let <info> be a record as defined in the `PackageInfo.g' file of a
##  package.
##  `LoadPackageDocumentation' loads books of the documentation for this
##  package.
##  If <all> is `true' then *all* books are loaded, otherwise only the
##  *autoloadable* books are loaded.
##
##  Note that this function might run twice for a package, first in the
##  autoloading process (where the package itself is not necessarily loaded)
##  and later when the package is loaded.
##  In this situation, the names used by the help viewer differ before and
##  after the true loading.
##
BindGlobal( "LoadPackageDocumentation", function( info, all )
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
#F  LoadPackage( <name>[, <version>] )
#F  LoadPackage( <name>[, <version>, <banner>[, <outercalls>]] )
##
##  loads the {\GAP} package with name <name>.
##  If the optional version string <version> is given, the package will only
##  be loaded in a version number at least as large as <version>,
##  or equal to <version> if its first character is `='
##  (see~"ext:Version Numbers" in ``Extending GAP'').
##  The argument <name> is case insensitive.
##
##  `LoadPackage' will return `true' if the package has been successfully
##  loaded and will return `fail' if the package could not be loaded.
##  The latter may be the case if the package is not installed, if necessary
##  binaries have not been compiled, or if the version number of the
##  available version is too small.
##
##  If the package <name> has already been loaded in a version number
##  at least or equal to <version>, respectively,
##  `LoadPackage' returns `true' without doing anything else.
##
##  If the optional third argument <banner> is `false' then no package banner
##  is printed.
##  The fourth argument <outercalls> is used only for recursive calls of
##  `LoadPackage', when the loading process for a package triggers the
##  loading of other packages.
##
DeclareGlobalFunction( "LoadPackage" );

RequirePackage:= LoadPackage;
#T to be removed as soon as `init.g' files in old format have disappeared

InstallGlobalFunction( LoadPackage, function( arg )
    local name, version, banner, outercalls, path, info, filename, read,
          dep, pair, pkg;

    # Get the arguments.
    name:= LowercaseString( arg[1] );
    version:= "";
    if 1 < Length( arg ) then
      version:= arg[2];
    fi;
    banner:= not GAPInfo.CommandLineOptions.q and
             not GAPInfo.CommandLineOptions.b and
             not ( 2 < Length( arg ) and arg[3] = false );
    outercalls:= [];
    if Length( arg ) = 4 then
      outercalls:= arg[4];
    fi;
    if name in outercalls then
      return true;
    fi;

    # Test whether the package is available.
    path:= TestPackageAvailability( name, version );
    if not IsString( path ) then
      # either `true' or `fail'
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
      Add( outercalls, name );
    fi;

    # Load the needed other packages.
    # (This is expected to work because of `TestPackageAvailability' above.)
    dep:= info.Dependencies;
    if IsBound( dep.NeededOtherPackages ) then
      for pair in dep.NeededOtherPackages do
        if LoadPackage( pair[1], pair[2], banner, outercalls ) <> true then
          # The package was classified as available, but we cannot load it?
          Error( "this should not happen" );
        fi;
      od;
    fi;

    # Try to load the suggested other packages,
    # and issue a warning for each such package where this is not possible.
    if IsBound( dep.SuggestedOtherPackages ) then
      for pair in dep.SuggestedOtherPackages do
        if LoadPackage( pair[1], pair[2], banner, outercalls ) <> true then
          Info( InfoWarning, 2,
                "suggested package `", pair[1], "' cannot be loaded" );
        fi;
      od;
    fi;

    # If wanted then show a package banner.
    if banner then
      # If the component `BannerString' is bound in `info' then we print
      # this string, otherwise we print the default banner string.
      if IsBound( info.BannerString ) then
        Print( info.BannerString );
      else
        Print( DefaultPackageBannerString( info ) );
      fi;
    fi;

    # Read the `init.g' file.
#T Perhaps a package in ``old'' format is read from `.gaprc',
#T so the obsolete function names are not yet known.
if GAPInfo.ReadObsolete <> false and not IsBoundGlobal( "ReadPkg" ) then
  RereadLib( "obsolete.g" );
fi;
#T Ignore possible `RequirePackage' calls in `init.g' files.
#T (Remove this as soon as `RequirePackage' is removed.)
RequirePackage:= ReturnTrue;
    Read( Filename( Directory( path ), "init.g" ) );
RequirePackage:= LoadPackage;

    # If the function was called on the outermost level
    # then we read the implementation part of all those packages
    # that have been loaded in the meantime;
    # it is contained in the file `read.g' in each package home directory.
    if Length( arg ) <> 4 then
      for pkg in Reversed( outercalls ) do
        ReadPackage( pkg, "read.g" );
      od;
    fi;

    return true;
    end );


#############################################################################
##
#F  LoadAllPackages()
##
##  loads all installed packages that can be loaded, in alphabetical order.
##  This admittedly trivial function is used for example in automatic tests.
##
BindGlobal( "LoadAllPackages", function()
    InitializePackagesInfoRecords( false );
    List( RecNames( GAPInfo.PackagesInfo ), LoadPackage );
    end );


#############################################################################
##
#F  InstalledPackageVersion( <name> )
##
##  If the {\GAP} package with name <name> has already been loaded then
##  `InstalledPackageVersion' returns the string denoting the version number
##  of this version of the package.
##  If the package is available but has not yet been loaded then the version
##  number string for that version of the package that currently would be
##  loaded.
##  (Note that loading *another* package might force loading another version
##  of the package <name>, so the result of `InstalledPackageVersion' will be
##  different afterwards.)
##  If the package is not available then `fail' is returned.
##
##  The argument <name> is case insensitive.
##
BindGlobal( "InstalledPackageVersion", function( name )
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
##  Only the packages in the list `GAPInfo.PackagesNames' are considered
##  for autoloading.
##  Note that we ignore packages for which the user has disabled autoloading,
##  in particular we do not autoload their package documentation.
##
##  For those packages which shall not be autoloaded but their documentation
##  shall be autoloaded, this is done *without* checking the availability of
##  the package; so it might be that documentation is available for packages
##  that in fact cannot be loaded in the current {\GAP} session.
#T note that we could run the tester function, but this might cause `Print'
#T statements saying that some package cannot be loaded which at the moment
#T shall not be loaded -- would this be better?
##
BindGlobal( "AutoloadPackages", function()
    local name, record;

    # Load the autoloadable packages (suppressing banners).
    for name in GAPInfo.PackagesNames do
      Info( InfoWarning, 2, "considering for autoloading: ", name );
      LoadPackage( name, "", false );
    od;

    # Load the autoloadable documentation for not autoloadable packages.
    for name in RecNames( GAPInfo.PackagesInfoAutoloadDocumentation ) do
      if not IsBound( GAPInfo.PackagesLoaded.( name ) ) then
        record:= First( GAPInfo.PackagesInfoAutoloadDocumentation.( name ),
                        IsRecord );
        if IsRecord( record ) then
          LoadPackageDocumentation( record, false );
        fi;
      fi;
    od;
    end );


#############################################################################
##
#F  ExcludeFromAutoload( <pkgname1>, <pkgname2>, ... )
##
##  This  function  is  intended  for disabling  autoloading   of  the
##  packages whose  names are given  as arguments,  via a call  in the
##  user's `.gaprc' file.
##
BindGlobal( "ExcludeFromAutoload", function( arg )
    SubtractSet( GAPInfo.PackagesNames, List(arg, LowercaseString) );
    end );


#############################################################################
##
#F  GAPDocManualLab(<pkgname>) . create manual.lab for package w/ GAPDoc docs
##
##  For a package <pkgname> with {\GAPDoc}  documentation,  `GAPDocManualLab'
##  builds a `manual.lab' file from the {\GAPDoc}-produced `manual.six'  file
##  so that the currently-default `gapmacro.tex'-compiled manuals can  access
##  the labels of package <pkgname>.
##
# avoid warning (will be def. in GAPDoc
if not IsBound(StripEscapeSequences) then
  StripEscapeSequences := 0;
fi;
BindGlobal( "GAPDocManualLab", function(pkgname)
  local pinf, file, stream, entries, SecNumber, esctex, book, bookname;
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
    stream := InputTextFile(file);
    entries := HELP_BOOK_HANDLER.GapDocGAP.ReadSix(stream).entries;
    SecNumber := function(list)
      if IsEmpty(list) or list[1] = 0 then
        return "";
      fi;
      while list[ Length(list) ] = 0 do
        Unbind( list[ Length(list) ] );
      od;
      return JoinStringsWithSeparator( List(list, String), "." );
    end;

    # throw away TeX critical characters here
    esctex := function(str)
      return Filtered(StripEscapeSequences(str), c-> not c in "%#$&^_~");
    end;

    bookname := LowercaseString(book.BookName);
    entries := List( entries,
                     entry -> Concatenation( "\\makelabel{", bookname, ":",
                                             esctex(entry[1]), "}{",
                                             SecNumber( entry[3] ), "}\n" ) );
    file := Concatenation(file{[1..Length(file)-3]}, "lab");
    FileString( file, Concatenation(entries) );
    Info(InfoWarning, 1, "File: ", file, " written.");
  od;
end );
if StripEscapeSequences = 0 then
  Unbind(StripEscapeSequences);
fi;

#############################################################################
##
#F  DeclareAutoreadableVariables( <pkgname>, <filename>, <varlist> )
##
##  Let <pkgname> be the name of a package, let <filename> be the name of
##  a file relative to the home directory of this package,
##  and let <varlist> be a list of strings that are the names of global
##  variables which get bound when the file is read.
##  `DeclareAutoreadableVariables' notifies the names in <varlist> such that
##  the first attempt to access one of the variables causes the file to be
##  read.
##
BindGlobal( "DeclareAutoreadableVariables",
    function( pkgname, filename, varlist )
    CallFuncList( AUTO,
        Concatenation( [ function( x ) RereadPackage( pkgname, filename ); end,
                         filename ], varlist ) );
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
##  This function is intended to support package authors who create or
##  modify `PackageInfo.g' files.
##  (It is *not* called when these files are read during the startup of
##  {\GAP} or when packages are actually loaded.)
##
##  The argument must be either a record <record> as is contained in a
##  `PackageInfo.g' file or a a string <filename> which describes the path
##  to such a file.
##  The result is `true' if the record or the contents of the file,
##  respectively, has correct format, and `false' otherwise;
##  in the latter case information about the incorrect components is printed.
##
##  Note that the components used for package loading are checked as well as
##  the components that are needed for composing the package overview Web
##  page or for updating the package archives.
##
BindGlobal( "ValidatePackageInfo", function( record )
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
    if TestMandat( record, "Dependencies", IsRecord, "a record" ) then
      TestMandat( record.Dependencies, "NeededOtherPackages",
          comp -> IsList( comp ) and ForAll( comp,
                      l -> IsList( l ) and Length( l ) = 2
                                       and ForAll( l, IsString ) ),
          "a list of pairs `[ <pkgname>, <pkgversion> ]' of strings" );
      TestMandat( record.Dependencies, "SuggestedOtherPackages",
          comp -> IsList( comp ) and ForAll( comp,
                      l -> IsList( l ) and Length( l ) = 2
                                       and ForAll( l, IsString ) ),
          "a list of pairs `[ <pkgname>, <pkgversion> ]' of strings" );
      TestMandat( record.Dependencies, "ExternalConditions",
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
##  Start {\GAP} with the command line option `-A', then call this function
##  once.
##
BindGlobal( "CheckPackageLoading", function( pkgname )
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
if ReadPackage( pkgname, "PackageInfo.g" ) = false
and ReadPackage( pkgname, "PkgInfo.g" ) then
Print( "#E  rename `PkgInfo.g' to `PackageInfo.g'\n" );
fi;
#T remove this as soon as it no longer necessary
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
##  This is a mutable record, each component being the name of a package
##  <pkg> (in lowercase letters) that is required/recommended to be updated
##  to a certain version, the value being a record with the following
##  components.
##
##  \beginitems
##  `OnInitialization' &
##      a function that takes one argument, the record stored in the
##      `PackageInfo.g' file of the package, and returns `true' if the
##      package can be loaded, and returns `false' if not;
##      the function is allowed to change components of the argument record,
##      for example to reset the `Autoload' component to `false';
##      it should not print any message, this should be left to the `OnLoad'
##      component,
##
##  `OnLoad' &
##      a function that takes one argument, the record stored in the
##      `PackageInfo.g' file of the package, and can print a message when the
##      availability of the package is checked for the first time;
##      this message is thought to explain why the package cannot loaded due
##      to the `false' result of the `OnInitialization' component,
##      or as a warning about known problems (when the package is in fact
##      loaded), and it might give hints for upgrading the package.
##  \enditems
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
        end ),

  guava := rec(
    OnInitialization := function( pkginfo )
        if CompareVersionNumbers( pkginfo.Version, "2.002" ) = false then
          pkginfo.Autoload:= false;
          return false;
        fi;
        return true;
        end,
    OnLoad := function( pkginfo )
        if CompareVersionNumbers( pkginfo.Version, "2.002" ) = false then
          Print( "  The package `guava'",
              " should be upgraded at least to version 2.002,\n",
              "  the given version (", pkginfo.Version,
              ") is known to be incompatible\n",
              "  with the current version of GAP.\n",
              "  It is strongly recommended to update to the ",
              "most recent version, see URL\n",
              "      http://cadigweb.ew.usna.edu/~wdj/gap/GUAVA\n" );
        fi;
        end ), 

    );


#############################################################################
##
#F  SuggestUpgrades( versions ) . . compare installed with distributed versions
##
##  versions: a list of pairs like
##     [  [ "GAPKernel", "4.4.0" ], [ "GAPLibrary", "4.4.0" ],
##        [ "AtlasRep", "1.2" ], ...
##     ]
##  where the second arguments are version numbers from the current official
##  distribution.
##  The function compares this with the available Kernel, Library, and
##  Package versions and print some text summarizing the result.
##
##  For 4.4 not yet documented, we should think about improvements first.
##  (e.g., how to download the necessary information in the background)
##
BindGlobal( "SuggestUpgrades", function( suggestedversions )
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


NamesSystemGVars := "dummy";   # is not yet defined when the file is read
NamesUserGVars   := "dummy";

#############################################################################
##
#F  PackageVariablesInfo( <pkgname>[, <version>] )
##
##  This is currently the function that does the work for
##  `ShowPackageVariables'.
##  In the future, better interfaces for such overviews are desirable,
##  so it makes sense to separate the computation of the data from the
##  actual rendering.
##
BindGlobal( "PackageVariablesInfo", function( arg )
    local pkgname, version, test, info, banner, outercalls, pair,
          user_vars_orig, new, redeclared, newmethod, rules, data, rule,
          loaded, pkg, args, docmark, done, result, subrule, added,
          subresult, entry, isrelevantvarname, globals, protected;

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
    for pair in Concatenation( info.Dependencies.NeededOtherPackages,
                               info.Dependencies.SuggestedOtherPackages ) do
      LoadPackage( pair[1], pair[2], banner, outercalls );
    od;

    # Store the current list of global variables.
    user_vars_orig:= Union( NamesSystemGVars(), NamesUserGVars() );
    new:= function( entry )
        if entry[1] in user_vars_orig then
          return fail;
        else
          return [ entry[1], ValueGlobal( entry[1] ) ];
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
        [ "new global functions",
          entry -> [ entry[1], ValueGlobal( entry[1] ) ] ] ],
      [ "DeclareGlobalVariable",
        [ "new global variables",
          entry -> [ entry[1], ValueGlobal( entry[1] ) ] ] ],
      [ "DeclareOperation",
        [ "new operations", new ],
        [ "redeclared operations", redeclared ] ],
      [ "DeclareAttribute",
        [ "new attributes", new ],
        [ "redeclared attributes", redeclared ] ],
      [ "DeclareProperty",
        [ "new properties", new ],
        [ "redeclared properties", redeclared ] ],
      [ "DeclareCategory",
        [ "new categories", new ],
        [ "redeclared categories", redeclared ] ],
      [ "DeclareRepresentation",
        [ "new representations", new ],
        [ "redeclared representations", redeclared ] ],
      [ "DeclareFilter",
        [ "new plain filters", new ],
        [ "redeclared plain filters", redeclared ] ],
      [ "InstallMethod",
        [ "new methods", newmethod ] ],
      [ "InstallOtherMethod",
        [ "new other methods", newmethod ] ],
      [ "DeclareSynonymAttr",
        [ "new synonyms of attributes", new ] ],
      [ "DeclareSynonym",
        [ "new synonyms", new ] ],
      ];

    # Save the relevant global variables, and replace them.
    GAPInfo.data:= rec();
    for rule in rules do
      GAPInfo.data.( rule[1] ):= [ ValueGlobal( rule[1] ), [] ];
      MakeReadWriteGlobal( rule[1] );
      UnbindGlobal( rule[1] );
      BindGlobal( rule[1], EvalString( Concatenation(
          "function( arg ) Add( GAPInfo.data.( \"", rule[1],
          "\" )[2], arg ); CallFuncList( GAPInfo.data.( \"", rule[1],
          "\" )[1], arg ); end" ) ) );
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
        if IsEmpty( added ) then
          subresult:= [ Concatenation( "no ", subrule[1] ), [] ];
        else
          subresult:= [ Concatenation( subrule[1], ":" ), [] ];
          Sort( added, function( a, b ) return a[1] < b[1]; end );
          for entry in added do
            Add( subresult[2], [ "  ", entry[1], args( entry[2] ),
                                 docmark( entry[1] ) ] );
            AddSet( done, entry[1] );
          od;
        fi;
        Add( result, subresult );
      # Print( "\n" );
      od;
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
##  Let <pkgname> be the name of a {\GAP} package.
##  If the package <pkgname> is available but not yet loaded then
##  `ShowPackageVariables' prints a list of global variables that become
##  bound and of methods that become installed when the package is loaded.
##  (For that, the package is actually loaded, so `ShowPackageVariables' can
##  be called only once for the same package and in the same {\GAP} session.)
##
##  If a version number <version> is given (see Section~"ext:Version Numbers"
##  of ``Extending GAP'') then this version of the package is considered.
##
##  An error message is printed if (the given version of) the package
##  is not available or already loaded.
##
##  The following entries are omitted from the list:
##  Default setter methods for attributes and properties that are declared in
##  the package,
##  and `Set<attr>' and `Has<attr>' type variables where <attr> is an
##  attribute or property.
##
BindGlobal( "ShowPackageVariables", function( arg )
    local data, entry, subentry;

    for entry in CallFuncList( PackageVariablesInfo, arg ) do
      Print( entry[1], "\n" );
      for subentry in entry[2] do
        Print( Concatenation( subentry ), "\n" );
      od;
      Print( "\n" );
    od;
    end );
#T improve this:
#T List also all globals that differ from other globals (in the same package
#T or defined outside) only by case -- note that the documentation is case
#T insensitive, so it will be difficult to document variables that differ
#T only by case!


#############################################################################
##
#E

