#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  This file initializes GAP.
##


#############################################################################
##
#1 Temporary error handling until we are able to read error.g
##
##

#############################################################################
##
#F  OnBreak( )  . . . . . . . . . function to call at entry to the break loop
##
##
OnBreak := function() Print("An error has occurred before the traceback ",
        "functions are defined\n"); end;

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
##  `Error' when GAP is starting up (i.e. reading this file). `OnQuit'  is
##  later  redefined  to  do  a  variant  of  `ResetOptionsStack'  to  ensure
##  `OptionsStack' is empty after a user quits an `Error'-induced break loop.
##  Currently, `OnQuit( )' is not advertised, since  exception  handling  may
##  make it obsolete.
##
OnQuit := function() end;


Error := function( arg )
    local x;
    Print("Error before error-handling is initialized: ");
    for x in arg do
      Print(x);
    od;
    Print("\nwhile reading ", INPUT_FILENAME(), ":", INPUT_LINENUMBER(), "\n");
    if SHOULD_QUIT_ON_BREAK() then
        ForceQuitGap(1);
    fi;
    JUMP_TO_CATCH("early error");
end;

ErrorNoReturn := Error;

ErrorInner := function(options, message)
    Print("Error before error-handling is initialized: ");
    Print(message);
    Print("\nwhile reading ", INPUT_FILENAME(), ":", INPUT_LINENUMBER(), "\n");
    if SHOULD_QUIT_ON_BREAK() then
        ForceQuitGap(1);
    fi;
    JUMP_TO_CATCH("early error");
end;


#############################################################################
##
#F  Ignore( <arg> ) . . . . . . . . . . . . ignore but evaluate the arguments
##
#T  1996/08/07 M.Schönert 'Ignore' should be in the kernel
#T  1996/09/08 S.Linton    Do we need it at all?
##
Ignore := function ( arg )  end;


#############################################################################
##
##  Define some global variables
##
SetFilterObj := "2b defined";
infinity := "2b defined";


#############################################################################
##
#F  ReplacedString( <string>, <old>, <new> )
##
##  This cannot be inside "kernel.g" because it is needed to read "kernel.g".
##
ReplacedString := function ( str, old, new, arg... )
    local lss, all, p, s, pp;
    if old = new then
        return str;
    fi;
    lss := LEN_LIST( old );
    if lss = 0  then
        Error("<old> must not be empty");
    fi;
    if LEN_LIST( arg ) > 0  then
        all := arg[1] = "all";
    else
        all := true;
    fi;
    p := POSITION_SUBSTRING( str, old, 0 );
    if p = fail  then
        return str;
    fi;
    s := str{[  ]};
    pp := 0;
    while p <> fail  do
        APPEND_LIST_INTR( s, str{[ pp+1 .. p - 1 ]} );
        APPEND_LIST_INTR( s, new );
        pp := p + lss - 1;
        if all  then
            p := POSITION_SUBSTRING( str, old, pp );
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
#V  CHECK_INSTALL_METHOD  . . . . . .  check requirements in `INSTALL_METHOD'
##
CHECK_INSTALL_METHOD := true;


#############################################################################
##
#F  READ_GAP_ROOT( <name> ) . . . . . . . . .  read file from GAP's root area
#F  ReadGapRoot( <name> ) . . . . . . . . . .  read file from GAP's root area
##
##  <Ref Func="READ_GAP_ROOT"/> runs through &GAP;'s root directories
##  (see <Ref Sect="GAP Root Directories"/>),
##  reads the first readable file with name <A>name</A> relative to the root
##  directory, and then returns <K>true</K> if a file was read or
##  <K>false</K> if no readable file <A>name</A> was found in any root
##  directory.
##
##  <Ref Func="ReadGapRoot"/> calls <Ref Func="READ_GAP_ROOT"/> and signals
##  an error if <K>false</K> was returned; it does not return anything.
##
##  <Ref Func="READ_GAP_ROOT"/> and <Ref Func="ReadGapRoot"/> are used only
##  for reading files from the &GAP; library.
##  Note that the paths of files from &GAP; packages are determined by the
##  path of the <F>PackageInfo.g</F> file of the package in question.
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
##  Read architecture dependent data and other globals, such as version
##  information.
##
ReadGapRoot( "lib/system.g" );

if IsHPCGAP then
  FILTER_REGION := NEW_REGION("filter region", -1);
