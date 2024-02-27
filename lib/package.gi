#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains support for &GAP; packages.
##


# recode string to GAPInfo.TermEncoding, assuming input is UTF-8 or latin1
# (if useful this may become documented for general use)
BindGlobal( "RecodeForCurrentTerminal", function( str )
    local fun, u;
    if IsBoundGlobal( "Unicode" ) and IsBoundGlobal( "Encode" ) then
      # The GAPDoc package is completely loaded.
      fun:= ValueGlobal( "Unicode" );
      u:= fun( str, "UTF-8" );
      if u = fail then
        u:= fun( str, "ISO-8859-1");
      fi;
      if GAPInfo.TermEncoding <> "UTF-8" then
        fun:= ValueGlobal( "SimplifiedUnicodeString" );
        u:= fun( u, GAPInfo.TermEncoding );
      fi;
      fun:= ValueGlobal( "Encode" );
      u:= fun( u, GAPInfo.TermEncoding );
      return u;
    else
      # GAPDoc is not yet available, do nothing in this case.
      return str;
    fi;
  end );

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
    local rnam, info;
    if IsHPCGAP then
        info := rec();
        for rnam in REC_NAMES(record) do
          info.(rnam) := Immutable(record.(rnam));
        od;
        record := info;
    fi;
    GAPInfo.PackageInfoCurrent:= record;
    end );


#############################################################################
##
#F  FindPackageInfosInSubdirectories( pkgdir, name )
##
##  Finds all PackageInfos in subdirectories of directory name in
##  directory pkgdir, return a list of their paths.
##
BindGlobal( "FindPackageInfosInSubdirectories", function( pkgdir, name )
    local pkgpath, file, files, subdir;
    pkgpath:= Filename( [ pkgdir ], name );
    # This can be 'fail' if 'name' is a void link.
    if pkgpath = fail then
      return [];
    fi;

    if not IsDirectoryPath( pkgpath ) then
      return [];
    fi;
    if name in [ ".", ".." ] then
      return [];
    fi;

    file:= Filename( [ pkgdir ],
                      Concatenation( name, "/PackageInfo.g" ) );
    if file = fail then
      files := [];
      # Perhaps some subdirectories contain `PackageInfo.g' files.
      for subdir in Set( DirectoryContents( pkgpath ) ) do
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
    return files;
end );


#############################################################################
##
#F  AddPackageInfo( files )
##
BindGlobal( "AddPackageInfos", function( files, pkgdir, ignore )
    local file, record, pkgname, date, dd, mm;
    for file in files do
      # Read the `PackageInfo.g' file.
      Unbind( GAPInfo.PackageInfoCurrent );
      Read( file[1] );
      if IsBound( GAPInfo.PackageInfoCurrent ) then
        record:= GAPInfo.PackageInfoCurrent;
        Unbind( GAPInfo.PackageInfoCurrent );
        pkgname:= LowercaseString( record.PackageName );
        NormalizeWhitespace( pkgname );

        # Check whether GAP wants to reset loadability.
        if     IsBound( GAPInfo.PackagesRestrictions.( pkgname ) )
            and GAPInfo.PackagesRestrictions.( pkgname ).OnInitialization(
                    record ) = false then
          Add( GAPInfo.PackagesInfoRefuseLoad, record );
        elif pkgname in ignore then
          LogPackageLoadingMessage( PACKAGE_DEBUG,
              Concatenation( "ignore package ", record.PackageName,
              " (user preference PackagesToIgnore)" ), "GAP" );
        else
          record.InstallationPath:= Filename( [ pkgdir ], file[2] );
          # normalize to include trailing "/"
          record.InstallationPath:= Filename( [ Directory( record.InstallationPath ) ], "" );
          if not IsBound( record.PackageDoc ) then
            record.PackageDoc:= [];
          elif IsRecord( record.PackageDoc ) then
            record.PackageDoc:= [ record.PackageDoc ];
          fi;

          # Normalize the format of 'Date', i.e. if it is the format yyyy-mm-dd
          # then we change it to dd/mm/yyyy. When other tools have adapted to
          # the yyyy-mm-dd format we can normalize to that format and at some
          # point in the future get rid of this code.
          if Length(record.Date) = 10 and record.Date{[5,8]} = "--" then
            date := List( SplitString( record.Date, "-" ), Int);
            date := Permuted(date, (1,3)); # date = [dd,mm,yyyy]
            # generate the day and month strings
            # if the day has only one digit we have to add a 0
            if date[1] < 10 then
              dd := Concatenation("0", String(date[1]));
            else
              dd := String(date[1]);
            fi;
            # if the month has only one digit we have to add a 0
            if date[2] < 10 then
              mm := Concatenation("0", String(date[2]));
            else
              mm := String(date[2]);
            fi;
            record.Date := Concatenation(dd, "/", mm, "/", String(date[3]));
          fi;

          if IsHPCGAP then
            # FIXME: we make the package info record immutable, to
            # allow access from multiple threads; but that in turn
            # can break packages, which rely on their package info
            # record being readable (see issue #2568)
            MakeImmutable(record);
          fi;
          Add( GAPInfo.PackagesInfo, record );
        fi;
      fi;
    od;
end );

#############################################################################
##
#F  InitializePackagesInfoRecords()
##
##  In earlier versions, this function had an argument; now we ignore it.
##
InstallGlobalFunction( InitializePackagesInfoRecords, function( arg )
    local pkgdirs, pkgdir, ignore, name, files, record, r;

    if IsBound( GAPInfo.PackagesInfoInitialized ) and
       GAPInfo.PackagesInfoInitialized = true then
      # This function has already been executed in this session.
      return;
    fi;

    GAPInfo.LoadPackageLevel:= 0;
    GAPInfo.PackagesInfo:= [];
    GAPInfo.PackagesInfoRefuseLoad:= [];

    LogPackageLoadingMessage( PACKAGE_DEBUG,
        "entering InitializePackagesInfoRecords", "GAP" );
    pkgdirs:= DirectoriesLibrary( "pkg" );
    if pkgdirs = fail then
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "exit InitializePackagesInfoRecords (no pkg directories found)",
          "GAP" );
      GAPInfo.PackagesInfo:= AtomicRecord();
      return;
    fi;

    if IsBound( GAPInfo.ExcludeFromAutoload ) then
      # The function was called from `AutoloadPackages'.
      # Collect the `NOAUTO' information in a global list,
      # which will be used in `AutoloadPackages' for both packages to be
      # loaded according to the user preference "PackagesToLoad"
      # and suggested packages of needed packages.
      # The component `GAPInfo.ExcludeFromAutoload' will be unbound after the
      # call of `AutoloadPackages'.
      GAPInfo.ExcludeFromAutoload:= Set(
          UserPreference( "ExcludeFromAutoload" ), LowercaseString );
    fi;

    # Do not store information about packages in "PackagesToIgnore".
    ignore:= List( UserPreference( "PackagesToIgnore" ), LowercaseString );

    # Loop over the package directories,
    # remove the packages listed in `NOAUTO' files from GAP's suggested
    # packages, and unite the information for the directories.
    for pkgdir in pkgdirs do

      if IsBound( GAPInfo.ExcludeFromAutoload ) then
        UniteSet( GAPInfo.ExcludeFromAutoload,
                  List( RECORDS_FILE( Filename( pkgdir, "NOAUTO" ) ),
                        LowercaseString ) );
      fi;

      # Loop over subdirectories of this package directory.
      for name in Set( DirectoryContents( Filename( pkgdir, "" ) ) ) do

          ## Get all package dirs
          files := FindPackageInfosInSubdirectories( pkgdir, name );

          AddPackageInfos( files, pkgdir, ignore );

      od;
    od;

    # Sort the available info records by their version numbers.
    # (Sort stably in order to make sure that an instance from the first
    # possible root path gets chosen if the same version of a package
    # is available in several root paths.
    # Note that 'CompareVersionNumbers' returns 'true'
    # if the two arguments are equal.)
    StableSortParallel( List( GAPInfo.PackagesInfo, r -> r.Version ),
                  GAPInfo.PackagesInfo,
                  { a, b } -> not CompareVersionNumbers( a, b, "equal" ) and CompareVersionNumbers( a, b ) );

    # Turn the lists into records.
    record:= rec();
    for r in GAPInfo.PackagesInfo do
      name:= LowercaseString( r.PackageName );
      if IsBound( record.( name ) ) then
        record.( name ) := Concatenation( record.( name ), [ r ] );
      else
        record.( name ):= [ r ];
      fi;
      if IsHPCGAP then
        # FIXME: we make the package info record immutable, to
        # allow access from multiple threads; but that in turn
        # can break packages, which rely on their package info
        # record being readable (see issue #2568)
        MakeImmutable( record.( name ) );
      fi;
    od;
    GAPInfo.PackagesInfo:= AtomicRecord(record);

    GAPInfo.PackagesInfoInitialized:= true;
    LogPackageLoadingMessage( PACKAGE_DEBUG,
        "return from InitializePackagesInfoRecords", "GAP" );
end );


#############################################################################
##
#F  LinearOrderByPartialWeakOrder( <pairs>, <weights> )
##
##  The algorithm works with a directed graph
##  whose vertices are subsets of the <M>c_i</M>
##  and whose edges represent the given partial order.
##  We start with one vertex for each <M>x_i</M> and each <M>y_i</M>
##  from the input list, and draw an edge from <M>x_i</M> to <M>y_i</M>.
##  Furthermore,
##  we need a queue <M>Q</M> of the smallest vertices found up to now,
##  and a stack <M>S</M> of the largest vertices found up to now;
##  both <M>Q</M> and <M>S</M> are empty at the beginning.
##  Now we add the vertices without predecessors to <M>Q</M> and remove the
##  edges from these vertices until no more such vertex is found.
##  Then we put the vertices without successors on <M>S</M> and remove the
##  edges to these vertices until no more such vertex is found.
##  If edges are left then each of them leads eventually into a cycle in the
##  graph; we find a cycle and amalgamate it into a new vertex.
##  Now we repeat the process until all edges have disappeared.
##  Finally, the concatenation of <M>Q</M> and <M>S</M> gives us the sets
##  <M>c_i</M>.
##
InstallGlobalFunction( LinearOrderByPartialWeakOrder,
    function( pairs, weights )
    local Q, S, Qw, Sw, F, pair, vx, vy, v, pos, candidates, minwght,
          smallest, s, maxwght, largest, p, cycle, next, new;

    # Initialize the queue and the stack.
    Q:= [];
    S:= [];
    Qw:= [];
    Sw:= [];

    # Create a list of vertices according to the input.
    F:= [];
    for pair in Set( pairs ) do
      if pair[1] <> pair[2] then
        vx:= First( F, r -> r.keys[1] = pair[1] );
        if vx = fail then
          vx:= rec( keys:= [ pair[1] ], succ:= [], pred:= [] );
          Add( F, vx );
        fi;
        vy:= First( F, r -> r.keys[1] = pair[2] );
        if vy = fail then
          vy:= rec( keys:= [ pair[2] ], succ:= [], pred:= [] );
          Add( F, vy );
        fi;
        Add( vx.succ, vy );
        Add( vy.pred, vx );
      fi;
    od;

    # Assign the weights.
    weights:= SortedList( weights );
    for v in F do
      pos:= PositionSorted( weights, v.keys );
      if pos <= Length( weights ) and weights[ pos ][1] = v.keys[1] then
        v.wght:= weights[ pos ][2];
      else
        v.wght:= 0;
      fi;
    od;

    # While F contains a vertex, ...
    while not IsEmpty( F ) do

      # ... find the vertices in F without predecessors and add them to Q,
      # remove the edges from these vertices,
      # and remove these vertices from F.
      candidates:= Filtered( F, v -> IsEmpty( v.pred ) );
      if not IsEmpty( candidates ) then
        minwght:= infinity;    # larger than all admissible weights
        for v in candidates do
          if v.wght < minwght then
            minwght:= v.wght;
            smallest:= [ v ];
          elif v.wght = minwght then
            Add( smallest, v );
          fi;
        od;
        for v in smallest do
          Add( Q, v.keys );
          Add( Qw, v.wght );
          for s in v.succ do
            s.pred:= Filtered( s.pred, x -> not IsIdenticalObj( v, x ) );
            if IsEmpty( s.pred )
               and ForAll( smallest, x -> not IsIdenticalObj( s, x ) ) then
              Add( smallest, s );
            fi;
          od;
          pos:= PositionProperty( F, x -> IsIdenticalObj( v, x ) );
          Unbind( F[ pos ] );
          F:= Compacted( F );
        od;
      fi;

      # Then find the vertices in F without successors and put them on S,
      # remove the edges to these vertices,
      # and remove these vertices from F.
      candidates:= Filtered( F, v -> IsEmpty( v.succ ) );
      if not IsEmpty( candidates ) then
        maxwght:= -1;    # smaller than all admissible weights
        for v in candidates do
          if v.wght > maxwght then
            maxwght:= v.wght;
            largest:= [ v ];
          elif v.wght = maxwght then
            Add( largest, v );
          fi;
        od;
        for v in largest do
          Add( S, v.keys );
          Add( Sw, v.wght );
          for p in v.pred do
            p.succ:= Filtered( p.succ, x -> not IsIdenticalObj( v, x ) );
            if IsEmpty( p.succ )
               and ForAll( largest, x -> not IsIdenticalObj( p, x ) ) then
              Add( largest, p );
            fi;
          od;
          pos:= PositionProperty( F, x -> IsIdenticalObj( v, x ) );
          Unbind( F[ pos ] );
          F:= Compacted( F );
        od;
      fi;

      if not IsEmpty( F ) then
        # Find a cycle in F.
        # (Note that now any vertex has a successor,
        # so we may start anywhere, and eventually get into a cycle.)
        cycle:= [];
        next:= F[1];
        repeat
          Add( cycle, next );
          next:= next.succ[1];
          pos:= PositionProperty( cycle, x -> IsIdenticalObj( x, next ) );
        until pos <> fail;
        cycle:= cycle{ [ pos .. Length( cycle ) ] };

        # Replace the set of vertices in the cycle by a new vertex,
        # replace all edges from/to a vertex outside the cycle
        # to/from a vertex in the cycle by edges to/from the new vertex.
        new:= rec( keys:= [], succ:= [], pred:= [],
                   wght:= Maximum( List( cycle, v -> v.wght ) ) );
        for v in cycle do
          UniteSet( new.keys, v.keys );
          for s in v.succ do
            if ForAll( cycle, w -> not IsIdenticalObj( s, w ) ) then
              if ForAll( new.succ, w -> not IsIdenticalObj( s, w ) ) then
                Add( new.succ, s );
              fi;
              pos:= PositionProperty( s.pred, w -> IsIdenticalObj( v, w ) );
              if ForAll( s.pred, w -> not IsIdenticalObj( new, w ) ) then
                s.pred[ pos ]:= new;
              else
                Unbind( s.pred[ pos ] );
                s.pred:= Compacted( s.pred );
              fi;
            fi;
          od;
          for p in v.pred do
            if ForAll( cycle, w -> not IsIdenticalObj( p, w ) ) then
              if ForAll( new.pred, w -> not IsIdenticalObj( p, w ) ) then
                Add( new.pred, p );
              fi;
              pos:= PositionProperty( p.succ, w -> IsIdenticalObj( v, w ) );
              if ForAll( p.succ, w -> not IsIdenticalObj( new, w ) ) then
                p.succ[ pos ]:= new;
              else
                Unbind( p.succ[ pos ] );
                p.succ:= Compacted( p.succ );
              fi;
            fi;
          od;
          pos:= PositionProperty( F, x -> IsIdenticalObj( v, x ) );
          Unbind( F[ pos ] );
          F:= Compacted( F );
        od;
        Add( F, new );
      fi;

    od;

    # Now the whole input is distributed to Q and S.
    return rec( cycles:= Concatenation( Q, Reversed( S ) ),
                weights:= Concatenation( Qw, Reversed( Sw ) ) );
    end );


