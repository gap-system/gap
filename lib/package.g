#############################################################################
##
#W  package.g                   GAP Library                      Frank Celler
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains support for share packages.
##
Revision.package_g :=
    "@(#)$Id$";

#############################################################################
##
#F  CompareVersionNumbers(<supplied>,<required>)
##
##  compares two version numbers, given as strings. They are split at
##  non-number
##  characters, the resulting integer lists are compared
##  lexicographically. The routine tests, whether <supplied> is at least as
##  large as <required> and returns `true' or `false' accordingly. A version
##  number ending in `dev' is considered to be infinite.
##  See Section~"ext:Version Numbers" of ``Extending GAP'' for details
##  about version numbers.
BindGlobal("CompareVersionNumbers",function(s,r)
local i,j,a,b;
  # special tratment of a ".dev" version
  if Length(s)>4 and s{[Length(s)-2..Length(s)]}="dev" then
    return true;
  elif Length(r)>4 and r{[Length(r)-2..Length(r)]}="dev" then
    return false;
  fi;

  i:=1;
  j:=1;
  while Length(s)>=i or Length(r)>=j do
    if Length(s)=0 then
      return false;
    elif Length(r)=0 then
      return true;
    fi;

    # read the next numbers
    while i<=Length(s) and IsDigitChar(s[i]) do
      i:=i+1;
    od;
    while j<=Length(r) and IsDigitChar(r[j]) do
      j:=j+1;
    od;
    a:=Int(s{[1..i-1]});
    b:=Int(r{[1..j-1]});
    if a<b then
      return false;
    elif a>b then
      return true;
    fi;
    # read the next nonnumbers
    while i<=Length(s) and not IsDigitChar(s[i]) do
      i:=i+1;
    od;
    s:=s{[i..Length(s)]};
    i:=1;
    while j<=Length(r) and not IsDigitChar(r[j]) do
      j:=j+1;
    od;
    r:=r{[j..Length(r)]};
    j:=1;
  od;
  return true;
end);

BindGlobal( "LOADED_PACKAGES", rec() );
BindGlobal( "PACKAGES_VERSIONS", rec() );

# CURRENTLY_TESTED_PACKAGES contains the version numbers of packages
# which are currently tested for availability
CURRENTLY_TESTED_PACKAGES := rec();

#############################################################################
##
#V  AUTOLOAD_PACKAGES
##
##  This list contains the names of packages which may not be autoloaded
##  automatically. This permits the user
##  to disable the automatic loading of certain packages which are properly
##  installed by simply removing package names from `AUTOLOAD_PACKAGES'
##  via a line in their `.gaprc' file.
AUTOLOAD_PACKAGES := [];

IS_IN_AUTOLOAD := false;     # indicates whether we are
                             # in the autoload stage
IS_IN_PACKAGE_TEST := false; # indicates whether package
                             # availability is tested.
IS_IN_PACKAGE_LOAD := false; # indicates whether currently
                             # already a package is being
                             # loaded
AUTOLOAD_LOAD_DOCU := false; # used to permit documentation
                             # loading if desired

