#############################################################################
##
#W  init.g                      GAP library                     Thomas Breuer
#W                                                             & Frank Celler
#W                                                         & Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file initializes GAP.
##
Revision.init_g :=
    "@(#)$Id$";


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


#############################################################################
##
#F  ReplacedString( <string>, <old>, <new> )
##
##  This cannot be inside "kernel.g" because it is needed to read "kernel.g".
##
ReplacedString := function ( string, old, new )
    local  res,  i,  k,  l;
    res := [];
    k := 1;
    l := false;
    for i  in [1..LEN_LIST(string)]  do
        if string{[i..i+LEN_LIST(old)-1]} = old  then
            l := i;
        fi;
        if string[i] = ';'  then
            if l <> false  then
                APPEND_LIST_INTR( res, string{[k..l-1]} );
                APPEND_LIST_INTR( res, new );
                APPEND_LIST_INTR( res, string{[l+LEN_LIST(old)..i]} );
            else
                APPEND_LIST_INTR( res, string{[k..i]} );
            fi;
            k := i + 1;
            l := false;
        fi;
    od;
    if l <> false  then
        APPEND_LIST_INTR( res, string{[k..l-1]} );
        APPEND_LIST_INTR( res, new );
        APPEND_LIST_INTR( res, string{[l+LEN_LIST(old)..LEN_LIST(string)]} );
    else
        APPEND_LIST_INTR( res, string{[k..LEN_LIST(string)]} );
    fi;
    return res;
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
#F  ReadAndCheckFunc( <path> )  . . . . . .  create a read and check function
##
##  'ReadAndCheckFunc' creates a function that  reads in a file named <name>,
##  this  name  must   include an extension.     The file  must  also  define
##  'Revision.<name_ext>'.
##
READED_FILES := [];

ReadAndCheckFunc := function( path )

    return function( name )
        local    ext,  libname;

        libname := SHALLOW_COPY_OBJ(path);
        APPEND_LIST_INTR( libname, "/" );
        APPEND_LIST_INTR( libname, name );
        ADD_LIST( READED_FILES, libname );
        if not READ_GAP_ROOT(libname)  then
            Error("the library file '",name,"' must exist and be readable");
        fi;
        ext := ReplacedString( name, ".", "_" );
        if not IsBound(Revision.(ext))  then
            Print( "#W  revision entry missing in \"", name, "\"\n" );
        fi;
    end;

end;


#############################################################################
##
#F  ReadOrComplete( <name> )  . . . . . . . . . . . . read file or completion
##
COMPLETABLE_FILES := [];

RANK_FILTER_LIST       := [];
RANK_FILTER_COUNT      := 0;
RANK_FILTER_COMPLETION := Error;	# defined in "filter.g"
RANK_FILTER_STORE      := Error;	# defined in "filter.g"
RANK_FILTER            := Error;	# defined in "filter.g"
RankFilter             := Error;        # defined in "filter.g"


ReadOrComplete := function( name )
    local   comp,  check;

    READED_FILES := [];

    # use completion files
    if CHECK_FOR_COMP_FILES  then
        comp := ReplacedString( name, "read", "comp" );

        # do not check installation and use cached ranks
        check := CHECK_INSTALL_METHOD;
        CHECK_INSTALL_METHOD := false;
        RankFilter := RANK_FILTER_COMPLETION;
        RANK_FILTER_COUNT := 1;

        # check for the completion file
        if not READ_GAP_ROOT(comp)  then

            # read the original file
            CHECK_INSTALL_METHOD := check;
            RankFilter := RANK_FILTER_STORE;
            RANK_FILTER_LIST := [];
            InfoRead1( "#I  reading ", name, "\n" );
            if not READ_GAP_ROOT(name)  then
                Error( "cannot read or complete file ", name );
            fi;
            ADD_LIST( COMPLETABLE_FILES, 
                      [ name, READED_FILES, RANK_FILTER_LIST ] );

            # reset rank
            RANK_FILTER_LIST := [];
            RANK_FILTER_COUNT := 0;
            RankFilter := RANK_FILTER;

        # file completed
        else
            CHECK_INSTALL_METHOD := check;
            RankFilter := RANK_FILTER;
            InfoRead1( "#I  completed ", name, "\n" );
        fi;
    else

        # hash the ranks
        RankFilter := RANK_FILTER_STORE;
        RANK_FILTER_LIST := [];
        RANK_FILTER_COUNT := 0;
        if not READ_GAP_ROOT(name)  then
            Error( "cannot read file ", name );
        fi;
        ADD_LIST( COMPLETABLE_FILES,
                  [ name, READED_FILES, RANK_FILTER_LIST ] );    
        RANK_FILTER_LIST := [];
    fi;