#############################################################################
##
#I  InfoPackageLoading
##
##  (We cannot do this in `package.gd'.)
##
DeclareInfoClass( "InfoPackageLoading" );


#############################################################################
##
#F  LogPackageLoadingMessage( <severity>, <message>[, <name>] )
##
if not IsBound( TextAttr ) then
  TextAttr:= "dummy";
fi;
#T needed? (decl. of GAPDoc is loaded before)

InstallGlobalFunction( LogPackageLoadingMessage, function( arg )
    local severity, message, currpkg, i;

    severity:= arg[1];
    message:= arg[2];
    if Length( arg ) = 3 then
      currpkg:= arg[3];
    elif IsBound( GAPInfo.PackageCurrent ) then
      # This happens inside availability tests.
      currpkg:= GAPInfo.PackageCurrent.PackageName;
    else
      currpkg:= "(unknown package)";
    fi;
    if IsString( message ) then
      message:= [ message ];
    fi;
    if severity <= PACKAGE_WARNING
       and UserPreference("UseColorsInTerminal") = true
       and IsBound( TextAttr )
       and IsRecord( TextAttr ) then
      if severity = PACKAGE_ERROR then
        message:= List( message,
            msg -> Concatenation( TextAttr.1, msg, TextAttr.reset ) );
      else
        message:= List( message,
            msg -> Concatenation( TextAttr.4, msg, TextAttr.reset ) );
      fi;
    fi;
    Add( GAPInfo.PackageLoadingMessages, [ currpkg, severity, message ] );
    Info( InfoPackageLoading, severity, currpkg, ": ", message[1] );
    for i in [ 2 .. Length( message ) ] do
      Info( InfoPackageLoading, severity, List( currpkg, x -> ' ' ),
            "  ", message[i] );
    od;
    end );

if not IsReadOnlyGlobal( "TextAttr" ) then
  Unbind( TextAttr );
fi;


#############################################################################
##
#F  DisplayPackageLoadingLog( [<severity>] )
##
InstallGlobalFunction( DisplayPackageLoadingLog, function( arg )
    local severity, entry, message, i;

    if Length( arg ) = 0 then
      severity:= PACKAGE_WARNING;
    else
      severity:= arg[1];
    fi;

    for entry in GAPInfo.PackageLoadingMessages do
      if severity >= entry[2] then
        message:= entry[3];
        Info( InfoPackageLoading, 1, entry[1], ": ", message[1] );
        for i in [ 2 .. Length( message ) ] do
          Info( InfoPackageLoading, 1, List( entry[1], x -> ' ' ),
                "  ", message[i] );
        od;
      fi;
    od;
    end );


#############################################################################
##
#F  PackageAvailabilityInfo( <name>, <version>, <record>, <suggested>,
#F      <checkall> )
##
InstallGlobalFunction( PackageAvailabilityInfo,
    function( name, version, record, suggested, checkall )
    local InvalidStrongDependencies, Name, equal, comp, pair, currversion,
          inforec, skip, msg, dep, record_local, wght, pos, needed, test,
          name2, testpair;

    InvalidStrongDependencies:= function( dependencies, weights,
                                          strong_dependencies )
      local result, order, pair, cycle;

      result:= false;
      if not IsEmpty( strong_dependencies ) then
        order:= LinearOrderByPartialWeakOrder( dependencies, weights ).cycles;
        for pair in strong_dependencies do
          for cycle in order do
            if IsSubset( cycle, pair ) then
              # This condition was imposed by some
              # `OtherPackagesLoadedInAdvance' component.
              LogPackageLoadingMessage( PACKAGE_INFO,
                  [ Concatenation( "PackageAvailabilityInfo: package '",
                        pair[1], "'" ),
                    Concatenation( "shall be loaded before package '", name,
                        "' but must be" ),
                    "in the same load cycle, due to other dependencies" ],
                  Name );
              result:= true;
              if not checkall then
                return result;
              fi;
            fi;
          od;
        od;
      fi;
      return result;
    end;

    Name:= name;
    name:= LowercaseString( name );
    equal:= "";
    if 0 < Length( version ) and version[1] = '=' then
      equal:= "equal";
    fi;

    if name = "gap" then
      # This case occurs if a package requires a particular GAP version.
      return CompareVersionNumbers( GAPInfo.Version, version, equal );
    fi;

    # 1. If the package `name' is already loaded then compare the version
    #    number of the loaded package with the required one.
    #    (Note that at most one version of a package can be available.)
    if IsBound( GAPInfo.PackagesLoaded.( name ) ) then
      return CompareVersionNumbers( GAPInfo.PackagesLoaded.( name )[2],
                                    version, equal );
    fi;

    # 2. If the function was called from `AutoloadPackages'
    #    and if the package is listed among the packages to be excluded
    #    from autoload then exit.
    if IsBound( GAPInfo.ExcludeFromAutoload )
       and name in GAPInfo.ExcludeFromAutoload then
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "package to be excluded from autoload, return 'false'", Name );
      return false;
    fi;

    # 3. Initialize the dependency info.
    for comp in [ "AlreadyHandled", "Dependencies", "StrongDependencies",
                  "InstallationPaths", "Weights" ] do
      if not IsBound( record.( comp ) ) then
        record.( comp ):= [];
      fi;
    od;

    # 4. Deal with the case that `name' is among the packages
    #    from whose tests the current check for `name' arose.
    for pair in record.AlreadyHandled do
      if name = pair[1] then
        if CompareVersionNumbers( pair[2], version, equal ) then
          # The availability of the package will be decided on an outer level.
          return fail;
        else
          # The version assumed on an outer level does not fit.
          return false;
        fi;
      fi;
    od;

    # 5. In recursive calls, regard the current package as handled,
    #    of course in the version in question.
    currversion:= [ name ];
    Add( record.AlreadyHandled, currversion );

    # 6. Get the info records for the package `name',
    #    and take the first record that satisfies the conditions.
    #    (Note that they are ordered w.r.t. descending version numbers.)
    for inforec in PackageInfo( name ) do

      Name:= inforec.PackageName;
      skip:= false;
      currversion[2]:= inforec.Version;

      if IsBound( inforec.Dependencies ) then
        dep:= inforec.Dependencies;
      else
        dep:= rec();
      fi;

      # Test whether this package version fits.
      msg:= [ Concatenation( "PackageAvailabilityInfo for version ",
                             inforec.Version ) ];
      if version <> "" then
        if not CompareVersionNumbers( inforec.Version, version, equal ) then
          # The severity of the log message must be less than `PACKAGE_INFO',
          # since we do not want to see the message when looking for reasons
          # why the current package cannot be loaded.
          LogPackageLoadingMessage( PACKAGE_DEBUG,
              [ Concatenation( "PackageAvailabilityInfo: version ",
                    inforec.Version, " does not fit" ),
                Concatenation( "(required: ", version, ")" ) ],
              inforec.PackageName );
          if not checkall then
            continue;
          fi;
          skip:= true;
        else
          Add( msg, Concatenation( "(required: ", version, ")" ) );
          LogPackageLoadingMessage( PACKAGE_INFO, msg,
              inforec.PackageName );
        fi;
      else
        LogPackageLoadingMessage( PACKAGE_INFO, msg,
            inforec.PackageName );
      fi;

      # Test whether the required GAP version fits.
      if IsBound( dep.GAP )
         and not CompareVersionNumbers( GAPInfo.Version, dep.GAP ) then
        LogPackageLoadingMessage( PACKAGE_INFO,
            Concatenation( "PackageAvailabilityInfo: required GAP version (",
                dep.GAP, ") does not fit",
            inforec.PackageName ) );
        if not checkall then
          continue;
        fi;
        skip:= true;
      fi;

      # Test whether the availability test function fits.
      GAPInfo.PackageCurrent:= inforec;
      test:= inforec.AvailabilityTest();
      Unbind( GAPInfo.PackageCurrent );
      if test = true then
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            Concatenation( "PackageAvailabilityInfo: the AvailabilityTest",
                " function returned 'true'" ),
            inforec.PackageName );
      else
        LogPackageLoadingMessage( PACKAGE_INFO,
            Concatenation( "PackageAvailabilityInfo: the AvailabilityTest",
                " function returned ", String( test ) ),
            inforec.PackageName );
        if not checkall then
          continue;
        fi;
        skip:= true;
      fi;

      # Locate the `init.g' file of the package.
      if Filename( [ Directory( inforec.InstallationPath ) ], "init.g" )
           = fail  then
        LogPackageLoadingMessage( PACKAGE_WARNING,
            Concatenation( "PackageAvailabilityInfo: cannot locate `",
              inforec.InstallationPath,
              "/init.g', please check the installation" ),
            inforec.PackageName );
        if not checkall then
          continue;
        fi;
        skip:= true;
      fi;

      record_local:= StructuralCopy( record );

      # If the GAP library is not yet loaded then assign
      # weight 0 to all packages that may be loaded before the GAP library,
      # and weight 1 to those that need the GAP library to be loaded
      # in advance.
      # The latter means that either another package or the GAP library
      # itself is forced to be loaded in advance,
      # for example because the current package has no `read.g' file.
      if Filename( [ Directory( inforec.InstallationPath ) ], "read.g" )
         = fail or
         ( not IsBound( GAPInfo.LibraryLoaded ) and
           IsBound( dep.OtherPackagesLoadedInAdvance ) and
           not IsEmpty( dep.OtherPackagesLoadedInAdvance ) ) then
        wght:= 1;
      else
        wght:= 0;
      fi;
      pos:= PositionProperty( record_local.Weights, pair -> pair[1] = name );
      if pos = fail then
        Add( record_local.Weights, [ name, wght ] );
      else
        record_local.Weights[ pos ][2]:= wght;
      fi;

      # Check the dependencies of this package version.
      needed:= [];
      if IsBound( dep.OtherPackagesLoadedInAdvance ) then
        Append( record_local.StrongDependencies,
                List( dep.OtherPackagesLoadedInAdvance,
                      x -> [ LowercaseString( x[1] ), name ] ) );
        Append( needed, dep.OtherPackagesLoadedInAdvance );
      fi;
      if IsBound( dep.NeededOtherPackages ) then
        Append( needed, dep.NeededOtherPackages );
      fi;
      test:= true;
      if IsEmpty( needed ) then
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            "PackageAvailabilityInfo: no needed packages",
            inforec.PackageName );
      else
        LogPackageLoadingMessage( PACKAGE_DEBUG, Concatenation(
            [ "PackageAvailabilityInfo: check needed packages" ],
            List( needed,
                  pair -> Concatenation( pair[1], " (", pair[2], ")" ) ) ),
            inforec.PackageName );
        for pair in needed do
          name2:= LowercaseString( pair[1] );
          testpair:= PackageAvailabilityInfo( name2, pair[2], record_local,
                         suggested, checkall );
          if testpair = false then
            # This dependency is not satisfied.
            test:= false;
            LogPackageLoadingMessage( PACKAGE_INFO,
                Concatenation( "PackageAvailabilityInfo: dependency '",
                    name2, "' is not satisfied" ), inforec.PackageName );
            if not checkall then
              # Skip the check of other dependencies.
              break;
            fi;
          elif testpair <> true then
            # The package `name2' is available but not yet loaded.
            Add( record_local.Dependencies, [ name2, name ] );
          fi;
        od;
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            "PackageAvailabilityInfo: check of needed packages done",
            inforec.PackageName );
      fi;
      if test = false then
        # At least one package needed by this version is not available,
        if not checkall then
          continue;
        fi;
        skip:= true;
      fi;

      if InvalidStrongDependencies( record_local.Dependencies,
             record_local.Weights, record_local.StrongDependencies ) then
        # This package version cannot be loaded due to conditions
        # imposed by `OtherPackagesLoadedInAdvance' components.
        # (Log messages are added inside the function.)
        if not checkall then
          continue;
        fi;
        skip:= true;
      fi;

      # All checks for this version have been performed.
      # Go to the next installed version if some check failed.
      if skip then
        continue;
      fi;

      # The version given by `inforec' will be taken.
      # Copy the information back to the argument record.
      record.InstallationPaths:= record_local.InstallationPaths;
      Add( record.InstallationPaths,
           [ name, [ inforec.InstallationPath, inforec.Version,
                     inforec.PackageName, false ] ] );
      record.Dependencies:= record_local.Dependencies;
      record.StrongDependencies:= record_local.StrongDependencies;
      record.AlreadyHandled:= record_local.AlreadyHandled;
      record.Weights:= record_local.Weights;

      if suggested and IsBound( dep.SuggestedOtherPackages ) then
        # Collect info about suggested packages and their dependencies.
        LogPackageLoadingMessage( PACKAGE_DEBUG, Concatenation(
            [ "PackageAvailabilityInfo: check suggested packages" ],
            List( dep.SuggestedOtherPackages,
                  pair -> Concatenation( pair[1], " (", pair[2], ")" ) ) ),
            inforec.PackageName );
        for pair in dep.SuggestedOtherPackages do
          name2:= LowercaseString( pair[1] );
          # Do not change the information collected up to now
          # until we are sure that we will really use the suggested package.
          record_local:= StructuralCopy( record );
          test:= PackageAvailabilityInfo( name2, pair[2], record_local,
                     suggested, checkall );
          if test <> true then
            Add( record_local.Dependencies, [ name2, name ] );
            if IsString( test ) then
              if InvalidStrongDependencies( record_local.Dependencies,
                     record_local.Weights,
                     record_local.StrongDependencies ) then
                test:= false;
              fi;
            fi;
            if test <> false then
              record.InstallationPaths:= record_local.InstallationPaths;
              record.Dependencies:= record_local.Dependencies;
              record.StrongDependencies:= record_local.StrongDependencies;
              record.AlreadyHandled:= record_local.AlreadyHandled;
              record.Weights:= record_local.Weights;
            fi;
          fi;
        od;
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            "PackageAvailabilityInfo: check of suggested packages done",
            inforec.PackageName );
      fi;

      # Print a warning if the package should better be upgraded.
      if IsBound( GAPInfo.PackagesRestrictions.( name ) ) then
        GAPInfo.PackagesRestrictions.( name ).OnLoad( inforec );
      fi;