#############################################################################
##
#F  TestPackageAvailability( <name>,<version> )
##
##  tests, whether the share package <name> is available for loading in
##  a version that is at least <version>. It returns `true' if the package
##  is already loaded, `fail' if it is not available, and the directory path
##  to the package if it is available, but not yet loaded.  A test function
##  (the third parameter to `DeclarePackage') should therefore test for the
##  result of `TestPackageAvailability' being not equal to `fail'.
BindGlobal( "TestPackageAvailability", function(name,ver)
local init,path,isin;
  
  # Is the package already installed?
  if IsBound(PACKAGES_VERSIONS.(name)) and 
    CompareVersionNumbers(PACKAGES_VERSIONS.(name),ver) 
    and IsBound(LOADED_PACKAGES.(name)) then
      return true;
  fi;
  
  # Is the package already currently tested for availability?
  if IsBound(CURRENTLY_TESTED_PACKAGES.(name)) and 
    CompareVersionNumbers(CURRENTLY_TESTED_PACKAGES.(name),ver) then
      return true; # only to avoid recursion. This response is a
      # conditional `true', provided the other packages will be OK.
  fi;

  # locate the init file
  path := DirectoriesPackageLibrary(name,"");
  if path = fail  then
    Info(InfoWarning,1,"Error, package `", name, "' does not exist" );
    return fail;
  fi;
  init := Filename( path, "init.g" );
  if init = fail  then
    Info(InfoWarning,1,"Package `",name,
         "': cannot locate `init.g', please check the installation" );
    return fail;
  fi;

  # read the `init' file once, ignoring all but `Declare(Auto)Package'
  isin:=IS_IN_PACKAGE_TEST;
  IS_IN_PACKAGE_TEST:=true;
  Read(init);
  IS_IN_PACKAGE_TEST:=isin;

  # on the ``outermost'' level clean the test pool info
  if isin=false then
    CURRENTLY_TESTED_PACKAGES := rec();
  fi;

  if not IsBound(PACKAGES_VERSIONS.(name)) then
    if AUTOLOAD_LOAD_DOCU=true then
      # the package does not claim to be autoloadable.
      AUTOLOAD_LOAD_DOCU:=false; 
      return fail;
    fi;
    # the package requirements were not fulfilled
    Info(InfoWarning,1,"Package ``",name,"'' has unfulfilled requirements");
    return fail;
  fi;

  # Make sure the version number we found is high enough -- AS 20/4/99
  if not CompareVersionNumbers(PACKAGES_VERSIONS.(name),ver) then
      return fail;
  fi;

  # Ah, everything worked. Return the path
  return path;
end );

#############################################################################
##
#F  ReadOrCompletePkg( <name> ) 
##
##  Go to package directory <name> and read read.g or read.co - whichever
##  is appropriate. AS 17/10/98
##
BindGlobal("ReadOrCompletePkg",function( package )
    local   comp,  check, name;

    name := Concatenation("pkg/",package,"/read.g");
    comp := Concatenation("pkg/",package,"/read.co");
    READED_FILES := [];
    check        := CHECK_INSTALL_METHOD;

    # use completion files
    if CHECK_FOR_COMP_FILES  then

        # do not check installation and use cached ranks
        CHECK_INSTALL_METHOD := false;
        RankFilter           := RANK_FILTER_COMPLETION;

        # check for the completion file
        if not READ_GAP_ROOT(comp)  then

            # set filter functions to store
            IS_READ_OR_COMPLETE  := true;
            CHECK_INSTALL_METHOD := check;
            RankFilter           := RANK_FILTER_STORE;
            RANK_FILTER_LIST     := [];

            # read the original file
            InfoRead1( "#I  reading ", name, "\n" );
            if not READ_GAP_ROOT(name)  then
                Error( "cannot read or complete file ", name );
            fi;
            ADD_LIST( LOADED_PACKAGES.(package), 
                      [name, READED_FILES, RANK_FILTER_LIST ] );
						#name is redundant, but we keep it for consistancy 
						#with the lib case. Also admits the possibility 
						#of more than 1 read file per package.

        # file completed
        else
            ADD_LIST( COMPLETED_FILES, name );
            InfoRead1( "#I  completed ", name, "\n" );
        fi;

    else

        # set `RankFilter' to hash the ranks
        IS_READ_OR_COMPLETE := true;
        RankFilter          := RANK_FILTER_STORE;
        RANK_FILTER_LIST    := [];

        # read the file
        if not READ_GAP_ROOT(name)  then
            Error( "cannot read file ", name );
        fi;
        ADD_LIST( LOADED_PACKAGES.(package), 
                  [ name, READED_FILES, RANK_FILTER_LIST ] );    
    fi;

    # reset rank and filter functions
    IS_READ_OR_COMPLETE  := false;
    CHECK_INSTALL_METHOD := check;
    RankFilter           := RANK_FILTER;
    Unbind(RANK_FILTER_LIST);
    Unbind(READED_FILES);
end);