end;


#############################################################################
##

#F  ReadLib( <name> ) . . . . . . . . . . . . . . . . . . . . . library files
##
ReadLib := ReadAndCheckFunc("lib");


#############################################################################
##
#F  ReadGrp( <name> ) . . . . . . . . . . . . . . . . . . group library files
##
ReadGrp := ReadAndCheckFunc("grp");


#############################################################################
##
#F  ReadTbl( <name> ) . . . . . . . . . . . . . . . .  character tables files
##
ReadTbl := ReadAndCheckFunc("tbl");


#############################################################################
##
#F  ReadSmall( <name> ) . . . . . . . . . . . . .  small groups library files
##
ReadSmall := ReadAndCheckFunc("small");


#############################################################################
##
#F  ReadIdLib( <name> ) . . . . . . . . . . . . .  small groups library files
##
ReadIdLib := ReadAndCheckFunc("small/idlib");


#############################################################################
##
#F  ReadPrim( <name> )  . . . . . . . . . primitive perm groups library files
##
ReadPrim := ReadAndCheckFunc("prim");


#############################################################################
##
#F  ReadTrans( <name> ) . . . . . . . .  transitive perm groups library files
##
ReadTrans := ReadAndCheckFunc("trans");


#############################################################################
##

#F  Banner  . . . . . . . . . . . . . . . . . . . . . . . print a nice banner
##
if not QUIET and BANNER then
ReadGapRoot( "lib/version.g" );
P := function(a) Print( a, "\n" );  end;

P("");
P("ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA");
P("");
P("This is  an ALPHA version  of GAP 4.  Please  do not  redistribute this");
P("version, discuss it  in the  GAP forum,  or use  it  for more  than two");
P("weeks.  You can get a new version from");
P("");
P("                ftp://ftp.math.rwth-aachen.de");
P("");
P("Please report bugs and problems to");
P("");
P("                  gap4@Math.RWTH-Aachen.DE");
P("");
P("quoting the Version and Date below and the machine, operation system,");
P("and compiler used.");
P("");
P("ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA");
P("");
Print("Version:  ", VERSION, "\n");
Print("Date:     ", DATE, "\n");
P("");
P("ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA ALPHA");
P("");
P("Loading the library, please be patient this may take a while.");
P("");
fi;


#############################################################################
##
#X  read in the files
##

# inner functions, needed in the kernel
ReadGapRoot( "lib/read1.g" );
ExportToKernelFinished();

ReadOrComplete( "lib/read2.g" );
ReadOrComplete( "lib/read3.g" );

# help system, profiling
ReadOrComplete( "lib/read4.g" );

#T  1996/09/01 M.Schoenert this helps performance
IMPLICATIONS:=IMPLICATIONS{[Length(IMPLICATIONS),Length(IMPLICATIONS)-1..1]};
HIDDEN_IMPS:=HIDDEN_IMPS{[Length(HIDDEN_IMPS),Length(HIDDEN_IMPS)-1..1]};

ReadOrComplete( "lib/read5.g" );
ReadOrComplete( "lib/read6.g" );

# character theory stuff
ReadOrComplete( "lib/read7.g" );

# overloaded operations
ReadOrComplete( "lib/read8.g" );


#############################################################################
##

#E  init.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
