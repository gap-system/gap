#############################################################################
##
#W  init.g                      GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file initializes GAP.
##
Revision.init_g :=
    "@(#)$Id$";

#############################################################################
##
#F  OnBreak( )  . . . . . . . . . function to call at entry to the break loop
##
##
OnBreak := Where;

#############################################################################
##
#F  OnBreakMessage( ) . . . . . . function to call at entry to the break loop
##
##  called after execution of `OnBreak' when an error condition is caused  by
##  an execution of `Error', to print what a user can do in order to exit the
##  break loop.
##
OnBreakMessage := function()
  Print("you can 'quit;' to quit to outer loop, or\n",
        "you can 'return;' to continue\n");
end;

#############################################################################
##
#F  OnQuit( ) . . . . . . . . . . function to call on quitting the break loop
##
##  called when a user elects to `quit;' a break loop entered  via  execution
##  of `Error'. Here we define it to do nothing, in  case,  we  encounter  an
##  `Error' when {\GAP} is starting up (i.e. reading this file). `OnQuit'  is
##  later  redefined  to  do  a  variant  of  `ResetOptionsStack'  to  ensure
##  `OptionsStack' is empty after a user quits an `Error'-induced break loop.
##  Currently, `OnQuit( )' is not advertised, since  exception  handling  may
##  make it obsolete.
##
OnQuit := function() end;

#############################################################################
##
#F  Ignore( <arg> ) . . . . . . . . . . . . ignore but evaluate the arguments
##
#T  1996/08/07 M.Schoenert 'Ignore' should be in the kernel
#T  1996/09/08 S.Linton    Do we need it at all?
##
Ignore := function ( arg )  end;


#############################################################################
##
##  Define some global variables
##
SetFilterObj := "2b defined";
infinity := "2b defined";
last:="2b defined";


#############################################################################
##
#F  ReplacedString( <string>, <old>, <new> )
##
##  This cannot be inside "kernel.g" because it is needed to read "kernel.g".
##
ReplacedString := function ( arg )
    local str, substr, lss, subs, all, p, s, pp;
    str := arg[1];
    substr := arg[2];
    lss := LEN_LIST( substr );
    subs := arg[3];
    if LEN_LIST( arg ) > 3  then
        all := arg[4] = "all";
    else
        all := true;
    fi;
    p := POSITION_SUBSTRING( str, substr, 0 );
    if p = fail  then
        return str;
    fi;
    s := str{[  ]};
    pp := 0;
    while p <> fail  do
        APPEND_LIST_INTR( s, str{[ pp+1 .. p - 1 ]} );
        APPEND_LIST_INTR( s, subs );
        pp := p + lss - 1;
        if all  then
            p := POSITION_SUBSTRING( str, substr, pp );
        else
            p := fail;
        fi;
        if p = fail  then
            APPEND_LIST_INTR( s, str{[pp+1..LEN_LIST(str)]} );
        fi;
    od;
    return s;
end;


#############################################################################
##
#V  InfoRead? . . . . . . . . . . . . . . . . . . . . print what file is read
##
if DEBUG_LOADING           then InfoRead1 := Print;   fi;
if not IsBound(InfoRead1)  then InfoRead1 := Ignore;  fi;
if not IsBound(InfoRead2)  then InfoRead2 := Ignore;  fi;


#############################################################################
##
#V  CHECK_INSTALL_METHOD  . . . . . .  check requirements in `INSTALL_METHOD'
##
CHECK_INSTALL_METHOD := true;


#############################################################################
##

#F  ReadGapRoot( <name> ) . . . . . . . . . .  read file from GAP's root area
##
ReadGapRoot := function( name )
    if not READ_GAP_ROOT(name)  then
        Error( "file \"", name, "\" must exist and be readable" );
    fi;
end;


#############################################################################
##
##  We will need this stuff to be able to bind global variables. Thus it
##  must be done first.
##
ReadGapRoot( "lib/kernel.g" );
ReadGapRoot( "lib/global.g" );


#############################################################################
##
##  Read the dependency information.
##
ReadGapRoot( "lib/system.g" );


IS_READ_OR_COMPLETE := false;

READED_FILES := [];

RANK_FILTER_LIST         := [];
RANK_FILTER_LIST_CURRENT := fail;
RANK_FILTER_COUNT        := fail;

