#############################################################################
##
#W  betti.gi                                                    Karel Dekimpe
#W                                                               Bettina Eick
##

#############################################################################
##
## The following functions can be used to determine Betti-numbers of a
## torsion-free polycyclic group given by a pcp presentation. All 
## Betti-numbers can be obtained if G has Hirsch length at most 5.
##
## The Betti-numbers B(G,m) are defined as the ranks of H_m(G,Z) for the
## trivial G-module Z. If M is the orientation G-module, then we can also
## characterise B(G,m) for n >= m >= n-2 as the ranks of H^n-m(G,M). 
## Further, the alternating sum of all Betti-numbers is 0 using the
## Euler characteristic. 
##

#############################################################################
##
#F OrientationModule( G )
##
InstallMethod( OrientationModule, "for pcp groups", true, [IsPcpGroup], 0, 
function( G )
    local pcps, gens, mats, acts, dets, i, pcp;
    pcps := PcpsOfEfaSeries( G );
    pcps := Filtered( pcps, x -> RelativeOrdersOfPcp(x)[1] = 0 );
    gens := Igs(G);
    mats := List( gens, x -> IdentityMat( 1 ) );
    for pcp in pcps do
        acts := LinearActionOnPcp( gens, pcp );
        dets := List( acts, x -> Determinant( x ) );
        for i in [1..Length(mats)] do
            mats[i] := dets[i] * mats[i];
        od;
    od;
    return mats;
end );

#############################################################################
##
#F IsOrientedMatGroup( G )
##
IsOrientedMatGroup := function( G )
    return ForAll( GeneratorsOfGroup(G), x -> Determinant(x) = 1 );
end;

#############################################################################
##
#F BettiNumber( G, m )
##
BettiNumberPcpGroup := function(G,m)
    local n, pcp, mats, CR, one, two;

    if not IsTorsionFree( G ) then
        Print("the input group must be torsion-free \n");
        return fail;
    fi;

    # catch the trivial case
    if IsFinite(G) then 
        if m = 0 then 
            return 1;
        else
            return 0;
        fi;
    fi;

    # the hirsch length 
    n := HirschLength( G );

    if m < 0 or m > n then return 0; fi;

    if m = 0 then return 1; fi;

    if m = 1 then 
        pcp := Pcp( G, DerivedSubgroup(G) );
        return Length( Filtered( RelativeOrdersOfPcp( pcp ),x -> x=0 ));
    fi;

    if m = n then
        mats := OrientationModule( G );
        if ForAny( mats, x -> x[1][1] = -1 ) then 
            return 0;
        else
            return 1;
        fi;
    fi;

    if m = 2 then
        mats := List( Pcp(G), x -> IdentityMat(1) );
        CR := CRRecordByMats( G, mats );
        two := TwoCohomologyCR( CR ).factor.rels;
        return Length( Filtered( two, x -> x = 0 ) );
    fi;

    if m = n-1 then
        mats := OrientationModule( G );
        CR := CRRecordByMats( G, mats );
        one := OneCohomologyCR( CR ).factor.rels;
        return Length( Filtered( one, x -> x = 0 ) );
    fi;

    if m = n-2 then
        mats := OrientationModule( G );
        CR := CRRecordByMats( G, mats );
        two := TwoCohomologyCR( CR ).factor.rels;
        return Length( Filtered( two, x -> x = 0 ) );
    fi;

    Print("Betti-number is out of range for our methods \n");
    return fail;
end;

InstallMethod( BettiNumber, "for torsion-free pcp groups", true,
   [IsPcpGroup, IsInt], 0,
function(G, m)
    if not IsTorsionFree(G) then TryNextMethod(); fi;
    if m in [3..HirschLength(G)-3] then TryNextMethod(); fi;
    return BettiNumberPcpGroup(G,m);
end); 
    
#############################################################################
##
#F BettiNumbers( G )
##
InstallMethod( BettiNumbers, "for torsion-free pcp groups", true,
    [IsPcpGroup], 0,
function( G )
    local n, betti;

    n := HirschLength( G );
    if not IsTorsionFree( G ) or n > 6 then TryNextMethod(); fi;

    # set up the Betti-numbers 
    betti := [1];
    if n = 0 then return betti; fi;
    betti[2] := BettiNumber( G, 1 );
    if n = 1 then return betti; fi;
    betti[3] := BettiNumber( G, 2 );
    if n = 2 then return betti; fi;
    betti[4] := betti[1] - betti[2] + betti[3];
    if n = 3 then return betti; fi;
    if n > 3 then 
        betti[5] := BettiNumber( G, 4 );
        betti[4] := betti[4] + betti[5];
    fi;
    if n > 4 then 
        betti[6] := BettiNumber( G, 5 );
        betti[4] := betti[4] - betti[6];
    fi;
    if n > 5 then 
        betti[7] := BettiNumber( G, 6 );
        betti[4] := betti[4] + betti[7];
    fi;
    return betti;
end );

