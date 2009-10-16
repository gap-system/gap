#############################################################################
##
#W  system.g                   GAP Library                   Alexander Hulpke
##
#H  @(#)$Id: system.g,v 4.32 2009/08/12 12:05:31 gap Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains functions that are architecture dependent,
##  and the record `GAPInfo', which collects global variables that are needed
##  internally.
##
Revision.system_g :=
    "@(#)$Id: system.g,v 4.32 2009/08/12 12:05:31 gap Exp $";



BIND_GLOBAL( "GAPInfo", rec(

# do not edit the following two lines. They get replaced by string matching
# in the distribution wrapper scripts. (Occurrences of `4.dev' and `today'
        # get replaced.)    
    Version := "4.dev",
    Date := "today",
    KernelInfo := KERNEL_INFO(),    
        
    # The kernel version numbers are expected in the format `<v>.<r>.<p>'.
    KernelVersion := ~.KernelInfo.KERNEL_VERSION,
    NeedKernelVersion := "4.5",

    Architecture := ~.KernelInfo.GAP_ARCHITECTURE,

    # Without the needed packages, GAP does not start.
    # The suggested packages are loaded if available when GAP is started.
    Dependencies := rec(
      NeededOtherPackages := [
      ],
      SuggestedOtherPackages := [
        [ "gapdoc", ">= 1.2" ],
        [ "ctbllib", ">= 1.0" ],
        [ "tomlib", ">= 1.0" ],
      ],
    ),

    # The exact command line which called GAP as list of strings;
    # first entry is the executable followed by the options.
    SystemCommandLine := ~.KernelInfo.COMMAND_LINE,

    # The shell environment in which GAP was called as record
    SystemEnvironment := ~.KernelInfo.ENVIRONMENT,
                    
    # paths
    RootPaths := ~.KernelInfo.GAP_ROOT_PATHS,
    UserHome := ~.SystemEnvironment.HOME,
                          # gaprc := GAP_RC_FILE, work this out later
    
    DirectoriesLibrary := rec(),
    # DirectoriesSystemPrograms := DIRECTORIES_SYSTEM_PROGRAMS, and this
    DirectoriesPrograms := false,
    DirectoriesTemporary := [],
    DirectoryCurrent := false,

    # Shall the file `lib/obsolete.g' be read upon initialization?
    # (This can be changed in the user's `.gaprc' file.)
    ReadObsolete := true,

    # the command line options that were given for the current session
    CommandLineOptions := rec(),

    # the banner that is printed if no `-b' or `-q' option was given
    BannerString := "\
    \n\
            #########           ######         ###########           ###  \n\
         #############          ######         ############         ####  \n\
        ##############         ########        #############       #####  \n\
       ###############         ########        #####   ######      #####  \n\
      ######         #         #########       #####    #####     ######  \n\
     ######                   ##########       #####    #####    #######  \n\
     #####                    ##### ####       #####   ######   ########  \n\
     ####                    #####  #####      #############   ###  ####  \n\
     #####     #######       ####    ####      ###########    ####  ####  \n\
     #####     #######      #####    #####     ######        ####   ####  \n\
     #####     #######      #####    #####     #####         #############\n\
      #####      #####     ################    #####         #############\n\
      ######     #####     ################    #####         #############\n\
      ################    ##################   #####                ####  \n\
       ###############    #####        #####   #####                ####  \n\
         #############    #####        #####   #####                ####  \n\
          #########      #####          #####  #####                ####  \n\
                                                                          \n\
     Information at:  http://www.gap-system.org\n\
     Try '?help' for help. See also  '?copyright' and  '?authors'\n\
    \n",

    # This holds the maximal number of lines that are reasonably printed
    # in `ViewObj' methods.
#T The value can be changed using the function `ViewLength' that is defined
#T in `lib/oper.g' but currently is undocumented.
#T Should it become documented or is it sufficient to document this variable?
    ViewLength := 3,

    # the maximal number of arguments a method can have
    MaxNrArgsMethod:= 6,
                          ) );


GAPInfo.DirectoriesSystemPrograms := [];
GAPInfo.MakeDSP := function()    
    local   j,  i;
    j := 1;
    for i in [1..LENGTH(GAPInfo.SystemEnvironment.PATH)] do
        if GAPInfo.SystemEnvironment.PATH[i] = ':' then
            if i > j then
                ADD_LIST_DEFAULT(GAPInfo.DirectoriesSystemPrograms, 
                        GAPInfo.SystemEnvironment.PATH{[j..i-1]});
            fi;
            j := i+1;
        fi;
    od;
    if j <= LENGTH(GAPInfo.SystemEnvironment.PATH) then
        ADD_LIST_DEFAULT(GAPInfo.DirectoriesSystemPrograms, 
                GAPInfo.SystemEnvironment.PATH{[j..LENGTH(GAPInfo.SystemEnvironment.PATH)]});
    fi;