RANK_FILTER_COMPLETION   := Error;	# defined in "filter.g"
RANK_FILTER_STORE        := Error;	# defined in "filter.g"
RANK_FILTER              := Error;	# defined in "filter.g"
RankFilter               := Error;      # defined in "filter.g"


#############################################################################
##
#F  ReadOrComplete( <name> )  . . . . . . . . . . . . read file or completion
##
COMPLETABLE_FILES := [];
COMPLETED_FILES   := [];

ReadOrComplete := function( name )
    local check;

    READED_FILES := [];
    check        := CHECK_INSTALL_METHOD;

    # use completion files
    if not GAPInfo.CommandLineOptions.N then

        # do not check installation and use cached ranks
        CHECK_INSTALL_METHOD := false;
        RankFilter           := RANK_FILTER_COMPLETION;

        # check for the completion file
        if not READ_GAP_ROOT( ReplacedString( name, ".g", ".co" ) ) then

            # set filter functions to store
            IS_READ_OR_COMPLETE  := true;
            CHECK_INSTALL_METHOD := check;
            RankFilter           := RANK_FILTER_STORE;
            RANK_FILTER_LIST     := [];

            # read the original file
            InfoRead1( "#I  reading ", name, "\n" );
            if not READ_GAP_ROOT( name ) then
                Error( "cannot read or complete file ", name );
            fi;
            ADD_LIST( COMPLETABLE_FILES, [ name, READED_FILES, RANK_FILTER_LIST ] );

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
        if not READ_GAP_ROOT( name ) then
            Error( "cannot read file ", name );
        fi;
        ADD_LIST( COMPLETABLE_FILES, [ name, READED_FILES, RANK_FILTER_LIST ] );
    fi;

    # reset rank and filter functions
    IS_READ_OR_COMPLETE  := false;
    CHECK_INSTALL_METHOD := check;
    RankFilter           := RANK_FILTER;
    Unbind(RANK_FILTER_LIST);
    Unbind(READED_FILES);
end;


#############################################################################
##
#F  READ_CHANGED_GAP_ROOT( <name> ) . . . . . .  completion file is out-dated
##
READ_CHANGED_GAP_ROOT := function( name )
    local   rankFilter;

    rankFilter := RankFilter;
    RankFilter := RANK_FILTER;
    Print( "#W  inconsistent completion for \"", name, "\"\n" );
    if not READ_GAP_ROOT(name)  then
        Error( "cannot read file ", name );
    fi;
    RankFilter := rankFilter;
end;


#############################################################################
##
##  Read architecture dependent data and other globals, such as version
##  information, 
##
GAPInfo.CompareKernelVersions := function()
    local nondigits, digits, i, char, have, need, haveint, needint;

    if GAPInfo.KernelVersion <> GAPInfo.NeedKernelVersion then
      Print( "\n\n",
        "You are running a GAP kernel which does not fit with the library.\n",
        "Probably you forgot to apply the kernel part or the library part\n",
        "of a bugfix?\n\n" );

      # Get the number parts of the two version numbers.
      # (Version numbers are defined in "ext:Version Numbers".)
      nondigits:= [];
      digits:= "0123456789";
      for i in [ 0 .. 255 ] do
        char:= CHAR_INT( i );
        if not char in digits then
          ADD_LIST_DEFAULT( nondigits, char );
        fi;
      od;
      have:= SplitStringInternal( GAPInfo.KernelVersion, nondigits, "" );
      need:= SplitStringInternal( GAPInfo.NeedKernelVersion, nondigits, "" );

      # Translate them to integers.
      # (When this function is called during startup, the function
      # `IntHexString' is available;
      # it has the right monotony behaviour for the comparisons.
      haveint:= [];
      needint:= [];
      for i in [ 1 .. 3 ] do
        haveint[i]:= IntHexString( have[i] );
        needint[i]:= IntHexString( need[i] );
      od;

      if haveint > needint then
        # kernel newer
        Print( "You only installed a new kernel.\n",
               "You must also install the most recent library bugfix,\n",
               "this is fix", have[1], "r", have[2], "n", have[3],
               ".zoo (or .zip) or newer.\n\n" );
      else
        # kernel older
        Print( "If you are using Windows, make sure you installed the file\n",
               "wbin", need[1], "r", need[2], "n", need[3],
               ".zoo (or .zip),\n",
               "Macintosh users make sure the file\n",
               "bin", need[1], "r", need[2], "n", need[3],
               "-PPC.sit (or -68k.sit) is installed,\n",
               "Unix users please recompile.\n\n" );
      fi;
      Error( "Update to correct kernel version!\n\n" );
    fi;