else
  BIND_GLOBAL("FILTER_REGION", "filter region");
fi;

#############################################################################
##
#V  ThreadVar  . . . . . . . . . . . . . . . . . . . . thread-local variables
if IsHPCGAP then
  BIND_GLOBAL("ThreadVar", ThreadLocalRecord());
  BIND_GLOBAL("BindThreadLocal", function(name, default)
    MakeThreadLocal(name);
    SetTLDefault(ThreadVar, name, default);
  end);
  BIND_GLOBAL("BindThreadLocalConstructor", function(name, default)
    MakeThreadLocal(name);
    SetTLConstructor(ThreadVar, name, default);
  end);
else
  BIND_GLOBAL("ThreadVar", rec());
  BIND_GLOBAL("BindThreadLocal", ASS_GVAR);
  BIND_GLOBAL("BindThreadLocalConstructor", function(name, fun)
    local ret;
    # Catch if the function returns a value
    ret := CALL_WITH_CATCH(fun,[]);
    if LEN_LIST(ret) > 1 then
      ASS_GVAR(name, ret[2]);
    fi;
  end);
fi;


#############################################################################
##
##  - Set or disable break loop according to the `-T' option.
##  - Set whether traceback may be suppressed (e.g. by `-T') according to the
##    `--alwaystrace' option.
##
CallAndInstallPostRestore( function()
    if IsHPCGAP then
      # In HPC-GAP we want to decide how to handle errors on a per thread
      # basis. E.g. the break loop can be disabled in a worker thread that
      # runs tasks.
      BindThreadLocal( "BreakOnError", not GAPInfo.CommandLineOptions.T );
      BindThreadLocal(
        "AlwaysPrintTracebackOnError",
        GAPInfo.CommandLineOptions.alwaystrace
      );
      BindThreadLocal( "SilentNonInteractiveErrors", false );
      # We store the error messages on a per thread basis to be able to
      # e.g. access them independently from the main thread.
      BindThreadLocal( "LastErrorMessage", "" );
    else
      ASS_GVAR( "BreakOnError", not GAPInfo.CommandLineOptions.T );
      ASS_GVAR( "AlwaysPrintTracebackOnError", GAPInfo.CommandLineOptions.alwaystrace );
      ASS_GVAR( "SilentNonInteractiveErrors", false );
    fi;
end);

ReadOrComplete := function(name)
    if GAPInfo.CommandLineOptions.D then
        Print( "#I  reading ", name, "\n" );
    fi;
    if not READ_GAP_ROOT( name ) then
        Error( "cannot read file ", name );
    fi;
end;


#############################################################################
##
#F  ReadAndCheckFunc( <path> )
##
##  `ReadAndCheckFunc' creates a function that take an argument <name>, and
##  then reads in a file named <name> from <path>.
##  This can be used for partial reading of the library.
##
BIND_GLOBAL("ReadAndCheckFunc",function( path )

    path := IMMUTABLE_COPY_OBJ(path);

    return function( name )
        local  libname, error;

        # create a filename from <path> and <name>
        libname := SHALLOW_COPY_OBJ(path);
        APPEND_LIST_INTR( libname, "/" );
        APPEND_LIST_INTR( libname, name );

        error := not READ_GAP_ROOT(libname);

        if error then
          Error( "the library file '", libname, "' must exist and ",
                 "be readable");
        fi;

    end;
end);

#############################################################################
##
#F  ReadLib( <name> ) . . . . . . . . . . . . . . . . . . . . . library files
#F  ReadGrp( <name> ) . . . . . . . . . . . . . . . . . . group library files
##
BIND_GLOBAL("ReadLib",ReadAndCheckFunc("lib"));
BIND_GLOBAL("ReadGrp",ReadAndCheckFunc("grp"));


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
PrimitiveGroup:=NONAVAILABLE_FUNC("Primitive Groups library");

#############################################################################
##
##  Initialize functions for the source of small group lib and id library
##
ID_AVAILABLE := x -> fail;

#############################################################################
##
#X  read in the files
##


# inner functions, needed in the kernel
ReadGapRoot( "lib/read1.g" );
ExportToKernelFinished();
if IsHPCGAP then
  ENABLE_AUTO_RETYPING();
fi;


#############################################################################
##
##  The command line option '-L' is supported only if GASMAN is used.
##
if "-L" in GAPInfo.SystemCommandLine and GAPInfo.KernelInfo.GC <> "GASMAN" then
  Error( "workspaces (-L option) are supported only if GASMAN is used" );