end;

GAPInfo.MakeDSP();
Unbind(GAPInfo.MakeDSP);

GAPInfo.CommandLineOptionData := rec(
                                     A := rec(type := "toggle", default := false),
                                     B := rec(type := "string", default := ""),
                                     D := rec(type := "toggle", default := false),
                                     E := rec(type := "toggle", default := false),
                                     K := rec(type := "string", default := "0"),
                                     L := rec(type := "string", default := ""),
                                     M := rec(type := "toggle", default := false),
                                     N := rec(type := "toggle", default := false),
                                     O := rec(type := "toggle", default := false),
                                     P := rec(type := "string", default := "0"),
                                     U := rec(type := "string", default := ""),
                                     W := rec(type := "string", default := "0"),
                                     R := rec(type := "string", default := ""),
                                     T := rec(type := "toggle", default := false),
                                     X := rec(type := "toggle", default := false),
                                     Y := rec(type := "toggle", default := false),
                                     a := rec(type := "string", default := "0"),
                                     b := rec(type := "toggle", default := false),
                                     c := rec(type := "string", default := "0"),
                                     e := rec(type := "toggle", default := false),
                                     f := rec(type := "toggle", default := false),
                                     g := rec(type := "modul3", default := 0),
                                     h := rec(type := "toggle", default := false),
                                     i := rec(type := "string", default := ""),
                                     l := rec(type := "strlst", default := []),
                                     m := rec(type := "string", default := "128m"),
                                     n := rec(type := "toggle", default := false),
                                     o := rec(type := "string", default := "1g"),
                                     p := rec(type := "toggle", default := false),
                                     q := rec(type := "toggle", default := false),
                                     r := rec(type := "toggle", default := false),
                                     s := rec(type := "string", default := "0k"),
                                     x := rec(type := "string", default := ""),
                                     y := rec(type := "string", default := ""),
                                     z := rec(type := "string", default := "20"));

for opt in REC_NAMES(GAPInfo.CommandLineOptionData) do
    GAPInfo.CommandLineOptions.(opt) := GAPInfo.CommandLineOptionData.(opt).default;
od;

GAPInfo.InitFiles := [];

GAPInfo.ScanCommandLine := function(line)
    local   i,  word,  r, opt;
    i := 2;
    while i <= LENGTH(line) do
        word := line[i];
        i := i+1;
        if word[1] = '-' and LENGTH(word) = 2 then
            opt := word{[2]};
            if not IsBound(GAPInfo.CommandLineOptionData.(opt)) then
                PRINT_TO("*errout*","Unrecognised command line option: ",
                         word,"\n");
            else
                r := GAPInfo.CommandLineOptionData.(opt);
                GAPInfo.CommandLineOptions.(opt) := r.default;
                if r.type = "toggle" then
                    GAPInfo.CommandLineOptions.(opt) := not GAPInfo.CommandLineOptions.(opt);
                elif r.type = "string" then
                    GAPInfo.CommandLineOptions.(opt) := line[i];
                    i := i+1;
                elif r.type = "strlst" then
                    ADD_LIST_DEFAULT(GAPInfo.CommandLineOptions.(opt), line[i]);
                    i := i+1;
                elif r.type = "modul3" then
                    GAPInfo.CommandLineOptions.(opt) := (GAPInfo.CommandLineOptions.(opt) + 1) mod 3;
                fi;
            fi;
        else
            ADD_LIST_DEFAULT(GAPInfo.InitFiles, word);
        fi;
    od;
end;

GAPInfo.ScanCommandLine(GAPInfo.KernelInfo.COMMAND_LINE);

