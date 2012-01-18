#############################################################################
##
#W subgroups.gi            POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of
## certain subgroups of matrix groups
##
#H  @(#)$Id: subgroups.gi,v 1.9 2011/09/23 13:36:33 gap Exp $
##
#Y 2004
##

#############################################################################
##
POL_Group := function( subGens, G )
    if Length( subGens ) = 0 then
        return TrivialSubgroup( G );
    else
        return Group( subGens );
    fi;
end;

#############################################################################
##
#F POL_TriangNSGFI_NonAbelianPRMGroup( arg )
##
##
##
## IN: arg[1] ..... G is an non-abelian  polycyclic rational matrix group
##     arg[2] ..... optional prime p
##
## OUT: Normal subgroup of finite index,
##      actually the p-congruence subgroup
##
InstallGlobalFunction( POL_TriangNSGFI_NonAbelianPRMGroup , function( arg )
    local   p, d, gens_p,G, bound_derivedLength, pcgs_I_p, gens_K_p,
            comSeries, gens_K_p_m, gens, gens_K_p_mutableCopy, pcgs,
            gensOfBlockAction, pcgs_nue_K_p, pcgs_GU, gens_U_p, pcgs_U_p,
            recordSeries, radSeries, isTriang, H;
    # setup
    G := arg[1];
    gens := GeneratorsOfGroup( G );
    d := Length(gens[1][1]);

    # determine an admissible prime or take the wished one
    if Length( arg ) = 2 then
        p := arg[2];
    else
        p := DetermineAdmissiblePrime(gens);
    fi;
    Info( InfoPolenta, 1, "Chosen admissible prime: " , p );
    Info( InfoPolenta, 1, "  " );

    # calculate the gens of the group phi_p(<gens>) where phi_p is
    # natural homomorphism to GL(d,p)
    gens_p := InducedByField( gens, GF(p) );

    # determine an upper bound for the derived length of G
    bound_derivedLength := d+2;

    # finite part
    Info( InfoPolenta, 1,"Determine a constructive polycyclic sequence\n",
          "    for the image under the p-congruence homomorphism ..." );
    pcgs_I_p := CPCS_finite_word( gens_p, bound_derivedLength );
    if pcgs_I_p = fail then return fail; fi;
    Info(InfoPolenta,1,"finished.");
    Info( InfoPolenta, 1, "Finite image has relative orders ",
                           RelativeOrdersPcgs_finite( pcgs_I_p ), "." );
    Info( InfoPolenta, 1, " " );

    # compute the normal the subgroup gens. for the kernel of phi_p
    Info( InfoPolenta, 1,"Compute normal subgroup generators for the kernel\n",
          "    of the p-congruence homomorphism ...");
    gens_K_p := POL_NormalSubgroupGeneratorsOfK_p( pcgs_I_p, gens );
    gens_K_p := Filtered( gens_K_p, x -> not x = IdentityMat(d) );
    Info( InfoPolenta, 1,"finished.");

       Info( InfoPolenta, 2,"The normal subgroup generators are" );
    Info( InfoPolenta, 2, gens_K_p );
    Info( InfoPolenta, 1, "  " );

    # radical series
    Info( InfoPolenta, 1, "Compute the radical series ...");
    gens_K_p_mutableCopy := CopyMatrixList( gens_K_p );
    recordSeries := POL_RadicalSeriesNormalGensFullData( gens,
                                                         gens_K_p_mutableCopy,
                                                         d );

    if recordSeries=fail then return fail; fi;
    radSeries := recordSeries.sers;
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 1, "The radical series has length ",
                          Length( radSeries ), "." );
    Info( InfoPolenta, 2, "The radical series is" );
    Info( InfoPolenta, 2, radSeries );
    Info( InfoPolenta, 1, " " );

    # test if G is unipotent by abelian
    isTriang := POL_TestIsUnipotenByAbelianGroupByRadSeries( gens, radSeries );
    if isTriang then
        return G;
    fi;

    # compositions series
    Info( InfoPolenta, 1, "Compute the composition series ...");
    comSeries := POL_CompositionSeriesByRadicalSeries( gens_K_p_mutableCopy,
                                                       d,
                                                   recordSeries.sersFullData,
                                                       1  );
    if comSeries=fail then return fail; fi;
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 1, "The composition series has length ",
                          Length( comSeries ), "." );
    Info( InfoPolenta, 2, "The composition series is" );
    Info( InfoPolenta, 2, comSeries );
    Info( InfoPolenta, 1, " " );

    # induce K_p to the factors of the composition series
    gensOfBlockAction := POL_InducedActionToSeries(gens_K_p, comSeries);

    # let nue be the homomorphism which induces the action of K_p to
    # the factors of the series
    Info( InfoPolenta, 1, "Compute a constructive polycyclic sequence\n",
     "    for the induced action of the kernel to the composition series ...");
    pcgs_nue_K_p := CPCS_AbelianSSBlocks_ClosedUnderConj( gens_K_p,
                                                       gens, comSeries );
    if pcgs_nue_K_p = fail then return fail; fi;
    Info(InfoPolenta,1,"finished.");

    # update generators of K_p
    gens_K_p := pcgs_nue_K_p.gens_K_p;
    pcgs_nue_K_p := pcgs_nue_K_p.pcgs_nue_K_p;
    Info( InfoPolenta, 1, "This polycyclic sequence has relative orders ",
                           pcgs_nue_K_p.relOrders, "."  );
    Info( InfoPolenta, 1, " " );

    return POL_Group( gens_K_p, G );