#############################################################################
##
#F  RequirePackage( <name>, [<version>] )
##
##  loads the share package <name>. If the optional version string <version>
##  is given, the package will only be loaded in a version number at least
##  as large as <version>
##  (see~"ext:Version Numbers" in ``Extending GAP'').
##  `RequirePackage' will return `true' if the package has been successfully
##  loaded and will return `fail' if the package could not be loaded. The
##  latter may be the case if the package is not installed, if necessary
##  binaries have not been compiled or if the available version is too small. 
##  If the package <name> has already been loaded in a version number 
##  at least <version>, `RequirePackage' returns `true' without doing
##  anything.
DELAYED_PACKAGE_LOAD := [];
# if package is not autoloading.
BindGlobal( "RequirePackage", function(arg)
local name,ver,init,path,isin, package;

  if IS_IN_PACKAGE_TEST=true then
    # if we are testing the availability of another package, a
    # `RequirePackage' in its `init.g' file will be ignored.
    return true;
  fi;

  name:= LowercaseString( arg[1] );
  if Length(arg)>1 then
    ver:=arg[2];
  else
    ver:="";
  fi;

  # test whether the package is available for requiring
  path:=TestPackageAvailability(name,ver);

  if path=fail then
    return fail; # package not available
  elif path=true and IsBound(LOADED_PACKAGES.(name)) then
    return true; # package already loaded
  fi;

  init := Filename( path, "init.g" );

  isin:=IS_IN_PACKAGE_LOAD;
  IS_IN_PACKAGE_LOAD:=true;

  LOADED_PACKAGES.(name) := path;

  # and finally read it
  Read(init);

  # test whether there is also a `read.g' file?
  init := Filename( path, "read.g" );
  if init<>fail  then
    Add(DELAYED_PACKAGE_LOAD,name);#changed init to name of package
  fi;

  IS_IN_PACKAGE_LOAD:=isin;

  # if this is the ``outermost'' `Require', we finally load all the
  # potentially delayed `read.g' files that contain the actual
  # implementation.
  if isin=false then
    for package in DELAYED_PACKAGE_LOAD do
        ReadOrCompletePkg(package); 
        #AS 17/10/99  This will become ReadOrCompletePkg
    od;
    DELAYED_PACKAGE_LOAD:=[];
  fi;

  return true; #package loaded

end );

#############################################################################
##
#F  DeclarePackage( <name>, <version>, <tester> )
#F  DeclareAutoPackage( <name>, <version>, <tester> )
##
##  This function may only occur within the `init.g' file of the share
##  package <name>. It prepares the installation of the package <name>,
##  which will be installed in version <version>. The third argument
##  <tester> is a function which tests for necessary conditions for the
##  package to be loadable, like the availability of other
##  packages (using `TestPackageAvailability', see
##  "TestPackageAvailability") or -- if necessary -- the existence of
##  compiled binaries. It should return `true' only if all conditions
##  are fulfilled (and `false' or `fail' otherwise). If it does not return
##  `true', the package will not be loaded,
##  and the documentation will not be available.
##  The second version `DeclareAutoPackage' declares the package and enables
##  automatic loading
##  when {\GAP} is started. (Because potentially all installed packages are
##  automatically loaded, the <tester> function should take little time.)
BindGlobal( "DeclareAutoPackage", function( name, version,tester )

  CURRENTLY_TESTED_PACKAGES.(name):=version;
  # test availability
  if IS_IN_PACKAGE_TEST=false then
    # we have tested the availability already before
    tester:=true;
  elif tester<>true then
    # test availability
    tester:=tester();
  fi;
  if tester then
    PACKAGES_VERSIONS.(name):=version;
  fi;
end );

BindGlobal( "DeclarePackage", function( name, version,tester )
  if IS_IN_AUTOLOAD=false then
    DeclareAutoPackage( name, version,tester );
    AUTOLOAD_LOAD_DOCU:=false;
  else
    # the package is not intended for autoloading. So at least we give the
    # documentation a chance
    AUTOLOAD_LOAD_DOCU:=true;
  fi;
end );