end;

GAPInfo.CompareKernelVersions();


#############################################################################
##
## print the banner (but not on the Macintosh version)
##
if not ( GAPInfo.CommandLineOptions.q or GAPInfo.CommandLineOptions.b ) then
  if not ARCH_IS_MAC() then
    Print( GAPInfo.BannerString,
      "   Loading the library. Please be patient, this may take a while.\n");
  else
    Print("Loading the library. Please be patient, this may take a while.\n\n");
  fi;
fi;

#############################################################################
##
#F  ReadAndCheckFunc( <path>[,<libname>] )
##
##  `ReadAndCheckFunc' creates a function that reads in a file named
##  `<name>.<ext>'.
##  The file must define `Revision.<name>_<ext>'.
##  If a second argument <libname> is given, {\GAP} return `true' or `false'
##  according to the read status, otherwise an error is signalled if the file
##  cannot be read.
##  This can be used for partial reading of the library.
##
BIND_GLOBAL("ReadAndCheckFunc",function( arg )
  local  path,  prefix;

    path := IMMUTABLE_COPY_OBJ(arg[1]);

    if LEN_LIST(arg) = 1  then
        prefix := IMMUTABLE_COPY_OBJ("");
    else
        prefix := IMMUTABLE_COPY_OBJ(arg[2]);
    fi;

    return function( arg )
        local  name,  ext,  libname, error, rflc, rfc;

	error:=false;
	name:=arg[1];
        # create a filename from <path> and <name>
        libname := SHALLOW_COPY_OBJ(path);
        APPEND_LIST_INTR( libname, "/" );
        APPEND_LIST_INTR( libname, name );

        # we are completing, store the filename and filter ranks
        if IS_READ_OR_COMPLETE  then
            ADD_LIST( READED_FILES, libname );
            if IsBound(RANK_FILTER_LIST_CURRENT) then
                rflc := RANK_FILTER_LIST_CURRENT;
            fi;
            if IsBound(RANK_FILTER_COUNT) then
                rfc := RANK_FILTER_COUNT;
            fi;
            RANK_FILTER_LIST_CURRENT := [];
            RANK_FILTER_COUNT := 0;
            ADD_LIST( RANK_FILTER_LIST, RANK_FILTER_LIST_CURRENT );
            error:=not READ_GAP_ROOT(libname);
            Unbind(RANK_FILTER_LIST_CURRENT);
            if IsBound(rflc) then
                RANK_FILTER_LIST_CURRENT := rflc;
            fi;
            Unbind(RANK_FILTER_COUNT);
            if IsBound(rfc) then
                RANK_FILTER_COUNT := rfc;
            fi;
        else
            error:=not READ_GAP_ROOT(libname);
        fi;

	if error then
	  if LEN_LIST( arg )=1 then
	    Error( "the library file '", name, "' must exist and ",
		   "be readable");
	  else
# we don't print a warning here but instead list the components at the end
#	    Print("#W  The library file '",name,"' was not available\n",
#	          "#W  The library of ",arg[2]," is not installed!\n");
	    return false;
	  fi;
	elif path<>"pkg" then
	  # check the revision entry
          ext := SHALLOW_COPY_OBJ(prefix);
	  APPEND_LIST_INTR(ext,ReplacedString( name, ".", "_" ));
	  if not IsBound(Revision.(ext))  then
	      Print( "#W  revision entry missing in \"", name, "\"\n" );
	  fi;
        fi;

      if LEN_LIST(arg)>1 then
	return true;
      fi;

    end;
end);

