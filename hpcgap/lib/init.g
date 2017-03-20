#############################################################################
##
#W  init.g                      GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                          & Martin Schönert
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file initializes GAP.
##
Revision := AtomicRecord( rec() );


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
    Print("\n");
    JUMP_TO_CATCH("early error");
end;

ErrorInner := function(options, message)
    Print("Error before error-handling is initialized: ");
    Print(message);
    JUMP_TO_CATCH("early error");
end;

#############################################################################
##
#F  MakeLiteral(<obj>) . . . . . . make the argument a literal and return it.
##

MakeLiteral := MakeImmutable;
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

##IS_READ_OR_COMPLETE := false;
## commented out - was needed by the completion mechanism
## READED_FILES := [];

FILTER_REGION	 	 := NEW_REGION("filter region", -1);
atomic FILTER_REGION do
  RANK_FILTER_LIST         := MIGRATE([], FILTER_REGION);
od;
RANK_FILTER_LIST_CURRENT := fail;
RANK_FILTER_COUNT        := fail;

RANK_FILTER_COMPLETION   := Error;	# defined in "filter.g"
RANK_FILTER_STORE        := Error;	# defined in "filter.g"
RANK_FILTER              := Error;	# defined in "filter.g"
RankFilter               := Error;      # defined in "filter.g"


#############################################################################
##
#V  ThreadVar  . . . . . . . . . . . . . . . . . . . . thread-local variables

BIND_GLOBAL("ThreadVar", ThreadLocalRecord());
BIND_GLOBAL("BindThreadLocal", function(name, default)
  MakeThreadLocal(name);
  SetTLDefault(ThreadVar, name, default);
end);
BIND_GLOBAL("BindThreadLocalConstructor", function(name, default)
  MakeThreadLocal(name);
  SetTLConstructor(ThreadVar, name, default);
end);


#############################################################################
##
##  - Unbind `DEBUG_LOADING', since later the `-D' option can be checked.
##  - Set or disable break loop according to the `-T' option.
##
CallAndInstallPostRestore( function()
    if DEBUG_LOADING then
      InfoRead1:= Print;
    else
      InfoRead1:= Ignore;
    fi;
    MAKE_READ_WRITE_GLOBAL( "DEBUG_LOADING" );
    UNBIND_GLOBAL( "DEBUG_LOADING" );

    MAKE_READ_WRITE_GLOBAL( "TEACHING_MODE" );
    UNBIND_GLOBAL( "TEACHING_MODE" );
    BIND_GLOBAL( "TEACHING_MODE", GAPInfo.CommandLineOptions.T );
    BindThreadLocal( "BreakOnError", not GAPInfo.CommandLineOptions.T );
    BindThreadLocal( "SilentErrors", false );
    BindThreadLocal( "LastErrorMessage", "" );
end);



#############################################################################
##
#F  ReadOrComplete( <name> )  . . . . . . . . . . . . read file or completion
####
##COMPLETABLE_FILES := [];
##COMPLETED_FILES   := [];
##
##ReadOrComplete := function( name )
##    local check;
##
##    READED_FILES := [];
##    check        := CHECK_INSTALL_METHOD;
##
##    # use completion files
##    if not GAPInfo.CommandLineOptions.N then
##
##        # do not check installation and use cached ranks
##        CHECK_INSTALL_METHOD := false;
##        RankFilter           := RANK_FILTER_COMPLETION;
##
##        # check for the completion file
##        if not READ_GAP_ROOT( ReplacedString( name, ".g", ".co" ) ) then
##
##            # set filter functions to store
##            IS_READ_OR_COMPLETE  := true;
##            CHECK_INSTALL_METHOD := check;
##            RankFilter           := RANK_FILTER_STORE;
##            RANK_FILTER_LIST     := [];
##
##            # read the original file
##            InfoRead1( "#I  reading ", name, "\n" );
##            if not READ_GAP_ROOT( name ) then
##                Error( "cannot read or complete file ", name );
##            fi;
##            ADD_LIST( COMPLETABLE_FILES, [ name, READED_FILES, RANK_FILTER_LIST ] );
##
##        # file completed
##        else
##            ADD_LIST( COMPLETED_FILES, name );
##            InfoRead1( "#I  completed ", name, "\n" );
##        fi;
##
##    else
##
##        # set `RankFilter' to hash the ranks
##        IS_READ_OR_COMPLETE := true;
##        RankFilter          := RANK_FILTER_STORE;
##        RANK_FILTER_LIST    := [];
##
##        # read the file
##        if not READ_GAP_ROOT( name ) then
##            Error( "cannot read file ", name );
##        fi;
##        ADD_LIST( COMPLETABLE_FILES, [ name, READED_FILES, RANK_FILTER_LIST ] );
##    fi;
##
##    # reset rank and filter functions
##    IS_READ_OR_COMPLETE  := false;
##    CHECK_INSTALL_METHOD := check;
##    RankFilter           := RANK_FILTER;
##    Unbind(RANK_FILTER_LIST);
##    Unbind(READED_FILES);
##end;
##

