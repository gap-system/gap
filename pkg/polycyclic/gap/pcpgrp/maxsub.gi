#############################################################################
##
#W  maxsub.gi                    Polycyc                         Bettina Eick
##
##  Maximal subgroups of p-power index.
##

#############################################################################
##
#F MaximalSubgroupsByLayer := function( G, pcp, p )
##
## A/B is an efa layer of G. We compute the maximal subgroups of p-index
## of G which do not contain A/B.
##
MaximalSubgroupsByLayer := function( G, pcp, p )
    local q, C, invs, max, inv, t, D, new;

    # get characteristic
    if Length( pcp ) = 0 then return []; fi;
    q := RelativeOrdersOfPcp( pcp )[1];
    if q <> 0 and q <> p then return []; fi;
    if q = 0 then 
        new := List( pcp, x -> x ^ p );
        new := AddIgsToIgs( new, DenominatorOfPcp( pcp ) );
        new := SubgroupByIgs( G, new );
        new := Pcp( GroupOfPcp( pcp ), new );
    else
        new := pcp;
    fi;

    # set up class record
    C := rec( );
    C.group  := G;
    C.super  := [];
    C.factor := Pcp( G, GroupOfPcp( pcp ) );
    C.normal := new;

    # add field
    C.char := p;
    C.field := GF(p);
    C.dim  := Length( pcp );
    C.one  := IdentityMat( C.dim, C.field );

    # add extension info
    AddRelatorsCR( C );
    AddOperationCR( C );
    
    # if it is a trivial factor
    if Length( pcp ) = 1 then
        AddInversesCR( C );
        t := ComplementClassesCR( C );
    fi;

    # get maximal subgroups
    invs := SMTX.BasesMaximalSubmodules(GModuleByMats(C.mats, C.dim, C.field));

    # loop trough
    max := [];
    for inv in invs do
        D := InduceToFactor( C, rec( repr := inv, stab := [] ) );
        AddInversesCR( D );
        t := ComplementClassesCR( D );
        Append( max, t );
    od;
    return max;
end;

#############################################################################
##
#F  MaximalSubgroupClassesByIndex( G, p ) 
##
##  The conjugacy classes of maximal subgroups of p-power index in G.
##
MaximalSubgroupClassesByIndexPcpGroup := function( G, p )
    local pcp, max, i, tmp;

    # loop over series and determine subgroups
    pcp := PcpsOfEfaSeries( G );
    max := [];
    for i in [1..Length(pcp)] do
        Append( max, MaximalSubgroupsByLayer( G, pcp[i], p ) );
    od;

    # translate to classes and return
    for i in [1..Length(max)] do
        tmp := ConjugacyClassSubgroups( G, max[i].repr );
        SetStabilizerOfExternalSet( tmp, max[i].norm );
        max[i] := tmp;
    od;
    return max;
end;

InstallMethod( MaximalSubgroupClassesByIndexOp, "for pcp groups", 
               true, [IsPcpGroup, IsPosInt], 0,
function( G, p ) return MaximalSubgroupClassesByIndexPcpGroup( G, p ); end ); 