#T component name OnLoad:
#T shouldn't this be done only if the package is actually loaded?

      LogPackageLoadingMessage( PACKAGE_INFO,
          Concatenation( "PackageAvailabilityInfo: version ",
                         inforec.Version, " is available" ),
          inforec.PackageName );

      return inforec.InstallationPath;

    od;

    # No info record satisfies the requirements.
    if not IsBound( GAPInfo.PackagesInfo.( name ) ) then
      inforec:= First( GAPInfo.PackagesInfoRefuseLoad,
                       r -> LowercaseString( r.PackageName ) = name );
      if inforec <> fail then
        # Some versions are installed but all were refused.
        GAPInfo.PackagesRestrictions.( name ).OnLoad( inforec );
      fi;
    fi;

    LogPackageLoadingMessage( PACKAGE_INFO,
        Concatenation( "PackageAvailabilityInfo: ",
            "no installed version fits" ), Name );

    return false;
end );


#############################################################################
##
#F  TestPackageAvailability( <name>[, <version>][, <checkall>] )
##
InstallGlobalFunction( TestPackageAvailability, function( arg )
    local name, version, checkall, result;

    # Get the arguments.
    name:= LowercaseString( arg[1] );
    version:= "";
    checkall:= false;
    if Length( arg ) = 2 then
      if IsString( arg[2] ) then
        version:= arg[2];
      elif arg[2] = true then
        checkall:= true;
      fi;
    elif Length( arg ) = 3 then
      if IsString( arg[2] ) then
        version:= arg[2];
      fi;
      if arg[3] = true then
        checkall:= true;
      fi;
    fi;

    # Ignore suggested packages.
    result:= PackageAvailabilityInfo( name, version, rec(), false,
                                      checkall );

    if result = false then
      return fail;
    else
      return result;
    fi;
    end );


#############################################################################
##
#F  IsPackageLoaded( <name>[, <version>] )
##
InstallGlobalFunction( IsPackageLoaded, function( name, version... )
    local result;

    if Length(version) > 0 then
        version := version[1];
    fi;
    result := IsPackageMarkedForLoading( name, version );
    if result then
        # check if the package actually completed loading
        result := GAPInfo.PackagesLoaded.( LowercaseString( name ) )[4];
    fi;
    return result;
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

DeclareUserPreference( rec(
  name:= "ShortBanners",
  description:= [
    "If this option is set to <K>true</K>, package banners printed during \
loading will only show the name, version and description of a package."
    ],
  default:= false,
  values:= [ true, false ],
  multi:= false,
  ) );

InstallGlobalFunction( DefaultPackageBannerString,
    function( inforec, useShortBanner... )
    local len, sep, i, str, authors, maintainers, contributors, printPersons;

    if Length( useShortBanner ) = 0 then
      useShortBanner := false;
    elif Length( useShortBanner ) = 1 then
      useShortBanner := useShortBanner[1];
    else
      Error( "DefaultPackageBannerString must be called with at most two arguments" );
    fi;

    # Start with a row of `-' signs.
    len:= SizeScreen()[1] - 3;
    if GAPInfo.TermEncoding = "UTF-8" then
      # The unicode character we use takes up 3 bytes in UTF-8 encoding,
      # hence we must adjust the length accordingly.
      sep:= "─";
      i:= 1;
      while 2 * i <= len do
        Append( sep, sep );
        i:= 2 * i;
      od;
      Append( sep, sep{ [ 1 .. 3 * ( len - i ) ] } );
    else
      sep:= ListWithIdenticalEntries( len, '-' );
    fi;
    Add( sep, '\n' );

    str:= "";

    # Add package name and version number.
    if IsBound( inforec.PackageName ) and IsBound( inforec.Version ) then
      Append( str, Concatenation(
              "Loading ", inforec.PackageName, " ", inforec.Version ) );
    fi;

    # Add the long title.
    if IsBound( inforec.PackageDoc ) and IsBound( inforec.PackageDoc[1] ) and
       IsBound( inforec.PackageDoc[1].LongTitle ) and
       not IsEmpty( inforec.PackageDoc[1].LongTitle ) then
      Append( str, Concatenation(
              " (", inforec.PackageDoc[1].LongTitle, ")" ) );
    fi;
    Add( str, '\n' );

    if not useShortBanner then
        # Add info about the authors and/or maintainers
        printPersons := function( role, persons )
          local fill, person;
          fill:= ListWithIdenticalEntries( Length(role), ' ' );
          Append( str, role );
          for i in [ 1 .. Length( persons ) ] do
            person:= persons[i];
            Append( str, person.FirstNames );
            Append( str, " " );
            Append( str, person.LastName );
            if   IsBound( person.WWWHome ) then
              Append( str, Concatenation( " (", person.WWWHome, ")" ) );
            elif IsBound( person.Email ) then
              Append( str, Concatenation( " (", person.Email, ")" ) );
            fi;
            if   i = Length( persons ) then
              Append( str, ".\n" );
            elif i = Length( persons )-1 then
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
        end;
        if IsBound( inforec.Persons ) then
          authors:= Filtered( inforec.Persons, x -> x.IsAuthor );
          if not IsEmpty( authors ) then
            printPersons( "by ", authors );
          fi;
          contributors:= Filtered( inforec.Persons, x -> not x.IsAuthor and not x.IsMaintainer );
          if not IsEmpty( contributors ) then
            Append( str, "with contributions by:\n");
            printPersons( "   ", contributors );
          fi;
          maintainers:= Filtered( inforec.Persons, x -> x.IsMaintainer );
          if not IsEmpty( maintainers ) and authors <> maintainers then
            Append( str, "maintained by:\n");
            printPersons( "   ", maintainers );
          fi;
        fi;

        # Add info about the home page of the package.
        if IsBound( inforec.PackageWWWHome ) then
          Append( str, "Homepage: " );
          Append( str, inforec.PackageWWWHome );
          Append( str, "\n" );
        fi;

        # Add info about the issue tracker of the package.
        if IsBound( inforec.IssueTrackerURL ) then
          Append( str, "Report issues at " );
          Append( str, inforec.IssueTrackerURL );
          Append( str, "\n" );
        fi;

        str := Concatenation(sep, str, sep);
    fi;

    # temporary hack, in some package names with umlauts are in HTML encoding
    str := RecodeForCurrentTerminal(str);
    str:= ReplacedString( str, "&auml;", RecodeForCurrentTerminal("ä") );
    str:= ReplacedString( str, "&ouml;", RecodeForCurrentTerminal("ö") );
    str:= ReplacedString( str, "&uuml;", RecodeForCurrentTerminal("ü") );

    return str;
    end );


#############################################################################
##
#F  DirectoriesPackagePrograms( <name> )
##
InstallGlobalFunction( DirectoriesPackagePrograms, function( name )
    local info, installationpath;

    # We are not allowed to call
    # `InstalledPackageVersion', `TestPackageAvailability' etc.
    name:= LowercaseString( name );
    info:= PackageInfo( name );
    if IsBound( GAPInfo.PackagesLoaded.( name ) ) then
      # The package is already loaded.
      installationpath:= GAPInfo.PackagesLoaded.( name )[1];
    elif IsBound( GAPInfo.PackageCurrent ) and
         LowercaseString( GAPInfo.PackageCurrent.PackageName ) = name then
      # The package in question is currently going to be loaded.
      installationpath:= GAPInfo.PackageCurrent.InstallationPath;
    elif 0 < Length( info ) then
      # Take the installed package with the highest version
      # that has been found first in the root paths.
      installationpath:= info[1].InstallationPath;
    else
      # This package is not known.
      return [];
    fi;
    return [ Directory( Concatenation( installationpath, "/bin/",
                            GAPInfo.Architecture, "/" ) ) ];
end );


#############################################################################
##
#F  DirectoriesPackageLibrary( <name>[, <path>] )
##
InstallGlobalFunction( DirectoriesPackageLibrary, function( arg )
    local name, path, info, installationpath, tmp;

    if IsEmpty(arg) or 2 < Length(arg) then
        Error( "usage: DirectoriesPackageLibrary( <name>[, <path>] )" );
    elif not ForAll(arg, IsString) then
        Error( "string argument(s) expected" );
    fi;

    name:= LowercaseString( arg[1] );
    if '\\' in name or ':' in name  then
        Error( "<name> must not contain '\\' or ':'" );
    elif 1 = Length(arg)  then
        path := "lib";
    else
        path := arg[2];
    fi;

    # We are not allowed to call
    # `InstalledPackageVersion', `TestPackageAvailability' etc.
    info:= PackageInfo( name );
    if IsBound( GAPInfo.PackagesLoaded.( name ) ) then
      # The package is already loaded.
      installationpath:= GAPInfo.PackagesLoaded.( name )[1];
    elif IsBound( GAPInfo.PackageCurrent ) and
         LowercaseString( GAPInfo.PackageCurrent.PackageName ) = name then
      # The package in question is currently going to be loaded.
      installationpath:= GAPInfo.PackageCurrent.InstallationPath;
    elif 0 < Length( info ) then
      # Take the installed package with the highest version
      # that has been found first in the root paths.
      installationpath:= info[1].InstallationPath;
    else
      # This package is not known.
      return [];
    fi;
    tmp:= Filename( Directory( installationpath ), path );
    if IsDirectoryPath( tmp ) = true then
      return [ Directory( tmp ) ];
    fi;
    return [];
end );


#############################################################################
##
#F  ReadPackage( [<name>, ]<file> )
#F  RereadPackage( [<name>, ]<file> )
##
InstallGlobalFunction( ReadPackage, function( arg )
    local pos, relpath, pkgname, namespace, filename;

    # Note that we cannot use `ReadAndCheckFunc' because this calls
    # `READ_GAP_ROOT', but here we have to read the file in one of those
    # directories where the package version resides that has been loaded
    # or (at least currently) would be loaded.
    if   Length( arg ) = 1 then
      # Guess the package name.
      pos:= Position( arg[1], '/' );
      if pos = fail then
        ErrorNoReturn(arg[1], " is not a filename in the form 'package/filepath'");
      fi;
      relpath:= arg[1]{ [ pos+1 .. Length( arg[1] ) ] };
      pkgname:= LowercaseString( arg[1]{ [ 1 .. pos-1 ] } );
      namespace := GAPInfo.PackagesInfo.(pkgname)[1].PackageName;
    elif Length( arg ) = 2 then
      pkgname:= LowercaseString( arg[1] );
      namespace := GAPInfo.PackagesInfo.(pkgname)[1].PackageName;
      relpath:= arg[2];
    else
      Error( "expected 1 or 2 arguments" );
    fi;

    # Note that `DirectoriesPackageLibrary' finds the file relative to the
    # installation path of the info record chosen in `LoadPackage'.
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
#F  LoadPackageDocumentation( <info> )
##
##  In versions before 4.5, a second argument was required.
##  For the sake of backwards compatibility, we do not forbid a second
##  argument, but we ignore it.
##  (In later versions, we may forbid the second argument.)
##
InstallGlobalFunction( LoadPackageDocumentation, function( arg )
    local info, short, pkgdoc, long, sixfile;

    info:= arg[1];

    # Load all books for the package.
    for pkgdoc in info.PackageDoc do
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
        LogPackageLoadingMessage( PACKAGE_INFO,
            Concatenation( [ "book `", pkgdoc.BookName,
                "': no manual index file `",
                pkgdoc.SixFile, "', ignored" ] ),
            info.PackageName );
      else
        # Finally notify the book via its directory.
#T Here we assume that this is the directory that contains also `manual.six'!
        HELP_ADD_BOOK( short, long,
            Directory( sixfile{ [ 1 .. Length( sixfile )-10 ] } ) );
      fi;
    od;
    end );

#############################################################################
##
#F  LoadPackage_ReadImplementationParts( <secondrun>, <banner> )
##
BindGlobal( "LoadPackage_ReadImplementationParts",
    function( secondrun, banner )
    local pair, info, bannerstring, pkgname, namespace;

    for pair in secondrun do
      namespace := pair[1].PackageName;
      pkgname := LowercaseString( namespace );
      if pair[2] <> fail then
        GAPInfo.PackageCurrent:= pair[1];
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            "start reading file 'read.g'",
            namespace );
        ENTER_NAMESPACE(namespace);
        Read( pair[2] );
        LEAVE_NAMESPACE();
        Unbind( GAPInfo.PackageCurrent );
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            "finish reading file 'read.g'",
            namespace );
      fi;
      # mark the package as completely loaded
      GAPInfo.PackagesLoaded.(pkgname)[4] := true;
      MakeImmutable( GAPInfo.PackagesLoaded.(pkgname) );
    od;

    # Show the banners.
    if banner then
      for pair in secondrun do
        info:= pair[1];

        # If the component `BannerString' is bound in `info' then we print
        # this string, otherwise we print the default banner string.
        if UserPreference( "ShortBanners" ) then
          bannerstring:= DefaultPackageBannerString( info, true );
        elif IsBound( info.BannerFunction ) then
          bannerstring:= RecodeForCurrentTerminal(info.BannerFunction(info));
        elif IsBound( info.BannerString ) then
          bannerstring:= RecodeForCurrentTerminal(info.BannerString);
        else
          bannerstring:= DefaultPackageBannerString( info );
        fi;

        # Suppress output formatting to avoid troubles with umlauts,
        # accents etc. in the banner.
        PrintWithoutFormatting( bannerstring );
      od;
    fi;
    end );