if GAPInfo.CommandLineOptions.h then
    PRINT_TO("*errout*","usage: gap [OPTIONS] [FILES]\n");
    PRINT_TO("*errout*","       run the Groups, Algorithms and Programming system, Version ");
    PRINT_TO("*errout*", GAPInfo.KernelInfo.KERNEL_VERSION);
    PRINT_TO("*errout*","\n");
    PRINT_TO("*errout*","\n");
    
    PRINT_TO("*errout*","  -h          print this help and exit\n");
    PRINT_TO("*errout*","  -b          disable/enable the banner\n");
    PRINT_TO("*errout*","  -q          enable/disable quiet mode\n");
    PRINT_TO("*errout*","  -e          disable/enable quitting on <ctr>-D\n");
    PRINT_TO("*errout*","  -f          force line editing\n");
    PRINT_TO("*errout*","  -n          prevent line editing\n");
    PRINT_TO("*errout*","  -x <num>    set line width\n");
    PRINT_TO("*errout*","  -y <num>    set number of lines\n");

    PRINT_TO("*errout*","\n");
    PRINT_TO("*errout*","  -g          show GASMAN messages (full garbage collections)\n");
    PRINT_TO("*errout*","  -g -g       show GASMAN messages (all garbage collections)\n");
    PRINT_TO("*errout*","  -m <mem>    set the initial workspace size\n");
    PRINT_TO("*errout*","  -o <mem>    set hint for maximal workspace size (GAP may allocate more)\n");
    PRINT_TO("*errout*","  -K <mem>    set maximal workspace size (GAP never allocates more)\n");
    PRINT_TO("*errout*","  -c <mem>    set the cache size value\n");
    PRINT_TO("*errout*","  -a <mem>    set amount to pre-malloc-ate\n");
    PRINT_TO("*errout*","              postfix 'k' = *1024, 'm' = *1024*1024, 'g' = *1024*1024*1024\n");
    
    PRINT_TO("*errout*","\n");
    PRINT_TO("*errout*","  -l <paths>  set the GAP root paths\n");
    PRINT_TO("*errout*","  -r          disable/enable reading of the '.gaprc' file \n");
    PRINT_TO("*errout*","  -A          disable/enable autoloading of GAP packages\n");
    PRINT_TO("*errout*","  -B <name>   current architecture\n");
    PRINT_TO("*errout*","  -D          enable/disable debugging the loading of library files\n");
    PRINT_TO("*errout*","  -M          disable/enable loading of compiled modules\n");
    PRINT_TO("*errout*","  -N          disable/enable check for completion files\n");
    PRINT_TO("*errout*","  -P <mem>    set amount of memory reserved for printing (Mac)\n");
    PRINT_TO("*errout*","  -T          disable/enable break loop\n");
    PRINT_TO("*errout*","  -W <mem>    set amount of memory available for GAP log window (Mac)\n");
    PRINT_TO("*errout*","  -X          enable/disable CRC for comp. files while reading\n");
    PRINT_TO("*errout*","  -Y          enable/disable CRC for comp. files while completing\n");
    PRINT_TO("*errout*","  -i <file>   change the name of the init file\n");
    
    PRINT_TO("*errout*","\n");
    PRINT_TO("*errout*","  -L <file>   restore a saved workspace\n");
    PRINT_TO("*errout*","  -R          prevent restoring of workspace (ignoring -L)\n");
    
    PRINT_TO("*errout*","\n");
    PRINT_TO("*errout*","  -p          enable/disable package output mode\n");
# -C -U undocumented options to the compiler. 
#   Also unadvertisted compatibility flag:
# PRINT_TO("*errout*","  -O          enable/disable old behavior, fail := false\n");


    PRINT_TO("*errout*","  Boolean options (b,q,e,r,A,D,M,N,T,X,Y) toggle the current value\n");
    PRINT_TO("*errout*","  each time they are called. Default actions are indicated first.\n");
    
    PRINT_TO("*errout*","\n");
    QUIT_GAP();
fi;



GAPInfo.SetScreenSize := function()
    local   xy;
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
end;

GAPInfo.SetScreenSize();
Unbind(GAPInfo.SetScreenSize);

for i in [1 .. GAPInfo.CommandLineOptions.g] do
    GASMAN("message");
od;



#############################################################################
##
##  Administration of Packages
##


#############################################################################
##
#V  GAPInfo.PackagesLoaded
##
##  <ManSection>
##  <Var Name="GAPInfo.PackagesLoaded"/>
##
##  <Description>
##  This is a mutable record, the component names are the names of those
##  packages that are already loaded.
##  The component for each package is a list of length three, the entries
##  being the path to the &GAP; root directory that contains the package,
##  the package version, and the package name.
##  For each package, the value gets bound in the <C>LoadPackage</C> call.
##  </Description>
##  </ManSection>
##
GAPInfo.PackagesLoaded := rec();


#############################################################################
##
#V  GAPInfo.PackageLoadingMessages
##
##  ...
##
GAPInfo.PackageLoadingMessages := [];


#############################################################################
##
#V  GAPInfo.PackagesCurrentlyLoaded
##
##  ...
##
GAPInfo.PackagesCurrentlyLoaded := [ "GAP" ];


