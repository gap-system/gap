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
        res := CallFuncList( Read, arg );
    else
        CallFuncList( Read, arg );
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
BIND_GLOBAL("RereadLib",RereadAndCheckFunc("lib"));


#############################################################################
##
#F  RereadGrp( <name> ) . . . . . . . . . . . . . . . . . . group library files
##
BIND_GLOBAL("RereadGrp",RereadAndCheckFunc("grp"));


#############################################################################
##
#F  RereadTbl( <name> ) . . . . . . . . . . . . . . . .  character tables files
##
BIND_GLOBAL("RereadTbl",RereadAndCheckFunc("tbl"));


#############################################################################
##
#F  RereadTom( <name> ) . . . . . . . . . . . . . . . . .  table of marks files
##
BIND_GLOBAL("RereadTom",RereadAndCheckFunc("tom"));


#############################################################################
##
#F  RereadSmall( <name> ) . . . . . . . . . . . . .  small groups library files
##
BIND_GLOBAL("RereadSmall",RereadAndCheckFunc("small"));


#############################################################################
##
#F  RereadPrim( <name> )  . . . . . . . . . primitive perm groups library files
##
BIND_GLOBAL("RereadPrim",RereadAndCheckFunc("prim"));


#############################################################################
##
#F  RereadTrans( <name> ) . . . . . . . .  transitive perm groups library files
##
BIND_GLOBAL("RereadTrans",RereadAndCheckFunc("trans"));
    

#############################################################################
##
#F  DoRereadPkg( <name> ) . . . . . . . . . . . . . . . . . . . package files
##
BIND_GLOBAL( "DoRereadPkg", RereadAndCheckFunc( "pkg" ) );
    

#############################################################################
##
#E