#############################################################################
##
#F  GetPackageNameForPrefix( <prefix> ) . . . . . . . .  show list of matches
#F                                                   or single match directly
##
##  Compute all names of installed packages that match the prefix <prefix>.
##  In case of a unique match return this match,
##  otherwise print an info message about the matches and return <prefix>.
##
##  This function is called by `LoadPackage'.
##
BindGlobal( "GetPackageNameForPrefix", function( prefix )
    local len, lowernames, name, allnames, indent, pos, sep;

    len:= Length( prefix );
    lowernames:= [];
    for name in Set( RecNames( GAPInfo.PackagesInfo ) ) do
      if Length( prefix ) <= Length( name ) and
         name{ [ 1 .. len ] } = prefix then
        Add( lowernames, name );
      fi;
    od;
    if IsEmpty( lowernames ) then
      # No package name matches.
      return prefix;
    fi;
    allnames:= List( lowernames,
                     nam -> GAPInfo.PackagesInfo.( nam )[1].PackageName );
    if Length( allnames ) = 1 then
      # There is one exact match.
      LogPackageLoadingMessage( PACKAGE_DEBUG, Concatenation(
          [ "replace prefix '", prefix, "' by the unique completion '",
            allnames[1], "'" ] ), allnames[1] );
      return lowernames[1];
    fi;

    # Several package names match.
    if 0 < InfoLevel( InfoPackageLoading ) then
      Print( "#I  Call 'LoadPackage' with one of the following strings:\n" );
      len:= SizeScreen()[1] - 6;
      indent:= "#I  ";
      Print( indent );
      pos:= Length( indent );
      sep:= "";
      for name in allnames do
        Print( sep );
        pos:= pos + Length( sep );
        if len < pos + Length( name ) then
          Print( "\n", indent );
          pos:= Length( indent );
        fi;
        Print( "\"", name, "\"" );
        pos:= pos + Length( name ) + 2;
        sep:= ", ";
      od;
      Print( ".\n" );
    fi;
    return prefix;
    end );


#############################################################################
##
#F  LoadPackage( <name>[, <version>][, <banner>] )
##
InstallGlobalFunction( LoadPackage, function( arg )
    local name, Name, version, banner, loadsuggested, msg, depinfo, path,
          pair, i, order, paths, cycle, secondrun, pkgname, pos, info,
          filename, entry, r;

    # Get the arguments.
    if Length( arg ) = 0 then
      name:= "";
    else
      name:= arg[1];
      if not IsString( name ) then
        Error( "<name> must be a string" );
      fi;
      name:= LowercaseString( name );
    fi;
    if not IsBound( GAPInfo.PackagesInfo.( name ) ) then
      name:= GetPackageNameForPrefix( name );
    fi;

    # Return 'fail' if this package is not installed.
    if not IsBound( GAPInfo.PackagesInfo.( name ) ) then
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "no package with this name is installed, return 'fail'", name );
      if InfoLevel(InfoPackageLoading) < 4 then
        Info(InfoWarning,1, name, " package is not available. Check that the name is correct");
        Info(InfoWarning,1, "and it is present in one of the GAP root directories (see '??RootPaths')");
      fi;
      return fail;
    fi;

    # The package is available, fetch the name for messages.
    Name:= GAPInfo.PackagesInfo.( name )[1].PackageName;
    version:= "";
    banner:= not GAPInfo.CommandLineOptions.q and
             not GAPInfo.CommandLineOptions.b;
    if 1 < Length( arg ) then
      if IsString( arg[2] ) then
        version:= arg[2];
        if 2 < Length( arg ) then
          banner:= banner and not ( arg[3] = false );
        fi;
      else
        banner:= banner and not ( arg[2] = false );
      fi;
    fi;
    loadsuggested:= ( ValueOption( "OnlyNeeded" ) <> true );

    # Print a warning if `LoadPackage' is called inside a
    # `LoadPackage' call.
    if not IsBound( GAPInfo.LoadPackageLevel ) then
      GAPInfo.LoadPackageLevel:= 0;
    fi;
    GAPInfo.LoadPackageLevel:= GAPInfo.LoadPackageLevel + 1;
    if GAPInfo.LoadPackageLevel <> 1 then
      if IsBound( GAPInfo.PackageCurrent ) then
        msg:= GAPInfo.PackageCurrent.PackageName;
      else
        msg:= "?";
      fi;
      LogPackageLoadingMessage( PACKAGE_WARNING,
          [ Concatenation( "Do not call `LoadPackage( \"", name,
                "\", ... )' in the package file" ),
            Concatenation( INPUT_FILENAME(), "," ),
            "use `IsPackageMarkedForLoading' instead" ], msg );
    fi;

    # Start logging.
    msg:= "entering LoadPackage ";
    if not loadsuggested then
      Append( msg, " (omitting suggested packages)" );
    fi;
    LogPackageLoadingMessage( PACKAGE_DEBUG, msg, Name );

    # Test whether the package is available,
    # and compute the dependency information.
    depinfo:= rec();
    path:= PackageAvailabilityInfo( name, version, depinfo, loadsuggested,
                                    false );
    if not IsString( path ) then
      if path = false then
        path:= fail;
      fi;
      # The result is either `true' (the package is already loaded)
      # or `fail' (the package cannot be loaded).
      if path = true then
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            "return from LoadPackage, package was already loaded", Name );
      else
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            "return from LoadPackage, package is not available", Name );
        if banner then
          if InfoLevel(InfoPackageLoading) < 4 then
            Info(InfoWarning,1, Name, " package is not available. To see further details, enter");
            Info(InfoWarning,1, "SetInfoLevel(InfoPackageLoading,4); and try to load the package again.");
          fi;
        fi;
      fi;
      GAPInfo.LoadPackageLevel:= GAPInfo.LoadPackageLevel - 1;
      return path;
    fi;

    # Suspend reordering of methods following InstallTrueMethod
    # because it would slow things down too much
    SuspendMethodReordering();

    # Compute the order in which the packages are loaded.
    # For each set of packages with cyclic dependencies,
    # we will first read all `init.g' files
    # and afterwards all `read.g' files.
    if IsEmpty( depinfo.Dependencies ) then
      order:= rec( cycles:= [ [ name ] ],
                   weights:= [ depinfo.Weights[1][2] ] );
    else
      order:= LinearOrderByPartialWeakOrder( depinfo.Dependencies,
                                             depinfo.Weights );
    fi;
    # paths:= TransposedMatMutable( depinfo.InstallationPaths );
    # (TransposedMatMutable is not yet available here ...)
    paths:= [ [], [] ];
    for pair in depinfo.InstallationPaths do
      Add( paths[1], pair[1] );
      Add( paths[2], pair[2] );
    od;
    SortParallel( paths[1], paths[2] );

    secondrun:= [];
    for i in [ 1 .. Length( order.cycles ) ] do
      cycle:= order.cycles[i];

      # First mark all packages in the current cycle as loaded,
      # in order to avoid that an occasional call of `LoadPackage'
      # inside the package code causes the files to be read more than once.
      for pkgname in cycle do
        pos:= PositionSorted( paths[1], pkgname );
        # the following entry is made immutable in LoadPackage_ReadImplementationParts
        GAPInfo.PackagesLoaded.( pkgname ):= paths[2][ pos ];
      od;

      # If the weight is 1 and the GAP library is not yet loaded
      # then load the GAP library now.
      if order.weights[i] = 1 and not IsBound( GAPInfo.LibraryLoaded ) then
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            [ "read the impl. part of the GAP library" ], Name );
        ReadGapRoot( "lib/read.g" );
        GAPInfo.LibraryLoaded:= true;
        LoadPackage_ReadImplementationParts( Concatenation(
            GAPInfo.delayedImplementationParts, secondrun ), false );
        GAPInfo.delayedImplementationParts:= [];
        secondrun:= [];
      fi;

      if loadsuggested then
        msg:= "start loading needed/suggested/self packages";
      else
        msg:= "start loading needed/self packages";
      fi;
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          Concatenation( [ msg ], cycle ),
          Name );

      for pkgname in cycle do
        pos:= PositionSorted( paths[1], pkgname );
        info:= First( PackageInfo( pkgname ),
                      r -> r.InstallationPath = paths[2][ pos ][1] );

        if not ValidatePackageInfo(info) then
           Print("#E Validation of package ", pkgname, " from ", info.InstallationPath, " failed\n");
        fi;

        # Notify the documentation (for the available version).
        LoadPackageDocumentation( info );

        # Notify extensions provided by the package.
        if IsBound( info.Extensions ) then
          for entry in info.Extensions do
            LogPackageLoadingMessage( PACKAGE_DEBUG,
                "notify extension ", entry.filename,
                " of package ", pkgname );
            r:= ShallowCopy( entry );
            r.providedby:= pkgname;
            Add( GAPInfo.PackageExtensionsPending, Immutable( r ) );
          od;
        fi;

        # Read the `init.g' files.
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            "start reading file 'init.g'",
            info.PackageName );
        GAPInfo.PackageCurrent:= info;
        ReadPackage( pkgname, "init.g" );
        Unbind( GAPInfo.PackageCurrent );
        LogPackageLoadingMessage( PACKAGE_DEBUG,
            "finish reading file 'init.g'",
            info.PackageName );

        filename:= Filename( [ Directory( info.InstallationPath ) ],
                             "read.g" );
        Add( secondrun, [ info, filename ] );
      od;

      if IsBound( GAPInfo.LibraryLoaded )
         and GAPInfo.LibraryLoaded = true then
        # Read the `read.g' files collected up to now.
        # Afterwards show the banners.
        # (We have delayed this until now because it uses functionality
        # from the package GAPDoc.)
        # Note that no banners are printed during autoloading.
        LoadPackage_ReadImplementationParts( secondrun, banner );
        secondrun:= [];
      fi;

    od;

    if IsBound( GAPInfo.LibraryLoaded ) then
      # Load those package extensions whose condition is satisfied.
      for i in [ 1 .. Length( GAPInfo.PackageExtensionsPending ) ] do
        entry:= GAPInfo.PackageExtensionsPending[i];
        if ForAll( entry.needed, l -> IsPackageLoaded( l[1], l[2] ) ) then
          ReadPackage( entry.providedby, entry.filename );
          Add( GAPInfo.PackageExtensionsLoaded, entry );
          Unbind( GAPInfo.PackageExtensionsPending[i] );
          LogPackageLoadingMessage( PACKAGE_DEBUG,
              "load extension ", entry.filename,
              " of package ", entry.providedby );
        fi;
      od;
      GAPInfo.PackageExtensionsPending:= Compacted( GAPInfo.PackageExtensionsPending );
    else
      Append( GAPInfo.delayedImplementationParts, secondrun );
    fi;

    LogPackageLoadingMessage( PACKAGE_DEBUG, "return from LoadPackage",
        Name );
    GAPInfo.LoadPackageLevel:= GAPInfo.LoadPackageLevel - 1;

    ResumeMethodReordering();
    return true;
    end );


