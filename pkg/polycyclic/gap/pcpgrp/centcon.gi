############################################################################
##
#W  centcon.gi                  Polycyc                         Bettina Eick
##
##  Computing centralizers of elements and subgroups. 
##  Solving the conjugacy problem for elements.
##
if not IsBound( CHECK_CENT ) then CHECK_CENT := false; fi;

#############################################################################
##
#F AffineActionByElement( gens, pcp, g )
##
AffineActionByElement := function( gens, pcp, g )
    local lin, i, j, c;
    lin := LinearActionOnPcp( gens, pcp );
    for i in [1..Length(gens)] do
 
        # add column
        for j in [1..Length(lin[i])] do
            Add( lin[i][j], 0 );
        od;

        # add row
        c := ExponentsByPcp( pcp, Comm( g, gens[i] ) );
        Add( c, 1 );
        Add( lin[i], c );
    od;
    return lin;
end;

#############################################################################
##
#F IsCentralLayer( G, pcp )
##
IsCentralLayer := function( G, pcp )
    local g, h, e, f;
    for g in Igs(G) do
        for h in AsList(pcp) do
            e := ExponentsByPcp( pcp, Comm(g,h) );
            if e <> 0*e then return false; fi;
        od; 
    od;
    return true;
end;

#############################################################################
##
#F CentralizerByCentralLayer( gens, cent, pcp )
##
CentralizerByCentralLayer := function( gens, cent, pcp )
    local rels, g, matrix, null;
    rels := ExponentRelationMatrix( pcp );
    for g in gens do
        if Length( cent ) = 0 then return cent; fi;

        # set up matrix
        matrix := List( cent, h -> ExponentsByPcp( pcp, Comm(h,g) ) );
        Append( matrix, rels );

        # get nullspace
        null := PcpNullspaceIntMat( matrix );
        null := null{[1..Length(null)]}{[1..Length(cent)]};

        # calculate elements corresponding to null
        cent := List( null, x -> MappedVector( x, cent ) );
        cent := Filtered( cent, x -> x <> x^0 );
    od;
    return cent;
end;
 
#############################################################################
##
#F CentralizerBySeries(G, g, pcps)
##
##  possible improvements: - refine layers of given series by fixedpoints
##                         - use translation subgroup induced by layers
##
CentralizerBySeries := function( G, elms, pcps )
    local i, C, R, pcp, rel, p, d, e, N, M, gen, lin, stb, F, fac, act,
          nat, CM, NM, gM, g;

    # do a simple check
    elms := Filtered( elms, x -> x <> One(G) );
    if Length(elms) = 0 then return G; fi;

    # loop over series
    C := G;
    for i in [2..Length(pcps)] do

        # get infos on layer
        pcp := pcps[i];
        rel := RelativeOrdersOfPcp( pcp );
        p := rel[1];
        d := Length( rel );
        e := List( [1..d], x -> 0 ); Add( e, 1 );

        # if the layer is central
        if IsCentralLayer( C, pcp ) then 
            Info( InfoPcpGrp, 1, "got central layer of type ",p,"^",d);
            N := SubgroupByIgs( G, NumeratorOfPcp(pcp) );
            gen := Pcp(C, N);
            stb := CentralizerByCentralLayer( elms, AsList(gen), pcp );
            stb := AddIgsToIgs( stb, Igs(N) );
            C := SubgroupByIgs( G, stb );

        # if it is a non-central finite layer
        elif p > 0 then 
            Info( InfoPcpGrp, 1, "got finite layer of type ",p,"^",d);
            F := GF(p);
            M := SubgroupByIgs( G, DenominatorOfPcp(pcp) );
            for g in elms do
                fac := Pcp( C, M );
                act := AffineActionByElement( fac, pcp, g );
                act := InducedByField( act, F );
                stb := PcpOrbitStabilizer( e*One(F), fac, act, OnRight );
                stb := AddIgsToIgs( stb.stab, Igs(M) );
                C := SubgroupByIgs( G, stb );
            od;

        # if it is infinite and not-central
        else
            Info( InfoPcpGrp, 1, "got infinite layer of type ",p,"^",d);
            M := SubgroupByIgs( G, DenominatorOfPcp(pcp) );
            N := SubgroupByIgs( G, NumeratorOfPcp(pcp) );
            nat := NaturalHomomorphism( G, M );
            NM := Image( nat, N );
            CM := Image( nat, C );
            for g in elms do
                gM := Image( nat, g );
                if gM <> gM^0 then
                    act := AffineActionByElement( Pcp(CM), Pcp(NM), gM );
                    CM := StabilizerIntegralAction( CM, act, e );
                fi;
            od;
            C := PreImage( nat, CM );
        fi;
    od;
    
    # add checking if required
    if CHECK_CENT then 
        Print("check result \n");
        for g in elms do
            if ForAny( Igs(C), x -> Comm(g,x) <> One(G) ) then 
                Error("centralizer is not centralizing");
            fi;
        od;
    fi;

    # now return the result
    return C;
end;

#############################################################################
##
#F Centralizer
##
CentralizerPcpGroup := function( G, g )

    # get arguments 
    if IsPcpGroup(g) then 
        g := SmallGeneratingSet(g); 
    elif IsPcpElement(g) then
        g := [g];
    fi;

    # check
    if ForAny( g, x -> not x in G ) then
        Error("elements must be contained in group");
    fi;
        
    # compute
    return CentralizerBySeries( G, g, PcpsOfEfaSeries(G) );
end;

InstallMethod( CentralizerOp, "for a pcp group", true,
        [IsPcpGroup and IsNilpotentGroup, IsPcpElement], 0,
function( G, g ) return CentralizerNilpotentPcpGroup( G, g ); end );

