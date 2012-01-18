#############################################################################
##
#W isom.gi                 POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of
## isomorphisms from matrix groups to pcp-presentations
##
#H  @(#)$Id: isom.gi,v 1.13 2011/09/26 19:07:16 gap Exp $
##
#Y 2003
##

#############################################################################
##
#F POL_IsomorphismToMatrixGroup_infinite
##
POL_IsomorphismToMatrixGroup_infinite := function( arg )
    local CPCS, pcp, H, nat,G;
    G := arg[1];
    # calculate a constructive pc-sequence
    if Length( arg ) = 2 then
        CPCS := CPCS_PRMGroup( G, arg[2] );
    else
        CPCS := CPCS_PRMGroup( G );
    fi;
    if CPCS = fail then return fail; fi;
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Compute the relations of the polycyclic\n",
          "    presentation of the group ..." );
    pcp := POL_SetPcPresentation_infinite( CPCS );
    Info( InfoPolenta, 1,"finished." );
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Construct the polycyclic presented group ..." );
    H := PcpGroupByCollector( pcp );
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Construct the isomorphism on the polycyclic\n",
          "    presented group ..." );
    nat := GroupHomomorphismByImagesNC( G, H, CPCS.pcs, AsList(Pcp(H)) );
    Info( InfoPolenta, 1,"finished.");

    # add infos
    SetIsBijective( nat, true );
    SetIsIsomorphismByPolycyclicMatrixGroup( nat, true );

    nat!.CPCS := CPCS;
    return nat;
end;

#############################################################################
##
#F POL_IsomorphismToMatrixGroup_finite
##
POL_IsomorphismToMatrixGroup_finite := function( G )
    local CPCS, pcp, H, nat, gens, d, pcs, bound_derivedLength;

     Info( InfoPolenta, 1,"Determine a constructive polycyclic sequence\n",
           "    for the input group ...");
    # calculate a constructive pc-sequence
    gens := GeneratorsOfGroup( G );
    d := Length(gens[1][1]);
    # determine an upper bound for the derived length of G
    bound_derivedLength := d+2;
    CPCS := CPCS_finite_word( gens, bound_derivedLength );
    if CPCS = fail then return fail; fi;
    Info( InfoPolenta, 1, "finished." );
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Compute the relations of the polycyclic\n",
          "    presentation of the group ..." );
    pcp := POL_SetPcPresentation_finite( CPCS );
    Info( InfoPolenta, 1,"finished." );
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Construct the polycyclic presented group ..." );
    H := PcpGroupByCollector( pcp );
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 1, " " );

    # new generating set for G
    pcs := Reversed(CPCS.gens);
    Info( InfoPolenta, 1,"Construct the isomorphism on the polycyclic\n",
          "    presented group ..." );
    nat := GroupHomomorphismByImagesNC( G, H, pcs, AsList(Pcp(H)) );
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 1, " " );

    # add infos
    SetIsBijective( nat, true );
    SetIsIsomorphismByFinitePolycyclicMatrixGroup( nat, true );

    nat!.CPCS := CPCS;
    return nat;
end;

#############################################################################
##
#M Create isom to pcp group
##
InstallMethod( IsomorphismPcpGroup,
               "for matrix groups over a finite field (Polenta)", true,
               [ IsFFEMatrixGroup ], 0,
               POL_IsomorphismToMatrixGroup_finite );

InstallMethod( IsomorphismPcpGroup,
               "for rational matrix groups (Polenta)", true,
               [ IsRationalMatrixGroup ], 0,
               POL_IsomorphismToMatrixGroup_infinite );

## Enforce rationality check for cyclotomic matrix groups
RedispatchOnCondition( IsomorphismPcpGroup, true,
    [ IsCyclotomicMatrixGroup ], [ IsRationalMatrixGroup ],
    RankFilter(IsCyclotomicMatrixGroup) );


InstallOtherMethod( IsomorphismPcpGroup,
                    "for matrix groups (Polenta)", true,
                    [IsCyclotomicMatrixGroup, IsInt], 0,
function( G, p )
    if IsRationalMatrixGroup( G ) then
        if not IsPrime(p) then
            Print( "Second argument must be a prime number.\n" );
            return fail;
        fi;
        return POL_IsomorphismToMatrixGroup_infinite( G, p );
    fi;
    TryNextMethod();
end);


#############################################################################
##
#M Images under IsomorphismByPolycyclicMatrixGroup
##
InstallMethod( ImagesRepresentative,
               "for isom by matrix groups (Polenta)",
               FamSourceEqFamElm,
               [IsGroupGeneralMappingByImages and IsIsomorphismByPolycyclicMatrixGroup, IsMultiplicativeElementWithInverse],
               0,
function( nat, h )
    local H, e, CPCS;
    CPCS := nat!.CPCS;
    H := Range( nat );
    e := ExponentVector_CPCS_PRMGroup( h, CPCS );
    if e=fail then return fail; fi;
    if Length(e)=0 then return OneOfPcp( Pcp( H ) );fi;
    return MappedVector( e, Pcp(H) );
end);

#############################################################################
##
#M Images under IsomorphismByFinitePolycyclicMatrixGroup
##
InstallMethod( ImagesRepresentative,
               "for isom by finite matrix groups (Polenta)",
               FamSourceEqFamElm,
               [IsGroupGeneralMappingByImages and IsIsomorphismByFinitePolycyclicMatrixGroup, IsMultiplicativeElementWithInverse],
               0,
function( nat, h )
    local H, e, CPCS;
    CPCS := nat!.CPCS;
    H := Range( nat );
    e := ExponentvectorPcgs_finite( CPCS, h );
    if e=fail then return fail; fi;
    if Length(e)=0 then return OneOfPcp( Pcp( H ) );fi;
    return MappedVector( e, Pcp(H) );
end);


#############################################################################
##
#E
