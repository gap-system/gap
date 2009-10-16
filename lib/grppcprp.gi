#############################################################################
##
#W  grppcprp.gi                 GAP Library                      Frank Celler
#W                                                             & Bettina Eick
##
#H  @(#)$Id: grppcprp.gi,v 4.6 2002/04/15 10:04:52 sal Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the methods for properties of polycylic groups.
##
Revision.grppcprp_gi :=
    "@(#)$Id: grppcprp.gi,v 4.6 2002/04/15 10:04:52 sal Exp $";

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
    pr := Set(FactorsInt(Size(G)));
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

#############################################################################
##

#E  grppcpprp.gi  . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