#############################################################################
##
#F  LoadAllPackages()
##
InstallGlobalFunction( LoadAllPackages, function()
    SuspendMethodReordering();
    if ValueOption( "reversed" ) = true then
        List( Reversed( RecNames( GAPInfo.PackagesInfo ) ), LoadPackage );
    else
        List( RecNames( GAPInfo.PackagesInfo ), LoadPackage );
    fi;
    ResumeMethodReordering();
    end );


#############################################################################
##
#F  SetPackagePath( <pkgname>, <pkgpath> )
##
InstallGlobalFunction( SetPackagePath, function( pkgname, pkgpath )
    local pkgdir, file, record;

    InitializePackagesInfoRecords();
    pkgname:= LowercaseString( pkgname );
    NormalizeWhitespace( pkgname );
    if IsBound( GAPInfo.PackagesLoaded.( pkgname ) ) then
      # compare using `Directory` to expand "~" and add trailing "/"
      if Directory( GAPInfo.PackagesLoaded.( pkgname )[1] ) = Directory( pkgpath ) then
        return;
      fi;
      Error( "another version of package ", pkgname, " is already loaded" );
    fi;

    pkgdir:= Directory( pkgpath );
    file:= Filename( [ pkgdir ], "PackageInfo.g" );
    if file = fail then
      return;
    fi;
    Unbind( GAPInfo.PackageInfoCurrent );
    Read( file );
    record:= GAPInfo.PackageInfoCurrent;
    Unbind( GAPInfo.PackageInfoCurrent );
    if pkgname <> NormalizedWhitespace( LowercaseString(
                      record.PackageName ) ) then
      Error( "found package ", record.PackageName, " not ", pkgname,
             " in ", pkgpath );
    fi;
    if IsBound( GAPInfo.PackagesRestrictions.( pkgname ) )
       and GAPInfo.PackagesRestrictions.( pkgname ).OnInitialization(
               record ) = false  then
      Add( GAPInfo.PackagesInfoRefuseLoad, record );
    else
      record.InstallationPath:= Filename( [ pkgdir ], "" );
      if not IsBound( record.PackageDoc ) then
        record.PackageDoc:= [];
      elif IsRecord( record.PackageDoc ) then
        record.PackageDoc:= [ record.PackageDoc ];
      fi;
    fi;
    GAPInfo.PackagesInfo.( pkgname ):= [ record ];
    end );


#############################################################################
##
#F  ExtendRootDirectories( <paths> )
##
InstallGlobalFunction( ExtendRootDirectories, function( rootpaths )
    local i;

    rootpaths:= Filtered( rootpaths, path -> not path in GAPInfo.RootPaths );
    if not IsEmpty( rootpaths ) then
      # 'DirectoriesLibrary' concatenates root paths with directory names.
      for i in [ 1 .. Length( rootpaths ) ] do
        if not EndsWith( rootpaths[i], "/" ) then
          rootpaths[i]:= Concatenation( rootpaths[i], "/" );
        fi;
      od;
      # Append the new root paths.
      GAPInfo.RootPaths:= Immutable( Concatenation( GAPInfo.RootPaths,
          rootpaths ) );
      # Clear the cache.
      GAPInfo.DirectoriesLibrary:= AtomicRecord( rec() );
      # Reread the package information.
      if IsBound( GAPInfo.PackagesInfoInitialized ) and
         GAPInfo.PackagesInfoInitialized = true then
        GAPInfo.PackagesInfoInitialized:= false;
        InitializePackagesInfoRecords();
      fi;
    fi;
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

# The packages to load during startup can be specified via a user preference.
DeclareUserPreference( rec(
  name:= "PackagesToLoad",
  description:= [
    "A list of names of packages which should be loaded during startup. \
For backwards compatibility, the default lists most of packages \
that were autoloaded in &GAP; 4.4 (add or remove packages as you like)."
    ],
  default:= [ "autpgrp", "alnuth", "crisp", "ctbllib", "factint", "fga",
              "irredsol", "laguna", "polenta", "polycyclic", "resclasses",
              "sophus", "tomlib" ],
  values:= function() return RecNames( GAPInfo.PackagesInfo ); end,
  multi:= true,
  ) );

# And a preference for avoiding some packages.
DeclareUserPreference( rec(
  name:= "ExcludeFromAutoload",
  description:= [
    "These packages are not loaded at &GAP; startup. This doesn't work for \
packages which are needed by the &GAP; library, or which are already loaded \
in a workspace."
    ],
  default:= [],
  values:= function() return RecNames( GAPInfo.PackagesInfo ); end,
  multi:= true,
  ) );

# And a preference for ignoring some packages completely during the session.
DeclareUserPreference( rec(
  name:= "PackagesToIgnore",
  description:= [
    "These packages are not regarded as available. This doesn't work for \
packages which are needed by the &GAP; library, or which are already loaded \
in a workspace."
    ],
  default:= [],
  values:= function() return RecNames( GAPInfo.PackagesInfo ); end,
  multi:= true,
  ) );

# And a preference for setting the info level of package loading.
DeclareUserPreference( rec(
  name:= "InfoPackageLoadingLevel",
  description:= [
    "Info messages concerning package loading up to this level are printed.  \
The level can be changed in a running session using \
<Ref Oper=\"SetInfoLevel\"/>."
    ],
  default:= PACKAGE_ERROR,
  values:= [ PACKAGE_ERROR, PACKAGE_WARNING, PACKAGE_INFO, PACKAGE_DEBUG ],
  multi:= false,
  ) );

InstallGlobalFunction( AutoloadPackages, function()
    local msg, pair, excludedpackages, name, record, neededPackages;

    SetInfoLevel( InfoPackageLoading,
        UserPreference( "InfoPackageLoadingLevel" ) );

    if GAPInfo.CommandLineOptions.L = "" then
      msg:= "entering AutoloadPackages (no workspace)";
    else
      msg:= Concatenation( "entering AutoloadPackages (workspace ",
                           GAPInfo.CommandLineOptions.L, ")" ) ;
    fi;
    LogPackageLoadingMessage( PACKAGE_DEBUG, msg, "GAP" );

    GAPInfo.ExcludeFromAutoload:= [];
    GAPInfo.PackagesInfoInitialized:= false;
    InitializePackagesInfoRecords();

    GAPInfo.delayedImplementationParts:= [];

    # If --bare is specified, load no packages
    if GAPInfo.CommandLineOptions.bare then
      neededPackages := [];
    else
      neededPackages := GAPInfo.Dependencies.NeededOtherPackages;
    fi;

    # Load the needed other packages (suppressing banners)
    # that are not yet loaded.
    if ForAny( neededPackages,
               p -> not IsBound( GAPInfo.PackagesLoaded.( p[1] ) ) ) then
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          Concatenation( [ "trying to load needed packages" ],
              List( neededPackages,
                  pair -> Concatenation( pair[1], " (", pair[2], ")" ) ) ),
          "GAP" );
      if GAPInfo.CommandLineOptions.A then
        PushOptions( rec( OnlyNeeded:= true ) );
      fi;
      for pair in neededPackages do
        if LoadPackage( pair[1], pair[2], false ) <> true then
          LogPackageLoadingMessage( PACKAGE_ERROR, Concatenation(
              "needed package ", pair[1], " cannot be loaded" ), "GAP" );
          Error( "failed to load needed package `", pair[1],
                 "' (version ", pair[2], ")" );
        fi;
      od;
      LogPackageLoadingMessage( PACKAGE_DEBUG, "needed packages loaded",
          "GAP" );
      if GAPInfo.CommandLineOptions.A then
        PopOptions();
      fi;
    fi;

    # If necessary then load the implementation part of the GAP library,
    # and the implementation parts of the packages loaded up to now.
    if not IsBound( GAPInfo.LibraryLoaded ) then
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          [ "read the impl. part of the GAP library" ], "GAP" );
      ReadGapRoot( "lib/read.g" );
      GAPInfo.LibraryLoaded:= true;
      GAPInfo.LoadPackageLevel:= GAPInfo.LoadPackageLevel + 1;
      LoadPackage_ReadImplementationParts(
          GAPInfo.delayedImplementationParts, false );
      GAPInfo.LoadPackageLevel:= GAPInfo.LoadPackageLevel - 1;
    fi;
    Unbind( GAPInfo.delayedImplementationParts );

    # Load suggested packages of GAP (suppressing banners).
    if   GAPInfo.CommandLineOptions.A then
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "omitting packages suggested via \"PackagesToLoad\" (-A option)",
          "GAP" );
    elif ValueOption( "OnlyNeeded" ) = true then
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          [ "omitting packages suggested via \"PackagesToLoad\"",
            " ('OnlyNeeded' option)" ],
          "GAP" );
    elif ForAny( List( UserPreference( "PackagesToLoad" ), LowercaseString ),
                 p -> not IsBound( GAPInfo.PackagesLoaded.( p ) ) ) then

      # Try to load the suggested other packages (suppressing banners),
      # issue a warning for each such package where this is not possible.
      excludedpackages:= List( UserPreference( "ExcludeFromAutoload" ),
                               LowercaseString );
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          Concatenation( [ "trying to load suggested packages" ],
              UserPreference( "PackagesToLoad" ) ),
          "GAP" );
      for name in UserPreference( "PackagesToLoad" ) do
#T admit pair [ name, version ] in user preferences!
        if LowercaseString( name ) in excludedpackages then
          LogPackageLoadingMessage( PACKAGE_DEBUG,
              Concatenation( "excluded from autoloading: ", name ),
              "GAP" );
        elif not IsBound( GAPInfo.PackagesLoaded.( LowercaseString( name ) ) ) then
          LogPackageLoadingMessage( PACKAGE_DEBUG,
              Concatenation( "considering for autoloading: ", name ),
              "GAP" );
          if LoadPackage( name, false ) <> true then
            LogPackageLoadingMessage( PACKAGE_DEBUG,
                 Concatenation( "suggested package ", name,
                     " cannot be loaded" ), "GAP" );
          else
            LogPackageLoadingMessage( PACKAGE_DEBUG,
                Concatenation( name, " loaded" ), "GAP" );