ReadOrComplete := function(name)
    InfoRead1( "#I  reading ", name, "\n" );
    if not READ_GAP_ROOT( name ) then
        Error( "cannot read file ", name );
    fi;
end;

#############################################################################
##
#F  READ_CHANGED_GAP_ROOT( <name> ) . . . . . .  completion file is out-dated
##
##READ_CHANGED_GAP_ROOT := function( name )
##    local   rankFilter;
##
##    atomic FILTER_REGION do
##	rankFilter := RankFilter;
##	RankFilter := RANK_FILTER;
##	Print( "#W  inconsistent completion for \"", name, "\"\n" );
##	if not READ_GAP_ROOT(name)  then
##	    Error( "cannot read file ", name );
##	fi;
##	RankFilter := rankFilter;
##    od;
##end;
##

#############################################################################
##
##  Check whether kernel version and library version fit.
##
CallAndInstallPostRestore( function()
    local nondigits, digits, i, char, have, need, haveint, needint;

    if ( not IS_STRING(GAPInfo.NeedKernelVersion) and
         not GAPInfo.KernelVersion in GAPInfo.NeedKernelVersion ) or
       ( IS_STRING(GAPInfo.NeedKernelVersion) and
         GAPInfo.KernelVersion <> GAPInfo.NeedKernelVersion ) then
      Print( "\n\n",
        "You are running a GAP kernel which does not fit with the library.\n\n" );

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
      # it has the right monotony behaviour for the comparisons.)
      haveint:= [];
      needint:= [];
      for i in [ 1 .. 3 ] do
        haveint[i]:= IntHexString( have[i] );
        needint[i]:= IntHexString( need[i] );
      od;

      if haveint > needint then
        # kernel newer
        Print( "The GAP kernel is newer than the library.\n\n" );
      else
        # kernel older
        Print( "The GAP kernel is older than the library. Perhaps you forgot to recompile?\n\n" );
      fi;
      Error( "Update to correct kernel version!\n\n" );
    fi;
end );


#############################################################################
##
#F  ReadAndCheckFunc( <path>[,<libname>] )
##
##  `ReadAndCheckFunc' creates a function that reads in a file named
##  `<name>.<ext>'.
##  If a second argument <libname> is given, GAP return `true' or `false'
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
##        if IS_READ_OR_COMPLETE  then
##	    atomic FILTER_REGION do
##		ADD_LIST( READED_FILES, libname );
##		if IsBound(RANK_FILTER_LIST_CURRENT) then
##		    rflc := RANK_FILTER_LIST_CURRENT;
##		fi;
##		if IsBound(RANK_FILTER_COUNT) then
##		    rfc := RANK_FILTER_COUNT;
##		fi;
##		RANK_FILTER_LIST_CURRENT := [];
##		RANK_FILTER_COUNT := 0;
##		ADD_LIST( RANK_FILTER_LIST, RANK_FILTER_LIST_CURRENT );
##		error:=not READ_GAP_ROOT(libname);
##		Unbind(RANK_FILTER_LIST_CURRENT);
##		if IsBound(rflc) then
##		    RANK_FILTER_LIST_CURRENT := rflc;
##		fi;
##		Unbind(RANK_FILTER_COUNT);
##		if IsBound(rfc) then
##		    RANK_FILTER_COUNT := rfc;
##		fi;
##	    od;
##        else
            error:=not READ_GAP_ROOT(libname);
##        fi;

	if error then
	  if LEN_LIST( arg )=1 then
	    Error( "the library file '", name, "' must exist and ",
		   "be readable");
	  else
	    return false;
	  fi;
	elif path<>"pkg" then
	  # check the revision entry
          ext := SHALLOW_COPY_OBJ(prefix);
	  APPEND_LIST_INTR(ext,ReplacedString( name, ".", "_" ));
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
ENABLE_AUTO_RETYPING();

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


  ##  i := Length (str)-Length (sub) + 1;
  ##  while i > 0 do
  ##      if str{[i..i+Length(sub)-1]}=sub then
  ##          return i;
  ##      fi;
  ##  od;
  ##  return fail;
  ##end;
        
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
    if IsBound(env.LC_CTYPE) then
      enc := env.LC_CTYPE;
    fi;
    if enc = fail and IsBound(env.LC_ALL) then
      enc := env.LC_ALL;
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