#############################################################################
##
#F  DeclarePackageDocumentation( <pkg>, <doc> )
#F  DeclarePackageAutoDocumentation( <pkg>, <doc> )
##
##  This function indicates that the documentation of the share package
##  <pkg> can be found in its <doc> subdirectory.
##  The second version will enable that the documentation is loaded
##  automatically when {\GAP} starts, even if the package itself will not be
##  loaded.
##  Both functions may only occur within the `init.g' file of a share
##  package.
BindGlobal( "DeclarePackageAutoDocumentation", function( pkg, doc )
local help,p;
  # on the second (true) read 
  if IS_IN_PACKAGE_TEST=false 
     or AUTOLOAD_LOAD_DOCU=true
  #install the documentation
   then
    # test for the existence of a `manual.six' file
    if Filename(DirectoriesPackageLibrary(pkg,doc),"manual.six")=fail then
      # if we are not autoloading print a warning that the documentation
      # is not available.
      Info(InfoWarning,1,"Package `",pkg,
	  "': cannot load documentation, no manual index file `",doc,
	  "/manual.six'" );
    else
      # declare the location
      help:=[ pkg, Concatenation( "pkg/", pkg, "/", doc ),
	  Concatenation( "Share Package `", pkg, "'" ) ];
      if AUTOLOAD_LOAD_DOCU then
	# indicate that the package still needs requiring
	help[1]:=Concatenation(pkg," (not loaded)");
	Append( HELP_BOOKS,help);
      else
	p:=Position(HELP_BOOKS,help[2]);
	if p=fail then
	  # was not yet loaded, append
	  Append( HELP_BOOKS,help);
	else
	  # overwrite the `not loaded' message
	  HELP_BOOKS[p-1]:=pkg;
        fi;
      fi;
    fi;
  fi;

end );

BindGlobal( "DeclarePackageDocumentation", function( pkg, doc )
  if IS_IN_AUTOLOAD=false then
    DeclarePackageAutoDocumentation( pkg, doc );
  fi;
end );

# now come some technical functions to support autoloading

#############################################################################
##
#F  AutoloadablePackagesList()
##
##  this function returns a list of all existing packages which are
##  permissible for automatic loading.
##  As there is no kernel functionality yet for getting a list of
##  subdirectories, we use the file `pkg/ALLPKG'.
BindGlobal("AutoloadablePackagesList",function()
    local pkgdir,f,pkg,name,paks,nopaks;
    paks:=[];
    
    if DO_AUTOLOAD_PACKAGES = false then
        return paks;
    fi;
    
    pkgdir:=DirectoriesLibrary("pkg");
    if pkgdir=fail then
        return paks;
    fi;

    nopaks:=[];
    # note the names of packages which are deliberately set in `pkg/NOAUTO'
    f:=Filename(pkgdir,"NOAUTO");
    if f<>fail then
        f:=InputTextFile(f);
        while not IsEndOfStream(f) do
            name:=ReadLine(f);
            if name<>fail then
                #remove a trailing \n
                name:=Filtered(name,i->i<>'\n');
                AddSet(nopaks,name);
            fi;
        od;
        CloseStream(f);
    fi;

    # get the lines from `ALLPKG' and test whther they are subdirectories
    # which contain an `init' file.
    f:=Filename(pkgdir,"ALLPKG");
    if f<>fail then
        f:=InputTextFile(f);
        while not IsEndOfStream(f) do
            name:=ReadLine(f);
            if name<>fail then
	        #remove a trailing \n
                name:=Filtered(name,i->i<>'\n');
                if not name in nopaks then
                    pkg := DirectoriesPackageLibrary(name,"");
                    if pkg<>fail then
                        # test for existence if `init.g' file
                        pkg:=Filename(pkg,"init.g");
                        if pkg<>fail then
                            AddSet(paks,name);
                        fi;
                    fi;
                fi;
            fi;
        od;
        CloseStream(f);
    fi;
    return paks;

end);

#############################################################################
##
#F  ReadPkg(<pkg>,<file>)
##
##  reads the file <file> of the share package <pkg>. <file> is given as a
##  relative path to the directory of <pkg>.
BindGlobal( "ReadPkg", function( arg )
# This must be a wrapper to be skipped when `init.g' is read the first
# time.
local path;
  if IS_IN_PACKAGE_TEST=false and
    AUTOLOAD_LOAD_DOCU=false then
    if Length(arg)=1 then
      path:=arg[1];
    else
      path:=Concatenation(arg[1],"/",arg[2]);
    fi;
    DoReadPkg(path);
  fi;
end);


