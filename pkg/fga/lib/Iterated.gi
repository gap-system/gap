#############################################################################
##
#W  Iterated.gi             FGA package                    Christian Sievers
##
##  Method installations for variants of Iterated
##
##  Maybe this should move to the GAP library
##
#H  @(#)$Id: Iterated.gi,v 1.1 2003/03/21 14:38:01 gap Exp $
##
#Y  2003
##
Revision.("fga/lib/Iterated_gi") :=
    "@(#)$Id: Iterated.gi,v 1.1 2003/03/21 14:38:01 gap Exp $";


#############################################################################
##
#M  Iterated( <list>, <func>, <obj> )
##
##  applies <func> to <list> iteratively as Iterated does, but uses
##  <obj> as initial value.
##
InstallOtherMethod( Iterated,
    [ IsList, IsFunction, IsObject ],
    function (list, f, init)
    local x;
    for x in list do
        init := f(init, x);
    od;
    return init;
    end );


#############################################################################
##
#M  IteratedF( <list>, <func> )
##
##  applies <func> to <list> iteratively as Iterated does, but stops
##  and returns fail when <func> returns fail.
InstallMethod( IteratedF,
    [ IsList, IsFunction ],
    function (list, f)
    local res, i;
    if IsEmpty( list ) then
        Error( "IteratedF: <list> must contain at least one element" );
    fi;
    res := list[1];
    for i in [ 2 .. Length( list ) ] do
        if res = fail then
            break;
        fi;
        res := f( res, list[i] ); 
    od;
    return res;
    end );


#############################################################################
##
#M  IteratedF( <list>, <func>, <obj> )
##
##  applies <func> to <list> iteratively as Iterated does, but stops
##  and returns fail when <func> returns fail, and uses <obj> as
##  initial value.
InstallOtherMethod( IteratedF,
    [ IsList, IsFunction, IsObject ],
    function (list, f, init)
    local x;
    for x in list do
        init := f(init, x);
        if init=fail then
            break;
        fi;
    od;
    return init;
    end );


#############################################################################
##
#E
