#############################################################################
##
#W  reread.g                   GAP Library                       Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the Reread function and its relatives
##  RereadLib, etc.
##
##  Seems rather little for a file by itself, but I can see no other
##  natural home
##
Revision.reread_g :=
    "@(#)$Id$";

BindGlobal("Reread",
        function(arg)
    local res;
    MakeReadWriteGlobal("REREADING");
    REREADING := true;
    MakeReadOnlyGlobal("REREADING");
    if LEN_LIST(arg) > 1 then
        res := CallFuncList(func,arg);
    else
        CallFuncList(func,arg);
    fi;
    MakeReadWriteGlobal("REREADING");
    REREADING := false;
    MakeReadOnlyGlobal("REREADING");
    if LEN_LIST(arg) > 1 then
        return res;
    fi;
end);


BindGlobal("RereadAndCheckFunc", 
        function( arg )
    local func;
    func := CallFuncList(ReadAndCheckFunc, arg);
    return function( arg )
        local res;
        MakeReadWriteGlobal("REREADING");
        REREADING := true;
        MakeReadOnlyGlobal("REREADING");
        if LEN_LIST(arg) > 1 then
            res := CallFuncList(func,arg);
        else
            CallFuncList(func,arg);
        fi;
        MakeReadWriteGlobal("REREADING");
        REREADING := false;
        MakeReadOnlyGlobal("REREADING");
        if LEN_LIST(arg) > 1 then
            return res;
        fi;
    end;
end);

#############################################################################
##
#F  RereadLib( <name> ) . . . . . . . . . . . . . . . . . . . . . library files
##
RereadLib := RereadAndCheckFunc("lib");


#############################################################################
##
#F  RereadGrp( <name> ) . . . . . . . . . . . . . . . . . . group library files
##
RereadGrp := RereadAndCheckFunc("grp");


#############################################################################
##
#F  RereadTbl( <name> ) . . . . . . . . . . . . . . . .  character tables files
##
RereadTbl := RereadAndCheckFunc("tbl");


#############################################################################
##
#F  RereadTom( <name> ) . . . . . . . . . . . . . . . . .  table of marks files
##
RereadTom := RereadAndCheckFunc("tom");


#############################################################################
##
#F  RereadSmall( <name> ) . . . . . . . . . . . . .  small groups library files
##
RereadSmall := RereadAndCheckFunc("small");


#############################################################################
##
#F  RereadIdLib( <name> ) . . . . . . . . . . . . .  small groups library files
##
RereadIdLib := RereadAndCheckFunc("small/idlib");


#############################################################################
##
#F  RereadPrim( <name> )  . . . . . . . . . primitive perm groups library files
##
RereadPrim := RereadAndCheckFunc("prim");


#############################################################################
##
#F  RereadTrans( <name> ) . . . . . . . .  transitive perm groups library files
##
RereadTrans := RereadAndCheckFunc("trans");




    

#############################################################################
##
#E  reread.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