#T possible to get the right case of the name?
          fi;
        fi;
      od;
      LogPackageLoadingMessage( PACKAGE_DEBUG,
          "suggested packages loaded", "GAP" );
    fi;

    # Load the documentation for not yet loaded packages.
    LogPackageLoadingMessage( PACKAGE_DEBUG,
        "call LoadPackageDocumentation for not loaded packages",
        "GAP" );
    for name in RecNames( GAPInfo.PackagesInfo ) do
      if not IsBound( GAPInfo.PackagesLoaded.( name ) ) then
        # Note that the info records for each package are sorted
        # w.r.t. decreasing version number.
        record:= First( GAPInfo.PackagesInfo.( name ), IsRecord );
        if record <> fail then
          LoadPackageDocumentation( record );
        fi;
      fi;
    od;
    LogPackageLoadingMessage( PACKAGE_DEBUG,
        "LoadPackageDocumentation for not loaded packages done",
        "GAP" );

    Unbind( GAPInfo.ExcludeFromAutoload );

    LogPackageLoadingMessage( PACKAGE_DEBUG,
        "return from AutoloadPackages",
        "GAP" );
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

    atomic readonly HELP_REGION do
      entries:= HELP_BOOK_HANDLER.GapDocGAP.ReadSix( stream ).entries;
    od;

    SecNumber:= function( list )
      if IsEmpty( list ) or list[1] = 0 then
        return "";
      fi;
      while Last( list ) = 0 do
        Remove( list );
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
                                       esctex(NormalizedWhitespace(entry[1])),
                                       "}{", SecNumber( entry[3] ), "}{",
                                       entry[7], "}\n" ) );
    # forget entries that contain a character from "\\*+/=" in label,
    # these were never allowed, so no old manual will refer to them
    entries := Filtered(entries, entry ->
                    not ForAny("\\*+/=", c-> c in entry{[9..Length(entry)]}));
    file:= Concatenation( sixfilepath{ [ 1 .. Length( sixfilepath ) - 3 ] },
                          "lab" );
    # add marker line
    entries := Concatenation (
        [Concatenation ("\\GAPDocLabFile{", bookname,"}\n")],
        entries);
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
#F  ValidatePackageInfo( <info> )
##
InstallGlobalFunction( ValidatePackageInfo, function( info )
    local record, pkgdir, i, IsStringList, IsRecordList, IsProperBool, IsURL,
          IsFilename, IsFilenameList, result, TestOption, TestMandat, subrec,
          list, CheckDateValidity;

    if IsString( info ) then
      if IsReadableFile( info ) then
        Unbind( GAPInfo.PackageInfoCurrent );
        Read( info );
        if IsBound( GAPInfo.PackageInfoCurrent ) then
          record:= GAPInfo.PackageInfoCurrent;
          Unbind( GAPInfo.PackageInfoCurrent );
        else
          Error( "the file <info> is not a `PackageInfo.g' file" );
        fi;
        pkgdir:= "./";
        for i in Reversed( [ 1 .. Length( info ) ] ) do
          if info[i] = '/' then
            pkgdir:= info{ [ 1 .. i ] };
            break;
          fi;
        od;
      else
        Error( "<info> is not the name of a readable file" );
      fi;
    elif IsRecord( info ) then
      pkgdir:= fail;
      record:= info;
    else
      Error( "<info> must be either a record or a filename" );
    fi;

    IsStringList:= x -> IsList( x ) and ForAll( x, IsString );
    IsRecordList:= x -> IsList( x ) and ForAll( x, IsRecord );
    IsProperBool:= x -> x = true or x = false;
    IsFilename:= x -> IsString( x ) and Length( x ) > 0 and
        ( pkgdir = fail or
          ( x[1] <> '/' and IsReadableFile( Concatenation( pkgdir, x ) ) ) );
    IsFilenameList:= x -> IsList( x ) and ForAll( x, IsFilename );
    IsURL := x -> ForAny(["http://","https://","ftp://"], s -> StartsWith(x,s));

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

    # check if the date is valid
    CheckDateValidity := function(x)
      local date;

      if not ( IsString(x) and Length(x) = 10
        and ( ( ForAll( x{ [1,2,4,5,7,8,9,10] }, IsDigitChar )
        and  x{ [3,6] } = "//" ) or ( ForAll( x{ [1,2,3,4,6,7,9,10] }, IsDigitChar ) and x{ [5,8] } = "--" ) ) ) then
        return false;
      elif x{ [3,6] } = "//" then # for the old format split at '/'
        date := List( SplitString( x, "/" ), Int);
      elif x{ [5,8] } = "--" then # for the yyyy-mm-dd format split at '-'
        date := List( SplitString( x, "-" ), Int);
        date := date{ [3,2,1] }; # sort such that date=[dd,mm,yyyy]
      fi;
      return date[2] in [1..12] and date[3] >= 1999 # GAP 4 appeared in 1999
          and date[1] in [1..DaysInMonth( date[2], date[3] )];
    end;

    TestMandat( record, "Date", CheckDateValidity, Concatenation( "a string of the form yyyy-mm-dd or dd/mm/yyyy",
    " that represents a date since 1999") );

    # If the date is in the format `dd/mm/yyyy` a message is printed
    # code to be used after an adaption period for packages
    #if IsBound( record.Date ) and  CheckDateValidity( record.Date ) and record.Date{ [3,6] } = "//" then
    #   Info( InfoPackageLoading, 2, Concatenation( record.PackageName, ": Please be advised to change the date format to `yyyy-mm-dd`") );
    #fi;

    TestMandat( record, "License",
        x -> IsString(x) and 0 < Length(x),
        "a nonempty string containing an SPDX ID" );
    TestMandat( record, "ArchiveURL", IsURL, "a string started with http://, https:// or ftp://" );
    TestMandat( record, "ArchiveFormats", IsString, "a string" );
    TestOption( record, "TextFiles", IsStringList, "a list of strings" );
    TestOption( record, "BinaryFiles", IsStringList, "a list of strings" );
    TestOption( record, "TextBinaryFilesPatterns",
        x -> IsStringList(x) and
             ForAll( x, i -> Length(i) > 0 ) and
             ForAll( x, i -> i[1] in ['T','B'] ),
        "a list of strings, each started with 'T' or 'B'" );
    if Number( [ IsBound(record.TextFiles),
                 IsBound(record.BinaryFiles),
                 IsBound(record.TextBinaryFilesPatterns) ],
               a -> a=true ) > 1 then
      Print("#W  only one of TextFiles, BinaryFiles or TextBinaryFilesPatterns\n");
      Print("#W  components must be bound\n");
    fi;
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
        if IsBound( subrec.IsMaintainer ) then
          if subrec.IsMaintainer = true and
               not ( IsBound( subrec.Email ) or
                     IsBound( subrec.WWWHome ) or
                     IsBound( subrec.PostalAddress ) ) then
            Print( "#E  one of the components `Email', `WWWHome', `PostalAddress'\n",
                   "#E  must be bound for each package maintainer \n" );
            result:= false;
          fi;
        fi;
        TestOption( subrec, "Email", IsString, "a string" );
        TestOption( subrec, "WWWHome", IsURL, "a string started with http://, https:// or ftp://" );
        TestOption( subrec, "PostalAddress", IsString, "a string" );
        TestOption( subrec, "Place", IsString, "a string" );
        TestOption( subrec, "Institution", IsString, "a string" );
      od;
    fi;

    TestMandat( record, "README_URL", IsURL, "a string started with http://, https:// or ftp://" );
    TestMandat( record, "PackageInfoURL", IsURL, "a string started with http://, https:// or ftp://" );

    if TestOption( record, "SourceRepository", IsRecord, "a record" ) then
      if IsBound( record.SourceRepository ) then
        TestMandat( record.SourceRepository, "Type", IsString, "a string" );
        TestMandat( record.SourceRepository, "URL", IsString, "a string" );
      fi;
    fi;
    TestOption( record, "IssueTrackerURL", IsURL, "a string started with http://, https:// or ftp://" );
    TestOption( record, "SupportEmail", IsString, "a string" );
    TestMandat( record, "AbstractHTML", IsString, "a string" );
    TestMandat( record, "PackageWWWHome", IsURL, "a string started with http://, https:// or ftp://" );
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
        if IsBound(subrec.Archive) then
          Print("#W  PackageDoc.Archive is withdrawn, use PackageDoc.ArchiveURLSubset instead\n");
        fi;
        TestMandat( subrec, "ArchiveURLSubset", IsFilenameList,
            "a list of strings denoting relative paths to readable files or directories" );
        TestMandat( subrec, "HTMLStart", IsFilename,
                    "a string denoting a relative path to a readable file" );
        TestMandat( subrec, "PDFFile", IsFilename,
                    "a string denoting a relative path to a readable file" );
        TestMandat( subrec, "SixFile", IsFilename,
                    "a string denoting a relative path to a readable file" );
        TestMandat( subrec, "LongTitle", IsString, "a string" );
      od;
    fi;
    if     TestOption( record, "Dependencies", IsRecord, "a record" )
       and IsBound( record.Dependencies ) then
      TestOption( record.Dependencies, "GAP", IsString, "a string" );
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

      # If the package is a needed package of GAP then all its needed
      # packages must also occur in the list of needed packages of GAP.
      list:= List( GAPInfo.Dependencies.NeededOtherPackages,
                   x -> LowercaseString( x[1] ) );
      if     IsBound( record.PackageName )
         and IsString( record.PackageName )
         and LowercaseString( record.PackageName ) in list
         and IsBound( record.Dependencies.NeededOtherPackages )
         and IsList( record.Dependencies.NeededOtherPackages ) then
        list:= Filtered( record.Dependencies.NeededOtherPackages,
                         x ->     IsList( x ) and IsBound( x[1] )
                              and IsString( x[1] )
                              and not LowercaseString( x[1] ) in list );
        if not IsEmpty( list ) then
          Print( "#E  the needed packages in '",
                 List( list, x -> x[1] ), "'\n",
                 "#E  are currently not needed packages of GAP\n" );
          result:= false;
        fi;
      fi;
    fi;
    TestOption( record, "Extensions",
        comp -> IsList( comp ) and ForAll( comp,
                    r -> IsRecord( r ) and
                         IsBound( r.needed ) and IsList( r.needed ) and
                         ForAll( r.needed,
                             l -> IsList( l ) and Length( l ) = 2 and
                                  ForAll( l, IsString ) ) and
                         IsBound( r.filename ) and IsString( r.filename ) ),
        "a list of records with components `needed' and `filename'" );
    TestMandat( record, "AvailabilityTest", IsFunction, "a function" );
    TestOption( record, "BannerFunction", IsFunction, "a function" );
    TestOption( record, "BannerString", IsString, "a string" );
    TestOption( record, "TestFile", IsFilename,
                "a string denoting a relative path to a readable file" );
    TestOption( record, "Keywords", IsStringList, "a list of strings" );

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
##      and returns <K>false</K> if not.
##      The function is allowed to change components of the argument record.
##      It should not print any message,
##      this should be left to the <C>OnLoad</C> component,
##  </Item>
##  <Mark><C>OnLoad</C></Mark>
##  <Item>
##      a function that takes one argument, the record stored in the
##      <F>PackageInfo.g</F> file of the package, and can print a message
##      when the availability of the package is checked for the first time;
##      this message is intended to explain why the package cannot loaded due
##      to the <K>false</K> result of the <C>OnInitialization</C> component,
##      or as a warning about known problems (when the package is in fact
##      loaded), and it might give hints for upgrading the package.
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##
GAPInfo.PackagesRestrictions := AtomicRecord(rec(
  anupq := MakeImmutable(rec(
    OnInitialization := function( pkginfo )
        if CompareVersionNumbers( pkginfo.Version, "1.3" ) = false then
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
        end )),

  autpgrp := MakeImmutable(rec(
    OnInitialization := function( pkginfo )
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
              "      https://www.gap-system.org/Packages/autpgrp.html\n" );
        fi;
        end )) ));