fi;


# try to find terminal encoding
CallAndInstallPostRestore( function()
  local env, pos, enc, a, PositionSublist;
  PositionSublist := function (str, sub)
    local i;

    for i in [1..Length(str)-Length(sub)+1] do
       if str{[i..i+Length(sub)-1]}=sub then
         return i;
       fi;
    od;
    return fail;
  end;

  # we leave the GAPInfo.TermEncodingOverwrite for gaprc
  # for a moment, but don't document it - doesn't work with
  # loaded workspaces
  if not IsBound(GAPInfo.TermEncodingOverwrite) then
    if IsList(GAPInfo.SystemEnvironment) then
      # for compatibility with GAP 4.4.
      env := rec();
      for a in GAPInfo.SystemEnvironment do
        pos := Position(a, '=');
        env.(a{[1..pos-1]}) := a{[pos+1..Length(a)]};
      od;
    else
      env := GAPInfo.SystemEnvironment;
    fi;
    enc := fail;
    if IsBound(env.LC_ALL) then
      enc := env.LC_ALL;
    fi;
    if enc = fail and IsBound(env.LC_CTYPE) then
      enc := env.LC_CTYPE;
    fi;
    if enc = fail and IsBound(env.LANG) then
      enc := env.LANG;
    fi;
    if enc <> fail then
      enc:=STRING_LOWER(enc);
      if (PositionSublist(enc, "utf-8") <> fail  or
          PositionSublist(enc, "utf8") <> fail) then
        GAPInfo.TermEncoding := "UTF-8";
      fi;
    fi;
    if not IsBound(GAPInfo.TermEncoding) then
      # default is latin1
      GAPInfo.TermEncoding := "ISO-8859-1";
    fi;
  else
    GAPInfo.TermEncoding := GAPInfo.TermEncodingOverwrite;
  fi;
  MakeImmutable( GAPInfo.TermEncoding );
end );

BindGlobal("_PrintInfo",
function( prefix, values, suffix )
  local linelen, indent, PL, comma, N;

  linelen:= SizeScreen()[1] - 2;
  indent := "             ";

  Print( prefix );
  PL:= Length(prefix)+1;
  comma:= "";
  for N in values do
    Print( comma );
    PL:= PL + Length( comma );
    if PL + Length( N ) > linelen then
      Print( "\n", indent);
      PL:= Length(indent)+1;
    fi;
    Print( N, "\c" );
    PL:= PL + Length( N );
    comma:= ", ";
  od;
  if PL + Length( suffix ) + 1 > linelen then
    Print( "\n", indent);
  fi;
  Print( suffix );
end);

BindGlobal( "ShowKernelInformation", function()
  local sysdate, btop, vert, bbot, config, str, gap;

  if GAPInfo.Date <> "today" then
    sysdate := " of ";
    Append(sysdate, GAPInfo.Date);
  elif GAPInfo.BuildDateTime = "reproducible" then
    sysdate := "";
  else
    sysdate := " built on ";
    Append(sysdate, GAPInfo.BuildDateTime);
  fi;

  if GAPInfo.TermEncoding = "UTF-8" then
    btop := "┌───────┐\c"; vert := "│"; bbot := "└───────┘\c";
  else
    btop := "*********"; vert := "*"; bbot := btop;
  fi;
  if IsHPCGAP then
    gap := "HPC-GAP";
  else
    gap := "GAP";
  fi;
  Print( " ",btop,"   ",gap," ", GAPInfo.BuildVersion,
         sysdate, "\n",
         " ",vert,"  GAP  ",vert,"   https://www.gap-system.org\n",
         " ",bbot,"   Architecture: ", GAPInfo.Architecture, "\n" );
  if IsHPCGAP then
    Print( "             Maximum concurrent threads: ",
       GAPInfo.KernelInfo.NUM_CPUS, "\n");
  fi;
  # For each library or configuration setting, print some info.
  config:= [];
  # always mention GMP
  if true then
    if IsBound( GAPInfo.KernelInfo.GMP_VERSION ) then
      str := "gmp ";
      Append(str, GAPInfo.KernelInfo.GMP_VERSION);
    else
      str := "gmp";
    fi;
    Add( config, str );
  fi;
  if IsBound( GAPInfo.KernelInfo.GC ) then
    Add( config, GAPInfo.KernelInfo.GC );
  fi;
  if IsBound( GAPInfo.KernelInfo.JULIA_VERSION ) then
    str := "Julia ";
    Append(str, GAPInfo.KernelInfo.JULIA_VERSION);
    Add( config, str );
  fi;
  if IsBound( GAPInfo.UseReadline ) then
    Add( config, "readline" );
  fi;
  if GAPInfo.KernelInfo.KernelDebug then
    Add( config, "KernelDebug" );
  fi;
  if GAPInfo.KernelInfo.MemCheck then
    Add(config, "MemCheck");
  fi;
  if config <> [] then
    _PrintInfo( " Configuration:  ", config, "\n" );
  fi;
  if GAPInfo.CommandLineOptions.L <> "" then
    Print( " Loaded workspace: ", GAPInfo.CommandLineOptions.L, "\n" );
  fi;
  if IsHPCGAP then
    Print("\n",
          "#W <<< This is an alpha release.      >>>\n",
          "#W <<< Do not use for important work. >>>\n",
      "\n");
  fi;
end );

