#############################################################################
##
#W  wpobj.gi                     GAP library                 Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  
##
##  This file contains the implementations for weak pointer objects
##
Revision.wpobj_gi :=
  "@(#)$Id$";

#############################################################################
##
#M  <wp> [<pos>]  access function for weak pointer objects   
##
##  We cannot use the kernel function directly, as it returns fail for unbound
##  see comments in wpobj.gd for the reason.
##

InstallMethod(\[\], 
        "method for a weak pointer object",
        true,
        [ IsWeakPointerObject, IsInt and IsPosRat ],
        0,
        function( wp, pos)
    local elm;
    elm := ElmWPObj(wp, pos);
    if elm <> fail or IsBoundElmWPObj(wp,pos) then
        return elm;
    else
        Error("<wpobj>[<pos>] must have a value.");
    fi;
end);

#############################################################################
##
#M <wp> [<pos>] := <obj>  weak pointer object member assignment
##

InstallMethod(\[\]\:\=, 
        "method for a weak pointer object",
        true,
        [ IsWeakPointerObject, IsInt and IsPosRat, IsObject ],
        0,
        SetElmWPObj);
        
#############################################################################
##
#M  Length( <wp> ) note that the answer may not stay valid
##

InstallMethod(Length, 
        "method for a weak pointer object",
        true,
        [ IsWeakPointerObject ],
        0,
        LengthWPObj);

#############################################################################
##
#M  IsBound(<wp>[<pos>]) note that the answer may not stay valid
##

InstallMethod(IsBound\[\], 
        "method for a weak pointer object",
        true,
        [ IsWeakPointerObject, IsInt and IsPosRat ],
        0,
        IsBoundElmWPObj);


#############################################################################
##
#M  Unbind(<wp>[<pos>]) 
##

InstallMethod(Unbind\[\], 
        "method for a weak pointer object",
        true,
        [ IsWeakPointerObject, IsInt and IsPosRat ],
        0,
        UnbindElmWPObj);


#############################################################################
##
#M  Print method, ~ is not supported, so self-referential weak pointer
##  objects cannot be printed
##

InstallMethod(PrintObj,   
        "method for a weak pointer object",
        true,
        [ IsWeakPointerObject ],
        0,
        function(wp)
    local i,l,x;
    Print("WeakPointerObj( [ ");
    l := Length(wp);
    if l <> 0 then
        if IsBound(wp[1]) then
            PrintObj(wp[1]);
        fi;
        for i in [2..l] do
            Print(", ");
            if IsBound(wp[i]) then
                x := wp[i];
                PrintObj(x);
            fi;
        od;
    fi;
    Print("] )");
end);


#############################################################################
##
#M  ShallowCopy(<wp>)  
##
##  Note that we do not use wp[i] access (see wpobj.gd for explanation)
##

InstallMethod(ShallowCopy,
        "method for a weak pointer object",
        true,
        [ IsWeakPointerObject ],
        0,
        function(wp)
    local w,i,l,x;
    w := WeakPointerObj([]);
    l := Length(wp);
    for i in [1..l] do
        x := ElmWPObj(wp,i);
        if x <> fail or IsBound(wp[i]) then
            w[i] := x;
        fi;
    od;
    return w;
end);