end );

#############################################################################
##
#F POL_TriangNSGFI_PRMGroup( arg )
##
## arg[1] = G is a rational polycyclic rational matrix group
##
InstallGlobalFunction( POL_TriangNSGFI_PRMGroup , function( arg )
    local G;
    G := arg[1];
    if IsAbelian( G ) then
        return  G;
    else
        if IsBound( arg[2] ) then
             return POL_TriangNSGFI_NonAbelianPRMGroup( arg[1], arg[2] );
        else
             return POL_TriangNSGFI_NonAbelianPRMGroup( G );
        fi;
    fi;
end );


# this code has to be reviewed. In the current form we can only assure,
# that it returns normal subgroup generators for K_p.
#############################################################################
##
#M TriangNormalSubgroupFiniteInd( G )
##
## G is a matrix group over the Rationals.
## Returned is triangularizable normal subgroup of finite index
##
##
#InstallMethod( TriangNormalSubgroupFiniteInd, "for polycyclic matrix groups",
#                true, [ IsMatrixGroup ], 0,
#function( G )
#        local test;
#        test := POL_IsMatGroupOverFiniteField( G );
#        if IsBool( test ) then
#            TryNextMethod();
#        elif test = 0 then
#            return  POL_TriangNSGFI_PRMGroup(G );
#        else
#            TryNextMethod();
#        fi;
#end) ;
#
#InstallOtherMethod( TriangNormalSubgroupFiniteInd,
#               "for polycyclic matrix groups", true,
#               [ IsMatrixGroup, IsInt], 0,
#function( G, p )
#        local test;
#        test := POL_IsMatGroupOverFiniteField( G );
#        if IsBool( test ) then
#            TryNextMethod();
#        elif test = 0 then
#            if not IsPrime(p) then
#                Print( "Second argument must be a prime number.\n" );
#                return fail;
#            fi;
#            return POL_TriangNSGFI_PRMGroup(G );
#         else
#            TryNextMethod();
#         fi;
#
#end );

#############################################################################
##
#M SubgroupsUnipotentByAbelianByFinite( G )
##
## G is a matrix group over the Rationals.
## Returned is triangularizable normal subgroup K of finite index
## and an unipotent normal subgroup U of K such that K/U is abelian.
##
InstallMethod( SubgroupsUnipotentByAbelianByFinite,
               "for polycyclic matrix groups (Polenta)",
                true, [ IsMatrixGroup ], 0,
function( G )
    local cpcs, U_p, K_p;
    if not IsRationalMatrixGroup( G ) then
       TryNextMethod( );
    fi;
    cpcs := CPCS_PRMGroup( G );
    if cpcs = fail then return fail; fi;
    if IsAbelian( G ) then
        U_p := cpcs.pcgs_U_p.pcs;
        return rec( T := G , U := POL_Group( U_p, G ));
    else
        U_p := cpcs.pcgs_U_p.pcs;
        # check if G is triangularizable
        if Length( cpcs.pcgs_GU.pcgs_I_p.gens ) = 0 then
            #G triangularizable
            return rec( T := G, U := POL_Group( U_p, G ));
        else
            #G not triangularizable
            K_p := cpcs.pcgs_GU.preImgsNue;
            K_p := Concatenation( K_p, U_p );
            return rec( T := POL_Group( K_p, G ), U := POL_Group( U_p, G ));
        fi;
    fi;
end );

InstallOtherMethod( SubgroupsUnipotentByAbelianByFinite ,
               "for polycyclic matrix groups (Polenta)", true,
               [ IsMatrixGroup, IsInt], 0,
function( G,p )
    local cpcs, U_p, K_p;
    if not IsRationalMatrixGroup( G ) then
       TryNextMethod( );
    fi;
    cpcs := CPCS_PRMGroup( G,p );
    if cpcs = fail then return fail; fi;
    if IsAbelian( G ) then
        U_p := cpcs.pcgs_U_p.pcs;
        return rec( T := G , U := POL_Group( U_p, G ));
    else
        U_p := cpcs.pcgs_U_p.pcs;
        # check if G is triangularizable
        if Length( cpcs.pcgs_GU.pcgs_I_p.gens ) = 0 then
            #G triangularizable
            return rec( T := G, U := POL_Group( U_p, G ));
        else
            #G not triangularizable
            K_p := cpcs.pcgs_GU.preImgsNue;
            K_p := Concatenation( K_p, U_p );
            return rec( T := POL_Group( K_p, G ), U := POL_Group( U_p, G ));
        fi;
    fi;
end );


#############################################################################
##
#E