# delay printing the banner, if -L option was passed (LB)

CallAndInstallPostRestore( function()
     if not ( GAPInfo.CommandLineOptions.q or
              GAPInfo.CommandLineOptions.b or GAPInfo.CommandLineOptions.L<>"" ) then
       ShowKernelInformation();
     fi;
     end );

#############################################################################
##
##  Name of option to avoid precomputed data libraries -- made a variable so
##  it can still be changed easily
##
BindGlobal("NO_PRECOMPUTED_DATA_OPTION","NoPrecomputedData");


if not ( GAPInfo.CommandLineOptions.q or GAPInfo.CommandLineOptions.b ) then
    Print (" Loading the library \c");
fi;

ReadOrComplete( "lib/read2.g" );
ReadOrComplete( "lib/read3.g" );

#  Force population of GAPInfo.DirectoryCurrent
#  Do it now so that Directory works, but it is available
#  to package code.
#
CallAndInstallPostRestore(DirectoryCurrent);

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

# Here are a few general user preferences which may be useful for
# various purposes. They are self-explaining.
DeclareUserPreference( rec(
  name:= "UseColorsInTerminal",
  description:= [
    "Almost all current terminal emulations support color display, \
setting this to <K>true</K> implies a default display of most manuals with \
color markup. It may influence the display of other things in the future."
    ],
  default:= true,
  values:= [ true, false ],
  multi:= false,
  ) );
DeclareUserPreference( rec(
  name:= "ViewLength",
  description:= [
    "A bound for the number of lines printed when <C>View</C>ing some large objects."
    ],
  default:= 3,
  check:= val -> IsInt( val ) and 0 <= val,
  ) );
DeclareUserPreference( rec(
  name:= "ReproducibleBehaviour",
  description:= [
    "This preference disables code in &GAP; which changes behaviour based on time \
spent, and therefore can produce different results depending on how much time is \
taken by other programs running on the same computer. This option may lead to \
slower or lower-quality results.\
\n\
Note that many algorithms in &GAP; use the global random number generator, which is \
NOT affected by this option. This only tries to ensure the same version of &GAP;, \
with the same package versions loaded, on the same machine, running the same code, \
in a fresh &GAP; session, will produce the same results."
    ],
  default:= false,
  values:= [ true, false ],
  multi:= false,
  ) );

# This provides a substitute for the function Runtime(), for use
# with the user option ReproducibleBehaviour. Instead of measuring
# time, it simply increments a global variable each time it is called.
FAKE_RUNTIME_COUNT := 0;
BindGlobal("FAKE_RUNTIME", function()
    FAKE_RUNTIME_COUNT := FAKE_RUNTIME_COUNT + 1;
    return FAKE_RUNTIME_COUNT;
end);

# get the timing function which should be used, which is either
# FAKE_RUNTIME, or Runtime, depending on the current value of
# ReproducibleBehaviour.

BindGlobal("GET_TIMER_FROM_ReproducibleBehaviour",
function()
    if UserPreference("ReproducibleBehaviour") then
        return FAKE_RUNTIME;
    else
        return Runtime;
    fi;
end);


############################################################################
##
#X  Name Synonyms for different spellings
##
ReadLib("transatl.g");


CallAndInstallPostRestore( function()
    READ_GAP_ROOT( "gap.ini" );
end );


