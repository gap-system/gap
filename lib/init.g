#############################################################################
##
#W  init.g                      GAP library                  Martin Schoenert
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

#F  Ignore( <arg> )
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

#F  Read( <name> )  . . . . . . . . . . . . . . . . read in file named <name>
##
READ_INDENT := "";

if DEBUG_LOADING           then InfoRead1 := Print;   fi;
if not IsBound(InfoRead1)  then InfoRead1 := Ignore;  fi;
if not IsBound(InfoRead2)  then InfoRead2 := Ignore;  fi;

Read := function ( name )
    local   readIndent,  found;

    readIndent := SHALLOW_COPY_OBJ( READ_INDENT );
    APPEND_LIST_INTR( READ_INDENT, "  " );
    InfoRead1( "#I", READ_INDENT, "Read( \"", name, "\" )\n" );
    found := READ(name);
    READ_INDENT := readIndent;
    if found and READ_INDENT = ""  then
        InfoRead1( "#I  Read( \"", name, "\" ) done\n" );
    fi;
    if not found  then
        Error( "file \"", name, "\" must exist and be readable" );
    fi;
    #return found;
end;


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
READED_FILES := [];

ReadAndCheckFunc := function( path )

    return function( name )
        local    ext,  libname;

        libname := SHALLOW_COPY_OBJ(path);
        APPEND_LIST_INTR( libname, "/" );
        APPEND_LIST_INTR( libname, name );
        if not READ_GAP_ROOT(libname)  then
            Error("the library file '",name,"' must exist and be readable");
        fi;
        ADD_LIST( READED_FILES, libname );
        ext := ReplacedString( name, ".", "_" );
        if not IsBound(Revision.(ext))  then
            Print( "#W  revision entry missing in \"", name, "\"\n" );
        fi;
    end;

end;


#############################################################################
##
#F  ReadLib( <name> )
##
##  'ReadLib'  reads  in a  file  named  <name>,  this  name must include  an
##  extension.  The file must also define 'Revision.<name_ext>'.
##
ReadLib := ReadAndCheckFunc("lib");


#############################################################################
##
#F  ReadGrp( <name> )
##
ReadGrp := ReadAndCheckFunc("grp");


#############################################################################
##
#F  ReadTbl( <name> )
##
ReadTbl := ReadAndCheckFunc("tbl");


#############################################################################
##
#F  ReadSmall( <name> )
##
ReadSmall := ReadAndCheckFunc("small");


#############################################################################
##
#F  ReadPrim( <name> )
##
ReadPrim := ReadAndCheckFunc("prim");


#############################################################################
##
#F  ReadTrans( <name> )
##
ReadTrans := ReadAndCheckFunc("trans");


#############################################################################
##
#F  ReadOrComplete( <name> )  . . . . . . . . . . . . read file or completion
##
COMPLETABLE_FILES := [];

ReadOrComplete := function( name )
    local   comp;

    READED_FILES := [];
    if CHECK_FOR_COMP_FILES  then
        comp := ReplacedString( name, "read", "comp" );
        if not READ_GAP_ROOT(comp)  then
            InfoRead1( "#I  reading ", name, "\n" );
            if not READ_GAP_ROOT(name)  then
                Error( "cannot read or complete file ", name );
            fi;
            ADD_LIST( COMPLETABLE_FILES, [ name, READED_FILES ] );
        else
            InfoRead1( "#I  completed ", name, "\n" );
        fi;
    else
        if not READ_GAP_ROOT(name)  then
            Error( "cannot read file ", name );
        fi;
        ADD_LIST( COMPLETABLE_FILES, [ name, READED_FILES ] );    
    fi;
end;


#############################################################################
##
#F  CreateCompletionFiles( <path> ) . . . . . . .  create "lib/compx.g" files
##
CreateCompletionFiles := function( path )
    local   i,  com,  j,  tmp;

    for i  in COMPLETABLE_FILES  do
        com := SHALLOW_COPY_OBJ(path);
        APPEND_LIST_INTR( com, ReplacedString( i[1], "read", "comp" ) );
        Print( "#I  converting \"", i[1], "\" to \"", com, "\"\n" );
        for j  in i[2]  do
            Print( "#I    parsing \"", j, "\"\n" );
        od;
        tmp := [ com ];
        APPEND_LIST_INTR( tmp, i[2] );

        # the names should be relative to 'GapRootDirectory'
        CALL_FUNC_LIST( MAKE_INIT, tmp );
    od;
end;


#############################################################################
##

#F  Banner
##
if not QUIET and BANNER then
READ_GAP_ROOT( "lib/version.g" );
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
ReadOrComplete( "lib/read1.g" );
ExportToKernelFinished();

ReadOrComplete( "lib/read2.g" );
ReadOrComplete( "lib/read3.g" );
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