BindGlobal( "ShowKernelInformation", function()
  local sysdate, fun, linelen, indent, btop, vert, bbot, print_info,
        libs;

    linelen:= SizeScreen()[1] - 2;
    print_info:= function( prefix, values, suffix )
      local PL, comma, N;

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
    end;

    sysdate:= GAPInfo.BuildDateTime;

    if IsBound(GAPInfo.shortbanner) then
        Print("This is GAP ", GAPInfo.Version, " of ", sysdate,
        " (", GAPInfo.Architecture);
        if "gmpints" in LoadedModules() then
            Print("+gmp");
        fi;
        if IsBound( GAPInfo.UseReadline ) then
            Print("+readline");
        fi;
        Print(")\n");
        if GAPInfo.CommandLineOptions.L <> "" then
            Print( "Restoring workspace ", GAPInfo.CommandLineOptions.L, "\n");
        fi;
    else
      indent := "             ";
      if GAPInfo.TermEncoding = "UTF-8" then
        btop := "┌───────┐\c"; vert := "│"; bbot := "└───────┘\c";
      else
        btop := "*********"; vert := "*"; bbot := btop;
      fi;
      Print( " ",btop,"   HPC-GAP, Version ", GAPInfo.Version, " of ",
             sysdate, "\n",
             " ",vert,"  GAP  ",vert,"   https://www.gap-system.org\n",
             " ",bbot,"   Architecture: ", GAPInfo.Architecture, "\n",
	     "             Maximum concurrent threads: ",
	     GAPInfo.KernelInfo.NUM_CPUS, "\n");
      # For each library, print the name.
      libs:= [];
      if "gmpints" in LoadedModules() then
        Add( libs, "gmp" );
      fi;
      if IsBound( GAPInfo.UseReadline ) then
        Add( libs, "readline" );
      fi;
      if libs <> [] then
        print_info( " Libs used:  ", libs, "\n" );
      fi;
      if GAPInfo.CommandLineOptions.L <> "" then
        Print( " Loaded workspace: ", GAPInfo.CommandLineOptions.L, "\n" );
      fi;
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
        
     
if not ( GAPInfo.CommandLineOptions.q or GAPInfo.CommandLineOptions.b ) then
    #Print (" Loading the library ... (see '?Saving and Loading' to start GAP faster)\n");
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


# we cannot complete the following command because printing may mess up the
# backslash-masked characters!
BIND_GLOBAL("VIEW_STRING_SPECIAL_CHARACTERS_OLD",
  # The first list is sorted and contains special characters. The second list
  # contains characters that should instead be printed after a `\'.
  Immutable([ "\c\b\n\r\"\\", "cbnr\"\\" ]));
BIND_GLOBAL("SPECIAL_CHARS_VIEW_STRING",
MakeImmutable(
[ List(Concatenation([0..31],[34,92],[127..255]), CHAR_INT), [
"\\000", "\\>", "\\<", "\\c", "\\004", "\\005", "\\006", "\\007", "\\b", "\\t",
"\\n", "\\013", "\\014", "\\r", "\\016", "\\017", "\\020", "\\021", "\\022",
"\\023", "\\024", "\\025", "\\026", "\\027", "\\030", "\\031", "\\032", "\\033",
"\\034", "\\035", "\\036", "\\037", "\\\"", "\\\\",
"\\177","\\200","\\201","\\202","\\203","\\204","\\205","\\206","\\207",
"\\210","\\211","\\212","\\213","\\214","\\215","\\216","\\217","\\220",
"\\221","\\222","\\223","\\224","\\225","\\226","\\227","\\230","\\231",
"\\232","\\233","\\234","\\235","\\236","\\237","\\240","\\241","\\242",
"\\243","\\244","\\245","\\246","\\247","\\250","\\251","\\252","\\253",
"\\254","\\255","\\256","\\257","\\260","\\261","\\262","\\263","\\264",
"\\265","\\266","\\267","\\270","\\271","\\272","\\273","\\274","\\275",
"\\276","\\277","\\300","\\301","\\302","\\303","\\304","\\305","\\306",
"\\307","\\310","\\311","\\312","\\313","\\314","\\315","\\316","\\317",
"\\320","\\321","\\322","\\323","\\324","\\325","\\326","\\327","\\330",
"\\331","\\332","\\333","\\334","\\335","\\336","\\337","\\340","\\341",
"\\342","\\343","\\344","\\345","\\346","\\347","\\350","\\351","\\352",
"\\353","\\354","\\355","\\356","\\357","\\360","\\361","\\362","\\363",
"\\364","\\365","\\366","\\367","\\370","\\371","\\372","\\373","\\374",
"\\375","\\376","\\377" ]]));


# help system, profiling
ReadOrComplete( "lib/read4.g" );
#  moved here from read4.g, because completion doesn't work with if-statements
#  around function definitions!
ReadLib( "helpview.gi"  );

#T  1996/09/01 M.Schönert this helps performance
ORIGINAL_IMPS := IMPLICATIONS;
atomic ORIGINAL_IMPS do
    IMPLICATIONS :=
      IMPLICATIONS{[Length(IMPLICATIONS),Length(IMPLICATIONS)-1..1]};
    MigrateSingleObj(IMPLICATIONS, ORIGINAL_IMPS);
    TypeObj(IMPLICATIONS[1]);
od;
#T shouldn't this better be at the end of reading the library?
#T and what about implications installed in packages?
#T (put later installations to the front?)


#############################################################################
##
##  Set the defaults of `GAPInfo.UserPreferences'.
##
##  We locate the first file `gap.ini' in GAP root directories,
##  and read it if available.
##  This must be done before `GAPInfo.UserPreferences' is used.
##  Some of the preferences require an initialization,
##  but this cannot be called before the complete library has been loaded.
##

# The following function is not recommended anymore.
# Give a warning but do what the function was expected to do.
BindGlobal( "SetUserPreferences", function( arg )
    local name, record;
    
    Info( InfoWarning, 1, "");
    Info( InfoWarning, 1, Concatenation( [
          "The call to 'SetUserPreferences' (probably in a 'gap.ini' file)\n",
          "#I  should be replaced by individual 'SetUserPreference' calls,\n",
          "#I  which are package specific.\n",
          "#I  Try 'WriteGapIniFile()'." ] ) );
 
    # Set the new values.
    if Length( arg ) = 1 then
      record:= arg[1];
      if not IsBound(GAPInfo.UserPreferences.gapdoc) then
        GAPInfo.UserPreferences.gapdoc := rec();
      fi;
      if not IsBound(GAPInfo.UserPreferences.gap) then
        GAPInfo.UserPreferences.gap := rec();
      fi;
      for name in RecNames( record ) do
        if name in [ "HTMLStyle", "TextTheme", "UseMathJax" ] then
          GAPInfo.UserPreferences.gapdoc.( name ):= record.( name );
        else
          GAPInfo.UserPreferences.gap.( name ):= record.( name );
        fi;
      od;
    fi;
    end );

# SetUserPreferences();

# Here are a few general user preferences which may be useful for 
# various purposes. They are self-explaining.
DeclareUserPreference( rec(
  name:= "UseColorsInTerminal",
  description:= [
    "Almost all current terminal emulations support color display, \
setting this to 'true' implies a default display of most manuals with \
color markup. It may influence the display of other things in the future."
    ],
  default:= true,
  values:= [ true, false ],
  multi:= false,
  ) );
DeclareUserPreference( rec(
  name:= "ViewLength",
  description:= [
    "A bound for the number of lines printed when 'View'ing some large objects."
    ],
  default:= 3,
  check:= val -> IsInt( val ) and 0 <= val,
  ) );

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
    "May be useful to say 'false' here to check if you are using commands \
which may vanish in a future version of GAP"
    ],
  default:= true,
  values:= [ true, false ],
  multi:= false,
  ) );
