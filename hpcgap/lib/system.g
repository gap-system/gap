#############################################################################
##
#W  system.g                   GAP Library                   Alexander Hulpke
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains functions that are architecture dependent,
##  and the record `GAPInfo', which collects global variables that are needed
##  internally.
##
##  `GAPInfo' is initialized when GAP is started without a workspace,
##  and various components are added and modified later on.
##  When GAP is started with a workspace, the value of `GAPInfo' is kept,
##  just some dedicated components are modified via the
##  ``post restore functions'' mechanism.
##

BIND_GLOBAL( "GAPInfo", AtomicRecord(rec(

# do not edit the following three lines. Occurences of `4.dev' and `today'
# will be replaced by string matching by distribution wrapping scripts.
    Version := MakeImmutable("4.dev"),
    Date := MakeImmutable("today"),
    NeedKernelVersion := MakeImmutable("4.dev"),

# Without the needed packages, GAP does not start.
    Dependencies := rec(
      NeededOtherPackages := `[
        [ "gapdoc", ">= 1.2" ],
        [ "primgrp", ">= 3.1.0" ],
        [ "smallgrp", ">= 1.0" ],
        [ "transgrp", ">= 1.0" ],
      ],
    ),
# There is no SuggestedOtherPackages here because the default value of
# the user preference PackagesToLoad does the job      

    HasReadGAPRC:= false,

    # list of all reserved keywords
    Keywords:=MakeImmutable(ALL_KEYWORDS()),

    # the maximal number of arguments a method can have
    MaxNrArgsMethod:= 6,

    # caches of functions that are needed also with a workspace
    AtExitFuncs:= AtomicList([]),
    PostRestoreFuncs:= AtomicList([]),

    TestData:= ThreadLocalRecord( rec() ),

    # admissible command line options
    # (name of the option, default value, descr. strings for help page;
    # if no help string appears then option is not advertised in the help)
    # These options must be kept in sync with those in system.c, so the help output
    # for those options is correct
    CommandLineOptionData := `[
      rec( short:= "S", default := false, help := ["disable/enable multi-threaded interface"] ),
      rec( short:= "P", default := "0", arg := "<num>", help := ["set number of logical processors"] ),
      rec( short:= "G", default := "0", arg := "<num>", help := ["set number of GC threads"] ),
      rec( short:= "Z", default := false, help := ["enforce ordering of region locks"] ),
      rec( short:= "h", long := "help", default := false, help := ["print this help and exit"] ),
      rec( short:= "b", long := "banner", default := false, help := ["disable/enable the banner"] ),
      rec( short:= "q", long := "quiet", default := false, help := ["enable/disable quiet mode"] ),
      rec( short:= "e", default := false, help := ["disable/enable quitting on <ctr>-D"] ),
      rec( short:= "f", default := false, help := ["force line editing"] ),
      rec( short:= "n", default := false, help := ["prevent line editing"] ),
      rec( short:= "E", long := "readline", default := true,
           help := ["disable/enable use of readline library (if", "possible)"] ),
      rec( short:= "x", long := "width", default := "", arg := "<num>", help := ["set line width"] ),
      rec( short:= "y", long := "lines", default := "", arg := "<num>", help := ["set number of lines"] ),
      ,
      rec( short:= "g", long := "gasinfo", default := 0,
           help := ["show GASMAN messages (full/all/no garbage","collections)"] ),
      rec( short:= "m", long := "minworkspace", default := "128m", arg := "<mem>",
           help := ["set the initial workspace size"] ),
      rec( short:= "o", long := "maxworkspace", default := "2g", arg := "<mem>",
           help := [ "set hint for maximal workspace size (GAP may", "allocate more)"] ),
      rec( short:= "K", long := "limitworkspace", default := "0", arg := "<mem>",
           help := [ "set maximal workspace size (GAP never", "allocates more)"] ),
      rec( short:= "s", default := "4g", arg := "<mem", help := [ "set the initially mapped virtual memory" ] ),
      rec( short:= "a", default := "0",  arg := "<mem>",help := [ "set amount to pre-malloc-ate",
             "postfix 'k' = *1024, 'm' = *1024*1024,", "'g' = *1024*1024*1024"] ),
      ,
      rec( short:= "l", long := "roots", default := [], arg := "<paths>",
           help := [ "set the GAP root paths",
                     "Directories are separated using ';'.",
                     "Putting ';' on the start/end of list appends",
                     "directories to the end/start of existing list",
                     "of root paths" ] ),
      rec( short:= "r", default := false, help := ["disable/enable user GAP root dir", "GAPInfo.UserGapRoot"] ),
      rec( short:= "A", default := false, help := ["disable/enable autoloading of suggested", "GAP packages"] ),
      rec( short:= "B", default := "",    arg := "<name>", help := [ "current architecture"] ),
      rec( short:= "D", default := false, help := ["enable/disable debugging the loading of files"] ),
      rec( short:= "M", default := false, help := ["disable/enable loading of compiled modules"] ),
      rec( short:= "N", default := false, help := ["unused, for backward compatibility only"] ),
      rec( short:= "O", default := false, help := ["disable/enable loading of obsolete files"] ),
      rec( short:= "T", default := false, help := ["disable/enable break loop"] ),
      rec( long := "quitonbreak", default := false, help := ["quit GAP with non-zero return value instead of entering break loop"]),
      ,
      rec( short:= "L", default := "", arg := "<file>", help := [ "restore a saved workspace"] ),
      rec( short:= "R", default := false, help := ["prevent restoring of workspace (ignoring -L)"] ),
      ,
      rec( short:= "p", default := false, help := ["enable/disable package output mode"] ),
      rec( short := "E", default :=false ),
      rec( short := "s", default := "4g" ),
      rec( short := "z", default := "20" ),
      rec( long := "prof", default := "", arg := "<file>",
           help := [ "Run ProfileLineByLine(<filename>) on GAP start"] ),
      rec( long := "memprof", default := "", arg := "<file>",
           help := [ "Run ProfileLineByLine(<filename>) with recordMem := true on GAP start"] ),
      rec( long := "cover", default := "", arg := "<file>",
           help := [ "Run CoverageLineByLine(<filename>) on GAP start"] ),
          ],
    ) ));


#############################################################################
##
#V  GAPInfo.BytesPerVariable
#V  DOUBLE_OBJLEN
##
##  <ManSection>
##  <Var Name="GAPInfo.BytesPerVariable"/>
##  <Var Name="DOUBLE_OBJLEN"/>
##
##  <Description>
##  <Ref Var="GAPInfo.BytesPerVariable"/> is the number of bytes used for one
##  <C>Obj</C> variable.
##  </Description>
##  </ManSection>
##
##  These variables need not be recomputed when a workspace is loaded.
##
GAPInfo.BytesPerVariable := 4;
# are we a 64 (or more) bit system?
while TNUM_OBJ( 2^((GAPInfo.BytesPerVariable-1)*8) )
    = TNUM_OBJ( 2^((GAPInfo.BytesPerVariable+1)*8) ) do
  GAPInfo.BytesPerVariable:= GAPInfo.BytesPerVariable + 4;
od;
BIND_GLOBAL( "DOUBLE_OBJLEN", 2*GAPInfo.BytesPerVariable );


#############################################################################
##
#F  CallAndInstallPostRestore( <func> )
##
##  The argument <func> must be a function with no argument.
##  This function is called,
##  and it is added to the global list `GAPInfo.PostRestoreFuncs'.
##  The effect of the latter is that the function will be called
##  when GAP is started with a workspace (option `-L').
##
BIND_GLOBAL( "CallAndInstallPostRestore", function( func )
    if not IS_FUNCTION( func )  then
      Error( "<func> must be a function" );
    elif CHECK_INSTALL_METHOD and not NARG_FUNC( func ) in [ -1, 0 ] then
      Error( "<func> must accept zero arguments" );
    fi;

    func();

    ADD_LIST( GAPInfo.PostRestoreFuncs, func );
end );


#############################################################################
##
#F  InstallAndCallPostRestore( <func> )
##
##  The argument <func> must be a function with no argument.
##  This function is added to the global list `GAPInfo.PostRestoreFuncs',
##  and afterwards it is called.
##  The effect of the former is that the function will be called
##  when GAP is started with a workspace (option `-L').
##
BIND_GLOBAL( "InstallAndCallPostRestore", function( func )
    if not IS_FUNCTION( func )  then
      Error( "<func> must be a function" );
    elif CHECK_INSTALL_METHOD and not NARG_FUNC( func ) in [ -1, 0 ] then
      Error( "<func> must accept zero arguments" );
    fi;

    ADD_LIST( GAPInfo.PostRestoreFuncs, func );

    func();
end );


#########################################################################
# For backwards compatability, we make the canonical version of an option
# its short version if it exists.
#
# Set up a map to tell us the canonical name of any command line option
GAPInfo.CommandLineOptionCanonicalName := rec();
CallAndInstallPostRestore( function()
  local option;
  for option in GAPInfo.CommandLineOptionData do
    if IsBound(option.short) then
      GAPInfo.CommandLineOptionCanonicalName.(option.short) := option.short;
      if IsBound(option.long) then
        GAPInfo.CommandLineOptionCanonicalName.(option.long) := option.short;
      fi;
    else
        GAPInfo.CommandLineOptionCanonicalName.(option.long) := option.long;
    fi;
  od;
end);

#############################################################################
##
##  - Set/adjust the kernel specific components.
##  - Compute `GAPInfo.DirectoriesSystemPrograms' from
##    `GAPInfo.SystemEnvironment.PATH'.
##  - Scan the command line.
##    In case of `-h' print a help screen and exit.
##
CallAndInstallPostRestore( function()
    local j, i, CommandLineOptions, CommandLineOptionData,
          opt, InitFiles, line, word, value, padspace;

    GAPInfo.KernelInfo:= KERNEL_INFO();
    GAPInfo.KernelVersion:= GAPInfo.KernelInfo.KERNEL_VERSION;
    GAPInfo.BuildVersion:= GAPInfo.KernelInfo.BUILD_VERSION;
    GAPInfo.BuildDateTime:= GAPInfo.KernelInfo.BUILD_DATETIME;
    GAPInfo.Architecture:= GAPInfo.KernelInfo.GAP_ARCHITECTURE;
    # On 32-bit we have to adjust some values:
    if GAPInfo.BytesPerVariable = 4 then
      CommandLineOptionData := SHALLOW_COPY_OBJ( GAPInfo.CommandLineOptionData );
      i := 1;
      while not(IsBound(GAPInfo.CommandLineOptionData[i])) or
            not(IsBound(GAPInfo.CommandLineOptionData[i].short)) or
            GAPInfo.CommandLineOptionData[i].short <> "m" do i := i + 1; od;
      CommandLineOptionData[i] := SHALLOW_COPY_OBJ( CommandLineOptionData[i] );
      CommandLineOptionData[i].default := "64m";
      i := 1;
      while not(IsBound(GAPInfo.CommandLineOptionData[i])) or
            not(IsBound(GAPInfo.CommandLineOptionData[i].short)) or
            GAPInfo.CommandLineOptionData[i].short <> "o" do i := i + 1; od;
      CommandLineOptionData[i] := SHALLOW_COPY_OBJ( CommandLineOptionData[i] );
      CommandLineOptionData[i].default := "1g";
      i := 1;
      while not(IsBound(GAPInfo.CommandLineOptionData[i])) or
            not(IsBound(GAPInfo.CommandLineOptionData[i].short)) or
            GAPInfo.CommandLineOptionData[i].short <> "s" do i := i + 1; od;
      CommandLineOptionData[i] := SHALLOW_COPY_OBJ( CommandLineOptionData[i] );
      CommandLineOptionData[i].default := "1500m";
    fi;

    # The exact command line which called GAP as list of strings;
    # first entry is the executable followed by the options.
    GAPInfo.SystemCommandLine:= GAPInfo.KernelInfo.COMMAND_LINE;

    # The shell environment in which GAP was called as record
    GAPInfo.SystemEnvironment:= GAPInfo.KernelInfo.ENVIRONMENT;

    # paths
    GAPInfo.RootPaths:= GAPInfo.KernelInfo.GAP_ROOT_PATHS;
    if  IsBound(GAPInfo.SystemEnvironment.HOME) then
      GAPInfo.UserHome := GAPInfo.SystemEnvironment.HOME;
    else
      GAPInfo.UserHome := fail;
    fi;
    if IsBound(GAPInfo.KernelInfo.DOT_GAP_PATH) then
      GAPInfo.UserGapRoot := GAPInfo.KernelInfo.DOT_GAP_PATH;
    else
      GAPInfo.UserGapRoot := fail;
    fi;

    # directory caches
    GAPInfo.DirectoriesLibrary:= AtomicRecord( rec() );
    GAPInfo.DirectoriesPrograms:= false;
    GAPInfo.DirectoriesTemporary:= AtomicList([]);
    GAPInfo.DirectoryCurrent:= false;
    GAPInfo.DirectoriesSystemPrograms:= AtomicList([]);
    if IsBound(GAPInfo.SystemEnvironment.PATH) then
      j:= 1;
      for i in [1..LENGTH(GAPInfo.SystemEnvironment.PATH)] do
        if GAPInfo.SystemEnvironment.PATH[i] = ':' then
          if i > j then
            ADD_LIST_DEFAULT(GAPInfo.DirectoriesSystemPrograms,
                  `GAPInfo.SystemEnvironment.PATH{[j..i-1]});
          fi;
          j := i+1;
        fi;
      od;
      if j <= LENGTH( GAPInfo.SystemEnvironment.PATH ) then
        ADD_LIST_DEFAULT( GAPInfo.DirectoriesSystemPrograms,
            `GAPInfo.SystemEnvironment.PATH{ [ j ..
                LENGTH( GAPInfo.SystemEnvironment.PATH ) ] } );
      fi;
    fi;

    # the command line options that were given for the current session
    CommandLineOptions:= rec();
    for opt in GAPInfo.CommandLineOptionData do
      if IsBound(opt.short) then
        CommandLineOptions.( opt.short ):= SHALLOW_COPY_OBJ( opt.default );
      else
        CommandLineOptions.( opt.long ):= SHALLOW_COPY_OBJ( opt.default );
      fi;
    od;

    InitFiles:= [];

    line:= GAPInfo.SystemCommandLine;
    i:= 2;
    while i <= LENGTH( line ) do
      word:= line[i];
      i:= i+1;
      if word[1] = '-' and (LENGTH( word ) = 2 or word[2] = '-') then
        opt:= word{[2..LENGTH(word)]};
        if opt[1] = '-' then
          opt := opt{[2..LENGTH(opt)]};
        fi;
        if not(IsBound( GAPInfo.CommandLineOptionCanonicalName.( opt ) )) then
          PRINT_TO( "*errout*", "Unrecognised command line option: ",
                      word, "\n" );
        else
          opt := GAPInfo.CommandLineOptionCanonicalName.( opt );
          value:= CommandLineOptions.( opt );
          if IS_BOOL( value ) then
            CommandLineOptions.( opt ):= not CommandLineOptions.( opt );
          elif IS_INT( value ) then
            CommandLineOptions.( opt ):= CommandLineOptions.( opt ) + 1;
          elif i <= LENGTH( line ) then
            if IS_STRING_REP( value ) then
              # string
              CommandLineOptions.( opt ):= line[i];
              i := i+1;
            elif IS_LIST( value ) then
              # list of strings, starting from the empty list
              ADD_LIST_DEFAULT( CommandLineOptions.( opt ), line[i] );
              i := i+1;
            fi;
          else
            PRINT_TO( "*errout*", "Command line option ", word, " needs an argument.\n" );
          fi;
        fi;
      else
        ADD_LIST_DEFAULT( InitFiles, word );
      fi;
    od;
    CommandLineOptions.g:= CommandLineOptions.g mod 3;
    # use the same as the kernel
    CommandLineOptions.E:= GAPInfo.KernelInfo.HAVE_LIBREADLINE;
    MakeImmutable( CommandLineOptions );
    MakeImmutable( InitFiles );

    if CommandLineOptions.L = "" or CommandLineOptions.R then
      # start without a workspace
      GAPInfo.CommandLineOptionsPrev:= [];
      GAPInfo.InitFilesPrev:= [];
    else
      # start with a workspace
      ADD_LIST_DEFAULT( GAPInfo.CommandLineOptionsPrev,
                        GAPInfo.CommandLineOptions );
      ADD_LIST_DEFAULT( GAPInfo.InitFilesPrev, GAPInfo.InitFiles );
    fi;
    GAPInfo.CommandLineOptions:= CommandLineOptions;
    GAPInfo.InitFiles:= InitFiles;

    # Switch on debugging (`-D' option) when GAP is started with a workspace.
    if GAPInfo.CommandLineOptions.D then
      InfoRead1:= Print;
    fi;

    padspace := function(strlen, len)
      local i;
      for i in [strlen+1..len] do
        PRINT_TO("*errout*", " ");
      od;
    end;

    # Evaluate the `-h' option.
    if GAPInfo.CommandLineOptions.h then
      PRINT_TO( "*errout*",
        "usage: gap [OPTIONS] [FILES]\n",
        "       run the Groups, Algorithms and Programming system, Version ",
        GAPInfo.KernelVersion, "\n\n" );

      for i in [ 1 .. LENGTH( GAPInfo.CommandLineOptionData ) ] do
        if IsBound( GAPInfo.CommandLineOptionData[i] ) and
           IsBound( GAPInfo.CommandLineOptionData[i].help ) then
          opt:= GAPInfo.CommandLineOptionData[i];

          # At least one of opt.short or opt.long must be bound
          if(IsBound(opt.short)) then
            PRINT_TO("*errout*", " -", opt.short);
            if(IsBound(opt.long)) then
              PRINT_TO("*errout*", ", --", opt.long);
              padspace(4+LENGTH(opt.long), 16);
            else
              padspace(0, 16);
            fi;
            if(IsBound(opt.arg)) then
              PRINT_TO("*errout*", " ", opt.arg);
              padspace(LENGTH(opt.arg)+1, 8);
            else
              padspace(0, 8);
            fi;
          else
            PRINT_TO("*errout*", "   ");
            # opt.short unbound, opt.long bound

            PRINT_TO("*errout*", "  --", opt.long);
            padspace(4+LENGTH(opt.long), 16);
            if(IsBound(opt.arg)) then
              PRINT_TO("*errout*", " ", opt.arg);
              padspace(LENGTH(opt.arg)+1, 8);
            else
              padspace(0, 8);
            fi;
          fi;
          if IsBound(opt.long) and LENGTH(opt.long) > 12 then
            PRINT_TO("*errout*", "\n");
            padspace(0, 3+16+8+3);
          else
            PRINT_TO("*errout*", "   ");
          fi;

          PRINT_TO("*errout*", opt.help[1], "\n");
          for j in [2..LENGTH(opt.help)] do
            padspace(0, 3+16+8+3);
            PRINT_TO("*errout*", opt.help[j],"\n");
          od;
        else
          if not IsBound(GAPInfo.CommandLineOptionData[i]) then
            PRINT_TO( "*errout*", "\n" );
          fi;
        fi;
      od;

      PRINT_TO("*errout*",
       "  Boolean options (b,q,e,r,A,D,E,M,N,T,X,Y) toggle the current value\n",
       "  each time they are called. Default actions are indicated first.\n",
       "\n" );
      QUIT_GAP();
    fi;
end );


#############################################################################
##
#V  GAPInfo.TestData
##
##  <ManSection>
##  <Var Name="GAPInfo.TestData"/>
##
##  <Description>
##  This is a mutable record used in files that are read via <C>Test</C>.
##  These files contain the commands <C>START_TEST</C> and <C>STOP_TEST</C>,
##  which set, read, and unbind the components <C>START_TIME</C> and <C>START_NAME</C>.
##  The function <C>RunStandardTests</C> also uses a component <C>results</C>.
##  </Description>
##  </ManSection>
##


#T the following functions eventually should be more clever. This however
#T will require kernel support and thus is something for later.  AH

#############################################################################
##
#F  ARCH_IS_WINDOWS()
##
##  <#GAPDoc Label="ARCH_IS_WINDOWS">
##  <ManSection>
##  <Func Name="ARCH_IS_WINDOWS" Arg=''/>
##
##  <Description>
##  tests whether &GAP; is running on a Windows system.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ARCH_IS_WINDOWS",function()
  return POSITION_SUBSTRING (GAPInfo.Architecture, "cygwin", 0) <> fail;
end);