#############################################################################
##
#F  ReadLib( <name> ) . . . . . . . . . . . . . . . . . . . . . library files
#F  ReadGrp( <name> ) . . . . . . . . . . . . . . . . . . group library files
#F  ReadSmall( <name> ) . . . . . . . . . . . . .  small groups library files
#F  ReadTrans( <name> ) . . . . . . . .  transitive perm groups library files
#F  ReadPrim( <name> )  . . . . . . . . . primitive perm groups library files
##
BIND_GLOBAL("ReadLib",ReadAndCheckFunc("lib"));
BIND_GLOBAL("ReadGrp",ReadAndCheckFunc("grp"));
BIND_GLOBAL("ReadSmall",ReadAndCheckFunc("small"));
BIND_GLOBAL("ReadTrans",ReadAndCheckFunc("trans"));
BIND_GLOBAL("ReadPrim",ReadAndCheckFunc("prim"));


#############################################################################
##
##  Define functions which may not be available to avoid syntax errors
##
NONAVAILABLE_FUNC:=function(arg)
local s;
  if LENGTH(arg)=0 then
    return function(arg)
	    Error("this function is not available");
	  end;
  else
    s:=arg[1];
    return function(arg)
	    Error("the ",s," is required but not installed");
	  end;
  fi;
end;

# these functions will be overwritten if loaded
IdGroup:=NONAVAILABLE_FUNC("Small Groups identification");
SmallGroup:=NONAVAILABLE_FUNC("Small Groups library");
NumberSmallGroups:=NONAVAILABLE_FUNC("Small Groups library");
AllGroups:=NONAVAILABLE_FUNC("Small Groups library");
OneGroup:=NONAVAILABLE_FUNC();
IdsOfAllGroups:=NONAVAILABLE_FUNC();
Gap3CatalogueIdGroup:=NONAVAILABLE_FUNC();
IdStandardPresented512Group:=NONAVAILABLE_FUNC();
PrimitiveGroup:=NONAVAILABLE_FUNC("Primitive Groups library");

#############################################################################
##
##  Initialize functions for the source of small group lib and id library
##
SMALL_AVAILABLE := x -> fail;
ID_AVAILABLE := x -> fail;

#############################################################################
##
#V  PRIM_AVAILABLE   variables for data libraries. Will be set during loading
#V  TRANS_AVAILABLE
PRIM_AVAILABLE:=false;
TRANS_AVAILABLE:=false;

#############################################################################
##
#F  DeclareComponent(<componentname>,<versionstring>)
##
GAPInfo.LoadedComponents:= rec();
BIND_GLOBAL("DeclareComponent",function(name,version)
  GAPInfo.LoadedComponents.( name ):= version;
end);

#############################################################################
##
#X  read in the files
##

# inner functions, needed in the kernel
ReadGapRoot( "lib/read1.g" );
ExportToKernelFinished();

ReadOrComplete( "lib/read2.g" );
ReadOrComplete( "lib/read3.g" );

#############################################################################
##
#F  NamesGVars()  . . . . . . . . . . . list of names of all global variables
##
##  This function returns an immutable (see~"Mutability and Copyability")
##  sorted (see~"Sorted Lists and Sets") list of all the global
##  variable names known to the system.  This includes names of variables
##  which were bound but have now been unbound and some other names which
##  have never been bound but have become known to the system by various
##  routes.
##
##  We need this BEFORE we read profile.g
##
BindGlobal( "NamesGVars", function()
    local names;
    names:= Set( IDENTS_GVAR() );
    MakeImmutable( names );
    return names;
end );



# help system, profiling
ReadOrComplete( "lib/read4.g" );
#  moved here from read4.g, because completion doesn't work with if-statements
#  around function definitions!
ReadLib( "helpview.gi"  );

#T  1996/09/01 M.Schoenert this helps performance
IMPLICATIONS:=IMPLICATIONS{[Length(IMPLICATIONS),Length(IMPLICATIONS)-1..1]};
# allow type determination of IMPLICATIONS without using it
TypeObj(IMPLICATIONS[1]);
HIDDEN_IMPS:=HIDDEN_IMPS{[Length(HIDDEN_IMPS),Length(HIDDEN_IMPS)-1..1]};

# we cannot complete the following command because printing may mess up the
# backslash-masked characters!
BIND_GLOBAL("VIEW_STRING_SPECIAL_CHARACTERS_OLD",
  # The first list is sorted and contains special characters. The second list
  # contains characters that should instead be printed after a `\'.
  Immutable([ "\c\b\n\r\"\\", "cbnr\"\\" ]));
