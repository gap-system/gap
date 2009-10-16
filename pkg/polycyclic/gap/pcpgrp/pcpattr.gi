#############################################################################
##
#W  pcpattr.gi                 Polycyc                           Bettina Eick
##
##  Some general attributes for pcp groups. Some of them are only available
##  for nilpotent pcp groups.
##

#############################################################################
##
#M MinimalGeneratingSet( G )
##
InstallMethod( MinimalGeneratingSet, "for pcp groups", true, [IsPcpGroup], 0,
function( G )
    if IsNilpotentGroup( G ) then 
        return MinimalGeneratingSetNilpotentPcpGroup(G);
    else
        Error("sorry: function is not installed");
    fi;
end );

#############################################################################
##
#M SmallGeneratingSet( G )
##
InstallMethod( SmallGeneratingSet, "for pcp groups", true, [IsPcpGroup], 0,
function( G )
    local g, s, U, i, V;
    if Size(G) = 1 then return []; fi;
    g := Igs(G);
    s := [g[1]];
    U := Subgroup( G, s );
    i := 1;
    while IndexNC(G,U) > 1 do
        i := i+1;
        Add( s, g[i] );
        V := Subgroup( G, s );
        if IndexNC(V, U) > 1 then
            U := V;
        else
            Unbind(s[Length(s)]);
        fi;
    od;
    return s;
end );

#############################################################################
##
#M SylowSubgroup( G, p )
##
InstallMethod( SylowSubgroupOp, true, [IsPcpGroup, IsPosInt], 0, 
function( G, p )
    if not IsFinite(G) then 
        Error("sorry: function is not installed");
    fi;
    TryNextMethod();
end );