#############################################################################
##
#X  files installing compatibility with deprecated, obsolescent or
##  obsolete GAP4 behaviour;
##  *not* to be read if `GAPInfo.UserPreferences.ReadObsolete' has the value
##  `false'
##  (this value can be set in the `gap.ini' file)
##
# reading can be configured via a user preference
DeclareUserPreference( rec(
  name:= "ReadObsolete",
  description:= [
    "May be useful to say <K>false</K> here to check if you are using commands \
which may vanish in a future version of &GAP;"
    ],
  default:= true,
  values:= [ true, false ],
  multi:= false,
  ) );
# HACKUSERPREF temporary hack for AtlasRep and CTblLib:
GAPInfo.UserPreferences.ReadObsolete := UserPreference("ReadObsolete");

ReadLib("obsolete.g"); # the helpers in there are always read
CallAndInstallPostRestore( function()
    if not GAPInfo.CommandLineOptions.O and UserPreference( "ReadObsolete" ) <> false and
       not IsBound( GAPInfo.Read_obsolete_gd ) then
      ReadLib( "obsolete.gd" );
      GAPInfo.Read_obsolete_gd:= true;
    fi;
end );


#############################################################################
##
##  Autoload packages (suppressing banners).
##  (If GAP was started with a workspace then the user may have given
##  additional directories, so more suggested packages may become available.
##  So we have to call `AutoloadPackages' also then.
##  Note that we have to use `CallAndInstallPostRestore' not
##  `InstallAndCallPostRestore' because some packages may install their own
##  post-restore functions, and when a workspaces gets restored then these
##  functions must be called *before* loading new packages.)
##
##  Load the implementation part of the GAP library.
##
##  Load additional packages, such that their names appear in the banner.
##
if not ( GAPInfo.CommandLineOptions.q or GAPInfo.CommandLineOptions.b ) then
    Print ("and packages ...\n");
fi;
CallAndInstallPostRestore( AutoloadPackages );


############################################################################
##
##  Propagate the user preferences.
##  (This function cannot be called earlier,
##  since the GAP library may not be loaded before.)
##
CallAndInstallPostRestore( function()
    local   xy;

    # screen size (options `-x' and `-y').
    xy := [];
    if GAPInfo.CommandLineOptions.x <> "" then
        xy[1] := SMALLINT_STR(GAPInfo.CommandLineOptions.x);
    fi;
    if GAPInfo.CommandLineOptions.y <> "" then
        xy[2] := SMALLINT_STR(GAPInfo.CommandLineOptions.y);
    fi;
    if xy <> [] then
        SizeScreen(xy);
    fi;

    # option `-g'
    if GAPInfo.KernelInfo.GC = "GASMAN" then
      if   GAPInfo.CommandLineOptions.g = 0 then
        SetGasmanMessageStatus( "none" );
      elif GAPInfo.CommandLineOptions.g = 1 then
        SetGasmanMessageStatus( "full" );
      else
        SetGasmanMessageStatus( "all" );
      fi;
    fi;

    # maximal number of lines that are reasonably printed
    # in `ViewObj' methods
    GAPInfo.ViewLength:= UserPreference( "ViewLength" );

    # user preference `UseColorPrompt'
    ColorPrompt( UserPreference( "UseColorPrompt" ) );
end );


#############################################################################
##
#X  files installing compatibility with deprecated, obsolescent or
##  obsolete GAP4 behaviour;
##  *not* to be read if `UserPreference( "ReadObsolete" )' has the value
##  `false'
##  (this value can be set in the `gap.ini' file)
##
CallAndInstallPostRestore( function()
    if not GAPInfo.CommandLineOptions.O and UserPreference( "ReadObsolete" ) <> false and
       not IsBound( GAPInfo.Read_obsolete_gi ) then
      ReadLib( "obsolete.gi" );
      GAPInfo.Read_obsolete_gi:= true;
    fi;
end );


#############################################################################
##
##  Install SaveCommandLineHistory as exit function and read history from
##  file, depending on user preference.
##
CallAndInstallPostRestore( function()
  if UserPreference("SaveAndRestoreHistory") = true then
    InstallAtExit(SaveCommandLineHistory);
    ReadCommandLineHistory();
  fi;
end );

