#############################################################################
##
#W  crystcat.grp                 GAP library                    Franz G"ahler
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

InstallMethod( NormalizerInGLnZ, 
    "for PointGroups of space groups from the cryst. groups catalogue",
    true, [ IsPointGroup ], 0,
function( P )
    local S, p, N, s, gen;
    S := AffineCrystGroupOfPointGroup( P );
    if not HasCrystCatRecord( S ) then
        TryNextMethod();
    fi;
    p := CrystCatRecord( S ).parameters;
    N := NormalizerZClass( p[1], p[2], p[3], p[4] );
    s := Size( N );
    if IsAffineCrystGroupOnRight( S ) then
        gen := List( GeneratorsOfGroup( N ), TransposedMat );
        N := GroupByGenerators( gen, One( N ) );
        SetSize( N, s );
    fi;
    return N;
end );