#############################################################################
##
#F  ARCH_IS_MAC_OS_X()
##
##  <#GAPDoc Label="ARCH_IS_MAC_OS_X">
##  <ManSection>
##  <Func Name="ARCH_IS_MAC_OS_X" Arg=''/>
##
##  <Description>
##  tests whether &GAP; is running on Mac OS X. Note that on Mac OS X, also
##  <Ref Func="ARCH_IS_UNIX"/> will be <C>true</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ARCH_IS_MAC_OS_X",function()
  return POSITION_SUBSTRING (GAPInfo.Architecture, "apple-darwin", 0) <> fail
    and IsReadableFile ("/System/Library/CoreServices/Finder.app");
end);

#############################################################################
##
#F  ARCH_IS_UNIX()
##
##  <#GAPDoc Label="ARCH_IS_UNIX">
##  <ManSection>
##  <Func Name="ARCH_IS_UNIX" Arg=''/>
##
##  <Description>
##  tests whether &GAP; is running on a UNIX system (including Mac OS X).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ARCH_IS_UNIX",function()
  return not ARCH_IS_WINDOWS();
end);

#############################################################################
##
#V  GAPInfo.InitFiles
##
##  <ManSection>
##  <Var Name="GAPInfo.InitFiles"/>
##
##  <Description>
##  <C>GAPInfo.InitFiles</C> is a list of strings containing the filenames
##  specified on the command line to be read initially.
##  </Description>
##  </ManSection>
##
#T really ???


#############################################################################
##
#E