#############################################################################
##
##  If the command line option `-r' is not given
##  and if no `gaprc' file has been read yet (if applicable then including
##  the times before the current workspace had been created)
##  then read the first `gaprc' file from the GAP root directories.
##
CallAndInstallPostRestore( function()
    if READ_GAP_ROOT( "gaprc" ) then
      GAPInfo.HasReadGAPRC:= true;
    elif not IsExistingFile(GAPInfo.UserGapRoot) then
      # For compatibility with GAP 4.4:
      # If no readable `gaprc' file exists in the GAP root directories and
      # the user root directory does not (yet) exist then
      # try to read `~/.gaprc' (on UNIX systems) or `gap.rc' (otherwise).
      if not ( GAPInfo.CommandLineOptions.r or GAPInfo.HasReadGAPRC ) then
        if ARCH_IS_UNIX() then
          GAPInfo.gaprc:= SHALLOW_COPY_OBJ( GAPInfo.UserHome );
          if IsString(GAPInfo.gaprc) then
            APPEND_LIST_INTR( GAPInfo.gaprc, "/.gaprc" );
          fi;
        else
          GAPInfo.gaprc:= "gap.rc";
        fi;
        if IsString(GAPInfo.gaprc) and READ( GAPInfo.gaprc ) then
          Info(InfoWarning, 1,
            "You are using an old ",GAPInfo.gaprc, " file. ");
          Info(InfoWarning, 1,
            "See '?Ref: The former .gaprc file' for hints to upgrade.");
          GAPInfo.HasReadGAPRC:= true;
        fi;
      fi;
    fi;
end );


#############################################################################
##
##  Display loaded packages
##

BindGlobal( "ShowPackageInformation", function()
  local packagenames;

  # For each loaded package, print name and version number.
  packagenames := SortedList( RecNames( GAPInfo.PackagesLoaded ) );
  if not IsEmpty(packagenames) then
    _PrintInfo( " Packages:   ",
               List( packagenames,
                     name -> Concatenation(
                                 GAPInfo.PackagesLoaded.( name )[3], " ",
                                 GAPInfo.PackagesLoaded.( name )[2] ) ),
               "\n" );
  fi;

  Print( " Try '??help' for help. See also '?copyright', '?cite' and '?authors'",
         "\n" );
end );
#T show also root paths?

CallAndInstallPostRestore( function()
     if not ( GAPInfo.CommandLineOptions.q or
              GAPInfo.CommandLineOptions.b ) then
       if GAPInfo.CommandLineOptions.L<>"" then
         ShowKernelInformation();
       fi;
       ShowPackageInformation();
     fi;
     end );

BindGlobal ("ShowSystemInformation", function ()
    ShowKernelInformation();
    ShowPackageInformation();
end );


#############################################################################
##
##  Finally, deal with the lists of global variables.
##  This must be done at the end of this file,
##  since the variables defined in packages are regarded as system variables.
#T But this way also the variables that get bound in `gaprc' are regarded
#T as system variables!
##


#############################################################################
##
#F  NamesSystemGVars()  . . . . . .  list of names of system global variables
##
##  This function returns an immutable sorted list of all the global
##  variable names created by the GAP library when GAP was started.
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
if IsHPCGAP then
  HELP_ADD_BOOK("HPC-GAP", "HPC-GAP Reference Manual", "doc/hpc");
fi;
if ForAny( GAPInfo.RootPaths,
           rp -> IsDirectoryPath( Concatenation( rp, "/doc/dev" ) ) ) then
  HELP_ADD_BOOK("Development", "GAP 4 Development Manual", "doc/dev");
fi;


#############################################################################
##
##  Read init files, run a shell, and do exit-time processing.
##

ResumeMethodReordering();

BindGlobal( "ProcessInitFiles", function(initFiles)
    local i, f;
    for i in [1..Length(initFiles)] do
        f := initFiles[i];
        if IsRecord(f) then
            Read(InputTextString(f.command));
        elif EndsWith(f, ".tst") then
            Test(f);
        else
            Read(f);
        fi;
    od;
end );

InstallAndCallPostRestore( function()
    ProcessInitFiles(GAPInfo.InitFiles);
end );

if GAPInfo.CommandLineOptions.norepl then
  # do not start an interactive session
elif IsHPCGAP and THREAD_UI() then
  ReadLib("hpc/consoleui.g");
  MULTI_SESSION();
  PROGRAM_CLEAN_UP();
else
  SESSION();
  PROGRAM_CLEAN_UP();
fi;

