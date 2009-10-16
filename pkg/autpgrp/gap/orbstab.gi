#############################################################################
##
#W  orbstab.gi              AutPGrp package                      Bettina Eick
##
#H  @(#)$Id: orbstab.gi,v 1.4 2003/08/18 12:10:28 gap Exp $
##
Revision.("autpgrp/gap/orbstab_gi") :=
    "@(#)$Id: orbstab.gi,v 1.4 2003/08/18 12:10:28 gap Exp $";

#############################################################################
##
#F BasesCompositionSeriesThrough( M, base )
##
BasesCompositionSeriesThrough := function( M, base )
    local full, chop, indu, smll, i, facb;

    full := IdentityMat( M.dimension, M.field );
    chop := [[]];

    # chop N
    if Length( base ) > 0 then
        indu := MTX.InducedActionSubmoduleNB( M, base );
        smll := MTX.BasesCompositionSeries( indu );
        for i in [2..Length( smll )] do
            smll[i] := smll[i] * base;
            Add( chop, EcheloniseMat( smll[i] ) );
        od;
    fi;

    # chop M/N
    if Length( base ) < Length( full ) then
        indu := MTX.InducedActionFactorModuleWithBasis( M, base );
        facb := indu[2];
        indu := indu[1];
        smll := MTX.BasesCompositionSeries( indu );
        for i in [2..Length( smll )] do
            smll[i] := smll[i] * facb;
            Append( smll[i], base );
            Add( chop, EcheloniseMat( smll[i] ) );
        od;
    fi;

    return chop;
end;

#############################################################################
##
#F PGOrbitStabilizer( <A>, <baseU>, <baseN>, <interrupt> )
##
InstallGlobalFunction( PGOrbitStabilizer, 
    function( A, baseU, baseN, interrupt )
    local u, n, l, baseM, str, glMats, agMats, mats, modu, chop;

    # set up and catch some trivial cases 
    u := Length( baseU );
    n := Length( baseN );
    if u = 0 or ( A.glOrder = 1 and Length( A.agOrder ) = 0 ) then
        return; 
    fi;

    l := Length( baseU[1] );
    baseM := IdentityMat( l, A.field );
    if l = u then return; fi;

    # print some info
    Info( InfoAutGrp, 3, "  dim U = ",u, "  dim N = ",n, "  dim M = ",l );

    # check interrupt
    if interrupt then
        str := Interrupt("chop M/N and N: (y/n)");
        if str = "y" then
            CHOP_MULT := true;
        elif str = "n" then
            CHOP_MULT := false;
        else
            Print("not a valid argument");
            return;
        fi;
    fi;

    # compute series
    glMats := List( A.glAutos, x -> x!.mat );
    agMats := List( A.agAutos, x -> x!.mat );
    mats   := Filtered( Concatenation( glMats, agMats ), x -> x<>1 );
    modu := GModuleByMats( mats, l, A.field );
    chop := [[], baseN, baseM];

    if CHOP_MULT then
        chop := BasesCompositionSeriesThrough( modu, chop[2] );
    fi;

    PGOrbitStabilizerBySeries( A, baseU, chop );
end );
