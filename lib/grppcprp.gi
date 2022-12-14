#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Bettina Eick.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for properties of polycyclic groups.
##

InstallMethod( IsNilpotentGroup,
               "method for pc groups",
               true,
               [IsGroup and CanEasilyComputePcgs],
               0,
function( G )
    local w;
    w := LGWeights( SpecialPcgs(G) );
    return w[Length(w)][1] = 1;
end);

InstallMethod( IsSupersolvableGroup,
               "method for pc groups",
               true,
               [IsGroup and CanEasilyComputePcgs],
               0,
function( G )
    local pr, spec, pcgs, p, sub, fac, mats, modu, facs;
    pr := PrimeDivisors(Size(G));
    spec := SpecialPcgs(G);
    pcgs := InducedPcgs( spec, FrattiniSubgroup( G ) );
    for p in pr do
        sub := InducedPcgsByPcSequenceAndGenerators( spec, pcgs,
               GeneratorsOfGroup( PCore(G, p) ) );
        if Length(sub) > Length(pcgs) then
            fac := sub mod pcgs;
            mats := LinearOperationLayer( G, fac );
            modu := GModuleByMats( mats, GF(p) );
            facs := MTX.CompositionFactors( modu );
            if not ForAll( facs, x -> x.dimension = 1 ) then
                return false;
            fi;
        fi;
    od;
    return true;
end);