InstallMethod( CentralizerOp, "for a pcp group", true,
        [IsPcpGroup and IsNilpotentGroup, IsPcpGroup], 0,
function( G, U ) return CentralizerNilpotentPcpGroup( G, U ); end );

InstallMethod( CentralizerOp, "for a pcp group", true,
        [IsPcpGroup, IsPcpElement], 0,
function( G, g ) return CentralizerPcpGroup( G, g ); end );

InstallMethod( CentralizerOp, "for a pcp group", true,
        [IsPcpGroup, IsPcpGroup], 0,
function( G, U ) return CentralizerPcpGroup( G, U ); end );

#############################################################################
##
#F ConjugacyByCentralLayer( g, h, cent, pcp )
##
ConjugacyByCentralLayer := function( g, h, cent, pcp )
    local matrix, c, solv, null;

    # first check
    c := ExponentsByPcp( pcp, g^-1 * h );
    if Length(cent) = 0 then 
        if c = 0*c then 
            return rec( stab := cent, prei := g^0 );
        else
            return false;
        fi;
    fi;

    # set up matrix
    matrix := List( cent, x -> ExponentsByPcp( pcp, Comm(x,g) ) );
    Append( matrix, ExponentRelationMatrix( pcp ) );
    
    # get solution
    solv := PcpSolutionIntMat( matrix, -c );
    if IsBool( solv ) then return false; fi;
    solv := solv{[1..Length(cent)]};
    
    # get nullspace
    null := PcpNullspaceIntMat( matrix );
    null := null{[1..Length(null)]}{[1..Length(cent)]};
    
    # calculate elements 
    solv := MappedVector( solv, cent );
    cent := List( null, x -> MappedVector( x, cent ) );
    cent := Filtered( cent, x -> x <> x^0 );
    return rec( stab := cent, prei := solv );
end;

#############################################################################
##
#F ConjugacyElementsBySeries( G, g, h, pcps )
##
ConjugacyElementsBySeries := function( G, g, h, pcps )
    local C, k, eg, eh, i, pcp, rel, p, d, 
          e, f, c, j, N, M, fac, stb, F, act, nat;

    # do a simple check
    if Order(g) <> Order(h) then return false; fi;

    # the first layer
    eg := ExponentsByPcp(pcps[1], g);
    eh := ExponentsByPcp(pcps[1], h);
    if eg <> eh then return false; fi;
    C := G;
    k := One(G);

    # the other layers
    for i in [2..Length(pcps)] do

        # get infos on layer
        pcp := pcps[i];
        rel := RelativeOrdersOfPcp( pcp );
        p := rel[1];
        d := Length( rel );

        # set up for computation
        e := List( [1..d], x -> 0 ); Add( e, 1 );
        c := g^k;
        if c = h then return k; fi;

        # if the layer is central
        if IsCentralLayer( C, pcp ) then

            Info( InfoPcpGrp, 1, "got central layer of type ",p,"^",d);
            N := SubgroupByIgs( G, NumeratorOfPcp(pcp) );
            fac := Pcp(C, N);
            stb := ConjugacyByCentralLayer( c, h, AsList(fac), pcp );

            # extract results
            if IsBool(stb) then return false; fi;
            k := k * stb.prei;
            stb := AddIgsToIgs( stb.stab, Igs(N) );
            C := SubgroupByIgs( G, stb );

        # if it is a non-central finite layer
        elif p > 0 then

            Info( InfoPcpGrp, 1, "got finite layer of type ",p,"^",d);
            F := GF(p);
            M := SubgroupByIgs( G, DenominatorOfPcp(pcp) );
            f := ExponentsByPcp( pcp, c^-1*h ); Add( f, 1 );
            fac := Pcp( C, M );
            act := AffineActionByElement( fac, pcp, c );
            act := InducedByField( act, F );
            stb := PcpOrbitStabilizer( e*One(F), fac, act, OnRight );

            # extract results
            j := Position( f*One(F), stb.orbit );
            if IsBool(j) then return false; fi;
            k := k * TransversalElement( j, stb, One(G) );
            stb := AddIgsToIgs( stb.stab, Igs(M) );
            C := SubgroupByIgs( G, stb );

        # if it is infinite and not-central
        else

            Info( InfoPcpGrp, 1, "got infinite layer of type ",p,"^",d);
            M := SubgroupByIgs( G, DenominatorOfPcp(pcp) );
            f := ExponentsByPcp( pcp, c^-1*h ); Add( f, 1 );
            fac := Pcp( C, M );
            act := AffineActionByElement( fac, pcp, g );
            nat := NaturalHomomorphism( C, M );
            stb := OrbitIntegralAction( Image(nat), act, e, f );

            # extract results
            if IsBool(stb) then return false; fi;
            C := PreImage( nat, stb.stab );
            k := k * PreImagesRepresentative( nat, stb.prei );
        fi;
    od;

    # add checking if required
    if CHECK_CENT then
        Info( InfoPcpGrp, 1, "check result");
        if g^k <> h then Error("conjugating element is incorrect"); fi;
    fi;

    # now return the result
    return k;
end;

#############################################################################
##
#F IsConjugate( G, g, h )
#F ConjugacyElementsPcpGroup( G, g, h )
##
ConjugacyElementsPcpGroup := function( G, g, h )

    # check
    if not g in Parent(G) or not h in Parent(G) then
        Error("arguments must have a common parent group");
    fi;

    # compute
    return ConjugacyElementsBySeries( G, g, h, PcpsOfEfaSeries(G) );
end;

InstallMethod( IsConjugate, "for a pcp group", true,
        [IsPcpGroup, IsPcpElement, IsPcpElement], 0,
function( G, g, h ) return ConjugacyElementsPcpGroup( G, g, h ); end );