#############################################################################
##
#F  RereadPkg( <pkg>, <file> )
##
##  rereads the file <file> of the share package <pkg>. <file> is given as a
##  relative path to the directory of <pkg>.
BindGlobal( "RereadPkg", function( arg )
    if IS_IN_PACKAGE_TEST = false and AUTOLOAD_LOAD_DOCU = false then
      if Length( arg ) = 1 then
        DoRereadPkg( arg[1] );
      else
        DoRereadPkg( Concatenation( arg[1], "/", arg[2] ) );
      fi;
    fi;
end );


#############################################################################
##
#M  CreateCompletionFilesPkg( <name> )  . . create "pkg/<name>/read.co" files
##
## AS: minor modification of  CreateCompletionFiles

BindGlobal( "CreateCompletionFilesPkg", function( name )
local   path,  input,   com,  read,  j,  crc, filesandfilts;
  if not IsBound(LOADED_PACKAGES.(name))  then
    Error("Can't create read.co for package ", name, " - package not loaded.");
    return false;
  fi;
  if not IsBound(LOADED_PACKAGES.(name)[2]) then
    Error("Completion file was loaded. Delete read.co and try again.");
    return false;
  fi;

  # get the path to the output
  path := LOADED_PACKAGES.(name)[1];
  input := DirectoriesLibrary(""); #The gap home where packages live

  #filesandfilts[1] = "pkg/<name>/read.g"
  #filesandfilts[2]= The files which read.g reads with ReadPkg.
  #filesandfilts[3]= For each file in filesandfilts[2] a list of filters
  filesandfilts := LOADED_PACKAGES.(name)[2];



  # com := the completion filename
  com := Filename( path, "read.co");
  if com = fail  then
		  Error( "cannot create output file" );
  fi;
  Print( "#I  converting \"","read.g", "\" to \"", com, "\"\n" );

  # now find the input file
  read := List( [1 .. Length(filesandfilts[2]) ], x 
	    -> [ filesandfilts[2][x], Filename( input, filesandfilts[2][x] ), filesandfilts[3][x] ] );
  if ForAny( read, x -> x[2] = fail )  then
		  Error( "cannot locate all input files" );
  fi;

  # create the completion files
  PRINT_TO( com, "#I  file=\"", filesandfilts[1], "\"\n\n" );
  for j  in read  do

    # create a crc value
    Print( "#I    parsing \"", j[1], "\"\n" );
    crc := GAP_CRC(j[2]);

    # create ranking list
    APPEND_TO( com, "#F  file=\"", j[1], "\" crc=", crc, "\n" );
    APPEND_TO( com, "RANK_FILTER_LIST  := ", j[3], ";\n",
		  "RANK_FILTER_COUNT := 1;\n\n" );

    # create `COM_FILE' header and `if' start
    APPEND_TO( com, "#C  load module, file, or complete\n" );
    APPEND_TO( com, 
      "COM_RESULT := COM_FILE( \"", j[1], "\", ", crc, " );\n",
      "if COM_RESULT = fail  then\n",
      "Error(\"cannot locate file \\\"", j[1], "\\\"\");\n",
      "elif COM_RESULT = 1  then\n",
      ";\n",
      "elif COM_RESULT = 2  then\n",
      ";\n",
      "elif COM_RESULT = 4  then\n",
      "READ_CHANGED_GAP_ROOT(\"",j[1],"\");\n",
      "elif COM_RESULT = 3  then\n"
      );

    # create completion
    MAKE_INIT( com, j[2] );

    APPEND_TO( com,
    "else\n",
    "Error(\"unknown result code \", COM_RESULT );\n",
    "fi;\n\n",
    "#U  unbind temporary variables\n",
    "Unbind(RANK_FILTER_LIST);\n",
    "Unbind(RANK_FILTER_COUNT);\n",
    "Unbind(COM_RESULT);\n",
    "#E  file=\"", j[1], "\"\n\n"
    );

  od;

end );

#############################################################################
##
#E  package.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