#############################################################################
##
#F  SuggestUpgrades( versions ) . . compare installed with distributed versions
##
InstallGlobalFunction( SuggestUpgrades, function( suggestedversions )
    local ok, outstr, out, entry, inform, info;

    suggestedversions := Set( suggestedversions, ShallowCopy );
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
    inform := Difference(RecNames(GAPInfo.PackagesInfo),
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


#############################################################################
##
#F  BibEntry( "GAP"[, <key>] )
#F  BibEntry( <pkgname>[, <key>] )
#F  BibEntry( <pkginfo>[, <key>] )
##
Unicode:= "dummy";
Encode:= "dummy";

InstallGlobalFunction( BibEntry, function( arg )
    local key, pkgname, pkginfo, GAP, ps, months, val, entry, author;

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
        pkginfo:= InstalledPackageVersion( pkgname );
        pkginfo:= First( PackageInfo( pkgname ), r -> r.Version = pkginfo );
        if pkginfo = fail then
          return "";
        fi;
      fi;
    fi;

    if key = false then
      if GAP then
        key:= "GAP";
      else
        key:= pkginfo.PackageName;
      fi;
    fi;

    # Make sure that output of BibEntry is in UTF-8 encoding (also
    # if PackageInfo.g is in latin1 encoding)
    ps:= function( str )
      local uni;

      uni:= Unicode( str, "UTF-8" );
      if uni = fail then
        uni:= Unicode( str, "ISO-8859-1" );
      fi;
      return Encode( uni, "UTF-8" );
    end;

    # According to <Cite Key="La85"/>,
    # the supported fields of a Bib&TeX; entry of <C>@misc</C> type are
    # the following.
    # <P/>
    # <List>
    # <Mark><C>author</C></Mark>
    # <Item>
    #   computed from the <C>Persons</C> component of the package,
    #   not distinguishing authors and maintainers,
    #   keeping the ordering of entries,
    # </Item>
    # <Mark><C>title</C></Mark>
    # <Item>
    #   computed from the <C>PackageName</C> and <C>Subtitle</C> components
    #   of the package,
    # </Item>
    # <Mark><C>month</C> and <C>year</C></Mark>
    # <Item>
    #   computed from the <C>Date</C> component of the package,
    # </Item>
    # <Mark><C>note</C></Mark>
    # <Item>
    #   the string <C>"Refereed \\textsf{GAP} package"</C> or
    #   <C>"\\textsf{GAP} package"</C>,
    # </Item>
    # <Mark><C>howpublished</C></Mark>
    # <Item>
    #   the <C>PackageWWWHome</C> component of the package.
    # </Item>
    # </List>
    # <P/>
    # Also the <C>edition</C> component seems to be supported;
    # it is computed from the <C>Version</C> component of the package.

    # Bib&Tex;'s <C>@manual</C> type seems to be not appropriate,
    # since this type does not support a URL component
    # in the base bib styles of La&TeX;.
    # Instead we can use the <C>@misc</C> type and its <C>howpublished</C>
    # component.
    # We put the version information into the <C>title</C> component since
    # the <C>edition</C> component is not supported in the base styles.

    months:= [ "Jan", "Feb", "Mar", "Apr", "May", "Jun",
               "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ];
    if GAP then
      val:= SplitString( GAPInfo.Date, "-" );
      if Length( val ) = 3 then
        if Int( val[2] ) in [ 1 .. 12 ] then
          val:= Concatenation( "  <month>", months[ Int( val[2] ) ],
                               "</month>\n  <year>", val[3], "</year>\n" );
        else
          val:= Concatenation( "  <month>", val[2],
                               "</month>\n  <year>", val[3], "</year>\n" );
        fi;
      else
        val:= "";
      fi;
      entry:= Concatenation(
        "<entry id=\"", key, "\"><misc>\n",
        "  <title><C>GAP</C> &ndash;",
        " <C>G</C>roups, <C>A</C>lgorithms,\n",
        "         and <C>P</C>rogramming,",
        " <C>V</C>ersion ", GAPInfo.Version, "</title>\n",
        "  <howpublished><URL>https://www.gap-system.org</URL></howpublished>\n",
        val,
        "  <key>GAP</key>\n",
        "  <keywords>groups; *; gap; manual</keywords>\n",
        "  <other type=\"organization\">The GAP <C>G</C>roup</other>\n",
        "</misc></entry>" );
    else
      entry:= Concatenation( "<entry id=\"", key, "\"><misc>\n" );
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
      if IsBound( pkginfo.PackageWWWHome ) then
        Append( entry, Concatenation(
          "  <howpublished><URL>", pkginfo.PackageWWWHome,
          "</URL></howpublished>\n" ) );
      fi;
      if IsBound( pkginfo.Date ) and IsDenseList( pkginfo.Date )
                                 and Length( pkginfo.Date ) = 10 then
        if Int( pkginfo.Date{ [ 4, 5 ] } ) in [ 1 .. 12 ] then
          Append( entry, Concatenation(
            "  <month>", months[ Int( pkginfo.Date{ [ 4, 5 ] } ) ],
            "</month>\n",
            "  <year>", pkginfo.Date{ [ 7 .. 10 ] }, "</year>\n" ) );
        else
          Append( entry, Concatenation(
            "  <month>", pkginfo.Date{ [ 4, 5 ] }, "</month>\n",
            "  <year>", pkginfo.Date{ [ 7 .. 10 ] }, "</year>\n" ) );
        fi;
      fi;
      Append( entry, "  <note>" );
#     Append( entry, "<Package>GAP</Package> package</note>\n" );
      Append( entry, "GAP package</note>\n" );
      if IsBound( pkginfo.Keywords ) then
        Append( entry, Concatenation(
          "  <keywords>",
          JoinStringsWithSeparator( pkginfo.Keywords, "; " ),
          "</keywords>\n" ) );
      fi;
      Append( entry, "</misc></entry>" );
    fi;

    return entry;
end );

# dummy assignments to functions to be read later in the GAPDoc package
ParseBibXMLextString:= "dummy";
StringBibXMLEntry:= "dummy";

InstallGlobalFunction( Cite, function(arg)
  local name, bib, key, parse, year, en, pkginfo;
  if Length(arg)=0 then
    name:="GAP";
  else
    name := NormalizedWhitespace(arg[1]);
  fi;
  if LowercaseString(name) = "gap" then
    name:="GAP";
  else
    # use spelling as in packages PackageInfo.g
    pkginfo := InstalledPackageVersion(name);
    pkginfo := First(PackageInfo(name), r-> r.Version = pkginfo);
    name := pkginfo.PackageName;
  fi;
  if Length(arg)<=1 then
    bib:= BibEntry( name );
  elif Length(arg)>2 then
    Error("`Cite' takes no more than two arguments");
  else
    key:=arg[2];
    bib:= BibEntry( name, key );
  fi;
  if bib="" then
    Print("WARNING: No working version of package ", name, " is available!\n");
    return;
  fi;
  parse:= ParseBibXMLextString( bib );
  # use encoding of terminal for printing
  en := function(str)
    local enc;
    enc := GAPInfo.TermEncoding;
    if enc = "UTF-8" then
      return str;
    else
      return Encode(Unicode(str, "UTF-8"), enc);
    fi;
  end;
  Print("Please use one of the following samples\n",
        "to cite ", en(name), " version from this installation\n\n");

  Print("Text:\n\n");
  Print( en(StringBibXMLEntry( parse.entries[1], "Text" )) );

  Print("HTML:\n\n");
  Print( en(StringBibXMLEntry( parse.entries[1], "HTML" )) );

  Print("BibXML:\n\n");
  Print( en(bib), "\n\n" );

  Print("BibTeX:\n\n");
  Print( en(StringBibXMLEntry( parse.entries[1], "BibTeX" )), "\n" );

  if name="GAP" then
    # The format of 'GAPInfo.Date' in released GAP is <year>-<month>-<day>.
    # In 'GAP.dev', the value is "today".
    year:= SplitString( GAPInfo.Date, "-" )[1];

    Print("If you are not using BibTeX, here is the bibliography entry produced \n",
          "by BibTeX (in bibliography style `alpha'):\n\n",
          "\\bibitem[GAP]{GAP4}\n",
          "\\emph{GAP -- Groups, Algorithms, and Programming}, ",
          "Version ", GAPInfo.Version, ",\n",
          "The GAP~Group (", year, "), \\verb+https://www.gap-system.org+.\n\n");
    Print(
    "If you have (predominantly) used one or more particular GAP packages,\n",
    "please cite these packages in addition to GAP itself (either check the\n",
    "package documentation for the suggestions, or use a scheme like:\n\n",

    "[PKG]\n",
    "<Author name(s)>, <package name>, <package long title>, \n",
    "Version <package version> (<package date>), (GAP package),\n",
    "<package URL>.\n\n",

    "You may also produce citation samples for a GAP package by entering\n\n",
    "    Cite(\"packagename\");\n\n",
    "in a GAP installation with the working version of this package available.\n\n");
  fi;
end);

Unbind( ParseBibXMLextString );
Unbind( StringBibXMLEntry );
Unbind( Unicode );
Unbind( Encode );


#############################################################################
##
#F  PackageVariablesInfo( <pkgname>, <version> )
##
NamesSystemGVars := "dummy";   # is not yet defined when this file is read
NamesUserGVars   := "dummy";

InstallGlobalFunction( PackageVariablesInfo, function( pkgname, version )
    local test, cache, cache2, PkgName, realname, new, new_up_to_case,
          redeclared, newmethod, pos, key_dependent_operation, rules,
          localBindGlobal, rule, loaded, args, docmark, done, result,
          subrule, added, prev, subresult, entry, isrelevant, guesssource,
          protected;

    pkgname:= LowercaseString( pkgname );
    test:= TestPackageAvailability( pkgname, version );

    # If the function has been called for this package then
    # return the stored value.
    cache:= Concatenation( pkgname, ":", version );
    if not IsBound( GAPInfo.PackageVariablesInfo ) then
      GAPInfo.PackageVariablesInfo:= rec();
    elif IsBound( GAPInfo.PackageVariablesInfo.( cache ) ) then
      return GAPInfo.PackageVariablesInfo.( cache );
    elif version = "" and test = true then
      cache2:= Concatenation( pkgname, ":",
                   InstalledPackageVersion( pkgname ) );
      if IsBound( GAPInfo.PackageVariablesInfo.( cache2 ) ) then
        return GAPInfo.PackageVariablesInfo.( cache2 );
      fi;
    fi;

    # Check that the package is available but not yet loaded.
    if test = true then
      Info( InfoWarning, 1,
            "the package `", pkgname, "' is already loaded" );
      return [];
    elif test = fail then
      if version = "" then
        Info( InfoWarning, 1,
              "the package `", pkgname, "' cannot be loaded" );
      else
        Info( InfoWarning, 1,
              "the package `", pkgname, "' cannot be loaded in version `",
              version, "'" );
      fi;
      return [];
    fi;

    PkgName:= GAPInfo.PackagesInfo.( pkgname )[1].PackageName;

    realname:= function( name )
        if Last(name) = '@' then
          return Concatenation( name, PkgName );
        else
          return name;
        fi;
    end;

    new:= function( entry )
        local name;

        name:= realname( entry[1][1] );
        if not name in GAPInfo.data.varsThisPackage then
          return fail;
        elif Length( entry[1] ) = 3 and entry[1][3] = "mutable"
             and Length( name  ) > 9 and name{ [ 1 .. 8 ] } = "Computed"
             and Last(name) = 's'
             and IsBoundGlobal( name{ [ 9 .. Length( name ) - 1 ] } ) then
          return fail;
        elif Length( entry[1] ) = 2
             and Length( name  ) > 3 and name{ Length( name ) - [1,0] } = "Op"
             and IsBoundGlobal( name{ [ 1 .. Length( name ) - 2 ] } )
             and ForAny( GAPInfo.data.KeyDependentOperation[2],
                         x -> x[1][1] = name{ [ 1 .. Length( name ) - 2 ] }
                              and x[2] = entry[2]
                              and x[3] = entry[3] ) then
          # Ignore the declaration of the operation created by
          # `KeyDependentOperation'.
          # (We compare filename and line number in the file with these values
          # for the call of `KeyDependentOperation'.)
          return fail;
        else
          return [ name, ValueGlobal( name ), entry[2], entry[3] ];
        fi;
      end;

    new_up_to_case:= function( entry )
        local name;

        name:= realname( entry[1][1] );
        if   not name in GAPInfo.data.varsThisPackage then
          return fail;
        elif LowercaseString( name ) in GAPInfo.data.lowercase_vars then
          return [ name, ValueGlobal( name ), entry[2], entry[3] ];
        else
          return fail;
        fi;
      end;

    redeclared:= function( entry )
        local name;

        name:= realname( entry[1][1] );
        if   not name in GAPInfo.data.varsThisPackage then
          return [ name, ValueGlobal( name ), entry[2], entry[3] ];
        else
          return fail;
        fi;
      end;

    newmethod:= function( entry )
      local name, setter, getter;

      name:= NameFunction( entry[1][1] );
      if IsString( entry[1][2] ) then
        if entry[1][2] in [ "system setter", "system mutable setter",
                            "default method, does nothing" ] then
          setter:= entry[1][1];
          if ForAny( ATTRIBUTES,
                     attr -> IsIdenticalObj( setter, attr[4] ) ) then
            return fail;
          fi;
        elif entry[1][2] in [ "system getter",
          "default method requiring categories and checking properties" ] then
          getter:= entry[1][1];
          if ForAny( ATTRIBUTES,
                     attr -> IsIdenticalObj( getter, attr[3] ) ) then
            return fail;
          fi;
        elif entry[1][2] in [ "default method" ] then
          # Ignore the default methods (for attribute and operation)
          # that are installed in calls to `KeyDependentOperation'.
          # (We compare filename and line number in the file
          # with these values for the call of `KeyDependentOperation'.)
          if 9 < Length( name  ) and name{ [ 1 .. 8 ] } = "Computed"
             and Last(name) = 's'
             and IsBoundGlobal( name{ [ 9 .. Length( name ) - 1 ] } )
             and ForAny( GAPInfo.data.KeyDependentOperation[2],
                         x -> x[1][1] = name{ [ 9 .. Length( name ) - 1 ] }
                              and x[2] = entry[2]
                              and x[3] = entry[3] ) then
            return fail;
          elif IsBoundGlobal( name )
               and ForAny( GAPInfo.data.KeyDependentOperation[2],
                           x -> x[1][1] = name
                                and x[2] = entry[2]
                                and x[3] = entry[3] ) then
            return fail;
          fi;
        fi;
      fi;

      # Omit methods for `FlushCaches'.
      if name = "FlushCaches" then
        return fail;
      fi;

      # Extract a comment if possible.
      if IsString( entry[1][2] ) then
        # Store also the comment for this method installation.
        return [ name, entry[1][ Length( entry[1] ) ],
                 entry[2], entry[3], entry[1][2] ];
      else
        pos:= PositionProperty( entry[1],
                                x -> IsList( x ) and not IsEmpty( x )
                                     and ForAll( x, IsString ) );
        if pos <> fail then
          # Create a comment from the list of strings that describe filters.
          return [ NameFunction( entry[1][1] ),
                   entry[1][ Length( entry[1] ) ],
                   entry[2], entry[3], Concatenation( "for ",
                   JoinStringsWithSeparator( entry[1][ pos ], ", " ) ) ];
        else
          # We know no comment.
          return [ NameFunction( entry[1][1] ),
                   entry[1][ Length( entry[1] ) ],
                   entry[2], entry[3] ];
        fi;
      fi;
      end;

    key_dependent_operation:= IdFunc;

    # List the cases to be dealt with.
    rules:= [
      [ "DeclareGlobalFunction",
        [ "new global functions", new ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "DeclareGlobalVariable",
        [ "new global variables", new ],
        [ "globals that are new only up to case", new_up_to_case ] ],
      [ "BindGlobal",
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
      [ "DeclareInfoClass",
        [ "new info classes", new ] ],
      [ "KeyDependentOperation",
        [ "KeyDependentOperation", key_dependent_operation ] ],
      ];

    # Save the relevant global variables, and replace them.
    GAPInfo.data:= rec( userGVars:= NamesUserGVars(),
                        varsThisPackage:= [],
                        pkgpath:= test,
                        pkgname:= pkgname );

    GAPInfo.data.lowercase_vars:= List( Union( NamesSystemGVars(),
        GAPInfo.data.userGVars ), LowercaseString );

    localBindGlobal:= BindGlobal;

    Perform( rules, function(rule)
      local orig_func, usage_locations;
      orig_func:= ValueGlobal( rule[1] );
      usage_locations:= [];
      GAPInfo.data.( rule[1] ):= [ orig_func, usage_locations ];
      MakeReadWriteGlobal( rule[1] );
      UnbindGlobal( rule[1] );
      localBindGlobal( rule[1], function( arg )
        local infile, path;
        infile:= INPUT_FILENAME();
        path:= GAPInfo.data.pkgpath;
        if Length( path ) <= Length( infile ) and
           infile{ [ 1 .. Length( path ) ] } = path then
          Add( usage_locations,
               [ StructuralCopy( arg ), infile, INPUT_LINENUMBER() ] );
        fi;
        CallFuncList( orig_func, arg );
      end );
    end );

    # Redirect `ReadPackage'.
    GAPInfo.data.ReadPackage:= ReadPackage;
    MakeReadWriteGlobal( "ReadPackage" );
    UnbindGlobal( "ReadPackage" );
    localBindGlobal( "ReadPackage",
        function( arg )
        local pos, pkgname, before, res, after;
        if Length( arg ) = 1 then
          pos:= Position( arg[1], '/' );
          pkgname:= LowercaseString( arg[1]{[ 1 .. pos - 1 ]} );
        elif Length( arg ) = 2 then
          pkgname:= LowercaseString( arg[1] );
        else
          pkgname:= fail;
        fi;
        if pkgname = GAPInfo.data.pkgname then
          before:= NamesUserGVars();
        fi;
        res:= CallFuncList( GAPInfo.data.ReadPackage, arg );
        if pkgname = GAPInfo.data.pkgname then
          after:= NamesUserGVars();
          UniteSet( GAPInfo.data.varsThisPackage,
            Filtered( Difference( after, before ), IsBoundGlobal ) );
        fi;
        return res;
        end );

    # Load the package `pkgname'.
    loaded:= LoadPackage( pkgname );

    # Put the original global variables back.
    for rule in rules do
      MakeReadWriteGlobal( rule[1] );
      UnbindGlobal( rule[1] );
      localBindGlobal( rule[1], GAPInfo.data.( rule[1] )[1] );
    od;
    MakeReadWriteGlobal( "ReadPackage" );
    UnbindGlobal( "ReadPackage" );
    localBindGlobal( "ReadPackage", GAPInfo.data.ReadPackage );

    if not loaded then
      Print( "#E  the package `", pkgname, "' could not be loaded\n" );
      return [];
    fi;

    # Functions are printed together with their argument lists.
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
    docmark:= function( nam )
      if not ( IsBoundGlobal( nam ) and IsDocumentedWord( nam ) ) then
        return "*";
      else
        return "";
      fi;
    end;

    # Prepare the output.
    done:= [];
    result:= [];
    rules:= Filtered( rules, x -> x[1] <> "KeyDependentOperation" );
    for rule in rules do
      for subrule in rule{ [ 2 .. Length( rule ) ] } do
        added:= [];
        for entry in Filtered( List( GAPInfo.data.( rule[1] )[2],
                                     x -> subrule[2]( x ) ),
                               x -> x <> fail ) do
          if Length( entry ) = 5 then
            Add( added, [ [ entry[1], args( entry[2] ),
                            docmark( entry[1] ), entry[5] ],
                          [ entry[3], entry[4] ] ] );
          else
            Add( added, [ [ entry[1], args( entry[2] ),
                            docmark( entry[1] ) ],
                          [ entry[3], entry[4] ] ] );
          fi;
        od;
        if not IsEmpty( added ) then
          prev:= First( result, x -> x[1] = subrule[1] );
          if prev = fail then
            Add( result, [ subrule[1], added ] );
          else
            Append( prev[2], added );
          fi;
          UniteSet( done, List( added, x -> x[1][1] ) );
        fi;
      od;
    od;
    for subresult in result do
      Sort( subresult[2] );
    od;

    # Mention the remaining new globals.
    isrelevant:= function( name )
      local name2, attr;

      # Omit variables that are not bound anymore.
      # (We have collected the new variables file by file, and it may happen
      # that some of them become unbound in the meantime.)
      if not IsBoundGlobal( name ) then
        return false;
      fi;

      # Omit `Set<attr>' and `Has<attr>' type variables.
      if 3 < Length( name ) and name{ [ 1 .. 3 ] } in [ "Has", "Set" ] then
        name2:= name{ [ 4 .. Length( name ) ] };
        if not IsBoundGlobal( name2 ) then
          return true;
        fi;
        attr:= ValueGlobal( name2 );
        if ForAny( ATTRIBUTES, entry -> IsIdenticalObj( attr, entry[3] ) ) then
          return false;
        fi;
      fi;

      # Omit operation and attribute created by `KeyDependentOperation'.
      if 9 < Length( name  ) and name{ [ 1 .. 8 ] } = "Computed"
         and Last(name) = 's'
         and IsBoundGlobal( name{ [ 9 .. Length( name ) - 1 ] } )
         and ForAny( GAPInfo.data.KeyDependentOperation[2],
                     x -> x[1][1] = name{ [ 9 .. Length( name ) - 1 ] } ) then
        return false;
      fi;
      if 3 < Length( name  ) and name{ Length( name ) - [1,0] } = "Op"
         and IsBoundGlobal( name{ [ 1 .. Length( name ) - 2 ] } )
         and ForAny( GAPInfo.data.KeyDependentOperation[2],
                     x -> x[1][1] = name{ [ 1 .. Length( name ) - 2 ] } ) then
        return false;
      fi;

      return true;
    end;

    added:= Filtered( Difference( GAPInfo.data.varsThisPackage, done ),
                      isrelevant );

    # Distinguish write protected variables from others.
    guesssource:= function( nam )
      local val;

      val:= ValueGlobal( nam );
      if IsFunction( val ) then
        return [ FilenameFunc( val ), StartlineFunc( val ) ];
      else
        return [ fail, fail ];
      fi;
    end;

    protected:= Filtered( added, IsReadOnlyGVar );
    if not IsEmpty( protected ) then
      Add( result, [ "other new globals (write protected)",
                     List( SortedList( protected ),
                           nam -> [ [ nam, args( ValueGlobal( nam ) ),
                                      docmark( nam ) ],
                                    guesssource( nam ) ] ) ] );
    fi;
    added:= Difference( added, protected );
    if not IsEmpty( added ) then
      Add( result, [ "other new globals (not write protected)",
                     List( SortedList( added ),
                           nam -> [ [ nam, args( ValueGlobal( nam ) ),
                                      docmark( nam ) ],
                                    guesssource( nam ) ] ) ] );
    fi;

    # Delete the auxiliary component from `GAPInfo'.
    Unbind( GAPInfo.data );

    # Store the data.
    GAPInfo.PackageVariablesInfo.( cache ):= result;
    if version = "" then
      Append( cache, InstalledPackageVersion( pkgname ) );
      GAPInfo.PackageVariablesInfo.( cache ):= result;
    fi;

    return result;
    end );

Unbind( NamesSystemGVars );
Unbind( NamesUserGVars );


#############################################################################
##
#F  ShowPackageVariables( <pkgname>[, <version>][, <arec>] )
##
InstallGlobalFunction( ShowPackageVariables, function( arg )
    local version, arec, pkgname, info, show, documented, undocumented,
          private, result, len, format, entry, first, subentry, str;

    # Get and check the arguments.
    version:= "";
    arec:= rec();
    if   Length( arg ) = 1 and IsString( arg[1] ) then
      pkgname:= LowercaseString( arg[1] );
    elif Length( arg ) = 2 and IsString( arg[1] ) and IsString( arg[2] ) then
      pkgname:= LowercaseString( arg[1] );
      version:= arg[2];
    elif Length( arg ) = 2 and IsString( arg[1] ) and IsRecord( arg[2] ) then
      pkgname:= LowercaseString( arg[1] );
      arec:= arg[2];
    elif Length( arg ) = 3 and IsString( arg[1] ) and IsString( arg[2] )
                           and IsRecord( arg[3] ) then
      pkgname:= LowercaseString( arg[1] );
      version:= arg[2];
      arec:= arg[3];
    else
      Error( "usage: ShowPackageVariables( <pkgname>[, <version>]",
             "[, <arec>] )" );
    fi;

    # Compute the data.
    info:= PackageVariablesInfo( pkgname, version );

    # Evaluate the optional record.
    if IsBound( arec.show ) and IsList( arec.show ) then
      show:= arec.show;
    else
      show:= List( info, entry -> entry[1] );
    fi;
    documented:= not IsBound( arec.showDocumented )
                 or arec.showDocumented <> false;
    undocumented:= not IsBound( arec.showUndocumented )
                   or arec.showUndocumented <> false;
    private:= not IsBound( arec.showPrivate )
              or arec.showPrivate <> false;

    # Render the relevant data.
    result:= "";
    len:= SizeScreen()[1] - 2;
    if IsBoundGlobal( "FormatParagraph" ) then
      format:= ValueGlobal( "FormatParagraph" );
    else
      format:= function( arg ) return Concatenation( arg[1], "\n" ); end;
    fi;
    for entry in info do
      if entry[1] in show then
        first:= true;
        for subentry in entry[2] do
          if ( ( documented and subentry[1][3] = "" ) or
               ( undocumented and subentry[1][3] = "*" ) ) and
             ( private or not '@' in subentry[1][1] ) then
            if first then
              Append( result, entry[1] );
              Append( result, ":\n" );
              first:= false;
            fi;
            Append( result, "  " );
            for str in subentry[1]{ [ 1 .. 3 ] } do
              Append( result, str );
            od;
            Append( result, "\n" );
            if Length( subentry[1] ) = 4 and not IsEmpty( subentry[1][4] ) then
              Append( result,
                      format( subentry[1][4], len, "left", [ "    ", "" ] ) );
            fi;
          fi;
        od;
        if not first then
          Append( result, "\n" );
        fi;
      fi;
    od;

    # Show the relevant data.
    if IsBound( arec.Display ) then
      arec.Display( result );
    else
      Print( result );
    fi;
    end );