BIND_GLOBAL("SPECIAL_CHARS_VIEW_STRING",
[ List(Concatenation([0..31],[34,92],[127..159]), CHAR_INT), [
"\\000", "\\>", "\\<", "\\c", "\\004", "\\005", "\\006", "\\007", "\\b", "\\t",
"\\n", "\\013", "\\014", "\\r", "\\016", "\\017", "\\020", "\\021", "\\022",
"\\023", "\\024", "\\025", "\\026", "\\027", "\\030", "\\031", "\\032", "\\033",
"\\034", "\\035", "\\036", "\\037", "\\\"", "\\\\", "\\177", "\\200", "\\201",
"\\202", "\\203", "\\204", "\\205", "\\206", "\\207", "\\210", "\\211",
"\\212", "\\213", "\\214", "\\215", "\\216", "\\217", "\\220", "\\221",
"\\222", "\\223", "\\224", "\\225", "\\226", "\\227", "\\230", "\\231",
"\\232", "\\233", "\\234", "\\235", "\\236", "\\237"]]);

ReadOrComplete( "lib/read5.g" );

ReadOrComplete( "lib/read6.g" );

# character theory stuff
ReadOrComplete( "lib/read7.g" );

# overloaded operations and compiler interface
ReadOrComplete( "lib/read8.g" );
ReadLib( "colorprompt.g"  );


#############################################################################
##
##  Load data libraries
##  The data libraries which may be absent cannot be completed, therefore
##  they must be read in here!

#############################################################################
##
#X  Read library of groups of small order
#X  Read identification routine
##
ReadSmall( "readsml.g","small groups" );

#############################################################################
##
#X  Read transitive groups library
##
TRANS_AVAILABLE:=ReadTrans( "trans.gd","transitive groups" );
TRANS_AVAILABLE:= TRANS_AVAILABLE and ReadTrans( "trans.grp",
                                        "transitive groups" );
TRANS_AVAILABLE:= TRANS_AVAILABLE and ReadTrans( "trans.gi",
                                        "transitive groups" );

if TRANS_AVAILABLE then
  ReadLib("galois.gd"); # the Galois group identification relies on the list
                        # of transitive groups
  ReadLib("galois.gi");
fi;

#############################################################################
##
#X  Read primitive groups library
##
PRIM_AVAILABLE:=ReadPrim( "primitiv.gd","primitive groups" );
PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "irredsol.gd","irreducible solvable groups" );
PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "primitiv.grp",
                                     "primitive groups" );
PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "primitiv.gi",
                                     "primitive groups" );

PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "irredsol.grp","irreducible solvable groups" );
PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "irredsol.gi","irreducible solvable groups" );
PRIM_AVAILABLE:=PRIM_AVAILABLE and ReadPrim( "cohorts.grp","irreducible solvable groups" );

#############################################################################
##
##  check whether version of loaded workspace coincides with
##  version of GAP library
##
Add( POST_RESTORE_FUNCS, function()
    local wsp_version, name, iw;

    wsp_version := GAPInfo;
    RereadLib( "system.g" );
    if GAPInfo.Version <> wsp_version.Version then
      Info( InfoWarning, 1,
            "The loaded workspace was created with a version of GAP (", 
            wsp_version.Version, ")" );
      Info( InfoWarning, 1,
            "which is different from the one presently installed (",
            GAPInfo.Version, ")." );
      Info( InfoWarning, 1,
            "This may lead to wrong results or further errors." );
    fi;
    for name in [ "PackagesLoaded", "PackagesInfo",
        "PackagesInfoAutoload", "PackagesInfoAutoloadDocumentation",
        "PackagesInfoRefuseLoad", "PackagesInfoInitialized",
        "PackagesNames", "PackagesRestrictions",
        "PackageInfoCurrent", "LoadedComponents",
        "CompareKernelVersions", "SystemInformation" ] do
      if IsBound( wsp_version.( name ) ) then
        GAPInfo.( name ) := wsp_version.( name );
      fi;
      GAPInfo.CommandLineOptionsRestore := 
                                     ShallowCopy(GAPInfo.CommandLineOptions);
      for name in NamesOfComponents(SY_RESTORE_OPTIONS) do
        GAPInfo.CommandLineOptionsRestore.(name) := SY_RESTORE_OPTIONS.(name);
      od;
  od;
  #
  # Workaround for warning message from reread of obsolete.g
  # SL
  #
  iw := InfoLevel(InfoWarning);
  SetInfoLevel(InfoWarning,0);
  RereadLib( "obsolete.g" );
  SetInfoLevel(InfoWarning,iw);
#T Remove this as soon as the globals corresponding to command line options
#T have disappeared and are not getting unbound in `system.g'.
    end );