#############################################################################
##
#V  GAPInfo.PackagesInfo
##
##  <ManSection>
##  <Var Name="GAPInfo.PackagesInfo"/>
##
##  <Description>
##  This is a mutable record, the component names are the names of those
##  packages for which the <F>PackageInfo.g</F> files have been read.
##  (These packages are not necessarily loaded.)
##  </Description>
##  </ManSection>
##
GAPInfo.PackagesInfo := rec();


#############################################################################
##
#V  GAPInfo.TestData
##
##  <ManSection>
##  <Var Name="GAPInfo.TestData"/>
##
##  <Description>
##  This is a mutable record used in files that are read via <C>ReadTest</C>.
##  These files contain the commands <C>START_TEST</C> and <C>STOP_TEST</C>,
##  which set, read, and unbind the components <C>START_TIME</C> and <C>START_NAME</C>.
##  The function <C>RunStandardTests</C> also uses a component <C>results</C>.
##  </Description>
##  </ManSection>
##
GAPInfo.TestData:= rec();


#############################################################################
##
##  Remove globals exported by the kernel that are no longer needed.
#T wouldn't it be better to create the record `GAPInfo' with these components
#T in the kernel?
##

for name in [ 
        
#        "KERNEL_VERSION", "GAP_ARCHITECTURE", "GAP_ROOT_PATHS",
#              "USER_HOME", "GAP_RC_FILE", "DIRECTORIES_SYSTEM_PROGRAMS",
        
        "DEBUG_LOADING" ] do
  MAKE_READ_WRITE_GLOBAL( name );
  UNBIND_GLOBAL( name );
od;


#############################################################################
##
##  identifier that will recognize the Windows and the Mac version
##
BIND_GLOBAL("WINDOWS_ARCHITECTURE",
  IMMUTABLE_COPY_OBJ("win"));
BIND_GLOBAL("MACINTOSH_68K_ARCHITECTURE",
  IMMUTABLE_COPY_OBJ("MC68020-motorola-macos-mwerksc"));
BIND_GLOBAL("MACINTOSH_PPC_ARCHITECTURE",
  IMMUTABLE_COPY_OBJ("PPC-motorola-macos-mwerksc"));

#T the following functions eventually should be more clever. This however
#T will require kernel support and thus is something for later.  AH

#############################################################################
##
#F  ARCH_IS_MAC()
##
##  <#GAPDoc Label="ARCH_IS_MAC">
##  <ManSection>
##  <Func Name="ARCH_IS_MAC" Arg=''/>
##
##  <Description>
##  tests whether &GAP; is running on a Macintosh under MacOS
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ARCH_IS_MAC",function()
  return GAPInfo.Architecture = MACINTOSH_68K_ARCHITECTURE
      or GAPInfo.Architecture = MACINTOSH_PPC_ARCHITECTURE;
end);

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
local l;
  l:=LEN_LIST( GAPInfo.Architecture );
  if l<9 then return false;fi; # trap some unixes with incredibly short
                               # string name
  return GAPInfo.Architecture{[l-6..l-4]} = WINDOWS_ARCHITECTURE;
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
##  tests whether &GAP; is running on a UNIX system.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ARCH_IS_UNIX",function()
  return not (ARCH_IS_MAC() or ARCH_IS_WINDOWS());
end);

#############################################################################
##
#V  GAPInfo.gaprc
##
if ARCH_IS_UNIX() then
    GAPInfo.gaprc := SHALLOW_COPY_OBJ(GAPInfo.UserHome);
    APPEND_LIST_INTR(GAPInfo.gaprc, "/.gaprc");
else
    GAPInfo.gaprc := "gap.rc";
fi;

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
##  <C>GAPInfo.BytesPerVariable</C> is the number of bytes used for one <C>Obj</C>
##  variable.
##  </Description>
##  </ManSection>
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
#V  GAPInfo.InitFiles
#V  GAPInfo.CommandLineArguments
##
##  <ManSection>
##  <Var Name="GAPInfo.InitFiles"/>
##  <Var Name="GAPInfo.CommandLineArguments"/>
##
##  <Description>
##  <C>GAPInfo.InitFiles</C> is a list of strings containing the filenames
##  specified on the command line to be read initially.
##  <P/>
##  <C>GAPInfo.CommandLineArguments</C> is a single string containing all
##  the options and arguments passed to GAP at runtime (although not
##  necessarily in the original order).
##  </Description>
##  </ManSection>
##

AT_EXIT_FUNCS := [];


#############################################################################
##
#E

