#############################################################################
##
#W  reread.g                   GAP Library                       Steve Linton
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the Reread function and its relatives
##  RereadLib, etc.
##
##  Seems rather little for a file by itself, but I can see no other
##  natural home
##


#############################################################################
##
##  <#GAPDoc Label="Reread">
##
##  <ManSection>
##  <Func Name="Reread" Arg='filename'/>
##  <Var Name="REREADING"/>
##
##  <Description>
##  In general, it is not possible to read the same &GAP; library file
##  twice, or to read a compiled version after reading a &GAP; version,
##  because crucial global variables are made read-only
##  (see <Ref Sect="More About Global Variables"/>)
##  and filters and methods are added to global tables.
##  <P/>
##  A partial solution to this problem is provided by the function
##  <Ref Func="Reread"/> (and related functions <C>RereadLib</C> etc.).
##  <C>Reread( <A>filename</A> )</C> sets the global variable
##  <Ref Var="REREADING"/> to <K>true</K>,
##  reads the file named by <A>filename</A> and then resets
##  <Ref Var="REREADING"/>.
##  Various system functions behave differently when <Ref Var="REREADING"/>
##  is set to <K>true</K>.
##  In particular, assignment to read-only global variables is permitted,
##  calls to <Ref Func="NewRepresentation"/>
##  and <Ref Func="NewInfoClass"/> with parameters identical to those
##  of an existing representation or info class will return the existing
##  object, and methods installed with
##  <Ref Func="InstallMethod"/> may sometimes displace
##  existing methods.
##  <P/>
##  This function may not entirely produce the intended results,
##  especially if what has changed is the super-representation of a
##  representation or the requirements of a method. In these cases, it is
##  necessary to restart &GAP; to read the modified file.
##  <P/>
##  An additional use of <Ref Func="Reread"/> is to load the compiled version
##  of a file for which the &GAP; language version had previously been read
##  (or perhaps was included in a saved workspace).
##  See <Ref Label="Kernel modules"/> and
##  <Ref Sect="Saving and Loading a Workspace"/> for more information.
##  <P/>
##  It is not advisable to use <Ref Func="Reread"/> programmatically.
##  For example, if a file that contains calls to <Ref Func="Reread"/>
##  is read with <Ref Func="Reread"/> then <Ref Var="REREADING"/> may be
##  reset too early.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
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
#E