Add(POST_RESTORE_FUNCS, function() 
    local A;
      # recheck in case user has given additional directories
      A:= GAPInfo.CommandLineOptionsRestore.A;
      if A = false or ( IsList( A ) and ( Length( A ) mod 2 = 0 ) ) then
#T This is just a hack, GAPInfo.CommandLineOptionsRestore should be
#T translated in the same way as GAPInfo.CommandLineOptions.
        GAPInfo.PackagesInfoInitialized := false;
        InitializePackagesInfoRecords(false);
      fi;
end);

#############################################################################
##
##  Display version, loaded components and packages
##
GAPInfo.SystemInformation := function( basic, extended )
    local linelen, PL, comma, name, info, N;

    linelen:= SizeScreen()[1] - 2;
    if basic then
    Print( "GAP4, Version: ", GAPInfo.Version, " of ", GAPInfo.Date, ", ",
           GAPInfo.Architecture, "\n" );
      if extended then

      # For each loaded component, print name and version number.
      if GAPInfo.LoadedComponents <> rec() then
        Print("Components:  ");
        PL:= 13;
        comma:=false;
        for name in RecNames( GAPInfo.LoadedComponents ) do
          N:= Concatenation( name, " ", GAPInfo.LoadedComponents.( name ) );
          if comma then
            Print(", ");
            PL:= PL + 2;
          fi;
          if PL + Length( N ) > linelen then
            Print("\n             ");
            PL:=13;
          fi;
          Print( N, "\c" );
          PL:=PL+Length( N );
          comma:= true;
        od;
        if PL + 10 > linelen then
          Print("\n             ");
        fi;
        Print("  loaded.\n");
      fi;

      # For each loaded package, print name and version number.
      if GAPInfo.PackagesLoaded <> rec() then
        Print( "Packages:    " );
        PL:= 13;
        comma:= false;
        for name in RecNames( GAPInfo.PackagesLoaded ) do
          info:= GAPInfo.PackagesLoaded.( name );
          N:= Concatenation( info[3], " ", info[2] );
          if comma then
            Print(", ");
            PL:= PL + 2;
          fi;
          if PL + Length( N ) > linelen then
            Print("\n             ");
            PL:= 13;
          fi;
          Print( N, "\c" );
          PL:=PL+Length(N);
          comma:= true;
        od;
        if PL + 10 > linelen then
          Print("\n             ");
        fi;
        Print("  loaded.\n");
      fi;

    fi;
  fi;
end;
Add( POST_RESTORE_FUNCS, function()
     GAPInfo.SystemInformation( not GAPInfo.CommandLineOptions.q,
                                not GAPInfo.CommandLineOptions.b );
     end );


#############################################################################
##
##  Deal with compatibility mode via command line option `-O'.
##
if false = fail then ReadLib( "compat3d.g" ); fi;


#############################################################################
##
##  Determine which packages are installed as autoloadable.
##  (This can be modified in the user's `.gaprc' file.)
##
InitializePackagesInfoRecords( GAPInfo.CommandLineOptions.A );
AUTOLOAD_PACKAGES:= GAPInfo.PackagesNames;
#T Remove this as soon as it is no longer needed.
#T (Note that we cannot put the assignment into `lib/obsolete.g'
#T because both autoloading and reading `lib/obsolete.g' are controlled by
#T the `.gaprc' file.)


#############################################################################
##
##  ParGAP/MPI slave hook
##
##  A ParGAP slave redefines this as a function if the {\GAP} package ParGAP
##  is loaded. It is called just once at  the  end  of  GAP's  initialisation
##  process i.e. at the end of this file.
##
PAR_GAP_SLAVE_START := fail;