# HACKUSERPREF temporary hack for AtlasRep and CTblLib:
GAPInfo.UserPreferences.ReadObsolete := UserPreference("ReadObsolete");
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
    if   GAPInfo.CommandLineOptions.g = 0 then
      SetGasmanMessageStatus( "none" );
    elif GAPInfo.CommandLineOptions.g = 1 then
      SetGasmanMessageStatus( "full" );
    else
      SetGasmanMessageStatus( "all" );
    fi;

    # maximal number of lines that are reasonably printed
    # in `ViewObj' methods
    GAPInfo.ViewLength:= UserPreference( "ViewLength" );

    # user preference `UseColorPrompt'
    ColorPrompt( UserPreference( "UseColorPrompt" ) );
end );


############################################################################
##
#X  Name Synonyms for different spellings
##
ReadLib("transatl.g");


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
##  Display version, loaded components and packages
##

BindGlobal( "ShowPackageInformation", function()
  local linelen, indent, btop, vert, bbot, print_info,
        libs, cmpdist, ld, f;

    linelen:= SizeScreen()[1] - 2;
    print_info:= function( prefix, values, suffix )
      local PL, comma, N;

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
    end;


    if IsBound(GAPInfo.shortbanner) then
        indent := "  ";
        if RecNames( GAPInfo.PackagesLoaded ) <> [ ] then
            print_info( "Packages ",
                  List( RecNames( GAPInfo.PackagesLoaded ),
                        name -> Concatenation(
                                    GAPInfo.PackagesLoaded.( name )[3], " ",
                                    GAPInfo.PackagesLoaded.( name )[2] ) ),
                  ".\n" );
        fi;
    else
      indent := "             ";

      # For each loaded component, print name and version number.
      # We use an abbreviation for the distributed combination of
      # idX and smallX components.
      if GAPInfo.LoadedComponents <> rec() then
        cmpdist := rec(id10:="0.1",id2:="3.0",id3:="2.1",id4:="1.0",id5:="1.0",
                   id6:="1.0",id9:="1.0",small:="2.1",small10:="0.2",
                   small11:="0.1",small2:="2.0",small3:="2.0",small4:="1.0",
                   small5:="1.0",small6:="1.0",small7:="1.0",small8:="1.0",
                   small9:="1.0");
        ld := ShallowCopy(GAPInfo.LoadedComponents);
        if ForAll(RecNames(cmpdist), f-> IsBound(ld.(f))
                                          and ld.(f) = cmpdist.(f)) then
          for f in RecNames(cmpdist) do
            Unbind(ld.(f));
          od;
          ld.("small*") := "1.0";
          ld.("id*") := "1.0";
        fi;
        print_info( " Components: ",
                    List( RecNames( ld ), name -> Concatenation( name, " ",
                                      ld.( name ) ) ),
                    "\n");
      fi;

      # For each loaded package, print name and version number.
      if GAPInfo.PackagesLoaded <> rec() then
        print_info( " Packages:   ",
                    List( SortedList( RecNames( GAPInfo.PackagesLoaded ) ),
                          name -> Concatenation(
                                      GAPInfo.PackagesLoaded.( name )[3], " ",
                                      GAPInfo.PackagesLoaded.( name )[2] ) ),
                    "\n" );
      fi;

      Print( " Try '?help' for help. See also  '?copyright' and  '?authors'",
             "\n" );
    fi;
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
HELP_ADD_BOOK("Changes", "Changes from Earlier Versions", "doc/changes");
HELP_ADD_BOOK("HPC-GAP", "HPC-GAP Shared Memory Extensions and MPI", "doc/hpc");


#############################################################################
##
##  MPIGAP loading 
##
if IsBoundGlobal("MPI_Initialized") then
  ReadLib("distributed/distgap.g");
fi;


#############################################################################
##
##  Read init files, run a shell, and do exit-time processing.
##
InstallAndCallPostRestore( function()
    local i, status;
    for i in [1..Length(GAPInfo.InitFiles)] do
        status := READ_NORECOVERY(GAPInfo.InitFiles[i]);
        if status = fail then
            PRINT_TO( "*errout*", "Reading file \"", GAPInfo.InitFiles[i],
                "\" has been aborted.\n");
            if i < Length (GAPInfo.InitFiles) then
                PRINT_TO( "*errout*",
                    "The remaining files on the command line will not be read.\n" );
            fi;
            break;
        elif status = false then
            PRINT_TO( "*errout*", 
                "Could not read file \"", GAPInfo.InitFiles[i],"\".\n" );
        fi;
    od;
end );

if IsBoundGlobal("MPI_Initialized") and MPI_Comm_rank() <> 0 then
  WaitThread(TaskManager);
  WaitThread(MessageManager);
  MPI_Finalize();
else
  if THREAD_UI() then
    ReadLib("hpc/consoleui.g");
    MULTI_SESSION();
  else
    SESSION();
  fi; 
fi;

PROGRAM_CLEAN_UP();


#############################################################################
##
#E