#############################################################################
##
##  Read the .gaprc file
##
READ( GAPInfo.gaprc );


#############################################################################
##
#X  files installing compatibility with deprecated, obsolescent or
##  obsolete GAP4 behaviour;
##  *not* to be read if `GAPInfo.ReadObsolete' has the value `false'
##  (this value can be set in the `.gaprc' file)
##
if ISB_GVAR( "GAP_OBSOLESCENT" ) then
#T for compatibility with GAP 4.3
  GAPInfo.ReadObsolete:= GAP_OBSOLESCENT;
  Print( "Please use `GAPInfo.ReadObsolete' instead of `GAP_OBSOLESCENT'\n",
         "in your `.gaprc' file\n" );
fi;
if GAPInfo.ReadObsolete <> false then
  RereadLib( "obsolete.g" );
fi;


#############################################################################
##
##  Autoload packages (suppressing banners)
##
if not GAPInfo.CommandLineOptions.A then
BANNER_ORIG:= BANNER;
#T remove this as soon as `BANNER' is not used anymore
MakeReadWriteGlobal("BANNER");
UnbindGlobal("BANNER");
BANNER:= false;
  AutoloadPackages();
BANNER:= BANNER_ORIG;
MakeReadOnlyGlobal("BANNER");
Unbind( BANNER_ORIG );
fi;


#############################################################################
##
##  Display version, loaded components and packages
##
GAPInfo.SystemInformation( not GAPInfo.CommandLineOptions.q,
                           not GAPInfo.CommandLineOptions.b );


#############################################################################
##
##  Finally, deal with the lists of global variables.
##  This must be done at the end of this file,
##  since the variables defined in packages are regarded as system variables.
##  (But also the variables defined in the file `GAPInfo.gaprc' are regarded
##  as system variables this way; is this inconvenient?)
##


#############################################################################
##
#F  NamesSystemGVars()  . . . . . .  list of names of system global variables
##
##  This function returns an immutable sorted list of all the global
##  variable names created by the {\GAP} library when {\GAP} was started.
##
NAMES_SYSTEM_GVARS := Filtered( IDENTS_GVAR(), ISB_GVAR );
Add( NAMES_SYSTEM_GVARS, "NamesUserGVars" );
Add( NAMES_SYSTEM_GVARS, "NamesSystemGVars" );
Add( NAMES_SYSTEM_GVARS, "NAMES_SYSTEM_GVARS" );
Add( NAMES_SYSTEM_GVARS, "last" );
Add( NAMES_SYSTEM_GVARS, "last2" );
Add( NAMES_SYSTEM_GVARS, "last3" );
Add( NAMES_SYSTEM_GVARS, "time" );
NAMES_SYSTEM_GVARS := Set( NAMES_SYSTEM_GVARS );
MakeImmutable( NAMES_SYSTEM_GVARS );
MakeReadOnlyGlobal( "NAMES_SYSTEM_GVARS" );

BIND_GLOBAL( "NamesSystemGVars", function()
    return NAMES_SYSTEM_GVARS;
end);


#############################################################################
##
#F  NamesUserGVars()  . . . . . . . .  list of names of user global variables
##
##  This function returns an immutable sorted list of the global variable
##  names created since the library was read, to which a value is
##  currently bound.
##
BIND_GLOBAL( "NamesUserGVars", function()
    local names;
    names:= Filtered( Difference( NamesGVars(), NamesSystemGVars() ),
                      ISB_GVAR );
    MakeImmutable( names );
    return names;
end);

#############################################################################
##
##  Initialize the help books of the library
##
HELP_ADD_BOOK("Tutorial", "GAP 4 Tutorial", "doc/tut");
HELP_ADD_BOOK("Reference", "GAP 4 Reference Manual", "doc/ref");
HELP_ADD_BOOK("Extending", "Extending GAP 4 Reference Manual", "doc/ext");
HELP_ADD_BOOK("Prg Tutorial", "Programmers Tutorial", "doc/prg");
HELP_ADD_BOOK("New Features", "New Features for Developers", "doc/new");


#############################################################################
##
##  ParGAP/MPI slave hook
##
if PAR_GAP_SLAVE_START <> fail then PAR_GAP_SLAVE_START(); fi;

#############################################################################
##
#E

